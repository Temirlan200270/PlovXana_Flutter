import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_SERVICE_ACCOUNT_JSON = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON")!;

type WebhookPayload = {
  type: "UPDATE";
  table: string;
  record: { id: string; user_id: string; status: string };
  old_record: { status: string };
};

const MESSAGES: Record<string, Record<string, { title: string; body: string }>> = {
  ru: {
    confirmed: {
      title: "Заказ подтверждён",
      body: "Ресторан принял ваш заказ",
    },
    done: {
      title: "Заказ выполнен",
      body: "Приятного аппетита!",
    },
  },
  kk: {
    confirmed: {
      title: "Тапсырыс расталды",
      body: "Мейрамхана тапсырысыңызды қабылдады",
    },
    done: {
      title: "Тапсырыс орындалды",
      body: "Ас болсын!",
    },
  },
};

const ALLOWED: Record<string, string> = {
  pending: "confirmed",
  confirmed: "done",
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const payload = (await req.json()) as WebhookPayload;
    if (payload.table !== "orders" || payload.type !== "UPDATE") {
      return new Response(JSON.stringify({ skipped: true }), { status: 200 });
    }

    const oldStatus = payload.old_record?.status;
    const newStatus = payload.record?.status;
    if (!oldStatus || !newStatus || oldStatus === newStatus) {
      return new Response(JSON.stringify({ skipped: true }), { status: 200 });
    }

    if (ALLOWED[oldStatus] !== newStatus) {
      return new Response(JSON.stringify({ skipped: true, reason: "transition" }), {
        status: 200,
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: tokens, error } = await supabase
      .from("push_tokens")
      .select("fcm_token, locale")
      .eq("user_id", payload.record.user_id);

    if (error) throw error;
    if (!tokens?.length) {
      return new Response(JSON.stringify({ sent: 0 }), { status: 200 });
    }

    const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_JSON);
    const accessToken = await getGoogleAccessToken(serviceAccount);

    let sent = 0;
    for (const row of tokens) {
      const locale = row.locale === "kk" ? "kk" : "ru";
      const msg = MESSAGES[locale][newStatus];
      if (!msg) continue;

      const ok = await sendFcm(
        accessToken,
        serviceAccount.project_id,
        row.fcm_token,
        msg.title,
        msg.body,
        payload.record.id,
      );
      if (ok) sent++;
    }

    return new Response(JSON.stringify({ sent }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});

async function getGoogleAccessToken(sa: {
  client_email: string;
  private_key: string;
  token_uri?: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlEncode(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = base64UrlEncode(
    JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: sa.token_uri ?? "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  );
  const unsigned = `${header}.${claim}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64UrlEncode(signature)}`;

  const res = await fetch(sa.token_uri ?? "https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await res.json();
  if (!json.access_token) throw new Error("No access_token from Google");
  return json.access_token as string;
}

async function sendFcm(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  orderId: string,
): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: { route: "/orders", order_id: orderId },
        },
      }),
    },
  );
  if (!res.ok) {
    console.error(await res.text());
    return false;
  }
  return true;
}

function base64UrlEncode(data: string | ArrayBuffer): string {
  const bytes =
    typeof data === "string"
      ? new TextEncoder().encode(data)
      : new Uint8Array(data);
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}
