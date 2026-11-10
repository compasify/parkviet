---
phase: 13
title: "Bàn, khu vực, trả sau, phí phục vụ"
status: pending
effort: "8 ngày"
dependsOn: [12]
---

# Phase 13: Bàn, khu vực, trả sau, phí phục vụ

## Overview

Phase này đưa vào bốn module của đợt F2: `resources` (khu vực và bàn/phòng), `fnb.tables` (mở bàn, nhiều đơn trên một bàn, chuyển / gộp / tách), `fnb.postpay` (trả sau, yêu cầu thanh toán, tạm tính có quyền) và `fnb.service_charge` (phí phục vụ là dòng chịu thuế). Thu ngân web có thêm hai màn bắt đầu là `table_grid` và `floor_plan`, cùng trang sửa sơ đồ bàn trong cài đặt.

Phase này chưa cho nhiều máy cùng sửa một đơn: phase 14 lo phần đó. Ở đây, bàn vẫn được sửa theo lease hiện có, nhưng **chủ thể sửa đơn không còn bắt buộc là chủ ca** (xem Q2), vì phục vụ không mở ca.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Bàn là `Resource`, không phải Workspace. Đơn đang mở của bàn là các Workspace có `resource_id` = bàn đó, `service_mode = 'dine_in'` và `operational_status` thuộc `editing` / `parked`. Trạng thái bàn **được tính** từ các đơn đó, không lưu. Riêng `cleaning` và `out_of_service` là trạng thái lưu tay. |
| Q2 | Hiện `ManageLineItem.execute` từ chối nếu `workspace.shift.owner_id != staff.id`. Với đơn tại bàn, quyền sửa sẽ là: chủ ca **hoặc** nhân viên có capability mới `pos.table.serve` ở chi nhánh đó. Đơn tại bàn gắn vào **ca ghi sổ** là ca đang mở của quầy được chọn làm `Branch.table_register_id`. Không có ca nào mở thì từ chối mở bàn với `reason: 'no_open_shift'`. |
| Q3 | Khi thu ngân khác thu tiền, đơn chưa có tiền chuyển sang ca của người thu: mở rộng `ShiftRebind` với lối `rebind_to_collector!`, vẫn chỉ áp dụng khi chưa có `ReceivedFunds`. Đơn đã có tiền thì không chuyển ca (giữ bất biến hiện tại). Đơn qua ca chặn đóng ca như hiện nay. Phase này thêm danh sách "bàn còn mở" vào hộp đóng ca để thu ngân biết vì sao bị chặn. |
| Q4 | Một bàn có nhiều đơn: mặc định một đơn; nút "Thêm đơn cho bàn" tạo Workspace thứ hai cùng `resource_id`. Có `table_label` (A, B…) để in phiếu. |
| Q5 | Chuyển bàn đổi `resource_id`. Gộp bàn chuyển mọi dòng của đơn nguồn sang đơn đích rồi hủy đơn nguồn. Tách đơn theo món chuyển các dòng đã chọn sang Workspace mới cùng bàn hoặc bàn khác. Cả ba đều từ chối khi đơn nào liên quan đã khóa snapshot (`ensure_snapshot_editable!`). Dòng đã báo bếp giữ `kitchen_sent_quantity` khi chuyển (cột của phase 14; ở phase này chuyển nguyên SaleLine nên không mất). |
| Q6 | Chia đều bill **không tách Order**: tạo nhiều tender trên cùng một đơn, mỗi tender bằng phần chia. Lõi đã cho nhiều TenderAttempt. Chia theo ghế để phase 18. |
| Q7 | Tạm tính (`prebill`) chuyển từ "chỉ in ở client" (`prebill-dialog.tsx` hiện không ghi gì) sang **có ghi nhận ở server**: bảng `spree_pos_prebill_prints`. Lần in đầu không cần duyệt; in lại hoặc hủy tạm tính cần `Approval` với action `workspace.reprint_prebill` / `workspace.cancel_prebill`. Đơn đã in tạm tính mà bị sửa thì tạm tính cũ được đánh dấu `superseded`, và bàn hiện cờ "đã sửa sau tạm tính". |
| Q8 | Phí phục vụ là `Spree::Fee` cấp đơn (giống `Deliveries::Assign`), loại `service_charge`, tính theo % trên tổng món sau giảm giá. Cấu hình theo chi nhánh: `rate`, có áp cho mang đi hay không, `tax_category_id`. Phí phục vụ **chịu thuế** theo tax category đã cấu hình (research §7). |
| Q9 | Yêu cầu thanh toán là lệnh `PaymentRequest` gắn Workspace. Lệnh này phát sự kiện `payment.requested` (plan.md) cho thu ngân và màn khách. Nó không đổi tiền và không khóa snapshot. |

