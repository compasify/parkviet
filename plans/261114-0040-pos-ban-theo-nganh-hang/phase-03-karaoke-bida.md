---
phase: 3
title: "Bảng phòng tính giờ cho karaoke và bida"
status: done
effort: "3 ngày"
dependsOn: []
---

# Phase 3: Bảng phòng tính giờ cho karaoke và bida

## Bối cảnh

Karaoke và bida (`karaoke_bida`: `fnb.tables`, `timed_billing`, `fnb.postpay`, `fnb.bottle_keep`, bề mặt `resource_board`) đang ở màn ba cột vì `sellingLayoutOf` loại `resource_board`. Bảng phòng hiện nằm trong `TableFloor` sau nút "Sơ đồ bàn"; ô phòng có `TimedClock` (`timed-panel.tsx`, `lib/timed-clock.ts`), board trả `clock` và `buffet_ends_at` theo đơn, `TimedSessions::AlertJob` cảnh báo sắp hết gói. Gói giờ trả trước, thẻ phút, tạm dừng cần duyệt, đổi phòng giữ giá đoạn cũ đều đã có ở server và `TimedPanel`.

Mockup màn 5 và 6, quy tắc 10 của research.

## Yêu cầu

1. `sellingLayoutOf` trả `table_service` cho `resource_board`. Khung `board` của `TableServiceScreen` vẽ ô phòng khi bề mặt là `resource_board`.
2. Ô phòng: tên và loại phòng, đồng hồ hh:mm lớn nhất (đếm lên, hoặc đếm ngược với gói giờ), giá giờ hiện hành, tiền giờ / tiền đồ / tổng. Đồng hồ đếm ngược chuyển cam khi còn ≤10 phút, đỏ và nhấp nháy khi hết giờ (tôn trọng `prefers-reduced-motion`); tạm dừng nền xám có biểu tượng tạm dừng. Mỗi màu kèm chữ.
3. Ba nút trên ô đổi theo trạng thái: Bắt đầu / Dừng / Tiếp tục; Gọi món (vào khung `order`); Thanh toán. Lọc "Cần xử lý" tính cả phòng sắp hết hoặc hết gói và phòng gọi thanh toán.
4. Khung `order` của phòng: dòng tính giờ ghim đầu phiếu với đồng hồ, giá, nút dừng/tiếp tục một chạm, đổi phòng, sửa giờ (cần duyệt như hiện nay). Phần còn lại giống phiếu bàn.
5. Thanh toán khi đồng hồ còn chạy (từ ô hoặc từ phiếu): hộp xác nhận "Dừng giờ và thanh toán P101?" có tiền giờ dự tính; đồng ý thì dừng rồi mở khung `pay`. Không có trường hợp thanh toán mà đồng hồ vẫn chạy.
6. Sổ gửi rượu vẫn mở từ "⋯" của phiếu như hiện nay.

## File

- Sửa: `packages/pos-shared/src/pos-modules.ts` + test; `packages/pos-shared/src/tables.ts` (tone và `needsAttention` cho phòng tính giờ) + test
- Tạo: `apps/pos/src/components/table-service/room-tile.tsx`, `timed-ticket-line.tsx`, `stop-and-pay-dialog.tsx`
- Sửa: `table-board.tsx`, `ticket.tsx`, `ticket-footer.tsx`, `table-service-screen.tsx`, `apps/pos/src/styles.css`, locale `vi`/`en`
- Dùng lại không sửa logic: `timed-panel.tsx`, `lib/timed-clock.ts`, `use-resource-board.ts`
- E2E: sửa `apps/pos/e2e/karaoke.spec.ts`
- Docs: mục karaoke / bida trong `docs/pos/` (tạo trang nếu chưa có)

## Các bước

1. Unit test tone của ô phòng (đang chạy, sắp hết, hết giờ, tạm dừng, trống) và `sellingLayoutOf`; cài đặt.
2. `RoomTile` dùng `TimedClock` và độ lệch giờ máy chủ có sẵn.
3. Dòng tính giờ ghim trong phiếu; hộp "Dừng giờ và thanh toán".
4. E2E: bắt đầu giờ, gọi đồ vào phòng, gửi bếp, thanh toán khi đồng hồ chạy qua hộp xác nhận, về bảng phòng.

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/pos-modules.test.ts src/tables.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/karaoke.spec.ts e2e/table-service-layout.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/karaoke.spec.ts --project tablet
```

## Rủi ro và rollback

- Đồng hồ cập nhật mỗi giây trên hàng chục ô: một bộ đếm chung cho cả bảng, không mỗi ô một `setInterval`.
- Chi nhánh nhà hàng bật thêm `timed_billing` cho vài bàn (bida trong nhà hàng): ô bàn có đồng hồ phải vẽ được trong cùng bảng bàn; kiểm bằng unit test tone.
- Rollback: revert commit; `sellingLayoutOf` loại `resource_board` như cũ.
