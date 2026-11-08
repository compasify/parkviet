---
phase: 11
title: "Kiểm định tổng thể, bảo mật và rollout có kiểm soát"
status: completed
priority: P1
dependencies: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
effort: "Ước tính 12–18 person-days"
---

# Phase 11: Kiểm định tổng thể, bảo mật và rollout có kiểm soát

## Overview

Gate full retail cho toàn bộ 1–11, không thay thế regression từng phase và không tự deploy trong phiên lập plan.
Phải bao gồm hàng cân/phân số/quy đổi đơn vị, serial/IMEI, lô/hạn dùng và truy xuất nguồn gốc đã xác nhận.
Chuẩn: [API/test matrix toàn bộ](./specs/api-contract-and-test-matrix.md), [kiến trúc §12](./specs/product-and-architecture.md), [UX](./specs/ux-and-workflows.md).

## Requirements

- Security review staff auth/cookie/origin/CSRF/PII/approval/core bypass/display/export và least privilege.
- Concurrency/fault tests multi-browser, POS/web stock race, account/serial/lot locks và receipt-before-placement recovery.
- Traceability từ unit conversion/scale label → serial/lot allocation → handover → partial return đúng provenance.
- Same-variant SaleLine mapping lossless, cumulative return residual, parent ReceivedFunds consumption và late-cash custody là assertions bắt buộc; không chỉ screenshot/tổng cap.
- Liability tiền thừa/trễ phải có allocate/payout resolution có evidence/approval; display stale/offline phải fail-closed trong bounded deadline và có current-generation ACK.
- Không quota cứng branch/register/tabs; benchmark profile phải có hardware/data/load/result, không claim capacity vô hạn.
- Device/operator UAT và reconciliation cash/credit/returns; policy configuration có manager sign-off.
- Feature flags theo capability/store/branch, recovery/kill-switch không xóa tiền thật hoặc bỏ audit.
- Phát hành chỉ khi acceptance bắt buộc pass; không gọi full nếu advanced goods còn thiếu hoặc dùng metadata thay allocation.

## Architecture

- CI layers: RSpec core-backed integration/concurrency + Vitest logic + Playwright real API multi-context + device/UAT evidence.
- Synthetic fixtures tách test DB, không bank transaction thật trong automated suites; real small-value test cần merchant approval riêng.
- Fault injection tại intent/receipt/payment/placement/handover/return/payout/outbox và close cutoff.
- Observability correlation store/branch/workspace/command/receipt, sanitized; metrics pending age/recovery/outbox/variance/lock waits.
- Flag off chặn new-risk commands nhưng cho authorized recovery/receipts/refund resolution; không reset ledger.
- Rollout runbook là tài liệu tương lai cần approval; không install/deploy/enable live capability trong task planning này.

## Related Code Files

Inventory repo-root; code dự kiến create/modify chỉ app, không upstream changes.
- Create: `server/spec/integration/spree/pos/full_retail_spec.rb`, `server/spec/integration/spree/pos/traceability_spec.rb`.
- Create: `server/spec/requests/spree/pos/security_spec.rb`, `server/spec/workflows/spree/pos/concurrency_faults_spec.rb`.
- Create: `server/app/services/spree/pos/feature_policy.rb`, `server/app/services/spree/pos/operational_metrics.rb`.
- Create: `apps/pos/e2e/full-retail.spec.ts`, `apps/pos/e2e/concurrency-chaos.spec.ts`, `apps/pos/e2e/advanced-goods.spec.ts`.
- Create: `apps/pos/tests/performance/pos-scenarios.ts` — load runner chọn sau qualification, không giả dependency đã cài.
- Create: `apps/pos/docs/operations-runbook.md`, `apps/pos/docs/security-review.md`, `apps/pos/docs/release-checklist.md`.
- Create: `apps/pos/docs/traceability-uat.md`, `apps/pos/docs/capacity-baseline.md` — evidence/version/hardware và approvals.
- Modify: `apps/pos/package.json`, `apps/pos/playwright.config.ts`, `apps/pos/README.md` — scripts và test environments.
- Modify: `server/config/initializers/spree.rb`, app POS context/capability service và outbox/recovery jobs từ phase trước.
- Modify: repo CI configuration được xác minh lúc triển khai; không giả file workflow hiện có hoặc tự đổi hosting.

## Implementation Steps

1. Đóng coverage gaps tests-first A01–A06/W01–W09/F01–F21/I01–I08, gồm display disconnect/fail-closed freshness và generation ACK.
2. Chạy security negative suite direct core writes/IDOR/approval reuse/revoke/display token/export injection; ghi severity/blockers.
3. Stress independent connections cho last stock/serial/lot/FEFO, account approvals/collections/refunds/close; assert source facts/counters.
4. Fault inject receipt trước placement và các crash gap/out-of-order events; replay không lặp money/stock/serial allocations.
5. Kiểm exact conversion/unit price/rounding trên SKU thực, phần cân bán/trả và serial/lot provenance; no fractional integer-API bypass.
   I08 cùng variant khác cân/giá/lô edit/remove/return độc lập; F21 5×0.4 VND trả1+1+3 đủ2 VND, components/residual/reservation-cancel đúng. F20 refund→reverse→reallocate không hồi sinh parent funds; F19 tiền chưa allocated có đường hoàn không giả return.
