---
phase: 9
title: "Bếp: trạm, ticket, KDS"
status: pending
effort: "9 ngày"
dependsOn: [3, 4, 5, 8]
---

# Phase 9: Bếp — trạm, ticket, KDS bản đầu (`fnb.kitchen`)

## Overview

Món đã bán phải tới đúng bếp hoặc bar. Phase này làm:
- trạm bếp (`KitchenStation`);
- bảng định tuyến (`StationRoute`);
- ticket bếp bất biến (`KitchenTicket` / `KitchenTicketItem`);
- đường in phiếu bếp dự phòng qua `PrintJob`;
- **KDS bản đầu (S3) trong app Flutter**, ở mode `kds`.

Phase 9 phục vụ quán trả trước (F1). Báo bếp theo phần chênh lệch, hủy món đã báo kèm `Approval`, All-day đầy đủ và recall sau khi phục vụ đều thuộc phase 14 và 15.

## Quyết định của phase

1. **Thời điểm báo bếp là cấu hình của chi nhánh** (`branches.kitchen_send_trigger`):
   - `on_complete` (mặc định cho quán trả trước): ticket được tạo ngay trong transaction của `Workspaces::Complete`, sau khi đơn đã placed;
   - `manual`: thu ngân bấm **Báo bếp** trước khi thu tiền.

   Với cả hai trigger, mỗi lần gửi tạo ticket cho phần chưa gửi (`quantity − kitchen_sent_quantity`).
2. **Ticket bất biến.** Mỗi lần gửi là một ticket theo từng trạm, idempotent theo `(workspace_id, send_key)`. `send_key` là idempotency key của lệnh, hoặc `complete:<workspace_id>` khi trigger là `on_complete`. Sửa đơn sau khi gửi không sửa ticket cũ. Ở phase này, giảm số lượng xuống dưới `kitchen_sent_quantity` bị từ chối (`Conflict reason: 'kitchen_sent'`); việc hủy món đã báo bếp làm ở phase 14.
3. **Định tuyến** theo thứ tự ưu tiên: route theo product + `service_mode` → route theo product → route theo `kitchen_category` + `service_mode` → route theo `kitchen_category` → trạm mặc định của chi nhánh. Việc báo bếp **không bao giờ lỗi vì thiếu route**, và không bao giờ chặn việc bán.
4. **Trạng thái món:** `new → preparing → ready → served`, cộng `voided` (dùng từ phase 14). Ở quầy trả trước, trạng thái `ready` là xong, còn `served` được đặt khi bấm "Đã giao" ở S5 / KDS (phase 10).
5. **Trạm có KDS, có máy in, hoặc cả hai.** Trạm gắn `printer_id` thì mỗi ticket sinh một `PrintJob` kind `kitchen_ticket` (phase 4). Trạm không có KDS chỉ dùng máy in, giống POS365.
6. **Combo** in món con khi món bật `show_components_on_kds`, nếu không thì chỉ in tên combo. Tùy chọn và ghi chú luôn in.

## Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_kitchen_stations` | `branch_id`, `name`, `kind` (`prep`/`bar`/`expo`), `printer_id` (nullable), `kds_enabled`, `is_default`, `warn_after_minutes` (8), `late_after_minutes` (15), `position`, `active` | mỗi chi nhánh có tối đa một `is_default` (partial unique) |
| `spree_pos_station_routes` | `branch_id`, `kitchen_station_id`, `product_id` (nullable), `kitchen_category` (nullable), `service_mode` (nullable = mọi hình thức) | check: đúng một trong `product_id` / `kitchen_category`; unique `(branch_id, product_id, kitchen_category, service_mode)` |
| `spree_pos_kitchen_tickets` | `store_id`, `branch_id`, `workspace_id`, `kitchen_station_id`, `sequence` (theo workspace), `kind` (`fire`/`void`), `send_key`, `service_mode`, `business_date`, `header` jsonb (số gọi, bàn, khách, nguồn đơn), `sent_by_type/id`, `sent_at` | unique `(workspace_id, send_key, kitchen_station_id)` |
| `spree_pos_kitchen_ticket_items` | `kitchen_ticket_id`, `sale_line_id`, `name`, `modifiers` jsonb, `components` jsonb, `note`, `quantity`, `status`, `started_at`, `ready_at`, `served_at`, `voided_at`, `changed_by_type/id` | check `status` |
| `spree_pos_sale_lines` (sửa) | thêm `kitchen_sent_quantity` decimal, mặc định 0 | check `0 ≤ kitchen_sent_quantity` |
| `spree_pos_branches` (sửa) | thêm `kitchen_send_trigger`, mặc định `on_complete` | check giá trị |

