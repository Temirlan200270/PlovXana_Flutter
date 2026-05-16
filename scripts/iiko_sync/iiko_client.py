"""
iiko Cloud API client.
Auth + nomenclature + stop lists. All calls are async via httpx.
"""

import asyncio
import logging
from collections.abc import Mapping
from typing import Any

import httpx

logger = logging.getLogger(__name__)

IIKO_BASE_URL = "https://api-ru.iiko.services"
REQUEST_TIMEOUT = 15.0
MAX_RETRIES = 2
RETRY_DELAY = 1.0


class IikoClient:
    def __init__(self, api_login: str) -> None:
        self._api_login = api_login
        self._token: str | None = None
        self._http: httpx.AsyncClient | None = None

    async def __aenter__(self) -> "IikoClient":
        self._http = httpx.AsyncClient(base_url=IIKO_BASE_URL, timeout=REQUEST_TIMEOUT)
        await self._authenticate()
        return self

    async def __aexit__(self, *args: Any) -> None:
        if self._http:
            await self._http.aclose()

    async def _ensure_token(self) -> None:
        if not self._token:
            await self._authenticate()

    async def _authenticate(self) -> None:
        if not self._http:
            raise RuntimeError("HTTP client not initialized. Use async with.")
        response = await self._http.post(
            "/api/1/access_token",
            json={"apiLogin": self._api_login},
        )
        response.raise_for_status()
        self._token = response.json().get("token")
        if not self._token:
            raise ValueError("iiko API did not return an auth token")
        logger.info("iiko: authenticated")

    def _auth_headers(self) -> dict[str, str]:
        if not self._token:
            raise RuntimeError("No token. Call _authenticate() first.")
        return {"Authorization": f"Bearer {self._token}"}

    async def _request(
        self,
        method: str,
        path: str,
        *,
        json: Mapping[str, Any] | None = None,
        timeout: float | None = None,
        retry_transient: bool = True,
    ) -> dict[str, Any]:
        if not self._http:
            raise RuntimeError("HTTP client not initialized.")

        await self._ensure_token()

        last_exc: Exception | None = None
        refreshed = False
        max_attempts = MAX_RETRIES if retry_transient else 1

        for attempt in range(1, max_attempts + 1):
            try:
                response = await self._http.request(
                    method=method,
                    url=path,
                    headers=self._auth_headers(),
                    json=dict(json) if json is not None else None,
                    timeout=timeout,
                )

                if response.status_code == 401 and not refreshed:
                    logger.warning("iiko: 401 on %s %s — re-authenticating", method, path)
                    await self._authenticate()
                    refreshed = True
                    response = await self._http.request(
                        method=method,
                        url=path,
                        headers=self._auth_headers(),
                        json=dict(json) if json is not None else None,
                        timeout=timeout,
                    )

                if response.status_code >= 400:
                    logger.error(
                        "iiko: %s %s HTTP %s (attempt %d/%d). body=%s",
                        method, path, response.status_code,
                        attempt, max_attempts, (response.text or "")[:2000],
                    )

                response.raise_for_status()
                data = response.json()
                if not isinstance(data, dict):
                    raise ValueError("iiko API returned unexpected JSON (expected object)")
                return data

            except (httpx.TimeoutException, httpx.ConnectError) as exc:
                last_exc = exc
                logger.warning("iiko: network error %s %s (attempt %d/%d): %s", method, path, attempt, max_attempts, exc)
            except httpx.HTTPStatusError as exc:
                last_exc = exc
                status = exc.response.status_code if exc.response is not None else 0
                if status >= 500:
                    logger.warning("iiko: 5xx %s %s (attempt %d/%d)", method, path, attempt, max_attempts)
                else:
                    raise

            if attempt < max_attempts:
                await asyncio.sleep(RETRY_DELAY * attempt)

        raise last_exc or RuntimeError(f"iiko: failed {method} {path}")

    async def get_organizations(self) -> list[dict[str, Any]]:
        data = await self._request("POST", "/api/1/organizations", json={})
        orgs = data.get("organizations", [])
        logger.info("iiko: found %d organizations", len(orgs))
        return orgs

    async def get_nomenclature(self, organization_id: str) -> dict[str, Any]:
        data = await self._request(
            "POST",
            "/api/1/nomenclature",
            json={"organizationId": organization_id},
            timeout=60.0,
        )
        logger.info(
            "iiko: loaded %d groups, %d products",
            len(data.get("groups", [])),
            len(data.get("products", [])),
        )
        return data

    async def fetch_menu(self, organization_id: str) -> dict[str, Any]:
        return await self.get_nomenclature(organization_id)

    async def get_stop_lists(self, organization_ids: list[str]) -> dict[str, Any]:
        data = await self._request("POST", "/api/1/stop_lists", json={"organizationIds": organization_ids})
        logger.info("iiko: stop lists received for %d organizations", len(organization_ids))
        return data
