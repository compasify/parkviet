---
phase: 6
title: "Thu nhiều phương thức và saga hoàn tất đơn"
status: pending
priority: P1
dependencies: [1, 3, 4, 5]
effort: "Ước tính 12–18 person-days"
---

# Phase 6: Thu nhiều phương thức và saga hoàn tất đơn

## Overview

Tạo financial primitives ngay khi phát sinh khoản thu, split tender và recovery tiền đã nhận trước placement.
Phase 7 dùng lại sổ nhận tiền này cho collection; phase 9 chỉ mở rộng projection/close, không tạo ledger muộn.
Mốc này **sandbox-only** theo [release roadmap](./specs/release-roadmap.md); hoàn thành phase 6 không cho phép pilot tiền thật.
Chuẩn: [kiến trúc §8–10](./specs/product-and-architecture.md), [UX §6](./specs/ux-and-workflows.md), [API/tests F01–F07](./specs/api-contract-and-test-matrix.md).

## Requirements

- Cash: handed/applied/change riêng; Payment chỉ applied, drawer movement net = handed − change.
- Bank manual và thẻ máy ngoài phải authorized attest evidence; không đọc PAN/CVV hoặc charge card.
- Partial receipts bền vững, pending/unknown không tính đã thu; không sửa giá/khách/items sau nhận tiền.
- Tiền đã về nhưng complete fail giữ `attention/completion_pending`; không rollback sự thật tiền hoặc thu lại.
- No overcommit dưới lock; actual excess/late transfers vẫn lưu đủ và vào unapplied liability/review, không âm nợ.
- Liability inbox có owner/evidence và workflow manager allocate hoặc hoàn phần chưa allocated; không treo tiền thừa/trễ vô thời hạn và không giả goods return/core Refund.
- Parent ReceivedFunds bảo toàn xuyên child Payment/refund/reversal; refunded hoặc reserved/unknown không thể phân bổ lại. Unknown payout giữ reservation tới evidence resolution.
- Credit vẫn tắt đến phase 7; free order không fake zero Payment; no raw `paid/payment_pending/force` input.
- Chặn prepare/confirm tiền tracked SKU khi chưa có stock/traceability capability phase 8; không thu rồi mới phát hiện thiếu serial/lô.
- Guard này chặn khởi tạo/allocate sale settlement, **không xóa/chối sự thật tiền đã tự về**: unsolicited/late bank receipt vẫn post ReceivedFunds → unapplied attention/liability, chưa được complete/giao hàng.

## Architecture

- TenderAttempt + ReceiptEvidence map một ReceivedFunds thực; mỗi allocation child có settlement identity/session/payment theo seam phase 1, unapplied phần thừa không tạo Payment.
- ReceivedFunds là parent financial fact đề xuất dùng chung cho sale/collection; allocations không clone actual receipt.
- Bất biến theo canonical §8: received_net = available_unapplied + allocated_unconsumed + payout_reserved_or_unknown + paid_out (disjoint); cả child Refund và LiabilityPayout consume cùng parent. Reversal chỉ release unconsumed, không hồi sinh paid_out.
- LiabilityPayout durable intent/reserved/submitted-or-unknown/confirmed và failed-no-effect resolution có evidence; riêng permission/approval/beneficiary checks, parent lock, idempotency/outbox. Tiền đã allocated đi core Refund ở phase 8; chưa allocated hoàn trực tiếp không fake Return/Refund.
- CashMovement immutable unique source tạo atomic với receipt posting **khi có physical inflow mới đúng drawer**; late cash evidence đi custody/variance reconciliation theo §10/F16, không tự cộng vào shift hiện tại. AuditEntry/Approval/CommandReceipt dùng từ phase 3–4.
- Saga: durable intent/commitment → external/manual evidence → durable received funds → allocation/settlement → guarded placement.
- Không DB lock qua provider I/O; transactional OutboxEntry + recovery sweep chữa enqueue gap/worker crash.
- Lock/recheck workspace/remaining/shift theo thứ tự chuẩn; replay cùng key/result trước revision conflict.
- Completion gate receipts completed + approved credit sau phase 7, no unresolved attempt, strict branch stock và active cash shift.
- Minimal cash handover gọi core fulfillment qua strict branch guard; phase 8 mở rộng đầy đủ returns/exchanges.

