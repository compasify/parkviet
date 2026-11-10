---
phase: 5
title: "Tính năng, mô hình kinh doanh, thiết lập lần đầu"
status: done
priority: P2
effort: "1.5d"
dependencies: [1, 3]
---

# Phase 5: Tính năng, mô hình kinh doanh, thiết lập lần đầu

## Goal
Làm lại các trang bật/tắt tính năng, chọn mô hình kinh doanh và thiết lập lần đầu. Hai vai trò chủ cửa hàng và quản lý chi nhánh phải hoạt động đúng như trước.

## Trang nguồn
- `apps/pos/src/pages/settings/branch-features.tsx` (320 dòng): chủ cửa hàng (`write_pos_topology`) đặt mặc định cho cả cửa hàng; quản lý chi nhánh (`pos.topology.manage`) chỉ tắt được tại chi nhánh của mình. Mỗi lần đổi phải nhập lý do.
- `apps/pos/src/pages/settings/business-model.tsx` (696 dòng) cùng `components/profile-diff.tsx` và `components/setup/setup-preview-step`
- `apps/pos/src/pages/setup.tsx` cùng `components/setup/*` và `styles/setup.css`: thiết lập lần đầu cho cửa hàng chưa có hồ sơ và chưa có chi nhánh nào đang hoạt động (`onboarding.required`, `can_setup`)

## Files to Create / Modify
- Create: `apps/pos-dashboard/src/routes/_authenticated/$storeId/features.tsx`, `business-model.tsx`, `setup.tsx`
- Create: `apps/pos-dashboard/src/pages/{branch-features,business-model,setup}.tsx`
- Create: `apps/pos-dashboard/src/components/{feature-switch-row,profile-diff,setup-preview-step}.tsx`
- Modify: `apps/pos-dashboard/src/routes/_authenticated/$storeId.tsx`: khi `onboarding.required` và người dùng có `can_setup` thì chuyển sang `/setup`
- Modify: `apps/pos-dashboard/src/locales/{vi,en}.json`

## Tasks & Steps
1. Dùng các hàm thuần trong `@parkviet/pos-shared` (`pos-features`, `pos-modules`, `setup-wizard`, `module-registry`). Không chép lại logic.
2. Trang thiết lập dùng `Wizard` của `dashboard-ui`.
3. Chuyển các e2e `branch-modules.spec.ts`, `business-model.spec.ts`, `feature-flags.spec.ts` và phần `/setup` trong `context.spec.ts`.

## Verification
- `cd apps/pos-dashboard && pnpm typecheck && pnpm lint && pnpm test && pnpm build && pnpm test:e2e`
- Thử thủ công bằng tài khoản quản lý chi nhánh: chỉ thấy chi nhánh của mình, tắt được tính năng có nhập lý do, không thấy phần mặc định của cửa hàng.
- Thử thủ công với một cửa hàng trống: được chuyển sang `/setup`, làm hết các bước, cuối cùng có chi nhánh đang hoạt động.

## Risk / Rollback
Trang cũ vẫn còn trong `apps/pos` cho tới phase 7.