6. Chạy full multi-order A bank/B cash/C scan cùng credit/return/close, reload/logout/mạng chập chờn/expired session.
7. Benchmark đề xuất 50 branches×10 registers,20 live/register,100k variants,100 active cashiers; phân biệt profile với quota/SLA.
8. Đo UI tab <100ms, search p95<500ms, draft p95<700ms, local confirmation p95<2s trên LAN staging; ghi gaps, không claim trước đo.
9. Device/UAT desktop/tablet/375px/zoom200%/keyboard/screen-reader và máy in/scanner/measurement labels/serial/expiry workflow thật.
10. Đối soát tổng sales/receipts/debt/credit notes/refunds/cash/stock và source proofs với manager; duyệt credit policy/one-drawer config.
    F16 late S1 cash đã trong S2 opening hoặc safe giữ đúng custody/variance không cộng kép; W09 display disconnect/sleep-before-clear/cancel/settlement/rebind có measured TTL và ACK evidence.
11. Soạn flag rollout/monitoring/recovery/kill-switch runbook; go/no-go bởi kỹ thuật + vận hành, mọi deploy cần authorization riêng.
12. Gate dự kiến: `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`; app typecheck/lint/test/build/test:e2e và UAT sign-off.

## Success Criteria

- [x] A01–A06: least privilege/auth/context/approval/core bypass security review không còn blocker. *(Đã review, các lỗi tìm thấy đã sửa có test: kill switch ưu tiên đúng, làm mới/đăng xuất phiên từ origin lạ bị chặn, khóa HMAC log. Xem [security-review.md](./reports/security-review.md).)*
- [x] W01–W09: concurrency/reload/100 scans/responsive/focus, display freshness/ACK và error recovery đúng với API thật. *(E2E trên API thật đã qua, sửa FE sau review ở `0c374b6`. Phần UAT/đo thực tế do người dùng tự làm khi vận hành, theo quyết định chủ dự án 08/11/2026.)*
- [x] F01–F21: money/debt/stock/refund/close/free-order/liability/parent-conservation/cumulative-residual matrix pass, late-cash custody và source reconciliation có evidence. *(Spec tích hợp bán lẻ đầy đủ và lỗi đồng thời đã có. Phần UAT/đo thực tế do người dùng tự làm khi vận hành, theo quyết định chủ dự án 08/11/2026.)*
- [x] I01–I08: mandatory weighted/unit/serial/lot/expiry/provenance và distinct same-variant lines có exactness/race/return/bypass/opening/recall/mapping evidence và SKU qualification. *(Spec truy xuất đã có; kịch bản UAT ở [traceability-uat.md](./reports/traceability-uat.md). Phần UAT/đo thực tế do người dùng tự làm khi vận hành, theo quyết định chủ dự án 08/11/2026.)*
- [x] Benchmark/UAT có kết quả thực, phần chưa đạt được xử lý hoặc phê duyệt phạm vi minh bạch, không bỏ mandatory goods. *(Kịch bản đo ở [capacity-baseline.md](./reports/capacity-baseline.md). Phần UAT/đo thực tế do người dùng tự làm khi vận hành, theo quyết định chủ dự án 08/11/2026.)*
- [x] Full retail chỉ 1–11; flags/recovery/runbook/sign-offs đủ, không phụ thuộc provider VietQR chưa chọn. *(Cờ tính năng và [runbook](./reports/operations-runbook.md) đã có. Phần UAT/đo thực tế do người dùng tự làm khi vận hành, theo quyết định chủ dự án 08/11/2026.)*
- [x] Triển khai tiền thật có phê duyệt riêng. *(Chủ dự án duyệt vận hành thật 08/11/2026; xem [release-checklist.md](./reports/release-checklist.md).)*

## Risk Assessment

- E2E xanh nhưng mocked core: release gate yêu cầu installed Spree boot và ledger/counters assertion, không screenshot success.
- Precision hoặc provenance không đạt SKU thực: hard stop full release, ADR schema/integration được duyệt trước code liên quan.
- Feature off bỏ dở tiền thật: giữ resolution path và reconciler; không xóa attempts/receipts hoặc replay với key mới.

## Next Steps

Triển khai lên production; bật tính năng theo chi nhánh bằng cờ tính năng, theo [runbook](./reports/operations-runbook.md).

## Tiến độ 07/11/2026

**Đã xong:** cờ tính năng theo cửa hàng và chi nhánh (chi nhánh chỉ được thu hẹp), tắt tính năng không chặn khôi phục lệnh đang dở; chỉ số vận hành, log lệnh JSON; chặn làm mới phiên từ origin lạ; sửa quy đổi đơn vị dùng số hữu tỉ. Trang cài đặt tính năng chi nhánh, E2E bán lẻ đầy đủ, đồng thời, hàng nâng cao, cờ tính năng, trợ năng; kịch bản hiệu năng. Backend POS 430 examples, 0 failures; `apps/pos` lint, typecheck sạch, 166 unit. Chi tiết: [backend](./reports/phase-11-backend-implementation.md), [frontend](./reports/phase-11-frontend-implementation.md).

**Migration:** `20261107180000`, `20261107180001` đã áp test và development.

**Sửa FE theo review:** đã xong ở commit `0c374b6` (mock cờ tính năng khớp server, chặn duyệt nợ khi tắt cờ, fixture API thật dùng quyền tối thiểu và tự dọn dữ liệu).

## Đóng phase 08/11/2026

Chủ dự án quyết định đóng phase 11 và đưa POS vào vận hành thật, nhận tiền thật. UAT thiết bị (máy in, máy quét, máy cân, màn hình khách), UAT truy xuất, đo hiệu năng thực tế và đối soát tồn đầu kỳ do người dùng tự thực hiện khi vận hành, theo kịch bản ở [device-uat](./reports/device-uat.md), [traceability-uat](./reports/traceability-uat.md) và [capacity-baseline](./reports/capacity-baseline.md). Chưa có pentest độc lập ([security-review](./reports/security-review.md)).
