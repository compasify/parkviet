---
phase: 1
title: Kiểm chứng hợp đồng và UX
status: completed
priority: P1
dependencies: []
effort: Ước tính 10–16 person-days; ước lượng lại nếu cần đổi schema/integration
---

# Phase 1: Kiểm chứng hợp đồng và UX

**Điều chỉnh phạm vi được người dùng duyệt 04/11/2026:** Phase 1 tập trung hợp đồng và kiểm chứng nền tảng cho POS siêu thị cơ bản. Bằng chứng chuyên sâu theo capability chuyển sang phase chịu trách nhiệm dưới đây, không chuyển thành pass và không bỏ gate trước khi bật. Danh sách gốc ở dưới được giữ để truy vết; tiêu chí đóng phase 1 là checklist mới ở mục Success Criteria.

POS cơ bản cần kết nối mạng để bán; recovery khi đứt mạng giữa giao dịch không phải chế độ bắt đầu bán offline. Chỉ bán hàng giao ngay tại quầy; giao sau không thuộc POS cơ bản, đồng bộ giao sau cho ngành ăn uống là nhu cầu tương lai chưa thiết kế.

| Nội dung chưa đạt | Chủ trì tiếp tục | Gate vẫn áp dụng |
|---|---|---|
| A01–A03, W08: auth, phân quyền/bypass, responsive | Phase 2–3 và 11 | Kiểm server, isolation, revoke và UX trước capability/release liên quan |
| W01/W07: đa đơn, giá/giảm giá và recalc | Phase 4–5 | Không bật discount khi chưa chứng minh tính đúng sau recalc, tax và approval |
| F01–F04/F07/F18/F19/F20: thu tiền, recovery và bảo toàn tiền | Phase 6 | Chưa cho thu tiền thật trước proof, đối soát và phê duyệt |
| F08–F11: công nợ/thu nợ | Phase 7; returns phase 8 | Không bật credit/refund khi chưa qualify |
| F12–F14/F21, I01–I07: stock, tracking, trả hàng, precision và serial/lô | Phase 5 và 8 | Ghi nhận tồn một lần, đối soát và proof riêng trước capability liên quan/full release |
| I08: các gói cùng variant khác giá/lô | [Plan riêng](../261103-pos-goi-hang-truy-xuat/plan.md) | Không giả hỗ trợ trong POS cơ bản |
| F16: late cash và custody | Phase 6 và 9 | Chống double-count và đối soát ca trước vận hành |

## Overview

**Điều chỉnh 03/11/2026:** Theo quyết định người dùng, proof tách gói I08 chuyển sang [plan riêng](../261103-pos-goi-hang-truy-xuat/plan.md), không chặn bắt đầu shell hay POS cơ bản dùng hành vi core Spree. Không hỗ trợ các gói cùng variant khác giá/lô cho đến khi plan riêng hoàn tất. Các proof tài chính, tồn và quyền vẫn áp dụng cho capability được bật; checkbox cũ bên dưới mô tả scope đầy đủ, không được coi toàn bộ đã đạt.

Chốt seam Spree thực chạy, schema POS và wireframe trước khi hoàn tất shell hoặc xây sổ tiền.
Một phần spike đã chạy; bằng chứng và các gate chưa đạt được ghi trong báo cáo runtime. Shell khởi tạo sớm được giữ lại nhưng chưa được coi là hoàn thành.
Chuẩn đọc: [kiến trúc](./specs/product-and-architecture.md), [UX](./specs/ux-and-workflows.md), [API/tests](./specs/api-contract-and-test-matrix.md).

## Requirements

- **Policy đã duyệt 04/11/2026:** bán trực tiếp khi có hàng thực tế tại quầy: thiếu tồn hoặc không đọc được tồn thì cảnh báo, được tiếp tục theo policy sau khi capability đủ điều kiện; không yêu cầu reserve đủ tồn trước thu. Cần mạng để bán, không đọc được tồn không đồng nghĩa cho phép bắt đầu bán offline. Ghi đúng branch, không fallback ngầm; tracking stock xử lý lệch/xung đột online. Xem [quyết định và gate](./reports/pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng).

