---
phase: 7
title: "Bếp, quầy trả trước, mở đợt 1"
status: in-progress
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

- [x] Đơn trả trước complete tạo đúng ticket theo trạm, idempotent, và không bao giờ chặn việc thu tiền.
- [x] Chế độ `manual` gửi đúng phần chưa gửi và khóa giảm số lượng đã gửi.
- [x] KDS Flutter có 3 tab, bump, recall, timer vàng/đỏ, hết món; hoạt động bằng danh tính thiết bị.
- [ ] Trạm có máy in in được phiếu bếp qua trạm in.
- [ ] Đo độ trễ đạt ≤ 2 giây trong LAN, kết quả được ghi lại.

### Kết quả

**Đã làm**

- Dữ liệu: migration `20261111180000_create_spree_pos_kitchen_tables.rb` (trạm, tuyến, ticket, dòng ticket) và `20261111180100_add_kitchen_columns_to_spree_pos_sale_lines_and_branches.rb` (`kitchen_sent_quantity`, `kitchen_send_trigger`). `schema.rb` cập nhật qua `pnpm spree migrate`, các dòng check constraint bị viết lại đã được trả về như cũ.
- Model `KitchenStation`, `StationRoute`, `KitchenTicket`, `KitchenTicketItem`. Ticket ghi một lần; chỉ trạng thái dòng được đổi.
- `Kitchen::Router` (5 mức ưu tiên, trạm mặc định), `Kitchen::TicketDocument` (phiếu in, ghi chú chữ trắng nền đen qua cờ `invert` của khối text), `Kitchen::Board`.
- Workflow `Kitchen::Send` (idempotent, chỉ gửi phần chưa gửi, tách ticket theo trạm), `Kitchen::ChangeItemStatus` (start/ready/serve/recall, bump cả ticket), `Kitchen::Guard`, `Kitchen::Setup`. `Complete` gọi gửi bếp khi `on_complete`; `ManageLineItem` và `UpdateLineModifiers` chặn giảm, xoá, đổi tuỳ chọn dưới phần đã gửi. Realtime `kitchen_ticket.updated` phát sau commit.
- Module `fnb.kitchen`; quyền `pos.kitchen.operate`, `pos.kitchen.manage`. Hồ sơ `quan_an` gồm `fnb.kitchen` và `fnb.order_number`, nên vẫn `coming_soon` tới khi 7B xong.
- API quản trị (trạm, tuyến, cài đặt, board, thao tác món/ticket, gửi bếp, lịch sử ticket của đơn) và API thiết bị `pos_device/kitchen/*` (chế độ `kds`/`expo`, không PIN). OpenAPI `pos-staff.yaml` cập nhật; `spec/fixtures/print_documents/schema.json` thêm `invert`; client `pos_api` sinh lại bằng `tool/gen_api.sh`.
- Flutter `apps/pos-staff/lib/modes/kds/`: board 3 tab (Ưu tiên, Theo món, Theo bàn/số gọi), bump, recall trong mục "Đã xong", timer vàng/đỏ theo ngưỡng của trạm dựa trên `server_now`, âm báo ticket mới, giữ màn sáng, banner mất kết nối kèm giờ đồng bộ cuối và poll 5 giây khi socket rớt, chọn trạm, "Hết món" ký bằng PIN nhân viên. Expo dùng lại màn KDS với mọi trạm. Trạm in ESC/POS và raster in được khối text đảo màu.
- Web `apps/pos`: nút "Báo bếp" có số món chưa gửi (chỉ khi `manual`), lịch sử ticket của đơn, huy hiệu đã gửi trên dòng, khoá giảm/xoá/sửa tuỳ chọn phần đã gửi.
- `apps/pos-dashboard`: tab chi nhánh "Bếp & bar" (`/branches/$branchId/kitchen`): thời điểm gửi bếp, trạm (máy in, màn hình, ngưỡng phút, mặc định, bật/tắt), tuyến theo món hoặc nhóm bếp và hình thức phục vụ.

**Lệch so với kế hoạch**

- Trang cài đặt nằm ở `apps/pos-dashboard/src/pages/branch-kitchen.tsx` và route `branches/$branchId/kitchen.tsx`, không phải `apps/pos/src/pages/settings/kitchen.tsx` (cài đặt không đặt trong `apps/pos`). Hook quản trị là `apps/pos-dashboard/src/hooks/use-kitchen.ts`; `apps/pos/src/hooks/use-kitchen.ts` chỉ đọc lịch sử.
- Nút "Báo bếp" nằm trong `kitchen-history.tsx`, gắn vào `workspace-tabs.tsx` trước `PaymentPanel`; `payment-panel.tsx` không sửa.
- Controller tách hai bộ: quản trị (`admin/pos/kitchen*`, `station_routes`, `kitchen_settings`, `workspaces/kitchen_*`) và thiết bị (`pos_device/kitchen`), thay vì một bộ "thiết bị + nhân viên".
- Đổi trạng thái món idempotent theo trạng thái đích, không đi qua `CommandExecutor` (thiết bị KDS không có nhân viên đăng nhập). Gửi bếp và cài đặt vẫn đi qua `CommandExecutor` với `Idempotency-Key`.
- "Hết món" từ KDS mở phiên nhân viên bằng PIN rồi ghi `menu_availabilities` sẵn có.
- Chỉ dòng thuộc thực đơn được gửi; chi nhánh chưa có trạm thì không gửi gì. Chế độ `manual` không tự gửi khi complete.
- Expo dùng lại `KdsScreen` (`AppMode.expo`).
- Spec bất biến ticket nằm trong `send_spec.rb`; `complete_spec.rb` thêm một `describe` cho gửi bếp.
- `print-commands` web trong `pos-shared` chỉ thêm kiểu `invert`, chưa render đảo màu (in phiếu bếp đi qua trạm in Flutter).

