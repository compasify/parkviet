---
name: reference-spree-core-source
description: Where to read installed Spree core gem source (workflows like orders/complete, fulfillments/fulfill) when verifying POS calls into core
metadata:
  type: reference
---

Spree core source is not on the host; it lives in the API container at
`/usr/local/bundle/ruby/4.0.0/gems/spree_core-6.0.2/` (version may change — `ls -d /usr/local/bundle/ruby/*/gems/spree_core*`).
Read it with `pnpm spree exec sh -c '...'` from the repo root (never docker compose / bundle directly).

Useful when reviewing POS server code that passes flags to core, e.g. `payment_pending:` to
`app/workflows/spree/orders/complete.rb` or `force:` to `app/workflows/spree/fulfillments/fulfill.rb`
(force skips paid gate, backorder check, shelf check AND the non-negative stock write guard in stock_level.rb).

Specs run via `pnpm spree rspec <paths>`; the POS credit/collection set takes ~35s.