## Related Code Files

Inventory repo-root, names proposed; chỉ tạo trong app, không fake gateway hoặc sửa upstream.
- Create: `server/app/models/spree/pos/tender_attempt.rb`, `server/app/models/spree/pos/receipt_evidence.rb`, `server/app/models/spree/pos/received_funds.rb`.
- Create: `server/app/models/spree/pos/funds_allocation.rb`, `server/app/models/spree/pos/cash_movement.rb`, `server/app/models/spree/pos/outbox_entry.rb`.
- Create: `server/app/models/spree/pos/liability_payout.rb`, `server/app/models/spree/pos/payout_evidence.rb`, `server/app/services/spree/pos/funds_balance.rb` — shared parent cap/evidence cho cả refunds phase 8.
- Create: `server/db/migrate/TIMESTAMP_create_spree_pos_financial_primitives.rb` — FK/unique settlement/source và decimal currency fields.
- Create: `server/app/workflows/spree/pos/tenders/prepare.rb`, `server/app/workflows/spree/pos/tenders/confirm.rb`, `server/app/workflows/spree/pos/workspaces/complete.rb`.
- Create: `server/app/workflows/spree/pos/funds/allocate.rb`, `server/app/workflows/spree/pos/funds/reverse_allocation.rb`, `server/app/workflows/spree/pos/liability_payouts/request.rb`, `server/app/workflows/spree/pos/liability_payouts/confirm.rb`, `server/app/workflows/spree/pos/liability_payouts/resolve.rb`.
- Create: `server/app/services/spree/pos/settlement_adapter.rb`, `server/app/services/spree/pos/strict_location_guard.rb`, `server/app/workflows/spree/pos/orders/handover.rb`.
- Create: `server/app/jobs/spree/pos/recover_settlement_job.rb`, `server/app/jobs/spree/pos/dispatch_outbox_job.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/workspaces/tender_attempts_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/tender_attempts/confirmations_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/workspaces/completions_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/orders/handovers_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/received_funds_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/received_funds/allocations_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/allocations/reversals_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/received_funds/liability_payouts_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/liability_payouts/confirmations_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/liability_payouts/resolutions_controller.rb`.
- Create: `apps/pos/src/components/payment-panel.tsx`, `apps/pos/src/components/tender-evidence-dialog.tsx`, `apps/pos/src/hooks/use-tenders.ts`, `apps/pos/src/pages/payment-attention.tsx`.
- Create: `server/spec/workflows/spree/pos/settlement_spec.rb`, `server/spec/workflows/spree/pos/settlement_recovery_spec.rb`, `apps/pos/e2e/split-tender.spec.ts`.
- Create: `server/spec/workflows/spree/pos/funds_conservation_spec.rb`, `server/spec/workflows/spree/pos/liability_payouts_spec.rb`, `apps/pos/src/pages/received-funds.tsx`, `apps/pos/src/components/liability-payout-dialog.tsx`.
- Modify: routes, permissions, workspace edit/handover guards, shift write lock và locales; bổ sung pending-summary reader.

## Implementation Steps

