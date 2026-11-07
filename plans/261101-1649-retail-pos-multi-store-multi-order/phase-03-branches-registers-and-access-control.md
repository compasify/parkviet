---
phase: 3
title: "Chi nhánh, quầy, quyền và mở ca tối thiểu"
status: completed
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

- [x] A02, A03: guessed IDs/core APIs không vượt quyền; membership được kiểm lại từng mutation. *(`topology_access_spec.rb`, `topology_spec.rb`)*
- [x] A04: đổi context không lộ cache hoặc đổi location của đơn có sẵn. *(Server chặn đổi kho khi còn đơn nháp; e2e `keyboard-context.spec.ts` kiểm ca của quầy cũ không hiện khi đổi quầy. Stale cache sau đổi store/logout vẫn theo phase 2 → phase 11.)*
- [x] A05, A06: approval primitive và disable/revoke có audit/recovery path, không mất lịch sử. *(`topology_access_spec.rb`)*
- [x] F15 đầu vào: unique active drawer + opening float được chứng minh race-safe trước thu cash. *(`open_shift_race_spec.rb`: hai connection PostgreSQL thật)*
- [ ] W08: selector/forms/open-shift dùng được bằng keyboard và tablet; dữ liệu từ API thật. *(Keyboard + 3 viewport đã pass với API mock. Chạy trên API thật và thiết bị thật chuyển phase 11.)*

## Risk Assessment

- Tưởng preferred location là enforce: chỉ lưu mapping tại đây; phase 6/8 vẫn kiểm strict routing bằng workflow.
- Khóa nhầm manager recovery khi disable: tách new-sale permission với audited resolution.
- Chưa chốt ngưỡng approval: default tắt hành động nhạy cảm đến khi manager cấu hình, không ngầm unlimited.

## Next Steps

Phase 4 dùng typed context và active shift; phase 9 mở rộng close barrier/cashbook, không tạo Shift model khác.

## Checkpoint 04/11/2026

- **In progress.** Đã có topology, membership/capability, ca tối thiểu, audit/approval primitives, selector phân trang và xử lý disable/recovery; có request/workflow tests và browser mock. Approval đã bind subject/action/revision nhưng chưa nối discount phase 5.
- Cần hoàn tất evidence A02–A06 và F15, đặc biệt kiểm IDOR/bypass đầy đủ, đổi context/revoke đồng thời, race hai connection mở cùng drawer và kiểm keyboard/tablet với API thật. Không coi topology location mapping là proof strict stock.
- Chi tiết và thứ tự quay lại: [bàn giao phase 1–4](./reports/phase-01-04-handoff.md).

## Đóng phase 06/11/2026

Người dùng yêu cầu review code, sửa lỗi, bổ sung test theo yêu cầu phase rồi đóng.

**Lỗi đã sửa:**

- Thu hồi approval đã dùng ghi đè `consumed` thành `revoked`, làm mất lịch sử. Nay chỉ approval `active` mới thu hồi được, còn lại trả 409 (`Approval#revoke!`).
- `expires_at` của approval không bị giới hạn: có thể ở quá khứ hoặc nhiều năm sau. Nay phải nằm trong tương lai và không quá `Approval::MAX_TTL` (1 giờ). Đây là trần kỹ thuật, không phải chính sách quản lý.
- Quầy đã có ca hoặc đơn vẫn chuyển được sang chi nhánh khác, khiến ca cũ trỏ sai chi nhánh. Nay trả 422.
- Đổi kho bán của chi nhánh khi còn đơn nháp `editing`/`parked` làm các đơn đó âm thầm lấy hàng từ kho mới lúc hoàn tất. Nay trả 422; cập nhật chạy dưới row lock.
- Disable/enable lặp lại ghi đè `disabled_at` và thêm audit trùng. Nay idempotent, chạy dưới row lock.
- Mở ca kiểm lại quyền sau khi lấy lock nhưng dùng policy cũ. Nay đọc lại staff và membership bên trong lock.

**Test mới:**

- `server/spec/requests/spree/pos/topology_access_spec.rb` (14 examples): ID đoán từ store khác, ID phụ (kho, staff, quầy khác chi nhánh), membership bị gỡ quyền/vô hiệu giữa phiên, quầy/chi nhánh bị khóa, disable lặp, chỉ RECOVER mới enable, quầy đã dùng không đổi chi nhánh, đơn nháp giữ kho và nguồn, approval hết hạn/quá trần/thiếu quyền/thu hồi/đã dùng/approver mất quyền.
- `server/spec/integration/spree/pos/open_shift_race_spec.rb` (2 examples): hai connection PostgreSQL cùng chờ lock một quầy thì chỉ một ca và một audit được tạo. Bỏ qua lock ứng dụng thì unique index vẫn từ chối ca mở thứ hai. Spec chạy ngoài transaction và tự xóa đúng bản ghi nó tạo; đã kiểm test DB về lại chỉ có store mặc định.
- `apps/pos/e2e/keyboard-context.spec.ts` (2 × 3 viewport): đăng nhập, chọn chi nhánh/quầy, mở ca hoàn toàn bằng bàn phím, lỗi 422 hiện tại form và giữ focus; đổi quầy khi context mới còn tải thì không hiện ca của quầy cũ và selector bị khóa tới khi xong.

**Kết quả 06/11/2026:** `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos` 162 examples, 0 failures. Sau đó, chỉ chạy lại 4 spec topology/shift: 25 examples, 0 failures. Rubocop sạch trên các file mới/sửa (vẫn còn offense cũ ở `approval.rb:59`, `approvals_controller.rb`, `branches_controller.rb`). `apps/pos`: lint, typecheck, 43 unit pass; `pnpm test:e2e` 93 passed / 6 skipped (live API opt-in), chạy hai lượt.

**Còn lại (phase 11):** W08 trên API thật và thiết bị thật; bypass core API toàn diện ngoài các endpoint đã thử.
