---
phase: 8
title: "Giao hàng đúng kho, trả đổi và bằng chứng hoàn tiền"
status: completed
priority: P1
dependencies: [1, 6, 7]
effort: "Ước tính 20–32 person-days; phụ thuộc stock/precision ADR phase 1"
---

# Phase 8: Giao hàng đúng kho, trả đổi và bằng chứng hoàn tiền

## Overview

Hoàn thiện strict-location fulfillment, returns/exchanges và refund saga; không trừ kho POS lần hai.
Chuẩn: [kiến trúc §8–9](./specs/product-and-architecture.md), [UX §7](./specs/ux-and-workflows.md), [API/tests F10–F14](./specs/api-contract-and-test-matrix.md).

## Requirements

- Policy đã duyệt: hàng thực tế tại quầy được tiếp tục khi thiếu tồn sau cảnh báo; không yêu cầu reserve đủ tồn thông thường trước thu. Tracking stock phải phát hiện/ghi nhận chênh lệch và xung đột online để người có trách nhiệm đối soát, xử lý, lưu kết quả; không tự hủy đơn hoặc giả nhập bù. Đúng location và effects một lần vẫn bắt buộc; giao sau và traceability có policy/gate riêng. Xem [quyết định](./reports/pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng).

- Chỉ handover paid-or-approved-credit sau gate; no preferred-location fallback hoặc force từ browser.
- Placement tăng allocation, fulfillment giảm physical stock; retry/collection/reprint không làm stock move thêm.
- Return bám original fulfillment items/giá/discount/tax và remaining returnable dưới lock.
- Restock chỉ resellable received units đúng receiving location; cross-branch theo manager policy/approval.
- Credit note giảm nợ trước, chỉ phần entitlement vượt debt mới refund với cap actual paid/refundable.
- Cash payout gắn active receiving shift; bank/card request và confirm riêng, unknown không refunded success.
- Exchange là linked return + replacement sale, đủ hai vế chứng từ/chênh lệch, không netting mất stock/tiền.
- Mandatory weighted/unit, serial/IMEI, batch/lot/expiry: allocation/provenance và expiry/FEFO enforce server, không metadata-only.
- Cumulative return entitlement theo immutable SaleLine và component/residual policy dùng chung debt-credit/refund; trả nhiều lần phải đủ tổng giá trị gốc, không chỉ chặn over-refund.
- Refund child consume shared ReceivedFunds; reverse/reallocate collection không giải phóng phần đã chi/reserved/unknown. Tiền chưa allocated dùng liability payout phase 6, không ép vào goods return.

## Architecture

- Mở rộng strict guard/handover phase 6, reuse core fulfillment/return/exchange/refund workflows đã spike.
- RefundRequest dùng shared PayoutEvidence/parent balance phase 6; core Refund chỉ map lúc thực chi được xác nhận, không thêm evidence ledger thứ hai.
- Return reservation khóa original units/entitlement; refund cap tính cả concurrent reserved/unknown payout amounts.
- Entitlement target lũy kế E(q) từ original SaleLine net/tax/discount allocations; delta = target mới − posted/reserved đã cấp. Full return hết residual, sum components khớp; cancel reservation revalidate dependent previews trước approval, không đổi posted document.
- Reservations ordered dưới SaleLine lock: dependent entitlement không post trước predecessor unresolved; cancel rebuild/reapprove unposted dependents, reject nếu cần sửa posted facts. Return receive/restock và actual payout độc lập, retry không tạo effect lần hai khi chờ entitlement.
- SaleLine → core line/fulfillment mapping phase 5 phải giữ riêng measured packages cùng variant khác giá/cân/lô; return theo SaleLine IDs/provenance, không dựa variant-only lookup.
- Refund reservation/confirm/failed-no-effect resolution và allocation reversal đều dùng shared parent lock/cap; liabilities và allocated refunds không được chi cùng một đồng hai lần.
- Credit-note posting cập nhật receivable ledger phase 7, không suy balance sau return từ core `order.amount_due`.
- Return/Refund seam cho phần chưa từng thu phải chạy thật: không Refund giả, sửa historical prices hoặc gán payment_status.
- External payout không giữ DB lock; durable intent/evidence/outbox/recovery dùng financial primitives phase 6.
- Orders timeline DTO trình bày original total, return entitlement, credit notes, receipts, refunds và debt riêng.
- Typed SerialUnit/InventoryLot/TraceAllocation nối variant/location/core line/fulfillment; locks/constraints chống bán serial hai lần và lot over-allocation.
- Base quantity nguyên + sale-unit snapshot từ phase 5; partial returns giữ original conversion/precision/serial-lot identity, không lấy conversion mới.
- Stock integrations receipt/import/transfer/count/fulfillment/return phải đồng bộ typed provenance và core counters; POS/web cùng đi guard đã spike.
- Với capability serial/lô nâng cao: qualification reservation/identity trước thu tiền, TTL/release owner-bound không ghim serial/lô bởi parked tabs; FEFO tie-break receipt, expired/quarantine bị chặn. Không suy rộng yêu cầu reserve này cho số lượng hàng thường đã có thực tế tại quầy.
- Opening tracked balances reconcile aggregate/core writer trước enable SKU/location; mutator web/admin/import chưa hỗ trợ phải reject rõ, không thay website checkout UI.

