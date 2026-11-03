# Research bổ sung và nhật ký quyết định POS

## Context

Ngày 01/11/2026, người dùng yêu cầu plan POS trước payment gem; đã xác nhận bán lẻ đầy đủ, mọi phương thức cash/transfer/external card/split/debt, nhiều cửa hàng × nhiều quầy. Đây là tài liệu planning; không có code ứng dụng hoặc giao dịch thật.

## Findings

### Research UI Việt Nam

- Sapo có nhiều đơn qua `+`, tab/điều hướng đơn; KiotViet tìm/scan/grid sản phẩm và thêm khách nhanh.
- Sapo/KiotViet có %/VND discount và split-payment picker. Các shortcut khác nhau theo sản phẩm/phiên bản; chọn map nhất quán riêng, không khẳng định sao chép chuẩn chung.
- MISA có branch context và công nợ trong tài liệu bán buôn; không suy thành cùng policy cho mọi khách lẻ.
- Sapo ca bán tách tiền đầu ca, tiền mặt kiểm đếm, lệch ca và thu/chi.
- Exact official URLs + proposed UI được ghi trong [UX spec](../specs/ux-and-workflows.md). Research bằng tài liệu public, không kiểm thử đăng nhập sản phẩm hoặc review screenshot thực.

### Financial research

- Split tender cần tách intent, receipt thật, allocation, Spree Payment và drawer movement. Một session thành công không tự chứng minh mọi split amount an toàn.
- Không fake bank/card/debt completed theo capture policy; tiền mặt cần attestation, chuyển khoản cần phía nhận, máy thẻ ngoài cần chứng từ approved.
- Sale250k + card100k + cash đưa200k → cash applied150k + change50k. Drawer chỉ tăng150k.
- Credit sale1m, đã thu300k, nợ700k: trả400k giảm nợ còn300k không hoàn tiền; trả hết giảm nợ0 và chỉ phát sinh hoàn300k.
- Closure là serialized cutoff; late evidence giữ original sale nhưng book reconciliation hiện tại, không rewrite ca cũ.
- Outbox/recovery và idempotent effects quan trọng hơn giả định exactly-once network. No DB locks across provider I/O.
- Mọi invariant và case bắt buộc đã đưa vào [Architecture](../specs/product-and-architecture.md) và [Test matrix](../specs/api-contract-and-test-matrix.md). Researcher không kiểm chứng runtime Spree cho các seam này.

### Source inspection do controller session thực hiện

- Admin Payment `create` tạo row, default amount không an toàn để client đoán remaining split.
- Core `Orders::Complete#payment_covered?` chấp nhận pending/processing, vì vậy không phải POS verified-money gate.
- Admin `preferred_stock_location_id` mô tả fallback; strict branch sale phải có routing invariant riêng.
- Draft updates rebuild fulfillment/recalc; manual discount persistence khi sửa giỏ là spike release-blocking.
- Source và docs đã biết được đọc trực tiếp vì CodeGraph tools không được expose; không init index hoặc lặp khám phá bằng subagent.
- Review evidence bổ sung: variant-keyed core upsert có thể gộp measured packages cùng SKU; return proportional rounding từng lần có thể under-credit dù không vượt cap. Paths/line references ở architecture §13; compatibility vẫn chưa được chạy thử.

### Correction approval và propagation

- Người dùng đã chọn **Áp dụng hết (Recommended)** cho các correction sau review: unapplied funds resolution, parent consumption xuyên refund/reversal, late-cash custody, distinct SaleLine identity, cumulative return residual, advanced-goods work packages, sandbox-only gates và display freshness/ACK.
- Canonical architecture/API/UX/release specs và phases đã được đồng bộ theo các correction này; [verification report](../reports/planning-verification.md) lưu disposition và kết quả kiểm tra tài liệu. Không coi correction approval là approval code/eject/deploy hoặc proof runtime.

## Decisions và trade-offs

| Quyết định đề xuất | Lý do | Chưa khẳng định |
|---|---|---|
| `apps/pos` SPA riêng | UX thu ngân tách back office, reuse API/core | App chưa scaffold, chưa có UI prototype |
| `server/app` POS namespace | Custom domain riêng, không fork upstream | Endpoint/schema vẫn proposed |
| Branch dưới một merchant Store | Chuỗi cửa hàng chia sẻ catalog/customer | Không tự đồng nghĩa multi-tenant SaaS |
| Server-backed workspaces, lease+revision | Nhiều tab/quầy và reload không mất đơn | Chưa benchmark số quầy |
| POS custom permission wrappers | Không cấp blanket core writes cho thu ngân | Cần bypass tests với role thật |
| Internal sessions/receipt ledger cho actual money | Shared settlement, không fake gateway | Phải spike split/session lifecycle trên runtime |
| Receivable ledger riêng | Nợ không phải tiền, thu nợ không phải doanh số | Credit-return core integration chưa thử |
| Bank manual trước auto | POS không bị chặn bởi provider onboarding | SePay/payOS chưa được triển khai |
| Online-first | Không hứa tính nhất quán tiền/kho khi offline | Không có offline-finalize |

## Unresolved questions và defaults đề xuất

1. **Đã xác nhận**: hàng cân/quy đổi + serial/IMEI/lô/hạn dùng trong scope chính; còn cần độ chính xác đo và format barcode/cân. Gate phase1 cho integer-base mapping và traceability all-writers.
2. Thiết bị printer/scanner/display nào? Bill browser80mm/A4 trước; native bridge/cash drawer driver chỉ sau UAT/phê duyệt.
3. **Đã chọn manager-configured credit**. Còn cần giá trị hạn mức/ngày hẹn/overdue và ngưỡng phê duyệt; capability credit default tắt đến configure, không mặc định nợ vô hạn.
4. Return window/cross-branch, discount/variance/refund thresholds? Manager-configured, action-bound approval; policy chưa coi là user-approved.
5. **Đã chọn mỗi quầy một két**, multi-device không nhân đôi ca. Không cần shared-drawer-many-register model trong release này.

## Next steps

Handoff plan đã reconcile để người dùng xem xét; trước triển khai cần authorization riêng và phase 1 qualification. Không cài package, deploy, migrate, eject hay implement trong phiên lập plan.
