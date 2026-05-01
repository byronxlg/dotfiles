---
name: polymarket
description: Query Polymarket prediction markets and place trades on the user's behalf. Discovers active markets, reads order books and prices, checks the user's positions/orders/balance, and — only when the user explicitly asks — places, modifies, or cancels orders. Use this skill whenever the user asks about Polymarket, prediction-market odds, "what are markets saying" about an event, wants to look up a market's price/depth/history, or asks to buy/sell/place/cancel an order on a prediction market. Trigger even when the user doesn't say "Polymarket" — phrases like "what are the odds on X", "is there a prediction market for Y", "buy YES on X", or "cancel my order on Z" are strong signals. Never initiate a trade autonomously based on the skill's own analysis — order placement is gated behind explicit user instruction.
---

# Polymarket

Two-tier API surface: the unauthenticated **Gamma API** for market discovery and metadata, and the **CLOB API** for live order books, prices, the user's authenticated state (positions, orders, balances), and order placement.

**Order placement is gated behind explicit user instruction.** Reads (markets, books, history, balances) can happen freely as part of research. Writes (place, modify, cancel orders) only happen when the user has asked for a specific action — never as a side effect of analysis, never proactively. If the user's request is ambiguous (size, side, market, price unclear), echo the proposed order back and confirm before signing.

## Which API to use

| Need | API | Auth required? |
|---|---|---|
| Find markets by topic, tag, slug, status | Gamma | No |
| Market metadata (description, end date, outcomes) | Gamma | No |
| Live order book / spread / depth | CLOB `/book/{token_id}` | No |
| Best bid/ask | CLOB `/price/{token_id}` | No |
| Historical prices | CLOB `/prices-history` | No |
| User's own positions, orders, fills, balance | CLOB | **Yes** |
| Place / modify / cancel an order | CLOB | **Yes** |

Default to Gamma for discovery and CLOB only when you need live book data or user state. Gamma is friendlier (richer metadata, simple filters) and avoids any auth setup.

## One-time setup

