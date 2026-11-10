---
phase: 6
title: "Mẫu in hóa đơn: danh sách và trình sửa"
status: done
priority: P2
effort: "2d"
dependencies: [1, 3]
---

# Phase 6: Mẫu in hóa đơn: danh sách và trình sửa

## Goal
Làm lại danh sách mẫu in và trình sửa mẫu bằng `dashboard-ui`. Bản xem trước phải giống bản in thật, vì cả hai dùng chung bộ dựng trong `@parkviet/pos-shared`.

## Trang nguồn
- `apps/pos/src/pages/settings/receipt-templates.tsx` (394 dòng) cùng `components/admin-dialog.tsx` và `components/paper-picker.tsx`
- `apps/pos/src/pages/settings/receipt-template-editor.tsx` (956 dòng) cùng `components/receipt-template/{block-editor,block-list,field-toggles,template-preview,version-drawer}` và `components/print-sheet.tsx`
- Style xem trước: `apps/pos/src/styles/receipt.css` và `receipt-templates.css`

## Files to Create / Modify
- Create: `apps/pos-dashboard/src/routes/_authenticated/$storeId/settings/receipt-templates.index.tsx`, `receipt-templates.$templateId.tsx`. Trang này nằm dưới Settings, dùng `SettingsSidebar`.
- Create: `apps/pos-dashboard/src/pages/{receipt-templates,receipt-template-editor}.tsx`
- Create: `apps/pos-dashboard/src/components/receipt-template/{block-editor,block-list,field-toggles,template-preview,version-drawer,paper-picker}.tsx`
- Create: `packages/pos-shared/src/receipt-template/receipt.css`. Đây là style của **phiếu in** (không phải style của trang), dùng chung cho bản in trong POS và bản xem trước. Chuyển từ `apps/pos/src/styles/receipt.css`.
- Modify: `apps/pos/src` import `receipt.css` từ `@parkviet/pos-shared`
- Modify: `apps/pos-dashboard/src/nav.ts` (thêm mục settingsNav "Mẫu in hóa đơn")
- Modify: `apps/pos-dashboard/src/locales/{vi,en}.json`

## Tasks & Steps
1. Đặt bản xem trước trong một khung riêng (iframe hoặc container có scope), để CSS phiếu in và Tailwind của trang không ảnh hưởng nhau.
2. Bản xem trước lấy dữ liệu từ `sample-data` trong `pos-shared`, giống trình sửa cũ.
3. Kiểm tra mẫu bằng `validate` trong `pos-shared` trước khi lưu, và hiện lỗi theo từng khối.
4. Chuyển e2e `receipt-templates.spec.ts`.

## Verification
- `cd apps/pos-dashboard && pnpm typecheck && pnpm lint && pnpm test && pnpm build && pnpm test:e2e`
- `cd apps/pos && pnpm test && pnpm build` (sau khi chuyển `receipt.css`)
- Sửa một mẫu trong `pos-dashboard`, in một đơn trong POS: phiếu in giống bản xem trước, ở cả khổ 58mm và 80mm.

## Risk / Rollback
Thay đổi chỗ đặt `receipt.css` ảnh hưởng tới bản in thật. Kiểm tra in trước khi đóng phase.
