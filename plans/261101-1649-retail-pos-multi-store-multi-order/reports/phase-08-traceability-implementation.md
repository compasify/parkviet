# Phase 8 (phần 2): truy xuất tồn kho — serial/IMEI, lô/hạn dùng FEFO, hàng cân, đồng bộ writer kho, thu hồi

Trạng thái: đã triển khai, chưa commit. Không sửa ô trạng thái của plan/phase. Gói hàng cùng variant (`plans/261103-pos-goi-hang-truy-xuat`) không làm; SaleLine/merge key giữ nguyên nên seam của plan đó không đổi.

## Seam core đã chọn (Spree 6.0.2)

- `Spree::StockMovement` là nơi duy nhất core đổi `count_on_hand`/`allocated_count` (`after_create :apply_to_stock_level`); `StockLocation#restock/unstock/allocate/release/adjust`, `StockLevels::Correct` (dashboard + feed `BulkUpsert`), `Variant#stock_levels=`, stock transfer/receipt, đặt đơn và giao hàng web đều đi qua đó. Ngoại lệ: ghi thẳng cột (`set_count_on_hand`, `update!`) và xóa mềm StockLevel.
- Guard đồng bộ trong transaction (không phải subscriber async): decorator `app/models/spree/stock_movement_decorator.rb` thêm validation `on: :create` từ chối movement của cặp (variant, location) đã mở truy xuất nếu không chạy trong `StockIntegration.writing { }`; `stock_level_decorator.rb` từ chối ghi thẳng `count_on_hand` (trừ khi chính movement đã kiểm đang áp dụng) và xóa level. Không sửa gem.
- Subscriber `Spree::Pos::StockTraceabilitySubscriber` (`stock_movement.created`, sau commit) và job `ReleaseTraceReservationsJob` (mỗi phút) chỉ **phát hiện** lệch (ghi SQL thô/`update_columns` không guard nào thấy): outbox `stock.trace_drift` một lần; cặp lệch tự bị chặn bán (`trace_unreconciled`) cho tới khi kiểm kê.

### Writer kho: được tham gia vs bị từ chối

| Writer | Kết quả |
|---|---|
| POS đặt đơn (`Workspaces::Complete`, allocate) | tham gia: reservation → committed cùng transaction |
| POS giao hàng (`Orders::Handover`, `ReconcileHandover`, job giao lại) | tham gia: committed → consumed, trừ `on_hand` của lô |
| POS nhận trả (`Returns::Receive`) | tham gia: serial/lô về kho nhận; hư hỏng/lô hết hạn → cách ly (đơn vị hư hỏng được restock core để số kệ khớp đơn vị đang giữ) |
| POS nhập (`Inventory::ReceiveTraceability`), chuyển kho (`TransferTraceability`), kiểm kê (`AdjustTraceability`), tồn đầu kỳ (`OpenBalance`) | tham gia: bản ghi typed + movement core cùng transaction |
| Dashboard sửa tồn / `StockLevels::Correct` / feed-import `BulkUpsert` / `Variant#stock_levels(_attributes)=` | **từ chối** (RecordInvalid "…is tracked by serial or lot at this location…") |
| `StockLocation#restock/unstock/adjust` ngoài POS, stock transfer/receipt/purchase order core | **từ chối** |
| Checkout website / đơn core đặt hoặc giao hàng tracked tại location đã mở | **từ chối** (allocated/shipped bị chặn) |
| Return core (dashboard) nhập lại hàng tracked | **từ chối** |
| `released` (hủy đơn core, nhả allocation) | cho qua — không đổi tồn vật lý |
| Ghi SQL thô / `update_columns` | không chặn được ở app; phát hiện sau commit (subscriber + job) → attention + chặn bán |

Cặp chưa mở truy xuất (chưa có opening balance) không bị guard; bán tại đó bị chặn (`trace_not_enrolled`).

## Đã làm

Backend (`server/`):