## Related Code Files

Inventory repo-root; không sửa gem source, names core seams chỉ chốt theo evidence phase 1.
- Create: `server/app/models/spree/pos/refund_request.rb`.
- Reuse: `server/app/models/spree/pos/payout_evidence.rb` từ phase 6, không tạo ledger thứ hai.
- Create: `server/app/models/spree/pos/return_reservation.rb`, `server/app/models/spree/pos/exchange_operation.rb`, `server/db/migrate/TIMESTAMP_create_spree_pos_return_operations.rb`.
- Create: `server/app/models/spree/pos/serial_unit.rb`, `server/app/models/spree/pos/inventory_lot.rb`, `server/app/models/spree/pos/trace_allocation.rb`, `server/db/migrate/TIMESTAMP_create_spree_pos_stock_traceability.rb`.
- Create: `server/app/workflows/spree/pos/inventory/allocate_traceability.rb`, `server/app/workflows/spree/pos/inventory/receive_traceability.rb`, `server/app/workflows/spree/pos/inventory/transfer_traceability.rb`.
- Create: `server/app/services/spree/pos/fefo_allocator.rb`, `server/app/services/spree/pos/stock_integration.rb`, `server/app/subscribers/spree/pos/stock_traceability_subscriber.rb` — đồng bộ side effects, critical gates bằng hooks transactional.
- Create: `server/app/controllers/spree/api/v3/admin/pos/inventory/traceability_controller.rb`, `apps/pos/src/pages/inventory-traceability.tsx`, `server/spec/workflows/spree/pos/traceable_inventory_spec.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/lots_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/serial_units_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/workspaces/trace_allocations_controller.rb` — reserve/lookup/recall scoped.
- Create: `server/app/workflows/spree/pos/returns/prepare.rb`, `server/app/workflows/spree/pos/returns/receive.rb`, `server/app/workflows/spree/pos/returns/apply_credit_note.rb`.
- Create: `server/app/workflows/spree/pos/refunds/request.rb`, `server/app/workflows/spree/pos/refunds/confirm_payout.rb`, `server/app/workflows/spree/pos/exchanges/execute.rb`.
- Create: `server/app/services/spree/pos/return_entitlement.rb`, `server/app/services/spree/pos/refund_adapter.rb`, `server/app/jobs/spree/pos/recover_return_operation_job.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/orders_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/returns_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/exchanges_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/refund_requests_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/refund_requests/confirmations_controller.rb`.
- Create: `apps/pos/src/pages/orders.tsx`, `apps/pos/src/pages/return-exchange.tsx`, `apps/pos/src/components/refund-evidence-dialog.tsx`, `apps/pos/src/hooks/use-returns.ts`.
- Create: `server/spec/workflows/spree/pos/fulfillment_returns_spec.rb`, `server/spec/workflows/spree/pos/credit_returns_spec.rb`, `server/spec/workflows/spree/pos/refunds_spec.rb`, `apps/pos/e2e/returns-exchanges.spec.ts`.
- Create: `server/spec/workflows/spree/pos/return_entitlement_spec.rb` — cumulative components/residual và partial/canceled/concurrent reservations.
- Modify: phase 6 `funds_balance.rb`/`funds_conservation_spec.rb`/`liability_payouts_spec.rb`, phase 5 `sale_line_mapper.rb`/identity specs; cùng parent conservation và lossless sale-to-return mapping.
- Modify: strict location guard/order handover phase 6, receivable projection phase 7, routes/permissions/locales.

