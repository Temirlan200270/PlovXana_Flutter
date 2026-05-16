"""
iiko → Supabase menu sync for plovxana.

Syncs categories and menu_items by iiko_id (UUID).
Stop list sync sets is_available=False for out-of-stock items.
"""

import logging
from typing import Any

from supabase import create_client, Client

from iiko_client import IikoClient

logger = logging.getLogger(__name__)

_IIKO_TYPES_DISH_GOOD = frozenset({"Dish", "Good", "Product"})


# ---------------------------------------------------------------------------
# Helpers (from RestoMind menu_sync.py — unchanged logic)
# ---------------------------------------------------------------------------

def _iiko_uuid_ref(raw: Any) -> str:
    if raw is None:
        return ""
    if isinstance(raw, str):
        return raw.strip()
    if isinstance(raw, dict):
        for k in ("id", "Id", "ID"):
            v = raw.get(k)
            if v and str(v).strip():
                return str(v).strip()
    return ""


def _merge_group_maps(nomenclature: dict[str, Any]) -> dict[str, str]:
    """iiko group id → display name (recursive, handles childGroups)."""
    merged: dict[str, str] = {}

    def take(node: dict[str, Any]) -> None:
        gid = str(node.get("id") or "").strip()
        gnm = str(node.get("name") or "").strip() or "Без категории"
        if gid:
            merged[gid] = gnm

    def walk(node: dict[str, Any]) -> None:
        take(node)
        for key in ("childGroups", "childgroups"):
            for ch in node.get(key) or []:
                if isinstance(ch, dict):
                    walk(ch)

    for g in nomenclature.get("groups") or []:
        if isinstance(g, dict):
            walk(g)

    for alt_key in ("productCategories", "categories"):
        for c in nomenclature.get(alt_key) or []:
            if isinstance(c, dict):
                take(c)

    return merged


def _product_category_uuid(product: dict[str, Any]) -> str:
    for key in ("parentGroup", "ParentGroup"):
        if key in product:
            u = _iiko_uuid_ref(product[key])
            if u:
                return u
    for key in ("groupId", "productCategoryId"):
        u = _iiko_uuid_ref(product.get(key))
        if u:
            return u
    return ""


