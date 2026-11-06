# Lộ trình và định nghĩa hoàn thành

## Context

**Điều chỉnh 03/11/2026:** Ưu tiên POS cơ bản theo Spree, ít sửa BE; tách từng gói cùng variant khác giá/lô nằm trong [plan riêng](../../261103-pos-goi-hang-truy-xuat/plan.md). Các tham chiếu gate tách gói bên dưới chỉ áp dụng cho capability/release có tuyên bố hỗ trợ tính năng đó, không chặn POS cơ bản. Không bỏ qua kiểm tra tiền, tồn kho, quyền và phê duyệt vận hành phù hợp với scope được bật.

Đây là work packages để triển khai POS đầy đủ đã xác nhận; không phải cắt bỏ phạm vi thành MVP. Tất cả phase mới đều pending. Không ước lượng lịch giao hàng trước khi phase1 qualification xong.

## Roadmap

| Mốc | Output | Có được vận hành bán thật? |
|---|---|---|
| Design gate | Phase1: contracts/spikes, wireframes desktop/tablet và flows nhiều đơn | Không; người dùng duyệt layout và compatibility decisions |
| Internal preview | Phase2–5: app, staff/context, branch/register, nhiều đơn, catalog/customer/discount/measured inputs | Không; chưa có toàn bộ tiền/kho/traceability |
| Financial integration | Phase6–7: split receipts/saga, credit/collections, failure recovery | Chỉ sandbox; không coi UI settled là full stock readiness |
| Operational integration | Phase8–10: stock/serial/lot/weighted correctness, returns/exchange, closure/reporting/devices | UAT hạn chế theo feature flags và checklist riêng |
| Full retail release | Phase11 + mọi acceptance bắt buộc, kể cả hàng cân/quy đổi/serial/lô | Sau sign-off; đây mới là hoàn tất scope |
| Future provider extension | SePay/payOS automatic confirmations tích hợp receipt/settlement contracts | Plan riêng; không blocker POS manual |

Cash pilot sớm nếu muốn là quyết định triển khai riêng, cần security/financial/stock checks của phase11 áp dụng ngay, chỉ ordinary SKUs đã đủ qualification. **Không tự cấp phép pilot tiền thật bằng việc hoàn thành phase6 và không gọi đó là bản POS đầy đủ.**

## Coverage theo yêu cầu

| Yêu cầu | Phase chính | Acceptance |
|---|---|---|
| App thu ngân tiếng Việt quen thuộc | 1,2,5,10 | W01,W08, prototype approval |
| Nhiều cửa hàng × nhiều quầy | 3 | A02,A04,A06 |
| Nhiều tab, nhiều khách song song | 4 | W01–W05 |
| Thêm khách hàng, giảm giá, payment picker | 5,6 | W06,W07,F01–F03 |
| Hàng cân, quy đổi và immutable sale-line | 1,5,8 | I01,I02,I05,I07,I08,F21 |
| Serial/IMEI, lô, hạn dùng | 1,5,8 | I03–I07 |
| Cash/bank/manual external card/split, xử lý tiền chưa phân bổ | 6 | F01–F07,F19,F20 |
| Manager-configured công nợ và thu nợ | 7 | F02,F08–F10,F19,F20 |
| Giao hàng, tồn đúng branch, đổi trả và residual | 8 | F10–F14,F20,F21,I03–I08 |
| Mỗi quầy một két, ca và báo cáo | 3,9 | F15–F17 |
| Bill, customer display freshness/ACK, scan/printer | 10 | W03,W08,W09,F05,F13 |
| Bảo mật, recovery và scale | 11 xuyên suốt | A01–A06 và toàn matrix |

## Gate sau phase 1, trước implementation phụ thuộc

Phase 1 completed 06/11/2026 theo phạm vi điều chỉnh: scope và layout prototype đã được người dùng duyệt, runtime/mount đã kiểm qua CLI. Các gate còn lại dưới đây **chưa pass**; trách nhiệm đã chuyển sang phase 5–8/11 hoặc plan tách gói theo [bảng trách nhiệm phase 1](../phase-01-contracts-and-ux-validation.md), vẫn chặn capability liên quan.

- [x] Người dùng duyệt scope/architecture và layout prototype gate.
- [x] Runtime source/mount verified; nếu phải eject thì có developer approval riêng.
- [ ] Phase1 ADR chọn được exact unit/price representation, không ép fractional quantity vào integer core.
- [ ] Trước khi bật tách gói: same-variant SaleLine mapping lossless có proof trong plan riêng; trước khi bật trả/hoàn: cumulative entitlement/residual có proof, không chỉ cap tổng.
- [ ] Inventory mutator inventory/guard cho tracked SKUs có đường thực hiện không drift/không fork ngầm.
- [ ] Split/credit-return/walk-in/pickup/permission seams được chứng minh; nếu fail phải điều chỉnh plan trước code tài chính.

Phase 1 là công việc qualification/prototype cần authorization riêng để bắt đầu, không đòi proof đã chạy trước khi cho phép viết spike tests. Gate đầu vào phase 2 và gates tài chính/advanced-goods ghi pass/fail riêng; gate liên quan chưa đạt thì không triển khai capability phụ thuộc.

## Go/no-go trước production

- [ ] Feature gates cho đủ ordinary + weighted + converted-unit + serial + lot/expiry; không chỉ normal product demo.
- [ ] Idempotency/concurrency tests và restart recovery tại từng checkpoint.
- [ ] Cash count, debt reconciliation, payout evidence và late-confirmation runbooks được kiểm tra với số liệu mẫu.
- [ ] F19/F20/F21: unapplied funds resolution + parent conservation xuyên child refunds/reversals + cumulative residual; F16 late-cash custody/variance không double-count ca mới.
- [ ] Opening stock/lot/serial provenance đã đối soát; backup/restore và rollback operational không xóa tiền.
- [ ] Thiết bị thực (cân nếu tích hợp, scanner/printer/display) UAT; shortcut không xung đột tác vụ thu ngân.
- [ ] W09: bounded display freshness deadline được chốt/đo, current-generation ACK và offline/sleep-before-clear/cancel/settlement/rebind tests pass; server revoke không được coi đã xóa QR đã render.
- [ ] Chi nhánh pilot được quản lý duyệt, nhân viên được đào tạo; observability/cảnh báo và support ownership rõ.
- [ ] Không outstanding critical/high findings; benchmark có evidence, không hứa vô hạn tài nguyên.

## Next steps

Thực hiện lần lượt dependencies trong phase files sau khi được duyệt. Chia milestone giúp review, không phải lý do bỏ hạng mục đã xác nhận. Acceptance matrix là tiêu chuẩn release, không phải test đã chạy.
