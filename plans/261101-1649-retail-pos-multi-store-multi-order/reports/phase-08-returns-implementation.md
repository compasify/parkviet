# Phase 8 (phần 1): lịch sử đơn, trả hàng, giảm nợ, hoàn tiền, đổi hàng

Trạng thái: đã triển khai, chưa commit. Không sửa ô trạng thái của plan/phase. Phần 2 (serial/lô/hạn dùng, FEFO, tích hợp mọi writer kho, I01–I07) chưa làm; SaleLine giữ nguyên định danh/provenance để phần 2 gắn vào.

## Seam core đã chọn (Spree 6.0.2)

Spree 6 bỏ chuỗi `ReturnAuthorization → CustomerReturn → Reimbursement`; thay bằng một bản ghi `Spree::Return` đi qua các workflow. Đã đọc nguồn `spree_core-6.0.2` trong container (`app/workflows/spree/returns/*`, `post_sale/receipt.rb`, `refunds/create.rb`, `models/spree/{return,return_line_item,refund,payment}.rb`).

- **Dùng**: `Spree::Returns::Create` (gắn với `FulfillmentItem` gốc, tự kiểm số lượng còn trả dưới khóa order; `stock_location` = kho bán của chi nhánh nhận), `Spree::Returns::Approve`, `Spree::Returns::Receive` (chỉ nhập lại đơn vị `resellable`, một lần; chuyển `approved → received` nên nhận lại lần hai bị từ chối), `Spree::Returns::Cancel`.
- **Dùng**: `Spree::Refunds::Create` trên Payment của đúng allocation child, `originator` = `Spree::Return`, **chỉ** trong lệnh xác nhận đã chi có bằng chứng. Phương thức POS là manual (`Check`), `credit` của nó không gọi cổng thanh toán, nên Refund core chỉ ghi lại một khoản chi đã thật sự xảy ra.
- **Không dùng**: `Spree::Returns::Refund` — nó tự chọn payment, gọi gateway và lấy `refund_total` của return (giá trị hàng, gồm cả phần chưa từng thu của đơn ghi nợ). Không dùng `Spree::Exchange` core (thay hàng trong cùng order); đổi hàng là đơn bán mới. Không sửa giá lịch sử, không gán `payment_status`, không tạo Refund cho tiền chưa nhận.

## Đã làm

Backend (`server/`):

