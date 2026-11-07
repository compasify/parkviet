# Phase 9 implementation: shift close, cashbook, cash reconciliation, reports

Status: implemented, not committed. Phase status cells were not edited.

## What was built

Backend (`server/`):

- Migration `20261107143000_create_spree_pos_shift_closures` (applied to the **test DB only**): shift `revision` + pending blind count (`closing_counted`, `closing_reason`, `closing_counted_by_id`, `closing_counted_at`) + `closed_at`; branch `variance_threshold` (nullable, >= 0); `spree_pos_shift_closures` (one per shift, check constraints `expected = opening_float + inflow - outflow`, `variance = counted - expected`); `spree_pos_cash_reconciliations` (outcome check, one per held receipt, source required, target rules); cash movement kinds `cash_in`, `cash_out`, `safe_drop`, `reconciliation_inflow` with a sign check and a required reason for manual kinds, plus `reason`, `evidence_reference`, `cash_reconciliation_id`; `spree_pos_export_requests`; index `received_funds(branch_id, received_at)`.
- **Close barrier** `Spree::Pos::ShiftBarrier.hold!(shift)`: `SELECT ... FOR UPDATE` on the shift row inside the caller's transaction, 409 `shift_closed` unless open. Lock order everywhere: workspace (CommandExecutor) -> shift -> credit account / parent funds / allocation / order. Taken by: tender prepare/confirm, funds allocate, workspace complete (all through `Tenders::Guard.validate_open_shift!`), unsolicited drawer cash, liability payout cash confirm, collection receive, refund cash payout, manual movements, late-cash inflow, count, approve and close.
- `CashbookProjection`: expected = opening float + sum(signed CashMovements). Receipts carry only cash kept (handed - change), so change is never subtracted twice; bank/card/debt write no movement; allocation/reversal move no cash.
- `ShiftChecklist`: blocks on prepared/unknown tender attempts of the shift, editing/parked drafts holding ReceivedFunds, and cash liability payouts / cash refunds at the branch still requested/reserved/unknown that the owner requested during the shift or marked unknown. Drafts without money are warnings. Items carry workspace/attempt/payout ids.
- Workflows `shifts/count.rb` (blind count, revision bump, audit, returns expected/variance), `shifts/approve_close.rb` (APPROVE holder distinct from the counter; Approval bound to shift, revision, counter and exact variance; needs the counter's reason first), `shifts/close.rb` (barrier, stale-count check, checklist, variance threshold, consumes the approval, immutable `ShiftClosure` with cutoff = last movement id, breakdown by category; retry with the same or another key returns the same snapshot), `shifts/post_cash_movement.rb` (capability `pos.cash.move`, own open shift, reason required, evidence optional, outflow cannot exceed expected), `shifts/reconcile_late_cash.rb`.
- `CashReconciliation`: links a closed shift's overage and/or a held receipt to `in_opening_float` | `safe` | `handed_over` | `new_physical_inflow`, with reason and (safe/handover) a custody reference. Manager needs APPROVE + RESOLVE and must be neither the closed shift owner nor the person who recorded the held cash. Only `new_physical_inflow` posts one CashMovement (source-unique) to the chosen open shift under its barrier. Linked amounts never exceed a closure's overage; a held receipt is reconciled once. Closed snapshots, shifts, closures, cash movements and reconciliations are read-only models (`readonly?`), so corrections are always new entries with audit.
- Late evidence: `RecordUnsolicitedFunds` takes an optional actual `received_at` for held cash and bank evidence (`created_at` is the booked time); the original workspace context is kept as before.
- Reports (`GET /pos/reports/:report`, `sales|receipts|cashbook|receivables|closures`), server-side allowlisted filters (`from`, `to`, `register_id`, `shift_id`, `cashier_id`, plus `section` / `kind`,`source` / `status`), unknown keys and bad values -> 422, ranges <= 366 days, days in the branch timezone. Sales by order completed time with returns as a separate section by `received_at`; receipts by actual received time with booked time and sale/collection/unsolicited split; cashbook rows with a SQL window running expected, shifts selected by open interval (overnight shift on both days); receivables from `ReceivableProjection` (customer name only); closures with reconciled amount. Readers without `pos.report.read` at the branch see only their own shifts, and the cashbook only once closed (blind count).
- Exports: `POST /pos/exports` (`pos.report.export`), `ExportRequest` with 24h TTL, `GenerateExportJob` (re-authorizes the requester, max 100k rows), CSV stored as an Active Storage attachment, formula cells (`= + - @ tab CR`) prefixed with `'` while plain numbers stay numeric; `GET /pos/exports/:id/download` only for the requester, re-checks the capability, 410 after expiry; `PurgeExpiredExportsJob` hourly in `config/recurring.yml`.
- New capabilities `pos.cash.move`, `pos.report.read`, `pos.report.export`. Branch `variance_threshold` is set through `PATCH /pos/branches/:id` (topology writers, which the context maps to `pos.topology.manage`).

Frontend (`apps/pos/`):

- `/shifts` page: current shift (float, opened time, counted status, blind-count notice), manual movements list, "Thu/chi tiền mặt" dialog, close wizard (checklist with links -> blind count -> expected/variance in words "Thừa/Thiếu/Khớp" -> reason + approval wait/poll -> snapshot), late-cash wizard for managers that states whether the choice adds drawer cash.
- `/reports` page: tabs Doanh số / Thực thu / Tiền mặt trong két / Công nợ / Đóng ca (arrow-key tabs), server filters, summary, paging, export button and own export list with download.
- Duyệt page: "Duyệt chênh lệch đóng ca" section. Branch editor: variance threshold field. Nav links in page nav and context popover.
- Every drawer/close/reconcile command uses `runFinancialCommand`.

## Verification

- `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`: 321 examples, 0 failures (31 new) before the refund barrier line. Final run after it: 321 examples, 2 failures, both in `pricing_spec.rb` (`create(:line_item, quantity: 1250)` refused as "not available": stock, not shift code). That spec passes on its own (4/4). The other agent was running specs against the same test database at the same time, so this is most likely interference between the two runs or an order dependency. It is not caused by this phase.
- New specs: `spec/workflows/spree/pos/shift_closure_spec.rb` (14: expected formula 360k with change/bank/debt/collection/payout/refund/manual, outflow and capability guards, checklist blocking and warnings, pending payout, variance approval bound to the count, threshold, stale count, retry same snapshot, immutability, late cash fixture S1 +100k / S2 float 100k stays 100k, inflow exactly once, safe custody and separation, actual vs booked received time, overnight dates), `spec/integration/spree/pos/shift_close_race_spec.rb` (3 two-connection races: close vs cash tender, vs cash collection, vs cash liability payout), `spec/requests/spree/pos/reports_spec.rb` (11: scoping, non-members, filter allowlist, timezone + overnight, late evidence dates, blind cashbook, checklist 409 payload, CSV injection, export re-authorization, TTL + purge, revoked requester), `spec/requests/spree/pos/shift_close_spec.rb` (3: threshold config, movements, close wizard HTTP, late-cash endpoints).
- Rubocop on new Ruby files: only `Metrics/ParameterLists` (same pattern as existing POS workflows). Shared files: no new offenses from these hunks (remaining ones pre-exist).
- `apps/pos`: biome clean, `tsc` clean, vitest 110 passed (new `src/lib/shifts.test.ts`), Playwright `POS_TEST_PORT=5176` 213 passed / 6 skipped (live API), including new `e2e/shift-reconciliation.spec.ts` (5 tests x 3 viewports).

## Files

Created (backend): `db/migrate/20261107143000_create_spree_pos_shift_closures.rb`; models `shift_closure.rb`, `cash_reconciliation.rb`, `export_request.rb`; services `shift_barrier.rb`, `cashbook_projection.rb`, `shift_checklist.rb`, `staff_name.rb`, `reports.rb`, `reports/{base,scope,filters,sales,receipts,cashbook,receivables,closures,export_file}.rb`; workflows `shifts/{guard,close_blocked,count,approve_close,close,post_cash_movement,reconcile_late_cash}.rb`; controllers `shifts/closures_controller.rb`, `shifts/cash_movements_controller.rb`, `cash_reconciliations_controller.rb`, `reports_controller.rb`, `exports_controller.rb`; jobs `generate_export_job.rb`, `purge_expired_exports_job.rb`; specs `spec/support/pos_shift_helpers.rb`, `spec/workflows/spree/pos/shift_closure_spec.rb`, `spec/integration/spree/pos/shift_close_race_spec.rb`, `spec/requests/spree/pos/reports_spec.rb`, `spec/requests/spree/pos/shift_close_spec.rb` (all under `server/app/...` or `server/spec/...`).

Created (frontend, `apps/pos/`): `src/lib/shifts.ts`, `src/lib/shifts.test.ts`, `src/hooks/use-shift-close.ts`, `src/hooks/use-reports.ts`, `src/components/shift-close-dialog.tsx`, `src/components/cash-movement-dialog.tsx`, `src/components/late-cash-wizard.tsx`, `src/components/shift-approvals.tsx`, `src/pages/shifts.tsx`, `src/pages/reports.tsx`, `e2e/shift-reconciliation.spec.ts`.

Modified (shared), with the hunks added by this phase:

- `server/db/schema.rb`: regenerated by the migration — version `2026_11_07_143000`; `spree_pos_branches.variance_threshold` + check; `spree_pos_cash_movements` `reason`, `evidence_reference`, `cash_reconciliation_id` (+ unique partial index), kind check replaced, new sign and reason checks; new tables `spree_pos_cash_reconciliations`, `spree_pos_export_requests`, `spree_pos_shift_closures`; `spree_pos_received_funds` index `idx_pos_received_funds_branch_received`; `spree_pos_shifts` six columns + `chk_pos_shifts_closing_counted`.
- `server/config/routes.rb`: one block after `resources :shifts, only: [:index, :show, :create]` — member routes `closure`, `count`, `close`, `close_approval`, `cash_movements` (GET/POST); `shift_closures/pending`; `cash_reconciliations/candidates` + `resources :cash_reconciliations`; `reports/:report`; `resources :exports` + `download`.
- `server/config/recurring.yml`: `pos_purge_expired_exports` entry before `pos_dispatch_outbox`.
- `server/app/models/spree/pos/shift.rb`: associations/callback block after `belongs_to :owner` (`closing_counted_by`, `closure`, `cash_movements`, `before_update :closed_is_final`, reason length); `to_pos` adds `closed_at`, `revision`, `counted`; `open?`; private `closed_is_final`. Line endings normalized to LF (the working copy had CRLF; git diff unaffected).
- `server/app/models/spree/pos/cash_movement.rb`: rewritten body — kind constants (`INFLOWS`, `OUTFLOWS`, `MANUAL`, `KINDS`), `cash_reconciliation` association, validations, `readonly?` once persisted, `category`, `to_pos` extra fields. The existing `refund_request` association and `to_pos` key are kept.
- `server/app/models/spree/pos/capabilities.rb`: `CASH_MOVE`, `REPORT_READ`, `REPORT_EXPORT` + appended to `ASSIGNABLE`.
- `server/app/models/spree/pos/branch.rb`: `variance_threshold` validation after the return-window validation; `to_pos` key.
- `server/app/models/spree/pos/approval.rb`: `Spree::Pos::Shift` added to `SUBJECTS`; `REQUESTER_CAPABILITIES['Spree::Pos::Shift'] = [OPEN_SHIFT, RECOVER]`.
- `server/app/workflows/spree/pos/tenders/guard.rb`: `validate_open_shift!` now calls `ShiftBarrier.hold!` (message becomes "Shift is closed.", reason `shift_closed`).
- `server/app/workflows/spree/pos/record_unsolicited_funds.rb`: `received_at:` keyword + payload key; `hold_drawer!` (barrier for fresh drawer cash) and `actual_received_at` helpers; `received_at: actual_at`.
- `server/app/workflows/spree/pos/liability_payouts/confirm.rb`: `ShiftBarrier.hold!(drawer) if drawer` before `funds.with_lock`.
- `server/app/workflows/spree/pos/collections/receive.rb`: `ShiftBarrier.hold!(shift)` after the shift lookup, before `account.lock!`.
- `server/app/workflows/spree/pos/refunds/confirm_payout.rb`: **one line** after `drawer = ...`: `ShiftBarrier.hold!(drawer) if drawer # shift close barrier, before the funds lock`.
- `server/app/controllers/spree/api/v3/admin/pos/branches_controller.rb`: `variance_threshold` attribute in `branch_attributes`.
- `server/app/controllers/spree/api/v3/admin/pos/received_funds_controller.rb`: passes `received_at: params[:received_at]`.
- `apps/pos/src/router.tsx`: imports `ReportsPage`, `ShiftsPage`; `shiftsRoute` (`/shifts`), `reportsRoute` (`/reports`) block before `createRouter`; both added to the route tree.
- `apps/pos/src/components/pos-shell.tsx`: page titles for `/shifts` and `/reports`, both added to the non-sale path regex; popover paragraph with "Ca & két · Báo cáo" links before the logout button.
- `apps/pos/src/components/pos-page.tsx`: nav links Ca & két, Báo cáo before the payment-attention link.
- `apps/pos/src/pages/credit-approvals.tsx`: import of `ShiftApprovals` and one `<ShiftApprovals .../>` line before `<ReturnApprovals>`.
- `apps/pos/src/components/topology-editor.tsx`: `variance_threshold` draft field, validation, body key, input after the return-window input, `parseVndInput` import.
- `apps/pos/src/lib/pos-capabilities.ts`: three capabilities and their sensitive entries.
- `apps/pos/src/lib/pos-administration.test.ts`: capability count 13 -> 16 (+ assertion of the three keys). `apps/pos/e2e/administration.spec.ts`: checkbox count 13 -> 16.
- `apps/pos/src/locales/vi.json`, `en.json`: one contiguous block of 293 keys appended at the end (`shiftsNav` ... `reportDownload`, then `adminVarianceThreshold*`).
- `apps/pos/src/styles.css`: block "Shift close, drawer cash and reports" appended at the end.

## Decisions and notes

- No separate `shifts/correct.rb`: closed records are read-only; the correction path is a new `CashReconciliation` (custody) or, for cash, a manual movement on the current shift — both audited. Report controllers are one allowlisted `ReportsController` with one service per report instead of a controller per report.
- Count is a separate command from close so the pending count and reason survive a 409 and the approver sees exactly what they approve; any cash movement after the count makes it stale and the close is refused (`count_stale`), which is also what the race specs observe when cash wins.
- Only the counter can close on their count (`recount_required` otherwise); a manager with `pos.topology.recover` may count and close an absent cashier's shift.
- Blind count is advisory, as in the spec: a cashier can recount after seeing expected; every count is audited (`shift.count`).
- Download returns a JSON envelope with the CSV text (the SDK client parses JSON); the browser saves it as a file.
- Shift approvals bind `amount` = signed variance.

## Concerns

- Development DB not migrated (same backup constraint as earlier phases).
- `credit-approvals.tsx`, `approval.rb` and `refunds/confirm_payout.rb` are also edited by the concurrent returns work; my hunks there are the single lines listed above.
- Drafts left on a closed shift stay recoverable but cannot take payment; there is no move-to-new-shift action yet. *(Fixed after review: see below.)*

## Sửa sau review

Two independent reviews found defects; all fixed with tests. Decisions applied: strict blind count in reports; drafts without received money move to the cashier's new open shift when resumed (audited), drafts holding money still block close; cash out and safe drop are two-person (requested → confirmed, only confirmed posts the movement under the barrier).

### Backend

1. **Held custody never leaves a drawer.** New `CustodyPayout` (`app/services/spree/pos/custody_payout.rb`): a cash liability payout or cash refund on funds with custody `held` (not reconciled `new_physical_inflow` / `in_opening_float`) is refused with `held_custody`; with `paid_from: 'custody'` and a reference it is a custody-only outflow (PayoutEvidence metadata `paid_from: custody`, no CashMovement). Drawer cash sent as custody is refused `not_held`.
2. **Stale count by id**: count stores `closing_cutoff_movement_id`; `count_stale?` compares movement ids.
3. **No double explanation**: held cash on a shift whose closure has an overage is linked to (and counted against) that closure even when not named; a closure overage already explained refuses further cash with `overage_explained`. Closure-only reconciliations stay allowed (with an amount). `in_opening_float` requires a target shift and never claims more than its float minus earlier claims (`exceeds_float`). Separation of duties excludes the shift owner, its closer, its variance approver and the held-cash recorder.
4. **Two-person outflows**: `CashMovementRequest` model + `Shifts::ConfirmCashMovement` (confirm/cancel); `PostCashMovement` posts cash in immediately and records cash out / safe drop as a request (evidence required). Confirmer holds `pos.cash.move` or `pos.approval.grant`, not the requester; confirmation posts one movement under the shift barrier and re-checks drawer cash. Pending requests block the close.
5. **Export scope**: `export_requests.full_scope`; generation and download require `pos.report.read` again when the export was branch-wide.
6. **Exports at scale**: keyset pagination (`Base#each_row`, receivables keyed by order id); CSV written to a Tempfile with UTF-8 BOM; formula escaping also behind leading whitespace; atomic `queued → processing` claim (`update_all … where status queued`), no enqueue on idempotent replay; download is `POST /pos/exports/:id/download_link` (re-authorizes, returns a one-minute signed link) and `GET /pos/export_files/:token` streams the blob (`ExportFilesController`, `ActionController::API`, 404 bad token, 410 expired).
7. **Report summaries**: cashbook shift summary paged (`shift_page`, 50 per page, true `shift_count`/`shift_pages`) with one grouped flow query per page; receivables summary is one SQL aggregate.
8. **Receipts recheck**: count/approve/close/movement/request results carry `branch_id`; request spec rechecks every shift/report command through `command_receipts`.
9. Low: a concurrent close with another key returns the existing snapshot; `received_at` parsed in the branch timezone (held cash within its shift's window, bank evidence ≤ 90 days, never future); `ShiftBarrier` uses `FOR NO KEY UPDATE` (still serializes holders; race specs pass); checklist blocks payouts/refunds marked unknown by this shift's owner (the would-be confirmer), not merely requested ones; refund items carry `return_id`, payout items `funds_id`; manager endpoint `GET /pos/shift_closures/open` (recover capability).
10. **Races** (two connections): close vs cash refund payout, unsolicited drawer cash, manual cash in, safe-drop confirmation vs count, late-cash inflow, credit completion, and two closes with different keys (same snapshot).

### Frontend

- A. Cash movement intent fixed per dialog instance; count intent `count:${revision}`, close `close:${revision}`, approval `approve:${revision}`, cash-request decisions `${decision}:${id}`, reconciliation per wizard instance; retries keep the revision of the uncertain attempt; a recovered earlier count is announced.
- B. Closure-only late cash sends an editable whole-VND `amount`, capped at the unexplained overage.
- C. Non-definitive errors show "Đang kiểm tra kết quả" + "Kiểm tra lại" (dialog, wizard, request list); reopening the close dialog with a pending local record offers the recheck (`usePendingShiftCommands`).
- D. Checklist actions activate the draft tab before going to the sale screen; refunds link `/returns?returnId=`, payouts `/funds?fundsId=` (funds page opens that item); draft warnings say they continue on the next shift.
- E. Cashbook tab shows the per-shift summary table with its own pagination.
- F. Rows of a previous report view are never shown under another report's columns.
- G. Approver button disabled "Chờ thu ngân nhập lý do" until the cashier gives a reason.
- H. Expired exports hide download; 410 shows "Bản xuất đã hết hạn, hãy tạo lại" and refetches; downloads use the signed link (streamed by the browser).
- I. Strict blind count: server hides the reader's own uncounted open shift from cashbook and its cash receipts (rows and totals) until the count.
- J. Currency from data; branch/meta timezone everywhere (`formatInZone`); today follows the branch day until dates are picked; count result written into the cache and approval polled when reopening; shift and "chỉ ca của tôi" filters; recover holders can close an absent cashier's open shift from the Shifts page; unknown server messages fall back to Vietnamese `shiftFailureGeneric`; Home/End on report tabs; late-cash wizard shows the held cash's shift and the closure's counted/expected.
- Held-custody liability payouts in the funds dialog confirm with a custody reference (`paid_from: custody`).

### Files (review fixes)

Created: `server/db/migrate/20261107150000_add_pos_cash_movement_requests.rb` (test DB only: `spree_pos_cash_movement_requests`, `spree_pos_shifts.closing_cutoff_movement_id`, `spree_pos_export_requests.full_scope`); `server/app/models/spree/pos/cash_movement_request.rb`; `server/app/services/spree/pos/{custody_payout,shift_rebind}.rb`; `server/app/workflows/spree/pos/shifts/confirm_cash_movement.rb`; `server/app/controllers/spree/api/v3/admin/pos/export_files_controller.rb`; `server/app/controllers/spree/api/v3/admin/pos/shifts/cash_movement_requests_controller.rb`; `apps/pos/src/components/cash-request-list.tsx`.

Rewritten/changed (own files): shift `guard`, `count`, `close`, `post_cash_movement`, `reconcile_late_cash`; `shift_checklist`, `shift_barrier`, `reports/{base,scope,cashbook,receipts,receivables,export_file}`, `generate_export_job`, `exports_controller`, `cash_reconciliations_controller`, `shifts/closures_controller`; specs `shift_closure_spec` (35), `reports_spec` (15), `shift_close_spec` (3), `shift_close_race_spec` (10), `spec/support/pos_shift_helpers.rb`; frontend `lib/shifts.ts` (+test), `hooks/use-shift-close.ts`, `hooks/use-reports.ts`, `components/{shift-close-dialog,cash-movement-dialog,late-cash-wizard,shift-approvals}.tsx`, `pages/{shifts,reports}.tsx`, `e2e/shift-reconciliation.spec.ts`.

Shared files, hunks added by the review fixes:

- `server/db/schema.rb`: version `2026_11_07_150000`; table `spree_pos_cash_movement_requests` (+ indexes, kind/status/amount/movement checks); `spree_pos_shifts.closing_cutoff_movement_id`; `spree_pos_export_requests.full_scope`.
- `server/config/routes.rb` (inside the phase block): `post :download_link` replaces `get :download`; `get 'export_files/:token'`; `resources :cash_movement_requests` with `confirm`/`cancel`; `get 'shift_closures/open'`.
- `server/app/models/spree/pos/cash_movement.rb`: `branch_id` in `to_pos`.
- `server/app/models/spree/pos/workspace.rb`: `source_is_immutable` lets `register_id`/`shift_id` change only inside the new `rebind_shift!(shift)` (public method added before `private`).
- `server/app/workflows/spree/pos/workspaces/claim_lease.rb`: one `ShiftRebind.call(workspace:, staff:)` line (+ comment) before the lease update.
- `server/app/workflows/spree/pos/liability_payouts/confirm.rb`: `paid_from:` keyword + payload key; `from_drawer` via `CustodyPayout.drawer?` decides the drawer; re-check inside the funds lock (`retry`); PayoutEvidence `metadata` paid_from.
- `server/app/controllers/spree/api/v3/admin/pos/received_funds_controller.rb`: passes `paid_from`.
- `server/app/workflows/spree/pos/record_unsolicited_funds.rb`: `actual_received_at(value, drawer, shift, kind)` parses in the branch timezone with bounds (`LATE_EVIDENCE_WINDOW`).
- **Returns/refunds files (minimal):** `server/app/workflows/spree/pos/refunds/confirm_payout.rb` — (a) `paid_from: nil` keyword and `'paid_from'` payload key; (b) `from_drawer = … CustodyPayout.drawer?(…)` and `drawer = from_drawer ? open_drawer!(…) : nil` replacing the old drawer line, plus `paid_from_metadata`; (c) PayoutEvidence metadata `.merge(paid_from_metadata)`; the earlier barrier line is unchanged. `server/app/controllers/spree/api/v3/admin/pos/refund_requests/confirmations_controller.rb` — passes `paid_from: params[:paid_from]`.
- `apps/pos/src/router.tsx`: `/funds` gets `validateSearch` for `fundsId`.
- `apps/pos/src/pages/received-funds.tsx`: `useSearch` import; initial `selectedId` from `fundsId`; `paidFrom` passed to payout confirm.
- `apps/pos/src/components/liability-payout-dialog.tsx`: held cash uses the reference form and confirms with `paidFrom: 'custody'`; label `fundsPayoutCustodyReference`.
- `apps/pos/src/hooks/use-tenders.ts`: `paidFrom` input → `paid_from` body key.
- `apps/pos/src/lib/pos-context.ts`: `custody?` on `PosReceivedFunds`.
- `apps/pos/src/pages/credit-approvals.tsx`: `ShiftApprovals` gets `timeZone` and `canConfirmCash` props.
- `apps/pos/src/locales/{vi,en}.json`: 48 new keys appended at the end (`fundsPayoutCustodyReference` … `shiftReason_retry`); `shiftChecklistWarnings` and `cashMovementOutHint` reworded in place (both in this phase's block).

### Verification (review fixes)

- `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`, run alone after the last edit: **345 examples, 0 failures**.
- Race spec run twice: 10/10 both times.
- Rubocop on new/changed own files: only `Metrics/ParameterLists` (existing pattern). Shared files: only pre-existing offenses remain (`workspace.rb` `to_pos` complexity, `claim_lease.rb` hash alignment, `routes.rb` empty block, parameter lists).
- `apps/pos`: biome clean, `tsc` clean, vitest 111 passed, Playwright (`POS_TEST_PORT=5176`) 219 passed / 6 skipped (live API), including 7 shift/report e2e tests × 3 viewports (lost count response rechecked via a committed `command_receipts` mock, closure-only amount, approver waiting for reason, two-person safe drop, cashbook shift summary, stale-row guard on tab switch, expired export).

### Remaining notes

- Held cash on a closed shift whose overage a closure-only reconciliation already explained cannot be reconciled again (`overage_explained`); it stays listed with that explanation for a manager decision.
- Development DB still not migrated (both migrations applied to test only).
