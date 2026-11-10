---
phase: 14
title: "Nhiều máy cùng sửa đơn, báo bếp theo phần chênh lệch"
status: pending
effort: "7 ngày"
dependsOn: [9, 13]
---

# Phase 14: Nhiều máy cùng sửa đơn, báo bếp theo phần chênh lệch

## Overview

Hiện mỗi workspace chỉ có một người giữ lease 120 giây (`Workspace::LEASE_TTL`). Mọi lệnh dòng hàng kiểm tra cùng lúc ba thứ: lease còn hạn, `lease_generation` khớp và `revision` khớp (`ManageLineItem.validate_command!`). Ở nhà hàng, hai phục vụ và một thu ngân có thể cùng thêm món vào một bàn trong một phút. Với luật hiện tại, hai trong ba người sẽ bị 409.

Phase này làm bốn việc:
- cho **thêm món** vào đơn tại bàn mà không cần lease;
- cho sửa / xóa **dòng chưa báo bếp** theo phiên bản của từng dòng;
- thêm lệnh "Báo bếp" chỉ gửi phần chênh lệch kể từ lần gửi trước và tạo ticket bất biến;
- quy định hủy món đã báo bếp phải có lý do và duyệt.

Đây là thay đổi lớn nhất ở lõi trong toàn plan (research §9.1), nên phải chạy lại toàn bộ bộ test race.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Lease **vẫn giữ** cho các lệnh đổi tiền cấp đơn: giảm giá đơn / dòng, đổi giá, khách hàng, phí, tender, complete. Chỉ ba lệnh mới được chạy không cần lease, và chỉ trên đơn có `resource_id` khi module `fnb.tables` bật: `append_items`, `edit_unsent_line`, `remove_unsent_line`. Đơn quầy giữ nguyên luật cũ. |
| Q2 | `append_items` nhận một **mẻ** dòng (một lần bấm "Thêm vào đơn" trên S2) và không kiểm tra `revision` của workspace, vì phép thêm giao hoán với nhau. Lệnh vẫn chạy dưới khóa workspace của `CommandExecutor`, vẫn gọi `ensure_snapshot_editable!` và tăng `revision`. Mỗi mẻ luôn tạo SaleLine mới; chỉ gộp với dòng **chưa báo bếp do chính mẻ đó tạo** (cùng `merge_key`). Không gộp vào dòng của người khác hay dòng đã báo bếp. |
| Q3 | Sửa / xóa dòng chưa báo bếp kiểm tra `SaleLine.row_version` (cột mới, tăng mỗi lần dòng đổi) thay cho `revision` của workspace. Lệch phiên bản trả 409 `reason: 'line_changed'` kèm dòng hiện tại. Không đụng đến dòng của người khác thì không bị chặn. |
| Q4 | Mỗi SaleLine có `kitchen_sent_quantity`. Ở phase 9, đơn trả trước gửi bếp nguyên đơn khi complete. Cột này do phase 9 thêm; phase này dùng nó để "Báo bếp" gửi phần chênh lệch `sale_quantity − kitchen_sent_quantity` (snapshot "đã gửi", như `last_order_preparation_change` của Odoo). |
| Q5 | `Kitchen::Send` là lệnh idempotent theo key. Mỗi lần chạy tạo một bản ghi `KitchenSend` có `sequence` tăng dần theo workspace, rồi tách theo `StationRoute` thành các `KitchenTicket` bất biến (một ticket cho mỗi trạm). Gửi khi không có chênh lệch trả 200 với `ticket_count: 0`, không tạo bản ghi rỗng. |
| Q6 | Giảm số lượng dòng **đã báo bếp** là lệnh riêng `Kitchen::VoidSent`. Lệnh cần lý do (danh sách lý do theo chi nhánh, có "khác" kèm ghi chú), và cần `Approval` action `kitchen.void_sent` khi người làm không có capability `pos.kitchen.void`. Lệnh giảm `quantity` và `kitchen_sent_quantity` cùng lúc, tạo ngay `KitchenTicket` loại `void` và `PrintJob` loại `void_ticket`. Món đã ở trạng thái `ready` / `served` thì vẫn hủy được nhưng ghi `wasted: true` để báo cáo hao hụt; **không nhập lại kho** (research §9.2). |
| Q7 | Sau khi đơn có tiền (snapshot khóa), mọi lệnh thêm / sửa đều bị chặn như hiện tại. Khách gọi thêm sau khi đã trả một phần thì tạo **đơn bổ sung** cho cùng bàn (`Tables::Open` với `table_label` kế tiếp). Không nới bất biến khóa snapshot. |
| Q8 | Lệnh mở rộng / tách / gộp bàn ở phase 13 chuyển nguyên SaleLine, kể cả `kitchen_sent_quantity` và `row_version`, nên báo bếp sau khi chuyển không gửi trùng. |