**Lệnh và kết quả**

- `pnpm spree rspec` gồm `print_documents_spec`, `kitchen_send_race_spec`, `spec/services/spree/pos/kitchen`, `spec/workflows/spree/pos/kitchen`, `complete_spec`, `manage_line_item_spec`, `update_line_modifiers_spec`, `kitchen_spec`, `kitchen_stations_spec` và các spec hồi quy (branch_modules, branch_profiles, business_profiles, onboarding, topology, module_policy, menu, menu_availabilities, print_jobs, printers, sale_lines, workspace_items, realtime, devices): 248 ví dụ, 1 lỗi. Lỗi là `business_profiles_spec.rb:180` (đếm truy vấn `onboarding` ra 2 thay vì 1), do `StoreProfile.einvoice_type_for` trong `context_resolver.rb:39` đã commit ở ded9cec, không thuộc 7A.
- `tool/gen_api.sh` chạy lại sau lần sửa yaml cuối: không lệch so với bản đã sinh.
- `flutter analyze`: không có lỗi. `flutter test`: 100/100 qua (gồm `test/modes/kds/` 14 test, invert trong `print_commands_test` và `escpos_renderer_test`).
- `packages/pos-shared`: typecheck, lint qua; test 250/250.
- `apps/pos`: typecheck, lint qua; test 258/258 (`pos-administration.test.ts` cập nhật lên 25 quyền).
- `apps/pos-dashboard`: typecheck, lint, build qua; test 88/88.

**Còn mở**

- In phiếu bếp trên máy in thật qua trạm in: đường phần mềm đã có (print job từ `TicketDocument`, renderer có test), chưa thử trên phần cứng.
- Đo độ trễ Báo bếp → KDS ≤ 2 giây trong LAN: cần tablet và mạng thật, chưa đo.
- `integration_test/kds_flow_test.dart` cần `PARKVIET_SERVER` và `PARKVIET_KDS_CODE`, chưa chạy với server seed. KDS chưa chạy trên tablet thật.
- e2e `apps/pos/e2e/fnb-kitchen.spec.ts` chưa viết.
- Lỗi đếm truy vấn ở `business_profiles_spec.rb:180` cần chủ phần hoá đơn điện tử xử lý.

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

- [x] Số gọi tăng đúng theo chi nhánh × ngày kinh doanh, không trùng khi chạy song song, và in trên hóa đơn, ticket bếp, tem ly.
- [x] Mỗi ly in đúng một tem, có "n/N"; in lại có audit.
- [x] Màn khách chế độ gọi số chuyển số từ "Đang làm" sang "Mời nhận" theo trạng thái bếp, và số rời màn khi Đã giao.
- [x] Chi nhánh tắt các module này thì không thấy thay đổi nào.

### Kết quả

**Đã làm**

