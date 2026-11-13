# Code Review: table-service selling layout

## Scope

- Commits: `79e2ae5`, `b0b96c6`, `25d04c2`, `1674057`, `608ad19`, `871c1c1` (range `4bbda60..871c1c1`). `33319cc` (pos-dashboard context loading) and `66d99fa` (dev file checker) are in the range but were not in the requested list, so they were skipped.
- Areas: `apps/pos` (hook, table-service components, payment panel, counter extraction), `packages/pos-shared` (`sellingLayoutOf`, board tones, ticket groups), `server` (send sequence, unsent count, seated alert), pos-dashboard seated-alert field.
- Checks run: `pnpm --dir apps/pos typecheck` passed. Vitest passed for `cash-suggestions`, `menu-density`, pos-shared `tables`, `ticket-groups` and `pos-modules` (58 tests). `biome check` on the changed POS files reported nothing. No e2e or rspec suites were run.

## Overall assessment

The extraction from `WorkspaceTabs` into `useSellingWorkspace` is faithful. A whitespace-insensitive diff of the old and new counter render shows only component extraction (`SellingNotices`, `OrderTrays`, `Active*` wrappers, `SellingCatalog`, `activePaymentProps`) with identical props. In panel layout, `PaymentPanel` keeps its counter behaviour: `qrAttempt` is `undefined`, so `blockingAttempts`, `heldAttempts` and `listedAttempts` reduce to the old arrays. The server changes are correct and use set-based SQL. The i18n keys are complete in both `vi` and `en`, counting the pos-shared bundle.

The defects are in the table frames. Two things cause most of them:

1. The selected order still falls back to `visible[0]`, which was written for the counter's tab strip. Table orders are booked on the branch's table register, so they are often missing from `/pos/workspaces?register_id=…`.
2. A VietQR tender is prepared automatically whenever the pay frame renders, and nothing releases it except the "← Đơn" button.

## Critical

None found.

## High

### H1. The pay frame can prepare a VietQR on the wrong order

- `apps/pos/src/hooks/use-selling-workspace.ts:160-161`: `active = rows.find(activeId) ?? visible[0]`.
- `apps/pos/src/hooks/use-workspaces.ts:103-108`: `detailId = activeId ?? <first list row of this register>`, so the fallback row gets a full detail with lines and `financial`.
- `use-selling-workspace.ts:284-296`: an order requested by the URL that is not in `rows` is dropped once the list loads. A table order on another register is only ever in `rows` through `pinned`, which needs `activeId` to match already.
- `apps/pos/src/components/payment-panel.tsx:601-617, 752-756`: `autoQr` only checks the workspace it was given. It never checks that this workspace is the order the frame is for.

Scenario: a cashier's register is not the branch's table register. They open `/?order=T5&view=pay` from a bookmark, a second tab, or after another tab of the same staff and store overwrote the shared layout in localStorage. `activeId` is null or another order X. T5 is not in the list, so the request is dropped. `active` becomes the first draft of the register, or X. `view=pay` renders `PaymentPanel` for that order and `autoQr` prepares a VietQR for its total. That order now has `payments=true`: its basket is frozen and its waiters' appends fail with `snapshot_locked`. Meanwhile the screen shows the wrong table's bill under a QR.

Fix:
- In table service, never fall back to `visible[0]`. Pass an option such as `useSellingWorkspace({ view, fallback: false })` so that `active = rows.find(activeId) ?? (pinned?.id === activeId ? pinned : null)`.
- Resolve a URL order that is not in the list by fetching its detail (look it up by `order_id`), instead of dropping it.
- Gate `autoQr` on the frame's own order, e.g. `PaymentScreen` passes `autoPrepare={active.id === selectedId && active.order_id === search.order}`.

### H2. The auto-prepared QR stays alive after the pay frame is left

- `payment-panel.tsx:601-617, 752-756`: the QR is prepared on mount.
- `apps/pos/src/components/table-service/payment-screen.tsx:130-137`: only `PayBill.back()` calls `controls.release()`. There is no release on unmount.
- `server/app/models/spree/pos/workspace.rb:114`: `payments` is true for any attempt that is not canceled or failed.
- `server/.../append_items.rb:76`: `ensure_snapshot_editable!` refuses appends while a tender is prepared.
- No server job cancels an expired VietQR attempt; the card just shows `vietqrExpired`.

Scenario: a cashier opens Pay only to check the total or print the pre-bill (`PayTools` offers it), then leaves through the shell navigation, a reload, a closed tab, a branch switch, or a lost lease. The prepared VietQR stays on the order. From then on, every waiter's phone and the order frame get `tableSnapshotLocked` or `editLockedPayments` when adding dishes. The Ticket gives no way to release the QR: someone has to go back into Pay and press "← Đơn". The QR also keeps an allocation open at the provider.

Fix (any of these):
- Release a waiting QR when `PaymentPanel` in fullscreen layout unmounts and the QR is not received. Do it best effort through the serializer, and also on `pagehide`.
- Do not prepare on mount: show the amount and prepare on the first idle second, or when the bill is turned to the guest.
- Have the server cancel expired, unreceived POS VietQR attempts.