## Dữ liệu

Migration `track_line_versions_on_pos_sale_lines` (`kitchen_sent_quantity` đã có từ phase 9; phase này thêm check `kitchen_sent_quantity ≤ sale_quantity` sau khi trừ void):
- `spree_pos_sale_lines`: `row_version` (int, mặc định 0), `added_by_id` (staff), `added_device_id` (nullable), `append_batch_id` (uuid, nullable).

Migration `create_spree_pos_kitchen_sends_and_voids`:
- `spree_pos_kitchen_sends`: `workspace_id`, `sequence`, `staff_id`, `device_id`, `command_receipt_id`. Unique `(workspace_id, sequence)`.
- `spree_pos_kitchen_tickets`: thêm `kitchen_send_id` (nullable cho ticket trả trước ở phase 9) (`kind` `fire|void` đã có từ phase 9).
- `spree_pos_kitchen_voids`: `sale_line_id`, `quantity`, `reason_code`, `note`, `staff_id`, `approval_id`, `wasted`, `kitchen_ticket_id`.
- `spree_pos_branches.void_reasons` (jsonb, mặc định `["khach_doi_y","het_mon","nhap_nham","lam_hong"]`).

## Server

- `Workspaces::AppendItems` (`app/workflows/spree/pos/workspaces/append_items.rb`): nhận `items: [{variant_id, quantity, modifiers, note, course?, seat?}]` và `append_batch_id`. Bên trong dùng lại phần dựng dòng của `ManageLineItem.add` (tách thành `LineBuilder` dùng chung, không sao chép), nhưng thay `validate_command!` bằng `validate_append!`. Hàm mới kiểm tra: đơn `editing`/`parked`, có `resource_id`, `AccessPolicy#can_edit_workspace?`, module `fnb.tables` bật, `ensure_snapshot_editable!`. Lệnh trả về workspace và danh sách SaleLine đã tạo.
- `Workspaces::EditUnsentLine` / `RemoveUnsentLine`: kiểm tra `row_version`, từ chối khi `kitchen_sent_quantity > 0` với `reason: 'line_sent'` và gợi ý dùng void.
- `Kitchen::Send` (`app/workflows/spree/pos/kitchen/send.rb`): khóa workspace, tính chênh lệch, gọi router trạm của phase 9 và tạo ticket. Cập nhật `kitchen_sent_quantity`, phát `kitchen_ticket.updated` và `workspace.updated`, tạo `PrintJob` cho trạm dùng máy in.
- `Kitchen::VoidSent` (`.../kitchen/void_sent.rb`): như Q6. Audit `kitchen.void_sent` kèm số lượng, lý do và người duyệt.
- `Approval`: thêm action `kitchen.void_sent`. Approval gắn vào Workspace và `revision`, nên Workspace vẫn là `SUBJECTS`.
- Capability mới: `pos.kitchen.void` (hủy món đã báo bếp không cần duyệt).
- `CommandExecutor`: không đổi. Lệnh không cần lease vẫn có idempotency key; replay cùng key trả cùng kết quả.
- `Workspace#to_pos` mỗi dòng thêm `kitchen_sent_quantity`, `row_version`, `pending_kitchen_quantity`, `added_by`. Đơn có thêm `kitchen_sends` (sequence, giờ, người).
- Thêm lịch sử báo bếp: `GET workspaces/:id/kitchen_history` gồm giờ, người, món tăng / giảm (học từ KiotViet "Lịch sử báo bếp").
- OpenAPI: `POST workspaces/:id/items:append`, `PATCH .../sale_lines/:id` (có `row_version`), `DELETE .../sale_lines/:id`, `POST workspaces/:id/kitchen_sends`, `POST sale_lines/:id/kitchen_voids`, `GET .../kitchen_history`.

