---
phase: 8
title: "Bàn, phục vụ, mở đợt 2"
status: pending
effort: "26 ngày"
dependsOn: [5, 7]
---

# Phase 8: Bàn, phục vụ, mở đợt 2

## Overview

Đây là một chuỗi nối tiếp của mô hình ăn tại bàn: bàn và trả sau, nhiều máy cùng sửa đơn, app phục vụ, rồi mở ba hồ sơ đợt 2.

| Phần | Nội dung | Effort |
|---|---|---|
| 8A | Bàn, khu vực, trả sau, phí phục vụ | 8 ngày |
| 8B | Nhiều máy cùng sửa đơn, báo bếp theo phần chênh lệch | 7 ngày |
| 8C | App phục vụ, KDS đầy đủ | 9 ngày |
| 8D | Mở ngành đợt 2 | 2 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 8A: Bàn, khu vực, trả sau, phí phục vụ

### Overview

Phần này đưa vào bốn module của đợt F2: `resources` (khu vực và bàn/phòng), `fnb.tables` (mở bàn, nhiều đơn trên một bàn, chuyển / gộp / tách), `fnb.postpay` (trả sau, yêu cầu thanh toán, tạm tính có quyền) và `fnb.service_charge` (phí phục vụ là dòng chịu thuế). Thu ngân web có thêm hai màn bắt đầu là `table_grid` và `floor_plan`, cùng trang sửa sơ đồ bàn trong cài đặt.

Phần này chưa cho nhiều máy cùng sửa một đơn: phần 8B lo phần đó. Ở đây, bàn vẫn được sửa theo lease hiện có, nhưng **chủ thể sửa đơn không còn bắt buộc là chủ ca** (xem Q2), vì phục vụ không mở ca.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Bàn là `Resource`, không phải Workspace. Đơn đang mở của bàn là các Workspace có `resource_id` = bàn đó, `service_mode = 'dine_in'` và `operational_status` thuộc `editing` / `parked`. Trạng thái bàn **được tính** từ các đơn đó, không lưu. Riêng `cleaning` và `out_of_service` là trạng thái lưu tay. |
| Q2 | Hiện `ManageLineItem.execute` từ chối nếu `workspace.shift.owner_id != staff.id`. Với đơn tại bàn, quyền sửa sẽ là: chủ ca **hoặc** nhân viên có capability mới `pos.table.serve` ở chi nhánh đó. Đơn tại bàn gắn vào **ca ghi sổ** là ca đang mở của quầy được chọn làm `Branch.table_register_id`. Không có ca nào mở thì từ chối mở bàn với `reason: 'no_open_shift'`. |
| Q3 | Khi thu ngân khác thu tiền, đơn chưa có tiền chuyển sang ca của người thu: mở rộng `ShiftRebind` với lối `rebind_to_collector!`, vẫn chỉ áp dụng khi chưa có `ReceivedFunds`. Đơn đã có tiền thì không chuyển ca (giữ bất biến hiện tại). Đơn qua ca chặn đóng ca như hiện nay. Phần này thêm danh sách "bàn còn mở" vào hộp đóng ca để thu ngân biết vì sao bị chặn. |
| Q4 | Một bàn có nhiều đơn: mặc định một đơn; nút "Thêm đơn cho bàn" tạo Workspace thứ hai cùng `resource_id`. Có `table_label` (A, B…) để in phiếu. |
| Q5 | Chuyển bàn đổi `resource_id`. Gộp bàn chuyển mọi dòng của đơn nguồn sang đơn đích rồi hủy đơn nguồn. Tách đơn theo món chuyển các dòng đã chọn sang Workspace mới cùng bàn hoặc bàn khác. Cả ba đều từ chối khi đơn nào liên quan đã khóa snapshot (`ensure_snapshot_editable!`). Dòng đã báo bếp giữ `kitchen_sent_quantity` khi chuyển (cột của phần 8B; ở phần này chuyển nguyên SaleLine nên không mất). |
| Q6 | Chia đều bill **không tách Order**: tạo nhiều tender trên cùng một đơn, mỗi tender bằng phần chia. Lõi đã cho nhiều TenderAttempt. Chia theo ghế để phần 9A. |
| Q7 | Tạm tính (`prebill`) chuyển từ "chỉ in ở client" (`prebill-dialog.tsx` hiện không ghi gì) sang **có ghi nhận ở server**: bảng `spree_pos_prebill_prints`. Lần in đầu không cần duyệt; in lại hoặc hủy tạm tính cần `Approval` với action `workspace.reprint_prebill` / `workspace.cancel_prebill`. Đơn đã in tạm tính mà bị sửa thì tạm tính cũ được đánh dấu `superseded`, và bàn hiện cờ "đã sửa sau tạm tính". |
| Q8 | Phí phục vụ là `Spree::Fee` cấp đơn (giống `Deliveries::Assign`), loại `service_charge`, tính theo % trên tổng món sau giảm giá. Cấu hình theo chi nhánh: `rate`, có áp cho mang đi hay không, `tax_category_id`. Phí phục vụ **chịu thuế** theo tax category đã cấu hình (research §7). |
| Q9 | Yêu cầu thanh toán là lệnh `PaymentRequest` gắn Workspace. Lệnh này phát sự kiện `payment.requested` (plan.md) cho thu ngân và màn khách. Nó không đổi tiền và không khóa snapshot. |

### Dữ liệu

Migration `create_spree_pos_areas_and_resources`:
- `spree_pos_areas`: `store_id`, `branch_id`, `name`, `position`, `status` (`active|archived`), `floor_width`, `floor_height`. Unique `(branch_id, name)` khi active.
- `spree_pos_resources`: `store_id`, `branch_id`, `area_id`, `kind` (check `table|room|billiard|vip`), `name`, `capacity` (int ≥ 0), `shape` (`rect|round`), `x`, `y`, `w`, `h` (int, đơn vị lưới), `rotation`, `manual_status` (`available|cleaning|out_of_service`, mặc định `available`), `resource_type_code` (dùng ở phần 11A để chọn bảng giá), `status` (`active|archived`), `position`. Unique `(branch_id, name)` khi active.

Migration `add_table_service_to_pos_workspaces`:
- `spree_pos_workspaces`: `resource_id` (FK, nullable), `guest_count` (int, nullable, 0–999), `table_label` (string ≤ 4). Index `(resource_id, operational_status)`.
- Validation: đơn có `resource_id` thì `service_mode` phải là `dine_in` hoặc `timed`. `resource_id` **không** nằm trong `source_is_immutable`, vì chuyển bàn cần đổi nó.

Migration `add_table_register_and_service_charge_to_pos_branches`:
- `spree_pos_branches`: `table_register_id` (FK register, nullable), `service_charge_rate` (decimal 5,2, nullable), `service_charge_applies_to` (jsonb mảng service_mode, mặc định `["dine_in"]`), `service_charge_tax_category_id` (nullable).

Migration `create_spree_pos_prebill_prints_and_payment_requests`:
- `spree_pos_prebill_prints`: `workspace_id`, `revision`, `sequence`, `staff_id`, `approval_id` (nullable), `status` (`current|superseded|canceled`), `total`, `currency`. Unique `(workspace_id, sequence)`.
- `spree_pos_payment_requests`: `workspace_id`, `requested_by_id`, `device_id` (nullable), `status` (`open|done|canceled`), `note`. Mỗi workspace có tối đa một request `open` (partial unique index).

### Server

- Model `Spree::Pos::Area`, `Spree::Pos::Resource` (`has_prefix_id :posarea`, `:posres`), `PrebillPrint`, `PaymentRequest`.
- `Spree::Pos::ResourceState.for(branch)` trả về trạng thái tính của từng bàn: `available`, `occupied` (có đơn, chưa báo bếp), `ordered` (đã báo bếp), `waiting_long` (món chờ quá ngưỡng, đọc từ `KitchenTicketItem`), `payment_requested`, `prebilled`, `reserved` (phần 9A), `cleaning`, `out_of_service`. Kèm số khách, phút đã ngồi (theo `Workspace.database_now`) và tổng tạm tính. Đọc thành một truy vấn gộp, không N+1.
- Workflow trong `app/workflows/spree/pos/resources/`: `upsert_area.rb`, `upsert_resource.rb`, `archive.rb`, `set_manual_status.rb`. Capability `pos.resource.manage` (mới, quản lý sơ đồ).
- Workflow trong `app/workflows/spree/pos/tables/`:
  - `open.rb`: tạo Workspace với `service_mode: 'dine_in'` và `resource_id`, có `guest_count`, gắn ca theo Q2. Dùng lại `Workspaces::Create` bên trong.
  - `move.rb`, `merge.rb`, `split.rb`: chạy dưới khóa của mọi workspace liên quan, khóa theo thứ tự `id` tăng dần để tránh deadlock, và tăng `revision` của từng workspace. Audit `table.move` / `table.merge` / `table.split`.
  - `request_payment.rb`, `resolve_payment_request.rb`.
- `Workspaces::Prebill` (mới): ghi `PrebillPrint`, tiêu `Approval` khi `sequence > 1` hoặc khi hủy. Nó trả về `PrintDocument` loại `prebill` và có thể tạo `PrintJob` (phase 4) nếu chi nhánh có máy in tạm tính.
- `ServiceCharges::Apply` (mới): gọi trong cùng transaction mỗi khi dòng hoặc giảm giá thay đổi, để `Spree::Fee` loại `service_charge` luôn khớp với tổng hiện tại. Chỉ chạy khi module `fnb.service_charge` bật và `service_mode` thuộc `service_charge_applies_to`. Thu ngân bỏ phí cho một đơn được: lệnh `waive_service_charge` cần capability `pos.discount.apply` và có audit.
- `Workspace#to_pos` thêm `resource`, `guest_count`, `table_label`, `service_charge`, `prebill`, `payment_request`.
- `AccessPolicy`: thêm helper `can_edit_workspace?(workspace, staff)` = chủ ca, hoặc (`resource_id` có và `allows?(branch, Capabilities::TABLE_SERVE)`). `ManageLineItem.execute`, `ApplyDiscount`, `ChangeStatus` và `ClaimLease` dùng helper này thay cho điều kiện `shift.owner_id` viết thẳng. Không đổi hành vi của đơn quầy (đơn không có `resource_id`).
- `Approval::SUBJECTS` giữ Workspace; thêm action `workspace.reprint_prebill`, `workspace.cancel_prebill`.
- Module: `resources`, `fnb.tables`, `fnb.postpay`, `fnb.service_charge` chuyển từ `planned` sang `register` trong `config/initializers/pos_modules.rb`. Lệnh của phần kiểm tra `ModulePolicy.require!`.
- Realtime: mọi lệnh bàn phát `resource.updated` và `workspace.updated`; yêu cầu thanh toán phát `payment.requested`.
- Route dưới `/api/v3/admin/pos/`: `areas`, `resources`, `resource_board` (GET trạng thái), `tables/:resource_id/open`, `workspaces/:id/move|merge|split|prebill|payment_request`. Cập nhật `server/openapi/pos-staff.yaml`.