1. Viết trước F01–F07/F18 với core boot thật: duplicate confirm, capture policy đổi, split sessions và cash/change.
2. Viết fault injection sau nhận tiền/trước Payment/placement/job enqueue; test replay không tạo effect lần hai.
3. Tạo financial schema/unique identities; command retention và receipt audit không phụ thuộc browser storage.
4. Cài prepare reservation theo snapshot/remaining/method capability; canceled/unknown attempts không được coi tiền đã thu.
5. Cài evidence và server attest capability; receiving-account/terminal ref/actor/time, sanitize/mask không tin ảnh khách tự gửi.
6. Post actual funds + allocation + core settlement đã spike; tạo cash movement source-unique cho physical effect mới. Late attest phải giữ received-at/custody và attention nếu chưa reconcile theo F16, không đoán drawer hiện tại nhận thêm tiền.
7. Lưu full excess receipt vào exception/liability; reference trùng nhưng hai khoản thật không tự deduplicate làm mất tiền.
   Cài inbox → explicit eligible allocation hoặc liability payout request/confirm/resolve với evidence/approval. Test F19 concurrent allocation-vs-payout, unknown không giải phóng reservation; allocation reversal chỉ phần unconsumed.
   Tạo shared parent balance/lock primitive và F20 tests cho child refund consumption (integration thật bổ sung phase 7/8); không chỉ cap theo từng Payment.
8. Cài outbox/recovery và command status lookup; timeout trả unknown/202, không phát key mới/charge lại.
9. Cài guarded completion + minimal strict-location handover, stock/event retry-safe; no unpaid pending bypass.
10. Dựng split rows, received/pending/remaining/change và recovery UI; callbacks đúng tab, tab B/C không bị khóa bởi A.
11. Tạo sandbox QA gate F01/F03/F04/F12/F13 và I03/I06 fail-closed; không cho checklist này cấp phép nhận tiền thật.
12. Gate: `pnpm spree rspec spec/workflows/spree/pos/settlement_spec.rb spec/workflows/spree/pos/settlement_recovery_spec.rb spec/workflows/spree/pos/funds_conservation_spec.rb spec/workflows/spree/pos/liability_payouts_spec.rb` + Playwright multi-order thật.

## Success Criteria

- [ ] F01: sale250k/card100k/cash handed200k/change50k → cash Payment150k, drawer +150k, confirm kép không nhân đôi.
- [ ] F03, F04, F07: partial/unknown/session lifecycle/recovery không auto-paid hoặc thu lại sau crash.
- [ ] F05, F06: excess/late/distinct actual transfers có ledger/review, commitments serialized.
- [ ] F19: tiền thừa/trễ allocate hoặc hoàn có evidence/approval, unknown giữ reservation; chưa allocated không tạo fake goods return/core Refund.
- [ ] F20 primitive: parent buckets disjoint, không negative/consume kép; integration collection→refund→reverse→reallocate phải pass ở phase 7/8 trước bật vận hành.
- [ ] A03, A05, F18: no core bypass/client paid flag; zero order có audit và không fake receipt.
- [ ] W01, F12, F13: A chờ/B cash/C scan; handover đúng location và stock effect một lần.
- [ ] Sandbox-only 1–6: chưa full retail/real-money pilot, chưa bật credit/returns/close thiếu gates; tracked SKU chưa phase 8 bị chặn trước thu tiền.

## Risk Assessment

- Core pending coverage quá rộng: restricted gate kiểm completed receipts riêng; không dùng capture default để attest.
- Nhận tiền trước order: immutable evidence + recovery; rollback DB không thể xóa external money reality.
- Ghi liability mà không có lối xử lý hoặc chỉ cap từng Payment sẽ treo/hoàn trùng tiền: bắt buộc inbox, explicit payout/reallocation và shared parent conservation, regression phase 7/8.
- Pilot tiền thật cần quyết định triển khai riêng và áp ngay phase 11 gates liên quan: qualified ordinary SKUs, refund/shift-close/reconciliation tested, support owner, explicit human deployment authorization; không phase 6 tự cấp quyền.

## Next Steps

Phase 7 credit/collections vẫn sandbox; phase 8–10 operational integration, phase 11 full retail. Bất kỳ tiền thật đều cần go/no-go/authorization riêng theo roadmap.