- Dữ liệu: bốn migration `20261111190000_create_spree_pos_order_number_counters.rb`, `20261111190100_add_call_number_and_guest_name_to_spree_pos_workspaces.rb` (unique một phần `(branch_id, business_date, order_number)`, `guest_name` tối đa 60), `20261111190200_add_cup_label_settings_to_spree_pos_branches.rb`, `20261111190300_add_mode_to_spree_pos_display_sessions.rb` (check `order`/`call_board`). `schema.rb` cập nhật qua `pnpm spree migrate`, các dòng check constraint bị viết lại đã được trả về như cũ; đã chạy `db:test:prepare`.
- `OrderNumberCounter` và `OrderNumbers.assign!`: một câu upsert `INSERT … ON CONFLICT … RETURNING`, đọc `workspace.business_date`, đơn đã có số thì giữ (model chặn đổi số), chi nhánh tắt `fnb.order_number` thì không cấp. Gọi trong `Kitchen::Send` trước khi ghi ticket (header ticket có `order_number`, `guest_name`) và trong `Complete` trước gửi bếp và phát hóa đơn.
- `Workspaces::SetGuestName` (`POST workspaces/:id/guest_name`): kiểm revision và lease như đặt nguồn đơn, gom khoảng trắng, chuỗi rỗng là xóa, quá 60 ký tự báo `guest_name_invalid`, cần `fnb.order_number` hoặc `fnb.cup_label`, ghi audit `workspace.guest_name.set`.
- Hóa đơn: biến `order.call_number`, `order.guest_name` ở `receipt_template_variables.json`, renderer, `TemplateData` và `pos-shared` (`variables.ts`, `data.ts`). `ReceiptBuilder#sale` đưa hai giá trị vào snapshot; mẫu `sale` mặc định có dòng "Số gọi {order.call_number}" cỡ lớn ngay dưới tiêu đề, dòng tự mất khi đơn không có số. Phiếu bếp in thêm tên khách dưới số gọi.
- Tem ly: `CupLabels::Settings` (khổ 40×30 / 50×30 / 58×40, trường hiện, phút ở cột "Mời nhận" 1–120, mặc định 15), `CupLabels::Document` (kind `cup_label`, "Số N · i/T", món, tùy chọn, ghi chú, tên khách, giờ · tên quán, `page.label` mm), `CupLabels::Issue` (một job mỗi ly, khóa `cup_label:<dòng>:<i>:<trigger>`, chạy sau commit của gửi bếp và của complete, lỗi máy in chỉ ghi log), `CupLabels::Reprint` (`POST workspaces/:id/cup_labels`, cần `pos.payment.collect`, audit `cup_label.reprint`), `CupLabels::Setup` (`GET/PUT cup_label_settings`, `POST cup_label_settings/test`, quyền quản lý bếp, audit `cup_label.settings`).
- Màn gọi số: `DisplaySession.mode`, `Displays::Pin.set_mode` (`POST display_sessions/:id/mode`, đổi mode thì xóa ghim và tăng generation; `call_board` cần `fnb.order_number`; ghim đơn khi đang `call_board` báo `display_call_board`). `CallBoard` trả `preparing` và `ready` (kèm tên khách, `ready_at`) của ngày kinh doanh; `DisplayState` dùng nó khi mode là `call_board`.
- Đã giao: `ChangeItemStatus.serve_order`, `POST kitchen/orders/:workspace_id/serve` (thu ngân, quầy bếp) và `POST pos_device/kitchen/orders/:workspace_id/serve` (KDS). `GET kitchen/orders` là danh sách chờ nhận cho thu ngân.
- Module `fnb.order_number` (depends_on: []) và `fnb.cup_label` (depends_on: `fnb.menu`) đăng ký `available`. `OpenAPI pos-staff.yaml`: `Workspace.order_number`, `guest_name`, `PrintPage.label`, schema `CallBoard`, `CupLabelSettings`, `KitchenOrderServedResult` và các endpoint mới; `schema.json` sinh lại; client `pos_api` sinh lại bằng `tool/gen_api.sh`.
- Web `apps/pos`: ô "Tên khách" ở đầu giỏ (`guest-name-field.tsx`), số gọi trên tab và băng số gọi trên giỏ (cỡ lớn sau khi complete), danh sách "Quầy trả món" (`pickup-queue.tsx`, nút "Đã giao", đọc lại khi có `kitchen_ticket.updated`), nút "In lại tem" trên dòng món đã gửi bếp hoặc đã bán, chọn chế độ màn khách trong `display-pin-control.tsx`, chế độ `call_board` trong `customer-display.tsx` (hai cột chữ lớn, số mới vào "Mời nhận" nhấp nháy và có âm báo, poll 2 giây). `readDisplayState` kiểm hình dạng trạng thái `call_board`.
- `apps/pos-dashboard`: thẻ "Tem ly" trong tab "Bếp & bar" (máy in tem, khổ, trường, phút ở "Mời nhận", in thử). Ô `cup_label` của món trong `pages/menu.tsx` đổi thành ô tích (cột là boolean).
- Flutter: KDS hiện số gọi và "Khách: …" trên ticket, khu "Đã xong" có nút "Đã giao" gọi API thiết bị. Trạm in đọc `page.label`: TSPL in đúng khổ tem (`SIZE w mm,h mm`, rộng `w × 8` chấm) và ngắt dòng theo bề rộng tem.

**Lệch so với kế hoạch**

- Cài đặt tem ly nằm ở `apps/pos-dashboard/src/pages/branch-kitchen.tsx`, không phải `apps/pos/src/pages/settings/kitchen.tsx` (như 7A).
- Tem in cả ở lần gửi bếp lẫn lúc complete khi chi nhánh bật bếp, dùng chung khóa `auto`: ly đã in ở lần gửi không in lại, ly mà chi nhánh `manual` chưa gửi bếp vẫn có tem khi thanh toán.
- `CupLabels::Issue` nằm ở `server/app/workflows/spree/pos/cup_labels/issue.rb` cùng `reprint.rb`, `setup.rb`; `Settings`, `Document` ở `services`.
- Danh sách chờ nhận dùng `GET kitchen/orders` (cùng dữ liệu `CallBoard`, có `workspace_id`). Danh sách hiện cả cột "Đang làm" để thu ngân thấy đơn đang chờ.
- Endpoint đổi mode màn khách không ghi vào `pos-staff.yaml` vì `display_sessions` không có trong hợp đồng đó.
- Hồ sơ F&B vẫn `coming_soon`: `BusinessProfiles::OPEN_GROUPS = %w[retail]` giữ chúng lại tới phần 7D, dù các module F1 đã `available`.
- Spec 50 luồng dùng số kết nối pool cho phép (pool − 1 worker) cùng rút 50 yêu cầu sau một cổng chung, thay vì 50 kết nối riêng.
- Không có mẫu hóa đơn F&B riêng: dòng số gọi nằm trong mẫu `sale` mặc định cho mọi cửa hàng và tự ẩn khi đơn không có số.
- Máy in tem không bị kiểm vai trò; chỉ cần máy in nhận lệnh qua trạm in (`printer_not_queued` nếu không).
- Sửa thêm ngoài phạm vi 7B: kiểu `cup_label` trong `pos-shared` (`string | null` → `boolean`) và ô nhập của dashboard menu, vì server lưu boolean và tem không thể bật đúng từ dashboard nếu để như cũ.
- Màn gọi số chỉ hiện đơn có ticket bếp: chi nhánh tắt `fnb.kitchen` có số gọi trên hóa đơn và tem nhưng màn gọi số trống.

**Lệnh và kết quả**

