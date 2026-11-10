---
phase: 4
title: "Chi nhánh, quầy, nhân viên, sản phẩm, tem cân"
status: done
priority: P2
effort: "2d"
dependencies: [1, 3]
---

# Phase 4: Chi nhánh, quầy, nhân viên, sản phẩm, tem cân

## Goal
Làm lại bằng `dashboard-ui` các trang cài đặt cấp cửa hàng và chi nhánh, trừ tính năng, mô hình kinh doanh và mẫu in.

## Trang nguồn
- `apps/pos/src/pages/settings/topology.tsx` (481 dòng) cùng `components/topology-editor.tsx`: chi nhánh, quầy, nhân viên và quyền chi nhánh (`TopologyKind = 'branches' | 'registers' | 'memberships'`)
- `apps/pos/src/pages/settings/branch-products.tsx` cùng `components/variant-unit-editor.tsx`
- `apps/pos/src/pages/settings/label-formats.tsx` cùng `components/label-format-editor.tsx`. Đây là trang của module `retail.measured`, nên chỉ hiện khi chi nhánh bật module đó, như hàm `branchSettingVisible` đang làm.

## Files to Create / Modify
- Create: `apps/pos-dashboard/src/routes/_authenticated/$storeId/branches/index.tsx`, `registers.tsx`, `staff.tsx`, `products.tsx`, `label-formats.tsx`
- Create: `apps/pos-dashboard/src/pages/{branches,registers,staff,branch-products,label-formats}.tsx`
- Create: `apps/pos-dashboard/src/tables/{branches,registers,staff,branch-products}.tsx` (`DataTable` của `dashboard-ui`)
- Create: `apps/pos-dashboard/src/schemas/{branch,register,membership,label-format}.ts` (zod và `FormValues`; không nhúng type entity của SDK)
- Create: `apps/pos-dashboard/src/components/{branch-form-dialog,register-form-dialog,membership-form-dialog,variant-unit-editor,label-format-editor}.tsx`
- Modify: `apps/pos-dashboard/src/locales/{vi,en}.json`

## Tasks & Steps
1. Với mỗi trang nguồn, ghi lại các trạng thái mà trang cũ xử lý: đang tải, lỗi, không có quyền, chỉ đọc, danh sách trống, xung đột `conflictReason`. Trang mới phải có đủ các trạng thái đó.
2. Dựng trang bằng `PageHeader`, `Card`, `DataTable`, `Dialog`, `Field` và `useConfirm` (thao tác tắt hoặc xóa phải có hộp xác nhận kiểu `destructive`).
3. Phần kiểm tra dữ liệu form dùng zod. Lỗi 422 từ server được gắn vào từng trường bằng `mapSpreeErrorsToForm`.
4. Chuyển các e2e liên quan (`apps/pos/e2e/administration.spec.ts`, `branch-assortment.spec.ts`) thành bản trong `apps/pos-dashboard/e2e/`, giữ nguyên các kịch bản nghiệp vụ.

## Verification
- `cd apps/pos-dashboard && pnpm typecheck && pnpm lint && pnpm test && pnpm build`
- `pnpm test:e2e` cho các spec đã chuyển (cần stack Spree đang chạy)
- So sánh thủ công với trang cũ trên cùng dữ liệu: tạo, sửa và tắt chi nhánh, quầy, nhân viên; gán sản phẩm cho chi nhánh; sửa định dạng tem cân.

## Risk / Rollback
Trang cũ vẫn còn trong `apps/pos` cho tới phase 7.
