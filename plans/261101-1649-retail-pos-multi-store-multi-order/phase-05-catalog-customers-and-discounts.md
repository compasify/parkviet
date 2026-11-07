---
phase: 5
title: "Hàng hóa, khách hàng và giảm giá có kiểm soát"
status: completed
priority: P1
dependencies: [1, 3, 4]
effort: "Ước tính 16–24 person-days; phụ thuộc precision ADR (chuyển từ phase 1 sang phase 5/8)"
---

# Phase 5: Hàng hóa, khách hàng và giảm giá có kiểm soát

## Overview

Nối catalog/customer/pricing thật vào nhiều workspace, dùng wrapper scoped thay browser gọi core writes.
Đây là mốc preview 1–5, chưa được thu tiền hoặc quảng bá là POS vận hành.
Chuẩn: [UX §5,9](./specs/ux-and-workflows.md), [kiến trúc §8](./specs/product-and-architecture.md), [API/tests](./specs/api-contract-and-test-matrix.md).

## Requirements

- Đơn bán trực tiếp có hàng thực tế tại quầy: tồn không đủ hoặc không đọc được tồn thì cảnh báo, cho tiếp tục theo policy; snapshot không bảo đảm khả dụng và xung đột online chuyển tracking stock. Tồn không xác định phải hiển thị riêng; không nhầm on-hand với purchasable. Cần mạng để bắt đầu bán; đây là yêu cầu tương lai, không có nghĩa checkout đã được bật; xem [policy](./reports/pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng).

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

- [x] W03, W06: đủ 100 physical scan intents, network replay không tăng kép; create customer đúng tab không fake email. *(Scanner đã nối vào tab đang sửa: unit 100 intent (`scanner-queue.test.ts`), e2e `catalog-scan.spec.ts` 20 lần quét liên tiếp đúng thứ tự/revision, mất response rồi thử lại cùng key không tăng kép, barcode mơ hồ không tự thêm, tạo khách sau mất response giữ key và gắn đúng tab, không gửi email trống. Máy quét vật lý thật chuyển phase 10/11.)*
- [x] W07, F18: %/VND/price override/recalc/zero-total đúng server rounding và quyền; reject fractional receipt/total không reject exact fractional base-unit price đã qualify. *(`sale_lines_spec.rb`, `workspace_discounts_spec.rb`, `pricing_spec.rb`, `sale_guards_spec.rb`: giảm về 0, override VND lẻ bị từ chối cả lúc thêm dòng, override cần đúng quyền riêng.)*
- [x] I01, I02, I07: weighted/unit/price-label DTO + input có API thật, exact base-unit proof và conversion version guard. *(`scale_labels_spec.rb`: tem cân và tem giá EAN-13 theo mẫu của chi nhánh, checksum, quy đổi gram chính xác, tem giá chỉ nhận khi giá server tái tạo được; `unit_normalization_spec.rb`, `sale_lines_spec.rb`; sửa số lượng bị chặn khi phiên bản quy đổi khác dòng. Máy cân/in tem thật chuyển phase 10.)*
- [x] I03–I05: serial-lot selector xử lý capability unavailable rõ; stock reservation/reader lifecycle hoàn thiện phase 8 trước thu tiền tracked SKU. *(Nhập lô/serial nháp hiện "chưa giữ hàng"; server bắt đủ serial và không trùng. Reservation thuộc phase 8.)*
- [x] I08: immutable SaleLine IDs và merge rules giữ độc lập hai gói cùng SKU; core quantity/value/discount/tax và return mapping lossless sau reload/edit/remove. *(`sale_lines_spec.rb` + `sale_guards_spec.rb`: gói cân và serial không bao giờ gộp, cùng lô khác hạn tách dòng, measurement event không thêm hai lần, serial không bán hai lần. Return mapping thuộc phase 8.)*
- [x] A02, A03, A05: scoped DTO, core bypass bị từ chối, approval cũ không dùng lại sau đổi snapshot. *(`sale_guards_spec.rb`: approval chỉ dùng một lần, đúng action/draft, bị thu hồi thì từ chối, bị ràng buộc đúng số tiền thực áp; sửa snapshot khi tender đang giữ bị từ chối `snapshot_locked`; variant ngoài assortment/ngoài thời gian bán trả 404.)*
- [ ] W02, W08: totals/khách/discount giữ sau reload và truy cập được desktop/tablet/keyboard. *(Detail workspace tải lại từ server sau reload; e2e mock chạy 3 viewport desktop/tablet/mobile, có luồng phím Enter/quét. Kiểm trên API thật và bàn phím đầy đủ chuyển phase 11.)*
- [x] Preview chỉ draft/catalog/customer/discount; chưa bill finalized, thu tiền hoặc giao hàng. *(Thu tiền chỉ ở sandbox phase 6, xem checkpoint.)*

