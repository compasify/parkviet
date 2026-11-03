---
phase: 1
title: Kiểm chứng hợp đồng và UX
status: in-progress
priority: P1
dependencies: []
effort: Ước tính 10–16 person-days; ước lượng lại nếu cần đổi schema/integration
---

# Phase 1: Kiểm chứng hợp đồng và UX

## Overview

**Điều chỉnh 03/11/2026:** Theo quyết định người dùng, proof tách gói I08 chuyển sang [plan riêng](../261103-pos-goi-hang-truy-xuat/plan.md), không chặn bắt đầu shell hay POS cơ bản dùng hành vi core Spree. Không hỗ trợ các gói cùng variant khác giá/lô cho đến khi plan riêng hoàn tất. Các proof tài chính, tồn và quyền vẫn áp dụng cho capability được bật; checkbox cũ bên dưới mô tả scope đầy đủ, không được coi toàn bộ đã đạt.

Chốt seam Spree thực chạy, schema POS và wireframe trước khi hoàn tất shell hoặc xây sổ tiền.
Một phần spike đã chạy; bằng chứng và các gate chưa đạt được ghi trong báo cáo runtime. Shell khởi tạo sớm được giữ lại nhưng chưa được coi là hoàn thành.
Chuẩn đọc: [kiến trúc](./specs/product-and-architecture.md), [UX](./specs/ux-and-workflows.md), [API/tests](./specs/api-contract-and-test-matrix.md).

## Requirements

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

- [ ] A01–A03: auth/runtime và permission bypass có test evidence trên đúng image/source.
- [ ] W01, W07, W08: prototype đa đơn/discount/responsive được duyệt; discount survives core recalc.
- [ ] F01–F04, F07, F18: partial/session/free order và recovery có seam khả thi đã kiểm chứng.
- [ ] F08–F11: credit/account lock, debt credit note và manual payout evidence có contract rõ.
- [ ] F12–F14: walk-in pickup, strict location, stock/restock một lần có spike chứng minh.
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

Chỉ sau duyệt evidence chuyển phase 2; phase 5/8 phải có proof base-unit/precision/serial-lot trước code, giữ financial capabilities tắt đến gate tương ứng.
