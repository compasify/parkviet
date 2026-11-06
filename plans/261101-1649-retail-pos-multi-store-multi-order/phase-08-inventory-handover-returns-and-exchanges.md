---
phase: 8
title: "Giao hàng đúng kho, trả đổi và bằng chứng hoàn tiền"
status: pending
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

- [ ] F12, F12a, F12b, F13: đúng branch; thiếu tồn tại quầy cảnh báo không chặn, xung đột online có dấu vết/đối soát; one allocation/depletion/restock; collection/reprint không move stock.
- [ ] F10: cả partial/full credit-sale returns đúng balance sau credit notes, no Refund cho tiền chưa nhận.
- [ ] F11: refund chỉ sau verified payout, cap gồm reserved/unknown, retry không payout lần hai.
- [ ] F19, F20: goods refunds và liability payouts chung parent cap, confirmed/reserved/unknown không sống lại sau collection reversal/reallocation; không fake Return/Refund cho unapplied funds.
- [ ] F21: cumulative 1+1+3 trả đủ2 VND, tax/discount/credit-note/refund components reconcile, full-return residual không mất, race/cancel không cấp kép.
- [ ] F14: damaged không restock; cross-branch đúng approval/location; exchange đủ linked financial/stock legs.
- [ ] I01–I07: exact weighted/unit bán-trả, serial uniqueness, FEFO/expiry/transfer races, mutator bypass/opening balances/recall/provenance pass; không fractional integer-API writes.
- [ ] I08: sale-to-fulfillment-to-return mapping lossless cho từng measured line cùng variant khác price/weight/lot, không gộp entitlement.
- [ ] A02, A03, A05: IDs/force/core-refund bypass và approval reuse bị chặn.
- [ ] W08, F16: wizard dùng thật API/evidence; cash refund hôm sau gắn receiving shift, lịch sử sale giữ nguyên.

## Risk Assessment

- Core return mặc định gắn refund cho unpaid value: release blocker, ADR scoped seam; không dummy `credit` luôn true.
- Refund/cancel unknown bị retry thành hai lần chi: giữ reservation và operation identity đến resolution có evidence.
- Return window/cross-branch chưa duyệt: capability tương ứng tắt; không giả mọi hàng đều refundable hoặc resellable.
- Serial/lot chỉ cập nhật qua POS sẽ lệch web/nhập-chuyển: gate stock integration mọi writer; schema seam thiếu cần ADR/ước lượng lại, không fork upstream.

## Next Steps

Phase 9 đối soát toàn bộ cash/debt/returns facts đã tạo; chỉ mở full retail sau báo cáo/thiết bị/security phase 9–11.