Also give the Ticket a "Hủy QR đang chờ" action when `payments` comes only from a prepared VietQR.

## Medium

### M1. Change and remaining previews are wrong when a received QR is combined with cash

`payment-panel.tsx:569, 579-589`. When `qrIn` is true and cash is typed, `cashPays = min(cashOver, target)` uses the target from before the QR is confirmed, and `changePreview = cashOver - target`. `finish()` (`:699+`) confirms the QR first and then charges cash against `dueOf(current)`, which is already reduced by the QR amount.

Scenario: due 300.000. The cashier picks "Chia 2", and a QR for 150.000 is prepared and paid by the bank. The cashier switches the split off: the QR is no longer waiting, so it is kept. The second guest hands over 200.000. The preview shows remaining 0 and change 0. The server takes 150.000 and records 50.000 of change. The frame then jumps to the board, because `completed` fires `onCompleted`, so the real change is never shown. The cashier keeps the 50.000 that belongs to the guest.

Fix: compute the cash target in the preview as `target - (qrIn ? qrAmount : 0n)`, floored at 0, and use it in `cashPays`, `changePreview`, `leftPreview` and `finishes`. Show the server's `financial.change_due` before leaving the frame, for example with a short "Trả lại X" notice on the board.

### M2. Order frame shows another order while the table's detail loads

Same root cause as H1: `use-selling-workspace.ts:160-161` together with `selectOrder` (`:507-518`).

Scenario: the branch's table register is not the selected register. The cashier taps table 5 on the board, so `activeId` is T5. Until `selectedQuery` for T5 resolves, `active` is `visible[0]`, a takeaway draft of this register:
- The Ticket shows that draft for the length of a round trip.
- `autoClaimTarget` (`:361-385`) claims that draft's lease when this device does not own it.
- A quick tap in `OrderMenu` (`table-service-screen.tsx:164-169`) adds the dish to the draft.
- The URL is briefly rewritten to the draft's order.

Fix: same as H1. In table frames, `active` must be the selected order or null, and the Ticket and menu should show a loading state while it is null.

### M3. Pay is enabled with unsent dishes, and the order is then handed over automatically

- `apps/pos/src/components/table-service/ticket-footer.tsx:136`: the Pay button has no condition.
- `payment-screen.tsx:49-58`: handover runs automatically after completion.
- `server/.../kitchen/send.rb:20-23`: `on_complete` only sends to the kitchen when `kitchen_send_trigger == 'on_complete'`. Table orders are always sent by hand.

Scenario: a waiter adds two dishes and the cashier presses "Thanh toán" instead of "Gửi bếp (2)". The guest pays, the order is completed and handed over, and the two dishes never reach the kitchen. The old counter layout had no guard either, but the new frame puts the two buttons side by side, and the automatic handover adds "dishes are at the table" to an order that is not.

Fix: when `pending > 0`, Pay should ask "Còn n món chưa gửi bếp — gửi rồi thanh toán / thanh toán luôn", or send first. At minimum, skip the automatic handover when unsent units exist.

### M4. "Đóng" on a settled order makes a counter draft at a table branch

- `apps/pos/src/components/workspace-tabs.tsx:1108-1116`: `SellingNotices` offers `closeView`. It is rendered in the order and pay frames (`table-service-screen.tsx:103`, `payment-screen.tsx:66, 80`).
- `use-selling-workspace.ts:502`: when no row is left, `hideWorkspace` calls `createDraft()`.

Scenario: after a reload to `?order=R1&view=order` where R1 is already completed, the cashier presses "Đóng". `activeId` becomes null and `active` falls back to `visible[0]` (another order, see M2). If the register has no other open draft, a new counter draft is created, selected, and shown in the order frame with no table attached. Each time this happens, another orphan draft is left at the table branch.

Fix: give table frames their own close action: set `view='board'` and clear the selection without `createDraft`. You can also make `hideWorkspace`'s auto-create counter-only, for example behind an option of the hook.

## Low

