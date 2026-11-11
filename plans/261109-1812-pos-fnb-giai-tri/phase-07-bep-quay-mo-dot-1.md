---
phase: 7
title: "Bếp, quầy trả trước, mở đợt 1"
status: pending
effort: "19 ngày"
dependsOn: [1, 3, 4, 5, 6]
---

# Phase 7: Bếp, quầy trả trước, mở đợt 1

## Overview

Mọi phần xoay quanh ticket bếp của đơn trả trước: trạm và KDS, số gọi và tem ly, đơn nền tảng nhập tay đi thẳng xuống bếp, rồi mở ba hồ sơ đợt 1.

| Phần | Nội dung | Effort |
|---|---|---|
| 7A | Bếp: trạm, ticket, KDS | 9 ngày |
| 7B | Số gọi, tem ly, màn khách gọi số | 4 ngày |
| 7C | Đơn từ nền tảng giao hàng (nhập tay) | 3 ngày |
| 7D | Mở ngành đợt 1 | 3 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 7A: Bếp: trạm, ticket, KDS

### Overview

Món đã bán phải tới đúng bếp hoặc bar. Phần này làm:
- trạm bếp (`KitchenStation`);
- bảng định tuyến (`StationRoute`);
- ticket bếp bất biến (`KitchenTicket` / `KitchenTicketItem`);
- đường in phiếu bếp dự phòng qua `PrintJob`;
- **KDS bản đầu (S3) trong app Flutter**, ở mode `kds`.

Phần 7A phục vụ quán trả trước (F1). Báo bếp theo phần chênh lệch, hủy món đã báo kèm `Approval`, All-day đầy đủ và recall sau khi phục vụ đều thuộc phần 8B và 8C.

### Quyết định

1. **Thời điểm báo bếp là cấu hình của chi nhánh** (`branches.kitchen_send_trigger`):
   - `on_complete` (mặc định cho quán trả trước): ticket được tạo ngay trong transaction của `Workspaces::Complete`, sau khi đơn đã placed;
   - `manual`: thu ngân bấm **Báo bếp** trước khi thu tiền.

   Với cả hai trigger, mỗi lần gửi tạo ticket cho phần chưa gửi (`quantity − kitchen_sent_quantity`).
2. **Ticket bất biến.** Mỗi lần gửi là một ticket theo từng trạm, idempotent theo `(workspace_id, send_key)`. `send_key` là idempotency key của lệnh, hoặc `complete:<workspace_id>` khi trigger là `on_complete`. Sửa đơn sau khi gửi không sửa ticket cũ. Ở phần này, giảm số lượng xuống dưới `kitchen_sent_quantity` bị từ chối (`Conflict reason: 'kitchen_sent'`); việc hủy món đã báo bếp làm ở phần 8B.
3. **Định tuyến** theo thứ tự ưu tiên: route theo product + `service_mode` → route theo product → route theo `kitchen_category` + `service_mode` → route theo `kitchen_category` → trạm mặc định của chi nhánh. Việc báo bếp **không bao giờ lỗi vì thiếu route**, và không bao giờ chặn việc bán.
4. **Trạng thái món:** `new → preparing → ready → served`, cộng `voided` (dùng từ phần 8B). Ở quầy trả trước, trạng thái `ready` là xong, còn `served` được đặt khi bấm "Đã giao" ở S5 / KDS (phần 7B).
5. **Trạm có KDS, có máy in, hoặc cả hai.** Trạm gắn `printer_id` thì mỗi ticket sinh một `PrintJob` kind `kitchen_ticket` (phase 4). Trạm không có KDS chỉ dùng máy in, giống POS365.
6. **Combo** in món con khi món bật `show_components_on_kds`, nếu không thì chỉ in tên combo. Tùy chọn và ghi chú luôn in.

### Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_kitchen_stations` | `branch_id`, `name`, `kind` (`prep`/`bar`/`expo`), `printer_id` (nullable), `kds_enabled`, `is_default`, `warn_after_minutes` (8), `late_after_minutes` (15), `position`, `active` | mỗi chi nhánh có tối đa một `is_default` (partial unique) |
| `spree_pos_station_routes` | `branch_id`, `kitchen_station_id`, `product_id` (nullable), `kitchen_category` (nullable), `service_mode` (nullable = mọi hình thức) | check: đúng một trong `product_id` / `kitchen_category`; unique `(branch_id, product_id, kitchen_category, service_mode)` |
| `spree_pos_kitchen_tickets` | `store_id`, `branch_id`, `workspace_id`, `kitchen_station_id`, `sequence` (theo workspace), `kind` (`fire`/`void`), `send_key`, `service_mode`, `business_date`, `header` jsonb (số gọi, bàn, khách, nguồn đơn), `sent_by_type/id`, `sent_at` | unique `(workspace_id, send_key, kitchen_station_id)` |
| `spree_pos_kitchen_ticket_items` | `kitchen_ticket_id`, `sale_line_id`, `name`, `modifiers` jsonb, `components` jsonb, `note`, `quantity`, `status`, `started_at`, `ready_at`, `served_at`, `voided_at`, `changed_by_type/id` | check `status` |
| `spree_pos_sale_lines` (sửa) | thêm `kitchen_sent_quantity` decimal, mặc định 0 | check `0 ≤ kitchen_sent_quantity` |
| `spree_pos_branches` (sửa) | thêm `kitchen_send_trigger`, mặc định `on_complete` | check giá trị |

Migration: `create_spree_pos_kitchen_tables`, `add_kitchen_columns_to_spree_pos_sale_lines_and_branches`.

### Server

