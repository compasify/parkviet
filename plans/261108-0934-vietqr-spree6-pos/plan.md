# VietQR cho Spree 6: gem, dashboard, POS

Status: implemented, chưa commit (chờ quyết định cách đưa gem vào repo)

## Outcome

POS (và storefront sau này) nhận thanh toán chuyển khoản bằng mã VietQR ở bước thanh toán, đối soát tự động qua webhook SePay/PayOS hoặc xác nhận thủ công.

## Constraints

- Gem `spree_vietqr` nằm ở `server/vendor/gems/spree_vietqr` (repo riêng `compasify/spree_vietqr`).
- Bản Spree 5 giữ nguyên ở tag `v0.1.0-spree5` và nhánh `spree-5-stable`; `master` chuyển sang Spree 6 (`1.0.0`).
- Cấu hình payment method, tài khoản nhận tiền và webhook nằm trong Admin Dashboard. POS chỉ hiển thị QR và xác nhận tender.
- Không đổi mô hình tender POS: tiền chỉ được ghi nhận khi nhân viên xác nhận (bằng chứng là webhook đã khớp, hoặc mã giao dịch nhập tay).

## Non-goals

- Giao diện storefront (Store API của gem đã sẵn sàng để làm sau).
- Đổi hành vi bản Spree 5 hoặc dự án omni-store.

## Phases

1. Gem: port sang Spree 6 (status thay cho state, payment_status của order, registry `Spree.payment_methods`, secret được mã hóa, thời hạn QR tính từ lúc cấp phát và cấu hình được), bỏ admin ERB, thêm Admin API v3 cho tài khoản nhận tiền và webhook event, thêm Store API lấy thông tin QR.
2. Server parkviet: cài gem, migration, Dockerfile.
3. Dashboard: trang quản lý tài khoản nhận tiền và webhook event, preference của payment method.
4. POS: tender kind `vietqr` (prepare cấp phát QR, cashier poll trạng thái, confirm bằng webhook hoặc thủ công, cancel giải phóng QR), màn hình khách hiển thị QR, hóa đơn ghi đúng tên phương thức.
5. Kiểm thử: rspec gem + server, vitest/playwright POS, typecheck dashboard.

## Acceptance

- Spec gem và spec POS liên quan pass.
- POS: chọn VietQR → hiện QR; webhook khớp → hộp thanh toán báo đã nhận tiền và đặt focus vào **Kết thúc** (thu ngân vẫn chọn in hoặc không); hủy → QR bị giải phóng.
- Dashboard: tạo payment method VietQR, thêm tài khoản nhận tiền, xem/khớp tay webhook.

## Progress (2026-11-08)

| Phase | Trạng thái | Kiểm chứng |
|---|---|---|
| 1. Gem Spree 6 | Xong, nhánh `spree-6` của repo gem (chưa commit) | `rspec` của gem: 72 examples, 0 failures |
| 2. Server parkviet | Xong | Toàn bộ suite server: 444 examples, 0 failures; `vietqr_api_spec` + `vietqr_tender_spec`: 11 examples, 0 failures |
| 3. Dashboard | Xong: Settings → VietQR (tài khoản nhận tiền, thông báo ngân hàng), thẻ hướng dẫn trong form payment method | typecheck, biome, vitest (3) pass; chưa xem trên trình duyệt vì cần đăng nhập admin dev |
| 4. POS | Xong: tender `vietqr`, chia nhiều phương thức tổng quát, màn hình khách hiện QR, hóa đơn in "Chuyển khoản VietQR", cờ chi nhánh `vietqr` | typecheck, vitest 27 file/173 test, Playwright desktop 112 pass/5 skip (live) |
| 5. Tài liệu | README gem viết lại cho Spree 6 (giữ ghi chú tag Spree 5), `apps/pos/README.md` | — |

Còn mở:

- Đẩy gem lên GitHub (`compasify/spree_vietqr`): tạo nhánh/merge `spree-6` vào `master`. Trước khi đẩy, omni-store nên khóa gem ở tag `v0.1.0-spree5`, vì hiện nó theo nhánh mặc định.
- Cách đưa gem vào repo parkviet: git submodule (cần push trước) hoặc commit thẳng mã nguồn vào `server/vendor/gems`.
- PayOS dùng chữ số của số đơn làm `orderCode`; cần kiểm tra với số đơn POS trước khi bật PayOS.
