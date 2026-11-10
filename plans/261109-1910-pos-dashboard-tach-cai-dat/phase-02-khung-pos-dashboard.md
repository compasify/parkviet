---
phase: 2
title: "Dựng khung apps/pos-dashboard"
status: done
priority: P2
effort: "2d"
dependencies: []
---

# Phase 2: Dựng khung `apps/pos-dashboard`

## Goal
Có một app chạy được ở `http://localhost:5176`. App đăng nhập bằng tài khoản admin, chọn cửa hàng, rồi hiện `AppShell` của Spree với sidebar POS còn trống và trang Settings có `SettingsSidebar`.

## Bối cảnh
`apps/seller-dashboard` là mẫu để làm theo. `@spree/seller-dashboard` dựng shell từ `AuthProvider`, `PermissionProvider` và `queryClient` của `dashboard-core`, cùng `ThemeProvider`, `TooltipProvider` và `ConfirmProvider` của `dashboard-ui` (xem `seller-dashboard.tsx`). Layout `$storeId` của Spree dashboard dùng `AppShell`, `AppShellProvider`, `StoreProvider` và `adminClient`, tất cả đều được `dashboard-core` export. Riêng `LoginPage` nằm trong `@spree/dashboard`, nên app phải tự làm trang đăng nhập.

`dashboard-core` không tự giữ API client. Host phải gọi `setApiClient` lúc khởi động. Các trường bắt buộc gồm `auth`, `setToken`, `onUnauthorized`, `clearTenant` và `fetchPermissions`; những trường như `imports` hay `stockLocations` là tùy chọn. Làm theo `apps/dashboard/node_modules/@spree/dashboard/src/api-client-setup.ts`, nhưng chỉ khai báo các trường bắt buộc và những trường shell thực sự dùng.

## Files to Create / Modify
- Create: `apps/pos-dashboard/package.json` với các dependency `@spree/admin-sdk`, `@spree/dashboard-core`, `@spree/dashboard-ui` (cùng `6.0.3`), `@tanstack/react-query`, `@tanstack/react-router`, `@tanstack/router-plugin`, `react-hook-form`, `zod`, `i18next`, `react-i18next`, `@parkviet/pos-shared` (`link:`); dev: `vite`, `@vitejs/plugin-react`, `@tailwindcss/vite`, `typescript`, `vitest`, `@biomejs/biome`, `@playwright/test`
- Create: `apps/pos-dashboard/pnpm-workspace.yaml` (copy từ `apps/pos`), `tsconfig.json`, `biome.json`, `vitest.config.ts`, `playwright.config.ts`, `index.html`
- Create: `apps/pos-dashboard/vite.config.ts`: `port: 5176`, `strictPort: true`, proxy `/api` và `/rails` giống `apps/pos`, các plugin `TanStackRouterVite`, `tailwindcss()` và `react()`
- Create: `apps/pos-dashboard/src/styles.css`: `@import "@spree/dashboard-ui/styles.css";` cộng `@source` cho `../node_modules/@spree/dashboard-core/src/**/*.{ts,tsx}`
- Create: `apps/pos-dashboard/src/api-client.ts` (`setApiClient` với `adminClient`)
- Create: `apps/pos-dashboard/src/main.tsx`, `src/app.tsx` (cây provider giống `SellerDashboard`)
- Create: `apps/pos-dashboard/src/routes/__root.tsx`, `login.tsx`, `forgot-password.tsx`, `_authenticated.tsx`, `_authenticated/index.tsx` (chuyển tới cửa hàng gần nhất), `_authenticated/$storeId.tsx` (`adminClient.setStore` trong `beforeLoad`, `StoreProvider`, `AppShell` với `inSettings` theo đường dẫn `/$storeId/settings`), `_authenticated/$storeId/index.tsx` (trang tổng quan, chỉ là khung), `_authenticated/$storeId/settings.tsx`
- Create: `apps/pos-dashboard/src/pages/login.tsx` (form dựng bằng `dashboard-ui`, gọi `useAuth().login`)
- Create: `apps/pos-dashboard/src/nav.ts` (chỗ đăng ký nav và settingsNav, lúc này còn trống), `src/i18n.ts`, `src/locales/{vi,en}.json`
- Create: `apps/pos-dashboard/AGENTS.md` và `CLAUDE.md` (`@AGENTS.md`): quy ước thư mục giống `apps/seller-dashboard/AGENTS.md`, nhưng dùng `adminClient` và hook thay cho Seller API
- Create: `apps/pos-dashboard/README.md` (cách chạy, port, biến môi trường)

## Tasks & Steps
1. Scaffold các file cấu hình, `pnpm install`.
2. Viết `api-client.ts` và cây provider. Chạy `pnpm dev`, kiểm tra console không còn lỗi "no API client registered".
3. Làm trang đăng nhập và quên mật khẩu, cùng layout `_authenticated`.
4. Làm layout `$storeId` với `AppShell`. Xác nhận sidebar, menu người dùng, đổi theme và đổi ngôn ngữ đều chạy.
5. Kiểm tra Tailwind: build xong mở trang, các component của `dashboard-core` (sidebar, breadcrumbs) phải có style. Nếu thiếu thì sửa `@source`.
6. Thêm một mục settingsNav thử để xác nhận `SettingsSidebar` hiện khi vào `/$storeId/settings`, sau đó xóa mục thử.

## Verification
- `cd apps/pos-dashboard && pnpm typecheck && pnpm lint && pnpm build`
- `pnpm dev`, đăng nhập bằng tài khoản admin seed ở `http://localhost:5176`: thấy `AppShell`, reload trang không bị đăng xuất, đăng xuất được.
- Dừng dev server sau khi kiểm tra xong.

## Risk / Rollback
App mới hoàn toàn, chưa ai dùng. Rollback bằng cách xóa thư mục.