- Migration `20261107160000_create_spree_pos_stock_traceability` (chỉ test DB): `spree_pos_trace_enrollments` (unique variant+location), `spree_pos_inventory_lots` (on_hand/quarantined/received ≥ 0, unique location+variant+code), `spree_pos_serial_units` (unique store+variant+serial), `spree_pos_trace_allocations` (đúng một trong lot/serial, `returned_quantity ≤ quantity`, serial quantity = 1, **unique partial index serial khi reserved/committed**), `spree_pos_trace_returns`, `spree_pos_inventory_adjustments`; branch `lot_selection` (`fefo`|`cashier_pick`, mặc định fefo) và `adjustment_approval_threshold` (đơn vị gốc; null = mọi điều chỉnh dương cần duyệt). `tracked_mode` chỉ còn `none|serial|lot` (migration đổi `serial_lot` cũ thành `serial`).
- Capability mới `pos.inventory.manage`, `pos.inventory.trace` (ASSIGNABLE 18).
- Thứ tự khóa mọi writer truy xuất: workspace → StockLevel (theo id) → lô (theo id)/serial → sale line. Hai quầy cùng một cặp xếp hàng ở dòng StockLevel.
- `Inventory::AllocateTraceability`: serial giữ ngay khi quét (TTL 15 phút, gắn workspace + lease generation, mỗi lệnh trên nháp gia hạn qua `CommandExecutor`); lô giữ FEFO lúc chuẩn bị thu tiền (`Tenders::Prepare/Confirm`, `Funds::Allocate`, `Complete` qua `tracked_guard!`) hoặc `POST /workspaces/:id/trace_allocations`; lệnh thanh toán giữ không hết hạn; park (khi chưa khóa snapshot) / cancel / xóa dòng / đổi số lượng nhả; job nhả hết hạn. Thiếu serial/lô → từ chối trước khi nhận tiền.
- `FefoAllocator`: hạn sớm nhất, tie-break id lô (thứ tự nhận), lô không hạn xếp cuối; loại hết hạn (theo ngày chi nhánh) và cách ly. Thu ngân chọn lô chỉ khi `cashier_pick` và lô hợp lệ.
- Trả hàng: `Inventory::ReturnTraceability` — dòng serial phải gửi đúng serial đã bán trên dòng đó; dòng lô cần `lot_code` khi lấy từ nhiều lô; giữ ở prepare (chặn trả hai lần), hủy hoàn lại, nhận đúng một lần (đi cùng `Spree::Returns::Receive`). Khác chi nhánh: lô tạo cùng mã/hạn ở kho nhận với `source_lot`; kho nhận phải đã mở truy xuất. Đổi hàng dùng lại luồng này.
- Đơn vị: cấm đổi cấu hình/tracked mode khi còn bản ghi typed hoặc tồn đã quy đổi (`trace_stock_exists`).
- Đọc: `GET /pos/traceability` (thật, bỏ `reservation: 'unavailable_phase_8'`), `/pos/inventory/variants`, `/pos/lots`, `/pos/serial_units`, `/pos/inventory/adjustments`, `/pos/inventory/recall` (chỉ chi nhánh có `pos.inventory.trace`, SĐT khách che như lịch sử đơn). DTO workspace có `trace {ready, issues}`, dòng có `trace` (allocations / preview FEFO); chi tiết đơn có `trace` đã bán; xem trước/phiếu trả có `trace`.
- Lệnh: tồn đầu kỳ, nhập, chuyển kho, kiểm kê (approve/apply/cancel; âm hoặc vượt ngưỡng cần Approval gắn hành động từ người khác có APPROVE), cách ly/bỏ cách ly lô và serial.

Frontend (`apps/pos/`, do subagent làm theo hợp đồng API): trang `/inventory` (mặt hàng theo dõi + tồn đầu kỳ, lô, tra serial, nhập, chuyển, kiểm kê/duyệt, thu hồi), luồng bán (nhập serial, lô dự kiến/đã giữ, chặn thanh toán kèm lý do + nút "Giữ hàng truy xuất"), wizard trả hàng (serial/lô gốc, chọn serial/lô trả), cài đặt chi nhánh, 2 capability mới, `lib/traceability.ts` + test, `e2e/inventory-traceability.spec.ts`.

## Kiểm tra

- Spec mới: `spec/workflows/spree/pos/traceable_inventory_spec.rb` (13 ví dụ: I01, I03, I04, I05, I06, I07, I08, nhập/chuyển/kiểm kê, thu hồi), `spec/integration/spree/pos/trace_race_spec.rb` (3 ví dụ hai kết nối: cùng serial, lô còn đơn vị cuối, chuyển kho đua với bán), `spec/requests/spree/pos/traceability_spec.rb` (4 ví dụ: quyền, phạm vi chi nhánh, che SĐT, khóa cấu hình đơn vị, DTO, duyệt kiểm kê). Cập nhật `sale_guards_spec`, `sale_lines_spec`, `settlement_spec` (hàng tracked giờ cần tồn đầu kỳ).
- Backend gate `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`: 377 examples, 0 failures (gồm cả spec của phiên phase 10 chạy song song). Sau sửa rubocop chạy lại 88 ví dụ bị ảnh hưởng: 0 failures.
- Rubocop: file mới sạch; file sửa chỉ còn vi phạm có sẵn ở dòng cũ (`manage_line_item.rb`, `units_controller.rb`, `change_status.rb`, `tenders/guard.rb`, `workspace.rb`, `command_executor.rb`, `approval.rb:76`, comment `capabilities.rb`).
- Frontend (theo báo cáo subagent): `tsc` sạch, biome sạch trên file của phần này, vitest của phần này qua, Playwright `POS_TEST_PORT=5175`: 228 passed, 6 skipped, 0 failed.

