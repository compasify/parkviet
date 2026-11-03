---
title: 'POS bán lẻ đầy đủ: đa cửa hàng, đa quầy và nhiều đơn đồng thời'
description: >-
  Kế hoạch POS độc lập với thu tiền, công nợ, ca quỹ và truy xuất hàng cân/đơn
  vị, serial/IMEI, lô/hạn dùng.
status: in-progress
priority: P1
branch: main
tags:
  - feature
  - frontend
  - backend
  - api
  - auth
  - critical
  - pos
  - retail
blockedBy: []
blocks: []
created: '2026-11-01T09:51:04.608Z'
createdBy: 'ck:plan'
source: skill
---

# POS bán lẻ đầy đủ: đa cửa hàng, đa quầy và nhiều đơn đồng thời

## Overview

**Điều chỉnh ưu tiên 03/11/2026 (ưu tiên hơn các gate cũ về tách gói):** Xây POS cơ bản chạy được theo hành vi chuẩn Spree, hạn chế thay đổi backend. Yêu cầu phân biệt từng gói cùng variant nhưng khác giá/lô chuyển sang [plan riêng](../261103-pos-goi-hang-truy-xuat/plan.md), không chặn app shell hoặc POS cơ bản. POS cơ bản không được hứa hoặc cho xử lý như thể hỗ trợ các gói đó; các gate an toàn tiền, quyền và tồn kho trong phạm vi bật vẫn bắt buộc. Những yêu cầu nâng cao khác không mặc nhiên được coi là đã hoàn tất hoặc đã loại bỏ.

**Đang triển khai phase 1; chưa xác minh được runtime backend.** Người dùng đã cài OrbStack và yêu cầu tiếp tục; Docker client/daemon đã đáp ứng, đang kiểm tra môi trường container và test DB qua Spree CLI. Lần eject trước đổi compose rồi dừng vì thiếu Docker; chưa chứng minh DB được chuẩn bị. API/paths vẫn là đề xuất; xem [runtime spike results](./reports/runtime-spike-results.md).
Bảng phase/status bên dưới do CLI quản lý; không coi phase 1 hoàn tất khi các qualification gates chưa chạy.

### Tài liệu chuẩn
- [Product và architecture](./specs/product-and-architecture.md): phạm vi/invariants/source-runtime gates.
- [UX và workflows](./specs/ux-and-workflows.md): cashier layout, nhiều tab, thu/đổi trả/ca.
- [API contract và test matrix](./specs/api-contract-and-test-matrix.md): endpoints proposed, A/W/F/I acceptance IDs.
- [Release roadmap](./specs/release-roadmap.md): sandbox milestones và human deployment/go-no-go gates.
- [Research và decision log](./research/pos-research-and-decisions.md): nguồn chính thức, đề xuất và defaults chưa duyệt.
- [Planning verification](./reports/planning-verification.md): review disposition, correction approval và giới hạn kiểm chứng.

### Phạm vi đã xác nhận
- POS bán lẻ đầy đủ: nhiều Branch dưới merchant Store, nhiều Register, nhiều đơn đồng thời; một quầy một physical drawer.
- Cash, bank manual, external-card attest, split tender, công nợ/thu nợ; manager cấu hình credit policy trước bật.
- Hàng cân/phân số/quy đổi đơn vị, serial/IMEI, batch/lot/expiry và traceability là **bắt buộc full release**, không metadata-only.
- Khách/discount/price override theo quyền, strict branch stock, trả/đổi/hoàn có evidence, đóng ca/quỹ/báo cáo và bill/display/thiết bị.
- Không hardcode quota cửa hàng/quầy/tab; pagination/virtualization và benchmark không phải cam kết capacity vô hạn.
- `apps/pos` React 19/Vite/TS/Query/Router/i18next package độc lập; không tạo root workspace nếu chưa có lý do được duyệt.
- Một Rails backend `server/app` namespace `Spree::Pos`, custom `/api/v3/admin/pos/*`; không sửa upstream Spree hoặc website checkout.
- VietQR tự động là adapter tương lai, không blocker POS; public provider/merchant ngân hàng chưa được chọn, không coi SePay/payOS đã chốt.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Contracts and UX validation](./phase-01-contracts-and-ux-validation.md) | In Progress |
| 2 | [App shell and staff authentication](./phase-02-app-shell-and-staff-authentication.md) | In Progress |
| 3 | [Branches registers and access control](./phase-03-branches-registers-and-access-control.md) | Pending |
| 4 | [Concurrent order workspace](./phase-04-concurrent-order-workspace.md) | Pending |
| 5 | [Catalog customers and discounts](./phase-05-catalog-customers-and-discounts.md) | Pending |
| 6 | [Split tender and settlement](./phase-06-split-tender-and-settlement.md) | Pending |
| 7 | [Credit sales and receivables](./phase-07-credit-sales-and-receivables.md) | Pending |
| 8 | [Inventory handover returns and exchanges](./phase-08-inventory-handover-returns-and-exchanges.md) | Pending |
| 9 | [Shifts cashbook and reporting](./phase-09-shifts-cashbook-and-reporting.md) | Pending |
| 10 | [Receipts customer display and devices](./phase-10-receipts-customer-display-and-devices.md) | Pending |
| 11 | [Quality security and rollout](./phase-11-quality-security-and-rollout.md) | Pending |

