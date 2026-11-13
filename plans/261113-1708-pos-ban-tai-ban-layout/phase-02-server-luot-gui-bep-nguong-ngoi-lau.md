---
phase: 2
title: "Server: lượt gửi bếp trên dòng món, ngưỡng ngồi lâu"
status: completed
effort: "1,5 ngày"
dependsOn: []
---

# Phase 2: Server: lượt gửi bếp trên dòng món, ngưỡng ngồi lâu

## Bối cảnh

Phiếu bàn nhóm món theo lượt gửi bếp ("Lượt 2 · 14:22 · Lan"). Workspace đã trả `kitchen_sends` (sequence, giờ, người gửi), nhưng dòng món chưa cho biết nó thuộc lượt nào. Liên kết đã có trong dữ liệu: `KitchenTicketItem.sale_line_id` → `KitchenTicket.send_key` → `KitchenSend.send_key` (cùng `workspace_id`). Không cần bảng mới.

Bảng bàn cần ngưỡng "ngồi lâu" để vẽ dải đỏ. Board đã trả `seated_minutes`; ngưỡng chưa có. Theo research, ngưỡng do cửa hàng cấu hình.

Project đã eject (`docker-compose.yml` mount `./server:/rails`), nên sửa `server/` có hiệu lực ngay.

## Yêu cầu

1. Mỗi dòng trong `line_items` của workspace có `kitchen_send_sequence: Integer | nil`: sequence nhỏ nhất của các lượt có phiếu bếp `fire` chứa dòng đó; `nil` khi chưa gửi. Tính một lần cho cả workspace (một truy vấn gom nhóm), không N+1.
2. Cột `spree_pos_branches.seated_alert_minutes` (integer, null, mặc định 60, check 10–600). Null nghĩa là tắt cảnh báo.
3. Context POS (`branch.to_pos`) trả `seated_alert_minutes`. `table_settings_controller` cho sửa trường này cùng các thiết lập bàn khác.
4. pos-dashboard, trang `branch-floor-plan.tsx`, thêm ô "Cảnh báo bàn ngồi lâu (phút)" cạnh phí phục vụ.
5. Cập nhật `server/openapi/pos-staff.yaml` cho trường dòng món mới (giữ nguyên tắc 5 của plan F&B).

## File

- Tạo: migration `add_seated_alert_minutes_to_pos_branches` (sinh bằng `pnpm spree generate migration`)
- Sửa: `server/app/models/spree/pos/workspace.rb` (dựng map `sale_line_id → sequence`, truyền vào `SaleLine#to_pos`), `server/app/models/spree/pos/sale_line.rb`, `server/app/models/spree/pos/branch.rb`, `server/app/controllers/spree/api/v3/admin/pos/table_settings_controller.rb`, `server/openapi/pos-staff.yaml`
- Sửa: `packages/pos-shared/src/types/pos-context.ts` (`kitchen_send_sequence?: number | null` trên dòng, `seated_alert_minutes?: number | null` trên branch)
- Sửa: `apps/pos-dashboard/src/pages/branch-floor-plan.tsx` và hook lưu thiết lập bàn tương ứng, locale `vi`/`en`
- Spec: `server/spec/requests/spree/pos/table_kitchen_spec.rb`, `server/spec/requests/spree/pos/tables_spec.rb`

## Các bước

1. Sao lưu DB dev trước khi migrate (quy tắc dự án), rồi tạo và chạy migration bằng `pnpm spree migrate`.
2. Viết spec trước: workspace có hai lượt gửi, dòng của lượt 1 trả 1, dòng gọi thêm sau đó trả 2, dòng chưa gửi trả `nil`, dòng đã hủy vẫn giữ sequence của lượt đã gửi.
3. Cài đặt map trong `Workspace#to_pos` bằng một truy vấn join ba bảng, nhóm theo `sale_line_id`, lấy `MIN(kitchen_sends.sequence)`.
4. Thêm cột, validation, `to_pos`, permit ở controller; spec request cho giá trị hợp lệ, ngoài khoảng và null.
5. Thêm ô nhập ở pos-dashboard, kèm unit test hook nếu hook có test.

## Kiểm tra

```bash
pnpm spree rspec spec/requests/spree/pos/table_kitchen_spec.rb spec/workflows/spree/pos/kitchen/send_spec.rb
pnpm spree rspec spec/requests/spree/pos/tables_spec.rb
pnpm --dir apps/pos-dashboard typecheck
```

Kịch bản `kitchen_send_sequence` đặt trong `table_kitchen_spec.rb` (đã test gửi bếp theo lượt qua API). Chưa có spec model cho workspace hay sale line; kịch bản ngưỡng ngồi lâu đặt trong `tables_spec.rb`, nơi đang test thiết lập phí phục vụ.

## Rủi ro và rollback

- Dòng gửi một phần qua nhiều lượt: lấy lượt đầu tiên là đủ cho nhóm hiển thị, vì món gọi thêm luôn tạo dòng mới theo lô (`append_items`).
- Rollback: revert commit và chạy `pnpm spree rails db:rollback` một bước; cột mới nullable nên không mất dữ liệu cũ.