- **Model:** `KitchenStation`, `StationRoute`, `KitchenTicket` (`readonly?` sau khi tạo, trừ quan hệ), `KitchenTicketItem`.
- **`Spree::Pos::Kitchen::Router.station_for(branch, sale_line, service_mode)`** theo thứ tự ở quyết định 3. Có memo theo lệnh gửi.
- **Workflow:**
  - `Kitchen::Send.call(workspace:, actor:, send_key:)` gom phần chưa gửi theo trạm, tạo ticket và item, tăng `kitchen_sent_quantity`, ghi `AuditEntry` `kitchen.send`. Sau commit, workflow sinh `PrintJob` cho trạm có máy in và phát `kitchen_ticket.updated`.
  - `Workspaces::Complete` gọi `Kitchen::Send` khi chi nhánh bật `fnb.kitchen` và trigger là `on_complete`. Lời gọi đặt sau `AllocateTraceability.commit!` và trước `ReceiptBuilder.issue_safely!`, cùng transaction. Nhờ đó không có đơn nào đã thu tiền mà không có phiếu bếp.
  - `Kitchen::ChangeItemStatus` chuyển trạng thái `start` / `ready` / `bump_ticket` (mọi item sang `ready`) / `recall` (`ready → preparing` trong 30 phút) / `serve`. Mỗi lần chuyển kiểm lượt chuyển hợp lệ, lấy giờ từ `database_now` và phát `kitchen_ticket.updated`.
- **Controller:**
  - `workspaces/kitchen_sends_controller#create`: thu ngân bấm Báo bếp, có `Idempotency-Key`, đi qua `CommandExecutor`.
  - `workspaces/kitchen_tickets_controller#index`: lịch sử báo bếp của đơn.
  - `kitchen/board_controller#show?station_id=`: ticket còn mở cộng ticket xong trong 30 phút gần nhất, kèm `server_now` để client tính timer.
  - `kitchen/items_controller` (`start`, `ready`, `serve`, `recall`) và `kitchen/tickets_controller#bump`.
  - CRUD `kitchen_stations` và `station_routes`.
- **Xác thực:** endpoint `kitchen/*` nhận cả **thiết bị** mode `kds` / `expo` (danh tính máy của phase 2, không cần PIN) lẫn nhân viên có quyền `Capabilities::OPERATE_KITCHEN = 'pos.kitchen.operate'`. Cấu hình trạm và route cần quyền `Capabilities::MANAGE_KITCHEN = 'pos.kitchen.manage'`.
- **In:** `Kitchen::TicketDocument.build(ticket)` dựng `PrintDocument` v1 gồm:
  - tên trạm, số ticket, giờ;
  - số gọi (phần 7B) hoặc bàn;
  - hình thức phục vụ;
  - món in cỡ lớn, tùy chọn thụt dòng, ghi chú in đảo màu.
- **Module:** đăng ký `fnb.kitchen` (depends_on: `fnb.menu`). Chi nhánh tắt module thì không gửi bếp; đơn vẫn bán và complete như cũ.
- **OpenAPI:** thêm `KitchenTicket`, `KitchenBoard`, `KitchenStation` và các endpoint ở trên.

### Flutter: KDS mode (`apps/pos-staff`)

- **Mã nguồn:** `lib/modes/kds/`, gồm:
  - `kds_shell.dart`: chọn trạm khi ghép thiết bị, giữ màn sáng (wakelock của phần 5A);
  - `board_screen.dart`, `ticket_card.dart`, `item_view.dart`;
  - `kds_repository.dart`: client sinh từ OpenAPI, cộng sự kiện `kitchen_ticket.updated` từ realtime, poll 5 giây khi websocket rớt.
- **Ba tab:**
  - **Ưu tiên**: ticket xếp theo giờ gửi; quá `warn_after_minutes` thì viền vàng, quá `late_after_minutes` thì viền đỏ.
  - **Theo món**: gộp cùng món + cùng tùy chọn trên mọi ticket, kèm tổng số lượng.
  - **Theo bàn / số gọi**.
- **Thao tác:**
  - chạm một món: `new → preparing → ready`;
  - nút **Xong cả phiếu** (bump);
  - khu **Đã xong** có nút **Gọi lại** (recall);
  - nút **Hết món** mở danh sách món của trạm và gọi `PUT menu_availabilities` (phần 6A).
- **Timer** tính bằng `server_now` cộng độ lệch đo khi tải, không dùng giờ của máy.
- **Âm thanh** khi có ticket mới. Giao diện chữ lớn, chạm được bằng tay ướt: nút tối thiểu 56dp.
- **i18n:** ARB `vi` / `en`, khóa `kds*`.

### Client web (`apps/pos`)

