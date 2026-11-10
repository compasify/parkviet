---
phase: 10
title: "Số gọi, tem ly, màn khách gọi số"
status: pending
effort: "4 ngày"
dependsOn: [1, 4, 8, 9]
---

# Phase 10: Số gọi, tem ly, màn khách gọi số

## Overview

Ba thứ của quán trả trước tại quầy:
1. **Số gọi** theo chi nhánh × ngày kinh doanh (`fnb.order_number`).
2. **Tem ly**: mỗi ly một tem (`fnb.cup_label`).
3. **Màn khách chế độ gọi số** (S5): hai cột "Đang làm" và "Mời nhận", lấy theo trạng thái ticket bếp của phase 9.

## Quyết định của phase

1. **Số gọi gắn với `business_date`**, không gắn với ngày lịch. Quán mở qua 0h vẫn đếm tiếp tới giờ cắt ngày kinh doanh của phase 1. Số bắt đầu lại từ 1 mỗi ngày kinh doanh.
2. **Cấp số ở lần đầu tiên** đơn được gửi bếp hoặc được complete, tùy việc nào đến trước. Việc cấp số idempotent: đơn đã có số thì giữ nguyên. Đơn bị hủy giữ số đã cấp và không cấp lại cho đơn khác, để không gọi nhầm khách.
3. **Bộ đếm atomic:** một câu `INSERT … ON CONFLICT (branch_id, business_date) DO UPDATE SET last_value = last_value + 1 RETURNING last_value`. Không có khóa ứng dụng.
4. **`fnb.cup_label` là module mới** (depends_on: `fnb.menu`), vì plan.md chưa đăng ký nó. Phase này thêm vào registry. Tem chỉ in cho món bật `menu_items.cup_label` (phase 8). Dòng có số lượng 3 in 3 tem, đánh "1/3", "2/3", "3/3".
5. **Bố cục tem v1 cố định**, chỉ có công tắc bật/tắt từng trường và chọn khổ (40×30, 50×30, 58×40 mm). Không làm trình sửa mẫu tem riêng. Trình sửa mẫu hóa đơn hiện có không dùng cho tem.
6. **Màn gọi số là một mode của `DisplaySession`**, gắn với chi nhánh, không theo workspace của một thu ngân. Màn vẫn dùng token `Display` hiện có và poll `api/v3/pos_display/state`, nên không cần kênh realtime cho màn khách.

## Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_order_number_counters` | `branch_id`, `business_date`, `last_value` | unique `(branch_id, business_date)` |
| `spree_pos_workspaces` (sửa) | thêm `order_number` int, `guest_name` varchar(60) | unique `(branch_id, business_date, order_number)` khi `order_number` not null |
| `spree_pos_branches` (sửa) | thêm `cup_label_printer_id` (nullable, Printer của phase 4), `cup_label_settings` jsonb (khổ, trường hiện) | |
| `spree_pos_display_sessions` (sửa) | thêm `mode` (`order` / `call_board`), mặc định `order` | check giá trị |

Migration: `create_spree_pos_order_number_counters`, `add_call_number_and_guest_name_to_spree_pos_workspaces`, `add_cup_label_settings_to_spree_pos_branches`, `add_mode_to_spree_pos_display_sessions`.

## Server

- **`Spree::Pos::OrderNumbers.assign!(workspace)`:** cấp số khi chi nhánh bật `fnb.order_number`, đọc `workspace.business_date`. Nơi gọi:
  - `Kitchen::Send` trước khi dựng ticket, để header ticket có số;
  - `Workspaces::Complete` trước `ReceiptBuilder.issue_safely!`.
