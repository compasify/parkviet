---
phase: 4
title: "Màn gọi món: rail, lưới món, panel tùy chọn"
status: pending
effort: "2 ngày"
dependsOn: [1]
---

# Phase 4: Màn gọi món: rail, lưới món, panel tùy chọn

## Bối cảnh

Mockup màn 2 (nửa trái) và màn 3; quy tắc 3, 5, 8 của research. `MenuGrid` hiện vẽ ô có ảnh, danh mục dạng tab trên, và mở `ModifierSheet` dạng popup che giỏ. `useMenu` đã trả nhóm, món, biến thể, nhóm tùy chọn; `soldOutVariantIds` cho món hết; `ModifierSheet` đã có `picksReady`, `estimatePrice`, `defaultPicks`.

## Yêu cầu

1. Khung `order` gồm: rail danh mục dọc 116px bên trái, vùng thực đơn co giãn ở giữa, phiếu 410px bên phải (phiếu làm ở phase 5; phase này để chỗ và vẽ phiếu cũ tạm thời).
2. Rail: mỗi danh mục một nút cao tối thiểu 56px, dải màu danh mục ở mép trái, số món. Cuộn được khi nhiều danh mục.
3. Đầu vùng thực đơn: ô tìm món (phím `/` để focus, tìm theo tên và mã nhanh), nút mật độ Thoáng / Vừa / Dày lưu theo máy trong `localStorage`.
4. Ô món: chữ trước, tên tối đa 2 dòng 15px đậm, giá dòng dưới, dải màu danh mục trên đầu ô, kích thước tối thiểu 120×80px. Huy hiệu số lượng của món đó trong đơn đang mở. Món hết làm mờ, ghi "Hết món", chạm không thêm. Ảnh tắt mặc định trong bố cục này.
5. Chạm món không có tùy chọn: thêm thẳng vào phần chưa gửi của đơn qua lệnh hiện có (`addItem` / append cho đơn bàn, kèm `tableAddExtra`).
6. Món có tùy chọn mở **panel thay chỗ rail và lưới món**, phiếu vẫn hiện. Nhóm bắt buộc chưa chọn đứng đầu, có dấu ✕ đỏ; nút thêm khóa và ghi "Chọn <nhóm> để thêm"; giá cộng thêm trên từng lựa chọn; ghi chú nhanh; ghế và course gán ở đáy panel. Dùng lại logic của `ModifierSheet` bằng cách tách phần thân thành `ModifierForm` để popup cũ và panel mới cùng dùng.

## File

- Tạo: `apps/pos/src/components/table-service/category-rail.tsx`, `menu-item-grid.tsx`, `modifier-panel.tsx`, `apps/pos/src/lib/menu-density.ts` (+ test)
- Sửa: `apps/pos/src/components/modifier-sheet.tsx` (tách `ModifierForm`, popup giữ nguyên hành vi)
- Sửa: `apps/pos/src/components/table-service/table-service-screen.tsx`, `apps/pos/src/styles.css`, locale
- Dùng lại: `use-menu.ts`, `lib/menu-selection.ts`, `CourseSeatPicker` cho chọn ghế / course trong panel

## Các bước

1. Tách `ModifierForm` khỏi `ModifierSheet`; chạy e2e `fnb-menu` để chắc popup cũ không đổi.
2. Dựng `CategoryRail` và `MenuItemGrid` từ dữ liệu `useMenu`, tính huy hiệu số lượng từ `active.line_items`.
3. Dựng `ModifierPanel` bọc `ModifierForm`, nối vào lệnh thêm món hiện có.
4. Lưu mật độ theo máy; unit test đọc/ghi và giá trị mặc định.

## Kiểm tra

```bash
pnpm --dir apps/pos exec vitest run src/lib/menu-density.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/fnb-menu.spec.ts e2e/fnb-wave1.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/fnb-menu.spec.ts --project tablet
```

## Rủi ro và rollback

- Màn 1366px: rail 116 + phiếu 410 còn ~840px cho lưới, tức 5–6 cột ở mật độ Vừa. Nếu chật thì giảm cột, không thu nhỏ ô.
- Rollback: revert commit; `ModifierSheet` vẫn dùng được vì popup giữ API cũ.