- Ở chế độ `manual`, đơn có nút **Báo bếp** cạnh nút thanh toán. Badge cho biết số món chưa gửi.
- Dòng đã gửi hiện biểu tượng "đã báo bếp". Nút giảm số lượng bị khóa xuống tới `kitchen_sent_quantity`, kèm gợi ý "Hủy món đã báo bếp có ở bản sau".
- Panel **Lịch sử báo bếp** (`components/kitchen-history.tsx`): giờ, trạm, món, trạng thái từng món.
- Trang **Cài đặt → Bếp & bar** (`pages/settings/kitchen.tsx`): trạm, máy in của trạm (chọn từ Printer của phase 4), ngưỡng vàng/đỏ, bảng route theo danh mục bếp / món / hình thức phục vụ, trigger báo bếp.

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/db/migrate/*_create_spree_pos_kitchen_tables.rb`, `*_add_kitchen_columns_to_spree_pos_sale_lines_and_branches.rb` | tạo | dữ liệu |
| `server/app/models/spree/pos/kitchen_station.rb`, `station_route.rb`, `kitchen_ticket.rb`, `kitchen_ticket_item.rb` | tạo | model |
| `server/app/services/spree/pos/kitchen/router.rb`, `ticket_document.rb` | tạo | định tuyến, phiếu in |
| `server/app/workflows/spree/pos/kitchen/send.rb`, `change_item_status.rb` | tạo | gửi bếp, trạng thái |
| `server/app/workflows/spree/pos/workspaces/complete.rb` | sửa | gọi `Kitchen::Send` khi `on_complete` |
| `server/app/workflows/spree/pos/workspaces/manage_line_item.rb` | sửa | chặn giảm dưới `kitchen_sent_quantity` |
| `server/app/controllers/spree/api/v3/admin/pos/kitchen/*`, `workspaces/kitchen_sends_controller.rb`, `workspaces/kitchen_tickets_controller.rb`, `kitchen_stations_controller.rb`, `station_routes_controller.rb` | tạo | API |
| `server/app/models/spree/pos/capabilities.rb`, `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | sửa | quyền, module, route, hợp đồng |
| `apps/pos-staff/lib/modes/kds/**` | tạo | KDS |
| `apps/pos/src/components/kitchen-history.tsx`, `pages/settings/kitchen.tsx`, `hooks/use-kitchen.ts` | tạo | web |
| `apps/pos/src/components/payment-panel.tsx`, `order-lines.tsx` | sửa | nút Báo bếp, khóa giảm |

### Các bước

1. Viết migration và model, kèm spec về tính bất biến của ticket.
2. Viết `Kitchen::Router`, kèm spec cho đủ 5 mức ưu tiên và trạm mặc định.
3. Viết `Kitchen::Send`, kèm spec:
   - idempotent khi gửi lại cùng key;
   - chỉ gửi phần chưa gửi;
   - một đơn có hai trạm sinh hai ticket;
   - combo theo cờ.
4. Nối `Kitchen::Send` vào `Complete`. Spec: đơn complete thì có ticket; module tắt thì không có ticket; lỗi in không làm rollback (việc in chạy sau commit).
5. Viết `ChangeItemStatus` và thao tác bump / recall, kèm spec lượt chuyển hợp lệ và chặn chuyển sai.
6. Viết controller (xác thực thiết bị + nhân viên), cập nhật OpenAPI, viết `TicketDocument` và `PrintJob`.
7. Viết KDS Flutter: board, ba tab, timer, âm báo, hết món. Viết widget test và integration test chạy với server seed.
8. Viết web: nút Báo bếp, lịch sử, trang cài đặt.
9. Đo độ trễ từ lúc bấm Báo bếp tới lúc KDS hiện ticket qua `BranchChannel` (mục tiêu ≤ 2 giây trong LAN), và ghi kết quả vào phase.

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/kitchen/router_spec.rb spec/workflows/spree/pos/kitchen/`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/complete_spec.rb spec/requests/spree/pos/kitchen_spec.rb spec/requests/spree/pos/kitchen_stations_spec.rb`
- Race: `spec/integration/spree/pos/kitchen_send_race_spec.rb`: hai lệnh Báo bếp cùng lúc chỉ ra một ticket cho mỗi phần chưa gửi.
- Flutter: `flutter test test/modes/kds/`, `flutter test integration_test/kds_flow_test.dart`.
- Web: `pnpm --dir apps/pos test test:e2e` (`e2e/fnb-kitchen.spec.ts`).

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Gửi bếp trong transaction của `Complete` làm chậm hoặc làm vỡ việc thu tiền | Chỉ ghi DB; định tuyến không bao giờ raise; in và realtime chạy sau commit. Spec hồi quy `complete_spec` |
| KDS mất kết nối, bếp không thấy món | Poll dự phòng; trạm có cả máy in; KDS hiện banner "Mất kết nối" kèm giờ đồng bộ cuối |
| Đồng hồ máy KDS lệch | Timer dùng `server_now` |

### Tiêu chí xong

- [ ] Đơn trả trước complete tạo đúng ticket theo trạm, idempotent, và không bao giờ chặn việc thu tiền.
- [ ] Chế độ `manual` gửi đúng phần chưa gửi và khóa giảm số lượng đã gửi.
- [ ] KDS Flutter có 3 tab, bump, recall, timer vàng/đỏ, hết món; hoạt động bằng danh tính thiết bị.
- [ ] Trạm có máy in in được phiếu bếp qua trạm in.
- [ ] Đo độ trễ đạt ≤ 2 giây trong LAN, kết quả được ghi lại.

## Phần 7B: Số gọi, tem ly, màn khách gọi số

### Overview

Ba thứ của quán trả trước tại quầy:
1. **Số gọi** theo chi nhánh × ngày kinh doanh (`fnb.order_number`).
2. **Tem ly**: mỗi ly một tem (`fnb.cup_label`).
3. **Màn khách chế độ gọi số** (S5): hai cột "Đang làm" và "Mời nhận", lấy theo trạng thái ticket bếp của phần 7A.

### Quyết định

1. **Số gọi gắn với `business_date`**, không gắn với ngày lịch. Quán mở qua 0h vẫn đếm tiếp tới giờ cắt ngày kinh doanh của phase 1. Số bắt đầu lại từ 1 mỗi ngày kinh doanh.
2. **Cấp số ở lần đầu tiên** đơn được gửi bếp hoặc được complete, tùy việc nào đến trước. Việc cấp số idempotent: đơn đã có số thì giữ nguyên. Đơn bị hủy giữ số đã cấp và không cấp lại cho đơn khác, để không gọi nhầm khách.
3. **Bộ đếm atomic:** một câu `INSERT … ON CONFLICT (branch_id, business_date) DO UPDATE SET last_value = last_value + 1 RETURNING last_value`. Không có khóa ứng dụng.
4. **`fnb.cup_label` là module mới** (depends_on: `fnb.menu`), vì plan.md chưa đăng ký nó. Phần này thêm vào registry. Tem chỉ in cho món bật `menu_items.cup_label` (phần 6A). Dòng có số lượng 3 in 3 tem, đánh "1/3", "2/3", "3/3".
5. **Bố cục tem v1 cố định**, chỉ có công tắc bật/tắt từng trường và chọn khổ (40×30, 50×30, 58×40 mm). Không làm trình sửa mẫu tem riêng. Trình sửa mẫu hóa đơn hiện có không dùng cho tem.
6. **Màn gọi số là một mode của `DisplaySession`**, gắn với chi nhánh, không theo workspace của một thu ngân. Màn vẫn dùng token `Display` hiện có và poll `api/v3/pos_display/state`, nên không cần kênh realtime cho màn khách.

### Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_order_number_counters` | `branch_id`, `business_date`, `last_value` | unique `(branch_id, business_date)` |
| `spree_pos_workspaces` (sửa) | thêm `order_number` int, `guest_name` varchar(60) | unique `(branch_id, business_date, order_number)` khi `order_number` not null |
| `spree_pos_branches` (sửa) | thêm `cup_label_printer_id` (nullable, Printer của phase 4), `cup_label_settings` jsonb (khổ, trường hiện) | |
| `spree_pos_display_sessions` (sửa) | thêm `mode` (`order` / `call_board`), mặc định `order` | check giá trị |

Migration: `create_spree_pos_order_number_counters`, `add_call_number_and_guest_name_to_spree_pos_workspaces`, `add_cup_label_settings_to_spree_pos_branches`, `add_mode_to_spree_pos_display_sessions`.

### Server

- **`Spree::Pos::OrderNumbers.assign!(workspace)`:** cấp số khi chi nhánh bật `fnb.order_number`, đọc `workspace.business_date`. Nơi gọi:
  - `Kitchen::Send` trước khi dựng ticket, để header ticket có số;
  - `Workspaces::Complete` trước `ReceiptBuilder.issue_safely!`.
- **`Workspaces::SetGuestName`:** lệnh ghi tên khách lên đơn. Lệnh kiểm revision và lease như `set_order_source.rb`; tên vẫn sửa được sau khi khóa snapshot vì không đụng đến tiền.
- **Hóa đơn:** thêm biến `order.call_number` và `order.guest_name` vào `config/pos/receipt_template_variables.json` và `ReceiptTemplateSchema`. Mẫu hóa đơn mặc định của F&B in số gọi cỡ lớn ở đầu phiếu. `ReceiptBuilder#sale` đưa hai giá trị này vào snapshot.
- **Tem ly:**
  - `CupLabels::Document.build(workspace, sale_line, index, total)` dựng `PrintDocument` v1 kind `cup_label` gồm: số gọi, `index/total`, tên món, tùy chọn, ghi chú, tên khách, giờ, tên quán.
  - `CupLabels::Issue.call(workspace, trigger:)` sinh một `PrintJob` cho mỗi ly, idempotent theo `(sale_line_id, index, trigger_key)`. Hàm chạy sau commit của `Kitchen::Send`, hoặc của `Complete` nếu chi nhánh không bật bếp.
  - Endpoint `POST workspaces/:id/cup_labels` (in lại một dòng hoặc cả đơn) cần quyền thu ngân hiện có `Capabilities::PAYMENT` (`pos.payment.collect`). Hiện chưa có quyền in lại riêng, và phần này không thêm. Mỗi lần in lại ghi `AuditEntry` `cup_label.reprint`.
- **Màn gọi số:**
  - `DisplayState#content` khi `session.mode == 'call_board'` trả về `{ state: 'call_board', preparing: [số], ready: [{số, tên khách, ready_at}] }`.
  - Một số ở cột "Mời nhận" khi mọi item của đơn đã `ready` và chưa `served`.
  - Số tự rời cột "Mời nhận" khi item được `served`, hoặc sau 15 phút (cấu hình được trong `cup_label_settings`; đây không phải tiền nên để chung một jsonb với thiết lập hiển thị là đủ).
  - `display_sessions_controller` có lệnh đổi `mode`.
- **Đánh dấu đã giao:** `POST kitchen/orders/:workspace_id/serve` chuyển mọi item `ready` của đơn sang `served`. Thu ngân dùng nút "Đã giao" trên danh sách đơn chờ nhận; KDS dùng nút ở khu Đã xong.
- **Module:** đăng ký `fnb.order_number` (depends_on: []) và `fnb.cup_label` (depends_on: `fnb.menu`).
- **OpenAPI:** thêm `order_number` và `guest_name` vào `Workspace`, thêm các endpoint mới.

### Client web (`apps/pos`)

- Ô **Tên khách** (không bắt buộc) ở đầu giỏ khi chi nhánh bật `fnb.order_number` hoặc `fnb.cup_label`.
- Số gọi hiện ở tab workspace và trên màn thanh toán sau khi complete, cỡ lớn để đọc cho khách.
- Danh sách **Chờ nhận** (`components/pickup-queue.tsx`): các đơn `ready` trong ngày kinh doanh, nút **Đã giao**.
- **`pages/customer-display.tsx`** có chế độ `call_board`: hai cột chữ rất lớn, số mới vào cột "Mời nhận" thì nhấp nháy và phát âm báo. `display-pin-control.tsx` thêm lựa chọn chế độ khi ghép màn.
- Mục **Tem ly** trong `pages/settings/kitchen.tsx` (phần 7A): chọn máy in tem, khổ, các trường, nút in thử.
- Nút **In lại tem** trên từng dòng trong `order-lines.tsx` (sau khi gửi bếp / complete).

### Flutter

- KDS (phần 7A) hiện số gọi và tên khách ở header ticket. Khu Đã xong có nút **Đã giao**.
- Trạm in (phần 5A) nhận job `cup_label`. Máy in tem trong `Printer` của phase 4 cần thuộc tính ngôn ngữ lệnh (ESC/POS hay TSPL); xem mục Rủi ro.

### File

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

### Các bước

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

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/order_numbers_spec.rb spec/integration/spree/pos/order_number_race_spec.rb`
- `pnpm spree rspec spec/workflows/spree/pos/cup_labels/issue_spec.rb spec/services/spree/pos/display_state_spec.rb spec/requests/spree/pos/display_sessions_spec.rb`
- Hồi quy hóa đơn: `pnpm spree rspec spec/services/spree/pos/receipt_builder_spec.rb spec/services/spree/pos/receipt_template_schema_spec.rb`
- Web: `pnpm --dir apps/pos test test:e2e`. File `e2e/fnb-call-number.spec.ts` chạy luồng: bán 2 đơn → màn gọi số hiện "Đang làm" → bump ở API → "Mời nhận" → Đã giao.
- Flutter: `flutter test test/modes/kds/`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Máy in tem phổ biến (Xprinter XP-365B…) dùng TSPL, không dùng ESC/POS | Phase 4 / phần 5A phải có `command_language` (`escpos` / `tspl`) trên `Printer` và có renderer TSPL ở trạm in. Nếu chưa có thì phần này thêm renderer TSPL vào trạm in |
| Số gọi trùng khi hai máy cùng complete | Upsert atomic và unique index trên workspace |
| Màn gọi số chậm vì poll | Poll 2 giây như `use-display.ts`; dữ liệu nhỏ |

### Tiêu chí xong

- [ ] Số gọi tăng đúng theo chi nhánh × ngày kinh doanh, không trùng khi chạy song song, và in trên hóa đơn, ticket bếp, tem ly.
- [ ] Mỗi ly in đúng một tem, có "n/N"; in lại có audit.
- [ ] Màn khách chế độ gọi số chuyển số từ "Đang làm" sang "Mời nhận" theo trạng thái bếp, và số rời màn khi Đã giao.
- [ ] Chi nhánh tắt các module này thì không thấy thay đổi nào.

## Phần 7C: Đơn từ nền tảng giao hàng (nhập tay)

### Overview

Thu ngân nhập tay đơn GrabFood / ShopeeFood vào POS. Đơn có nguồn là nền tảng và đi thẳng xuống bếp với `service_mode = delivery`. Báo cáo cho thấy doanh thu, hoa hồng và tiền thực nhận theo nền tảng.

**Đã chốt 09/11/2026:** chưa có hợp đồng đối tác, và chi phí nối API ShopeeFood (khoảng 500 triệu) quá lớn ở giai đoạn này. Vì vậy phần này **chỉ làm nhập đơn tay**. Nối API (webhook, tự nhận đơn, đồng bộ thực đơn và hết món) làm sau, khi có hợp đồng; mục "Để sau" ở cuối file ghi điểm nối cho việc đó.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Đơn nền tảng **khách đã trả cho nền tảng**. Trong POS đơn vẫn đi đúng lõi: workspace → order → tender → complete. Tender là phương thức thanh toán mới `platform_receivable`, ghi khoản nền tảng nợ quán theo giá bán; khi nền tảng chuyển tiền thì đối soát. Không ghi tiền mặt, không đụng ngăn kéo. |
| Q2 | `Workspace::ORDER_SOURCES` thêm `grabfood` và `shopeefood`, nên báo cáo theo nguồn đơn hiện có tự tách được. Đơn có `service_mode = delivery`. Không dùng `Spree::Pos::Delivery` (người giao của quán), vì tài xế là của nền tảng. |
| Q3 | Nhập đơn tay gồm: nền tảng, mã đơn của nền tảng, mã lấy hàng, các món chọn từ thực đơn POS kèm modifier (phần 6A), và giá theo nền tảng nếu khác giá quán. Giá ghi đè có lý do `platform_price` và có audit, không cần `Approval`. |
| Q4 | Mã đơn nền tảng là unique theo chi nhánh × nền tảng, để không nhập trùng một đơn hai lần. |
| Q5 | Hoa hồng tính theo `commission_rate` cấu hình cho từng chi nhánh × nền tảng. Thu ngân sửa được số thực tế khi đối soát. |

### Dữ liệu

- `spree_pos_platform_settings`:
  - cột `store_id`, `branch_id`, `platform` (`grabfood | shopeefood`), `commission_rate`, `status` (`active | disabled`);
  - unique `(branch_id, platform)`.
- `spree_pos_platform_orders`:
  - cột `branch_id`, `platform`, `platform_order_ref`, `pickup_code`, `workspace_id`, `status` (`accepted | ready | completed | canceled`), `gross_amount`, `commission_amount`, `net_amount`, `entered_by_id`, `settled_at`;
  - unique `(branch_id, platform, platform_order_ref)`.
- Module `fnb.delivery_platforms` đăng ký là `available`.

### Server

- `Spree::Pos::PlatformOrders::Enter` nhận đơn nhập tay:
  - tạo workspace trên quầy và ca đang mở của thu ngân, với `order_source` và `service_mode = delivery`;
  - thêm các dòng menu, ghi giá nền tảng;
  - báo bếp như đơn trả trước (phần 7A);
  - in phiếu bếp có tên nền tảng và `pickup_code`, cấp số gọi (phần 7B).

  Lệnh idempotent theo idempotency key và theo mã đơn.
- `MarkReady` chạy khi KDS bump xong toàn bộ đơn. `Complete` chạy khi tài xế lấy hàng: tender `platform_receivable` theo `gross_amount`, complete, rồi phát hành hóa đơn điện tử theo cấu hình (phần 6C).
- `Cancel`: workspace chưa complete thì hủy. Món đã báo bếp thì đi qua luồng hủy món đã báo bếp (phần 8B), với lý do "nền tảng hủy".
- `Settle`: thu ngân đánh dấu các đơn đã được nền tảng chuyển tiền, và nhập hoa hồng thực tế nếu khác.
- Công nợ nền tảng: bước 1 kiểm xem `ReceivableEntry` có ghi được đối tượng nợ không phải khách hàng không. Nếu không được, tạo một `CustomerProfile` đại diện cho từng nền tảng ở mỗi store và dùng sổ hiện có. Chọn cách nào thì ghi lại trong file này.
- Báo cáo `Spree::Pos::Reports::Platforms` theo nền tảng × ngày kinh doanh: số đơn, doanh thu gộp, hoa hồng, thực nhận, khoản chưa đối soát. Xuất CSV qua `export_file.rb` đã có.
- API dưới `api/v3/admin/pos/`: `platform_orders` (create, index, `:id/ready`, `:id/complete`, `:id/cancel`, `settle`) và `platform_settings`. Cập nhật `server/openapi/pos-staff.yaml`.

### Client web `apps/pos`

- Nút "Đơn Grab / Shopee" trên màn bán, mở form nhập đơn: chọn nền tảng, mã đơn, mã lấy hàng, chọn món từ lưới thực đơn.
- Khay "Đơn nền tảng": đơn đang làm và đơn đã sẵn sàng, bấm "Tài xế đã lấy" để complete.
- Trang đối soát: lọc đơn chưa đối soát theo nền tảng và kỳ, đánh dấu đã nhận tiền.
- Cài đặt: bật nền tảng cho chi nhánh, tỷ lệ hoa hồng.
- Báo cáo nền tảng nằm ở trang Báo cáo.
- KDS (Flutter) hiện nhãn nền tảng và `pickup_code` trên ticket.

### File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_platform_orders.rb` (settings và orders) | Tạo |
| `server/app/models/spree/pos/platform_setting.rb`, `platform_order.rb` | Tạo |
| `server/app/workflows/spree/pos/platform_orders/enter.rb`, `mark_ready.rb`, `complete.rb`, `cancel.rb`, `settle.rb` | Tạo |
| `server/app/controllers/spree/api/v3/admin/pos/platform_orders_controller.rb`, `platform_settings_controller.rb` | Tạo |
| `server/app/services/spree/pos/reports/platforms.rb` | Tạo |
| `server/app/models/spree/pos/workspace.rb` | Sửa: `ORDER_SOURCES` thêm `grabfood`, `shopeefood` |
| `server/app/models/spree/pos/pos_payment_method.rb` | Sửa: thêm loại `platform_receivable` |
| `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos/src/components/platform-order-form.tsx`, `platform-order-tray.tsx`, `pages/platform-settlement.tsx`, `pages/settings/delivery-platforms.tsx`, `hooks/use-platform-orders.ts` | Tạo |

### Các bước

1. Kiểm khả năng ghi công nợ cho đối tượng không phải khách hàng của `ReceivableEntry`, rồi chốt cách ghi công nợ nền tảng.
2. Viết migration, model và tender `platform_receivable`.
3. Viết `Enter`, `MarkReady`, `Complete`, `Cancel`, `Settle`. Spec phải đi hết lõi: có tender, có `ReceivedFunds`, không đụng ngăn kéo.
4. Làm báo cáo nền tảng và xuất CSV.
5. Làm API và OpenAPI, rồi UI: form nhập, khay, đối soát, cài đặt, báo cáo; thêm nhãn nền tảng trên KDS.

### Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/platform_orders/ spec/requests/spree/pos/platform_orders_spec.rb spec/services/spree/pos/reports/platforms_spec.rb`.
- Spec: cùng mã đơn nhập hai lần chỉ tạo một đơn; giá nền tảng có audit; hủy đơn đã báo bếp đi qua luồng hủy món; đối soát chỉ đổi trạng thái công nợ, không đổi doanh thu.
- E2E web: nhập đơn tay → KDS bump → tài xế lấy → complete → báo cáo nền tảng có dòng → đối soát.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Thu ngân nhập sai giá hoặc sai món | Giá nền tảng hiện cạnh giá quán khi nhập; có audit; mã đơn unique. |
| Hoa hồng thực tế khác tỷ lệ cấu hình | Sửa được khi đối soát; báo cáo tách số ước tính và số thực tế. |
| Nhập tay chậm giờ cao điểm | Form dùng chung lưới thực đơn và modifier của màn bán. Nối API là bước sau. |

### Tiêu chí xong

- [ ] Đơn nhập tay đi hết luồng nhập → bếp → sẵn sàng → hoàn tất → đối soát.
- [ ] Không nhập trùng được cùng mã đơn nền tảng.
- [ ] Báo cáo theo nền tảng có doanh thu gộp, hoa hồng, thực nhận và khoản chưa đối soát.
- [ ] Spec và e2e xanh; OpenAPI đã cập nhật.

### Để sau: nối API nền tảng

Làm khi có hợp đồng đối tác và chấp nhận được chi phí. Phần cần thêm:
- interface `Spree::Pos::DeliveryPlatforms::Adapter` (`verify_webhook`, `parse_order`, `accept`, `reject`, `mark_ready`, `sync_availability`);
- webhook công khai `POST api/v3/pos_platforms/:platform/webhook`, cần địa chỉ công khai: VPS hoặc tunnel của phần 5B;
- tự nhận đơn và ánh xạ món nền tảng sang thực đơn POS;
- đồng bộ hết món qua `menu.sold_out`.

Workflow `Enter` của phần này là điểm vào chung: đơn từ webhook sẽ gọi cùng workflow đó, nên phần nhập tay không phải sửa.

## Phần 7D: Mở ngành đợt 1

### Overview

Phần này chốt đợt F1:
- chuyển các module F1 sang `available`;
- mở ba hồ sơ `cafe_tra_sua`, `quan_an` (trả trước) và `cang_tin_tram_dung` (bán nhanh, chưa có thẻ suất ăn);
- thêm vào wizard các bước F&B;
- có checklist phần cứng;
- chạy kịch bản đầu-cuối trên S1 (thu ngân), S3 (KDS), S5 (màn khách) và trạm in;
- viết hướng dẫn cho chủ quán và các bước rollout.

**Điều kiện phát hành:** phần 6C phải phát hành được hóa đơn qua adapter VNPT (nhà cung cấp do khách chọn; VNPT là bên làm trước). Hộ có doanh thu trên 1 tỷ/năm bắt buộc dùng hóa đơn điện tử.

### Quyết định

1. **Module F1 chuyển sang `available`:** `fnb.menu`, `fnb.kitchen`, `fnb.order_number`, `fnb.cup_label`, `fnb.recipes`. Các phần 6A, 7A, 7B, 6B đã đăng ký code của chúng; phần này kiểm tra mọi module F1 đều có trong `Modules.available` và có spec.

   Các module `resources`, `fnb.tables`, `fnb.postpay`, `fnb.service_charge`, `timed_billing` vẫn ở `planned`, nên hồ sơ `karaoke_bida`, `bar_pub_club`, `nha_hang` tiếp tục `coming_soon`.
2. **Hồ sơ đợt 1** (`server/config/pos/business_profiles.yml`):

   | Key | Module | `display.surface` | `branch_defaults` | Cờ "thường dùng" |
   |---|---|---|---|---|
   | `cafe_tra_sua` | fnb.menu, fnb.kitchen, fnb.order_number, fnb.cup_label, fnb.recipes | `menu_grid` | `kitchen_send_trigger: on_complete` | vietqr, customer_display |
   | `quan_an` | fnb.menu, fnb.kitchen, fnb.order_number, fnb.recipes, retail.measured | `menu_grid` | `kitchen_send_trigger: on_complete` | vietqr, credit, delivery |
   | `cang_tin_tram_dung` | fnb.menu, fnb.kitchen, fnb.order_number, retail.units | `menu_grid` | `kitchen_send_trigger: on_complete` | vietqr, customer_display |

   - `quan_an` thêm `retail.measured` để bán hải sản theo cân. `fnb.tables` sẽ được thêm vào hồ sơ này ở phần 8D.
   - Danh sách cờ trên chỉ là nhãn "thường dùng" và không tự bật cờ nào (D9).
   - Hồ sơ không ghi giờ cắt ngày kinh doanh mặc định: dùng mặc định của phase 1.
3. **Mở rộng validate của `BusinessProfiles`:**
   - `DISPLAY_FIELDS` thêm `surface`, nhận các giá trị `catalog`, `menu_grid` (bản sau thêm `table_grid`, `floor_plan`, `resource_board`, `tab_list`);
   - `BRANCH_DEFAULT_FIELDS` thêm `kitchen_send_trigger`.

   Client chọn surface theo `display.surface` của hồ sơ chi nhánh, còn module vẫn là điều kiện bắt buộc (`menu_grid` cần `fnb.menu`).
4. **Wizard:**
   - Ba hồ sơ đợt 1 chọn được ngay. Ba hồ sơ còn lại giữ nhãn "Sắp hỗ trợ" và giữ luồng hỏi "cửa hàng có bán cả hàng hóa không" như hiện tại.
   - Chọn hồ sơ F&B mở thêm bước **Thiết lập quán**: tạo trạm Bếp và Bar mặc định (căng tin chỉ một trạm), chọn thuế suất mặc định cho món ăn và đồ uống có cồn từ cấu hình thuế của phase 1, chọn trigger báo bếp.
   - Không có thực đơn mẫu; thực đơn nhập ở trang Cài đặt → Thực đơn.
5. **Checklist phần cứng** là một trang trong cài đặt (`pages/settings/hardware.tsx`). Trang đọc trạng thái thật từ server, không đánh dấu tay:
   - máy in hóa đơn, máy in bếp, máy in tem đã khai báo và đã in thử thành công (`PrintJob` gần nhất `printed`);
   - mỗi trạm có KDS hoặc máy in;
   - trạm in (`print_station`) đang online, theo `last_seen_at` của Device;
   - màn khách đã ghép (DisplaySession còn hạn);
   - địa chỉ server và kết nối internet ra ngoài cho VietQR / hóa đơn điện tử (health của phần 5B);
   - hóa đơn điện tử đã cấu hình (phần 6C).

### Server

- Bật đăng ký `available` cho module F1 trong `config/initializers/pos_modules.rb`, và kiểm thứ tự `depends_on` khi boot.
- Sửa `business_profiles.yml` và `business_profiles.rb` như quyết định 2 và 3.
- Workflow `Onboarding::Setup` nhận thêm `fnb_setup: { stations:, tax_categories:, kitchen_send_trigger: }`. Workflow gọi workflow tạo trạm của phần 7A và ghi `AuditEntry` `onboarding.fnb_setup`. Tạo lại không nhân đôi trạm (idempotency key của lệnh onboarding).
- `GET /pos/hardware_status?branch_id=` tổng hợp checklist từ Printer, PrintJob, Device, DisplaySession, KitchenStation, cấu hình hóa đơn điện tử và health. Quyền: `Capabilities::MANAGE`.
- OpenAPI: thêm `HardwareStatus`; cập nhật enum của hồ sơ và module.

### Client web (`apps/pos`)

- `components/setup/profile-picker.tsx`: ba hồ sơ đợt 1 hết nhãn "Sắp hỗ trợ" nhờ `status` từ server, không sửa danh sách cứng.
- Bước mới `components/setup/setup-fnb-step.tsx`; `setup-preview-step.tsx` hiện thêm trạm, thuế và trigger.
- Trang `pages/settings/hardware.tsx`, có lối vào từ `business-model.tsx` và thông báo sau wizard.
- `locales`: nhãn và mô tả của 3 hồ sơ (`profiles.cafe_tra_sua.*`…), bước thiết lập quán, checklist.

### Kịch bản đầu-cuối

Môi trường gồm server LAN (phần 5B) seed sẵn, thu ngân web, một app Flutter ở mode `kds`, một app ở mode `print_station` và một màn khách.

| # | Kịch bản | Kỳ vọng |
|---|---|---|
| 1 | Cafe: 3 ly (2 cùng tùy chọn, 1 khác), trả VietQR khớp webhook | 2 dòng; số gọi 1; ticket ở trạm Bar; 3 tem ly; màn khách "Đang làm" → bump → "Mời nhận" → Đã giao; nguyên liệu trừ đúng |
| 2 | Cafe: khách trả tiền mặt, máy in bếp tắt | Bán xong; PrintJob `failed` hiện ở checklist; in lại được khi bật máy |
| 3 | Quán ăn trả trước: 1 phở + 1 bia + 0,8 kg ốc theo cân | Phở tới Bếp, bia tới Bar; dòng cân dùng `retail.measured`; hóa đơn có 2 mức thuế (8% / 10%) |
| 4 | Căng tin: 30 đơn liên tiếp, có hàng đóng gói quét mã vạch | Số gọi liên tục; thao tác dưới 3 chạm cho một suất; hàng đóng gói trừ tồn như bán lẻ |
| 5 | Qua giờ cắt ngày kinh doanh khi quán đang mở | Số gọi bắt đầu lại từ 1; báo cáo theo `business_date` |
| 6 | Hóa đơn điện tử: mất internet trên server LAN | Bán vẫn xong; hóa đơn nằm trong hàng đợi và tự phát hành khi có mạng |
| 7 | Chi nhánh bán lẻ cùng store | Không thấy thay đổi nào; e2e bán lẻ không lỗi mới |

- Kịch bản 1–5 viết thành Playwright `apps/pos/e2e/fnb-wave1.spec.ts`. Phần KDS và trạm in kiểm bằng API cộng `flutter test integration_test/wave1_test.dart` trên emulator, với máy in giả là một TCP server nhận ESC/POS ở cổng 9100, chạy trong test.
- Kịch bản 6 và kiểm thử trên phần cứng thật (Sunmi T2 có máy in tích hợp, Xprinter LAN, máy in tem) chạy tay theo checklist, rồi ghi kết quả vào mục Kết quả của phần.

### Tài liệu và rollout

- Thêm mục **"Bán hàng F&B (cafe, quán ăn, căng tin)"** trong `README.md`, cùng chỗ với hướng dẫn chức năng hiện có. Nội dung:
  - chọn hồ sơ;
  - nhập thực đơn và tùy chọn;
  - trạm bếp và máy in;
  - ghép KDS / trạm in / màn khách;
  - số gọi và tem ly;
  - công thức;
  - hóa đơn điện tử.

  Lệnh và cấu hình kỹ thuật thì link sang tài liệu phần 5A và 5B, không chép lại.
- Rollout:
  1. Bật ở một quán thử: cafe, trên server LAN.
  2. Theo dõi 1 tuần các chỉ số: độ trễ KDS, PrintJob failed, discrepancy nguyên liệu, hóa đơn trong hàng đợi.
  3. Mở cho mọi khách mới.

  Rollback là chuyển module về `planned`. Dữ liệu được giữ nguyên, và chi nhánh đã chọn hồ sơ F&B vẫn bán được như bán lẻ (D5).

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/config/initializers/pos_modules.rb` | sửa | module F1 `available` |
| `server/config/pos/business_profiles.yml`, `server/app/services/spree/pos/business_profiles.rb` | sửa | hồ sơ, validate `surface`, `kitchen_send_trigger` |
| `server/app/workflows/spree/pos/onboarding/setup.rb`, `attributes.rb` | sửa | bước thiết lập quán |
| `server/app/controllers/spree/api/v3/admin/pos/hardware_status_controller.rb`, `server/app/services/spree/pos/hardware_status.rb` | tạo | checklist |
| `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | sửa | route, hợp đồng |
| `apps/pos/src/components/setup/setup-fnb-step.tsx`, `pages/settings/hardware.tsx` | tạo | wizard, checklist |
| `apps/pos/src/components/setup/profile-picker.tsx`, `setup-preview-step.tsx`, `pages/setup.tsx`, `pages/settings/business-model.tsx`, `locales/*` | sửa | wizard |
| `apps/pos/e2e/fnb-wave1.spec.ts`, `apps/pos-staff/integration_test/wave1_test.dart` | tạo | đầu-cuối |
| `README.md` | sửa | hướng dẫn chủ quán |

### Các bước

1. Viết spec boot: mọi module F1 `available`, hồ sơ đợt 1 `available`, ba hồ sơ còn lại `coming_soon`.
2. Viết validate `surface` và `kitchen_send_trigger`, kèm spec YAML hợp lệ / không hợp lệ.
3. Viết bước wizard F&B ở server và client. Spec: onboarding idempotent; hồ sơ bán lẻ không qua bước này.
4. Viết checklist phần cứng (service, endpoint, trang).
5. Viết kịch bản đầu-cuối tự động 1–5 và 7; chạy kịch bản 6 và phần cứng thật bằng tay.
6. Viết `README.md`. Xác nhận adapter VNPT của phần 6C phát hành được hóa đơn trên cửa hàng thử. Khách dùng nhà cung cấp khác thì chờ adapter tương ứng.
7. Rollout quán thử, rồi ghi kết quả.

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/business_profiles_spec.rb spec/services/spree/pos/modules_spec.rb spec/requests/spree/pos/onboarding_spec.rb spec/requests/spree/pos/hardware_status_spec.rb`
- Toàn bộ server: `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`
- Web: `pnpm --dir apps/pos lint typecheck test test:e2e`
- Flutter: `flutter analyze && flutter test && flutter test integration_test/wave1_test.dart` trong `apps/pos-staff`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Khách dùng nhà cung cấp hóa đơn điện tử chưa có adapter | Bản đầu chỉ có VNPT. Khách dùng bên khác thì viết thêm adapter theo interface của phần 6C trước khi mở cho khách đó |
| Phần cứng thật khác máy giả lập (font, khổ giấy, TSPL) | Bắt buộc chạy checklist phần cứng thật trước khi rollout |
| Hồ sơ `quan_an` đổi module ở phần 8D | Đổi hồ sơ ra diff (D7 của plan bán lẻ), không ghi đè chi nhánh đang chạy |

### Tiêu chí xong

- [ ] Ba hồ sơ đợt 1 chọn được trong wizard và tạo được chi nhánh F&B có trạm bếp và thuế.
- [ ] Kịch bản 1–7 đạt; kết quả phần cứng thật được ghi lại.
- [ ] Checklist phần cứng phản ánh trạng thái thật.
- [ ] `README.md` có hướng dẫn F&B đợt 1.
- [ ] Phát hành được hóa đơn qua adapter VNPT.
- [ ] Quán thử chạy 1 tuần không có lỗi chặn.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
