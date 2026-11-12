# ADR 0003: Ví suất ăn là tiền giữ hộ, đơn vị chi trả là công nợ

Ngày: 2026-11-12
Trạng thái: đã chấp nhận

## Bối cảnh

Căng tin (module `fnb.meal_accounts`) nhận diện người ăn bằng mã nhân viên. Người
ăn có thể trả bằng ví nạp trước, hoặc công ty / trường trả thay, toàn bộ hay
một phần (trợ giá). Tiền cọc đặt bàn đã chốt mô hình "tiền khách gửi giữ"
([ADR 0002](0002-pos-tien-coc-giu-cho.md)), còn bán chịu đã có tài khoản công
nợ (`CreditAccount`, `ReceivableEntry`).

## Quyết định

1. **Nạp ví không phải doanh thu.** Mỗi lần nạp là một `ReceivedFunds` không
   gắn đơn, trên ca của người thu (tiền mặt vào két). Sổ ví
   (`spree_pos_stored_value_entries`) ghi dòng `top_up` trỏ tới khoản nhận đó.
2. **Trả bằng ví** là allocate các khoản nạp vào đơn, khoản cũ trước (FIFO):
   mỗi phần là một core `Payment` đã hoàn tất cộng một `FundsAllocation`, và
   sổ ví ghi dòng `spend` tương ứng. Không có tender kind mới.
3. **Hoàn số dư** là `LiabilityPayout` trên các khoản nạp, người thứ hai xác
   nhận như mọi payout. Hoàn và điều chỉnh cần `Approval` gắn với tài khoản suất
   ăn, theo revision và số tiền.
4. **Số dư luôn là tổng sổ ví**, và luôn nằm giữa 0 và phần còn `available` của
   các khoản nạp. Mọi lệnh ghi khóa hàng ví trước, rồi mới khóa các khoản nhận.
   Đảo allocation, hoặc payout thất bại / bị hủy, sẽ trả tiền lại vào ví bằng
   dòng `adjust`.
5. **Đơn vị chi trả là khách mua chịu.** Phần của đơn vị chi trả được ghi nợ
   lúc hoàn tất đơn (`complete` với `meal_sponsor`): một `ReceivableEntry` debit
   trên `CreditAccount` của đơn vị chi trả. Hạn mức đã được duyệt khi cấu hình
   tài khoản công nợ, nên từng suất không cần quản lý duyệt. Thu nợ đi qua luồng
   thu nợ hiện có. Trợ giá chia một đơn thành hai phần, nên vẫn chỉ có một đơn
   và một hóa đơn.

## Hệ quả

- Tổng số dư ví là nghĩa vụ phải trả cho người ăn. Kế toán ghi nhận như tiền
  nhận trước của khách, không phải doanh thu, cho tới khi suất ăn được bán.
- Ví chỉ dùng trong căng tin của store, không rút tiền mặt ngoài luồng hoàn có
  duyệt, không chuyển giữa người dùng. Trước khi triển khai, cần kế toán và tư
  vấn pháp lý của khách xác nhận rằng mô hình này không thuộc diện ví điện tử hay
  trung gian thanh toán phải xin phép. Cũng cần xác nhận cách xử lý số dư khi
  người lao động nghỉ việc (hoàn hay khấu trừ lương), và ghi điều đó vào thỏa
  thuận với đơn vị chi trả.
- Bảng kê kỳ của đơn vị chi trả là báo cáo `meal_statement`, cộng lại khớp với
  debit trong sổ công nợ. Khấu trừ lương đọc từ file này; POS không gửi gì sang
  hệ thống lương.
