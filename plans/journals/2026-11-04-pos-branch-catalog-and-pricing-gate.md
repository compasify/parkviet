---
title: POS branch catalog and pricing gate
date: 2026-11-04
summary: Added scoped read-only catalog and identified draft discount recalc blocker
---

# POS branch catalog and pricing gate

## Changes
Implemented explicit per-branch product assortment, a topology-authorized management API, a membership-scoped read-only catalog API and POS search UI. Applied migration 20261104121000 to test and development through the Spree CLI; no reset or seed.

## Evidence
Catalog request specs, frontend unit/build/lint and catalog mocked browser tests pass. The full Playwright run had one intermittent anonymous redirect timeout; it passed when rerun alone. Phase 5 is incomplete.

## Blockers
Spree's default customer requires email in model and database. Draft manual 10% order discount remains 10 after the remaining line quantity doubles; expected 180 VND is 190, and pricing qualification remains failing. Advanced-goods precision and lossless mapping remain unqualified; do not enable payment or unsupported writes.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