## Client web (`apps/pos`)

- Đơn tại bàn: dòng đã báo bếp có nhãn "Đã báo bếp ×n"; phần chưa gửi hiện rõ. Nút **Báo bếp** hiện số món sẽ gửi.
- Giảm số lượng dòng đã báo bếp mở hộp hủy món: chọn lý do, ghi chú, và xin duyệt nếu thiếu quyền (dùng lại luồng `Approval` đang có của giảm giá).
- 409 `line_changed`: refetch, giữ phần người dùng vừa nhập nếu áp lại được, và hiện thông báo "Dòng này vừa được người khác sửa". 409 `line_sent`: mở hộp hủy món.
- Thu ngân không cần lease để thêm món vào bàn, nhưng nút giảm giá / thanh toán vẫn đi theo lease như hiện tại.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_track_kitchen_sent_quantity_on_pos_sale_lines.rb`, `*_create_spree_pos_kitchen_sends_and_voids.rb` |
| Tạo | `server/app/workflows/spree/pos/workspaces/{append_items,edit_unsent_line,remove_unsent_line}.rb`, `server/app/services/spree/pos/line_builder.rb`, `server/app/workflows/spree/pos/kitchen/{send,void_sent}.rb`, `server/app/models/spree/pos/{kitchen_send,kitchen_void}.rb` |
| Sửa | `server/app/workflows/spree/pos/workspaces/manage_line_item.rb` (tách `LineBuilder`), `server/app/models/spree/pos/{sale_line,workspace,approval,capabilities,branch}.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `server/spec/integration/spree/pos/table_append_race_spec.rb`, `server/spec/workflows/spree/pos/kitchen/{send,void_sent}_spec.rb`, `server/spec/workflows/spree/pos/workspaces/append_items_spec.rb` |
| Sửa | `apps/pos/src/components/{order-lines,workspace-tabs}.tsx`; tạo `apps/pos/src/components/{kitchen-send-button,void-item-dialog,kitchen-history}.tsx` |

## Các bước

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

## Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/workspaces/ spec/workflows/spree/pos/kitchen/ spec/integration/spree/pos/`.
- Hồi quy đầy đủ: `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`.
- Spec phủ định:
  - đơn quầy gọi `append_items` trả 409 `module_disabled` hoặc `not_table_order`;
  - sửa dòng đã báo bếp bằng `edit_unsent_line` trả `line_sent`;
  - hủy món đã báo bếp không có duyệt và không có `pos.kitchen.void` trả `approval_required`.
- Web: `pnpm --dir apps/pos typecheck`, `test`, `test:e2e` (thêm `e2e/table-kitchen-send.spec.ts`: hai tab trình duyệt cùng thêm món vào một bàn rồi báo bếp).

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Tách `LineBuilder` làm đổi hành vi bán lẻ (cân, lô, serial) | Bước 1 tách riêng, có commit riêng và chạy toàn bộ spec trước khi thêm lệnh mới. |
| Thêm món không cần lease mà chạy cùng lúc với tender của thu ngân | Khóa workspace của `CommandExecutor` tuần tự hóa hai lệnh. `ensure_snapshot_editable!` chạy trong khóa. Có spec race. |
| Báo bếp gửi trùng khi mạng chập chờn | Idempotency key và `kitchen_sent_quantity` cập nhật trong cùng transaction. |
| Hủy món bị lạm dụng | Lý do bắt buộc, duyệt theo quyền, audit, báo cáo hủy món theo nhân viên (phase 24 đọc). |

## Tiêu chí xong

- [ ] Hai phục vụ và một thu ngân cùng thêm món vào một bàn mà không ai bị 409.
- [ ] "Báo bếp" chỉ gửi phần chênh lệch; gửi lại cùng key không tạo ticket mới.
- [ ] Hủy món đã báo bếp có lý do, duyệt theo quyền, phiếu hủy in ở trạm, và có audit.
- [ ] Đơn đã có tiền không sửa được; gọi thêm đi vào đơn bổ sung.
- [ ] Toàn bộ spec bán lẻ, `workspace_race_spec` và e2e bán hàng vẫn xanh.
