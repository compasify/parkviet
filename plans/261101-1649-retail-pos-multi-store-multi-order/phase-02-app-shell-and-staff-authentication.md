---
phase: 2
title: Shell POS độc lập và đăng nhập nhân viên
status: in-progress
priority: P1
dependencies:
  - 1
effort: Ước tính 5–8 person-days
---

# Phase 2: Shell POS độc lập và đăng nhập nhân viên

## Overview

Tạo `apps/pos` độc lập, đăng nhập staff thật và shell bán hàng tiếng Việt.
Chưa có khả năng thu tiền; auth/context phải hoạt động với Rails đã qua gate phase 1.
Tham chiếu [kiến trúc §4,11](./specs/product-and-architecture.md), [API/tests](./specs/api-contract-and-test-matrix.md).

## Requirements

- React 19, Vite, TypeScript, TanStack Query/Router và i18next theo pattern app hiện có.
- Package/lockfile riêng; không thêm root workspace nếu chưa có lý do/approval độc lập.
- Admin JWT access ở memory, refresh HttpOnly cookie; không secret key/localStorage token trong SPA.
- Login/refresh/logout/revoke thật, session expired khóa writes; logout không xóa draft server.
- Shell có context placeholder từ API thật, connection state, breakpoint 1280/1024/768/375px và keyboard focus.
- Không mount full dashboard router; chỉ dùng UI primitives sau xác minh exports/CSS.

## Architecture

- Admin SDK auth transport → memory session coordinator → API hooks; components không tự gọi client.
- BroadcastChannel chỉ báo refresh/logout/invalidation; không broadcast long-lived credentials hoặc dữ liệu khách.
- Refresh single-flight giữa browser tabs cần cơ chế lock đã kiểm chứng; tab thức lại đọc trạng thái session hiện hành.
- `GET /pos/context` ban đầu có identity/capabilities rỗng có kiểm soát; phase 3 bổ sung topology thật.
- API BaseController xác minh admin audience/store và POS access; không dựa nút UI để authorize.
- Query keys có store/context; abort requests và clear private caches khi logout/đổi merchant.

## Related Code Files

Mọi path từ repo root, create/modify dự kiến; không sửa upstream `spree/`.
- Create: `apps/pos/package.json`, `apps/pos/pnpm-lock.yaml`, `apps/pos/index.html`, `apps/pos/tsconfig.json`.
- Create: `apps/pos/vite.config.ts`, `apps/pos/biome.json`, `apps/pos/vitest.config.ts`, `apps/pos/playwright.config.ts`.
- Create: `apps/pos/src/main.tsx`, `apps/pos/src/router.tsx`, `apps/pos/src/pages/login.tsx`, `apps/pos/src/pages/sale.tsx`.
- Create: `apps/pos/src/lib/admin-client.ts`, `apps/pos/src/lib/session-coordinator.ts`, `apps/pos/src/lib/query-keys.ts`.
- Create: `apps/pos/src/hooks/use-session.ts`, `apps/pos/src/hooks/use-pos-context.ts`, `apps/pos/src/components/pos-shell.tsx`.
- Create: `apps/pos/src/locales/vi.json`, `apps/pos/src/locales/en.json`, `apps/pos/src/styles.css`, `apps/pos/README.md`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/base_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/context_controller.rb`.
- Create: `server/spec/requests/spree/pos/authentication_spec.rb`, `apps/pos/src/lib/session-coordinator.test.ts`, `apps/pos/e2e/auth.spec.ts`.
- Modify: `server/config/routes.rb`, `server/config/initializers/spree.rb` — POS namespace/access registration theo seam phase 1.

## Implementation Steps

1. Viết trước request tests invalid admin audience/revoked staff/CSRF-origin và browser tests nhiều tabs refresh cùng lúc.
2. Xác nhận package manager/tool versions, SDK auth contract và primitive exports; chốt app package độc lập.
3. Khai báo scripts `dev/typecheck/lint/test/build/test:e2e`; test không pass nhờ `passWithNoTests` cho logic bắt buộc.
4. Dựng router base `/pos`, login route/guard, QueryClient và i18next; lấy origin/proxy từ config không chứa secret.
5. Tạo restricted BaseController/context endpoint với DTO tối thiểu; dùng installed error/envelope và prefixed IDs.
6. Nối admin login/refresh/cookie credentials; memory token, single-flight/revoke và purge cache khi logout.
7. Làm shell bán hàng với header/context/connection và vùng tab/checkout theo wireframe; không nút success giả.
8. Map 401/403/422/network error ra tiếng Việt; giữ navigation/focus và cảnh báo unsent state khi cần.
9. Test callback auth/context về muộn không khôi phục session đã logout hoặc hiển thị merchant cũ.
10. README chỉ rõ `pnpm dev` trong `apps/pos` cho Vite riêng; backend hiện có qua CLI, không chạy stack thứ hai.
11. Không khuyên `spree dev --app pos`; kiểm CLI thực có hỗ trợ trước mọi hướng dẫn tích hợp.
12. Gate dự kiến: `pnpm spree rspec spec/requests/spree/pos/authentication_spec.rb`; app chạy đủ năm scripts kiểm tra.

## Success Criteria

- [ ] A01: login/rotation/revoke/logout đa browser tabs qua SDK + API thật, không credentials bền vững trong JS storage.
- [ ] A02, A04: context unauthorized bị chặn; cache/request cũ không xuất hiện sau đổi store/logout.
- [ ] W08: shell responsive/zoom200%/keyboard; mọi nhãn và lỗi qua i18next.
- [ ] A03: staff POS không được blanket core writes chỉ để shell hoạt động.
- [ ] Build độc lập thành công trong môi trường triển khai tương lai; không thay root workspace hoặc website checkout.

## Risk Assessment

- Cookie/CORS khác origin: xác minh same-site/origin policy trước coding; không nới wildcard credentials.
- Reuse dashboard kéo full admin bundle/quyền: chỉ import primitives đã thử, fallback UI nhỏ theo hệ hiện có.
- Refresh race hoặc tab ngủ: khóa/coordinator có tests; BroadcastChannel không được coi là authority.

## Next Steps

Chuyển phase 3 để cấp topology/ca thật; shell không được gọi là POS vận hành hoặc bản bán lẻ đầy đủ.
