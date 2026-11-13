---
phase: 10
title: "Sửa số khách của bàn đang mở"
status: pending
effort: "0,5 ngày"
dependsOn: [5]
---

# Phase 10: Sửa số khách của bàn đang mở

## Bối cảnh

Số khách chỉ ghi được lúc mở bàn (`Tables::Open`), đặt bàn (`Reservations::Seat`) hoặc tách bàn (`Tables::Split`). Không có lệnh sửa, nên chip số khách ở đầu phiếu (`ticket-header.tsx`) chỉ để xem. Khách đến thêm hay thu ngân chạm nhầm thì số khách sai mãi trên bảng bàn, phiếu checklist bếp và báo cáo chủ quán (`owner_dashboard.rb`).

## Yêu cầu

1. Lệnh `table.set_guest_count`: `POST .../workspaces/:id/guest_count` (cạnh `move`, `merge`, `split`), đi qua `CommandExecutor` với revision, lease, editor như các lệnh bàn khác; kiểm bằng `Tables::Guard.guest_count!` (0–999, null là bỏ). Trả `workspace.to_pos`, phát realtime cho bảng bàn, ghi `AuditEntry`.
2. Chip số khách thành nút; chạm mở `GuestCountPopover` có sẵn (1–8 và "…"), nút "Lưu". Đơn bị khóa thì chip vẫn chỉ xem.
3. Đơn không có số khách hiện chip "+ Số khách" để ghi.
4. Cập nhật `server/openapi/pos-staff.yaml` và client trong `use-workspaces.ts`.

## File

- Tạo: `server/app/workflows/spree/pos/tables/set_guest_count.rb`
- Sửa: `server/config/routes.rb`, `server/app/controllers/spree/api/v3/admin/pos/tables_controller.rb`, `server/openapi/pos-staff.yaml`
- Spec: `server/spec/requests/spree/pos/tables_spec.rb`
- Sửa: `apps/pos/src/hooks/use-workspaces.ts`, `apps/pos/src/components/table-service/ticket-header.tsx`, `guest-count-popover.tsx` (nhãn nút), locale `vi`/`en`

## Các bước

1. Spec request: sửa hợp lệ, null, ngoài khoảng, revision cũ, đơn đã thanh toán.
2. Workflow, route, controller, OpenAPI.
3. Nối giao diện; thêm bước sửa số khách vào e2e `table-service-layout.spec.ts`.

## Kiểm tra

```bash
pnpm spree rspec spec/requests/spree/pos/tables_spec.rb
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project desktop
```

## Rủi ro và rollback

- Lệnh mới phải được chính sách ghi lệnh của bàn chấp nhận (`Tables::Guard.edit!`), không mở quyền mới.
- Rollback: revert commit; không có cột mới.
