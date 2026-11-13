---
phase: 11
title: "Biểu tượng lỗi in bếp trên ô bàn"
status: pending
effort: "0,5 ngày"
dependsOn: [3]
---

# Phase 11: Biểu tượng lỗi in bếp trên ô bàn

## Bối cảnh

Phiếu bếp in qua `PrintJob` (`kind: kitchen_ticket` / `void_ticket`, `source` là `KitchenTicket`). Khi in lỗi, màn bán chỉ có `PrintQueueAlert` nổi ("n lệnh in lỗi", link sang `/receipts`), không biết bàn nào. Bếp không nhận phiếu thì bàn đó chờ món mãi.

`PrintJob#to_pos` chỉ trả `workspace_id` khi `source` là `Workspace`, nên phiếu bếp lỗi không gắn được với đơn.

Biểu tượng **bàn gộp** bỏ khỏi phạm vi: `Tables::Merge` dời món sang đơn đích và hủy đơn nguồn, bàn nguồn trở lại trống. Không có trạng thái "bàn ghép" kéo dài để vẽ.

## Yêu cầu

1. `PrintJob#to_pos` trả `workspace_id` cho phiếu bếp và phiếu hủy món (qua `KitchenTicket#workspace_id`), không thêm truy vấn cho từng dòng (preload ở chỗ liệt kê).
2. Bảng bàn dùng `usePrintJobs` có sẵn: ô có đơn mang lệnh in bếp `failed` hoặc kẹt (`stuckPrintJob`) hiện biểu tượng máy in gạch chéo ở góc kèm chữ cho trình đọc màn hình ("In bếp lỗi"). Chip "Cần xử lý" tính cả trường hợp này.
3. Phiếu bàn của đơn đó hiện dòng cảnh báo "Phiếu bếp chưa in được" với nút "In lại" (dùng lệnh in lại có sẵn của `print-queue-panel.tsx`) và link sang hàng đợi in.

## File

- Sửa: `server/app/models/spree/pos/print_job.rb`, controller liệt kê print job (preload), `server/openapi/pos-staff.yaml`, spec request print jobs
- Sửa: `packages/pos-shared/src/tables.ts` (`needsAttention` nhận cờ lỗi in) + test
- Sửa: `apps/pos/src/components/table-service/board-tile.tsx`, `table-board.tsx`, `ticket.tsx`, locale `vi`/`en`

## Các bước

1. Spec: lệnh in bếp lỗi trả `workspace_id` của đơn.
2. Hàm thuần gom lệnh lỗi theo `workspace_id`; nối vào ô và phiếu.
3. E2E mock một lệnh in bếp lỗi, kiểm biểu tượng và lọc "Cần xử lý".

## Kiểm tra

```bash
pnpm spree rspec spec/requests/spree/pos/print_jobs_spec.rb
pnpm --dir packages/pos-shared exec vitest run src/tables.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project desktop
```

## Rủi ro và rollback

- Tên spec print jobs có thể khác; tìm spec đang test `print_jobs#index` trước khi chạy.
- Rollback: revert commit; trường mới là thêm vào, client cũ bỏ qua.