## Quyết định / điểm cần biết

- Định nghĩa đối soát: lô = Σ(on_hand + quarantined); serial = in_stock + reserved + quarantined + sold chưa giao. Hàng cách ly vẫn nằm trong số kệ core (vật lý còn ở đó); xóa sổ bằng kiểm kê.
- Hàng hư hỏng tracked được restock core để khớp đơn vị đang cách ly — khác hàng thường (không restock).
- Cách ly lô chỉ nhả reservation của nháp chưa thu tiền; reservation đang giữ cho thanh toán vẫn được bán.
- Mở truy xuất khi lệch thì từ chối, không ghi gì; sửa số kệ core trước (vẫn được phép trước khi mở).
- Kiểm kê một cặp đã lệch đưa cả kệ core về số đã đếm (delta core = tổng typed sau đếm − kệ hiện tại).
- Drift: ban đầu dùng `record_once!` (mỗi enrollment chỉ báo một lần); đã thay bằng báo theo từng đợt lệch, xem mục 5 bên dưới.

## Sửa sau review

Backend:

1. Website/dashboard bị chặn trước khi thu tiền: `Spree::Pos::TraceCheckoutGuard` đăng ký hook `carts.add_item|upsert_items|merge|complete.validate` và `orders.add_item|upsert_items.validate` (initializer). Từ chối khi variant đã mở truy xuất tại một location mà channel của giỏ có thể giao (`served_stock_locations`; không có channel → mọi location). Guard movement vẫn là chốt chặn cuối khi đặt đơn.
2. Kiểm kê: khi apply, chạy lại kiểm tra counted ≥ reserved + committed dưới khóa lô. `consume!` trả 409 `trace_lot_short` (kèm details), không còn lỗi 500 do CHECK.
3. Hủy đơn core: chọn **từ chối** movement `released` ngoài `writing` khi fulfillment còn allocation committed. Hủy đơn POS từ dashboard bị chặn; serial vẫn `sold`, allocation vẫn committed. Không chọn nhả qua subscriber vì subscriber chạy sau commit, có thể để lộ lô/serial đang bán.
4. Migration `20261107160100_tighten_pos_tracked_modes`: chuyển dòng bán `serial_lot` cũ sang `serial`; CHECK của `sale_lines` và `variant_units` chỉ còn `none|serial|lot`; thêm `drift_signature`, `drift_checked_at` vào enrollment. `commit!` có chốt: dòng của variant đã mở truy xuất mà không có allocation → `trace_allocation_missing`.
5. Phát hiện lệch: đọc số kệ core và số typed dưới `FOR SHARE` trên StockLevel, khóa enrollment. Mỗi đợt lệch báo một lần (chữ ký `typed:core`; reconcile thì xóa chữ ký, lệch lại thì báo lần mới). Job bỏ qua cặp đã báo khi kệ không đổi.
6. Kiểm kê lô nhận thêm `counted_quarantined`: ghi giảm hàng cách ly, luôn cần duyệt. Dòng lô có thêm `quarantined_before/after/delta`, `on_hand_delta`.
7. `OpenBalance` khóa variant `FOR SHARE` như cấu hình đơn vị, và từ chối khi kệ còn `allocated_count > 0` (`enrollment_allocated`).
8. Job hết hạn khóa theo thứ tự StockLevel → serial → allocation, bắt lỗi từng dòng.
9. `commit!` đòi đúng một FulfillmentItem phủ đủ `base_quantity` của dòng (`trace_fulfillment_mismatch`).
10. Nhỏ:
    - Serial chỉ bán theo đơn vị 1:1 (`trace_serial_unit_mismatch`).
    - Cập nhật cùng số lượng giữ nguyên reservation.
    - Recall: phân trang, cờ `truncated`, lọc `variant_id`, kèm `variant_id`.
    - Nhập/chuyển vào lô đang cách ly bị từ chối (`lot_quarantined`).
    - Guard xóa StockLevel dùng `throw :abort` kèm lỗi.
    - Cache cặp enrollment theo request (`TraceCurrent`, CurrentAttributes, xóa khi enrollment đổi).
    - `Workspace#to_pos` dùng memo theo variant.