- **L1. The counter UI renders first on every load of a table branch.** In `apps/pos/src/pages/sale.tsx:10-16`, `sellingLayoutOf(context.data)` is `'counter'` while the context loads, and `pos-shell.tsx` does not wait for it. `WorkspaceTabs` mounts, runs its own hook, then unmounts. Its URL effect also strips `?view=` when no `order` is present. Nothing is written to the server because `staffId` is null, but the counter DOM flashes. Render nothing, or a skeleton, until `context.data` is defined.
- **L2. Duplicate handover.** In `payment-panel.tsx:1046-1056` and `payment-screen.tsx:49-58`, while the automatic handover is awaited, the completed panel still shows a "Giao hàng" button. Another device on the same order also hands over when it sees `completed`. The server treats a repeat as a no-op (`handover.rb`, `shipped.empty?`), but the second device shows `payHandoverFailed` if its staff is not the shift owner. Hide the handover button in fullscreen layout.
- **L3. A failed service-mode change still opens the order.** In `apps/pos/src/components/table-service/table-board.tsx:138-152`, `startOrder` opens the new draft as a dine-in order when `setServiceMode` fails, because `served` is undefined and the code takes the else branch. Every tap on "+ Mang về / Giao đi" also creates a draft, and an abandoned one stays open. Open the order only when `served` is set, and consider reusing an empty draft of the same mode.
- **L4. The delivery dialog ignores locks.** `table-board.tsx:453`: `DeliveryDialog` passes `disabled={false}`, ignoring `locked` and `channelUnavailable`. Use `selling.editDisabled`.
- **L5. The QR countdown floods screen readers.** At `payment-panel.tsx:1610`, the VietQR status `<p role="status">` changes every second, so a screen reader announces the countdown continuously. Put the timer outside the live region, or mark it `aria-live="off"` and announce only received or expired.
- **L6. The board tile hides details from screen readers and uses the device time zone.** `apps/pos/src/components/table-service/board-tile.tsx:37-55`: the tile's `aria-label` replaces its content, so minutes seated, guests and total are not read. Fold them into the label or use `aria-describedby`. The booking time is formatted in the device's time zone (`toLocaleTimeString` without `timeZone`), unlike the Ticket, which uses `orderTimeZone`.
- **L7. "Cần thu" does not change after a partial payment.** At `payment-panel.tsx:1157` it always shows `totals.total`. After a partial cash or split payment it still shows the full bill while "Còn lại" is smaller. Show the remaining amount, or label the value as the bill total.
- **L8. Dead props.** `workspace-tabs.tsx:115-125`: `WorkspaceTabsView` props `catalog`, `className` and `onBoard`, and the `onBoard` branch at `:221-224`, are no longer used by anyone since `608ad19`. Remove them to keep counter DOM parity easy to verify.
- **L9. One tap marks a dish sold out for the whole branch.** `apps/pos/src/components/table-service/menu-item-grid.tsx:147-155`: the sold-out toggle sits on every tile and needs no confirmation.

## Verified non-issues

- **`kitchen_send_by_line`** (`workspace.rb:246-254`) is a single grouped query, scoped to `workspace_id` and `kind='fire'`. Course fires go through `Send.call`, which runs `record_send!`, so the inner join to `spree_pos_kitchen_sends` does not drop fired courses. Appends merge only into unsent lines (`append_items.rb:28`), so the minimum sequence is the line's only send.
- **`UNSENT_ITEMS`** (`resource_state.rb:151-158`) matches `Kitchen::Send` and `SaleLine#pending_kitchen_quantity`. `course_status` is NOT NULL with a default, so `<> 'held'` is safe. It is a correlated subquery per board row, not N+1.
- **`seated_alert_minutes`:** the model validation, DB check constraint, workflow parse (`Integer(raw, 10, exception: false)`, range 10..600, blank turns it off) and dashboard parser agree. Writes go through `manage!` authorization in `CommandExecutor`.
- **`placeLine`:** `findLine` matches by `sale_line_id`, and the server allows a seat-only change on a sent line (`edit_unsent_line.rb:23-25`).
- **Ticket stepper and remove:** passing `sale_line_id` to `updateItem` and `removeItem` matches the counter's `OrderLines` (`items/:id/update` takes a sale line id).
- **Even split:** `evenShare` rounds up and `target = min(share, due)`, so the parts add up exactly (100.000 / 3 gives 33.334 + 33.334 + 33.332).
- **QR re-prepare loop:** `triedQr` keys on order and amount, is cleared after `finish` and `releaseQr`, and failures are not retried automatically. StrictMode double effects are guarded by the ref.
- **Cash with a waiting QR:** the QR is canceled first, and if the bank already reported the money the server refuses the cancel (`vietqr_tender.rb:110-117`), so cash is not taken on top of it. A transfer that arrives after the cancel is released by the provider allocation and handled as unapplied funds on the server.
- **i18n:** every literal and dynamic key family used by the changed files exists in both `vi` and `en`. `tableState_*` and `missing` come from the pos-shared bundle.
- **Single hook call:** `useSellingWorkspace` is called once in `TableServiceScreen` and once in `WorkspaceTabs`. `SalePage` mounts only one of the two (see L1 for the transient mount).

## Recommended actions (priority order)

1. H1 and M2: remove the `visible[0]` fallback in table frames, resolve URL orders outside the list, and gate `autoQr` on the frame's own order.
2. H2: release the auto-prepared QR on unmount and `pagehide`, or delay preparing it; add a release action on the Ticket.
3. M1: correct the cash target in the preview when a received QR is combined with cash, and show the server's change before leaving the frame.
4. M3: add a guard on Pay when dishes are unsent, and skip the automatic handover in that case.
5. M4: give table frames their own close action, without `createDraft`.
6. Low items as convenient. L1 is a small fix with a visible benefit.

## Unresolved questions

1. Should opening Pay prepare the QR at once (decision L8 and the mockup), or only when the cashier turns to payment? This decides whether the fix for H2 is a release on unmount or a delay.
2. Should a branch whose table register is not the cashier's register be supported in the order and pay frames? The M2 window only exists in that configuration. If it is unsupported, a guard or notice would be cheaper than fixing the fallback.