## Risk Assessment

- Core recalc xóa manual discount: blocker phase 1/W07, chỉ dùng seam đã chứng minh hoặc ADR scoped wrapper.
- Floating math hoặc input `%` nhầm money: decimal-safe parser, tách input types; total/receipt/payout VND nguyên theo policy, không reject exact fractional base-unit price đã qualify.
- Duplicate phone không phải cùng người: cảnh báo/chọn thủ công có quyền, không merge dữ liệu tùy tiện.
- Base-unit price cần precision core không hỗ trợ: hard stop/ADR integration-schema được duyệt; không loại hàng cân khỏi full release để né lỗi.

## Next Steps

Đánh giá preview 1–5; chỉ chuyển phase 6 khi runtime/permission/discount gates đã pass, chưa nhận tiền thật tại preview.

## Checkpoint triển khai

**Rà soát source sau các checkpoint dưới:** `server/config/routes.rb` hiện có các route item/customer/discount và controller tương ứng; không coi câu lịch sử “chưa mở API” bên dưới là mô tả source hiện tại. Chưa xác minh deployment/runtime, exposure thực tế hay đủ proof an toàn; xem [rà soát contract](./reports/phase-01-basic-contract-review.md). Phải giữ gate discount cho đến khi capability được kiểm chứng; route tồn tại không chứng minh gate đang được cưỡng chế.