- Migration `20261107130000_create_spree_pos_return_operations` (chỉ chạy trên test DB; `schema.rb` chỉ thêm, ngoài việc `payout_evidences.liability_payout_id` thành nullable): `spree_pos_branches.return_window_days` (null = tắt trả hàng), `spree_pos_return_operations`, `spree_pos_return_reservations` (theo SaleLine, có `sequence`, `cumulative_before/after`, các thành phần total/net/tax/discount/gross với check `total = net + tax`, `gross − discount = net`, tất cả ≥ 0), `spree_pos_refund_requests` (check `confirmed ⇔ refund_id`), `spree_pos_exchange_operations`, `spree_pos_stock_discrepancies`; `payout_evidences.refund_request_id` (đúng một chủ thể), `cash_movements.refund_request_id`.
- Capability `pos.return.process`. Cửa sổ trả hàng do người có `write_pos_topology` đặt qua `PATCH /pos/branches/:id`.
- `ReturnEntitlement`: giá trị gốc từng dòng làm tròn nguyên tiền bằng largest-remainder trên toàn đơn (cả giá base-unit lẻ và giảm giá cấp đơn); E(q) lũy kế, round-half-up theo net/tax/discount, total = net + tax; E(Q) đúng giá trị gốc. 5 × 0,4 trả 1+1+3 → 0+1+1 = 2.
- Workflow `returns/{prepare,approve,receive,cancel,apply_credit_note}`: khóa SaleLine theo id; số lượng còn trả = base_quantity − reservation chưa hủy; cần duyệt khi khác chi nhánh, quá hạn hoặc hư hỏng (Approval gắn requester/operation/revision/số tiền, người duyệt khác requester). Ghi giá trị khi nhận hàng: giảm nợ trước qua `ReceivableEntry.post_credit_note!(up_to_balance: true)` dưới khóa tài khoản công nợ; phần còn lại thành quyền hoàn, chặn bởi tiền đã thu trừ quyền hoàn đã cấp cho phiếu khác. Phiếu sau không được ghi khi phiếu trước cùng dòng chưa xong (`awaiting_predecessor`); hủy phiếu trước tính lại các phiếu sau chưa ghi (tăng revision ⇒ duyệt cũ hết hiệu lực), từ chối hủy nếu phiếu sau đã ghi.
- Workflow `refunds/{request,approve,confirm_payout,resolve}`: yêu cầu giữ tiền trên allocation child dưới khóa receipt cha (`FundsBalance` tính reserved/unknown của refund vào `payout_reserved`, không còn trong `allocated`); xác nhận cần người duyệt khác (người duyệt tự xác nhận, hoặc người yêu cầu dùng Approval); tiền mặt ghi `CashMovement` âm vào ca đang mở của người chi tại chi nhánh trả; ngân hàng cần mã giao dịch; `unknown` giữ tiền; `failed_no_effect` cần bằng chứng và quyền `pos.payment.resolve`; `cancel` chỉ khi chưa chi. Đảo phân bổ thu nợ bị từ chối khi child có refund đã chi hoặc đang giữ.
- `exchanges/execute`: tạo workspace bán mới trên ca của nhân viên, `ExchangeOperation` liên kết; chênh lệch chỉ hiển thị, hai vế giữ chứng từ riêng.
- Giao hàng (`orders/handover.rb`): kiểm kệ dưới khóa `StockLevel` cho mọi đơn; thiếu thì **không chặn, không force âm kho**: fulfillment giữ allocated, ghi `StockDiscrepancy` (một bản mở cho mỗi fulfillment/variant) + outbox `stock.discrepancy`; giao lại sau khi kho được điều chỉnh sẽ xuất kho đúng một lần và đóng discrepancy.
- Đọc: `GET /pos/orders` (lọc server: số đơn, khoảng ngày theo múi giờ chi nhánh, quầy, thu ngân, trạng thái `all|debt|returned|refund_pending`, phân trang), `GET /pos/orders/:id` (timeline: tổng gốc, khoản thu/đã hoàn/đang giữ/còn hoàn, quyền trả đã ghi/đang giữ, giảm nợ, công nợ, phiếu trả, hoàn tiền, đổi hàng, fulfillment, nhập lại/hư hỏng, thiếu tồn), `GET /pos/orders/lookup?number=&branch_id=` (tra đúng số đơn để trả khác chi nhánh, che PII).
- Endpoint: `POST /pos/returns/preview`, `/pos/returns` (+ `approve`, `receive`, `cancel`), `/pos/refund_requests` (+ `approve`, `confirmation`, `resolution`), `/pos/exchanges`. Endpoint duyệt chung từ chối action `return.process`/`refund.payout`.
- Job `RecoverReturnOperationJob` (5 phút): ghi các phiếu đang chờ phiếu trước đã xong; báo attention một lần cho refund reserved/unknown quá 15 phút và thiếu tồn chưa xử lý. `OutboxEntry.record_once!` dùng chung với `RecoverSettlementJob`.

Sửa lỗi có sẵn phát hiện khi test:

- `Adjusters::ManualDiscount`: mọi đơn có giảm giá POS **không hoàn tất được** sau khi đã thu tiền (hoàn tất tạo fulfillment ⇒ core tính lại tổng ⇒ adjuster raise). Nay chỉ từ chối khi giảm giá thật sự thay đổi sau khi có payment; tính lại cho cùng kết quả thì giữ nguyên dòng. `pricing_spec` cập nhật theo bất biến này.
- `ManageLineItem`: gộp gói (`merge: true`) dùng `find_by` không thứ tự giữa các gói cùng merge key ⇒ `sale_lines_spec.rb:233` lỗi ngẫu nhiên. Nay gộp vào gói cũ nhất.

Frontend (`apps/pos/`):

