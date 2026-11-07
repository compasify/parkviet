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

**Phạm vi đã duyệt 04/11/2026:** Phase 1 chốt contracts và kiểm chứng nền tảng cho POS siêu thị cơ bản; proof chuyên sâu tiếp tục tại phase 2–9/11 theo [bảng trách nhiệm](./phase-01-contracts-and-ux-validation.md). POS cần mạng để bán, chỉ bán giao ngay tại quầy; mất mạng giữa giao dịch là recovery, không phải chế độ bán offline. Giao sau không thuộc POS cơ bản; đồng bộ giao sau cho ngành ăn uống là nhu cầu tương lai. Chuyển proof không đồng nghĩa đã pass hoặc cho phép bật capability.

**Quyết định tồn kho 04/11/2026:** bán trực tiếp khi hàng thực tế đã có tại quầy: tồn không đủ chỉ cảnh báo, không tự chặn thanh toán hoặc bắt giữ đủ tồn trước thu; tracking stock xử lý lệch và xung đột online. Vẫn phải ghi đúng kho, có bằng chứng/đối soát và stock effects một lần trước mở bán thật. Quyết định này ưu tiên hơn các yêu cầu cũ về chặn thiếu tồn/giữ tồn cho đơn tại quầy; không áp tự động cho giao sau, serial/lô hoặc quyền. Chi tiết và gate: [quyết định tồn kho](./reports/pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng).

**Điều chỉnh ưu tiên 03/11/2026 (ưu tiên hơn các gate cũ về tách gói):** Xây POS cơ bản chạy được theo hành vi chuẩn Spree, hạn chế thay đổi backend. Yêu cầu phân biệt từng gói cùng variant nhưng khác giá/lô chuyển sang [plan riêng](../261103-pos-goi-hang-truy-xuat/plan.md), không chặn app shell hoặc POS cơ bản. POS cơ bản không được hứa hoặc cho xử lý như thể hỗ trợ các gói đó; các gate an toàn tiền, quyền và tồn kho trong phạm vi bật vẫn bắt buộc. Những yêu cầu nâng cao khác không mặc nhiên được coi là đã hoàn tất hoặc đã loại bỏ.

**Checkpoint 04/11/2026:** Phase 1–4 đã có implementation và bằng chứng từng phần, nhưng chưa phase nào đạt toàn bộ tiêu chí. Backend và database đã được chạy/kiểm thử qua Spree CLI; các mốc môi trường ban đầu trong nhật ký là lịch sử, không phải trạng thái hiện tại. Phase 5 đã bắt đầu một số phần độc lập theo checkpoint riêng. Xem [bàn giao phase 1–4](./reports/phase-01-04-handoff.md) và [nhật ký runtime](./reports/runtime-spike-results.md).

Theo yêu cầu tiếp tục phát triển phase tiếp theo, các vấn đề chưa đóng được giữ thành backlog và gate theo capability. **Được tiếp tục code/kiểm thử preview trong phạm vi an toàn; không coi dependency chưa đạt là đã pass, không bật bán hàng, thu tiền, giao hàng hoặc thao tác tồn kho vận hành cho tới khi gate tương ứng được chứng minh và phê duyệt.**

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
- Khách/discount/price override theo quyền, ghi nhận tồn đúng branch theo policy tại quầy, trả/đổi/hoàn có evidence, đóng ca/quỹ/báo cáo và bill/display/thiết bị.
- Không hardcode quota cửa hàng/quầy/tab; pagination/virtualization và benchmark không phải cam kết capacity vô hạn.
- `apps/pos` React 19/Vite/TS/Query/Router/i18next package độc lập; không tạo root workspace nếu chưa có lý do được duyệt.
- Một Rails backend `server/app` namespace `Spree::Pos`, custom `/api/v3/admin/pos/*`; không sửa upstream Spree hoặc website checkout.
- VietQR tự động là adapter tương lai, không blocker POS; public provider/merchant ngân hàng chưa được chọn, không coi SePay/payOS đã chốt.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Contracts and UX validation](./phase-01-contracts-and-ux-validation.md) | Completed |
| 2 | [App shell and staff authentication](./phase-02-app-shell-and-staff-authentication.md) | Completed |
| 3 | [Branches registers and access control](./phase-03-branches-registers-and-access-control.md) | Completed |
| 4 | [Concurrent order workspace](./phase-04-concurrent-order-workspace.md) | Completed |
| 5 | [Catalog customers and discounts](./phase-05-catalog-customers-and-discounts.md) | Completed |
| 6 | [Split tender and settlement](./phase-06-split-tender-and-settlement.md) | In Progress |
| 7 | [Credit sales and receivables](./phase-07-credit-sales-and-receivables.md) | Pending |
| 8 | [Inventory handover returns and exchanges](./phase-08-inventory-handover-returns-and-exchanges.md) | Pending |
| 9 | [Shifts cashbook and reporting](./phase-09-shifts-cashbook-and-reporting.md) | Pending |
| 10 | [Receipts customer display and devices](./phase-10-receipts-customer-display-and-devices.md) | Pending |
| 11 | [Quality security and rollout](./phase-11-quality-security-and-rollout.md) | Pending |

