# Implementation evidence

## Authorized boundaries

- Execute the accepted eight-phase plan; do not change `apps/dashboard/`.
- Keep selling, browser printing, shifts, credit, stock operations, scanner and
  customer-display controls in `apps/pos`.
- Do not cut over or remove the old settings/setup pages until the replacement
  business journeys pass E2E.
- No production deployment, account provisioning, commit or push is implied.

## Inspection findings

- The initial working tree contained only untracked plans/research. Preserve them.
- CodeGraph tools are unavailable and `.codegraph/` is absent. The user was asked
  whether to initialize it; no initialization has been performed.
- The existing API, Spree dashboard and POS dev servers were already listening on
  ports 3000, 5173 and 5175. Do not stop or replace those processes.
- Phase 7 also needs `apps/pos/src/components/pos-shell.tsx`: it redirects an
  unconfigured store to `/setup`. Removing the router entry alone would leave a
  broken redirect. The replacement must show an external setup link instead.

## Verification ledger

- URL helper: four unit tests passed on the initial implementation; Biome passed
  after adding traversal protection. Rerun the final test revision before delivery.
- An early POS desktop E2E invocation overlapped the phase-1 file moves and failed
  during Vite import resolution. This is **not** a valid baseline or final result;
  rerun only after the package extraction and import updates finish.
- `git diff --stat -- apps/dashboard` was empty at the initial scope check.
- Phase-1 first verification: shared 16 files/169 unit tests, POS 30 files/172
  unit tests, both typechecks/lints, POS build passed. A subsequent independent
  review found device preference storage in shared `receipt-template/selection`;
  this pure-boundary finding is being repaired before final verification.
- Stable POS desktop baseline: 25/26 selected journeys initially passed. Two
  missed relocated imports in receipt E2E/support were corrected before this run.
  The remaining feature-flags test had an ambiguous substring selector matching
  both `credit` and `quick_credit`; selecting `data-feature="credit"` retained
  every business assertion. All five feature-flags journeys then passed.
- Independent extraction review confirmed renderer, CSS, defaults, types,
  Code128, validation and variable resolution unchanged from HEAD after the move;
  no behavior-preserving simplification was needed.
- Dashboard reconciliation (09/11/2026, main agent, subagent channels exhausted):
  detached dashboard E2E from `apps/pos` (`business-profiles.ts`,
  `live-onboarding.ts` copied into `e2e/support/`), removed dead
  `rememberedTemplate` import, fixed `stores` fixture for `AuthProvider`,
  setup auto-redirect and read-reachable setup route, closed-trigger labels for
  Base UI `Select`, full accessible name for default-apply checkbox, and
  fixtures that must include `error.message` or SDK 6.0.3 drops `details`.
- Final gates (this run): shared 16 files/168 tests + TSC pass;
  POS typecheck/lint/176 tests/build pass; dashboard typecheck/lint/5 files/
  12 tests/build pass; dashboard E2E 40 passed + 2 live skipped on each of
  desktop, tablet and mobile (the receipt-template tablet/mobile failure was a
  `show()` helper race fixed by waiting for the editor before toggling panes);
  `git diff --stat -- apps/dashboard` empty.

## Completion gates

- [x] Shared package tests and TypeScript pass.
- [x] POS typecheck, lint, unit tests and production build pass.
- [x] New dashboard typecheck, lint, unit tests and production build pass.
- [x] Migrated E2E journeys pass without reducing business assertions.
- [x] Auth/refresh/logout and all three permission roles are verified.
- [x] Shared renderer and isolated print preview are verified.
- [ ] POS cutover and remaining POS E2E pass. (Dashboard equivalents pass E2E;
      Phase 7 removal in `apps/pos` awaits explicit go-ahead.)
- [x] Production build/base-path behavior and deployment documentation are verified.
- [x] Final scope check confirms no change under `apps/dashboard/`.