## Dữ liệu

Migration `create_spree_pos_areas_and_resources`:
- `spree_pos_areas`: `store_id`, `branch_id`, `name`, `position`, `status` (`active|archived`), `floor_width`, `floor_height`. Unique `(branch_id, name)` khi active.
- `spree_pos_resources`: `store_id`, `branch_id`, `area_id`, `kind` (check `table|room|billiard|vip`), `name`, `capacity` (int ≥ 0), `shape` (`rect|round`), `x`, `y`, `w`, `h` (int, đơn vị lưới), `rotation`, `manual_status` (`available|cleaning|out_of_service`, mặc định `available`), `resource_type_code` (dùng ở phase 17 để chọn bảng giá), `status` (`active|archived`), `position`. Unique `(branch_id, name)` khi active.

Migration `add_table_service_to_pos_workspaces`:
- `spree_pos_workspaces`: `resource_id` (FK, nullable), `guest_count` (int, nullable, 0–999), `table_label` (string ≤ 4). Index `(resource_id, operational_status)`.
- Validation: đơn có `resource_id` thì `service_mode` phải là `dine_in` hoặc `timed`. `resource_id` **không** nằm trong `source_is_immutable`, vì chuyển bàn cần đổi nó.

Migration `add_table_register_and_service_charge_to_pos_branches`:
- `spree_pos_branches`: `table_register_id` (FK register, nullable), `service_charge_rate` (decimal 5,2, nullable), `service_charge_applies_to` (jsonb mảng service_mode, mặc định `["dine_in"]`), `service_charge_tax_category_id` (nullable).

Migration `create_spree_pos_prebill_prints_and_payment_requests`:
- `spree_pos_prebill_prints`: `workspace_id`, `revision`, `sequence`, `staff_id`, `approval_id` (nullable), `status` (`current|superseded|canceled`), `total`, `currency`. Unique `(workspace_id, sequence)`.
- `spree_pos_payment_requests`: `workspace_id`, `requested_by_id`, `device_id` (nullable), `status` (`open|done|canceled`), `note`. Mỗi workspace có tối đa một request `open` (partial unique index).

## Server

- Model `Spree::Pos::Area`, `Spree::Pos::Resource` (`has_prefix_id :posarea`, `:posres`), `PrebillPrint`, `PaymentRequest`.
- `Spree::Pos::ResourceState.for(branch)` trả về trạng thái tính của từng bàn: `available`, `occupied` (có đơn, chưa báo bếp), `ordered` (đã báo bếp), `waiting_long` (món chờ quá ngưỡng, đọc từ `KitchenTicketItem`), `payment_requested`, `prebilled`, `reserved` (phase 18), `cleaning`, `out_of_service`. Kèm số khách, phút đã ngồi (theo `Workspace.database_now`) và tổng tạm tính. Đọc thành một truy vấn gộp, không N+1.
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
- Module: `resources`, `fnb.tables`, `fnb.postpay`, `fnb.service_charge` chuyển từ `planned` sang `register` trong `config/initializers/pos_modules.rb`. Lệnh của phase kiểm tra `ModulePolicy.require!`.
- Realtime: mọi lệnh bàn phát `resource.updated` và `workspace.updated`; yêu cầu thanh toán phát `payment.requested`.
- Route dưới `/api/v3/admin/pos/`: `areas`, `resources`, `resource_board` (GET trạng thái), `tables/:resource_id/open`, `workspaces/:id/move|merge|split|prebill|payment_request`. Cập nhật `server/openapi/pos-staff.yaml`.