- Đã bắt đầu phần độc lập: hàng đợi scanner trong bộ nhớ giữ thứ tự theo workspace, key riêng cho mỗi scan và dừng khi kết quả chưa rõ; chưa nối UI hay API, không bảo đảm khôi phục sau reload hoặc chống replay server. Có kiểm thử 100 intent tổng hợp, retry và loại trừ IME/input; chưa phải kiểm thử scanner vật lý hoặc end-to-end.
- Các gate phase 4 do agent khác tiếp tục xử lý. Precision/discount và mapping hàng cân vẫn thiếu proof/ADR phase 1; core đã quan sát gộp và ghi đè các gói cùng variant. Không bật mutation hàng hóa, giá hoặc discount dựa trên hàng đợi này. Phase 1 ghi nhận scope tách gói chuyển sang plan riêng; các tiêu chí đầy đủ ở phase này vẫn chưa đạt.
- Đã thêm assortment tường minh `spree_pos_branch_products` (mặc định rỗng), API topology writer thêm/xóa sản phẩm cùng store và API catalog yêu cầu membership chi nhánh active. Search tên/SKU/barcode, phân trang, báo exact barcode trùng; trả on-hand đúng kho được cấp, không coi là tồn có thể bán. UI tìm kiếm chỉ đọc. Migration đã áp trên test và development qua Spree CLI; request specs và e2e mock có kiểm, chưa có e2e API thật. Chưa có giá/ảnh/variant options hoặc quản lý assortment trên UI.
- Thêm parser decimal input không dùng float: phân biệt giá decimal, total VND nguyên và phần trăm, không tính toán hoặc tự làm tròn. Chưa nối vào UI/pricing và không thay thế proof precision server.
- Spike VND trên draft: `1250 × 0.4 = 500` trước thuế/discount và manual line discount sống qua một recalc đơn giản. Nhưng core order discount 10% sau khi xóa một dòng rồi đổi quantity dòng còn lại từ 1→2 giữ discount cũ 10, total 190 thay vì 180; test characterization giữ nguyên hành vi này. Chưa được bật manual discount cho đến khi seam POS tái tính an toàn, stacking/tax/approval và test đầy đủ.
- Customer mặc định Spree 6.0.2 yêu cầu email cả validation và NOT NULL database. Quick-create không email vẫn chưa có seam scoped được chứng minh; không tạo email giả hoặc bỏ validation chung. Cần thiết kế mapping/permission cho khách POS và kiểm không ảnh hưởng storefront trước khi mở ghi.
- Người dùng chấp thuận hướng POS discount intent + adjuster: promotion trước/manual sau, fixed VND quá base phải từ chối, không tự clamp. Calculator thuần server tái dùng rounding và largest-remainder Spree, có test phân bổ VND và validation. Adjuster thử nghiệm chưa nối vào endpoint, permission, approval hoặc UI; không bật discount và không coi test calculator là proof thuế/stacking/revision.
- Cập nhật thử nghiệm: migration intent/allocation đã áp **chỉ database test**; adjuster POS chưa đăng ký trong ứng dụng, chỉ gắn tạm trong spec. Với workspace/intent thật, test recalc 10% từ 90 lên 180 sau tăng quantity và recalc lặp lại pass; test riêng xác nhận core vẫn là snapshot 190. Chưa chứng minh transaction/concurrency, vòng đời xóa dòng, promotion/tax, payment commitment, approval và quyền; chưa áp migration development, chưa mở API/UI discount. Đây chưa phải bản sửa đang hoạt động cho người dùng POS.
- Checkpoint hiện tại (sau các checkpoint trên; câu cũ về API/UI discount, customer không email và migration development đã lỗi thời): discount intent/allocation + POS adjuster đã nối qua workspace command có capability `pos.discount.apply`, approval action/amount/revision-bound, audit và UI hiển thị totals từ server. % tính lại theo base hiện tại; fixed quá base bị từ chối, không clamp. Khách POS phone-only dùng hồ sơ POS riêng, email khớp tài khoản Spree thì liên kết khách gốc; gắn/xóa qua workspace command. Thêm/sửa/xóa dòng thường theo line ID chỉ cho variant thuộc assortment branch. Ghi chú POS để riêng trên workspace (migration `20261104124000`, đã áp test + development), không ghi `customer_note`/`internal_note` của đơn gốc. Catalog trả thêm `price`/`compare_at_price`/`currency` theo `price_in` của store; UI hiển thị giá và phân biệt tồn chưa rõ. Workspace đang chọn/ghim tải detail từ server sau reload để khách/dòng/discount/totals/ghi chú không trống oan.
- Cập nhật mới nhất (SaleLine): migration `20261105100000` đã áp test + development. `spree_pos_sale_lines` map 1:1 core line item; `UnitsController` đọc theo `read_pos_orders|read_pos_topology` và PUT cần `write_pos_topology` + capability `pos.topology.manage` (Spree key-gate không trộn hai scope trong một controller, nên `Pos::BaseController` tự chạy gate theo action map `pos_permissions`, mặc định vẫn derived scope như cũ). Hàng đo kg exact thành g (1.25 kg = 1250 g, line price 0.1 VND/g); dòng POS được đánh dấu `price_source = manual` nên core không re-price khi đổi quantity. Spec I08 `spec/requests/spree/pos/sale_lines_spec.rb` pass: hai gói cùng variant khác giá override độc lập, merge chỉ khi `merge: true` + cùng merge key (variant/giá/đơn vị/lô/serial), tracked serial luôn tách riêng, edit/remove/line-discount theo `sale_line_id`; VND là zero-decimal nên discount % làm tròn nguyên VND (10% của 125 = 13). Toàn suite backend POS: **121 examples, 0 failures**.
- Cập nhật frontend SaleLine: types `PosLineItem`/`PosVariantUnit` mang SaleLine; `OrderLines` sửa theo measured sale quantity hoặc count, hiển thị lô/serial + trạng thái chưa reserve, line-discount/clear và price-override theo `sale_line_id`; `AddItemForm` tra variant unit/traceability, nhập exact decimal cho hàng đo, nhập lô/serial nháp và merge tường minh (mặc định không merge); catalog thêm nhanh dùng `merge: true` cho scan thường. Frontend: **29 unit tests**, lint, build pass.
- Cập nhật phase 6 ảnh hưởng phase 5: snapshot workspace bị khóa bởi tender prepare/confirmed ở server (`ManageLineItem` guard qua tender attempts), completion chỉ qua completed-receipt guard và handover strict-location. Frontend đã có PaymentPanel/financial summary; phase 5 vì vậy không còn ghi “không mở thu tiền/giao hàng” tuyệt đối, nhưng chỉ ở **sandbox phase 6**: không tiền thật, không tracked SKU, không returns/credit/close.
- Vẫn chưa đạt trong phase 5: price-label barcode (chỉ ordinary), quản lý assortment trên UI, concurrency hai connection, scanner vật lý/e2e API thật. Phase 5 giữ `in-progress`; không đóng chỉ vì phase 6 sandbox đã nối.

## Review 07/11/2026

Người dùng yêu cầu làm phase 5 như phase 3/4: review code, sửa lỗi, bổ sung test rồi đóng.

**Lỗi backend đã sửa:**