Phase 1 completed 06/11/2026: hợp đồng POS cơ bản và wireframe đã chốt. Dependency `1` của các phase sau chỉ thỏa phần hợp đồng; proof quyền, tiền, tồn và hàng cân/serial/lô vẫn là gate tại phase phụ trách theo [bảng trách nhiệm](./phase-01-contracts-and-ux-validation.md).

Phase 2 completed 06/11/2026: shell, auth và context đã implement. Proof đa browser, accessibility và triển khai chuyển phase 11; xem [mục đóng phase](./phase-02-app-shell-and-staff-authentication.md#đóng-phase-06112026).

Phase 3 completed 06/11/2026: đã review và sửa 6 lỗi, có test race hai connection cho mở ca (F15). W08 trên API thật chuyển phase 11; xem [mục đóng phase](./phase-03-branches-registers-and-access-control.md#đóng-phase-06112026).

Phase 4 completed 06/11/2026: đã review và sửa 6 lỗi (lease sau takeover, hủy draft còn tiền, ẩn draft khi bị gỡ quyền...), có test race hai connection cho lease và tạo draft. Mở 20 view trên trình duyệt với API thật chuyển phase 11; xem [mục đóng phase](./phase-04-concurrent-order-workspace.md#đóng-phase-06112026).

Phase 5 completed 07/11/2026: review sửa lỗi backend/frontend (khóa snapshot khi có tender, số lượng nguyên, gộp gói, approval theo số tiền thực áp, scanner, tạo khách trùng...), thêm tem cân/giá EAN-13 và UI quản lý hàng chi nhánh. Migration mẫu tem mới áp database test; máy cân/quét thật chuyển phase 10, kiểm API thật chuyển phase 11; xem [mục đóng phase](./phase-05-catalog-customers-and-discounts.md#đóng-phase-07112026).

## Dependencies

Không có unfinished plan khác theo scan; report VietQR trước chỉ là research, không dependency đã duyệt.
Luồng chính: `1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11`; dependency IDs chi tiết trong từng phase. Có thể phát triển preview phase 5 song song với backlog phase 1–4, nhưng dependency/gate chưa đạt vẫn chặn capability liên quan và không tự chuyển thành completed.
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
- Acceptance A01–A06/W01–W09/F01–F21/I01–I08: đã có bằng chứng từng phần được ghi trong báo cáo; chưa claim toàn bộ acceptance, phase 11 full suite/UAT/benchmark hoặc readiness vận hành.

## Review trước triển khai
- Duyệt ADR precision/stock integration, ngành hàng/SKU thực và data receipt/import/transfer traceability.
- Manager chốt limit/due date/overdue, discount/refund/variance/return-window/cross-branch policies; chưa cấu hình thì capability rủi ro tắt.
- Chọn printer/scanner/display và quy trình payout/reconciliation; bill POS không phải hóa đơn điện tử pháp lý.
- Người dùng đã duyệt **áp dụng toàn bộ correction review**, triển khai plan và eject. Một số runtime proofs đã chạy nhưng còn các gate chưa đạt; deploy/nhận tiền thật vẫn cần authorization riêng.
