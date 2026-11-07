# Phase 7 implementation: credit sales, receivables, collections

Status: implemented, not committed. Phase status cells were not edited.

## What was built

- Schema `20261107120000_create_spree_pos_receivables`: `spree_pos_credit_accounts` (store + customer profile + currency, limit, due days, active/suspended), `spree_pos_credit_reservations` (one active per workspace, unique per approval), `spree_pos_collections` (one per parent ReceivedFunds), `spree_pos_receivable_entries` (immutable debit / credit_note / collection / collection_reversal with check constraints and unique source links), `spree_pos_funds_allocations.collection_id`. Applied to the test DB only; `schema.rb` diff is additive.
- Capabilities `pos.credit.manage` (configure accounts, checked on the branch in the request) and `pos.credit.sell` (complete on credit). Collecting reuses `pos.payment.collect`; reversing a collection child needs `pos.payment.resolve`.
- Approval: `POST /pos/workspaces/:id/credit_approvals` (approver session, `Approval` with action `credit.sale`, bound to requester, amount = unpaid remainder, revision, customer, TTL). Exposure is reserved under the account row lock: ledger balance + usable reservations + amount <= limit. A reservation stops counting the moment its approval is revoked/expired/consumed or the workspace leaves that revision/customer/editing state (SQL `holding` scope), and is marked released with an audit when a command meets it (customer change, park/cancel, revoke, refused completion). The generic approvals endpoint refuses `credit.sale`.
- Completion: `credit_approval_id` on `/complete`. Server computes debt = total - active allocations, commits the reservation into a debit (due date in branch timezone) in the same transaction as placement, and calls `Spree.order_complete_workflow` with `payment_pending: true` only in that case. Core payment status stays derived (`partially_paid`/`none`), never `paid` from credit; no fake Payment.
- Handover of a credit order forces core dispatch only when completed payments + the order's debit cover the total, after checking backorders and shelf stock itself.
- Collections: `POST /pos/collections` records one ReceivedFunds on the collector's own open shift (cash: handed/change + CashMovement; bank: reference + receiving account), then child allocations (core Payment + FundsAllocation + collection entry) bounded by `FundsBalance#available` under the parent lock and by each order's ledger balance. `POST /pos/collections/:id/allocations` allocates the remainder later; `.../allocations/:id/reverse` voids one child. Lock order: workspace -> account -> parent funds -> orders.
- `FundsBalance` now treats core Refunds of child Payments as `paid_out` (also after reversal) and subtracts them from `allocated`; a reverse of a child with any refunded part is rejected.
- Projection: `ReceivableProjection` (debt, credit notes, collected net of reversals, refunds, balance, due date, overdue, aging buckets) from the ledger only. `GET /pos/receivables` (server-side status/customer/search filters, paging) and `GET /pos/receivables/customers` (per-customer balance/overdue/aging). Branch members only; phone masked unless the reader collects, approves or manages credit.
- Return seam: `ReceivableEntry.post_credit_note!` (capped at open balance, unique per source); no UI.
- POS app: "Ghi nợ" in the payment panel with `CreditApprovalDialog` (customer, limit/available, due date, approver, "Hoàn tất & ghi nợ"), credit lines in the payment summary, `/receivables` page and nav, `CollectionDialog` with oldest-first multi-order allocation preview, change and remainder. All money commands go through `runFinancialCommand`.

## Verification

- `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`: 220 examples, 0 failures (203 before).
- New specs: `spec/workflows/spree/pos/credit_sales_spec.rb`, `collections_spec.rb`, `spec/requests/spree/pos/credit_receivables_spec.rb`, `spec/integration/spree/pos/credit_race_spec.rb` (two real connections: concurrent approvals vs one limit; concurrent collections vs one debt).
- `apps/pos`: lint clean, typecheck clean, vitest 88 passed, Playwright (`POS_TEST_PORT=5175`) 168 passed, 6 skipped (live API).
- Rubocop: only `Metrics/ParameterLists` remains on new workflow signatures, the same pattern existing POS workflows already carry.

## Open points (first pass)

- Approvals and credit account administration were API-only (both now have screens; see below).
- A collection command with allocations is all-or-nothing: if a concurrent collection already settled the debt, the second receipt is refused and must be re-recorded (for example without allocations, which keeps it available as liability).
- Collection reversal has no UI; refunds of collected payments are only shown, they do not raise the balance. Both belong with the phase 8 refund and return seam.

## Sửa sau review

Quyết định đã áp dụng:

- Tài khoản công nợ có chi nhánh gốc (`branch_id`, đặt khi tạo, không đổi). Tạo/sửa/tạm khóa cần `pos.credit.manage` tại chi nhánh gốc. Liệt kê cần `pos.credit.manage` tại chi nhánh được hỏi và chỉ trả tài khoản gốc ở đó; thu ngân chỉ tra một khách bằng `customer_id`.
- Khách trả nợ ở chi nhánh bất kỳ mà người thu có `pos.payment.collect`; phân bổ được vào nợ của khách ở mọi chi nhánh cùng store; tiền mặt vào ca đang mở của chính người thu. Tra cứu nợ theo khách đi xuyên chi nhánh; danh sách theo chi nhánh vẫn chỉ gồm đơn bán tại chi nhánh đó.
- Duyệt ghi nợ cần cả `pos.approval.grant` và `pos.credit.manage` tại chi nhánh của đơn.
- Duyệt cấp trước khi hạ hạn mức vẫn được hoàn tất (ghi chú trong `credit/configure.rb`).
- Trùng mã giao dịch ngân hàng (reference + tài khoản nhận, không phân biệt hoa thường/khoảng trắng) khi thu nợ chuyển khoản và khi xác nhận tender chuyển khoản: 409 `duplicate_reference`, trừ khi người có `pos.payment.resolve` gửi `confirm_duplicate: true` (ghi audit `funds.duplicate_reference_confirmed`). Một helper chung `ReceiptReferenceGuard`.

