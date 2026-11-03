---
phase: 3
title: "Chi nhánh, quầy, quyền và mở ca tối thiểu"
status: pending
priority: P1
dependencies: [1, 2]
effort: "Ước tính 7–10 person-days"
---

# Phase 3: Chi nhánh, quầy, quyền và mở ca tối thiểu

## Overview

Thiết lập Branch/Register/Membership và mở ca tối thiểu trước workspace, không trì hoãn drawer identity tới phase 9.
Backend và màn cấu hình/selector dùng cùng server authorization.
Chuẩn: [kiến trúc §5,10,11](./specs/product-and-architecture.md), [API/tests A02–A06](./specs/api-contract-and-test-matrix.md).

## Requirements

- Store là merchant boundary; Branch là địa điểm vật lý; Channel POS không thay branch/access scope.
- Mỗi branch có timezone, kho bán hợp lệ, receiving config; register là logical drawer không phải browser ID.
- Membership theo staff/branch/capabilities; manager có quyền cấu hình riêng, cashier chỉ được scope cấp.
- Một ca active mỗi register bằng DB constraint; lưu opening float/người chịu trách nhiệm, không mở kép hai máy.
- Disable thay hard-delete khi có lịch sử; chặn new writes nhưng manager còn đường recovery có audit.
- Không quota cứng branches/registers; phân trang/search, giới hạn kỹ thuật per-request có giải thích.

## Architecture

- Models `Spree::Pos::{Branch,Register,StaffMembership,Shift,AuditEntry,Approval}` thuộc Store bằng FK/constraints.
- Membership resolver và context policy xác minh tất cả incidental IDs, kể cả stock location/channel/approver.
- OpenShift lock register + unique active-shift index; tiền đầu ca decimal, không ghi thành doanh số/Payment.
- Audit/Approval primitives tạo từ đây; sensitive workflows sau chỉ bổ sung action types và amount/revision binding.
- Active shift/context trả về server capabilities; client không tự đoán quyền từ tên role hoặc channel header.
- Đổi context abort query; không âm thầm chuyển source branch hoặc location của draft đang có.

## Related Code Files

Inventory từ repo root; tất cả app-specific, không sửa source gem.
- Create: `server/app/models/spree/pos/branch.rb`, `server/app/models/spree/pos/register.rb`, `server/app/models/spree/pos/staff_membership.rb`.
- Create: `server/app/models/spree/pos/shift.rb`, `server/app/models/spree/pos/audit_entry.rb`, `server/app/models/spree/pos/approval.rb`.
- Create: `server/db/migrate/TIMESTAMP_create_spree_pos_topology.rb` — placeholder timestamp generator cấp khi triển khai.
- Create: `server/app/services/spree/pos/context_resolver.rb`, `server/app/services/spree/pos/access_policy.rb`.
- Create: `server/app/workflows/spree/pos/shifts/open.rb`, `server/app/workflows/spree/pos/topology/disable.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/branches_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/registers_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/memberships_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/shifts_controller.rb`.
- Create: `apps/pos/src/pages/settings/topology.tsx`, `apps/pos/src/components/context-selector.tsx`, `apps/pos/src/components/open-shift-dialog.tsx`.
- Create: `apps/pos/src/hooks/use-topology.ts`, `apps/pos/src/hooks/use-shift.ts`, `apps/pos/e2e/context.spec.ts`.
- Create: `server/spec/requests/spree/pos/topology_spec.rb`, `server/spec/workflows/spree/pos/open_shift_spec.rb`, `server/spec/factories/spree/pos.rb`.
- Modify: `server/config/routes.rb`, `server/config/initializers/spree.rb`, POS context controller, shell và locale files từ phase 2.

## Implementation Steps

1. Viết trước tests Store/branch IDOR, guessed incidental IDs, disable/revoke và hai connections cùng mở drawer.
2. Sinh migration có FK/index/unique active shift; dùng `Spree.admin_user_class`, không hardcode user class.
3. Cài context/access policy, capability registry và request scope server; không grant write_orders/payments/refunds.
4. Cài CRUD/config/disable có audit và pagination; payment config chỉ trả capabilities/public labels, không secrets.
5. Cài OpenShift với lock, float validation và owner; shift DTO chưa tuyên bố có full close/reports.
6. Làm manager topology forms, selector và open-shift dialog; map 422 inline và 403 giữ nguyên context an toàn.
7. Xử lý đổi branch/register khi request đang chạy: abort/resolve trước; source drafts giữ đúng chi nhánh cũ.
8. Cài action-bound Approval primitives và expiry/revocation tests, chưa dùng shared PIN hoặc reusable admin token.
9. Chạy browser test disable branch/staff khi session đang mở; manager chỉ recovery bằng capability riêng.
10. Gate dự kiến: `pnpm spree rspec spec/requests/spree/pos/topology_spec.rb spec/workflows/spree/pos/open_shift_spec.rb` và app checks.

## Success Criteria

- [ ] A02, A03: guessed IDs/core APIs không vượt quyền; membership được kiểm lại từng mutation.
- [ ] A04: đổi context không lộ cache hoặc đổi location của đơn có sẵn.
- [ ] A05, A06: approval primitive và disable/revoke có audit/recovery path, không mất lịch sử.
- [ ] F15 đầu vào: unique active drawer + opening float được chứng minh race-safe trước thu cash.
- [ ] W08: selector/forms/open-shift dùng được bằng keyboard và tablet; dữ liệu từ API thật.

## Risk Assessment

- Tưởng preferred location là enforce: chỉ lưu mapping tại đây; phase 6/8 vẫn kiểm strict routing bằng workflow.
- Khóa nhầm manager recovery khi disable: tách new-sale permission với audited resolution.
- Chưa chốt ngưỡng approval: default tắt hành động nhạy cảm đến khi manager cấu hình, không ngầm unlimited.

## Next Steps

Phase 4 dùng typed context và active shift; phase 9 mở rộng close barrier/cashbook, không tạo Shift model khác.
