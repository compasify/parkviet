---
phase: 5
title: "Hàng hóa, khách hàng và giảm giá có kiểm soát"
status: pending
priority: P1
dependencies: [1, 3, 4]
effort: "Ước tính 16–24 person-days; phụ thuộc precision ADR phase 1"
---

# Phase 5: Hàng hóa, khách hàng và giảm giá có kiểm soát

## Overview

Nối catalog/customer/pricing thật vào nhiều workspace, dùng wrapper scoped thay browser gọi core writes.
Đây là mốc preview 1–5, chưa được thu tiền hoặc quảng bá là POS vận hành.
Chuẩn: [UX §5,9](./specs/ux-and-workflows.md), [kiến trúc §8](./specs/product-and-architecture.md), [API/tests](./specs/api-contract-and-test-matrix.md).

## Requirements

- Search tên/SKU/barcode, variants/ảnh, tồn tại branch và kết quả phân trang; barcode mơ hồ phải chọn, không đoán.
- Mandatory: nhập số lượng cân/phân số, đơn vị bán/quy đổi, barcode nhãn cân/giá và chọn serial/IMEI/lô-hạn dùng.
- Chỉ gửi base-unit quantity nguyên khi phase 1 chứng minh exact decimal giá/thuế/discount; không làm tròn lén hoặc đẩy fractional vào integer API.
- Quick create khách tên/phone, email tùy chọn, duplicate warning; không tự merge hoặc tạo fake email.
- Giảm dòng/toàn đơn, %/VND, lý do, promotion tách manual; price override là capability riêng.
- Server preview/recalc giá-thuế-discount; action-bound manager approval khi vượt policy, không trusted client totals.
- Sau receipt/commitment theo policy: snapshot giá/khách/items bị khóa; vẫn enforced server khi phase 6 bật thu tiền.
- Immutable SaleLine ID cho mọi edit/remove/discount target; measured packages cùng variant khác cân/giá/unit/lô phải riêng, ordinary scans chỉ merge theo explicit compatible key. Phase 1 phải qualify mapping core lossless trước implementation.

## Architecture

- Restricted readers serialize POS DTO, không giá vốn/PII dư thừa hoặc tồn kho branch khác không được cấp.
- Workspace command executor phase 4 gọi core order update/pricing/discount services đã spike; không copy engine tính giá.
- Approval bound action/order/customer/amount/revision/expiry/approver; thay snapshot invalidates approval.
- Scanner intents có sequence và idempotency riêng, serial queue per workspace; debounce search không drop scan.
- `Catalog` query key có store/branch/assortment/search; customer debt/history chỉ tải với permission riêng.
- UI drawer/modal giữ focus/tab ID; mutation response thay totals từ server, không optimistic financial success.
- UnitDefinition/UnitConversion/MeasuredLine typed ratios + precision/version; snapshot lưu sale quantity/unit và base quantity; không đổi conversion khi còn stock/order, không metadata authority.
- Serial selector/lot availability lấy typed stock reader; chọn nháp không bảo đảm tồn. Phase 8 reserve dưới lock **trước nhận tiền**, rồi transition allocation/handover cùng core lifecycle; chưa capability thì phase 6 reject tracked-SKU tender.
- SaleLine/MeasuredLine giữ measurement-event identity và exact price/discount/tax/conversion snapshot. Core line-ID-aware seam hoặc typed sublines mapping theo ADR phase 1; không dùng variant-only upsert làm mất dòng. Server mapping dùng cả fulfillment/return, không average giá gộp mất provenance.
- Barcode measurement/price-label parser có branch format/version/checksum/tare/net, server kiểm unit/amount/price consistency; không tin encoded price tùy ý.

## Related Code Files

