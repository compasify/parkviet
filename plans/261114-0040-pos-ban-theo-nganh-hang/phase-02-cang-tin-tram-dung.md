---
phase: 2
title: "Căng tin và trạm dừng trên quầy nhanh"
status: pending
effort: "1,5 ngày"
dependsOn: [1]
---

# Phase 2: Căng tin và trạm dừng trên quầy nhanh

## Bối cảnh

Căng tin và trạm dừng (`cang_tin_tram_dung`: `fnb.menu`, `fnb.order_number`, `fnb.meal_accounts`, `fnb.vehicle_commission`) là quầy đông bán trả trước, cùng dạng với quầy nhanh của phase 1. Khác biệt là hai công cụ đang gắn vào màn ba cột:

- Ô nhập mã suất ăn trong `scan-input.tsx` (`resolveMealAccount`, gợi ý theo tên, âm báo `lib/scan-sounds.ts` cho hợp lệ / trùng / lỗi). Trang ngành hứa "ô nhập mã luôn sẵn trên màn bán".
- `VehicleVisitBar` (mở lượt xe bằng biển số, nhà xe, số khách; gắn đơn vào lượt; chốt lượt).

Thanh toán bằng ví trả trước, công ty trả sau và trợ giá theo suất đã có trong `PaymentPanel`.

## Yêu cầu

1. Bỏ ngoại lệ tạm của phase 1: chi nhánh có `fnb.meal_accounts` / `fnb.vehicle_commission` cũng vào `quick_counter`.
2. Ô mã suất ăn nằm cố định ở đầu phiếu của quầy nhanh khi bật `fnb.meal_accounts`, giữ focus sau mỗi đơn để quét hoặc gõ liên tục. Nhận mã thì phiếu hiện tên người ăn, đơn vị chi trả, suất còn lại trong ngày và phần công ty / người ăn trả; âm báo như hiện nay.
3. Suất trùng hoặc vượt hạn mức hiện ngay trên phiếu bằng chữ đỏ kèm lý do (`mealReasonKey`), không mở hộp thoại.
4. Khi bật `fnb.vehicle_commission`: dải lượt xe đang mở ở trên lưới món (biển số, nhà xe, số đơn đã gắn), chạm để gắn đơn đang bán vào lượt; nút "+ Lượt xe" và "Chốt lượt" dùng lại lệnh của `VehicleVisitBar`.
5. Gỡ nhánh suất ăn và lượt xe khỏi `WorkspaceTabs` nếu không còn bố cục nào dùng.

## File

- Sửa: `packages/pos-shared/src/pos-modules.ts` + test
- Sửa: `apps/pos/src/components/quick-counter/quick-ticket-header.tsx`, `quick-counter-screen.tsx`
- Tạo: `apps/pos/src/components/quick-counter/vehicle-visit-strip.tsx` (dùng lại `useOpenVehicleVisits`, `useVehicleVisitCommands`)
- Sửa: `apps/pos/src/components/scan-input.tsx` (tách phần nhận mã suất ăn nếu cần dùng riêng), `apps/pos/src/components/workspace-tabs.tsx`, locale `vi`/`en`
- E2E: sửa `apps/pos/e2e/meal-accounts.spec.ts`, `vehicle-visits.spec.ts`
- Docs: trang tài liệu căng tin / trạm dừng trong `docs/pos/` nếu có, không thì thêm mục vào trang quầy nhanh của phase 1

## Các bước

1. Unit test `sellingLayoutOf` cho căng tin; cài đặt.
2. Dời ô mã suất ăn vào đầu phiếu; kiểm focus quay lại ô mã sau khi thanh toán.
3. Dải lượt xe.
4. Sửa hai e2e; chạy kèm `quick-counter.spec.ts`.

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/pos-modules.test.ts
pnpm --dir apps/pos exec vitest run src/lib/scan-sounds.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/meal-accounts.spec.ts e2e/vehicle-visits.spec.ts e2e/quick-counter.spec.ts --project desktop
```

## Rủi ro và rollback

- Máy quét mã gửi phím như bàn phím: phím tắt F1–F3 của phase 1 không được nuốt ký tự quét. Kiểm bằng e2e gõ mã nhanh.
- Rollback: revert commit; ngoại lệ của phase 1 trả căng tin về màn cũ.
