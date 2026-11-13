---
phase: 9
title: "Đơn mang về và giao đi trên bảng bàn"
status: pending
effort: "1 ngày"
dependsOn: [3]
---

# Phase 9: Đơn mang về và giao đi trên bảng bàn

## Bối cảnh

Ô "Mang về" / "Giao đi" (`table-board.tsx`, `startOrder`) mỗi lần chạm tạo một đơn nháp mới rồi đặt `service_mode`. Ô chỉ ghi "n đơn đang mở" mà không có cách mở lại các đơn đó. Đơn mang về hay giao đi chưa trả tiền (chờ món, chờ shipper) không nằm trên ô bàn nào, nên rời đơn về bảng bàn là không quay lại được từ bảng bàn. Chạm nhầm hai lần thì sinh hai đơn nháp rỗng.

## Yêu cầu

1. Chạm ô khi chưa có đơn mở cùng loại: tạo đơn như hiện nay, nhưng nếu đã có một đơn nháp **rỗng** cùng loại ở máy này thì mở đơn đó thay vì tạo mới.
2. Chạm ô khi có đơn mở cùng loại: popover dưới ô (cùng kiểu chọn đơn của bàn nhiều đơn) liệt kê các đơn: số đơn/tên khách, giờ mở, tạm tính, trạng thái món (chưa gửi / đã gửi). Dòng cuối là "+ Đơn mới". Chạm một đơn thì vào khung `order` của đơn đó.
3. Đơn giao đi hiện thêm tên hoặc số điện thoại người nhận nếu `DeliveryForm` đã ghi.
4. Số trên ô vẫn là số đơn đang mở, không tính đơn rỗng.

## File

- Sửa: `apps/pos/src/components/table-service/table-board.tsx` (tách popover ra `quick-order-popover.tsx` nếu file quá 600 dòng)
- Hàm thuần lọc đơn mở theo loại và nhận đơn rỗng: `packages/pos-shared/src/tables.ts` + test
- Locale `vi`/`en`; e2e `apps/pos/e2e/table-service-layout.spec.ts`

## Các bước

1. Unit test hàm lọc (đơn rỗng, đơn đã trả, đơn của loại khác), rồi cài đặt.
2. Popover dùng lại focus trap và Esc như `guest-count-popover.tsx`.
3. E2E: mở mang về, về bảng bàn, chạm lại thấy đơn trong popover và mở được; chạm hai lần liền không sinh hai đơn rỗng.

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/tables.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project desktop
```

## Rủi ro và rollback

- Danh sách đơn lấy từ `workspaces` đã tải ở máy; đơn mở ở máy khác cùng chi nhánh chưa hiện. Ghi rõ trong tài liệu nếu vậy, không thêm API ở phase này.
- Rollback: revert commit.