- `pnpm spree rspec spec/services/spree/pos/order_numbers_spec.rb spec/integration/spree/pos/order_number_race_spec.rb`: 7 ví dụ, 0 lỗi.
- `pnpm spree rspec spec/workflows/spree/pos/cup_labels/issue_spec.rb spec/services/spree/pos/display_state_spec.rb spec/requests/spree/pos/display_sessions_spec.rb`: 18 ví dụ, 0 lỗi.
- `pnpm spree rspec spec/services/spree/pos/print_documents_spec.rb`: lần đầu ghi lại golden (`sale-call-number.json` mới, `sale-default.json`, `sale-einvoice.json`, `schema.json`), lần sau 16 ví dụ, 0 lỗi.
- Hồi quy (`kitchen_send_race_spec`, `receipt_template_spec`, branch_modules, branch_profiles, business_profiles ×2, devices, kitchen, kitchen_stations, onboarding, print_jobs, printers, receipt_templates, receipts_displays, topology_access, topology, module_policy, `receipt_template_schema_spec`, kitchen `send_spec`, `complete_spec`): 248 ví dụ, 2 lỗi ở `receipt_template_schema_spec` do chỉ số khối header cố định; spec sửa sang đọc chỉ số từ mẫu mặc định, chạy lại cùng workspaces, menu, sale_lines, workspace_commands, sale_line_identity_contract, menu_item: 50 ví dụ, 0 lỗi. Đếm truy vấn ở `business_profiles_spec` (lỗi ghi ở 7A) lần này qua.
- Sau khi đặt tên `KitchenOrderServedResult` trong yaml: `devices_spec`, `display_sessions_spec`, `print_documents_spec`, `kitchen_spec`: 31 ví dụ, 0 lỗi.
- Hồi quy hóa đơn (`pay_later_spec`, `manage_line_item_spec`, `receipts_displays_spec`, các spec có `ReceiptBuilder`; không có `receipt_builder_spec.rb`): 46 ví dụ, 0 lỗi.
- `tool/gen_api.sh`: sinh lại `pos_api`. `flutter analyze`: không có lỗi. `flutter test`: 105/105 qua (golden `sale-call-number-58mm/80mm.escpos` mới, KDS số gọi + Đã giao, tem TSPL đúng khổ, ngắt dòng theo tem).
- `packages/pos-shared`: typecheck, lint qua; test 252/252 (`validate.test.ts` đọc chỉ số header từ mẫu mặc định).
- `apps/pos`: typecheck, lint, build qua; test 259/259. `e2e/fnb-call-number.spec.ts` viết xong và typecheck riêng qua, **chưa chạy** (máy chưa cài trình duyệt Playwright).
- `apps/pos-dashboard`: typecheck, lint, build qua; test 88/88.

**Còn mở**

- In tem trên máy in thật (một máy TSPL như Xprinter XP-365B và một máy ESC/POS): đường phần mềm có test, chưa thử phần cứng, chưa kiểm khổ tem thật.
- Màn gọi số trên màn hình thật (cỡ chữ, nhấp nháy, âm báo; trình duyệt có thể chặn âm thanh tới khi có người chạm màn) chưa thử.
- Chạy `apps/pos/e2e/fnb-call-number.spec.ts` (và cả bộ e2e) khi có trình duyệt Playwright.
- Thay đổi `config/initializers/pos_modules.rb` cần `pnpm spree restart` trên stack dev để module mới hiện ở môi trường dev.

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

- [x] Đơn nhập tay đi hết luồng nhập → bếp → sẵn sàng → hoàn tất → đối soát.
- [x] Không nhập trùng được cùng mã đơn nền tảng.
- [x] Báo cáo theo nền tảng có doanh thu gộp, hoa hồng, thực nhận và khoản chưa đối soát.
- [ ] Spec và e2e xanh; OpenAPI đã cập nhật.

### Để sau: nối API nền tảng

Làm khi có hợp đồng đối tác và chấp nhận được chi phí. Phần cần thêm:
- interface `Spree::Pos::DeliveryPlatforms::Adapter` (`verify_webhook`, `parse_order`, `accept`, `reject`, `mark_ready`, `sync_availability`);
- webhook công khai `POST api/v3/pos_platforms/:platform/webhook`, cần địa chỉ công khai: VPS hoặc tunnel của phần 5B;
- tự nhận đơn và ánh xạ món nền tảng sang thực đơn POS;
- đồng bộ hết món qua `menu.sold_out`.

Workflow `Enter` của phần này là điểm vào chung: đơn từ webhook sẽ gọi cùng workflow đó, nên phần nhập tay không phải sửa.

### Kết quả

**Đã làm**

- Dữ liệu: migration `20261111200000_create_spree_pos_platform_orders.rb`.
  - Bảng `spree_pos_platform_settings`: tỷ lệ là phần trăm 0–100; unique `(branch_id, platform)`.
  - Bảng `spree_pos_platform_orders`:
    - các cột theo kế hoạch, thêm `store_id`, `commission_rate` (chép lúc nhập), `currency`, `ready_at`, `completed_at`, `canceled_at`, `cancel_reason`, `settled_by_id`, `settlement_reference`;
    - unique `(branch_id, platform, platform_order_ref)` và unique `workspace_id`;
    - check `net = gross − commission`, và check chỉ đơn `completed` mới được đối soát.
  - Mở rộng các check constraint: `order_source` thêm `grabfood`, `shopeefood`; loại phương thức thanh toán và `received_funds.kind` thêm `platform_receivable`; `receipt_evidences.kind` thêm `platform_order`; báo cáo xuất thêm `platforms`.
  - `schema.rb` cập nhật qua `pnpm spree migrate`. Các dòng check constraint bị viết lại đã trả về như cũ, chỉ để lại 5 constraint đổi có chủ ý. Đã chạy `db:test:prepare`.