- Tender đã `prepared`/`unknown`/`confirmed` vẫn cho đổi discount, coupon, giảm dòng, đổi giá, khách hàng và ghi chú; khách có thể đã trả tiền theo tổng cũ. Nay mọi lệnh sửa snapshot dùng chung `Workspace#ensure_snapshot_editable!`, trả 409 `snapshot_locked`. Cờ `payments` của workspace không còn tính tender `failed`.
- Số lượng hàng đếm dạng JSON `1.9` bị cắt thành 1, `"010"` bị đọc hệ bát phân. Nay chỉ nhận số nguyên 1–10000, không làm tròn ngầm.
- `merge: true` gộp cả gói cân và hàng serial; cùng lô khác hạn dùng gộp làm mất hạn dùng; cùng measurement event gửi lại gây lỗi 500. Nay gói cân và serial luôn tách dòng, hạn dùng nằm trong merge key (key cũ không đổi khi không có hạn dùng), event trùng trả 409, hạn dùng sai định dạng trả 409.
- Serial không kiểm số lượng: `quantity: 3` với một serial vẫn nhận; serial đã có trên đơn vẫn bán lần nữa; SKU cấu hình serial thì thêm được mà không có serial. Nay bắt buộc đúng một serial khác nhau cho mỗi đơn vị và không trùng trên đơn.
- Cấu hình đơn vị nhận base `kg` (hệ số so với `g`), làm số lượng lệch 1000 lần; quản lý chi nhánh A sửa được đơn vị của SKU chỉ bán ở chi nhánh B; kiểm "đã có dòng bán" không khóa. Nay base phải là đơn vị chuẩn, SKU phải thuộc assortment của chi nhánh, và cấu hình được khóa theo variant cùng với lần bán đầu tiên.
- Thêm dòng bằng variant ID bỏ qua `available_on`/`discontinue_on` của sản phẩm mà catalog vẫn lọc; master cũ cạnh option variants bán được. Nay cùng điều kiện với catalog. Catalog preload giá (bỏ N+1).
- Số tiền approval giảm hóa đơn tính trên base đã trừ giảm dòng, trong khi adjuster tính trước giảm dòng: quản lý duyệt 9 nhưng server áp 10. Nay approval được đối chiếu với số tiền adjuster thực áp sau khi tính lại, lệch thì rollback; xóa giảm giá được duyệt theo số tiền của chính giảm giá đó thay vì tổng mọi giảm thủ công.
- Đổi giá chấp nhận quyền giảm giá thay cho quyền đổi giá riêng; đổi giá lúc thêm dòng nhận VND lẻ và không ghi audit trước/sau; idempotency key của đổi giá bỏ qua lý do. Đã sửa cả ba.
- Audit giảm giá/đổi giá thiếu approver và giá trị trước; dùng approval không có audit. Nay ghi `approval_id`, `approver_id`, `before`, số tiền và có audit `approval.consume`.
- Hạn approval so theo giờ app server; nay theo giờ database.
- `customer/clear` kèm `profile_id` lại gắn khách đó; audit tạo khách lưu số điện thoại thô; tra/tạo khách vẫn chạy trên chi nhánh đã tắt. Đã sửa cả ba.

**Lỗi frontend đã sửa:**

- Hàng đợi scanner chưa được nối: quét chỉ chạy tìm kiếm. Nay quét khi không đứng trong ô nhập (loại IME/phím tắt), tra đúng barcode rồi đúng SKU, chỉ thêm khi có đúng một variant có giá; mơ hồ hoặc không thấy thì đưa mã vào ô tìm và báo, không đoán. Kết quả chưa rõ (mạng/5xx) chặn hàng đợi và có nút "Thử lại quét" gửi lại cùng nội dung, cùng key.
- Tạo khách nhanh sinh key mới mỗi lần bấm, mất response thì tạo trùng; tạo được nhưng gắn lỗi thì bấm lại tạo thêm. Nay giữ key theo nội dung form đến khi thành công và gắn lại hồ sơ đã tạo.
- Các form con tự giữ `busy`, hai lệnh cùng revision chạy song song và lệnh sau bị 409. Nay mọi lệnh của một workspace đi qua một hàng tuần tự, mỗi lệnh dùng workspace mới nhất server trả về và khóa control khi đang chạy.
- `clearLineDiscount` đi vòng qua command queue và không xử lý `lease_stale`; nay dùng chung `sendIntent`.
- Sau khi có thanh toán, các control sửa vẫn bật; nay khóa và giải thích lý do. Thông báo lỗi nay hiện message server cho 409/422 thay vì một câu chung.
- Form giảm giá không kiểm giá trị và giữ "10" khi đổi % sang VND; form thêm hàng nhận số lẻ cho hàng đếm; mọi thẻ sản phẩm có cùng tên trợ năng "Thêm hàng". Đã sửa; xóa component chết `line-discount-form.tsx`.