## Implementation Steps

1. Viết trước F12/F13 last-unit POS/POS/web race, preferred fallback và duplicate complete/handover/receive assertions counters/events.
   Gate proof phase 1 bắt buộc; test weighted conversion/price precision và serial uniqueness/FEFO/expired lots/transfer race trên installed core.
2. Viết F10 core integration thật: sale1m/paid300k/debt700k; return400k → debt300k/no refund, full return → debt0/refund entitlement300k.
3. Chạy seam Return/Refund phần chưa thu; so ledger/core facts không ép `amount_due` bằng receivable bằng sửa giá/status.
4. Viết F11/F14 concurrent return/refund reservations, unknown payout, damaged/cross-branch và exchange chênh lệch.
   Thêm F20 collection→A→refund40k→reverse/reallocate B tối đa60k và F19 payout-vs-refund-vs-allocation; test shared parent bằng core Payment/Refund thật.
   Thêm F21: 5×0.4 VND =2, return1+1+3 nhận đủ2; discount/tax/debt-credit/refund chung entitlement, partial/concurrent/canceled reservation giữ components/tổng. I08 return một gói không thay gói cùng variant còn lại.
5. Mở rộng strict guard mọi placement/handover, branch location và paid-or-credit authority; không thêm direct stock decrement.
   Tích hợp stock receipt/import/transfer/count/cancel + transactional trace guards mọi writer; bootstrap/đối soát typed serial/lot từ chứng từ, reject unsupported consumers, không chỉ selector UI.
6. Cài return eligibility/quantity reservation, reason/condition, core receive và once-only resellable restock.
   Return weighted base units theo original snapshot, serial phải đúng đã giao, lot/expiry provenance giữ xuyên cross-branch/damaged/exchange.
7. Cài credit-note ledger trước refund entitlement; atomic caps không cho credit note + refund vượt returned value.
   Cài cumulative target/residual dưới SaleLine quantity/entitlement lock, không round từng return độc lập; revalidate reservation dependencies, giữ nguyên posted credit-note/refund values.
8. Cài refund request/evidence/confirm; cash tạo negative CashMovement tại ca hiện tại, bank/card chờ chứng từ thực chi.
9. Cài exchange operation liên kết hai legs, payment/credit/refund delta riêng; recovery không lặp receive/placement/payout.
10. Dựng order history/timeline và wizard preview return/debt-credit/refund, action-bound approvals và attention recovery.
11. Gate: `pnpm spree rspec spec/workflows/spree/pos/fulfillment_returns_spec.rb spec/workflows/spree/pos/credit_returns_spec.rb spec/workflows/spree/pos/refunds_spec.rb spec/workflows/spree/pos/return_entitlement_spec.rb spec/workflows/spree/pos/funds_conservation_spec.rb spec/workflows/spree/pos/traceable_inventory_spec.rb` + e2e.

## Success Criteria

