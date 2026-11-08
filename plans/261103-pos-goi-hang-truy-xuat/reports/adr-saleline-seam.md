# ADR — SaleLine seam for POS (plan 261103 phase 1)

## Context
Core `Spree::Carts::AddItem` upserts by variant: two packages of the same variant with
different prices/lots collapse to one core line and the later price/metadata overwrites
the earlier (characterized in `sale_line_identity_contract_spec.rb`). POS must not sell
such packages as if they were distinguishable.

## Decision
Use **typed POS SaleLines mapped 1:1 to distinct core line items**:
- `Spree::Pos::SaleLine` owns immutable prefixed ID, merge key, sale/base quantities,
  unit/conversion snapshot, unit price, lot/serial draft provenance.
- POS add never calls variant-upsert for measured/tracked packages. Ordinary scans merge
  only when client sends `merge: true` and the full merge key (variant, price-per-base,
  sale unit, lot/serials, tracked mode) matches.
- Core remains writer of totals/tax/discount; POS adjuster allocates manual discounts
  per core line, therefore per SaleLine.
- Integer canonical base units only (g/ml/chai/item). Fractional sale quantities are
  rejected unless they convert exactly; no silent rounding, no fractional core quantity.

## Consequences
- Draft identity survives reload/edit/remove/discount by SaleLine ID.
- Returns/refunds per package (F21 residual) remain phase 8; fulfillment core mapping is
  by core line item, which is 1:1 with SaleLine, so provenance is not averaged away.
- Tracked SKUs can be drafted but phase 6 tender is blocked until phase 8 reservation
  lifecycle exists. Embedded weight/price barcodes stay disabled (ordinary scan only).