- **`Workspaces::SetGuestName`:** lệnh ghi tên khách lên đơn. Lệnh kiểm revision và lease như `set_order_source.rb`; tên vẫn sửa được sau khi khóa snapshot vì không đụng đến tiền.
- **Hóa đơn:** thêm biến `order.call_number` và `order.guest_name` vào `config/pos/receipt_template_variables.json` và `ReceiptTemplateSchema`. Mẫu hóa đơn mặc định của F&B in số gọi cỡ lớn ở đầu phiếu. `ReceiptBuilder#sale` đưa hai giá trị này vào snapshot.
- **Tem ly:**
  - `CupLabels::Document.build(workspace, sale_line, index, total)` dựng `PrintDocument` v1 kind `cup_label` gồm: số gọi, `index/total`, tên món, tùy chọn, ghi chú, tên khách, giờ, tên quán.
  - `CupLabels::Issue.call(workspace, trigger:)` sinh một `PrintJob` cho mỗi ly, idempotent theo `(sale_line_id, index, trigger_key)`. Hàm chạy sau commit của `Kitchen::Send`, hoặc của `Complete` nếu chi nhánh không bật bếp.
  - Endpoint `POST workspaces/:id/cup_labels` (in lại một dòng hoặc cả đơn) cần quyền thu ngân hiện có `Capabilities::PAYMENT` (`pos.payment.collect`). Hiện chưa có quyền in lại riêng, và phase này không thêm. Mỗi lần in lại ghi `AuditEntry` `cup_label.reprint`.
- **Màn gọi số:**
  - `DisplayState#content` khi `session.mode == 'call_board'` trả về `{ state: 'call_board', preparing: [số], ready: [{số, tên khách, ready_at}] }`.
  - Một số ở cột "Mời nhận" khi mọi item của đơn đã `ready` và chưa `served`.
  - Số tự rời cột "Mời nhận" khi item được `served`, hoặc sau 15 phút (cấu hình được trong `cup_label_settings`; đây không phải tiền nên để chung một jsonb với thiết lập hiển thị là đủ).
  - `display_sessions_controller` có lệnh đổi `mode`.
- **Đánh dấu đã giao:** `POST kitchen/orders/:workspace_id/serve` chuyển mọi item `ready` của đơn sang `served`. Thu ngân dùng nút "Đã giao" trên danh sách đơn chờ nhận; KDS dùng nút ở khu Đã xong.
- **Module:** đăng ký `fnb.order_number` (depends_on: []) và `fnb.cup_label` (depends_on: `fnb.menu`).
- **OpenAPI:** thêm `order_number` và `guest_name` vào `Workspace`, thêm các endpoint mới.

## Client web (`apps/pos`)

- Ô **Tên khách** (không bắt buộc) ở đầu giỏ khi chi nhánh bật `fnb.order_number` hoặc `fnb.cup_label`.
- Số gọi hiện ở tab workspace và trên màn thanh toán sau khi complete, cỡ lớn để đọc cho khách.
- Danh sách **Chờ nhận** (`components/pickup-queue.tsx`): các đơn `ready` trong ngày kinh doanh, nút **Đã giao**.
- **`pages/customer-display.tsx`** có chế độ `call_board`: hai cột chữ rất lớn, số mới vào cột "Mời nhận" thì nhấp nháy và phát âm báo. `display-pin-control.tsx` thêm lựa chọn chế độ khi ghép màn.
- Mục **Tem ly** trong `pages/settings/kitchen.tsx` (phase 9): chọn máy in tem, khổ, các trường, nút in thử.
- Nút **In lại tem** trên từng dòng trong `order-lines.tsx` (sau khi gửi bếp / complete).

## Flutter