Backend:

1. Giao hàng ghi nợ khóa các dòng `StockLevel` (theo id) trước khi kiểm tra kệ; test đua hai kết nối (kệ còn 1, hai lần giao: một thành công, một 409) và test thiếu kệ.
2. `credit_accounts` lọc theo chi nhánh gốc / tra một khách như trên.
3. Tìm kiếm công nợ khi bị che số: chỉ khớp tên hoặc nguyên số điện thoại đã chuẩn hóa, không khớp đoạn số.
4. `Workspace#financial_pos` bỏ qua phân bổ thu nợ; `Funds::Allocate` không gắn khoản thu nợ vào một đơn.
5. Phân bổ phần tiền còn lại sau đó cần `pos.payment.resolve`; người thu ban đầu vẫn làm được bằng `pos.payment.collect` khi ca giữ tiền là ca đang mở của chính họ.
6. Mọi lệnh trên workspace (qua `CommandExecutor`) đóng và ghi audit các reservation không còn dùng được (đổi revision, khách, trạng thái, hết hạn, bị thu hồi) và đánh dấu yêu cầu ghi nợ cũ là `stale`; job phục hồi quét reservation hết hạn của đơn không ai chạm tới. Hoàn tất không ghi nợ cũng đi qua bước này.
7. Test thêm: duyệt hết hạn trước khi hoàn tất; thu hồi đua với hoàn tất (hai kết nối, chỉ một kết quả); luồng hoàn tiền một phần trên khoản thu nợ.
   - Không làm đảo phân bổ một phần: Spree 6 không có cách giảm một Payment đã completed (đã kiểm `Spree::Payment`: chỉ có `void!`, `invalidate!`, `update_store_credit_amount!` cho store credit). Mọi cách khác (void rồi tạo Payment mới, Refund giả) đều làm sai số đã thu/đã hoàn của core. Vì vậy đảo toàn phần bị từ chối (`allocation_consumed`), 60k chưa hoàn vẫn thuộc đơn A, đơn B không nhận được gì từ khoản thu đó (test khẳng định 60k bị từ chối).
8. Luồng yêu cầu duyệt: bảng `spree_pos_credit_requests` (một yêu cầu cho mỗi revision của workspace). `POST /pos/workspaces/:id/credit_requests` (thu ngân), `GET /pos/credit_requests?branch_id=` (người duyệt), `POST /pos/credit_requests/:id/{approve,reject,revoke}` (dùng lại `Credit::Approve`, `Credit::Reject`, `Approvals::Revoke`). Endpoint credit của workspace trả thêm `request`.

Frontend:

- A. Thu nợ dùng một khóa idempotency cố định cho mỗi tài khoản công nợ (`intent: 'receipt'` trong `runFinancialCommand`): gửi lại sau khi sửa "Khách đưa" vẫn dùng khóa cũ, kiểm biên nhận trước; đã ghi thì báo đã ghi nhận, chưa rõ thì chặn thu mới cho khách đó và hiện "Kiểm tra lại". Trang công nợ hiện các bản ghi cục bộ chưa rõ kết quả.
- B. Hộp thoại ghi nợ tự gửi yêu cầu duyệt, tự kiểm tra lại mỗi 5 giây khi đang chờ, coi duyệt hết hạn là không dùng được, luôn có nút kiểm tra khi chưa hoàn tất được, tải lại sau khi hoàn tất thất bại.
- C. Trang công nợ: về trang 1 khi đổi khách; chỉ phân bổ vào đơn đang hiện; không đóng hộp thoại khi đang gửi; lỗi hiện ở cả trang; hộp thoại giữ trạng thái thành công khi khách đã hết nợ.
- D. Lý do xung đột có câu tiếng Việt riêng (`conflictReason_*`).
- E. Nút "Ghi nợ" bị khóa kèm lý do khi còn khoản thanh toán đang chuẩn bị hoặc chưa rõ.
- F. `useModalFocus`: trả focus về nút mở, Escape/Tab ở mức document, giữ focus khi nút bị disable, nền `inert`.
- G. Hạn trả dd/MM/yyyy; thời điểm theo Asia/Ho_Chi_Minh; báo lỗi định dạng "Khách đưa"; so tiền theo dấu; chặn gửi trùng; khóa số nhiều tiếng Anh.
- H. Trang "Công nợ khách hàng" (`/credit-accounts`, cần `pos.credit.manage`): danh sách, mở tài khoản (tìm khách), sửa hạn mức/số ngày nợ, tạm khóa/mở lại.
- I. Trang "Duyệt" (`/credit-approvals`, cần duyệt + quản lý công nợ): duyệt, từ chối có lý do, thu hồi duyệt còn hiệu lực.
- J. E2e cho A, B, H, I trong `e2e/credit-collections.spec.ts`.

Kiểm tra sau sửa:

- `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`: 237 examples, 0 failures. Một lần chạy trước đó có `sale_lines_spec.rb:233` lỗi ngẫu nhiên (test cũ: `SaleLine.find_by(merge_key:)` không có thứ tự giữa hai dòng cùng khóa); chạy lại đều qua, không liên quan thay đổi này.
- Rubocop trên file mới/sửa: chỉ còn `Metrics/ParameterLists` (cùng mẫu các workflow POS hiện có) và các vi phạm có sẵn từ trước trong file cũ.
- `apps/pos`: biome sạch, `tsc` sạch, vitest 95 passed, Playwright (`POS_TEST_PORT=5175`) 177 passed, 6 skipped (live API).