11. Kết quả lệnh tồn kho có `branch_id` ở cấp cao nhất (TraceStatus, transfer, adjustment, lot, serial), khôi phục được qua `command_receipts` (request spec kiểm từng lệnh).
12. Mọi conflict của lệnh tồn kho đều có reason (`count_no_change`, `duplicate_lot`, `duplicate_serial`, `nothing_to_receive`, `nothing_to_transfer`, `same_location`, `quantity_invalid`, `expiry_invalid`, `lot_code_invalid`, `reason_required`, `too_many_rows`). `Conflict` có `details`, gộp vào `error.details`; lệch tồn đầu kỳ trả `typed_on_hand`/`core_on_hand`.
13. Theo quyết định: dòng trả hàng có truy xuất phải chọn tình trạng (`trace_condition_required`; preview vẫn chạy). Preview đánh dấu `forced_quarantine` cho lô đã hết hạn theo ngày chi nhánh.

Ghi chú theo từng hunk cho file dùng chung:

- `workspaces/complete.rb`: chỉ bọc `order_complete_workflow` trong `StockIntegration.writing` và gọi `AllocateTraceability.commit!`. Không đụng `ReceiptBuilder.issue!` của phiên receipts.
- `models/spree/pos/branch.rb`: `to_pos` thêm `lot_selection`, `adjustment_approval_threshold`.
- `branches_controller.rb`: thêm hai khối tham số sau `display_attributes` của phiên khác.
- `config/routes.rb`: thêm namespace `inventory`, `lots`, `serial_units`, `workspaces/:id/trace_allocations`.
- `config/initializers/spree.rb`: đăng ký subscriber + hook trong `after_initialize`.
- `base_controller.rb`: một dòng gộp `error.details`.
- `models/spree/pos/conflict.rb`: thêm `details`, sửa thụt lề.
- `db/schema.rb`: chỉ thêm, sinh từ hai migration của phần này.
- `TraceAllocation`: scope `sold` (committed|consumed) và các trường `serial_unit`, `inventory_lot`, `quantity`, `returned_quantity`, `status` giữ nguyên cho `ReceiptBuilder#trace`.

Frontend (subagent, `apps/pos`, mục A–H):

- **A.** Lệnh tồn kho đi qua `runFinancialCommand`: intent bền, tra receipt trước khi gửi lại, khóa "Đang kiểm tra kết quả…". Có e2e mất phản hồi cho nhập lô và chuyển kho.
- **B.** Người chỉ có quyền duyệt chỉ thấy tab kiểm kê.
- **C.** Danh sách chờ duyệt tự tải lại 12 giây/lần và có nút tải lại.
- **D.** Wizard trả hàng: không có tình trạng mặc định; nhãn hết hạn/sắp hết hạn theo ngày chi nhánh; lô hết hạn bị cách ly kèm thông báo.
- **E.** Phân trang.
- **F.** Hai quyền mới là quyền nhạy cảm.
- **G.** Câu tiếng Việt cho mọi reason.
- **H.** Các mục nhỏ.

Kiểm tra sau sửa:

- Spec mới `spec/workflows/spree/pos/traceable_inventory_guards_spec.rb`: 11 ví dụ (giỏ web, mở truy xuất khi còn allocation, hủy core, kiểm kê sau khi bán, giao thiếu lô, xóa sổ hàng cách ly, chốt commit, mode cũ, đợt lệch, serial pack/lô cách ly/xóa level, thứ tự khóa job hết hạn).
- Request spec thêm ví dụ khôi phục qua `command_receipts` và recall phân trang.
- Gate backend toàn bộ POS: 396 examples, 0 failures. Sau các sửa cuối, chạy lại 46 ví dụ truy xuất: 0 failures.
- Spec race từng lỗi chập chờn: DELETE khi dọn dữ liệu và trùng SKU factory. Nguyên nhân là dòng committed còn sót khi một bộ test khác chạy cùng lúc trên test DB. Nay spec dùng SKU riêng; chạy 3 lần liên tiếp đều qua.
- Rubocop: còn lại chỉ `Metrics/ParameterLists` ở điểm vào workflow dùng keyword, như các workflow returns/refunds hiện có.
- Frontend (theo subagent): tsc sạch, biome sạch trên 26 file, vitest 154/154. Playwright 5175: 256 passed, 6 skipped, 2 failed; cả 2 lỗi thuộc `e2e/receipts-display.spec.ts` của phiên receipts (định dạng HSD).
