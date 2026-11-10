# POS channel integration

## Outcome

Use the current Spree store's channel with code `pos` for new POS drafts, published product eligibility and channel-aware prices/promotions. Retain branch assortment and warehouse boundaries. POS Dashboard explains channel setup without creating channels or publishing products automatically.

## Scope and safeguards

- Keep Spree Dashboard and store/tenant selection unchanged.
- Do not migrate, create development data, republish products or relabel historical POS orders.
- Back up the test database before executing database-writing tests; use transactional specs.
- Missing/inactive POS channel must never fall back to Online/Wholesale.
- Block new drafts, new items and quantity increases when channel/publication is unavailable. Preserve cancellation, removal, read/history and financial recovery after payment has started.
- Existing drafts keep their original channel; do not silently relabel them.

## Work

1. Inspect channel/publication and pricing contracts on installed Spree 6.0.3.
2. Add one POS sales-channel policy and integrate draft creation, catalog, direct/scale-code additions and branch-assortment configuration. Expose non-blocking channel readiness in context.
3. Show translated setup guidance in POS and POS Dashboard. Apply channel-aware pricing consistently without changing committed payment snapshots.
4. Add request/service regression coverage for publication windows, foreign channels, bypass attempts, attribution, prices and recovery. Update existing fixtures explicitly for POS publication.
5. Run focused and affected Rails suites plus shared/frontend tests, typecheck, lint and build; review the final diff.

All five steps are complete. Implementation and selected regression checks passed; manual operator setup remains separate from this code change.

## Verification status

Implementation is in place. Installed Spree 6.0.3 source confirmed order channel attribution, publication windows, contextual pricing and promotion channel rules. Development/test database backups both passed `pg_restore --list`. No development data, migrations or historical channel repairs were applied.

| Check | Observed result |
| --- | --- |
| Final focused backend, six files (`ba0a9338c`, seed 57788) | 51 examples, zero failures; includes channel policy, draft creation, catalog, scale labels, settlement and test-database safety |
| Shared logic (`b4ddf8b74`) | 188 tests passed; typecheck and lint passed |
| Final cashier (`bb232195d`) | 180 tests passed; typecheck, lint and production build passed |
| Administration (`b2289c4c2`) | 34 tests passed; typecheck, lint and production build passed |
| Cashier browser (`b089febb6`, `b5563036c`) | 33 cases passed across desktop/tablet/mobile |
| Administration browser (`b04356961`) | 33 cases passed across desktop/tablet/mobile |
| Affected backend (`ba3a70a8a`, seed 34064) | 136 examples, zero failures; covers workspace/items, guards, discounts, credit, funds, returns, receipts/history, branch-only sessions, feature flags and VietQR |
| Modules-off regression (`ba3a70a8a`, seed 31488) | 38 examples, zero failures; 298 requests ran with every branch module off and 33 setup commands ran with them on |
| Final diff review | `git diff --check` passed; temporary verification config and tracing removed; no commit or staging performed |

Browser tests use API fixtures, not a live end-to-end payment gateway. Static editor diagnostics were inconclusive; the compiler, lint and executed tests provide the verification evidence. Existing Biome schema/deprecation and build chunk-size warnings remain; no unrelated configuration migration or bundle refactor is included.

Earlier failures were resolved before the final focused backend pass: an ordered DISTINCT query, new-fixture mistakes and Rails JSON GET mutating shared test headers (a later POST became GET /items). Temporary diagnostic instrumentation was removed. Final tests also cover canceled sole tenders, unrelated versus linked late funds, and locked measured-line prices expressed in sale units rather than core base units. Windows temporarily blocked a Biome formatting write; targeted formatting and a complete cashier rerun passed. The first administration browser launch hit occupied port 5176; the successful run used isolated port 5178 without stopping the existing server, and its temporary config was removed.

Setup and recovery behavior are documented in `docs/pos-sales-channel.md`. Store Shop still has Online/Wholesale only; 62 POS-marked orders use Online (draft/completed split was not inspected). Manual creation/activation of `pos`, product publication and branch assignment are operator actions, not automatic changes.