## Client web (`apps/pos`)

- Surface `table_grid`: lưới ô bàn có lọc theo khu và theo trạng thái (Trống / Có khách / Chờ món / Yêu cầu thanh toán). Ô bàn hiện tên, số khách, phút ngồi và tạm tính. Chạm vào ô thì vào đơn; bàn có nhiều đơn thì hiện chọn đơn A / B.
- Surface `floor_plan`: vẽ bàn theo `x, y, w, h, shape` trong khung của khu, có tab tầng / khu. Dùng chung component ô bàn với `table_grid`.
- Màu trạng thái dùng token có sẵn trong `styles/`: trống = trung tính, có khách = xanh, đã báo bếp = xanh đậm, chờ lâu = vàng, yêu cầu thanh toán = đỏ, đã in tạm tính = tím, đang dọn = xám kẻ sọc. Màu luôn đi kèm nhãn chữ hoặc biểu tượng, không truyền nghĩa chỉ bằng màu.
- Thanh công cụ của đơn tại bàn: Chuyển bàn, Gộp bàn, Tách đơn, Tạm tính, Phí phục vụ (bỏ / áp), Thêm đơn cho bàn.
- `prebill-dialog.tsx` gọi `POST workspaces/:id/prebill` trước khi in. Khi in lại thì hiện `credit-approval-dialog` dạng chung để xin duyệt.
- Trang cài đặt `/settings/branches/$branchId/floor-plan`: sửa khu và bàn, kéo thả trên lưới, đặt kích thước và hình. Chỉ hiện khi module `resources` bật (`useBranchModules`).
- Màn bắt đầu chọn theo `display.surface` của hồ sơ ngành (plan bán lẻ đa ngành §display). Thu ngân đổi được giữa `menu_grid`, `table_grid` và `floor_plan`; lựa chọn lưu theo thiết bị.
- Realtime: `resource_board` refetch khi nhận `resource.updated`, `payment.requested` hoặc `workspace.updated`. Không có realtime thì poll mỗi 10 giây.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_create_spree_pos_areas_and_resources.rb`, `*_add_table_service_to_pos_workspaces.rb`, `*_add_table_register_and_service_charge_to_pos_branches.rb`, `*_create_spree_pos_prebill_prints_and_payment_requests.rb` |
| Tạo | `server/app/models/spree/pos/{area,resource,prebill_print,payment_request}.rb`, `server/app/services/spree/pos/resource_state.rb` |
| Tạo | `server/app/workflows/spree/pos/resources/*.rb`, `.../tables/{open,move,merge,split,request_payment,resolve_payment_request}.rb`, `.../workspaces/prebill.rb`, `.../service_charges/apply.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/{areas,resources,resource_boards,tables,prebills,payment_requests}_controller.rb` |
| Sửa | `server/app/models/spree/pos/{workspace,branch,capabilities,approval}.rb`, `server/app/services/spree/pos/{access_policy,shift_rebind}.rb`, `server/app/workflows/spree/pos/workspaces/{manage_line_item,apply_discount,change_status,claim_lease}.rb`, `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos/src/pages/tables.tsx`, `apps/pos/src/components/{table-tile,table-grid,floor-plan,floor-plan-editor,table-actions,split-order-dialog}.tsx`, `apps/pos/src/hooks/use-resource-board.ts`, `apps/pos/src/pages/settings/floor-plan.tsx` |
| Sửa | `apps/pos/src/router.tsx`, `apps/pos/src/components/{prebill-dialog,workspace-tabs,shift-close-dialog,payment-panel}.tsx`, `apps/pos/src/modules/registry.ts`, `apps/pos/src/locales/*` |

## Các bước

1. Migration và model, kèm spec model (ràng buộc kind, unique tên, `resource_id` chỉ với `dine_in` / `timed`).
2. `AccessPolicy#can_edit_workspace?` và thay điều kiện chủ ca trong bốn workflow. Chạy lại toàn bộ spec workspace để chứng minh đơn quầy không đổi hành vi.
3. `Tables::Open` gắn ca ghi sổ; mở rộng `ShiftRebind` cho người thu tiền.
4. Move / merge / split dưới khóa nhiều workspace; spec race cho hai lệnh gộp chéo nhau (A→B và B→A cùng lúc).
5. `ServiceCharges::Apply` và thuế của phí; spec tổng tiền khớp sau mỗi lần thêm / bớt dòng và giảm giá.
6. Tạm tính có ghi nhận và duyệt; yêu cầu thanh toán và sự kiện realtime.
7. `ResourceState` và endpoint `resource_board`, đo số truy vấn (một chi nhánh 80 bàn ≤ 6 truy vấn).
8. Client: hai surface, thanh công cụ, trang sửa sơ đồ, đổi `prebill-dialog`.
9. OpenAPI, i18n vi/en, bật module trong initializer.

## Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/resource_spec.rb spec/workflows/spree/pos/tables/ spec/workflows/spree/pos/service_charges/ spec/requests/spree/pos/tables_spec.rb spec/requests/spree/pos/resource_board_spec.rb spec/requests/spree/pos/prebills_spec.rb`.
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/workspaces/ spec/integration/spree/pos/workspace_race_spec.rb`.
- Spec bắt buộc:
  - nhân viên chỉ có `pos.table.serve` sửa được đơn tại bàn nhưng không sửa được đơn quầy của người khác;
  - đơn có tiền không chuyển ca;
  - gộp bàn từ chối khi một đơn đã khóa snapshot;
  - phí phục vụ có thuế đúng tax category;
  - in lại tạm tính khi không có duyệt trả 409 `approval_required`.
- Web: `pnpm --dir apps/pos typecheck`, `test`, `lint`; e2e `apps/pos/e2e/tables.spec.ts` (mở bàn → gọi món → tạm tính → thu tiền → bàn về trống).

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Nới điều kiện chủ ca mở đường cho nhân viên sửa đơn quầy của người khác | Helper chỉ nới khi `resource_id` có. Spec phủ định cho đơn quầy. |
| Deadlock khi gộp / tách nhiều workspace | Luôn khóa theo `id` tăng dần; spec race với hai kết nối. |
| Phí phục vụ lệch tổng khi giảm giá đổi sau | `ServiceCharges::Apply` chạy trong mọi lệnh đổi tiền; spec bất biến `fee == round(rate × net_item_total)`. |
| Chi nhánh chưa đặt `table_register_id` | Wizard ở phase 16 bắt chọn. Endpoint mở bàn trả `reason: 'table_register_missing'` kèm hướng dẫn. |

## Tiêu chí xong

- [ ] Quản lý tạo khu và bàn, kéo thả sơ đồ, đánh dấu bàn đang dọn.
- [ ] Thu ngân mở bàn, nhập số khách, mở hai đơn trên một bàn, chuyển / gộp / tách đơn.
- [ ] Trạng thái bàn trên `table_grid` và `floor_plan` cập nhật qua realtime (≤ 2 giây) và vẫn chạy khi chỉ có poll.
- [ ] Tạm tính lần đầu in ngay; in lại hoặc hủy cần duyệt và có audit.
- [ ] Phí phục vụ tự tính, chịu thuế, bỏ được có audit.
- [ ] Đơn quầy và toàn bộ spec bán lẻ không đổi hành vi.