- [x] F12, F12a, F12b, F13: đúng branch; thiếu tồn tại quầy cảnh báo không chặn, xung đột online có dấu vết/đối soát; one allocation/depletion/restock; collection/reprint không move stock. *(Kệ thiếu khi giao ghi `StockDiscrepancy` + attention, không ép tồn âm; `reconcile_handover` theo quyền RESOLVE; giao lại/thu nợ/in lại không trừ kho thêm — `fulfillment_returns_spec.rb`.)*
- [x] F10: cả partial/full credit-sale returns đúng balance sau credit notes, no Refund cho tiền chưa nhận. *(`credit_returns_spec.rb`: bán 1tr trả 300k nợ 700k; trả 400k → nợ 300k không hoàn; trả hết → nợ 0, quyền hoàn 300k; không tạo Refund cho tiền chưa nhận.)*
- [x] F11: refund chỉ sau verified payout, cap gồm reserved/unknown, retry không payout lần hai. *(`refunds_spec.rb`: Refund core chỉ tạo khi xác nhận chi; cap gồm reserved/unknown; thử lại cùng key không chi lần hai; hủy chỉ người yêu cầu/người duyệt và có lý do, đã cấp duyệt thì phải qua unknown/failed có chứng từ.)*
- [x] F19, F20: goods refunds và liability payouts chung parent cap, confirmed/reserved/unknown không sống lại sau collection reversal/reallocation; không fake Return/Refund cho unapplied funds. *(`funds_conservation_spec.rb`: hoàn hàng, liability payout và phân bổ dùng chung cap của phiếu nhận; đảo phân bổ đã hoàn bị từ chối; đảo khoản thu nợ mà quyền hoàn trả hàng phụ thuộc bị từ chối.)*
- [x] F21: cumulative 1+1+3 trả đủ2 VND, tax/discount/credit-note/refund components reconcile, full-return residual không mất, race/cancel không cấp kép. *(`return_entitlement_spec.rb`: 5×0,4 đ trả 1+1+3 cấp đủ 2 đ; net và thuế làm tròn lũy kế riêng, tổng = net + thuế; hủy/đua reservation không cấp kép.)*
- [x] F14: damaged không restock; cross-branch đúng approval/location; exchange đủ linked financial/stock legs. *(Hàng hỏng không nhập lại bán được (hàng truy vết vào cách ly); trả khác chi nhánh cần duyệt, nhập kho chi nhánh nhận; đổi hàng giữ phiếu trả + đơn thay thế, chênh lệch trừ phần đã hoàn.)*
- [x] I01–I07: exact weighted/unit bán-trả, serial uniqueness, FEFO/expiry/transfer races, mutator bypass/opening balances/recall/provenance pass; không fractional integer-API writes. *(`traceable_inventory_spec.rb`, `traceable_inventory_guards_spec.rb`, `trace_race_spec.rb`: số lượng cân nguyên đơn vị cơ sở, serial một chủ, FEFO bỏ lô hết hạn/cách ly, nhập/chuyển/kiểm có duyệt, tồn đầu kỳ phải khớp, checkout website/dashboard bị chặn trước thanh toán, writer core bị chặn hoặc phát hiện lệch.)*
- [x] I08: sale-to-fulfillment-to-return mapping lossless cho từng measured line cùng variant khác price/weight/lot, không gộp entitlement. *(Hai dòng cân cùng variant giữ SaleLine/provenance riêng qua fulfillment và trả một phần.)*
- [x] A02, A03, A05: IDs/force/core-refund bypass và approval reuse bị chặn. *(`returns_refunds_spec.rb`, `traceability_spec.rb`: ngoài chi nhánh/thiếu quyền bị chặn, endpoint duyệt chung không tạo được duyệt trả/hoàn/kiểm kho, tham chiếu ngân hàng bị che, không dùng được `force`/refund core.)*
- [x] W08, F16: wizard dùng thật API/evidence; cash refund hôm sau gắn receiving shift, lịch sử sale giữ nguyên. *(Wizard trả/đổi, lịch sử đơn, trang tồn kho truy vết dùng API thật trong request spec và e2e mock 3 viewport; hoàn tiền mặt hôm sau vào ca đang mở của người chi, lịch sử bán giữ nguyên. Kiểm trên API thật chuyển phase 11.)*

## Risk Assessment

