---
title: POS discount calculation foundation
date: 2026-11-04
summary: Added exact VND discount calculation; safe POS recalc still incomplete
---

# POS discount calculation foundation

## Changes
Added a server-only VND discount calculator using Spree currency rounding and largest-remainder allocation. Rejects fractional fixed VND, invalid amounts and fixed discounts greater than the available base.

## Evidence and limits
Seven calculator examples and the existing promotion example pass. The draft pricing qualification remains red: after a quantity change the core manual percentage stays at 10 VND, giving 190 rather than 180. No POS intent storage, adjuster, endpoint, approval or UI has been wired; discount remains disabled.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