- Model `PlatformSetting` và `PlatformOrder` (có `estimate` và `assign_gross`). `Workspace` tách `PICKABLE_SOURCES` (nguồn thu ngân chọn) và `PLATFORM_SOURCES`; `SetOrderSource` từ chối chọn nền tảng và từ chối đổi nguồn của đơn nền tảng.
- Tender `platform_receivable`:
  - `PaymentMethodResolver#platform_method!` tạo phương thức `platform_receivable`, gắn với phương thức Check của Spree. Quầy không bao giờ thấy nó: danh sách quầy và trang phương thức thanh toán dùng scope `counter`.
  - `Tenders::Prepare` chỉ cho tender này trên workspace nền tảng, và workspace nền tảng chỉ nhận tender này (`platform_tender`).
  - `Tenders::Confirm` cần evidence `platform_order` kèm mã tham chiếu `nền tảng:mã đơn`, ghi `ReceivedFunds` loại `platform_receivable` đúng số tiền, không có `CashMovement`.
  - Phiếu thu ghi "Nền tảng giao hàng" (`receiptPlatform` trong `print_labels.json` và `pos-shared`).
- Workflow `PlatformOrders::*`:
  - `Enter`:
    - một lệnh `CommandExecutor`, idempotent theo key;
    - khóa `PlatformSetting` để hai lần nhập cùng mã luôn thấy nhau; trùng mã thì trả `platform_order_duplicate` kèm `platform_order_id`;
    - tạo workspace `delivery` trên ca của thu ngân, thêm dòng menu bằng `ManageLineItem.add`, chỉ nhận món thực đơn (`platform_item_not_menu`);
    - giá nền tảng ghi đè có audit `workspace.price.override` với lý do `platform_price`, không cần `Approval`;
    - cấp số gọi, báo bếp ngay cả khi chi nhánh để `manual`.
  - `MarkReady`: tự chuyển `ready` khi bếp xong hết món (gọi từ `Kitchen::ChangeItemStatus`), về lại `accepted` khi recall. Thu ngân cũng bấm tay được, bấm lần hai không đổi gì.
  - `Complete`: một lệnh gồm `ClaimLease` → `Tenders::Prepare` → `Tenders::Confirm` → `Workspaces::Complete`, nên có phiếu thu, `FundsAllocation`, Spree Payment `completed`, và hóa đơn điện tử theo cấu hình.
  - `Cancel`:
    - món bếp đang có (`new`, `preparing`, `ready`) cần duyệt (`approval_required`, hoặc người có `pos.approval.grant`);
    - món bị void với lý do `platform_canceled` và audit `kitchen.void`, rồi hủy workspace; số gọi giữ lại.
  - `Settle`: tối đa 200 đơn một lần. Chỉ đơn `completed` chưa đối soát; hoa hồng thực tế ≤ doanh thu. Chỉ đổi `PlatformOrder`; tender, `ReceivedFunds` và tổng đơn giữ nguyên.
  - Thêm ngoài kế hoạch: `Configure` (bật/tắt nền tảng, tỷ lệ; audit `platform_setting.change`) và `Guard` (quyền).
- Phiếu bếp: header ticket có `platform_order_ref` và `pickup_code`. `TicketDocument` in dòng đảo màu "GRABFOOD · Mã lấy: A12" và "Mã đơn nền tảng".
- Module `fnb.delivery_platforms` (`available`, phụ thuộc `fnb.menu`). Hồ sơ F&B chưa thêm module này.
- Báo cáo `Reports::Platforms` theo ngày kinh doanh × nền tảng: số đơn, doanh thu gộp, hoa hồng, thực nhận, chưa đối soát, hoa hồng ước tính và thực tế tách riêng. Xuất CSV qua `ExportFile` có sẵn. Route `reports/:report` thêm `platforms`.
- API `admin/pos/platform_orders`:
  - `index`: lọc `open`, `completed`, `canceled`, `unsettled`, theo nền tảng và kỳ (ngày kinh doanh); tham số sai trả 422;
  - `create`, `:id/ready`, `:id/complete`, `:id/cancel`, `settle`;
  - `platform_settings` (show/update).
  - `workspaces#index` nhận `platform=exclude`.
  - OpenAPI `pos-staff.yaml` thêm các path, kèm schema có tên cho mọi body và response (không sinh `InlineObject`), path `reports/platforms`, và mô tả header ticket. Client `pos_api` sinh lại bằng `tool/gen_api.sh`.
- Flutter KDS: `ticket_card.dart` hiện dải đảo màu "GRABFOOD · Mã lấy: A12" thay cho mã nguồn thô. Khóa ARB `kdsPlatformGrabfood`, `kdsPlatformShopeefood`, `kdsPickupCode` (vi/en); thêm widget test.
- `packages/pos-shared`:
  - `ORDER_SOURCES` thêm hai nền tảng; thêm `PICKABLE_ORDER_SOURCES`, `PLATFORM_ORDER_SOURCES`, `isPlatformSource`;
  - `ReceivedFunds.kind` thêm `platform_receivable`;
  - `platform-orders.ts` (kiểu, `activePlatforms`, kiểm mã đơn);
  - báo cáo `platforms` chỉ hiện khi bật module.