- KDS (phase 9) hiện số gọi và tên khách ở header ticket. Khu Đã xong có nút **Đã giao**.
- Trạm in (phase 5) nhận job `cup_label`. Máy in tem trong `Printer` của phase 4 cần thuộc tính ngôn ngữ lệnh (ESC/POS hay TSPL); xem mục Rủi ro.

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/db/migrate/*` (4 migration ở trên) | tạo | dữ liệu |
| `server/app/models/spree/pos/order_number_counter.rb` | tạo | model |
| `server/app/services/spree/pos/order_numbers.rb` | tạo | cấp số |
| `server/app/services/spree/pos/cup_labels/document.rb`, `server/app/workflows/spree/pos/cup_labels/issue.rb` | tạo | tem ly |
| `server/app/workflows/spree/pos/workspaces/set_guest_name.rb` | tạo | tên khách |
| `server/app/workflows/spree/pos/kitchen/send.rb`, `workspaces/complete.rb` | sửa | gọi cấp số, in tem |
| `server/app/services/spree/pos/display_state.rb`, `models/spree/pos/display_session.rb`, `controllers/.../display_sessions_controller.rb` | sửa | chế độ gọi số |
| `server/app/services/spree/pos/receipt_builder.rb`, `receipt_template_schema.rb`, `server/config/pos/receipt_template_variables.json`, `server/config/pos/receipt_templates/*` | sửa | biến số gọi |
| `server/app/controllers/spree/api/v3/admin/pos/workspaces/cup_labels_controller.rb`, `workspaces/guest_names_controller.rb`, `kitchen/orders_controller.rb` | tạo | API |
| `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | sửa | module, route, hợp đồng |
| `apps/pos/src/pages/customer-display.tsx`, `components/display-pin-control.tsx`, `components/order-lines.tsx`, `components/workspace-tabs.tsx`, `pages/settings/kitchen.tsx` | sửa | web |
| `apps/pos/src/components/pickup-queue.tsx` | tạo | chờ nhận |
| `apps/pos-staff/lib/modes/kds/ticket_card.dart` | sửa | số gọi, Đã giao |

## Các bước

1. Viết bộ đếm và `OrderNumbers.assign!`. Spec:
   - 50 luồng song song ra 50 số liên tiếp, không trùng;
   - qua giờ cắt ngày kinh doanh thì đếm lại từ 1;
   - đơn hủy giữ số của nó.
2. Nối việc cấp số vào `Kitchen::Send` và `Complete`. Thêm biến hóa đơn và cập nhật mẫu F&B mặc định.
3. Viết lệnh tên khách và cột `guest_name`.
4. Viết tem ly: document, issue, in lại, audit. Spec: số tem bằng tổng số lượng các dòng có cờ `cup_label`; gửi lại không in trùng.
5. Viết mode `call_board` cho DisplaySession và DisplayState, cộng endpoint "Đã giao".
6. Viết web: tên khách, số gọi, danh sách chờ nhận, màn gọi số, cài đặt tem.
7. Cập nhật KDS Flutter. Kiểm in tem trên máy in thật: một máy TSPL và một máy ESC/POS.

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/order_numbers_spec.rb spec/integration/spree/pos/order_number_race_spec.rb`
- `pnpm spree rspec spec/workflows/spree/pos/cup_labels/issue_spec.rb spec/services/spree/pos/display_state_spec.rb spec/requests/spree/pos/display_sessions_spec.rb`
- Hồi quy hóa đơn: `pnpm spree rspec spec/services/spree/pos/receipt_builder_spec.rb spec/services/spree/pos/receipt_template_schema_spec.rb`
- Web: `pnpm --dir apps/pos test test:e2e`. File `e2e/fnb-call-number.spec.ts` chạy luồng: bán 2 đơn → màn gọi số hiện "Đang làm" → bump ở API → "Mời nhận" → Đã giao.
- Flutter: `flutter test test/modes/kds/`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Máy in tem phổ biến (Xprinter XP-365B…) dùng TSPL, không dùng ESC/POS | Phase 4 / 5 phải có `command_language` (`escpos` / `tspl`) trên `Printer` và có renderer TSPL ở trạm in. Nếu chưa có thì phase này thêm renderer TSPL vào trạm in |
| Số gọi trùng khi hai máy cùng complete | Upsert atomic và unique index trên workspace |
| Màn gọi số chậm vì poll | Poll 2 giây như `use-display.ts`; dữ liệu nhỏ |

## Tiêu chí xong

- [ ] Số gọi tăng đúng theo chi nhánh × ngày kinh doanh, không trùng khi chạy song song, và in trên hóa đơn, ticket bếp, tem ly.
- [ ] Mỗi ly in đúng một tem, có "n/N"; in lại có audit.
- [ ] Màn khách chế độ gọi số chuyển số từ "Đang làm" sang "Mời nhận" theo trạng thái bếp, và số rời màn khi Đã giao.
- [ ] Chi nhánh tắt các module này thì không thấy thay đổi nào.
