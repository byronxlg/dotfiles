"""Smoke test: derive V2 creds (via V1 bootstrap), read USDC balance, open orders, trades.

Reads creds from env vars (POLYMARKET_PRIVATE_KEY, POLYMARKET_FUNDER,
POLYMARKET_SIGNATURE_TYPE). Never prints the private key.

Bootstrap pattern: V2's /auth/api-key endpoint is Cloudflare-blocked, so we derive
the L2 API creds via the legacy V1 client (its endpoint still works) and pass them
into the V2 client. Creds are deterministic from the wallet, so the two are identical.
"""
import os
import sys
import traceback

from py_clob_client.client import ClobClient as V1Client
from py_clob_client.constants import POLYGON as POLYGON_V1
from py_clob_client_v2 import (
    ApiCreds,
    AssetType,
    BalanceAllowanceParams,
    ClobClient,
    OpenOrderParams,
)
from py_clob_client_v2.constants import POLYGON


def main():
    missing = [
        v
        for v in ("POLYMARKET_PRIVATE_KEY", "POLYMARKET_FUNDER")
        if not os.environ.get(v)
    ]
    if missing:
        print(f"ERROR: missing env vars: {missing}", file=sys.stderr)
        sys.exit(2)

    host = os.environ.get("POLYMARKET_HOST", "https://clob.polymarket.com")
    sig_type = int(os.environ.get("POLYMARKET_SIGNATURE_TYPE", "1"))
    funder = os.environ["POLYMARKET_FUNDER"]
    key = os.environ["POLYMARKET_PRIVATE_KEY"]
    print(f"Host: {host}")
    print(f"Funder: {funder}")
    print(f"Signature type: {sig_type}")

    print("\nBootstrapping API creds via V1 (V2 /auth/api-key is Cloudflare-blocked)...")
    v1 = V1Client(host=host, key=key, chain_id=POLYGON_V1, signature_type=sig_type, funder=funder)
    v1_creds = v1.create_or_derive_api_creds()
    api_key_preview = v1_creds.api_key[:8] + "..." if v1_creds.api_key else "(unknown)"
    print(f"API key derived: {api_key_preview}")

    client = ClobClient(
        host=host,
        chain_id=POLYGON,
        key=key,
        creds=ApiCreds(
            api_key=v1_creds.api_key,
            api_secret=v1_creds.api_secret,
            api_passphrase=v1_creds.api_passphrase,
        ),
        signature_type=sig_type,
        funder=funder,
    )

    print("\n--- USDC balance + allowance (COLLATERAL) ---")
    try:
        ba = client.get_balance_allowance(
            BalanceAllowanceParams(asset_type=AssetType.COLLATERAL, signature_type=sig_type)
        )
        usdc = int(ba["balance"]) / 1_000_000
        print(f"balance: ${usdc:.4f}")
        print(f"raw response: {ba}")
    except Exception as e:
        print(f"get_balance_allowance failed: {e}")
        traceback.print_exc()

    print("\n--- Open orders ---")
    try:
        orders = client.get_open_orders(OpenOrderParams())
        if not orders:
            print("(none)")
        else:
            print(f"{len(orders)} open order(s):")
            for o in orders:
                print(o)
    except Exception as e:
        print(f"get_open_orders failed: {e}")
        traceback.print_exc()

    print("\n--- Recent trades (last 10) ---")
    try:
        trades = client.get_trades()
        if not trades:
            print("(none)")
        else:
            for t in trades[:10]:
                print(t)
    except Exception as e:
        print(f"get_trades failed: {e}")
        traceback.print_exc()


if __name__ == "__main__":
    main()