def _dedupe_products(raw: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id: dict[str, dict[str, Any]] = {}
    ordered: list[str] = []
    for p in raw:
        sid = str(p.get("id") or "").strip()
        if not sid:
            continue
        if sid not in by_id:
            ordered.append(sid)
        by_id[sid] = p
    return [by_id[i] for i in ordered]


def _extract_price(product: dict[str, Any]) -> int:
    """Returns price in tenge as integer."""
    size_prices = product.get("sizePrices") or []
    if size_prices and isinstance(size_prices[0], dict):
        price_obj = size_prices[0].get("price")
        if isinstance(price_obj, dict):
            v = price_obj.get("currentPrice")
            if v is not None:
                return int(float(v))
        if isinstance(price_obj, (int, float)):
            return int(price_obj)

    price_cats = product.get("priceCategories") or []
    if price_cats and isinstance(price_cats[0], dict):
        v = price_cats[0].get("price")
        if isinstance(v, (int, float)):
            return int(v)
        if isinstance(v, dict) and v.get("currentPrice") is not None:
            return int(float(v["currentPrice"]))

    raw = product.get("price")
    if isinstance(raw, (int, float)):
        return int(raw)

    return 0


def _include_product(product: dict[str, Any]) -> bool:
    t = product.get("type")
    if t is None or t == "":
        return True
    return str(t) in _IIKO_TYPES_DISH_GOOD


# ---------------------------------------------------------------------------
# Category sync
# ---------------------------------------------------------------------------

def _sync_categories(
    supabase: Client,
    groups_map: dict[str, str],
) -> dict[str, str]:
    """
    Upsert categories by iiko_id.
    Returns: {iiko_id → supabase_uuid} for FK resolution in menu items.
    """
    if not groups_map:
        return {}

    existing_result = supabase.table("categories").select("iiko_id").execute()
    existing_ids = {row["iiko_id"] for row in existing_result.data if row.get("iiko_id")}

    new_rows: list[dict] = []
    update_rows: list[dict] = []
    for i, (iiko_id, name) in enumerate(groups_map.items()):
        sid = str(iiko_id)
        if sid in existing_ids:
            update_rows.append({"iiko_id": sid, "name": name})
        else:
            new_rows.append({"iiko_id": sid, "name": name, "sort_order": i})

    if new_rows:
        supabase.table("categories").insert(new_rows).execute()
        logger.info("categories: inserted %d new rows", len(new_rows))
    for row in update_rows:
        supabase.table("categories").update({"name": row["name"]}).eq("iiko_id", row["iiko_id"]).execute()
    if update_rows:
        logger.info("categories: updated name for %d existing rows (sort_order preserved)", len(update_rows))

    result = supabase.table("categories").select("id, iiko_id").execute()
    return {row["iiko_id"]: row["id"] for row in result.data if row.get("iiko_id")}


# ---------------------------------------------------------------------------
# Menu items sync
# ---------------------------------------------------------------------------

def sync_menu_from_iiko(
    supabase: Client,
    api_login: str,
    organization_id: str,
) -> dict[str, Any]:
    import asyncio
    return asyncio.run(_async_sync_menu(supabase, api_login, organization_id))


async def _async_sync_menu(
    supabase: Client,
    api_login: str,
    organization_id: str,
) -> dict[str, Any]:
    async with IikoClient(api_login=api_login) as client:
        nomenclature = await client.fetch_menu(organization_id)

    groups_map = _merge_group_maps(nomenclature)
    iiko_to_supabase_cat = _sync_categories(supabase, groups_map)

    raw_products = [p for p in (nomenclature.get("products") or []) if isinstance(p, dict)]
    products = _dedupe_products(raw_products)

    existing_images_res = (
        supabase.table("menu_items").select("iiko_id, image_url").execute()
    )
    existing_images: dict[str, str] = {
        row["iiko_id"]: row["image_url"]
        for row in existing_images_res.data
        if row.get("iiko_id") and row.get("image_url")
    }

    skip_no_id = skip_deleted = skip_type = skip_no_name = skip_no_category = 0
    rows_to_upsert: list[dict[str, Any]] = []

    for product in products:
        sid = str(product.get("id") or "").strip()
        if not sid:
            skip_no_id += 1
            continue
        if bool(product.get("isDeleted")):
            skip_deleted += 1
            continue
        if not _include_product(product):
            skip_type += 1
            continue

        name = (product.get("name") or "").strip()
        if not name:
            skip_no_name += 1
            continue

        cat_iiko_id = _product_category_uuid(product)
        category_id = iiko_to_supabase_cat.get(cat_iiko_id)
        if not category_id:
            skip_no_category += 1
            logger.debug("Skipping '%s' — category %s not found", name, cat_iiko_id)
            continue

        image_links = product.get("imageLinks") or []
        weight_raw = product.get("weight") or product.get("weightGrams")
        current_image = (
            image_links[0] if image_links else existing_images.get(sid)
        )

        rows_to_upsert.append({
            "iiko_id": sid,
            "category_id": category_id,
            "name": name,
            "description": (product.get("description") or "").strip() or None,
            "price": _extract_price(product),
            "image_url": current_image,
            "weight_g": int(float(weight_raw) * 1000) if weight_raw and float(weight_raw) < 100 else (int(weight_raw) if weight_raw else None),
            "is_available": True,
            "is_halal": True,
        })

    # Batch upsert in chunks of 500
    CHUNK = 500
    for i in range(0, len(rows_to_upsert), CHUNK):
        chunk = rows_to_upsert[i:i + CHUNK]
        supabase.table("menu_items").upsert(chunk, on_conflict="iiko_id").execute()

    # Fetch db_id mapping for modifier sync
    upserted_iiko_ids = [r["iiko_id"] for r in rows_to_upsert]
    if upserted_iiko_ids:
        id_res = supabase.table("menu_items").select("id, iiko_id").in_(
            "iiko_id", upserted_iiko_ids
        ).execute()
        item_id_map: dict[str, str] = {row["iiko_id"]: row["id"] for row in id_res.data}
        # Build product lookup by iiko_id for modifier sync
        product_by_iiko: dict[str, dict] = {
            str(p.get("id") or "").strip(): p for p in products
            if str(p.get("id") or "").strip() in item_id_map
        }
        mod_synced = 0
        for iiko_id, db_id in item_id_map.items():
            product = product_by_iiko.get(iiko_id)
            if product and product.get("modifierGroups"):
                _sync_modifiers(supabase, db_id, product)
                mod_synced += 1
        logger.info("Modifiers synced for %d items", mod_synced)

    total = len(rows_to_upsert)
    logger.info(
        "Menu sync done: upserted=%d skip(no_id=%d deleted=%d type=%d no_name=%d no_cat=%d) raw=%d unique=%d",
        total, skip_no_id, skip_deleted, skip_type, skip_no_name, skip_no_category,
        len(raw_products), len(products),
    )
    return {
        "upserted": total,
        "skip_no_id": skip_no_id,
        "skip_deleted": skip_deleted,
        "skip_type": skip_type,
        "skip_no_name": skip_no_name,
        "skip_no_category": skip_no_category,
        "api_products_raw": len(raw_products),
        "api_products_unique": len(products),
        "categories_synced": len(groups_map),
    }


def _sync_modifiers(supabase: Client, item_db_id: str, product: dict[str, Any]) -> None:
    for g in (product.get("modifierGroups") or []):
        g_iiko = str(g.get("id") or "").strip()
        g_name = (g.get("name") or "").strip()
        if not g_iiko or not g_name:
            continue
        supabase.table("modifier_groups").upsert({
            "iiko_id": g_iiko,
            "menu_item_id": item_db_id,
            "name": g_name,
            "required": bool(g.get("required")),
            "min_amount": int(g.get("minAmount") or 0),
            "max_amount": int(g.get("maxAmount") or 1),
        }, on_conflict="iiko_id").execute()

        grp_res = supabase.table("modifier_groups").select("id").eq("iiko_id", g_iiko).single().execute()
        grp_db_id = grp_res.data["id"]

        for m in (g.get("items") or []):
            m_iiko = str(m.get("id") or "").strip()
            m_name = (m.get("name") or "").strip()
            m_price = int(float(m.get("price") or 0))
            if not m_iiko or not m_name:
                continue
            supabase.table("modifiers").upsert({
                "iiko_id": m_iiko,
                "group_id": grp_db_id,
                "name": m_name,
                "price": m_price,
            }, on_conflict="iiko_id").execute()


# ---------------------------------------------------------------------------
# Stop list sync
# ---------------------------------------------------------------------------

def sync_stop_lists(
    supabase: Client,
    api_login: str,
    organization_id: str,
    terminal_group_id: str = "",
) -> dict[str, int]:
    import asyncio
    return asyncio.run(_async_sync_stop_lists(supabase, api_login, organization_id, terminal_group_id))


async def _async_sync_stop_lists(
    supabase: Client,
    api_login: str,
    organization_id: str,
    terminal_group_id: str,
) -> dict[str, int]:
    async with IikoClient(api_login=api_login) as client:
        stop_data = await client.get_stop_lists([organization_id])

    stopped_ids = _collect_stopped_ids(stop_data, terminal_group_id)
    logger.info("Stop list: %d items stopped", len(stopped_ids))

    # Set stopped items unavailable
    if stopped_ids:
        supabase.table("menu_items").update({"is_available": False}).in_("iiko_id", list(stopped_ids)).execute()

    # Restore everything else
    supabase.table("menu_items").update({"is_available": True}).not_.in_("iiko_id", list(stopped_ids) or ["__none__"]).execute()

    return {"stopped": len(stopped_ids)}


def _collect_stopped_ids(stop_data: dict[str, Any], terminal_group_id: str) -> set[str]:
    want = (terminal_group_id or "").strip().lower()
    stopped: set[str] = set()

    for org_wrapper in stop_data.get("terminalGroupStopLists") or []:
        for block in org_wrapper.get("items") or []:
            if not isinstance(block, dict):
                continue
            bid = (block.get("terminalGroupId") or "").strip().lower()
            if want and bid != want:
                continue
            for row in block.get("items") or []:
                if isinstance(row, dict) and row.get("productId"):
                    stopped.add(row["productId"])

    return stopped
