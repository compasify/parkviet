---
phase: 7
title: "Cắt chuyển trong apps/pos"
status: pending
priority: P2
effort: "1d"
dependencies: [4, 5, 6]
---

# Phase 7: Cắt chuyển trong `apps/pos`

## Goal
`apps/pos` không còn trang cài đặt và trang thiết lập. Mọi lối vào cũ đều mở sang `apps/pos-dashboard`.

## Files to Create / Modify
- Delete: `apps/pos/src/pages/settings/*`, `apps/pos/src/pages/setup.tsx`, `apps/pos/src/components/setup/*`, `apps/pos/src/styles/setup.css`, `apps/pos/src/styles/receipt-templates.css`
- Delete: các component chỉ trang cài đặt dùng, gồm `topology-editor.tsx`, `variant-unit-editor.tsx`, `label-format-editor.tsx`, `profile-diff.tsx`, `admin-dialog.tsx` và `components/receipt-template/*` trừ phần in. Giữ `paper-picker.tsx` vì `template-picker.tsx` của màn bán hàng đang dùng. Trước khi xóa phải kiểm tra bằng `grep`.
- Delete: hook chỉ trang cài đặt dùng (`use-onboarding`, `use-business-profiles`…, cũng kiểm tra bằng `grep` trước)
- Delete: các e2e đã chuyển ở phase 4–6
- Create: `apps/pos/src/lib/pos-dashboard-url.ts` (dựng URL từ `VITE_POS_DASHBOARD_URL`, `storeId` và đường dẫn), kèm test
- Modify: `apps/pos/src/router.tsx` (bỏ `settingsRoute`, `branch*Route`, `businessModelRoute`, `setupRoute`, `receiptTemplate*Route`)
- Modify: `apps/pos/src/components/user-menu.tsx`, `components/pos-page.tsx`, `components/feature-off-note.tsx`: link `<a href>` mở sang pos-dashboard
- Modify: `apps/pos/src/pages/login.tsx`: bỏ chuyển hướng `administration ? '/settings' : '/'`. Nếu cửa hàng cần thiết lập lần đầu thì hiện thông báo kèm link sang pos-dashboard.
- Create: `apps/pos/.env.example` (`VITE_POS_DASHBOARD_URL=http://localhost:5176`; hiện POS chưa có file env nào). Trong dev, khi biến này chưa đặt thì mặc định dùng `http://localhost:5176`.
- Modify: `apps/pos/src/styles.css`: xóa các rule chỉ trang cài đặt dùng
- Modify: `apps/pos/src/locales/{vi,en}.json`: xóa các khóa không còn dùng

## Tasks & Steps
1. `grep` từng component hoặc hook định xóa. Chỉ xóa khi không còn chỗ nào ngoài `pages/settings` và `pages/setup` dùng nó.
2. Đổi các link, viết test cho `pos-dashboard-url.ts`.
3. Chạy lại toàn bộ e2e của POS để chắc màn bán hàng không bị ảnh hưởng.

## Verification
- `cd apps/pos && pnpm typecheck && pnpm lint && pnpm test && pnpm build && pnpm test:e2e`
- `grep -rn "/settings\|/setup" apps/pos/src` chỉ còn các link sang pos-dashboard.
- `git diff --stat -- apps/dashboard` trống.

## Risk / Rollback
Đây là phase duy nhất người dùng nhận ra có thay đổi. Commit riêng để có thể revert một mình mà không mất các phase trước.