**Test mới:**

- `server/spec/requests/spree/pos/sale_guards_spec.rb` (12 examples): số lượng nguyên, gói cân/measurement event, serial, lô và hạn dùng, cấu hình đơn vị, master và thời gian bán, khóa snapshot theo từng trạng thái tender cho 8 lệnh, quyền đổi giá và VND nguyên, approval theo số tiền thực áp và audit, approval dùng một lần/đúng action/đúng draft/bị thu hồi, clear khách, khách hàng trên chi nhánh tắt và audit không chứa số điện thoại.
- `topology_access_spec.rb`: test hạn approval chuyển sang dời hạn theo giờ database.
- Frontend unit: `workspace-serializer`, `scan-lookup`, `submission-key`, `quantity`, scanner burst, `request-failure`; e2e `apps/pos/e2e/catalog-scan.spec.ts` (5 test × 3 viewport).

**Kết quả 07/11/2026:** `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`: 182 examples, 0 failures. `apps/pos`: lint, typecheck sạch, 62 unit pass; Playwright 117 passed / 6 skipped (live API opt-in).

Người dùng chọn làm nốt tem cân/giá và giao diện assortment trước khi đóng; xem mục dưới.

## Đóng phase 07/11/2026

**Tem cân/giá (EAN-13 in tại cửa hàng):**

- Migration `20261107100000_create_spree_pos_label_formats`: bảng mẫu tem theo chi nhánh (prefix, độ dài mã hàng, độ dài giá trị, số lẻ, đơn vị, dung sai giá, version, active/disabled; một prefix active mỗi chi nhánh, tổng độ dài phải là 12), `label_code` duy nhất theo store trên cấu hình đơn vị SKU, và `label_barcode`/`label_format_id`/`label_format_version` trên SaleLine.
- `MeasurementBarcodeParser`: mẫu active khớp prefix dài nhất mới nhận barcode; sai check digit, giá trị 0, mã hàng chưa cấu hình, đơn vị không khớp hoặc không quy đổi chính xác đều trả 409; tem giá chỉ suy ra khối lượng từ giá server và từ chối khi chênh vượt dung sai. Barcode không thuộc mẫu nào vẫn là barcode thường.
- Thêm dòng bằng `label_barcode`: server tự đọc lại tem, bỏ qua số lượng client gửi, từ chối variant khác hoặc đổi giá, không gộp gói, ghi tem và version vào SaleLine và audit; không sửa số lượng dòng tem (chỉ xóa).
- API quản trị: `branches/:id/label_formats` (list/create/update tăng version/disable), `label_code` qua `PUT units/variant` (đổi riêng mã tem được phép sau khi đã bán, không đổi version), `GET branches/:id/products` liệt kê hàng của store kèm trạng thái gán.
- UI: quét gọi parse trước, tem hợp lệ thêm bằng `label_barcode` và một `measurement_event_id` cố định cho mỗi lần quét (thử lại gửi y hệt); trang Cài đặt có "Hàng bán tại chi nhánh", "Mẫu tem cân" và hộp "Đơn vị và mã tem" cho SKU.

**Test thêm:** `server/spec/requests/spree/pos/scale_labels_spec.rb` (7 examples); unit `measured-label`, `label-format`; e2e `scale-labels.spec.ts`, `branch-assortment.spec.ts`.

**Kết quả 07/11/2026:** backend POS 189 examples, 0 failures; rubocop sạch trên file mới. `apps/pos`: lint, typecheck sạch, 73 unit pass; Playwright 141 passed / 6 skipped (live API opt-in).

**Migration:** đã áp **chỉ database test**. Chưa áp development vì không sao lưu được: `pg_dump` trong container là bản 17, PostgreSQL server là 18. Cần sao lưu bằng công cụ bản 18 rồi chạy `pnpm spree migrate`.

**Chuyển phase sau:** máy cân/in tem và máy quét thật (phase 10); W02/W08 trên API thật, race hai connection cho thêm dòng và cấu hình đơn vị (phase 11). Spree 6 đã deprecate `available_on`/`discontinue_on` của product (chuyển sang ProductPublication); catalog và lệnh thêm dòng vẫn dùng hai cột này, cần chuyển khi nâng Spree.
