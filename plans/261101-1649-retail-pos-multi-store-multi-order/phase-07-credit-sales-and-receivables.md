---
phase: 7
title: "Bán chịu, công nợ và thu nợ nhiều lần"
status: pending
priority: P1
dependencies: [3, 5, 6]
effort: "Ước tính 10–15 person-days"
---

# Phase 7: Bán chịu, công nợ và thu nợ nhiều lần

## Overview

Thêm exposure account lock, credit approval và collections dựa trên actual received-funds ledger phase 6.
Công nợ là nghĩa vụ chưa thu, không phải tender completed hoặc doanh số mới khi thu lại.
Chuẩn: [kiến trúc §8](./specs/product-and-architecture.md), [UX §6–7](./specs/ux-and-workflows.md), [API/tests F02,F08–F10](./specs/api-contract-and-test-matrix.md).

## Requirements

- Credit default tắt; manager cấu hình account/limit/due-date/overdue policy rồi mới cấp capability.
- Customer xác định bắt buộc, không khách lẻ; approval bound customer/action/amount/revision/expiry/approver.
- Atomic exposure = open debt + committed exposure + pending approved credit trong configured limit.
- Một collection có một actual receipt, nhiều bounded allocations tới order(s); không tạo sale/stock mới.
- Hai quầy thu cùng nợ hoặc approve đồng thời không vượt limit/remaining; excess thật vào liability/review.
- Receivable balance sau credit notes/allocations không suy thẳng từ core `order.amount_due` hoặc gán `payment_status`.
- Allocation reversal không giải phóng tiền child đã refund/payout-reserved/unknown; collection phải dùng chung parent conservation/liability resolution phase 6. Partial reverse có chủ đích hoặc reject whole reverse, không hồi sinh receipt balance.

## Architecture

- CreditAccount thuộc customer/store, ReceivableEntry immutable debit/credit-note/allocation/reversal và CollectionAllocation liên kết facts.
- Collection parent tham chiếu ReceivedFunds phase 6; child face allocation histories có reversal, nhưng live spendable cap dùng parent buckets ở canonical §8, không chỉ `sum(active allocations) <= received amount`. Refunded/reserved/unknown portions vẫn consume parent sau reverse.
- Reserve exposure dưới account lock; completion chuyển reservation sang open debt atomic, cancel/reject giải phóng có audit.
- Lock order chuẩn account → resource locks có thứ tự ổn định, phối hợp workspace/shift phase 6 để tránh deadlock.
- POS completion mới tự quyết `payment_pending: true`; core payment status vẫn derive từ actual Payments.
- Return credit-note seam nhận từ phase 8, authoritative receivable projection tách original total/credit notes/receipts/refunds/balance.
- Không tạo Refund cho phần chưa thu, sửa giá bán lịch sử hoặc fake debt Payment để số dư trông khớp.

## Related Code Files

Inventory từ repo root; app-specific paths dự kiến, không upstream modifications.
- Create: `server/app/models/spree/pos/credit_account.rb`, `server/app/models/spree/pos/receivable_entry.rb`, `server/app/models/spree/pos/collection_allocation.rb`.
- Create: `server/app/models/spree/pos/collection.rb`, `server/db/migrate/TIMESTAMP_create_spree_pos_receivables.rb`.
- Create: `server/app/workflows/spree/pos/credit/approve.rb`, `server/app/workflows/spree/pos/credit/commit.rb`, `server/app/workflows/spree/pos/credit/release.rb`.
- Create: `server/app/workflows/spree/pos/collections/receive.rb`, `server/app/workflows/spree/pos/collections/allocate.rb`, `server/app/workflows/spree/pos/collections/reverse.rb`.
- Create: `server/app/services/spree/pos/exposure_calculator.rb`, `server/app/services/spree/pos/receivable_projection.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/credit_accounts_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/workspaces/credit_approvals_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/receivables_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/collections_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/collections/allocations_controller.rb`.
- Create: `apps/pos/src/pages/receivables.tsx`, `apps/pos/src/components/credit-approval-dialog.tsx`, `apps/pos/src/components/collection-dialog.tsx`, `apps/pos/src/hooks/use-receivables.ts`.
- Create: `server/spec/workflows/spree/pos/credit_concurrency_spec.rb`, `server/spec/workflows/spree/pos/collections_spec.rb`, `apps/pos/e2e/credit-collections.spec.ts`.
- Modify: completion/settlement/access policy/routes, customer summary/payment panel và locale files từ phase 3–6.
- Modify: shared `funds_balance.rb`, funds allocation/reversal và `funds_conservation_spec.rb` phase 6; collection delegates shared primitives, không copy cap riêng.

