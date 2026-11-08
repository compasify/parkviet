---
title: POS catalog reader and decimal inputs
date: 2026-11-04
summary: Added scoped catalog reader and exact decimal input foundation
---

# POS catalog reader and decimal inputs

## Changes
Added a server-side POS catalog reader requiring an authorized product relation and enforcing the store boundary. Added exact barcode ambiguity and pagination tests, plus decimal-string input parsers for price, VND totals and percentages.

## Verification
Catalog and existing core characterization specs passed 8 examples. Frontend passed 29 unit tests, typecheck, build and scoped lint.

## Remaining
No POS branch assortment authority exists yet, so the reader is not exposed through an endpoint. Pricing, customer, advanced goods, UI integration and phase 5 gates remain incomplete.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