## Dependencies

Không có unfinished plan khác theo scan; report VietQR trước chỉ là research, không dependency đã duyệt.
Luồng chính: `1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11`; dependency IDs chi tiết trong từng phase.
Capability hàng cân/serial/lô phụ thuộc proof precision/base-unit/serial-lot; capability tách gói cùng variant phụ thuộc plan riêng. POS cơ bản có thể phát triển theo hành vi Spree; phase 6 vẫn phụ thuộc financial/runtime proof phù hợp phạm vi bật.
Financial primitives/cash movements ở phase 6, debt ở 7, return/provenance ở 8, projection/close mở rộng ở 9.

## Gates rủi ro cao
- Runtime/source/mount phải trùng evidence; backend chỉ qua `pnpm spree ...`. Nếu chưa ejected, xin developer duyệt trước eject vì tác động DB; không tự reset.
- Core integer quantity: base-unit normalization chỉ dùng cho SKU chứng minh exact decimal price/tax/discount và bán-trả; không truyền fractional vào integer API.
- Precision/schema/serial-lot integration không đủ → hard gate ADR approved trước code liên quan; không fork upstream hoặc gọi bản thiếu traceability là full.
- Walk-in/pickup, draft discount persistence, partial PaymentSession, credit placement, strict routing, refund evidence và core permission bypass phải spike thật.
- Actual receipt trước placement bền vững; unknown/retry không thu hai lần; nợ không fake paid; credit-return balance không ép bằng core `amount_due`.
- Tiền thừa/trễ có liability payout hoặc explicit allocation; parent ReceivedFunds không giải phóng lại tiền đã refund/reserved/unknown khi reverse child allocation.
- Immutable SaleLine identity/core mapping lossless là gate capability tách gói ở plan riêng, không phải gate POS cơ bản. Không bán các gói khác giá/lô như thể phân biệt được; cumulative return entitlement/residual vẫn là gate cho bất kỳ nghiệp vụ trả/hoàn nào được bật.
- Close barrier/immutable facts và late-cash custody/variance không double-count opening ca mới; serial/lot FEFO races và original return provenance là release blockers.
- Display có bounded local freshness deadline + current-generation ACK; server revoke không đủ xóa QR offline/đã chụp.

## Milestones và effort
- **1–5: preview**, chỉ auth/context/draft/catalog/customer/discount và advanced-goods input; không thu tiền/giao hàng vận hành.
- **1–6/7: financial integration sandbox-only**, không tự cấp phép cash pilot tiền thật từ checklist phase 6.
- Pilot tiền thật là quyết định triển khai riêng: áp ngay phase 11 gates liên quan, qualified ordinary SKUs, refund/close/reconciliation đã test, support owner và human deployment authorization rõ.
- **1–11: full retail**, phải đủ công nợ/trả đổi/ca quỹ/thiết bị/security và weighted/unit/serial/lot/expiry traceability; không chỉ giỏ + nút pay.
- Ước tính tổng **117–179 person-days**, không là lịch cam kết; gồm backend/UI/tests. Re-estimate khi ADR precision/schema hoặc thiết bị mở rộng scope kỹ thuật.
- Acceptance A01–A06/W01–W09/F01–F21/I01–I08: từng phase tests thật, phase 11 full suite/UAT/benchmark; chưa claim test pass.

## Review trước triển khai
- Duyệt ADR precision/stock integration, ngành hàng/SKU thực và data receipt/import/transfer traceability.
- Manager chốt limit/due date/overdue, discount/refund/variance/return-window/cross-branch policies; chưa cấu hình thì capability rủi ro tắt.
- Chọn printer/scanner/display và quy trình payout/reconciliation; bill POS không phải hóa đơn điện tử pháp lý.
- Người dùng đã duyệt **áp dụng toàn bộ correction review** và sau đó yêu cầu triển khai toàn bộ plan, cho phép eject. Deploy/nhận tiền thật vẫn cần authorization riêng; runtime proofs chưa chạy, phase 1 đang in-progress.