Migration: `create_spree_pos_kitchen_tables`, `add_kitchen_columns_to_spree_pos_sale_lines_and_branches`.

## Server

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
  - số gọi (phase 10) hoặc bàn;
  - hình thức phục vụ;
  - món in cỡ lớn, tùy chọn thụt dòng, ghi chú in đảo màu.
- **Module:** đăng ký `fnb.kitchen` (depends_on: `fnb.menu`). Chi nhánh tắt module thì không gửi bếp; đơn vẫn bán và complete như cũ.
- **OpenAPI:** thêm `KitchenTicket`, `KitchenBoard`, `KitchenStation` và các endpoint ở trên.

## Flutter: KDS mode (`apps/pos-staff`)

- **Mã nguồn:** `lib/modes/kds/`, gồm:
  - `kds_shell.dart`: chọn trạm khi ghép thiết bị, giữ màn sáng (wakelock của phase 5);
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
  - nút **Hết món** mở danh sách món của trạm và gọi `PUT menu_availabilities` (phase 8).
- **Timer** tính bằng `server_now` cộng độ lệch đo khi tải, không dùng giờ của máy.
- **Âm thanh** khi có ticket mới. Giao diện chữ lớn, chạm được bằng tay ướt: nút tối thiểu 56dp.
- **i18n:** ARB `vi` / `en`, khóa `kds*`.

## Client web (`apps/pos`)

- Ở chế độ `manual`, đơn có nút **Báo bếp** cạnh nút thanh toán. Badge cho biết số món chưa gửi.
- Dòng đã gửi hiện biểu tượng "đã báo bếp". Nút giảm số lượng bị khóa xuống tới `kitchen_sent_quantity`, kèm gợi ý "Hủy món đã báo bếp có ở bản sau".
- Panel **Lịch sử báo bếp** (`components/kitchen-history.tsx`): giờ, trạm, món, trạng thái từng món.
- Trang **Cài đặt → Bếp & bar** (`pages/settings/kitchen.tsx`): trạm, máy in của trạm (chọn từ Printer của phase 4), ngưỡng vàng/đỏ, bảng route theo danh mục bếp / món / hình thức phục vụ, trigger báo bếp.

## File

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

## Các bước

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

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/kitchen/router_spec.rb spec/workflows/spree/pos/kitchen/`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/complete_spec.rb spec/requests/spree/pos/kitchen_spec.rb spec/requests/spree/pos/kitchen_stations_spec.rb`
- Race: `spec/integration/spree/pos/kitchen_send_race_spec.rb`: hai lệnh Báo bếp cùng lúc chỉ ra một ticket cho mỗi phần chưa gửi.
- Flutter: `flutter test test/modes/kds/`, `flutter test integration_test/kds_flow_test.dart`.
- Web: `pnpm --dir apps/pos test test:e2e` (`e2e/fnb-kitchen.spec.ts`).

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Gửi bếp trong transaction của `Complete` làm chậm hoặc làm vỡ việc thu tiền | Chỉ ghi DB; định tuyến không bao giờ raise; in và realtime chạy sau commit. Spec hồi quy `complete_spec` |
| KDS mất kết nối, bếp không thấy món | Poll dự phòng; trạm có cả máy in; KDS hiện banner "Mất kết nối" kèm giờ đồng bộ cuối |
| Đồng hồ máy KDS lệch | Timer dùng `server_now` |

## Tiêu chí xong

- [ ] Đơn trả trước complete tạo đúng ticket theo trạm, idempotent, và không bao giờ chặn việc thu tiền.
- [ ] Chế độ `manual` gửi đúng phần chưa gửi và khóa giảm số lượng đã gửi.
- [ ] KDS Flutter có 3 tab, bump, recall, timer vàng/đỏ, hết món; hoạt động bằng danh tính thiết bị.
- [ ] Trạm có máy in in được phiếu bếp qua trạm in.
- [ ] Đo độ trễ đạt ≤ 2 giây trong LAN, kết quả được ghi lại.