Inventory từ repo root; paths tạo mới trừ dòng Modify, không sửa `spree/`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/catalog_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/customers_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/workspaces/items_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/workspaces/customers_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/workspaces/discounts_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/workspaces/notes_controller.rb`.
- Create: `server/app/services/spree/pos/catalog_reader.rb`, `server/app/services/spree/pos/customer_reader.rb`, `server/app/services/spree/pos/price_policy.rb`.
- Create: `server/app/models/spree/pos/unit_definition.rb`, `server/app/models/spree/pos/unit_conversion.rb`, `server/app/models/spree/pos/measured_line.rb`, `server/db/migrate/TIMESTAMP_create_spree_pos_sale_units.rb`.
- Create: `server/app/models/spree/pos/sale_line.rb`, `server/app/services/spree/pos/sale_line_mapper.rb`, `server/spec/workflows/spree/pos/sale_line_identity_spec.rb` — typed identity/mapping/merge contract, cùng migration sale units.
- Create: `server/app/controllers/spree/api/v3/admin/pos/units_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/unit_conversions_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/measured_lines_controller.rb`.
- Create: `server/app/services/spree/pos/unit_normalizer.rb`, `server/app/services/spree/pos/measurement_barcode_parser.rb`, `server/app/controllers/spree/api/v3/admin/pos/catalog/traceability_controller.rb`.
- Create: `server/app/workflows/spree/pos/workspaces/update_items.rb`, `server/app/workflows/spree/pos/workspaces/assign_customer.rb`.
- Create: `server/app/workflows/spree/pos/workspaces/apply_discount.rb`, `server/app/workflows/spree/pos/customers/create.rb`.
- Create: `apps/pos/src/hooks/use-catalog.ts`, `apps/pos/src/hooks/use-customers.ts`, `apps/pos/src/hooks/use-workspace-commands.ts`.
- Create: `apps/pos/src/components/catalog-search.tsx`, `apps/pos/src/components/order-lines.tsx`, `apps/pos/src/components/customer-picker.tsx`, `apps/pos/src/components/discount-dialog.tsx`.
- Create: `apps/pos/src/components/weighted-quantity-input.tsx`, `apps/pos/src/components/sale-unit-picker.tsx`, `apps/pos/src/components/serial-lot-selector.tsx`, `apps/pos/src/lib/measurement-barcode.ts`.
- Create: `apps/pos/src/lib/scanner-queue.ts`, `apps/pos/src/lib/money.ts`, `apps/pos/src/lib/scanner-queue.test.ts`, `apps/pos/src/lib/money.test.ts`.
- Create: `server/spec/workflows/spree/pos/pricing_spec.rb`, `server/spec/requests/spree/pos/catalog_customers_spec.rb`, `apps/pos/e2e/catalog-discounts.spec.ts`.
- Create: `server/spec/workflows/spree/pos/unit_normalization_spec.rb`, `apps/pos/e2e/weighted-serial-lot-selection.spec.ts` — exact price/quantity/provenance DTO gates.
- Modify: routes/access policy, sale/workspace hooks và locale files từ phase 2–4.

## Implementation Steps

1. Viết trước tests discount persistence sau recalc/remove line, stacking, rounding VND và direct core price bypass.
   Chỉ bắt đầu advanced-goods code sau proof phase 1/ADR approved; test fractional sale-unit/base-unit exactness với SKU/precision thực.
   Viết I08 trước: hai gói cùng variant khác cân/giá/lô, reload/edit/remove/discount riêng và mapped quantities/values không bị overwrite; thêm ordinary merge positive/negative cases.
2. Viết customer duplicate/retry/branch permissions và scanner 100 intents với out-of-order responses/IME tests.
3. Cài readers scoped theo context/assortment, barcode ambiguous response và pagination; allowlist mọi search/filter.
4. Cài quick-create idempotent, gắn đúng workspace/customer model config; trả duplicate choice không auto merge.
5. Cài item quantity/note/customer commands qua revision/lease; không gửi stock location hoặc arbitrary metadata price từ client.
   Thêm unit-normalizer typed ratios, MeasuredLine snapshots, unit/config APIs và server parser nhãn cân/giá; serial/lot reader trả capability chưa sẵn sàng tới phase 8, không stub success.
   Cài SaleLine IDs/explicit merge key và mapping core đã qualify; scanner/discount/edit/remove dùng line ID, không row index/variant ID; persistence/recovery giữ mapping server-owned.
6. Cài server price policy, discount preview/apply và price override riêng; audit reason/before-after/approver.
7. Cài approval validation và invalidation khi đổi customer/amount/revision; cashier không dùng shared admin PIN.
8. Dựng search/grid toggle/line editing và customer/discount controls luôn thấy; totals và field errors lấy server.
9. Cài scanner queue bound workspace, IME/focus exclusions và shortcuts không chiếm browser controls.
   Dựng nhập cân/chọn đơn vị/serial-lot/expiry; lỗi exact conversion chặn action có giải thích, không tự bỏ traceability.
10. Khóa các mutation nhạy cảm khi financial snapshot không editable; phase 6 bổ sung integration actual receipts.
11. Gate: `pnpm spree rspec spec/workflows/spree/pos/pricing_spec.rb spec/requests/spree/pos/catalog_customers_spec.rb spec/workflows/spree/pos/unit_normalization_spec.rb spec/workflows/spree/pos/sale_line_identity_spec.rb`; app unit/e2e thật.

## Success Criteria

- [ ] W03, W06: đủ 100 physical scan intents, network replay không tăng kép; create customer đúng tab không fake email.
- [ ] W07, F18: %/VND/price override/recalc/zero-total đúng server rounding và quyền; reject fractional receipt/total không reject exact fractional base-unit price đã qualify.
- [ ] I01, I02, I07: weighted/unit/price-label DTO + input có API thật, exact base-unit proof và conversion version guard.
- [ ] I03–I05: serial-lot selector xử lý capability unavailable rõ; stock reservation/reader lifecycle hoàn thiện phase 8 trước thu tiền tracked SKU.
- [ ] I08: immutable SaleLine IDs và merge rules giữ độc lập hai gói cùng SKU; core quantity/value/discount/tax và return mapping lossless sau reload/edit/remove.
- [ ] A02, A03, A05: scoped DTO, core bypass bị từ chối, approval cũ không dùng lại sau đổi snapshot.
- [ ] W02, W08: totals/khách/discount giữ sau reload và truy cập được desktop/tablet/keyboard.
- [ ] Preview chỉ draft/catalog/customer/discount; chưa bill finalized, thu tiền hoặc giao hàng.

## Risk Assessment

- Core recalc xóa manual discount: blocker phase 1/W07, chỉ dùng seam đã chứng minh hoặc ADR scoped wrapper.
- Floating math hoặc input `%` nhầm money: decimal-safe parser, tách input types; total/receipt/payout VND nguyên theo policy, không reject exact fractional base-unit price đã qualify.
- Duplicate phone không phải cùng người: cảnh báo/chọn thủ công có quyền, không merge dữ liệu tùy tiện.
- Base-unit price cần precision core không hỗ trợ: hard stop/ADR integration-schema được duyệt; không loại hàng cân khỏi full release để né lỗi.

## Next Steps

Đánh giá preview 1–5; chỉ chuyển phase 6 khi runtime/permission/discount gates đã pass, chưa nhận tiền thật tại preview.