## Implementation Steps

1. Viết trước F02/F08/F09 account races và approval invalidation; dùng independent DB connections, không sequential test giả race.
2. Viết projection tests debit/credit-note/allocations/reversal, bao gồm `amount_due` core không bằng dư nợ POS sau return.
3. Tạo account/ledger/collection schema, immutable entries và unique source links; không sửa/xóa posted facts.
4. Cài policy configure/approve/reserve exposure; customer/amount/revision đổi hoặc approver revoke làm approval invalid.
5. Tích hợp completion commit/release credit; receipts400k + approved debt100k trên sale500k không thành paid.
6. Cài collection receive qua evidence/ReceivedFunds phase 6; payment children chỉ bằng allocation vào đúng orders.
7. Cài allocate/reverse dưới account/resource locks; retry/unknown giữ operation cũ, không phát doanh số/stock effects.
   F20: nhận100k→allocate A100k→refund40k→reverse/reallocate B tối đa60k; thử refund reserved/unknown, concurrent reversal/refund và whole-reversal rejection. Giữ original Payment/refund links, không fake payout để sửa receivable; rerun core integration với phase 8.
8. Làm debt list/aging/customer balance và collection preview nhiều đơn; mask PII theo quyền, filters server-side.
9. UI giải thích original sale, credit notes, actual receipts/refunds và remaining debt; không hiện một core balance gây hiểu sai.
10. Chuẩn bị integration seam Return/Refund với phase 8 cho tiền chưa từng thu; nếu core mismatch, dừng bật returns-credit.
11. Gate: `pnpm spree rspec spec/workflows/spree/pos/credit_concurrency_spec.rb spec/workflows/spree/pos/collections_spec.rb` + app unit/e2e.

## Success Criteria

- [ ] F02: sale500k/cash200k/bank200k/debt100k → actual payments400k, nợ100k, core không paid.
- [ ] F08, A05: concurrent approvals không vượt exposure; stale/revoked approval bị chặn và audit.
- [ ] F09: sale1m collect300k rồi200k → nợ500k, no new sales/stock; nhiều allocations không vượt parent receipt.
- [ ] F19, F20: unapplied collection có resolution; refunded/reserved/unknown parent funds không dùng lại qua reverse/reallocate, integration child refunds là prerequisite trước enable phase 8.
- [ ] F06, F16: concurrent collections/cash next-day gắn current shift, excess thật không mất.
- [ ] F10: projection sau credit notes đúng ledger, không fake Refund/sửa lịch sử giá/payment_status; full return gate phase 8.
- [ ] A02, A03: cashier không đọc nợ hoặc ghi credit ngoài scope; direct core bypass bị chặn.

## Risk Assessment

- Core amount_due không phản ánh credit notes: giữ reconciliation DTO riêng, spike phase 1 và regression phase 8, không ép equality.
- Account/workspace/shift lock deadlock: chốt lock order dùng chung phase 6, timeout/retry an toàn với key cũ.
- Policy chưa duyệt: credit vẫn tắt, không mặc định limit vô hạn hoặc cho manager tự approve trái separation policy.

## Next Steps

Phase 8 nối return credit notes và actual refund evidence; chưa gọi tính năng credit-return hoàn chỉnh trước F10/F11 pass.