- Core return mặc định gắn refund cho unpaid value: release blocker, ADR scoped seam; không dummy `credit` luôn true.
- Refund/cancel unknown bị retry thành hai lần chi: giữ reservation và operation identity đến resolution có evidence.
- Return window/cross-branch chưa duyệt: capability tương ứng tắt; không giả mọi hàng đều refundable hoặc resellable.
- Serial/lot chỉ cập nhật qua POS sẽ lệch web/nhập-chuyển: gate stock integration mọi writer; schema seam thiếu cần ADR/ước lượng lại, không fork upstream.

## Next Steps

Phase 9 đối soát toàn bộ cash/debt/returns facts đã tạo; chỉ mở full retail sau báo cáo/thiết bị/security phase 9–11.

## Review 07/11/2026

Phase làm hai đợt, mỗi đợt có review độc lập backend/frontend; lỗi tìm thấy đã sửa và có test. Chi tiết: [trả/hoàn/đổi](./reports/phase-08-returns-implementation.md), [truy vết serial/lô](./reports/phase-08-traceability-implementation.md).

- Trả/hoàn/đổi: hàng giao lúc kệ thiếu không bao giờ được trừ kho vì chỉ chủ ca chạy lại được; số tài khoản nhận hoàn lộ ở màn hình đơn đã che khách; hạn trả không kiểm lại khi nhận hàng; ai cũng hủy được yêu cầu hoàn (có thể chi hai lần); phiếu trả bỏ dở chặn mãi các lần trả sau; đảo khoản thu nợ sau khi trả hàng làm khách nợ trên hàng đã trả. Frontend: phiếu trả không mở lại được, bấm lại sau mất phản hồi tạo phiếu trùng, hoàn tiền kẹt vì thiếu hủy/không thực hiện, chênh lệch đổi hàng tính sai.
- Truy vết: checkout website mặt hàng đang truy vết trừ tiền rồi mới bị chặn; áp kiểm kho sau duyệt đẩy lô dưới số đã bán; hủy đơn từ core bỏ kẹt allocation; dòng `serial_lot` cũ bỏ qua truy vết; cảnh báo lệch tồn chỉ phát một lần; hàng cách ly không xóa sổ được; deadlock job hết hạn với giữ serial. Frontend: mất phản hồi khi nhập/chuyển lô có thể ghi hai lần; người duyệt không vào được tab kiểm kho; trả hàng mặc định "bán lại được".

## Đóng phase 07/11/2026

**Kết quả:** backend POS 396 examples, 0 failures (gồm `return_entitlement_spec`, `credit_returns_spec`, `refunds_spec`, `fulfillment_returns_spec`, `return_recovery_spec`, `returns_refunds_spec`, `return_race_spec`, `traceable_inventory_spec`, `traceable_inventory_guards_spec`, `traceability_spec`, `trace_race_spec`). `apps/pos`: e2e trả/đổi và tồn kho truy vết pass trên 3 viewport.

**Migration:** `20261107130000`, `20261107135000`, `20261107160000`, `20261107160100` chỉ áp database test. Development vẫn chờ sao lưu.

**Seam core (Spree 6.0.2):** dùng `Spree::Returns::{Create,Approve,Receive,Cancel}` và `Spree::Refunds::Create` trên Payment của allocation chỉ khi xác nhận chi; không dùng `Spree::Returns::Refund` (tự hoàn cả phần chưa thu) và `Spree::Exchange`. Guard kho qua decorator `StockMovement`/`StockLevel` và hook cart/checkout; SQL thô chỉ phát hiện được, khi đó chặn bán tới khi kiểm kho.

**Ghi chú:** đảo một phần phân bổ thu nợ đã hoàn tiền vẫn bị từ chối (spec cho phép). Hủy đơn POS có hàng truy vết từ dashboard bị từ chối, phải xử lý qua POS. Race spec dùng dữ liệu commit nên chỉ tin cậy khi suite chạy một mình.

**Chuyển phase sau:** in serial/lô trên biên nhận (phase 10); kiểm trên API thật, tải lớn và đối soát kho vận hành (phase 11). Vẫn sandbox-only.