- Web `apps/pos`:
  - khay "Đơn Grab / Shopee" (`platform-order-tray.tsx`) với nút "Nhập đơn nền tảng", và đơn đang làm / sẵn sàng với "Sẵn sàng", "Tài xế đã lấy", "Hủy" (có lý do);
  - form `platform-order-form.tsx`: chọn nền tảng đang bật, mã đơn, mã lấy hàng, ghi chú, chọn món từ `MenuGrid` (kèm sheet modifier), số lượng, giá nền tảng cạnh giá quán, tổng theo giá nền tảng;
  - hook `use-platform-orders.ts`, logic thuần `lib/platform-order-draft.ts` (có test);
  - tab bán lọc bỏ đơn nền tảng; `OrderSourcePicker` chỉ hiện nguồn chọn được, và đơn nền tảng hiện nhãn cố định;
  - `MenuAdd` trả `Promise<unknown>` để form dùng lại lưới.
- `apps/pos-dashboard`:
  - tab chi nhánh "Nền tảng giao hàng" (`/branches/$branchId/platforms`): bật nền tảng, tỷ lệ hoa hồng;
  - trang "Đối soát nền tảng" (`/platform-settlement`, nhóm Tiền): lọc đơn chưa đối soát theo nền tảng và kỳ, chọn đơn, sửa hoa hồng thực tế, mã thanh toán của nền tảng;
  - tab báo cáo "Nền tảng giao hàng" (`/reports/platforms`, theo ngày kinh doanh);
  - quyền `branch-platforms` và `platform-settlement` trong `pos-access.ts`, kèm test.

**Cách ghi công nợ nền tảng (bước 1)**

- `ReceivableEntry` không ghi được đối tượng nợ không phải khách:
  - mỗi dòng cần `CreditAccount` gắn `CustomerProfile`, mà hồ sơ khách bắt buộc số điện thoại hoặc email thật;
  - ghi nợ còn đặt chỗ hạn mức và `due_on`;
  - nếu làm hồ sơ "GrabFood" đại diện thì phải bịa liên hệ, và đơn nền tảng lẫn vào sổ nợ khách, nhắc nợ, tuổi nợ.
- Đã chọn: khoản nền tảng nợ là chính dòng `PlatformOrder` (`gross_amount`, `commission_amount`, `net_amount`, `settled_at`), có `ReceivedFunds` loại `platform_receivable` làm chứng từ. Phiếu thu ghi tiền phải thu từ nền tảng, không vào ngăn kéo.
- "Chưa đối soát" là các đơn `completed` có `settled_at` rỗng; `Settle` chỉ đổi dòng `PlatformOrder`.

**Lệch so với kế hoạch**

- Hủy đơn đã báo bếp: chưa có luồng hủy món của 8B. `Cancel` tự void các món bếp đang có với lý do `platform_canceled`, cần duyệt bằng `ApplyDiscount.approve!` và có audit. Phiếu hủy in cho bếp (`void_ticket`) chưa phát; khi làm 8B thì chuyển sang luồng đó.
- Trang đối soát, cài đặt và báo cáo nằm ở `apps/pos-dashboard` (`pages/platform-settlement.tsx`, `pages/branch-platforms.tsx`, `hooks/use-platform-orders.ts`), không ở `apps/pos` (cài đặt và back office không đặt trong `apps/pos`).
- Không thêm quyền mới, dùng quyền sẵn có:
  - nhập, sẵn sàng, hủy cần `write_pos_orders` và `pos.shift.open`;
  - "Tài xế đã lấy" như mọi tender: chủ ca, `pos.payment.collect`;
  - đối soát cần `pos.payment.resolve` hoặc `write_pos_topology`;
  - cài đặt cần `pos.topology.manage` hoặc `write_pos_topology`;
  - duyệt hủy cần `pos.approval.grant`.
- `Cancel` và `Complete` lấy lại quyền sửa workspace (takeover) khi người làm có `pos.workspace.takeover`.
- Khay đọc lại mỗi 10 giây và sau mỗi lệnh; không thêm sự kiện realtime riêng.
- Không có `spec/services/spree/pos/reports/platforms_spec.rb`: báo cáo (dòng, tổng, ước tính và thực tế, lọc nền tảng, xuất CSV) được kiểm trong `spec/requests/spree/pos/platform_orders_spec.rb`.
- Báo cáo bán hàng theo nguồn đơn (`by_source`) nay có thêm dòng `grabfood` và `shopeefood`; `order_sources_spec.rb` cập nhật theo.
- KDS chỉ đổi phần hiển thị header, dữ liệu ticket không đổi; số gọi lấy từ 7B.

**Lệnh và kết quả**

- `pnpm spree rspec spec/workflows/spree/pos/platform_orders/ spec/requests/spree/pos/platform_orders_spec.rb` (sau khi rubocop `-a` chỉnh định dạng): 19 ví dụ, 0 lỗi.
- `pnpm spree rspec` các spec hồi quy: module_policy, business_profiles (service và request), branch_modules, branch_profiles, onboarding, topology, `spec/workflows/spree/pos/kitchen`, kitchen, workspaces complete, workspaces, order_sources, devices, print_documents, reports, receipts_displays, vietqr_tender, settlement, shared_master_data, funds_conservation, pay_later, kitchen_send_race.
  - Kết quả: 211 ví dụ, 1 lỗi.
  - Lỗi là `order_sources_spec.rb:126`, do danh sách nguồn có thêm nền tảng. Đã sửa expectation, chạy lại `order_sources_spec.rb`: 7/7 qua.