- Xác minh source version, image và mount runtime; local Spree 6.0.1 không chứng minh container tương ứng.
- Nếu chưa mount `./server:/rails`, xin developer duyệt eject và tác động DB trước mọi thử nghiệm backend.
- Không tự install, eject, reset, deploy hoặc chạy giao dịch ngân hàng thật trong bước lập kế hoạch.
- Chứng minh walk-in không email/address cá nhân, pickup đúng kho, discount persistence, partial settlements và credit placement.
- Chốt DTO, permission subjects, tiền decimal VND, trạng thái `202/409/422`, revision và idempotency theo spec.
- Duyệt layout desktop/tablet: A chờ bank, B cash, C scan; split + credit có trạng thái riêng.
- Mandatory full release: hàng cân/phân số/quy đổi đơn vị, serial/IMEI và lô/hạn dùng; không được loại khỏi launch.
- Xác nhận một register một physical drawer; credit policy do manager cấu hình trước khi bật.

## Architecture

- Spike trên test DB và installed workflows; không mock toàn bộ payment/complete/fulfillment để kết luận pass.
- Trace draft → totals/discount → receipt/session → complete → allocation → handover → return/refund.
- Cashier chỉ có granular POS rights; thử direct core endpoints để tìm bypass trước thiết kế wrapper.
- Kiểm nhiều partial PaymentSession, capture settings, canceled attempts và identity; không giả create Payment là nhận tiền.
- Preferred location có fallback: tìm hook/wrapper enforce strict branch, không sửa core upstream.
- Refund manual phải tách payout evidence với core Refund; nếu seam thiếu, ADR và gate dừng phase tài chính.
- Spike ReceivedFunds conservation xuyên allocation → refund/reservation → reversal/reallocation; liability payout tiền thừa/trễ không cần giả goods return/core Refund và unknown không release funds.
- Late cash phải reconcile original closed-shift variance/custody, không auto ghi receipt thành physical inflow ca mới đã có tiền trong opening float/safe transfer.
- Chỉ scoped POS policies; không bỏ validation website hay tạo email/địa chỉ giả cho walk-in.
- Core quantity integer: đề xuất chuẩn hóa sang base-unit nguyên cho SKU tương thích, chứng minh exact decimal unit-price/tax/discount/rounding bán và trả.
- Core variant-keyed upsert không đủ cho hai gói cùng SKU khác cân/giá/lô: chốt immutable SaleLine ID và line-ID-aware seam hoặc sublines mapping lossless. Chứng minh edit/remove/return từng gói độc lập trước phase 5/6/8.
- Chốt cumulative return entitlement/component allocation/residual; 5 units × 0.4 VND = 2 VND, trả 1+1+3 phải cấp đủ2 VND; không chỉ cap rồi round độc lập.
- SKU precision không biểu diễn chính xác phải hard gate ADR approved integration/schema trước code; không gửi fractional qty vào integer API, không fork upstream.
- Serial/IMEI và lot/expiry cần typed ownership/allocation, FEFO + expiry policy và locks xuyên POS/web/admin/import/stock nhập-chuyển/adjustment; metadata không đủ.

## Related Code Files

Quy ước inventory: mọi đường dẫn từ repo root; đều là đề xuất, không thay file ngoài plan ở phiên này.
- Create: `server/spec/integration/spree/pos/runtime_contract_spec.rb` — boot/version và draft lifecycle.
- Create: `server/spec/integration/spree/pos/settlement_contract_spec.rb` — partial/session/credit/refund.
- Create: `server/spec/integration/spree/pos/location_contract_spec.rb` — walk-in/pickup và stock counters.
- Create: `server/spec/integration/spree/pos/unit_precision_contract_spec.rb`, `server/spec/integration/spree/pos/traceability_contract_spec.rb` — exact unit pricing/serial-lot/FEFO races.
- Create: `server/spec/integration/spree/pos/sale_line_identity_contract_spec.rb`, `server/spec/integration/spree/pos/return_entitlement_contract_spec.rb` — same-variant lossless mapping và cumulative rounding.
- Create: `server/spec/integration/spree/pos/funds_conservation_contract_spec.rb`, `server/spec/integration/spree/pos/late_cash_contract_spec.rb` — refund/reverse/liability payout và custody no-double-count.
- Create: `server/spec/requests/spree/pos/permission_contract_spec.rb` — custom quyền và bypass core.
- Create: `plans/261101-1649-retail-pos-multi-store-multi-order/reports/runtime-spike-results.md` — evidence/seams/gates.
- Create: `plans/261101-1649-retail-pos-multi-store-multi-order/reports/pos-contract-decisions.md` — schema/ADR chưa ghi đè spec chuẩn.
- Create: `plans/261101-1649-retail-pos-multi-store-multi-order/assets/pos-wireframes.html` — prototype không mô phỏng thành công thu tiền.
- Modify: phase files của plan sau review nếu spike buộc đổi seam; không chỉnh `spree/` hoặc website checkout.

