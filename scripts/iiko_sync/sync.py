"""
Entry point: iiko → Supabase sync for plovxana.

Usage:
    python sync.py menu          # sync categories + menu items
    python sync.py stop          # sync stop lists (is_available)
    python sync.py all           # menu + stop lists
    python sync.py orgs          # list iiko organizations (get org UUID)

Environment variables (see .env.iiko.example):
    IIKO_API_LOGIN
    IIKO_ORGANIZATION_ID
    IIKO_TERMINAL_GROUP_ID   (optional, for stop list filtering)
    SUPABASE_URL
    SUPABASE_SERVICE_ROLE_KEY
"""

import logging
import os
import sys

from dotenv import load_dotenv
from supabase import create_client

from menu_sync import sync_menu_from_iiko, sync_stop_lists
from iiko_client import IikoClient
import asyncio

from pathlib import Path

# Загружаем .env из корня проекта (scripts/iiko_sync/../../.env)
_ROOT = Path(__file__).resolve().parents[2]
load_dotenv(_ROOT / ".env")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


def _require_env(key: str) -> str:
    v = os.getenv(key, "").strip()
    if not v:
        logger.error("Missing required env var: %s", key)
        sys.exit(1)
    return v


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"

    supabase_url = _require_env("SUPABASE_URL")
    supabase_key = _require_env("SUPABASE_SERVICE_ROLE_KEY")
    iiko_login = _require_env("IIKO_API_LOGIN")
    iiko_org = _require_env("IIKO_ORGANIZATION_ID")
    iiko_tg = os.getenv("IIKO_TERMINAL_GROUP_ID", "").strip()

    supabase = create_client(supabase_url, supabase_key)

    if cmd == "orgs":
        async def _list_orgs() -> None:
            async with IikoClient(api_login=iiko_login) as client:
                orgs = await client.get_organizations()
            for o in orgs:
                print(f"  {o.get('id')}  {o.get('name')}")
        asyncio.run(_list_orgs())
        return

    if cmd in ("menu", "all"):
        logger.info("=== Syncing menu ===")
        stats = sync_menu_from_iiko(supabase, iiko_login, iiko_org)
        logger.info("Menu stats: %s", stats)

    if cmd in ("stop", "all"):
        logger.info("=== Syncing stop lists ===")
        stats = sync_stop_lists(supabase, iiko_login, iiko_org, iiko_tg)
        logger.info("Stop list stats: %s", stats)


if __name__ == "__main__":
    main()