- `tool/gen_api.sh`: sinh lại, không có `InlineObject`. `flutter analyze`: không có lỗi. `flutter test`: 106/106 qua.
- `packages/pos-shared`: typecheck, lint qua; test 257/257.
- `apps/pos`: typecheck, lint qua; test 262/262.
- `apps/pos-dashboard`:
  - `pnpm build` qua (sinh lại `routeTree.gen.ts`);
  - typecheck và lint qua;
  - test 88/88; chạy lại `src/lib` sau khi thêm test quyền: 66/66.
- `rubocop` trên file mới: còn vài cảnh báo `Metrics/ParameterLists` và độ dài dòng (CI không chạy rubocop).

**Còn mở**

- E2E chưa chạy vì máy chưa cài trình duyệt Playwright:
  - `apps/pos/e2e/platform-orders.spec.ts`: nhập đơn, sẵn sàng, tài xế lấy;
  - `apps/pos-dashboard/e2e/platform-settlement.spec.ts`: đối soát, báo cáo.
  - Hai file đã viết và qua typecheck riêng.
- Luồng hủy món của 8B và in phiếu hủy cho bếp khi nền tảng hủy đơn đã báo bếp.
- Hồ sơ F&B chưa gồm `fnb.delivery_platforms` (mở hồ sơ ở 7D).
- Nối API nền tảng: xem mục "Để sau" ở trên; `Enter` là điểm vào chung.

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
- [x] Checklist phần cứng phản ánh trạng thái thật.
- [x] `README.md` có hướng dẫn F&B đợt 1.
- [ ] Phát hành được hóa đơn qua adapter VNPT.
- [ ] Quán thử chạy 1 tuần không có lỗi chặn.

### Kết quả

**Đã làm**

- Server:
  - `OPEN_GROUPS` của `BusinessProfiles` mở nhóm `fnb`. Ba hồ sơ `cafe_tra_sua`, `quan_an`, `cang_tin_tram_dung` là `available`; `karaoke_bida`, `bar_pub_club`, `nha_hang` vẫn `coming_soon` vì cần module `planned`. Spec boot mới `spec/services/spree/pos/modules_spec.rb`: mọi module F1 `available`, `depends_on` trỏ tới module có trước.
  - Validate mới: `display.surface` (`catalog`, `menu_grid`; `menu_grid` cần `fnb.menu`), `branch_defaults.kitchen_send_trigger` (theo `Kitchen::Send::TRIGGERS`), trường hồ sơ mới `kitchen_stations` (`prep`/`bar`, không trùng, cần `fnb.kitchen`). `GET business_profiles` trả thêm `tax_categories` (mức của ngày hiện tại, 8% → 10% từ 01/01/2027) và `menu_tax_defaults`.
  - `Onboarding::Setup` nhận `fnb_setup: { stations, tax_categories: { food, alcohol }, kitchen_send_trigger }`: kiểm hồ sơ có `fnb.menu`, tối đa 4 trạm, tên 1–80 ký tự không trùng; tạo trạm qua `Kitchen::Setup.create_station` (lệnh con, khóa suy ra từ khóa onboarding nên gửi lại không nhân đôi trạm); seed thuế và lưu thuế mặc định của món vào `StoreProfile`; trigger ghi vào chi nhánh; audit `onboarding.fnb_setup`. Hồ sơ bán lẻ gửi `fnb_setup` bị từ chối 422, không gửi thì không qua bước này.
  - Migration `add_menu_tax_defaults_to_spree_pos_store_profiles` (`food_tax_category_id`, `alcohol_tax_category_id`). `Menu::Save` gán thuế đồ ăn, đồ uống cho món mới khi sản phẩm chưa có thuế; `GET menu_items` trả `meta.tax_defaults`.
  - `GET /pos/hardware_status?branch_id=` (`HardwareStatus`): máy in hóa đơn / bếp / tem (PrintJob gần nhất `printed`), mỗi trạm có KDS online hoặc máy in, trạm in online theo `last_seen_at` (3 phút), màn khách còn phiên, server (địa chỉ, hàng đợi gửi ra ngoài), hóa đơn điện tử đã đủ thông tin. Quyền: `read_pos_topology` hoặc `Capabilities::MANAGE` ở chi nhánh. OpenAPI thêm `HardwareStatus` và các schema con, `MenuItemsMeta`; client Dart sinh lại.
- `packages/pos-shared`: `sellingSurfaceOf` chọn surface theo `display.surface` của hồ sơ (module vẫn là điều kiện bắt buộc); reducer wizard có bước **Thiết lập quán** (trạm, thuế, trigger, lỗi tên trạm / trùng / thuế) chỉ khi hồ sơ có `fnb.menu`; nhãn module F1 vi/en.
- `apps/pos`: quầy dùng `sellingSurfaceOf` thay vì chỉ xét `fnb.menu`.
- `apps/pos-dashboard`: bước wizard `components/setup/setup-fnb-step.tsx`; xem trước hiện lưới thực đơn, trigger và trạm; tóm tắt hiện trạm và thuế; sau khi tạo quán F&B mở thẳng checklist. Checklist là tab **Phần cứng** của chi nhánh (`pages/branch-hardware.tsx`, route `branches/$branchId/hardware`, đọc lại 30 giây một lần, mỗi dòng cần xử lý có link tới chỗ sửa), có lối vào từ trang Mô hình kinh doanh. Trang Thực đơn có ô Thuế suất cho món.
- Kịch bản: `apps/pos/e2e/fnb-wave1.spec.ts` (6 test, fixture giả lập API như các spec F&B khác): ba hồ sơ đợt 1 mở lưới thực đơn; bán cafe 3 ly (2 giống, 1 khác) thành 2 dòng, client không gửi giá; hồ sơ giữ `catalog` bán bằng tìm hàng; chi nhánh bán lẻ cùng store không thấy thực đơn và không gọi API thực đơn (kịch bản 7). `apps/pos-staff/integration_test/wave1_test.dart`: ghép trạm in với server thật, máy in giả là TCP server cổng 9100 trong test, in thử và (tùy chọn) nhận PrintJob đang chờ. Dashboard e2e thêm test wizard F&B và test bán lẻ không gửi `fnb_setup`.
- `README.md`: mục "Bán hàng F&B (cafe, quán ăn, căng tin)", link sang `apps/pos-staff/README.md` (5A), `docs/deploy/pos-lan-vps.md` (5B) và `docs/einvoice-providers.md`.