## Implementation Steps

1. Đọc root/server instructions và docs local; kiểm CLI capabilities, source/mount và test DB bằng `pnpm spree` phù hợp.
2. Ghi approval eject nếu cần; dừng nếu chưa được duyệt, không coi edits `server/` đã chạy trong prebuilt image.
3. Viết trước integration cases walk-in/pickup, discount sau recalc/remove line, last-unit race và không fallback branch.
   Qualification SKU thực: scale/price-label checksum/tare/net, base-unit/rational conversion versioning, price-column scale/money normalization/volume tiers/tax/return/overflow; không early rounding.
   Thử hai gói cùng variant khác weight/price/lot; trace variant-keyed upsert và chọn SaleLine/core seam có edit/remove/return mapping lossless, không metadata-only.
4. Viết partial sessions/confirm kép/timeout tests; chứng minh completed receipts khác pending/processing coverage core.
5. Kiểm actual cash applied/change, bank/card attest, receipt trước placement và retry không nhận tiền lần hai.
   Thêm F19/F20: exception allocate/liability payout, unknown/concurrent cap và collection→A→refund→reverse→B; F16 late S1 cash đã nằm trong S2 opening/safe không tạo inflow mới.
6. Kiểm approved credit dùng `payment_pending` có kiểm soát; account lock/exposure reservation và không fake debt Payment.
7. Chạy return/refund seam tests: cap paid/refundable, pending payout chưa refunded, debt credit note trước refund.
   Test Return/Refund cho phần chưa từng thu: receivable sau credit notes không suy từ `order.amount_due`; không fake Refund/sửa giá lịch sử/gán `payment_status` để ép khớp.
   Chứng minh F21 cumulative entitlement dùng chung credit notes/refunds/tax/discount, full return hết residual và reserved/cancel concurrency không over/under-credit.
8. Kiểm permissions trên wrapper và direct core writes; ghi subjects/registration API từ version đã boot thật.
   Spike serial unique-allocation, lot FEFO/expiry và last-unit races POS/web/transfer; chốt stock integration hooks + provenance trước phase 5/8.
9. Dựng wireframe 1280/1024/768/375px, tab overflow, nhận tiền nền, action-bound approval và recovery dialog.
10. Chốt schema mới `/api/v3/admin/pos/*`, route/auth seam và danh sách decision còn chờ; không giả endpoint đã có.
11. Sau approval triển khai mới chạy `pnpm spree rspec spec/integration/spree/pos` và request spike; lưu kết quả thực.
12. Review evidence với kỹ thuật/vận hành; seam không đạt phải ADR + sửa plan, không lách bằng dummy gateway.

## Success Criteria

### Checklist đóng phase 1 sau điều chỉnh phạm vi

