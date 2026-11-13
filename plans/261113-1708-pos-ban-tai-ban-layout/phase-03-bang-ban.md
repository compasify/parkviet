---
phase: 3
title: "Bảng bàn"
status: completed
effort: "2 ngày"
dependsOn: [1, 2]
---

# Phase 3: Bảng bàn

## Bối cảnh

Mockup màn 1, quy tắc 1–2 của research. `TableFloor` (`components/table-floor.tsx`) và `TableTile` đã vẽ ô bàn và sơ đồ từ `useResourceBoard`, với dữ liệu `BoardTable` đủ cho ô mới: `seated_minutes`, `guest_count`, `subtotal`, `state`, `orders[].pending_kitchen_items`, `payment_requested`, `prebilled`, `next_reservation`. `TableFloor` cũng đã có luồng mở bàn (`workspaces.openTable`) và chọn đơn.

## Yêu cầu

1. Khung `board` của `TableServiceScreen` chiếm toàn vùng dưới thanh trên, không có thanh tab hóa đơn hay nút "Sơ đồ bàn".
2. Đầu bảng: tab khu vực kèm "đang dùng/tổng"; chip lọc Tất cả, Đang dùng, Trống, Cần xử lý (gọi thanh toán, chờ món lâu, ngồi quá ngưỡng, có món chưa gửi); dòng chú thích màu và biểu tượng.
3. Hai ô cố định đầu lưới: "Mang về" mở đơn mang đi ở khung `order` (ô nhỏ ghi số đơn mang đi đang mở); "Giao đi" mở đơn với `DeliveryForm`.
4. Ô bàn theo L5: tên, thời gian ngồi to nhất, trạng thái bằng chữ, số khách, tạm tính. Màu nền tính bằng hàm thuần `tileTone(table)` trong `packages/pos-shared/src/tables.ts`: `free`, `serving`, `unsent`, `prebilled`, `payment`. Dải đỏ khi `seated_minutes >= seated_alert_minutes` hoặc `state === 'waiting_long'`. Biểu tượng góc: đặt trước (giờ), bàn gộp, lỗi in bếp nếu board có dữ liệu (không thì bỏ, ghi rõ trong PR).
5. Chạm bàn trống: popover chọn số khách (1–8 và "…") ngay dưới ô, nút "Mở bàn · n khách". Chạm bàn có khách: chuyển sang khung `order` với đơn của bàn (bàn nhiều đơn thì hỏi chọn đơn như hiện nay).
6. Bề mặt `floor_plan` vẽ cùng kiểu ô ở vị trí trên sơ đồ; lựa chọn lưới/sơ đồ vẫn lưu theo máy (`saveTableSurface`) qua một nút nhỏ ở đầu bảng.
7. Khay đơn chờ có sẵn (QR tại bàn, nền tảng giao hàng, kiosk) hiện thành nút có số đếm ở đầu bảng, mở khay hiện tại; không thiết kế lại khay.

## File

- Tạo: `apps/pos/src/components/table-service/table-board.tsx`, `board-tile.tsx`, `guest-count-popover.tsx`, CSS trong `apps/pos/src/styles.css` (khối `.table-service`)
- Sửa: `packages/pos-shared/src/tables.ts` (+ `tileTone`, `needsAttention`, `boardCounts`), `packages/pos-shared/src/tables.test.ts`
- Sửa: `apps/pos/src/components/table-service/table-service-screen.tsx`
- Locale: `apps/pos/src/locales/vi.json`, `en.json` (hoặc `packages/pos-shared/src/locales` nếu khóa dùng chung)
- Dùng lại không sửa: `use-resource-board.ts`, `DeliveryForm`, `GuestOrderTray`, `PlatformOrderTray`, `KioskOrderTray`

## Các bước

1. Unit test `tileTone`, `needsAttention`, `boardCounts` với các tổ hợp trạng thái, rồi cài đặt.
2. Dựng `BoardTile` và `TableBoard`, nối `useResourceBoard` và lệnh mở bàn từ hook phase 1.
3. Popover số khách có focus trap và Esc để đóng (dùng `dialog-focus`).
4. Nối "Mang về" / "Giao đi" vào lệnh tạo đơn quầy hiện có với `service_mode` tương ứng.
5. Sửa e2e `tables.spec.ts` để đi từ bảng bàn mới thay vì nút "Sơ đồ bàn".

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/tables.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/tables.spec.ts e2e/reservations.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/tables.spec.ts --project tablet
```

## Rủi ro và rollback

- Chi nhánh có hàng trăm bàn: lưới cuộn trong khung, không phân trang; giữ `content-visibility: auto` cho ô nếu chậm.
- Rollback: revert commit; `TableServiceScreen` quay về vẽ màn cũ.