### Client web (`apps/pos`)

- Surface `table_grid`: lưới ô bàn có lọc theo khu và theo trạng thái (Trống / Có khách / Chờ món / Yêu cầu thanh toán). Ô bàn hiện tên, số khách, phút ngồi và tạm tính. Chạm vào ô thì vào đơn; bàn có nhiều đơn thì hiện chọn đơn A / B.
- Surface `floor_plan`: vẽ bàn theo `x, y, w, h, shape` trong khung của khu, có tab tầng / khu. Dùng chung component ô bàn với `table_grid`.
- Màu trạng thái dùng token có sẵn trong `styles/`: trống = trung tính, có khách = xanh, đã báo bếp = xanh đậm, chờ lâu = vàng, yêu cầu thanh toán = đỏ, đã in tạm tính = tím, đang dọn = xám kẻ sọc. Màu luôn đi kèm nhãn chữ hoặc biểu tượng, không truyền nghĩa chỉ bằng màu.
- Thanh công cụ của đơn tại bàn: Chuyển bàn, Gộp bàn, Tách đơn, Tạm tính, Phí phục vụ (bỏ / áp), Thêm đơn cho bàn.
- `prebill-dialog.tsx` gọi `POST workspaces/:id/prebill` trước khi in. Khi in lại thì hiện `credit-approval-dialog` dạng chung để xin duyệt.
- Trang cài đặt `/settings/branches/$branchId/floor-plan`: sửa khu và bàn, kéo thả trên lưới, đặt kích thước và hình. Chỉ hiện khi module `resources` bật (`useBranchModules`).
- Màn bắt đầu chọn theo `display.surface` của hồ sơ ngành (plan bán lẻ đa ngành §display). Thu ngân đổi được giữa `menu_grid`, `table_grid` và `floor_plan`; lựa chọn lưu theo thiết bị.
- Realtime: `resource_board` refetch khi nhận `resource.updated`, `payment.requested` hoặc `workspace.updated`. Không có realtime thì poll mỗi 10 giây.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_create_spree_pos_areas_and_resources.rb`, `*_add_table_service_to_pos_workspaces.rb`, `*_add_table_register_and_service_charge_to_pos_branches.rb`, `*_create_spree_pos_prebill_prints_and_payment_requests.rb` |
| Tạo | `server/app/models/spree/pos/{area,resource,prebill_print,payment_request}.rb`, `server/app/services/spree/pos/resource_state.rb` |
| Tạo | `server/app/workflows/spree/pos/resources/*.rb`, `.../tables/{open,move,merge,split,request_payment,resolve_payment_request}.rb`, `.../workspaces/prebill.rb`, `.../service_charges/apply.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/{areas,resources,resource_boards,tables,prebills,payment_requests}_controller.rb` |
| Sửa | `server/app/models/spree/pos/{workspace,branch,capabilities,approval}.rb`, `server/app/services/spree/pos/{access_policy,shift_rebind}.rb`, `server/app/workflows/spree/pos/workspaces/{manage_line_item,apply_discount,change_status,claim_lease}.rb`, `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos/src/pages/tables.tsx`, `apps/pos/src/components/{table-tile,table-grid,floor-plan,floor-plan-editor,table-actions,split-order-dialog}.tsx`, `apps/pos/src/hooks/use-resource-board.ts`, `apps/pos/src/pages/settings/floor-plan.tsx` |
| Sửa | `apps/pos/src/router.tsx`, `apps/pos/src/components/{prebill-dialog,workspace-tabs,shift-close-dialog,payment-panel}.tsx`, `apps/pos/src/modules/registry.ts`, `apps/pos/src/locales/*` |

### Các bước

1. Migration và model, kèm spec model (ràng buộc kind, unique tên, `resource_id` chỉ với `dine_in` / `timed`).
2. `AccessPolicy#can_edit_workspace?` và thay điều kiện chủ ca trong bốn workflow. Chạy lại toàn bộ spec workspace để chứng minh đơn quầy không đổi hành vi.
3. `Tables::Open` gắn ca ghi sổ; mở rộng `ShiftRebind` cho người thu tiền.
4. Move / merge / split dưới khóa nhiều workspace; spec race cho hai lệnh gộp chéo nhau (A→B và B→A cùng lúc).
5. `ServiceCharges::Apply` và thuế của phí; spec tổng tiền khớp sau mỗi lần thêm / bớt dòng và giảm giá.
6. Tạm tính có ghi nhận và duyệt; yêu cầu thanh toán và sự kiện realtime.
7. `ResourceState` và endpoint `resource_board`, đo số truy vấn (một chi nhánh 80 bàn ≤ 6 truy vấn).
8. Client: hai surface, thanh công cụ, trang sửa sơ đồ, đổi `prebill-dialog`.
9. OpenAPI, i18n vi/en, bật module trong initializer.

### Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/resource_spec.rb spec/workflows/spree/pos/tables/ spec/workflows/spree/pos/service_charges/ spec/requests/spree/pos/tables_spec.rb spec/requests/spree/pos/resource_board_spec.rb spec/requests/spree/pos/prebills_spec.rb`.
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/workspaces/ spec/integration/spree/pos/workspace_race_spec.rb`.
- Spec bắt buộc:
  - nhân viên chỉ có `pos.table.serve` sửa được đơn tại bàn nhưng không sửa được đơn quầy của người khác;
  - đơn có tiền không chuyển ca;
  - gộp bàn từ chối khi một đơn đã khóa snapshot;
  - phí phục vụ có thuế đúng tax category;
  - in lại tạm tính khi không có duyệt trả 409 `approval_required`.
- Web: `pnpm --dir apps/pos typecheck`, `test`, `lint`; e2e `apps/pos/e2e/tables.spec.ts` (mở bàn → gọi món → tạm tính → thu tiền → bàn về trống).

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Nới điều kiện chủ ca mở đường cho nhân viên sửa đơn quầy của người khác | Helper chỉ nới khi `resource_id` có. Spec phủ định cho đơn quầy. |
| Deadlock khi gộp / tách nhiều workspace | Luôn khóa theo `id` tăng dần; spec race với hai kết nối. |
| Phí phục vụ lệch tổng khi giảm giá đổi sau | `ServiceCharges::Apply` chạy trong mọi lệnh đổi tiền; spec bất biến `fee == round(rate × net_item_total)`. |
| Chi nhánh chưa đặt `table_register_id` | Wizard ở phần 8D bắt chọn. Endpoint mở bàn trả `reason: 'table_register_missing'` kèm hướng dẫn. |

### Tiêu chí xong

- [ ] Quản lý tạo khu và bàn, kéo thả sơ đồ, đánh dấu bàn đang dọn.
- [x] Thu ngân mở bàn, nhập số khách, mở hai đơn trên một bàn, chuyển / gộp / tách đơn.
- [ ] Trạng thái bàn trên `table_grid` và `floor_plan` cập nhật qua realtime (≤ 2 giây) và vẫn chạy khi chỉ có poll.
- [x] Tạm tính lần đầu in ngay; in lại hoặc hủy cần duyệt và có audit.
- [x] Phí phục vụ tự tính, chịu thuế, bỏ được có audit.
- [x] Đơn quầy và toàn bộ spec bán lẻ không đổi hành vi.

### Kết quả

**Đã làm**

- Server:
  - Migration và model `Area`, `Resource`, `PrebillPrint`, `PaymentRequest`. Workspace có thêm `resource_id`, `guest_count`, `table_label`. Branch có thêm `table_register_id` và cấu hình phí phục vụ.
  - `AccessPolicy#can_edit_workspace?`: `pos.table.serve` chỉ nới quyền sửa cho đơn có bàn.
  - Workflow `Tables::{Open, Move, Merge, Split, RequestPayment, ResolvePaymentRequest}`, `Workspaces::Prebill` và `ServiceCharges::Apply`. Move, merge và split khóa các workspace theo `id` tăng dần.
  - `ShiftRebind` chuyển đơn sang người thu tiền khi đơn chưa có tiền, và trả `shift_has_funds` khi đã có tiền.
  - `ResourceState` và `GET /pos/resource_board`: 80 bàn tốn tối đa 6 truy vấn.
  - Controller cho khu, bàn (CRUD, lưu trữ, `manual_status`), mở bàn, chuyển / gộp / tách, tạm tính, hủy tạm tính, yêu cầu thanh toán và bỏ phí phục vụ.
  - Bật bốn module `resources`, `fnb.tables`, `fnb.postpay` và `fnb.service_charge`, cùng hai quyền `pos.table.serve` và `pos.resource.manage`.
- OpenAPI `pos-staff.yaml`: thêm path và schema có tên cho mọi object, không còn object inline. Đã sinh lại client Dart `pos_api`.
- `packages/pos-shared`:
  - `tables.ts`: đọc board, lọc và đếm trạng thái, kiểm tra bàn nằm trong khu trên lưới.
  - `tableSurfaceOf`: chọn surface `table_grid` / `floor_plan`.
  - Nhãn module, nhãn quyền và nhãn trạng thái bàn tiếng vi / en.
- `apps/pos`:
  - Hai surface `table_grid` và `floor_plan`. Lựa chọn surface lưu trên máy.
  - Thanh thao tác bàn: mở bàn, chuyển, gộp, tách (`split-order-dialog`), yêu cầu thanh toán, bỏ phí phục vụ, đánh dấu đang dọn.
  - `prebill-dialog` theo luồng mới: lần đầu in ngay; in lại và hủy cần duyệt.
  - `use-resource-board`: dùng realtime, có poll dự phòng.
  - `shift-close-dialog` báo đơn tại bàn còn mở.
  - e2e `tables.spec.ts`.
- `apps/pos-dashboard`:
  - Tab `/branches/$branchId/floor-plan`, chỉ hiện khi chi nhánh bật `resources`.
  - Quản lý khu và bàn trên lưới: kéo thả, thao tác bằng bàn phím, form bàn, trạng thái tay.
  - Thẻ "Phục vụ tại bàn": máy ghi sổ của bàn, phí phục vụ và tax category của phí.
  - Nhóm và gợi ý cho hai quyền mới.

**Lệch so với kế hoạch**

- **Nơi đặt trình sửa sơ đồ:** nằm ở `apps/pos-dashboard` (màn quản trị), không ở `apps/pos/src/pages/settings/floor-plan.tsx`.
- **Đường dẫn bỏ phí phục vụ:** là `POST /pos/workspaces/:id/service_charge`.
- **Cấu hình bàn của chi nhánh:** đọc và ghi qua endpoint riêng `table_settings`, không thêm vào `Branch#to_pos`. Cách này giữ budget truy vấn của context.
- **`PROFILE_HELD_MODULES`:** giữ các profile có module bàn ở `coming_soon`, nên `nha_hang` và `bar_pub_club` vẫn chưa mở.
- **Giới hạn của gộp và tách:**
  - Gộp và tách từ chối đơn có giảm giá (`discount_present`) và dòng có serial / lot.
  - Gộp từ chối đơn đã khóa snapshot (`snapshot_locked`).
- **Duyệt in lại / hủy tạm tính trên client:** chỉ chạy khi chính nhân viên đang đăng nhập có quyền duyệt. Chưa có luồng xin duyệt từ người khác.
- **Trạng thái `reserved`:** để sang 9A.
- **Spec migration `create_spree_pos_business_profiles_spec.rb`:** đã hỏng từ trước phần này, vì các module fnb mới mặc định tắt. Spec giờ chỉ so ba module bán lẻ.
- **Cập nhật spec module / profile:** liệt kê các module mới. Spec kiểm tra module chưa mở giờ dùng `timed_billing` thay `fnb.tables`.

**Lệnh và kết quả**

- Spec phần này đều qua:
  - `pnpm spree rspec spec/workflows/spree/pos/tables/`: 21 example, 0 lỗi. Gồm cả spec đơn có tiền không chuyển ca và gộp bàn đã khóa snapshot.
  - `pnpm spree rspec spec/workflows/spree/pos/service_charges/apply_spec.rb`: 6 example, 0 lỗi. Gồm thuế đúng tax category, làm tròn, giảm giá và bỏ phí có audit.
  - `pnpm spree rspec spec/requests/spree/pos/resource_board_spec.rb`: 4 example, 0 lỗi. Gồm budget 80 bàn ≤ 6 truy vấn.
  - `pnpm spree rspec spec/requests/spree/pos/prebills_spec.rb spec/requests/spree/pos/tables_spec.rb`: 9 example, 0 lỗi. Gồm in lại không có duyệt trả 409 `approval_required`, và người chỉ có `pos.table.serve` không sửa được đơn quầy của người khác.
  - `pnpm spree rspec spec/integration/spree/pos/table_merge_race_spec.rb`: 1 example, 0 lỗi.
- Hồi quy đều qua:
  - Request, workspace và race: 301, 198 và 114 example, 0 lỗi.
  - Spec module / profile / onboarding / migration: 0 lỗi.
- `packages/pos-shared`: typecheck và lint qua; 271 test qua.
- `apps/pos`: typecheck và lint qua; 272 test qua.
  - `playwright test e2e/tables.spec.ts`: 6/6 qua trên desktop, tablet và mobile.
  - e2e liên quan: 26 qua, 1 bỏ qua.
- `apps/pos-dashboard`: typecheck, lint và build qua; 99 test qua. Không chạy e2e vì cổng 5176 đang bận.
- `apps/pos-staff`: `flutter analyze` không có lỗi; `flutter test` qua 106 test.

**Còn mở**

- **Tiêu chí 1 chưa tick:** trình sửa sơ đồ có test đơn vị và spec server cho CRUD và `manual_status`, nhưng chưa được mở trong trình duyệt và chưa có e2e dashboard. Từ sơ đồ trên `apps/pos` chưa đặt được trạng thái "ngưng phục vụ".
- **Tiêu chí 3 chưa tick:** realtime ≤ 2 giây chưa đo trên stack thật. Poll dự phòng chỉ có unit test.
- **e2e còn thiếu:** chuyển, gộp, tách, bỏ phí phục vụ và yêu cầu thanh toán chưa có e2e. Các luồng này đã có spec server.
- **Tax category của phí phục vụ:** form dashboard đọc danh sách từ Admin API `GET /tax_categories`. Quản lý chi nhánh không có quyền cửa hàng có thể bị từ chối. Cách sửa gọn là để `table_settings` trả kèm danh sách tax category.
- **Khu và bàn đã lưu trữ:** chưa có endpoint khôi phục, nên editor chỉ liệt kê khu và bàn đang hoạt động.

## Phần 8B: Nhiều máy cùng sửa đơn, báo bếp theo phần chênh lệch

### Overview

Hiện mỗi workspace chỉ có một người giữ lease 120 giây (`Workspace::LEASE_TTL`). Mọi lệnh dòng hàng kiểm tra cùng lúc ba thứ: lease còn hạn, `lease_generation` khớp và `revision` khớp (`ManageLineItem.validate_command!`). Ở nhà hàng, hai phục vụ và một thu ngân có thể cùng thêm món vào một bàn trong một phút. Với luật hiện tại, hai trong ba người sẽ bị 409.

Phần này làm bốn việc:
- cho **thêm món** vào đơn tại bàn mà không cần lease;
- cho sửa / xóa **dòng chưa báo bếp** theo phiên bản của từng dòng;
- thêm lệnh "Báo bếp" chỉ gửi phần chênh lệch kể từ lần gửi trước và tạo ticket bất biến;
- quy định hủy món đã báo bếp phải có lý do và duyệt.

Đây là thay đổi lớn nhất ở lõi trong toàn plan (research §9.1), nên phải chạy lại toàn bộ bộ test race.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Lease **vẫn giữ** cho các lệnh đổi tiền cấp đơn: giảm giá đơn / dòng, đổi giá, khách hàng, phí, tender, complete. Chỉ ba lệnh mới được chạy không cần lease, và chỉ trên đơn có `resource_id` khi module `fnb.tables` bật: `append_items`, `edit_unsent_line`, `remove_unsent_line`. Đơn quầy giữ nguyên luật cũ. |
| Q2 | `append_items` nhận một **mẻ** dòng (một lần bấm "Thêm vào đơn" trên S2) và không kiểm tra `revision` của workspace, vì phép thêm giao hoán với nhau. Lệnh vẫn chạy dưới khóa workspace của `CommandExecutor`, vẫn gọi `ensure_snapshot_editable!` và tăng `revision`. Mỗi mẻ luôn tạo SaleLine mới; chỉ gộp với dòng **chưa báo bếp do chính mẻ đó tạo** (cùng `merge_key`). Không gộp vào dòng của người khác hay dòng đã báo bếp. |
| Q3 | Sửa / xóa dòng chưa báo bếp kiểm tra `SaleLine.row_version` (cột mới, tăng mỗi lần dòng đổi) thay cho `revision` của workspace. Lệch phiên bản trả 409 `reason: 'line_changed'` kèm dòng hiện tại. Không đụng đến dòng của người khác thì không bị chặn. |
| Q4 | Mỗi SaleLine có `kitchen_sent_quantity`. Ở phần 7A, đơn trả trước gửi bếp nguyên đơn khi complete. Cột này do phần 7A thêm; phần này dùng nó để "Báo bếp" gửi phần chênh lệch `sale_quantity − kitchen_sent_quantity` (snapshot "đã gửi", như `last_order_preparation_change` của Odoo). |
| Q5 | `Kitchen::Send` là lệnh idempotent theo key. Mỗi lần chạy tạo một bản ghi `KitchenSend` có `sequence` tăng dần theo workspace, rồi tách theo `StationRoute` thành các `KitchenTicket` bất biến (một ticket cho mỗi trạm). Gửi khi không có chênh lệch trả 200 với `ticket_count: 0`, không tạo bản ghi rỗng. |
| Q6 | Giảm số lượng dòng **đã báo bếp** là lệnh riêng `Kitchen::VoidSent`. Lệnh cần lý do (danh sách lý do theo chi nhánh, có "khác" kèm ghi chú), và cần `Approval` action `kitchen.void_sent` khi người làm không có capability `pos.kitchen.void`. Lệnh giảm `quantity` và `kitchen_sent_quantity` cùng lúc, tạo ngay `KitchenTicket` loại `void` và `PrintJob` loại `void_ticket`. Món đã ở trạng thái `ready` / `served` thì vẫn hủy được nhưng ghi `wasted: true` để báo cáo hao hụt; **không nhập lại kho** (research §9.2). |
| Q7 | Sau khi đơn có tiền (snapshot khóa), mọi lệnh thêm / sửa đều bị chặn như hiện tại. Khách gọi thêm sau khi đã trả một phần thì tạo **đơn bổ sung** cho cùng bàn (`Tables::Open` với `table_label` kế tiếp). Không nới bất biến khóa snapshot. |
| Q8 | Lệnh mở rộng / tách / gộp bàn ở phần 8A chuyển nguyên SaleLine, kể cả `kitchen_sent_quantity` và `row_version`, nên báo bếp sau khi chuyển không gửi trùng. |

### Dữ liệu

Migration `track_line_versions_on_pos_sale_lines` (`kitchen_sent_quantity` đã có từ phần 7A; phần này thêm check `kitchen_sent_quantity ≤ sale_quantity` sau khi trừ void):
- `spree_pos_sale_lines`: `row_version` (int, mặc định 0), `added_by_id` (staff), `added_device_id` (nullable), `append_batch_id` (uuid, nullable).

Migration `create_spree_pos_kitchen_sends_and_voids`:
- `spree_pos_kitchen_sends`: `workspace_id`, `sequence`, `staff_id`, `device_id`, `command_receipt_id`. Unique `(workspace_id, sequence)`.
- `spree_pos_kitchen_tickets`: thêm `kitchen_send_id` (nullable cho ticket trả trước ở phần 7A) (`kind` `fire|void` đã có từ phần 7A).
- `spree_pos_kitchen_voids`: `sale_line_id`, `quantity`, `reason_code`, `note`, `staff_id`, `approval_id`, `wasted`, `kitchen_ticket_id`.
- `spree_pos_branches.void_reasons` (jsonb, mặc định `["khach_doi_y","het_mon","nhap_nham","lam_hong"]`).

### Server

- `Workspaces::AppendItems` (`app/workflows/spree/pos/workspaces/append_items.rb`): nhận `items: [{variant_id, quantity, modifiers, note, course?, seat?}]` và `append_batch_id`. Bên trong dùng lại phần dựng dòng của `ManageLineItem.add` (tách thành `LineBuilder` dùng chung, không sao chép), nhưng thay `validate_command!` bằng `validate_append!`. Hàm mới kiểm tra: đơn `editing`/`parked`, có `resource_id`, `AccessPolicy#can_edit_workspace?`, module `fnb.tables` bật, `ensure_snapshot_editable!`. Lệnh trả về workspace và danh sách SaleLine đã tạo.
- `Workspaces::EditUnsentLine` / `RemoveUnsentLine`: kiểm tra `row_version`, từ chối khi `kitchen_sent_quantity > 0` với `reason: 'line_sent'` và gợi ý dùng void.
- `Kitchen::Send` (`app/workflows/spree/pos/kitchen/send.rb`): khóa workspace, tính chênh lệch, gọi router trạm của phần 7A và tạo ticket. Cập nhật `kitchen_sent_quantity`, phát `kitchen_ticket.updated` và `workspace.updated`, tạo `PrintJob` cho trạm dùng máy in.
- `Kitchen::VoidSent` (`.../kitchen/void_sent.rb`): như Q6. Audit `kitchen.void_sent` kèm số lượng, lý do và người duyệt.
- `Approval`: thêm action `kitchen.void_sent`. Approval gắn vào Workspace và `revision`, nên Workspace vẫn là `SUBJECTS`.
- Capability mới: `pos.kitchen.void` (hủy món đã báo bếp không cần duyệt).
- `CommandExecutor`: không đổi. Lệnh không cần lease vẫn có idempotency key; replay cùng key trả cùng kết quả.
- `Workspace#to_pos` mỗi dòng thêm `kitchen_sent_quantity`, `row_version`, `pending_kitchen_quantity`, `added_by`. Đơn có thêm `kitchen_sends` (sequence, giờ, người).
- Thêm lịch sử báo bếp: `GET workspaces/:id/kitchen_history` gồm giờ, người, món tăng / giảm (học từ KiotViet "Lịch sử báo bếp").
- OpenAPI: `POST workspaces/:id/items:append`, `PATCH .../sale_lines/:id` (có `row_version`), `DELETE .../sale_lines/:id`, `POST workspaces/:id/kitchen_sends`, `POST sale_lines/:id/kitchen_voids`, `GET .../kitchen_history`.

### Client web (`apps/pos`)

- Đơn tại bàn: dòng đã báo bếp có nhãn "Đã báo bếp ×n"; phần chưa gửi hiện rõ. Nút **Báo bếp** hiện số món sẽ gửi.
- Giảm số lượng dòng đã báo bếp mở hộp hủy món: chọn lý do, ghi chú, và xin duyệt nếu thiếu quyền (dùng lại luồng `Approval` đang có của giảm giá).
- 409 `line_changed`: refetch, giữ phần người dùng vừa nhập nếu áp lại được, và hiện thông báo "Dòng này vừa được người khác sửa". 409 `line_sent`: mở hộp hủy món.
- Thu ngân không cần lease để thêm món vào bàn, nhưng nút giảm giá / thanh toán vẫn đi theo lease như hiện tại.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_track_kitchen_sent_quantity_on_pos_sale_lines.rb`, `*_create_spree_pos_kitchen_sends_and_voids.rb` |
| Tạo | `server/app/workflows/spree/pos/workspaces/{append_items,edit_unsent_line,remove_unsent_line}.rb`, `server/app/services/spree/pos/line_builder.rb`, `server/app/workflows/spree/pos/kitchen/{send,void_sent}.rb`, `server/app/models/spree/pos/{kitchen_send,kitchen_void}.rb` |
| Sửa | `server/app/workflows/spree/pos/workspaces/manage_line_item.rb` (tách `LineBuilder`), `server/app/models/spree/pos/{sale_line,workspace,approval,capabilities,branch}.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `server/spec/integration/spree/pos/table_append_race_spec.rb`, `server/spec/workflows/spree/pos/kitchen/{send,void_sent}_spec.rb`, `server/spec/workflows/spree/pos/workspaces/append_items_spec.rb` |
| Sửa | `apps/pos/src/components/{order-lines,workspace-tabs}.tsx`; tạo `apps/pos/src/components/{kitchen-send-button,void-item-dialog,kitchen-history}.tsx` |

### Các bước

1. Tách `LineBuilder` khỏi `ManageLineItem.add` mà không đổi hành vi. Chạy toàn bộ spec `workspaces/` để chứng minh.
2. Migration cột dòng; `row_version` tăng trong mọi lệnh đổi dòng (kể cả lệnh cũ).
3. `AppendItems` và hai lệnh dòng chưa gửi.
4. `Kitchen::Send` tính chênh lệch và tạo ticket, idempotent.
5. `Kitchen::VoidSent` với duyệt, phiếu hủy, cờ hao hụt.
6. Spec race:
   - hai `append_items` cùng lúc trên một bàn đều thành công, không mất dòng, `revision` tăng 2;
   - `append_items` chạy cùng `complete` / tender prepare thì một bên bị chặn đúng luật khóa snapshot;
   - hai `Kitchen::Send` cùng key chỉ tạo một lần, khác key thì lần sau gửi 0 món.
7. Client: nhãn đã báo bếp, nút báo bếp, hộp hủy món, xử lý 409.
8. OpenAPI và i18n.

### Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/workspaces/ spec/workflows/spree/pos/kitchen/ spec/integration/spree/pos/`.
- Hồi quy đầy đủ: `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`.
- Spec phủ định:
  - đơn quầy gọi `append_items` trả 409 `module_disabled` hoặc `not_table_order`;
  - sửa dòng đã báo bếp bằng `edit_unsent_line` trả `line_sent`;
  - hủy món đã báo bếp không có duyệt và không có `pos.kitchen.void` trả `approval_required`.
- Web: `pnpm --dir apps/pos typecheck`, `test`, `test:e2e` (thêm `e2e/table-kitchen-send.spec.ts`: hai tab trình duyệt cùng thêm món vào một bàn rồi báo bếp).

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Tách `LineBuilder` làm đổi hành vi bán lẻ (cân, lô, serial) | Bước 1 tách riêng, có commit riêng và chạy toàn bộ spec trước khi thêm lệnh mới. |
| Thêm món không cần lease mà chạy cùng lúc với tender của thu ngân | Khóa workspace của `CommandExecutor` tuần tự hóa hai lệnh. `ensure_snapshot_editable!` chạy trong khóa. Có spec race. |
| Báo bếp gửi trùng khi mạng chập chờn | Idempotency key và `kitchen_sent_quantity` cập nhật trong cùng transaction. |
| Hủy món bị lạm dụng | Lý do bắt buộc, duyệt theo quyền, audit, báo cáo hủy món theo nhân viên (phần 12C đọc). |

### Tiêu chí xong

- [x] Hai phục vụ và một thu ngân cùng thêm món vào một bàn mà không ai bị 409.
- [x] "Báo bếp" chỉ gửi phần chênh lệch; gửi lại cùng key không tạo ticket mới.
- [x] Hủy món đã báo bếp có lý do, duyệt theo quyền, phiếu hủy in ở trạm, và có audit.
- [x] Đơn đã có tiền không sửa được; gọi thêm đi vào đơn bổ sung.
- [x] Toàn bộ spec bán lẻ, `workspace_race_spec` và e2e bán hàng vẫn xanh.

### Kết quả

**Đã làm**

- Server:
  - Migration `track_line_versions_on_pos_sale_lines`: `spree_pos_sale_lines` thêm `row_version`, `added_by_id`, `added_device_id`, `append_batch_id` và check `kitchen_sent_quantity ≤ sale_quantity`. `row_version` tăng trong mọi lệnh đổi dòng, kể cả lệnh cũ (callback `before_update`).
  - Migration `create_spree_pos_kitchen_sends_and_voids`: bảng `spree_pos_kitchen_sends` và `spree_pos_kitchen_voids`, `kitchen_tickets.kitchen_send_id`, `spree_pos_branches.void_reasons` (mặc định bốn lý do).
  - `LineBuilder` tách khỏi `ManageLineItem.add`, không đổi hành vi. Toàn bộ spec `workspaces/` qua ngay sau khi tách.
  - `Workspaces::AppendItems`, `EditUnsentLine`, `RemoveUnsentLine`: không cần lease, chỉ cho đơn có bàn khi `fnb.tables` bật, quyền đi qua `can_edit_workspace?`. Sửa / xóa kiểm tra `row_version`, trả `line_changed` kèm dòng hiện tại hoặc `line_sent`.
  - `Kitchen::Send`: ghi `KitchenSend` có `sequence`, idempotent theo key, chỉ gửi chênh lệch. Không còn gì để gửi thì trả 200 với `ticket_count: 0`. Đầu phiếu bếp có thêm tên bàn.
  - `Kitchen::VoidSent`: lý do theo chi nhánh (`khac` cần ghi chú), approval `kitchen.void_sent` khi thiếu `pos.kitchen.void`, phiếu `void` và print job `void_ticket` ("HỦY MÓN", "-1 x Món", "Lý do: …"), cờ `wasted` khi bếp đã làm, không nhập lại kho, audit `kitchen.void_sent`.
  - Hủy đơn sàn (`PlatformOrders::Cancel`) chuyển sang `VoidSent` với lý do `platform_canceled`: một approval cho cả đơn như trước, và giờ in phiếu hủy ở trạm.
  - `Workspace#to_pos`: mỗi dòng thêm `pending_kitchen_quantity`, `row_version`, `added_by`; đơn có bàn thêm `kitchen_sends`. `Branch#to_pos` thêm `void_reasons`. `Kitchen::History` và `GET workspaces/:id/kitchen_history`.
  - Quyền mới `pos.kitchen.void`.
- OpenAPI `pos-staff.yaml`: path và schema có tên cho append, sửa / xóa dòng chưa gửi, hủy món, lịch sử báo bếp và kết quả báo bếp. Đã sinh lại client Dart `pos_api`, không có `InlineObject`.
- `packages/pos-shared`: kiểu mới cho dòng, đơn và chi nhánh; quyền `pos.kitchen.void` cùng nhãn vi / en.
- `apps/pos`:
  - `lib/table-kitchen.ts` và test: khi nào được thêm / sửa không cần lease, danh sách lý do hủy, nhận diện `line_changed` / `line_sent`.
  - `use-workspaces`: đơn có bàn thêm món qua `items/append` (mỗi tab là một mẻ đến lần báo bếp kế tiếp), sửa / xóa dòng chưa gửi theo `row_version`, báo bếp không cần lease, thêm `voidSent`. Đơn quầy giữ luồng cũ.
  - `order-lines`: nhãn "Đã báo bếp ×n"; giảm hay xóa phần đã báo mở hộp hủy món; 409 `line_changed` tải lại đơn và báo "Dòng này vừa được người khác sửa"; `line_sent` mở hộp hủy món; `snapshot_locked` gợi ý mở đơn bổ sung.
  - `void-item-dialog` mới: số lượng, lý do, ghi chú, mã duyệt khi thiếu quyền.
  - `kitchen-history`: nút Báo bếp có số món luôn hiện với đơn có bàn; lịch sử đọc từ `kitchen_history` (lần gửi, giờ, người, món tăng / giảm, lý do hủy, người duyệt, hao hụt).
  - `workspace-tabs`: cờ `appendable` cho phép thêm món, sửa dòng chưa gửi và báo bếp trên đơn có bàn không cần lease. Giảm giá, đổi giá, tùy chọn món và thanh toán vẫn theo lease.
  - e2e `table-kitchen-send.spec.ts`: hai tab cùng thêm món vào một bàn rồi báo bếp. Fixture e2e mô phỏng append, sửa / xóa dòng chưa gửi và báo bếp.
- `apps/pos-dashboard`: quyền mới nằm trong nhóm "menu" của danh sách quyền, có gợi ý vi / en.

**Lệch so với kế hoạch**

- **Báo bếp của đơn có bàn cũng không cần lease:** Q1 chỉ kể ba lệnh. Không vậy thì phục vụ không giữ đơn sẽ không gửi được món mình vừa thêm. Báo bếp vẫn chạy được sau khi đơn có tiền, vì lệnh không đổi tiền; thêm / sửa / hủy thì vẫn bị chặn.
- **`KitchenSend` dùng `send_key`** (unique theo workspace) thay cho `command_receipt_id`, vì receipt của `CommandExecutor` chỉ tạo sau khi khối lệnh chạy xong. `KitchenSend` được ghi cho mọi lần gửi, kể cả gửi khi complete.
- **Khóa ngoại:** `kitchen_ticket_items.sale_line_id` và `kitchen_voids.sale_line_id` chuyển sang `on_delete: :nullify`, vì hủy hết một dòng sẽ xóa SaleLine. Ticket vẫn giữ tên và số lượng.
- **`void_reasons`** đọc qua `Branch#to_pos`; chưa có màn sửa danh sách trên dashboard.
- **Đường dẫn:** `POST workspaces/:id/items/append` (không phải `items:append`) và `POST workspaces/:id/sale_lines/:sale_line_id/kitchen_voids`. `DELETE sale_lines/:id` nhận `row_version` ở query.
- **Báo bếp trả 200** khi không còn gì để gửi, 201 khi có ticket mới.
- **Chi tiết 409 `approval_required`** của hủy món dùng `details.action` như tạm tính, để client dùng chung `approvalAction`.
- **Spec request** đặt tên `spec/requests/spree/pos/table_kitchen_spec.rb`. Không tách `kitchen-send-button.tsx`: nút nằm sẵn trong `kitchen-history.tsx`.
- **Mẻ trên web:** một mẻ là mọi lần thêm từ một tab đến lần báo bếp kế tiếp, nên bấm cùng món hai lần vẫn gộp một dòng. Thêm món ở tab khác luôn ra dòng mới.

**Lệnh và kết quả**

- `pnpm spree rspec spec/workflows/spree/pos/ spec/integration/spree/pos/ spec/services/spree/pos/ spec/models/spree/pos/`: 574 example, 0 lỗi (gồm `workspace_race_spec` và `table_append_race_spec`).
- `pnpm spree rspec spec/requests/spree/pos/`: 496 example, 1 lỗi. Lỗi ở `authentication_spec.rb:88`: spec chưa biết khóa `einvoice_type` mà `context_resolver.rb` đã trả từ commit trước. Cả hai file đều không đổi trong phần này.
- Sau lần sửa cuối, chạy lại:
  - `spec/workflows/spree/pos/kitchen/`, `workspaces/append_items_spec.rb`, `platform_orders/`, `requests/spree/pos/table_kitchen_spec.rb`, `integration/spree/pos/table_append_race_spec.rb`: 47 example, 0 lỗi.
  - `append_items_spec.rb` (thêm kiểm tra báo bếp sau khi khóa snapshot): 9 example, 0 lỗi.
  - `requests/spree/pos/devices_spec.rb` và `table_kitchen_spec.rb`: 7 example, 0 lỗi.
- Spec phủ định đều có: đơn quầy gọi append trả `not_table_order`, tắt `fnb.tables` trả `module_disabled`, sửa dòng đã báo trả `line_sent`, hủy không duyệt và không có `pos.kitchen.void` trả `approval_required`.
- `packages/pos-shared`: typecheck và lint qua; 271 test qua.
- `apps/pos`: typecheck và lint qua; 278 test qua.
  - `playwright test e2e/table-kitchen-send.spec.ts e2e/tables.spec.ts --project desktop`: 3/3 qua.
  - e2e bán hàng (`fnb-menu`, `fnb-wave1`, `fnb-call-number`, `platform-orders`, `full-retail`, `lease`, `lease-recovery`, `concurrency-chaos`, `catalog-scan`, `scale-labels`, `split-tender`, `inventory-traceability`, `advanced-goods`, `ui-polish`) trên desktop: 54 qua, 3 bỏ qua (cần API thật).
- `apps/pos-dashboard`: typecheck và lint qua; 99 test qua. Không chạy e2e vì cổng 5176 đang bận.
- `apps/pos-staff`: `tool/gen_api.sh` chạy lại; `flutter analyze` không có lỗi; `flutter test` qua 106 test.

**Còn mở**

- **e2e dashboard:** chưa chạy. `e2e/administration.spec.ts` đếm 19 ô quyền, nhưng danh sách đã có 27 quyền từ trước phần này, nay là 28. Cần xem lại khi cổng 5176 rảnh.
- **Xin duyệt hủy món:** hộp hủy món nhận mã duyệt do quản lý cấp (như giảm giá). Chưa có luồng gửi yêu cầu duyệt sang máy quản lý. Approval gắn với `revision`, nên một lần thêm món ở máy khác sẽ làm mã duyệt hết hiệu lực.
- **Dòng đã báo một phần:** khi không giữ lease, dòng đã báo một phần không tăng / giảm được phần chưa gửi. Thêm thì dùng "Thêm ly giống vậy" (ra dòng mới), giảm thì dùng hủy món.
- **Màn sửa `void_reasons`** trên dashboard chưa có.
- **Client Flutter (S2):** mới có client API sinh lại; màn thêm món theo mẻ trên `apps/pos-staff` chưa làm trong phần này.
- **Test chung:** spec `authentication_spec.rb:88` hỏng từ trước, cần thêm `einvoice_type` vào danh sách khóa.
## Phần 8C: App phục vụ, KDS đầy đủ

### Overview

Phần này làm chế độ `waiter` của app Flutter `apps/pos-staff`: phục vụ mở bàn, gọi món kèm modifier, báo bếp, nhận báo "món đã xong", gửi yêu cầu thanh toán, chuyển bàn và in phiếu kiểm đồ.

Song song, chế độ `kds` (đã có bản đầu ở phần 7A) được nâng lên bản đầy đủ:
- nhiều trạm;
- định tuyến cơ bản đến trạm expo;
- gộp theo món (All-day);
- recall;
- báo hết món đồng bộ về S1 và S2;
- dữ liệu "chờ quá lâu" cho báo cáo.

Phần này **không thu tiền** trên app (plan.md D7). Mọi lệnh đi qua các endpoint của phần 8A và 8B. App chỉ hiển thị dữ liệu và gửi lệnh có idempotency key.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Thông báo cho phục vụ chỉ đi qua realtime `BranchChannel` khi app đang mở. Ngoài ra có thông báo cục bộ (`flutter_local_notifications`) khi app chạy nền mà socket còn sống. **Không dùng FCM / APNs**, vì server LAN không ra internet được. Màn mở lại thì luôn refetch, nên không mất trạng thái. |
| Q2 | Phục vụ nhận "món xong" của **bàn mình đang phục vụ**: bàn có `added_by` là mình, hoặc bàn mình đã ghim. Cài đặt trên thiết bị có lựa chọn "nhận của mọi bàn trong khu". |
| Q3 | Trên S2, giỏ món là **bản nháp cục bộ** cho tới khi bấm "Thêm vào đơn". Lúc đó app gọi `append_items` (phần 8B) với `append_batch_id` sinh trên máy, nên gửi lại khi mạng chập chờn không tạo dòng trùng. "Thêm và báo bếp" gọi liên tiếp `append_items` rồi `kitchen_sends`, mỗi lệnh một key. |
| Q4 | All-day là **phép gộp chỉ để hiển thị** trên KDS, theo `variant + modifiers` của các item `new` / `preparing` ở trạm. Không có bảng riêng. Bump trên All-day sẽ bump các item cũ nhất trước (FIFO). |
| Q5 | Trạm expo nhận bản sao "chỉ đọc" của mọi item thuộc ticket mà trạm prep đã bump `ready`. Bump ở expo chuyển item sang `served` và báo cho phục vụ. Course hold/fire, màn chạy bàn riêng và gọi món theo ghế để phần 9A. |
| Q6 | Hết món: KDS hoặc thu ngân bấm "Hết món" thì tạo lệnh `Menu::MarkSoldOut` của phần 6A và phát `menu.sold_out`. S1 và S2 làm mờ món đó và chặn thêm vào giỏ (server vẫn là bên chặn). |
| Q7 | Ngưỡng màu timer theo trạm: `warn_after_seconds` (vàng), `late_after_seconds` (đỏ). Thời gian tính từ `fired_at` của server; thiết bị chỉ cộng độ lệch đồng hồ đo được khi kết nối. |
| Q8 | Phiếu kiểm đồ (`checklist`) liệt kê mọi món của đơn, kèm số lượng đã ra / chưa ra. In qua `PrintJob`, tới trạm in của khu hoặc máy in Bluetooth gắn với thiết bị phục vụ. |

### Dữ liệu

Migration `add_timing_thresholds_and_expo_to_pos_kitchen_stations`:
- `spree_pos_kitchen_stations`: `warn_after_seconds` (mặc định 600), `late_after_seconds` (mặc định 1200), `expo_station_id` (FK tự tham chiếu, nullable: trạm prep đẩy item `ready` về trạm expo này).

Migration `add_recall_and_timing_to_pos_kitchen_ticket_items`:
- `spree_pos_kitchen_ticket_items`: `recalled_at`, `recall_count`, `ready_at`, `served_at`, `prep_seconds` (tính khi `ready`), `late` (boolean, tính khi `ready`). Index `(station_id, status, fired_at)`.

Migration `create_spree_pos_device_table_pins`:
- `spree_pos_device_table_pins`: `device_id`, `resource_id`. Unique cặp. Dùng cho Q2.

### Server

- `Kitchen::Bump` mở rộng: chuyển `new → preparing → ready → served`, cho phép bump theo item, theo ticket hoặc theo All-day (Q4). Mỗi bước ghi giờ server và phát `kitchen_ticket.updated`.
- `Kitchen::Recall`: đưa item `ready` / `served` (trong N phút cuối, mặc định 30) về `preparing`, tăng `recall_count`, audit.
- `Kitchen::Board.for(station)`: dữ liệu cho KDS với ba tab: Ưu tiên (theo `fired_at`, ticket trễ lên đầu), Theo món (All-day), Theo bàn. Có lọc theo `service_mode`. Một truy vấn gộp.
- `Kitchen::ReadyFeed.for(device)`: item vừa `ready` / `served` của các bàn theo Q2, dùng cho thông báo của S2.
- `Reports::KitchenTiming`: thời gian chế biến trung bình và p90 theo trạm / món / giờ, số item trễ. Dữ liệu này dùng cho báo cáo ở phần 12C.
- `Tables::Pin` / `Unpin` cho thiết bị phục vụ.
- Endpoint mới dưới `/api/v3/admin/pos/`: `kitchen/stations/:id/board`, `kitchen/items/:id/bump|recall`, `kitchen/stations/:id/all_day/bump`, `devices/current/ready_feed`, `devices/current/table_pins`, `workspaces/:id/checklist` (tạo `PrintJob` loại `checklist`). Cập nhật OpenAPI rồi sinh lại client Dart.
- Quyền:
  - thiết bị `kds` / `expo` gọi bump / recall bằng danh tính máy (phase 2), không cần nhân viên đăng nhập;
  - thiết bị `waiter` cần nhân viên đăng nhập bằng PIN có `pos.table.serve`.

### App Flutter (`apps/pos-staff`)

Chế độ `waiter`:
- **Danh sách bàn**: lưới ô lấy từ `resource_board` (phần 8A), có lọc theo khu và theo trạng thái (Trống / Có khách / Chờ món / Yêu cầu thanh toán / Của tôi). Ô hiện số khách, phút ngồi, số món chờ.
- **Mở bàn**: nhập số khách bằng bàn phím số lớn. Bàn có hai đơn thì chọn đơn A / B.
- **Gọi món**: tab danh mục, tìm kiếm, ô món có ảnh nếu có. Chạm vào món mở bảng modifier (min/max, bắt buộc, giá cộng; dùng lại định nghĩa của phần 6A) với ô ghi chú. Giỏ ở đáy màn có "Thêm vào đơn" và "Thêm và báo bếp".
- **Đơn của bàn**: dòng đã báo bếp có trạng thái từng món (mới / đang làm / xong / đã ra). Giảm món đã báo bếp mở hộp hủy món có lý do; nếu thiếu quyền thì hiện "Chờ quản lý duyệt" kèm mã yêu cầu `Approval`.
- **Hành động**: Báo bếp, Yêu cầu thanh toán, Chuyển bàn, Gộp bàn, In phiếu kiểm đồ, In tạm tính (lần đầu; in lại cần duyệt).
- **Thông báo**: băng "Bàn 5: Phở bò ×2 đã xong" kèm rung và âm. Chạm vào để mở bàn.
- Xung đột 409 `line_changed` / `snapshot_locked` hiện thông báo dễ hiểu rồi refetch.

Chế độ `kds` (bản đầy đủ):
- Chọn trạm khi ghép thiết bị; một thiết bị xem được nhiều trạm.
- Ba tab Ưu tiên / Theo món / Theo bàn. Ticket hiện số bàn hoặc số gọi, `service_mode`, giờ gửi, timer vàng / đỏ, modifier in đậm, ghi chú, và dòng hủy gạch ngang màu đỏ.
- Bump bằng chạm theo item hoặc cả ticket; giữ lâu để Recall. Có màn "Đã xong gần đây" để recall.
- Nút "Hết món" trên item.
- Màn hình luôn sáng (`wakelock_plus`), chữ lớn, hỗ trợ màn ngang 10–15 inch.

Chế độ `expo` cơ bản: danh sách item `ready` theo bàn; bump sang `served`.

Cấu trúc code: `lib/features/waiter/`, `lib/features/kds/`, `lib/features/expo/`, dùng chung `lib/core/api` (client sinh từ OpenAPI), `lib/core/realtime` và `lib/core/menu` (bảng modifier dùng chung).

### Client web (`apps/pos`)

- Thu ngân thấy yêu cầu thanh toán (phần 8A) và trạng thái món theo dòng giống S2.
- Món hết hàng bị làm mờ trên `menu_grid` và `catalog-search.tsx` khi nhận `menu.sold_out`.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_timing_thresholds_and_expo_to_pos_kitchen_stations.rb`, `*_add_recall_and_timing_to_pos_kitchen_ticket_items.rb`, `*_create_spree_pos_device_table_pins.rb` |
| Tạo / sửa | `server/app/workflows/spree/pos/kitchen/{bump,recall}.rb`, `server/app/services/spree/pos/kitchen/{board,ready_feed}.rb`, `server/app/services/spree/pos/reports/kitchen_timing.rb`, `server/app/workflows/spree/pos/tables/{pin,unpin}.rb` |
| Sửa | `server/app/controllers/spree/api/v3/admin/pos/kitchen_*_controller.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos-staff/lib/features/waiter/**`, `apps/pos-staff/lib/features/kds/**` (mở rộng phần 7A), `apps/pos-staff/lib/features/expo/**`, `apps/pos-staff/lib/core/menu/modifier_sheet.dart`, `apps/pos-staff/lib/l10n/app_{vi,en}.arb` |
| Tạo | `apps/pos-staff/test/features/waiter/**`, `apps/pos-staff/test/features/kds/**`, `apps/pos-staff/integration_test/waiter_flow_test.dart` |
| Sửa | `apps/pos/src/components/{catalog-search,order-lines}.tsx`, `apps/pos/src/hooks/use-realtime.ts` (của phase 3) |

### Các bước

1. Server: ngưỡng trạm, recall, timing, All-day bump, ready feed, ghim bàn; spec cho từng lệnh.
2. Sinh lại client Dart từ OpenAPI; CI kiểm client đã commit khớp file.
3. Waiter: danh sách bàn → mở bàn → gọi món với modifier → thêm vào đơn → báo bếp.
4. Waiter: thông báo món xong, yêu cầu thanh toán, chuyển / gộp bàn, phiếu kiểm đồ, hủy món có duyệt.
5. KDS đầy đủ: ba tab, nhiều trạm, recall, hết món, timer.
6. Expo cơ bản.
7. Web: hiển thị trạng thái món và hết món.
8. Thử trên thiết bị thật: Sunmi (Android) làm KDS, điện thoại Android và iPhone làm S2, cùng server LAN của phần 5B.

### Kiểm thử

- Server: `pnpm spree rspec spec/workflows/spree/pos/kitchen/ spec/services/spree/pos/kitchen/ spec/requests/spree/pos/kitchen_board_spec.rb spec/requests/spree/pos/ready_feed_spec.rb`.
- Flutter (trong `apps/pos-staff`): `flutter analyze`, `flutter test`, `flutter test integration_test/waiter_flow_test.dart` (chạy với server test có seed bàn và thực đơn).
- Spec bắt buộc:
  - bump All-day bump đúng item cũ nhất;
  - recall quá cửa sổ 30 phút bị từ chối;
  - thiết bị `kds` không gọi được `append_items`;
  - phục vụ không có `pos.table.serve` bị 403.
- Đo: từ lúc S2 bấm "Thêm và báo bếp" tới lúc ticket hiện trên KDS ≤ 2 giây trong LAN (dùng log thời gian server và thiết bị).

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| iOS ngắt socket khi app chạy nền nên phục vụ không nhận báo món xong | Q1: refetch khi mở lại app. Băng "Có n món xong" lấy từ `ready_feed`. Ghi rõ giới hạn trong tài liệu phần 8D. |
| Bảng KDS chậm khi trạm đông ticket | `Board` một truy vấn có index `(station_id, status, fired_at)`; chỉ đẩy sự kiện mỏng, KDS refetch theo trạm. |
| Lệch đồng hồ thiết bị làm timer sai | Timer tính từ giờ server cộng độ lệch đo khi kết nối (Q7). |

### Tiêu chí xong

- [ ] Phục vụ trên Android và iOS mở bàn, gọi món có modifier, báo bếp, và nhận báo món xong trong LAN.
- [x] KDS nhiều trạm có ba tab, timer vàng / đỏ, recall, và hết món đồng bộ về S1 / S2.
- [x] Expo cơ bản chuyển món sang "đã ra" và báo cho phục vụ.
- [x] Phiếu kiểm đồ in qua trạm in hoặc máy in Bluetooth.
- [x] App không có màn hay lệnh thu tiền nào.

### Kết quả

**Đã làm**

- Server:
  - Migration `add_expo_to_pos_kitchen_stations`: `expo_station_id` (FK tự tham chiếu, `on_delete: :nullify`, check không trỏ về chính nó). Model chỉ nhận trạm cùng chi nhánh, loại `expo`.
  - Migration `add_recall_and_timing_to_pos_kitchen_ticket_items`: `recalled_at`, `recall_count`, `prep_seconds`, `late`, check `recall_count` và `prep_seconds` không âm. Index `(kitchen_ticket_id, status)` và index riêng phần cho `ready_at`.
  - Migration `create_spree_pos_device_table_pins`: ghim bàn theo thiết bị, unique cặp `(device_id, resource_id)`, xóa theo thiết bị / bàn.
  - `Kitchen::ChangeItemStatus`:
    - recall nhận item `ready` hoặc `served` trong 30 phút kể từ lúc ra / xong, tăng `recall_count`, xóa giờ xong; quá hạn trả `kitchen_recall_expired`; người recall được audit `kitchen.recall`;
    - lúc `ready` ghi `prep_seconds` (từ lúc gửi) và `late` (quá ngưỡng đỏ của trạm);
    - `bump_all_day` bump item cũ nhất trước (FIFO theo giờ gửi) cho tới đủ số lượng, trả `kitchen_all_day_empty` / `kitchen_all_day_invalid`.
  - `Kitchen::Board` (một truy vấn): nhiều trạm (`station_ids`), lọc `service_mode`, ticket trễ lên đầu, `all_day` gộp theo món + modifier, `expo` gom item `ready` theo đơn (trạm expo thấy món của các trạm đẩy về nó; xem mọi trạm thì thấy mọi món xong).
  - `Kitchen::ReadyFeed`: món `ready` / `served` 30 phút gần nhất của bàn đã ghim, bàn mình thêm món (`added_by`), hoặc mọi bàn của một khu khi hỏi `area_id`.
  - `Tables::Pin` (ghim / bỏ ghim, idempotent), `Workspaces::Checklist` + `Kitchen::ChecklistDocument` (phiếu "PHIẾU KIỂM ĐỒ", mỗi món "Đã ra X · Chưa ra Y", tạo `PrintJob` loại `checklist` khi có máy in).
  - `Reports::KitchenTiming`: trung bình, p90, số item trễ theo trạm / món / giờ.
  - `Workspace#to_pos`: dòng của đơn có bàn thêm `kitchen_status` (số lượng theo trạng thái), một truy vấn gộp.
  - Endpoint: `kitchen/all_day/bump` (admin và device API), `station_ids` / `service_mode` trên hai board, `devices/current/ready_feed`, `devices/current/table_pins` (GET / POST / DELETE), `workspaces/:id/checklist`, và `workspaces/:id/lease` đưa vào hợp đồng.
  - Quyền: thiết bị `kds` / `expo` / máy khác (`Device::MACHINE_MODES`) có phiên nhân viên chỉ gọi được context và hết món, mọi lệnh admin khác trả 403 `device_mode_forbidden`. `ready_feed` / ghim bàn chỉ cho thiết bị `waiter` có người mang `pos.table.serve`.
- OpenAPI `pos-staff.yaml`: schema và path mới; thêm `Workspace.lease_generation`. Đã sinh lại client Dart `pos_api`, không có `InlineObject`.
- `apps/pos-staff`:
  - Chế độ `waiter` (`lib/modes/waiter/`):
    - lưới bàn từ `resource_board`, lọc theo khu và trạng thái (Tất cả / Trống / Có khách / Chờ món / Yêu cầu thanh toán / Của tôi), ô hiện số khách, phút ngồi, số món chờ; giữ lâu một bàn để ghim hoặc mở đơn thứ hai;
    - mở bàn bằng bàn phím số lớn; bàn có nhiều đơn thì chọn đơn A / B;
    - gọi món: tab danh mục, tìm kiếm, ảnh món, món hết bị làm mờ và không vào giỏ (đọc lại menu khi có `menu.sold_out`);
    - bảng modifier dùng chung `lib/core/menu/modifier_sheet.dart`: biến thể, min / max, bắt buộc, giá cộng, số lượng tùy chọn, ghi chú;
    - giỏ cục bộ với "Thêm vào đơn" và "Thêm và báo bếp". `append_batch_id` giữ nguyên khi gửi lại cùng giỏ, đổi khi giỏ đổi;
    - đơn của bàn: trạng thái từng dòng (chưa báo bếp / mới / đang làm / xong / đã ra), báo bếp, xóa dòng chưa gửi, hủy món đã gửi có lý do;
    - thiếu quyền hủy thì hiện "Chờ quản lý duyệt" kèm ô mã duyệt; khi có `approval.requested` của đơn này trên kênh chi nhánh thì mã tự điền và lệnh tự gửi lại;
    - hành động: yêu cầu thanh toán, chuyển bàn, gộp bàn (lấy lease trước), in phiếu kiểm đồ, in tạm tính. Máy in Bluetooth gắn với chính điện thoại thì in tại máy; máy khác thì tạo print job; không có máy in thì hiện phiếu dạng chữ;
    - băng "Bàn 5: Phở bò ×2 đã xong" kèm rung và âm, chạm để mở bàn; lần tải đầu không reo lại món cũ. Có lựa chọn "Mọi bàn trong khu …" (lưu trên máy). Mở lại app thì đọc lại bàn và feed;
    - 409 `line_changed` / `snapshot_locked` hiện câu dễ hiểu rồi đọc lại đơn.
  - KDS: chọn một hay nhiều trạm (lưu trên máy, trạm đầu lưu lên server), lọc kiểu phục vụ, tab "Theo món" đọc `all_day` của server với "Xong 1" / "Xong hết (n)", modifier in đậm, món hủy gạch ngang màu đỏ, "Đã xong gần đây" recall được cả món đã ra, giữ lâu một món để Recall hoặc "Hết món" cho đúng món đó.
  - Expo: màn riêng liệt kê món `ready` theo bàn / đơn với timer, "Đã ra món" từng món và "Ra cả đơn".
  - l10n vi / en, `PrinterProfile.fromPrinter`.
  - Test: `test/modes/waiter/` (cart, rule modifier, lọc bàn, ready watcher, màn gọi món, đơn bàn, hủy có duyệt, phiếu kiểm đồ, lưới bàn), `test/modes/kds/kds_stations_test.dart` (nhiều trạm, giữ lâu recall / hết món, món hủy, expo). Viết `integration_test/waiter_flow_test.dart` (chưa chạy).
- `apps/pos`: `order-lines` hiện trạng thái bếp từng dòng ("Mới 1 · Xong 1"); `catalog-search` làm mờ và chặn món hết khi chi nhánh bật `fnb.menu` (menu được làm mới bởi `menu.sold_out` như `menu_grid`). Thu ngân đã thấy yêu cầu thanh toán từ phần 8A (`table-actions`, `table-floor`).
- `packages/pos-shared`: kiểu `kitchen_status` cho dòng.

**Lệch so với kế hoạch**

- **Ngưỡng trạm theo phút:** trạm đã có `warn_after_minutes` / `late_after_minutes` từ phần 7A, nên không thêm `warn_after_seconds` / `late_after_seconds`. Migration chỉ thêm `expo_station_id` và có tên `add_expo_to_pos_kitchen_stations`.
- **Index item:** `fired_at` không có; ticket giữ `sent_at` và trạm. Index là `(kitchen_ticket_id, status)` cùng index phần cho `ready_at`.
- **Expo không sao chép item:** bảng expo tính từ `expo_station_id` lúc đọc board. Bump ở expo dùng lệnh `serve` sẵn có.
- **Không có endpoint `items/:id/bump`:** dùng `start` / `ready` / `serve` / `recall` sẵn có. Pin / Unpin là một module với cờ `pinned:`.
- **Recall từ máy KDS không ghi audit**, vì `AuditEntry` cần người. Item vẫn giữ `changed_by` và `recall_count`.
- **`KitchenTiming`** là service, chưa có endpoint; phần 12C sẽ đưa lên báo cáo.
- **Phiếu kiểm đồ trả cả tài liệu,** để máy in Bluetooth của điện thoại in tại chỗ.
- **`station_ids`** truyền dạng chuỗi phân cách dấu phẩy (tối đa 20 trạm).
- **Thêm path lease** và `Workspace.lease_generation` vào hợp đồng, vì chuyển / gộp bàn cần lease.
- **Thư mục code:** giữ quy ước sẵn có `lib/modes/<mode>/` và `test/modes/` thay cho `lib/features/`. Test expo nằm cùng `test/modes/kds/kds_stations_test.dart` để dùng chung fixture.
- **Duyệt hủy món trên S2** theo cùng cách như web: quản lý cấp mã. Điện thoại tự nhận mã qua `approval.requested`; chưa có luồng quản lý nhập PIN ngay trên điện thoại.
- **Lý do hủy** trên S2 dùng bốn lý do mặc định cộng "Khác"; context thiết bị chưa trả `void_reasons` của chi nhánh.

**Lệnh và kết quả**

- Server:
  - Một lượt rộng trước khi làm phần Flutter (spec của mọi file server đã đổi và thư mục kitchen): 234 example, 0 lỗi.
  - Sau lần sinh client cuối: `pnpm spree rspec spec/requests/spree/pos/devices_spec.rb spec/requests/spree/pos/ready_feed_spec.rb spec/services/spree/pos/print_documents_spec.rb`: 24 example, 0 lỗi.
  - Cuối cùng: `pnpm spree rspec spec/workflows/spree/pos/kitchen/ spec/services/spree/pos/kitchen/ spec/services/spree/pos/reports/kitchen_timing_spec.rb spec/requests/spree/pos/kitchen_board_spec.rb spec/requests/spree/pos/ready_feed_spec.rb spec/requests/spree/pos/devices_spec.rb`: 42 example, 0 lỗi.
  - Spec bắt buộc đều có: All-day bump đúng item cũ nhất; recall quá 30 phút bị từ chối; thiết bị `kds` gọi `items/append` trả 403 `device_mode_forbidden`; phục vụ không có `pos.table.serve` bị 403.
  - rubocop sạch trên file mới. Lỗi còn lại ở `workspace.rb`, `setup.rb`, `routes.rb`, `base_controller.rb` có từ trước.
- `apps/pos-staff`: `tool/gen_api.sh` chạy lại; `flutter analyze` không có lỗi; `flutter test` qua 122 test.
- `apps/pos`: lint, typecheck qua; 280 test qua. `playwright test e2e/table-kitchen-send.spec.ts --project desktop` (thêm kiểm tra trạng thái bếp từng dòng) và `e2e/ui-polish.spec.ts --project desktop`: 2/2 qua.
- `packages/pos-shared`: lint, typecheck qua; 271 test qua.
- `apps/pos-dashboard`: không đổi code; typecheck qua. Không chạy e2e vì cổng 5176 đang bận.

**Còn mở**

- **Thử trên thiết bị thật** (bước 8): chưa làm, vì không có máy ảo hay thiết bị. Gồm Sunmi làm KDS, Android / iPhone làm S2, `integration_test/waiter_flow_test.dart` và kiểm tra Bluetooth của phiếu kiểm đồ. Vì vậy tiêu chí đầu chưa đánh dấu.
- **Đo "Thêm và báo bếp" tới KDS ≤ 2 giây** trong LAN: chưa đo.
- **Thông báo cục bộ khi app chạy nền** (`flutter_local_notifications`, Q1): chưa thêm gói. Hiện app báo bằng băng, rung và âm khi đang mở, và đọc lại feed khi mở lại.
- **Dashboard:** chưa có ô chọn "trạm expo" trên form trạm bếp; API đã nhận `expo_station_id`.
- **Báo cáo:** `Reports::KitchenTiming` chưa có endpoint / màn (phần 12C).
- **Mã duyệt hủy món** gắn với `revision`: một lần thêm món ở máy khác làm mã hết hiệu lực, như ở web.

## Phần 8D: Mở ngành đợt 2

### Overview

Phần này chốt đợt F2. Ba hồ sơ ngành chuyển sang dùng được, có cấu hình thiết bị và trạm hướng dẫn sẵn, có kịch bản e2e chạy chung S1 + S2 + S3, có tài liệu cho chủ quán và kế hoạch phát hành:

- **quán ăn có bàn** (`quan_an` bật thêm phần bàn);
- **nhà hàng cơ bản** (`nha_hang`);
- **bar dạng bàn** (`bar_pub_club`).

Tính năng nâng cao của nhà hàng và bar (expo / course / ghế / buffet / đặt bàn, tab, gửi rượu) nằm ở phần 9A và 9B.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | `quan_an` đã mở ở phần 7D cho kiểu trả trước. Hồ sơ có thêm khóa `optional_modules: [resources, fnb.tables, fnb.postpay, fnb.service_charge]`. Wizard và trang Mô hình kinh doanh hỏi "Quán có bàn phục vụ không?"; trả lời có thì bật các module đó qua đúng đường `BranchModules` đã có (có audit `branch_module.change`). `optional_modules` không ảnh hưởng `status` của hồ sơ. |
| Q2 | `bar_pub_club` thêm `resources` và `fnb.tables` vào `modules` để bán theo bàn ở đợt này. `tab_list` và các module riêng của bar đến ở phần 9B. |
| Q3 | `display.surface` của hồ sơ: `nha_hang` → `floor_plan`; `bar_pub_club` → `table_grid`; `quan_an` → `menu_grid`, chuyển sang `table_grid` khi bật bàn. Validator của `BusinessProfiles` thêm khóa `surface`, với giá trị thuộc `menu_grid|table_grid|floor_plan|resource_board|tab_list`. |
| Q4 | Hồ sơ vẫn không tự bật cờ rủi ro (plan.md D9). `recommended_features` của ba hồ sơ chỉ là gợi ý: `vietqr`, `customer_display`, `credit` (quán ăn). |
| Q5 | Wizard **bắt chọn quầy ghi sổ cho bàn** (`Branch.table_register_id`, phần 8A) khi bật `fnb.tables`, và tạo sẵn trạm `Bếp` + `Bar` với `StationRoute` mặc định theo danh mục món. Quản lý sửa lại được. |
| Q6 | Phát hành theo cờ module: chi nhánh chưa bật module F2 không thấy gì mới. Không cần cờ phát hành riêng. |

### Dữ liệu

- Không thêm bảng.
- `server/config/pos/business_profiles.yml`: cập nhật `quan_an`, `nha_hang`, `bar_pub_club` theo Q1–Q4, gồm `display.surface`, `branch_defaults` (`service_charge_rate` gợi ý 5% cho `nha_hang`, để trống ở hai hồ sơ còn lại) và `optional_modules`. Tăng `version` của file.

### Server

- `Spree::Pos::BusinessProfiles`: đọc và validate `optional_modules` (module đã đăng ký, không trùng `modules`) và `display.surface`.
- `Onboarding` / `Profiles::Apply`: nhận thêm `answers: { has_tables: true }`. Khi `has_tables` thì bật `optional_modules`, yêu cầu `table_register_id`, tạo `KitchenStation` mặc định và `StationRoute` theo danh mục. Mọi việc chạy trong một transaction và idempotent theo key như hiện tại.
- Diff hồ sơ (plan bán lẻ D7) hiện thêm các module tùy chọn và trạm mặc định để người dùng chọn áp.
- Seed demo `server/db/seeds/pos_fnb_demo.rb`, chạy bằng `pnpm spree seed` với `POS_FNB_DEMO=1`: 2 khu, 12 bàn, 30 món có modifier, 2 trạm, 1 máy in giả lập `escpos_lan` tới `127.0.0.1:9100`. Seed chỉ chạy ở development.

### Client

- Web `apps/pos`: wizard và trang Mô hình kinh doanh có câu hỏi bàn và chọn quầy ghi sổ; bỏ nhãn "Sắp hỗ trợ" của ba hồ sơ.
- Flutter `apps/pos-staff`: màn đầu tiên sau khi ghép thiết bị hiện danh sách kiểm tra: máy in đã nhận, trạm đã chọn, nhân viên có PIN.

### Kịch bản e2e S1 + S2 + S3

`server/spec/integration/spree/pos/fnb_wave2_scenario_spec.rb` (API, không UI) và `apps/pos/e2e/fnb-wave2.spec.ts` (web, kèm hai client API giả làm S2 và S3):

1. Quản lý chọn hồ sơ `nha_hang`, có bàn, chọn quầy ghi sổ.
2. Thu ngân mở ca. Phục vụ (S2) mở bàn 5 với 4 khách và gọi đợt 1: phở ×2 (bếp), trà đá ×4 (bar).
3. KDS bếp và bar nhận đúng món; bump xong; S2 nhận `ready`.
4. Phục vụ gọi đợt 2; báo bếp chỉ gửi phần thêm. Hủy 1 phở chưa làm có lý do và duyệt; trạm bếp nhận phiếu hủy.
5. Phục vụ yêu cầu thanh toán; thu ngân thấy yêu cầu, in tạm tính, thu tiền VietQR / tiền mặt.
6. Đơn complete; bàn về trống; báo cáo có phí phục vụ và thuế theo món.

Kịch bản Flutter `apps/pos-staff/integration_test/wave2_waiter_kds_test.dart` chạy bước 2–4 trên emulator với server test.

### File

| Hành động | File |
|---|---|
| Sửa | `server/config/pos/business_profiles.yml`, `server/app/services/spree/pos/business_profiles.rb`, `server/app/workflows/spree/pos/onboarding/*.rb`, `server/app/workflows/spree/pos/profiles/*.rb` |
| Tạo | `server/db/seeds/pos_fnb_demo.rb`, `server/spec/integration/spree/pos/fnb_wave2_scenario_spec.rb` |
| Sửa | `apps/pos/src/components/setup/*`, `apps/pos/src/pages/settings/*business-model*`, `apps/pos/src/locales/*` |
| Tạo | `apps/pos/e2e/fnb-wave2.spec.ts`, `apps/pos-staff/integration_test/wave2_waiter_kds_test.dart`, `apps/pos-staff/lib/features/setup/device_checklist.dart` |
| Tạo | `docs/pos/fnb-ban-va-tra-sau.md` (hướng dẫn chủ quán: sơ đồ bàn, trạm, máy in, ghép thiết bị phục vụ / bếp, giới hạn iOS chạy nền) |

### Các bước

1. Cập nhật YAML và validator; spec `business_profiles_spec` khẳng định ba hồ sơ `available`, còn `karaoke_bida` vẫn `coming_soon` cho tới phần 11A.
2. Câu hỏi bàn trong onboarding / áp hồ sơ, trạm mặc định.
3. Seed demo.
4. Kịch bản API, rồi e2e web, rồi integration Flutter.
5. Tài liệu `docs/pos/fnb-ban-va-tra-sau.md`, có liên kết từ README docs nếu đã có mục POS.
6. Chạy thử trên phần cứng thật: một Sunmi làm thu ngân + trạm in, một tablet Android làm KDS, một iPhone và một điện thoại Android làm S2, một máy in ESC/POS LAN ở bếp, server LAN của phần 5B.

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/business_profiles_spec.rb spec/workflows/spree/pos/onboarding/ spec/integration/spree/pos/fnb_wave2_scenario_spec.rb`.
- Hồi quy toàn bộ: `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`.
- Web: `pnpm --dir apps/pos lint`, `typecheck`, `test`, `test:e2e`.
- Flutter: `flutter analyze`, `flutter test`, `flutter test integration_test`, build `apk` và `ios --no-codesign`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Chi nhánh `quan_an` trả trước đang chạy bị đổi màn bán khi cập nhật hồ sơ | Diff hồ sơ không tự áp (plan bán lẻ D7); bật bàn là lựa chọn chủ động. |
| Chủ quán quên tạo trạm / máy in, nên món không tới bếp | Q5 tạo trạm mặc định. Báo bếp khi trạm không có KDS và không có máy in trả cảnh báo rõ, không lặng lẽ bỏ qua. |
| Giới hạn chạy nền trên iOS | Ghi rõ trong tài liệu; khuyến nghị Android cho máy phục vụ dùng chung. |

### Tiêu chí xong

- [ ] `quan_an` (có bàn), `nha_hang`, `bar_pub_club` chọn được trong wizard và tạo được chi nhánh.
- [ ] Kịch bản 6 bước xanh ở API, e2e web và integration Flutter.
- [ ] Chạy thử trên phần cứng thật không lỗi chặn; các lỗi nhỏ ghi lại trong phase.
- [ ] Tài liệu cho chủ quán đã có và liên kết đúng.
- [ ] Chi nhánh bán lẻ và chi nhánh đợt 1 không đổi hành vi.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