- [x] Quyết định scope POS siêu thị cơ bản, online-first, bán giao ngay tại quầy; tiền mặt/chuyển khoản thủ công, QR để sau; chính sách tồn và recovery được ghi nhận trong [hợp đồng](./reports/pos-contract-decisions.md).
- [x] Ghi nhận evidence runtime, walk-in, permission, discount, stock và payment từng phần cùng giới hạn/risks trong [runtime](./reports/runtime-spike-results.md); không coi characterization là pass gate vận hành.
- [x] Chỉ định phase chịu trách nhiệm và giữ gate cho các proof chuyên sâu chưa đạt theo bảng ở đầu phase; I08 theo plan riêng.
- [x] Tổng hợp và đối chiếu contract POS cơ bản, permission/bypass và DTO với evidence thực tế; phân biệt phần đã có, chỉ là dự thảo và chưa chứng minh; ghi rõ gate trước khi bật: [báo cáo rà soát](./reports/phase-01-basic-contract-review.md). Đây không phải security audit hoặc proof toàn bộ DTO.
- [x] Review wireframe POS cơ bản với người dùng: layout, multi-order, cảnh báo tồn không xác định và recovery. Không suy diễn prototype đã duyệt từ kiểm tra tự động. *Người dùng xác nhận đã duyệt 06/11/2026; trạng thái mạng hiển thị bằng icon trên header (xem [quyết định](./reports/pos-contract-decisions.md#trạng-thái-mạng-trên-header--quyết-định-06112026)). Nút Thẻ/Kết hợp/Ghi nợ trong prototype là scope mở rộng, không phải capability POS cơ bản đã bật.*
- [x] Tách gate preview khỏi các gate capability/operational, kiểm tra links và các tài liệu downstream không hiểu phase 1 done là đã pass permission/tài chính/tồn. Sau đó mới đổi status. *Links trong phase này đã kiểm 06/11/2026; ghi chú dependency trong [plan](./plan.md#phases) và [roadmap](./specs/release-roadmap.md#gate-sau-phase-1-trước-implementation-phụ-thuộc).*

### Checklist gốc — chuyển trách nhiệm, không phải kết quả đã pass

- [ ] A01–A03: auth/runtime và permission bypass có test evidence trên đúng image/source.
- [ ] W01, W07, W08: prototype đa đơn/discount/responsive được duyệt; discount survives core recalc.
- [ ] F01–F04, F07, F18: partial/session/free order và recovery có seam khả thi đã kiểm chứng.
- [ ] F08–F11: credit/account lock, debt credit note và manual payout evidence có contract rõ.
- [ ] F12–F14: walk-in pickup, đúng location, cảnh báo thiếu tồn không chặn tại quầy, xung đột online có dấu vết/đối soát, stock/restock một lần có spike chứng minh; policy giao sau kiểm riêng.
- [ ] I01–I07: base-unit exactness và typed serial/lot/FEFO/provenance/bypass mutators được qualification; ADR duyệt nếu seam không đủ, chưa gọi full khi thiếu.
- [ ] I08, F21: SaleLine/core mapping lossless và cumulative entitlement 1+1+3 có proof, không chỉ UI tách dòng hoặc cap tổng.
- [ ] F16, F19, F20: liability payout/reallocation/parent funds và late-cash custody có contract + spike evidence; unknown không giải phóng tiền.
- [ ] Gate đầu vào phase 2 và gate tài chính được ghi pass/fail riêng; không tự đánh dấu phase hoàn tất.

## Risk Assessment

- Runtime lệch source hoặc eject đổi DB: approval rõ, synthetic test DB và lưu phiên bản/mount, không suy luận từ lockfile.
- Seam split/refund/walk-in thiếu: blocker kiến trúc, không cấp quyền rộng hoặc tắt validations để vượt gate.
- Credit-return lệch balance core: chốt reconciliation DTO và seam phase 8; không làm biến mất khoản nợ bằng Refund giả.
- Sai độ chính xác hoặc chỉ khóa serial trong POS: blocker release; mở rộng kiểm integration mọi writer, effort cần ước lượng lại theo ADR.
- Prototype được hiểu là app chạy thật: gắn nhãn UX-only; provider/merchant ngân hàng vẫn chưa được chọn.

## Next Steps

Tiếp tục preview phase 5 song song theo phạm vi đã cho phép; advanced-goods/financial/inventory capabilities vẫn cần proof và ADR tương ứng trước khi bật. Xem backlog và điều kiện đóng tại [bàn giao phase 1–4](./reports/phase-01-04-handoff.md).

## Checkpoint 04/11/2026

- **In progress, chưa đạt gate đầy đủ.** Runtime Spree/container, auth, walk-in scoped và nhiều characterization đã được kiểm thử; chi tiết và giới hạn trong [runtime](./reports/runtime-spike-results.md).
- Core đã được quan sát cho phép over-allocation trong fixture staff draft và over-reservation xuyên cart/order ở service spike; `pending` payment có thể đi cùng order được đặt. Không dùng các kết quả đó làm proof an toàn tồn hoặc đã thu tiền.
- Đã chốt policy thiếu tồn tại quầy; còn thiếu proof đúng branch, cảnh báo, stock effects/recovery và tracking xung đột xuyên writer; financial settlement/recovery/refund, advanced-goods precision/traceability và các acceptance chưa tick. Phân biệt package cùng variant đã chuyển sang plan riêng; không giả định capability đó có sẵn.

## Đóng phase 06/11/2026

- **Completed theo checklist đã điều chỉnh phạm vi.** Người dùng xác nhận đã duyệt wireframe; đang triển khai phase 5–6. Không còn hạng mục implement nào thuộc phase 1.
- Phase 1 done chỉ có nghĩa là hợp đồng POS cơ bản và wireframe đã chốt. Mục "Checklist gốc" vẫn chưa pass; các proof đó (quyền/bypass, tiền, tồn, hàng cân/serial/lô, trả hàng) tiếp tục là gate tại phase phụ trách trong bảng đầu file. Phase phụ thuộc `1` không được coi các gate đó đã đạt.