- `lib/returns.ts` (kiểu DTO, cộng/so sánh tiền bằng BigInt 4 chữ số lẻ, tách giảm nợ/hoàn tiền, mặc định số tiền hoàn, chênh lệch đổi hàng, kiểm số lượng chọn), `hooks/use-returns.ts` (mọi lệnh tiền — yêu cầu hoàn, xác nhận chi, xử lý — qua `runFinancialCommand` với intent riêng cho từng khoản).
- Trang `/orders` (lọc, danh sách, chi tiết + timeline, nút "Trả / đổi hàng"), `/returns` (tìm đơn, chọn số lượng + tình trạng, xem trước lũy kế/đã ghi/đang giữ/lần này + thành phần, giảm nợ vs hoàn tiền, lý do; chờ duyệt tự cập nhật; nhận hàng; hủy; hoàn tiền; đổi hàng), `RefundEvidenceDialog` (đếm tiền mặt / mã giao dịch, "Chưa rõ"; `useModalFocus`).
- Trang Duyệt: thêm phần "Trả hàng và hoàn tiền" cho người có `pos.approval.grant` (phần ghi nợ vẫn cần thêm `pos.credit.manage`); hoàn tiền `unknown` hiện cần kiểm tra. Nav/menu: Đơn hàng, Trả / đổi hàng, Duyệt theo quyền. Cấu hình chi nhánh có "Số ngày cho phép trả hàng". Locales vi/en.

## Kiểm tra

- Backend: `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos` — 271 examples, 0 failures (237 trước phase này).
- Spec mới: `return_entitlement_spec`, `credit_returns_spec` (1tr/300k/700k: trả 400k → nợ 300k, không hoàn; trả hết → nợ 0, quyền hoàn 300k), `refunds_spec`, `fulfillment_returns_spec`, mở rộng `funds_conservation_spec` (F20, F19), `integration/return_race_spec` (2 kết nối: tranh đơn vị cuối, refund vs liability payout cùng receipt, hai refund tranh quyền hoàn còn lại), `requests/returns_refunds_spec` (A02/A03/A05). Cập nhật `credit_race_spec`, `credit_sales_spec` (thiếu kệ nay ghi discrepancy thay vì 409).
- Rubocop trên file mới/sửa: chỉ còn vi phạm có sẵn trong dòng cũ (`approval.rb:72`, `capabilities.rb` comment, `manual_discount.rb` dòng dài cũ, `branches_controller`/`approvals_controller` dòng cũ).
- `apps/pos`: biome sạch, `tsc` sạch, vitest 102 passed, Playwright (`POS_TEST_PORT=5175`) 189 passed, 6 skipped (live API); `e2e/returns-exchanges.spec.ts` mới; `administration.spec.ts` cập nhật 13 quyền.

## Quyết định / điểm cần biết

- Thiếu kệ khi giao: chọn giữ fulfillment allocated + discrepancy thay vì force âm kho (quyết định tồn kho cấm force/âm kho). Chưa có màn hình đối soát discrepancy; hiển thị trong chi tiết đơn và outbox attention.
- Duyệt trả hàng gắn requester: chỉ người lập phiếu dùng được Approval để nhận hàng. Người duyệt có thể tự xác nhận chi hoàn (khác requester).
- Trả hàng chỉ cho đơn vị đã giao (fulfillment `fulfilled`); đơn đang thiếu tồn chưa giao thì chưa trả được.
- Làm tròn lũy kế theo net và tax riêng (round-half-up); total = net + tax có thể lệch 1 đơn vị so với làm tròn trực tiếp total ở lần trả giữa, nhưng luôn đơn điệu và lần trả cuối luôn đủ giá trị gốc.
- Đổi hàng không bù trừ: tiền mặt hoàn (có duyệt) và tiền thu đơn mới là hai chứng từ; két chênh lệch ròng đúng bằng số khách trả thêm/nhận lại.

## Sửa sau review

Backend:

