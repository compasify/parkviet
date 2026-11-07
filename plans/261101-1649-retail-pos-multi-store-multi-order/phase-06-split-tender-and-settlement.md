---
phase: 6
title: "Thu nhiều phương thức và saga hoàn tất đơn"
status: completed
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

- Phương thức ban đầu: tiền mặt và chuyển khoản cá nhân do nhân viên kiểm tra/xác nhận; QR là nghiệp vụ riêng về sau, không giả kết nối ngân hàng. Quyết định và giới hạn recovery: [hợp đồng tiền](./reports/pos-contract-decisions.md#tiền--gate-đóng).
- POS cần mạng để bắt đầu bán; lưu browser chỉ hỗ trợ recovery khi mất mạng giữa giao dịch, không cho bắt đầu bán offline. Việc khách rời quầy khi tiền/đơn chưa được server xác nhận chưa được chốt; không tự mặc định quyền giao hàng ngoại lệ.
- Hỗ trợ lưu cục bộ intent/evidence tối thiểu để recovery qua reload/đóng browser và kết nối lại; phân biệt chưa đồng bộ, server đã ghi nhận nhưng đơn chưa hoàn tất, và hoàn tất. Không dùng `sessionStorage` TTL 12h hiện có làm ledger tiền; không coi lưu browser là đã nhận trên server.
- Đồng bộ chỉ sau xác thực lại đúng scope/quyền và tra trạng thái server; retry duy nhất cùng operation/key/payload theo contract replay bền vững. Nếu trạng thái không thể xác định, bị từ chối, key hết hạn hay dữ liệu xung đột: giữ attention, không tạo key thu mới. Không tự xóa records chưa giải quyết khi logout/TTL; có hướng dẫn đối soát thủ công khi browser bị xóa, mất máy hoặc storage lỗi.
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
- Completion gate receipts completed + approved credit sau phase 7, no unresolved attempt, đúng kho branch, policy tồn theo loại đơn và active cash shift. Với hàng thực tế tại quầy thiếu tồn chỉ cảnh báo, không chặn vì thiếu tồn; trước vận hành phải qualify cảnh báo, stock effects và tracking theo [policy](./reports/pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng). Giao sau và serial/lô có gate riêng.
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
- Create (tên dự kiến): browser financial recovery store/queue và tests riêng, ví dụ IndexedDB; backend command status/replay và durable ledger phải có trước khi nối đồng bộ thực. Không reuse `apps/pos/src/lib/uncertain-intents.ts` làm dữ liệu tài chính.
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
   Cài browser recovery storage sau khi định nghĩa schema/version, giới hạn dữ liệu, scope/quyền và cơ chế atomic/cross-tab; kiểm storage unavailable/quota/eviction, mất máy, logout/đổi staff, revoke, offline-reload, server committed response lost, delayed original, concurrent replay và operation retention. Khôi phục phải tra server, không đồng bộ mù hay tin clock/browser state.
9. Cài guarded completion + minimal strict-location handover, stock/event retry-safe; no unpaid pending bypass.
10. Dựng split rows, received/pending/remaining/change và recovery UI; callbacks đúng tab, tab B/C không bị khóa bởi A.
11. Tạo sandbox QA gate F01/F03/F04/F12/F13 và I03/I06 fail-closed; không cho checklist này cấp phép nhận tiền thật.
12. Gate: `pnpm spree rspec spec/workflows/spree/pos/settlement_spec.rb spec/workflows/spree/pos/settlement_recovery_spec.rb spec/workflows/spree/pos/funds_conservation_spec.rb spec/workflows/spree/pos/liability_payouts_spec.rb` + Playwright multi-order thật.

## Success Criteria

- [x] F01: sale250/card-style bank100/cash handed200/change50 → cash Payment150, drawer +150, confirm lần hai không nhân đôi (sandbox request spec; thẻ thật/gateway vẫn chưa mở).
- [x] F03, F04, F07: partial/unknown/session lifecycle/recovery không auto-paid hoặc thu lại sau crash. *(Fault injection: lỗi giữa confirm rollback sạch rồi retry cùng key ghi đúng một lần; lỗi placement sau khi nhận tiền giữ tiền, recovery job báo `workspace.completion_pending` một lần, retry hoàn tất một lần. Race hai connection: confirm cùng key trả cùng kết quả, hai key khác chỉ một lần nhận tiền — `settlement_race_spec.rb`.)*
- [x] F04 offline: reload/đóng browser giữ recovery intent; commit mất response rồi reconnect cùng key không nhân tiền, Payment hay order; lỗi storage/permission/retention và mất máy tạo attention/manual reconciliation, không báo đã đồng bộ sai hoặc xóa chứng cứ chưa giải quyết. *(Key retry không phụ thuộc editor/revision/lease nên giữ nguyên sau reload; tra receipt trước khi gửi lại; 4xx dứt khoát xóa record, lỗi mạng/5xx giữ; storage lỗi/abort/memory fallback hiện cảnh báo đối soát thủ công; trang chú ý có "Đã đối soát". Unit `financial-command.test.ts`. E2E reload trên API thật chuyển phase 11.)*
- [x] F05, F06: excess/late/distinct actual transfers có ledger/review, commitments serialized ở mức request specs hiện có; concurrency thật hai connection vẫn thuộc gate còn thiếu.
- [x] F19: tiền thừa/trễ allocate hoặc hoàn có evidence/approval, unknown giữ reservation; chưa allocated không tạo fake goods return/core Refund.
- [x] F20 primitive: parent buckets disjoint, không negative/consume kép trong unit/request specs; integration collection→refund→reverse→reallocate phải pass ở phase 7/8 trước bật vận hành.
- [x] A03, A05, F18: no core bypass/client paid flag; zero order có audit và không fake receipt. *(Đơn 0 đ cần quyền duyệt, audit `workspace.complete_zero_total`, không tạo Payment; tiền lẻ VND bị từ chối ở tender/confirm/allocate/unsolicited/payout; POS chỉ ghi Payment lên phương thức thủ công không cần nguồn thẻ.)*
- [x] W01, F12, F13: A chờ/B cash/C scan; handover đúng location và stock effect một lần. *(E2E mock: đơn A giữ tender chuyển khoản "Để chờ", đơn B thu tiền mặt và hoàn tất, A tiếp tục giữ tender; request spec handover trừ tồn một lần. Multi-order trên API thật chuyển phase 11.)*
- [x] Sandbox-only 1–6: chưa full retail/real-money pilot, chưa bật credit/returns/close thiếu gates; tracked SKU chưa phase 8 bị chặn trước thu tiền.

## Risk Assessment

- Core pending coverage quá rộng: restricted gate kiểm completed receipts riêng; không dùng capture default để attest.
- Nhận tiền trước order: immutable evidence + recovery; rollback DB không thể xóa external money reality.
- Ghi liability mà không có lối xử lý hoặc chỉ cap từng Payment sẽ treo/hoàn trùng tiền: bắt buộc inbox, explicit payout/reallocation và shared parent conservation, regression phase 7/8.
- Pilot tiền thật cần quyết định triển khai riêng và áp ngay phase 11 gates liên quan: qualified ordinary SKUs, refund/shift-close/reconciliation tested, support owner, explicit human deployment authorization; không phase 6 tự cấp quyền.

## Next Steps

Phase 7 credit/collections vẫn sandbox; phase 8–10 operational integration, phase 11 full retail. Bất kỳ tiền thật đều cần go/no-go/authorization riêng theo roadmap.

## Checkpoint triển khai

- Backend sandbox hoàn thành ở mức request/workflow specs: migrations `20261105110000` + `20261105112000` đã áp development + test; models/workflows/controllers/routes cho payment methods, tender prepare/confirm/cancel, funds allocate/reverse, unsolicited funds, liability payout request/confirm/resolve, completion và handover đã nối. Cash luôn mặc định có; bank manual follow cấu hình `Spree::PaymentMethod` active hoặc mapping POS tường minh. Capability riêng: `pos.payment.collect` và `pos.payment.resolve`.
- `settlement_spec.rb`: 5/5 pass, gồm F01 bank 100 + cash handed 200/change 50 trên remainder 150, khóa items sau prepare, chặn completion khi chưa có completed receipts, complete/handover trừ tồn đúng một lần, chặn tender tracked SKU, unsolicited 40 ở attention/liability, payout reserve chống double-spend, unknown giữ reservation, allocate/reverse trước placement. `funds_conservation_spec.rb` + `settlement_recovery_spec.rb` pass. Toàn suite backend POS sau thay đổi: **128 examples, 0 failures**.
- Frontend sandbox đã nối: `PaymentPanel` + `TenderEvidenceDialog`, hook `use-tenders`, IndexedDB financial recovery store riêng (`financial-recovery.ts`, không reuse sessionStorage intent), received-funds/liability UI tại `/funds`, payment-attention tại `/payment-attention`, shell cảnh báo/recheck command receipt và split-tender Playwright mock trên desktop/tablet/mobile. Kết quả: **31 unit tests**, lint, typecheck, build và `e2e/split-tender.spec.ts` 3 projects pass. Đây vẫn là sandbox: không gateway/ngân hàng/thẻ thật, không offline-start, không credit/returns/close.
- Allocation detail fix: `Workspace#financial_pos` tính allocations theo `workspace_id` nên tiền unsolicited được allocate vào workspace hiển thị đúng allocated/remaining, đồng thời unapplied cộng đủ buckets từ parent funds liên quan.
- Còn thiếu trước khi coi phase 6 là gate đóng: fault injection mất response/concurrent replay hai connection, e2e API thật/multi-order, recovery sau reload bằng API thật, qualification F16 late-cash custody và sandbox QA gate chính thức. Không dùng checkpoint này để mở tiền thật.

## Review 07/11/2026

Review độc lập backend và frontend tìm thấy các lỗi thật trong luồng tiền; tất cả đã sửa và có test:

- Payout: resolve không kiểm lại trạng thái sau lock nên có thể hủy payout đã xác nhận (tiền đã chi quay lại available); `cancel` giải phóng payout `unknown` không cần bằng chứng. Nay chỉ cancel từ requested/reserved, `failed_no_effect` bắt buộc bằng chứng, người xác nhận phải khác người yêu cầu, chi tiền mặt ghi vào ca mở của người xác nhận; request duyệt approval trước khi khóa funds (tránh deadlock với allocate).
- Ca không quầy (branch-only) không thu được tiền vì bảng tài chính bắt buộc register. Migration `20261107110000_relax_pos_financial_registers` bỏ ràng buộc này và thêm `receiving_account`, `custody`, `custody_note` cho ReceivedFunds.
- Tiền mặt ngoài luồng có thể cộng vào ca đã đóng hoặc ca người khác. Nay tiền mặt `drawer` chỉ vào ca mở của chính người ghi; tiền mặt không nằm trong két hiện tại ghi `held` kèm ghi chú, không tạo cash movement. Chuyển khoản ngoài luồng cần quyền resolve, số tham chiếu và tài khoản nhận.
- Tiền lẻ VND được chấp nhận; tiền mặt đưa thiếu được xác nhận thành thu một phần; chuyển khoản dư không ghi được thành một khoản nhận. Nay từ chối tiền lẻ và đưa thiếu; `received_amount` ghi một ReceivedFunds, phần dư nằm ở unapplied.
- Resolver có thể ghi Payment POS lên cổng thẻ hoặc phương thức đã xóa. Nay chỉ dùng phương thức thủ công active của store, không có thì từ chối.
- Attempt `unknown` không bị trừ khỏi số còn phải thu; Payment void sau reverse vẫn khóa đơn; recovery job ghi trùng và chưa được lên lịch; outbox không claim khi chạy song song. Đã sửa, job chạy theo `config/recurring.yml`.
- Frontend: "100.000" bị đọc thành 100 đ; mọi 409 để lại record khôi phục không xóa được; bằng chứng chuyển khoản điền sẵn giá trị giả và QR trang trí; tiền mặt mặc định bằng số phải thu; lỗi server bị ẩn; lệnh thanh toán không qua serializer của workspace; dialog che các tab khác; key retry đổi sau reload; IndexedDB abort làm treo. Tất cả đã sửa, thêm "Để chờ, bán đơn khác" và dialog có focus trap/Escape.

## Đóng phase 07/11/2026

**Kết quả:** backend POS 203 examples, 0 failures (thêm 10 example settlement và `spec/integration/spree/pos/settlement_race_spec.rb` 4 example race hai connection). `apps/pos`: lint, typecheck sạch, 84 unit pass; `e2e/split-tender.spec.ts` 21 passed trên 3 viewport; toàn bộ Playwright 159 passed / 6 skipped (live API opt-in).

**Migration:** `20261107110000_relax_pos_financial_registers` đã áp **chỉ database test**, cùng `20261107100000` của phase 5. Development chưa áp vì chưa sao lưu được (`pg_dump` trong container bản 17, server PostgreSQL 18).

**Chuyển phase sau:** e2e multi-order và reload/mất response trên API thật (phase 11); đối soát tiền mặt `held` vào chênh lệch ca/két và F16 đầy đủ (phase 9 đóng ca); tích hợp refund thật consume parent funds F20 (phase 7/8). Vẫn sandbox-only: không tiền thật, không cổng thanh toán.