**Lệch so với kế hoạch**

- Module của hồ sơ: `cafe_tra_sua` và `quan_an` thêm `retail.units` (vì `fnb.recipes` phụ thuộc `fnb.menu` + `retail.units`; `quan_an` còn cần nó cho `retail.measured`), và thêm `fnb.delivery_platforms` (module đã `available` từ phần 7C).
- Thêm trường hồ sơ `kitchen_stations` để wizard biết đề xuất trạm nào (cafe, quán ăn: Bếp + Quầy pha chế; căng tin: Bếp), thay vì cứng trong client.
- Wizard và checklist ở `apps/pos-dashboard`, không ở `apps/pos` (màn cài đặt thuộc dashboard): `components/setup/setup-fnb-step.tsx`, `pages/branch-hardware.tsx` là một tab chi nhánh thay cho `pages/settings/hardware.tsx`. Không có `profile-picker.tsx`: nhãn "Sắp hỗ trợ" đã theo `status` từ server nên không phải sửa.
- Thuế mặc định của món lưu ở `StoreProfile` (cột mới) và trả trong `meta` của `GET menu_items`, vì Spree không có chỗ sẵn cho "thuế mặc định của món".
- OpenAPI không có enum hồ sơ / module: hợp đồng dùng chuỗi, danh mục đọc từ `GET business_profiles`, nên không cập nhật enum.
- Quyền `hardware_status`: ngoài `MANAGE` ở chi nhánh, người có `read_pos_topology` của store cũng xem được (quản trị cửa hàng).
- `fnb-wave1.spec.ts` chạy trên fixture giả lập API, không trên server thật: lúc làm, stack dev không chạy (container web tắt) và fixture thật (`pos-live-fixture.rb`) chỉ có chi nhánh bán lẻ. Phần cần server (ticket tới đúng trạm, bump, tem ly, trừ nguyên liệu, hai mức thuế, số gọi qua ngày) được kiểm ở rspec của 7A–7C và phần này.
- Rollback: đưa `fnb` ra khỏi `OPEN_GROUPS` (hồ sơ F&B về `coming_soon`) hoặc chuyển module về `planned`; dữ liệu giữ nguyên.

**Lệnh và kết quả**

- `pnpm spree rspec spec/services/spree/pos/business_profiles_spec.rb spec/services/spree/pos/modules_spec.rb spec/requests/spree/pos/onboarding_spec.rb spec/requests/spree/pos/hardware_status_spec.rb` cùng `business_profiles` (request), `branch_profiles`, `branch_modules`, `topology`, `module_policy`, `system_status`: 71 example, 0 failure.
- `pnpm spree rspec` cho `menu_item_spec`, `devices_spec`, `kitchen_stations_spec`, `menu_spec`, `receipt_store_profile_spec`, `print_documents_spec`, `kitchen_spec`: 45 example, 0 failure.
- `packages/pos-shared`: typecheck, lint, test 264/264 đạt.
- `apps/pos`: lint, typecheck đạt; test 262/262; `playwright test e2e/fnb-wave1.spec.ts --project desktop` 6/6; `fnb-menu`, `fnb-call-number`, `branch-modules`, `catalog-search` desktop 12/12.
- `apps/pos-dashboard`: typecheck, lint, test 89/89, `pnpm build` đạt (sinh lại `routeTree.gen.ts`).
- `apps/pos-staff`: `flutter analyze` không lỗi, `flutter test` 106 test đạt.

**Còn mở**

- Dashboard e2e (`e2e/setup.spec.ts`, `e2e/business-model.spec.ts`) đã sửa theo hồ sơ mới nhưng chưa chạy: cổng 5176 đang bị một tiến trình khác giữ. Vì vậy tiêu chí "chọn được trong wizard" chưa tick dù server và reducer đã có spec.
- `flutter test integration_test/wave1_test.dart` (và `kds_flow_test.dart`) chưa chạy: không có emulator / thiết bị, server dev không chạy.
- Kịch bản 1–5 trên server LAN thật với app KDS, trạm in và màn khách; kịch bản 6 (mất internet, hóa đơn trong hàng đợi) chạy tay; checklist phần cứng thật (Sunmi T2, Xprinter LAN, máy in tem).
- Kịch bản 4: lưới thực đơn thay chỗ ô tìm / quét mã, nên căng tin chưa quét được mã vạch hàng đóng gói khi đang ở lưới thực đơn (hồ sơ giữ `surface: catalog` thì quét được nhưng mất lưới). Cần quyết định có thêm quét mã vào lưới thực đơn không.
- Phát hành hóa đơn thật qua adapter VNPT trên cửa hàng thử.
- Quán thử chạy 1 tuần và các chỉ số rollout.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