1. Giao thiếu kệ hoàn tất được: `POST /pos/orders/:id/reconcile_handover` (`Orders::ReconcileHandover`, cần `pos.payment.resolve` tại chi nhánh bán, không cần chủ ca) giao lại dưới cùng khóa `StockLevel` và quy tắc force-chỉ-khi-ghi-nợ. Job phục hồi tự giao khi kệ đã đủ (kiểm trước, không ghi lại thiếu hụt mỗi lượt). Khi còn thiếu: outbox `order.handover_short` và audit `<action>_short`, không phát `order.handed_over`. Trước khi ghi thiếu hụt kiểm đã thu đủ hoặc ghi nợ được duyệt (`not_covered`). Giao lặp lại khi không còn gì để giao là no-op. Hàng giao thiếu vẫn chưa trả được cho tới khi đối soát.
2. Che thông tin: `beneficiary_reference`, mã giao dịch của khoản thu và bằng chứng chi chỉ còn 4 ký tự cuối, trừ người có `pos.approval.grant` hoặc `pos.payment.resolve` tại chi nhánh. Kết quả lệnh (được lưu trong command receipt) luôn che. `/pos/returns`, `/pos/refund_requests`, `/pos/exchanges/:id` cần RETURN/RESOLVE/APPROVE, không chỉ là thành viên.
3. Nhận hàng kiểm lại: chi nhánh đã tắt trả hàng → từ chối; quá hạn mà chưa cần duyệt → chuyển `pending_approval`, `revision + 1`, kết quả lệnh là phiếu đang chờ duyệt.
4. Hủy hoàn tiền: chỉ người yêu cầu hoặc người duyệt, bắt buộc lý do (ghi audit); từ chối khi đã có Approval cho khoản đó (`approval_issued`) — phải đi `unknown` rồi `failed_no_effect` có chứng từ.
5. Phiếu bỏ dở: TTL 24 giờ (`ReturnOperation::TTL`), job hủy qua `Returns::Cancel.expire!` (cùng thân xử lý với hủy thường, audit `return.expire`). Attention một lần cho `awaiting_predecessor` và phiếu chưa nhận quá 15 phút.
6. Đảo phân bổ thu nợ bị từ chối khi quyền hoàn đã ghi của đơn vượt (đã thu − khoản này) (`return_entitlement_depends_on_collection`); cùng khóa tài khoản công nợ với việc ghi phiếu trả.
7. Job phục hồi xử lý từng mục riêng: lỗi được log + attention `recovery.failed`, rồi chạy tiếp.
8. Danh sách đơn/phiếu trả/hoàn tiền: tải trước quan hệ, hàng gọn (`ReturnOperation#to_row`, tra cứu theo lô trong `OrderHistory#rows`); request spec kiểm số truy vấn không tăng theo số dòng.
9. Nhỏ: bằng chứng `unknown` hiển thị kind `unknown`; `OutboxEntry.record_once!` khóa advisory theo sự kiện+đối tượng; `Cancel` khóa mọi phiếu bị ảnh hưởng trước SaleLine, đọc lại sau khóa và từ chối (`retry`) nếu có phiếu mới, deadlock → 409 `retry`; một dòng giao qua nhiều fulfillment item được trả thành nhiều phần (migration `20261107135000_allow_split_pos_return_reservations` bỏ unique (phiếu, dòng)), phần của cùng phiếu không chặn nhau; DTO đổi hàng trước khi ghi dùng cùng phép chia giảm nợ/hoàn như lúc ghi.
10. Chênh lệch đổi hàng: `refund_owed` = quyền hoàn − đã chi; `customer_pays`/`store_refunds` tính trên phần còn nợ khách và là `null` khi đơn mới chưa có tổng.

Frontend:

- A. `/returns?returnId=` mở lại phiếu (tải đơn theo `order_id`); sau khi lập phiếu URL chuyển sang `returnId`. Chi tiết đơn liệt kê phiếu trả (trạng thái, đã hoàn/đang chờ, link). Trang Duyệt: mỗi dòng link tới phiếu.
- B. Lập phiếu và đổi hàng đi qua `runFinancialCommand` với intent ổn định (lập phiếu: đơn + dòng đã sắp xếp; đổi hàng: theo phiếu). Nhận hàng gặp `already_received` khi gửi lại → coi là thành công và tải lại.
- C. Hủy hoàn tiền (form lý do, theo đúng quyền server) và "Không thực hiện (có chứng từ)" cho người có RESOLVE, trên trang phiếu và trang Duyệt (component chung `RefundActions`).
- D. Mất phản hồi: thông báo "Chưa nhận được phản hồi — đang kiểm tra kết quả…", khóa thao tác mới với khoản/phiếu đó, nút "Kiểm tra lại" tra receipt theo khóa đã lưu rồi chỉ gửi lại đúng lệnh cũ nếu server chưa ghi; bản ghi còn lại từ trước khi mở màn hình được kiểm một lần tự động; kết quả `recovered` báo "Yêu cầu trước đó đã được ghi nhận". Bản ghi đang gửi dở chỉ tính là chưa rõ sau 3 giây.
- E. Đổi hàng: tóm tắt lấy từ `GET /pos/exchanges/:id` qua `exchange_id` (còn sau khi tải lại); chỉ hiện khách trả thêm/cửa hàng hoàn khi đơn mới có tổng, đã trừ khoản đã hoàn; "Mở màn hình bán" đặt tab đơn đổi là tab đang mở rồi về màn hình bán.
- F. Xem trước hiện "Không hoàn được" từ `unrefundable` của server; bỏ `splitReturnValue`/`exchangeDifference` phía client.
- G. Trang Duyệt: "Từ chối" phiếu trả có form lý do.
- H. Lọc đơn theo thu ngân; đóng chi tiết khi đổi bộ lọc/trang; kiểm "Từ ngày" ≤ "Đến ngày"; dòng cân hiện theo đơn vị bán (kèm đơn vị gốc), số lượng trả gửi theo đơn vị gốc; cột "Đã trả (ghi / giữ)"; tag nợ so theo dấu; form hủy phiếu chỉ cho người lập/người duyệt; số tiền hoàn điền sẵn dạng "200.000", để trống thì báo lỗi, xóa sau khi gửi thành công; ô số ngày trả hàng là ô chữ có kiểm tra (không còn biến chữ sai thành "tắt").
- I. E2e: mở lại sau tải lại, mất phản hồi lập phiếu/yêu cầu hoàn (mất 3 lần liên tiếp vì SDK tự thử lại 2 lần với cùng khóa), hủy và không thực hiện.

Kiểm tra sau sửa:

- Backend toàn bộ POS (`spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`, gồm cả spec ca/báo cáo đang làm song song): 321 examples, 0 failures. Sau rubocop `-a` chạy lại 64 examples của phần trả hàng/hoàn tiền/race: 0 failures.
- Spec mới/mở rộng: `return_recovery_spec` (TTL, attention một lần, lỗi từng mục, `record_once!`), `fulfillment_returns_spec` (giao thiếu: `handover_short`, đối soát bởi người không giữ ca sau khi đóng ca, job tự giao khi đủ kệ, `not_covered`; kiểm lại hạn/chính sách khi nhận; dòng giao qua 2 fulfillment item; chênh lệch đổi hàng trừ khoản đã hoàn), `refunds_spec` (quyền hủy, lý do, `approval_issued`, evidence `unknown`), `credit_returns_spec` (từ chối đảo thu nợ 700k khi trả cả đơn 1tr; đổi hàng ghi nợ trước khi nhận), `returns_refunds_spec` (che tham chiếu, chặn thành viên không có quyền, hủy qua HTTP, đối soát qua HTTP, số truy vấn không tăng theo dòng).
- Rubocop trên file vòng này: chỉ còn `approval.rb:74` (dòng cũ).
- `apps/pos`: vitest 103 passed; biome và `tsc` sạch với mọi file của phần này (lỗi còn lại chỉ ở `late-cash-wizard.tsx`, `shifts.tsx` của phần ca đang làm song song). Playwright (`POS_TEST_PORT=5175`): 194 passed, 6 skipped, 4 failed; 3 lỗi (`credit-collections:647`, `keyboard-context:152`, `lease:3`, tablet) qua khi chạy lại; `administration.spec.ts:122` lỗi vì phần ca đã thêm 3 quyền (16 thay vì 13), không thuộc phần này.