Polymarket migrated to **CLOB V2** on April 28, 2026 — V1-signed orders are now rejected with `order_version_mismatch`. We use `py-clob-client-v2` for trading and reads, plus the legacy `py-clob-client` for one specific thing: deriving API credentials, because V2's `/auth/api-key` endpoint is Cloudflare-blocked while V1's still works (the L2 creds are deterministic from the wallet sig, so they're interchangeable across versions).

A dedicated venv at `~/.venvs/polymarket/` is required (macOS Homebrew Python is PEP 668):

```bash
python3 -m venv ~/.venvs/polymarket
~/.venvs/polymarket/bin/pip install --upgrade pip py-clob-client py-clob-client-v2
```

Always invoke Python through the venv's interpreter:

```bash
~/.venvs/polymarket/bin/python your_script.py
```

For unauthenticated reads (Gamma), the venv isn't strictly needed — `requests` from system Python works fine. The venv only matters for the CLOB clients.

For authenticated reads (positions, orders, balance), the user needs these env vars set in their shell:

| Var | What it is |
|---|---|
| `POLYMARKET_PRIVATE_KEY` | Polygon EOA private key (hex, no `0x` required by client) |
| `POLYMARKET_FUNDER` | Address of the user's Polymarket proxy wallet (the address shown in the Polymarket UI) |
| `POLYMARKET_SIGNATURE_TYPE` | `1` for the standard Polymarket proxy wallet (most users); `0` for direct EOA; `2` for Magic/email-login proxy |
| `POLYMARKET_HOST` | Optional, defaults to `https://clob.polymarket.com` |

If any of these are missing when an auth'd read is requested, stop and tell the user which one to set rather than guessing — silently failing wastes their time. Never log or echo `POLYMARKET_PRIVATE_KEY` in any output.

## Gamma — market discovery

Base URL: `https://gamma-api.polymarket.com`. Public, no auth. Hit it with `requests`.

Common endpoints:
- `GET /markets` — list/filter markets. Useful params: `active=true`, `closed=false`, `archived=false`, `limit` (default 100), `offset`, `order` (e.g. `volume24hr`), `ascending=false`, `tag_id`, `slug`.
- `GET /markets/{id}` — single market by id (numeric) or slug.
- `GET /events` — events grouping multiple related markets (e.g. an election with one market per candidate).
- `GET /events/{slug}` — single event with all its markets.

Each market exposes `clobTokenIds` — a JSON-encoded list of two token IDs (one per outcome, typically YES and NO). You'll need the right token id to query CLOB endpoints.

Pattern: search markets by keyword + active filter, sort by 24h volume to find the live ones.

```python
import requests

resp = requests.get(
    "https://gamma-api.polymarket.com/markets",
    params={
        "active": "true",
        "closed": "false",
        "limit": 20,
        "order": "volume24hr",
        "ascending": "false",
    },
    timeout=10,
)
resp.raise_for_status()
markets = resp.json()
for m in markets:
    print(m["question"], "→", m.get("volume24hr"), "vol24h")
```

For a topical search, filter client-side on `question` / `description` substring — Gamma's full-text search is limited.

## CLOB — public reads (no auth)

Base URL: `https://clob.polymarket.com`. Use `py-clob-client-v2` without creds for clean reads, or hit endpoints directly with `requests`.

```python
from py_clob_client_v2 import ClobClient
from py_clob_client_v2.constants import POLYGON

client = ClobClient("https://clob.polymarket.com", chain_id=POLYGON)

# Order book for a token (token_id from Gamma's clobTokenIds)
book = client.get_order_book(token_id)
# In V2, book is a dict: {"bids": [{"price": "...", "size": "..."}, ...], "asks": [...]}
# (V1 returned a dataclass — V2 returns dicts for most read responses.)

# Best price for a side
price = client.get_price(token_id, side="BUY")  # what you'd pay to buy

# Historical prices
hist = client.get_prices_history(market=token_id, interval="1h", fidelity=60)
```

When a market has two outcomes (YES/NO), prices are complementary (`p_yes + p_no ≈ 1`) but the books are separate — quote both if the user is asking about implied probability.

## CLOB — authenticated reads (user state)

Bootstrap pattern: derive L2 creds via the V1 client (its endpoint isn't Cloudflare-blocked), then plug them into a V2 client for everything else. Creds are deterministic from the wallet, so they're interchangeable.

```python
import os
from py_clob_client.client import ClobClient as V1Client
from py_clob_client.constants import POLYGON as POLYGON_V1
from py_clob_client_v2 import ApiCreds, ClobClient
from py_clob_client_v2.constants import POLYGON

sig_type = int(os.environ.get("POLYMARKET_SIGNATURE_TYPE", "1"))
funder = os.environ["POLYMARKET_FUNDER"]
key = os.environ["POLYMARKET_PRIVATE_KEY"]

# Step 1: derive creds via V1
v1 = V1Client(host="https://clob.polymarket.com", key=key, chain_id=POLYGON_V1,
              signature_type=sig_type, funder=funder)
v1_creds = v1.create_or_derive_api_creds()

# Step 2: V2 client with those creds
client = ClobClient(
    host=os.environ.get("POLYMARKET_HOST", "https://clob.polymarket.com"),
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
```

If V2's auth endpoint is ever un-blocked you can drop the V1 step and call `client.set_api_creds(client.create_or_derive_api_key())` directly — the resulting creds are identical.

Useful authenticated reads:

```python
from py_clob_client_v2 import AssetType, BalanceAllowanceParams, OpenOrderParams

# Open orders (V2 method is get_open_orders, not get_orders)
orders = client.get_open_orders(OpenOrderParams())

# Trade history
trades = client.get_trades()

# USDC balance + exchange allowance. Note: balance is in micro-USDC (6 decimals).
ba = client.get_balance_allowance(
    BalanceAllowanceParams(asset_type=AssetType.COLLATERAL, signature_type=sig_type)
)
usd = int(ba["balance"]) / 1_000_000  # → human-readable USDC

# For a specific position token, pass token_id
ba_pos = client.get_balance_allowance(
    BalanceAllowanceParams(
        asset_type=AssetType.CONDITIONAL,
        token_id="<token_id from Gamma's clobTokenIds>",
        signature_type=sig_type,
    )
)
shares = int(ba_pos["balance"]) / 1_000_000  # conditional token balance, also 6 decimals
```

`get_balance_allowance` requires the typed `BalanceAllowanceParams` object — always include `signature_type` matching the client's setting.

For positions held (non-zero conditional-token balances), there's no single "positions" endpoint — derive them from trade history or query `get_balance_allowance` per token id of interest.

A reusable smoke test for verifying auth setup lives at `scripts/smoke_test.py` in the skill directory — run it with `~/.venvs/polymarket/bin/python` to confirm env vars + creds + the three reads (balance, orders, trades) all work.

## CLOB — order placement (auth required, user-initiated only)

Only place orders when the user has asked for a specific action. Never trade as a consequence of analysis or research.

```python
from py_clob_client_v2 import OrderArgs, OrderType

order_args = OrderArgs(
    token_id="<token_id>",   # from Gamma's clobTokenIds (YES or NO side)
    price=0.50,              # in USDC, between 0 and 1
    size=10,                 # number of shares (each share pays $1 if it resolves YES)
    side="BUY",              # "BUY" or "SELL"
)
signed = client.create_order(order_args)
resp = client.post_order(signed, OrderType.GTC)
print(resp)
# → {"success": True, "status": "matched"|"live", "orderID": "0x...",
#    "makingAmount": "...", "takingAmount": "...", "transactionsHashes": [...]}
```

V2 `OrderArgs` no longer has `fee_rate_bps`, `nonce`, `taker`, or `expiration` (well — `expiration` exists but is for GTD; FOK/FAK don't need it). Fields are `token_id, price, size, side, expiration, builder_code, metadata`. Fees are now baked into the exchange contract behavior, not the order struct.

`OrderType` values:
- **GTC** (good-til-cancel) — rests until filled or cancelled. Default for limits.
- **GTD** (good-til-date) — needs `expiration` on `OrderArgs`.
- **FOK** (fill-or-kill) — fully fill at the limit or cancel entirely.
- **FAK** (fill-and-kill, a.k.a. IOC) — fill what's available, cancel the rest.

For "trade at market" semantics there's no native market order — use a marketable limit (BUY at the best ask or above) with FAK. Convenience helpers `create_market_order` and `create_and_post_order` exist; both still require explicit price/size.

### Pre-flight checklist (run before signing)

1. **Resolve the market**: Gamma `/markets` or `/events` → confirm slug, end date, outcomes, `clobTokenIds`. Pick the right token (YES vs NO) for the side the user named.
2. **Read the book**: `client.get_order_book(token_id)` and `client.get_price(token_id, side)`. Sanity-check the user's price against mid — reject anything more than ~2% off mid unless the user explicitly insists.
3. **Check funds**: `get_balance_allowance(BalanceAllowanceParams(asset_type=AssetType.COLLATERAL, signature_type=sig_type))`. For BUYs, ensure `balance / 1_000_000 ≥ price * size`.
4. **Echo before signing**: print the resolved market, side, token_id, price, size, total notional, and order type. If the user was specific and unambiguous, you can submit; if anything was inferred, ask for confirmation.

### Cancelling

```python
client.cancel(order_id="<order_id>")
client.cancel_orders([id1, id2])
client.cancel_all()                  # cancels everything currently open
client.cancel_market_orders(market="<condition_id>", asset_id="<token_id>")
```

`cancel_all` is irreversible at scale — only use it when the user explicitly asks to clear their book.

### Order response shape

`post_order` returns a dict like:
```python
{
  "success": True,
  "errorMsg": "",
  "orderID": "0x...",
  "status": "matched",          # or "live"
  "makingAmount": "3.7",         # USDC the maker put up
  "takingAmount": "5",           # shares received
  "transactionsHashes": ["0x..."]  # on-chain settlement hashes (V2)
}
```
- `status="matched"` → fully filled on submit
- `status="live"` → resting on the book (GTC)
- `status="delayed"` / `"unmatched"` → check `errorMsg`
- `success=False` → order rejected; `errorMsg` has the reason

## Logging trades to Obsidian

After every successful order (place, partial fill, or cancel), write a note in the user's vault under:

`/Users/byron/repos/obsidian/Byron/Prediction Markets/Polymarket/Trades/`

The folder note `Trades/Trades.md` is the canonical source for the filename pattern, full frontmatter schema, body shape, and field conventions. Read it before writing a trade note and match its shape exactly — it owns the Bases view that depends on the schema.

**Updating an existing trade** (e.g. user asks "how is the WTI trade going", "did it resolve", "close my X position"): re-query Polymarket (Gamma `/markets/{conditionId}` for status, CLOB `get_price` for current mark) and edit the existing note in place — update `status`, `exit_price`, `exit_date`, `realized_pnl`, `closed_via` as appropriate, and append a dated line under `## Updates`. Don't create a second note for the same position.

## Common patterns

**"What are markets saying about X?"** — Gamma `/markets` with active filter, search question text for X, return top by volume with current YES price (from CLOB `/price`).

**"What's the depth on market Y?"** — Gamma to resolve slug → token ids; CLOB `get_order_book` for both YES and NO; show top-of-book and ~5% depth.

**"How is market Y trending?"** — CLOB `prices-history` over the requested interval, plot or summarize.

**"What are my positions / open orders?"** — auth'd CLOB. If env vars missing, tell the user which ones to set; do not prompt for or accept the private key in chat.

**"Buy/sell N at price P on market X"** — Gamma to resolve market → token_id; read book; check balance; echo the resolved order back if anything was ambiguous; `client.create_order(OrderArgs(...))` then `client.post_order(signed, OrderType.GTC)`. Report the response status and orderID.

**"Cancel my order on X"** — fetch open orders via `get_orders`, match the one the user means (by market or order id), call `cancel(order_id=...)`. If multiple match, list them and ask which.

## Output format

When summarizing markets to the user, prefer this shape:

```
[Market question]
  YES: $0.62 (62%)  vol24h: $48k  ends: 2026-06-30
  https://polymarket.com/event/<slug>
```

Probabilities are just YES price as a percentage. Always include the URL so the user can click through.

For order-book summaries, show top 3 levels each side with cumulative size, plus the spread.

## What this skill does NOT do

- **Initiate trades autonomously.** Order placement is gated behind explicit user instruction — never trade as a side effect of analysis, "just to verify the path works", or because the skill thinks an order is a good idea.
- **Move funds on-chain.** Deposits, withdrawals, and the initial CTF / Neg Risk Exchange / Conditional Tokens approvals happen in the Polymarket UI, not here. The skill assumes those are already in place.
- **Hold or persist credentials.** Read env vars at runtime; never write the private key to disk or log it.

## Troubleshooting

- `401 Unauthorized` on auth'd endpoints → API creds not set. Did you call `set_api_creds(create_or_derive_api_creds())`?
- `signature_type` mismatch → if the user signs up via Polymarket UI with a wallet, signature_type is `1` and `funder` is their proxy address (not the EOA). If they used Magic/email login, type is `2`. EOA-direct (type `0`) is uncommon.
- Gamma returns empty list → check `active`/`closed`/`archived` flags. By default Gamma includes archived markets which dilutes results.
- Rate limiting → CLOB is roughly 50 req/sec per API key on reads; Gamma is more lenient but unspecified. Back off on 429.
- `post_order` returns `success=False` with `errorMsg` like `not enough balance / allowance` → check `get_balance_allowance` (USDC is in micro-USDC, divide by 10^6).
- `errorMsg: invalid tick size` → market has a per-market tick (often `0.001` or `0.01`); round price accordingly.
- `errorMsg: minimum size` → Polymarket minimum is generally 5 shares per order (subject to per-market overrides). Increase `size` or pick a market with a smaller minimum.
- `order_version_mismatch` (HTTP 400) → using legacy `py-clob-client` to sign against post-April-28-2026 markets. Switch to `py-clob-client-v2` (see setup section).
- `403 Cloudflare block on /auth/api-key` → V2's API-key derivation endpoint is geofenced/blocked; bootstrap creds via the legacy V1 client and pass them to the V2 client (see "authenticated reads" section).
