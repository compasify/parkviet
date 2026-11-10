---
phase: 3
title: "Hook API, ngữ cảnh POS và gate quyền"
status: done
priority: P2
effort: "1.5d"
dependencies: [2]
---

# Phase 3: Hook API, ngữ cảnh POS và gate quyền

## Goal
`apps/pos-dashboard` gọi được mọi endpoint `/api/v3/admin/pos/...` mà các trang cài đặt cần. Menu POS cũng ẩn hoặc hiện đúng theo quyền cấp cửa hàng và quyền cấp chi nhánh.

## Bối cảnh
- Trong POS, các hook gọi API qua `session.request` của `apps/pos/src/lib/app-session.ts`, là phần riêng của POS. App mới thay bằng `adminClient`. Cần xác nhận `@spree/admin-sdk` có hàm gửi request tùy ý (đường dẫn, method, body, header `Idempotency-Key`) để gọi endpoint POS. Nếu không có thì viết một helper `posRequest` nhỏ dùng token từ `adminClient`. `[UNVERIFIED]`
- Quyền cấp cửa hàng có trong `permissionKeys` (`usePermissions()`), vì `pos_topology` đã được khai báo qua `register_scope` trong `server/config/initializers/spree.rb`.
- Quyền cấp chi nhánh (`pos.topology.manage`…) chỉ có trong `GET /api/v3/admin/pos/context` (`server/app/controllers/spree/api/v3/admin/pos/context_controller.rb`), trường `capabilities` theo chi nhánh đang chọn và `administration`.

## Files to Create / Modify
- Create: `apps/pos-dashboard/src/lib/pos-request.ts` (gọi endpoint POS, chuẩn hóa lỗi thành dạng mà `mapSpreeErrorsToForm` hoặc toast đọc được)
- Create: `apps/pos-dashboard/src/hooks/use-pos-context.ts` (context theo chi nhánh đang chọn, gồm `administration` và `capabilities`)
- Create: `apps/pos-dashboard/src/hooks/use-branch-selection.ts` (chi nhánh đang chọn lưu trong search param `?branch=`, mặc định là chi nhánh đầu tiên được xem)
- Create: `apps/pos-dashboard/src/lib/pos-access.ts` (các hàm điều kiện thuần: `canAdminister`, `canManageBranch`, `visibleNav`), kèm `pos-access.test.ts`
- Create: `apps/pos-dashboard/src/hooks/` cho từng nhóm endpoint: `use-topology.ts` (branches, registers, memberships), `use-branch-catalog.ts`, `use-branch-features.ts`, `use-branch-modules.ts`, `use-business-profiles.ts`, `use-onboarding.ts`, `use-label-formats.ts`, `use-receipt-templates.ts`. Query key dựng theo `storeId`. Thao tác ghi đi qua `useMutation` và invalidate đúng key.
- Create: `apps/pos-dashboard/src/components/pos-branch-picker.tsx` (dựng bằng `dashboard-ui`, đặt trong `PageHeader`)
- Modify: `apps/pos-dashboard/src/nav.ts` (đăng ký đủ mục nav ở D4, mỗi mục có `if` dùng `pos-access`)

## Tasks & Steps
1. Đọc `@spree/admin-sdk` để chọn cách gọi endpoint POS, và ghi lựa chọn vào đầu `pos-request.ts`.
2. Với mỗi hook bên `apps/pos/src/hooks/*` mà trang cài đặt dùng, viết bản tương đương: cùng endpoint, cùng payload, cùng cách xử lý lỗi `conflictReason` (dùng `request-failure` trong `pos-shared` nếu đã chuyển, nếu chưa thì chuyển ở phase này).
3. Viết `pos-access.ts` và test cho ba vai trò: chủ cửa hàng (`write_pos_topology`), người chỉ được xem (`read_pos_topology`), và quản lý chi nhánh (chỉ có `pos.topology.manage` tại một chi nhánh).
4. Đăng ký nav. Mỗi route cũng tự kiểm tra quyền trong component và trả về trang 403 khi mở URL trực tiếp mà không có quyền.

## Verification
- `cd apps/pos-dashboard && pnpm test && pnpm typecheck && pnpm lint`
- Ở dev, đăng nhập lần lượt bằng ba tài khoản của ba vai trò (tạo qua seed hoặc role editor), sidebar phải đúng như bảng trong `pos-access.test.ts`.

## Risk / Rollback
Phase này chỉ đọc API và ghi qua endpoint có sẵn, không đổi server.
