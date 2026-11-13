---
phase: 1
title: "Quầy nhanh cho cafe và trà sữa"
status: done
effort: "2,5 ngày"
dependsOn: []
---

# Phase 1: Quầy nhanh cho cafe và trà sữa

## Bối cảnh

Cafe (`cafe_tra_sua`: `fnb.menu`, `fnb.order_number`, `fnb.cup_label`, không `fnb.tables`, `kitchen_send_trigger: on_complete`) đang bán trên màn ba cột của bán lẻ (`WorkspaceTabs`): thực đơn | giỏ | cột thanh toán luôn hiện. Đơn trả trước, đóng trong vài giây, nên màn cần ít bước nhất. Mockup màn 8 "Quầy nhanh" và câu hỏi mở 2 của research.

Đã có, dùng lại: `CategoryRail`, `MenuItemGrid`, `ModifierPanel`, phiếu (`ticket*.tsx`), `PaymentPanel`, số gọi (`order_number`, `callNumber`), loại đơn (`setServiceMode`), tem ly, màn khách. Chưa có: ảnh trên ô món của lưới mới, phím tắt thanh toán.

## Yêu cầu

1. `sellingLayoutOf` trả `quick_counter` khi `fnb.menu` bật và `fnb.tables` tắt. `SalePage` vẽ `QuickCounterScreen`. Bán lẻ vẫn `counter`.
2. Bố cục: rail danh mục | lưới món | phiếu bên phải. Không có bảng bàn, không thanh tab hóa đơn.
3. Đầu phiếu: số gọi to; chip loại đơn một chạm (Mang đi / Tại quán, cùng Grab / Shopee khi bật `fnb.delivery_platforms`); ô tên khách (in trên tem ly).
4. Ô món hiện ảnh khi món có ảnh. Bật/tắt ảnh là thiết lập theo máy, cạnh ba mức mật độ của `menu-density.ts`; quầy nhanh mặc định bật.
5. Thanh toán ngay trong phiếu: hàng nút phương thức dưới tổng tiền (Tiền mặt, VietQR, các phương thức khác trong "⋯"). Phím F1 tiền mặt đủ, F2 VietQR, F3 phương thức khác. Tiền mặt có mệnh giá gợi ý (`cash-suggestions.ts`). Thanh toán xong: in hóa đơn và tem ly như hiện nay, phiếu trống cho đơn mới, số gọi của đơn vừa xong hiện thoáng ở đầu phiếu.
6. Đơn giữ lại (khách chưa trả, chờ thêm món): nút "Giữ đơn" đưa đơn vào dải đơn chờ trên đầu lưới; chạm để mở lại. Thay thanh tab hóa đơn của màn cũ.

## File

- Sửa: `packages/pos-shared/src/pos-modules.ts` + test (`quick_counter`)
- Tạo: `apps/pos/src/components/quick-counter/quick-counter-screen.tsx`, `quick-ticket-header.tsx`, `quick-pay-bar.tsx`, `held-orders-strip.tsx`
- Sửa: `apps/pos/src/pages/sale.tsx`, `apps/pos/src/components/table-service/menu-item-grid.tsx` (ảnh), `apps/pos/src/lib/menu-density.ts` (+ cờ ảnh), `apps/pos/src/styles.css`, locale `vi`/`en`
- E2E: tạo `apps/pos/e2e/quick-counter.spec.ts`; sửa `fnb-call-number.spec.ts`
- Docs: tài liệu ngành cafe trong `docs/pos/` (tạo `fnb-quay-nhanh.md` nếu chưa có trang phù hợp)

## Các bước

1. Unit test `sellingLayoutOf` cho cafe, quán ăn không bàn, căng tin, bán lẻ; cài đặt.
2. Dựng `QuickCounterScreen` từ `useSellingWorkspace` và các thành phần của màn bàn.
3. Thanh toán trong phiếu và phím tắt; kiểm focus không bị phím tắt cướp khi đang gõ ô tìm món hay tên khách.
4. Dải đơn giữ; ảnh ô món.
5. E2E: bán một ly có tùy chọn, trả tiền mặt bằng F1, phiếu trống và số gọi tăng; giữ đơn rồi mở lại; đổi loại đơn sang Grab.

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/pos-modules.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/quick-counter.spec.ts e2e/fnb-call-number.spec.ts e2e/full-retail.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/quick-counter.spec.ts --project tablet
```

## Rủi ro và rollback

- Quán ăn không bàn và căng tin cũng đổi màn ngay khi phase này vào. Căng tin cần ô mã suất ăn và lượt xe (phase 2): cho tới khi phase 2 xong, `sellingLayoutOf` giữ `counter` cho chi nhánh bật `fnb.meal_accounts` hoặc `fnb.vehicle_commission`.
- Rollback: revert commit; `sellingLayoutOf` trả `counter` như cũ.
