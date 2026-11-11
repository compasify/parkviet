# ADR 0002: Tiền cọc giữ chỗ là tiền khách gửi giữ

Ngày: 2026-11-12
Trạng thái: đã chấp nhận

## Bối cảnh

Nhà hàng nhận cọc khi khách đặt bàn (module `fnb.reservations`). Bán lẻ có
các nhu cầu cùng dạng trong lộ trình: đặt cọc giữ hàng (module `deposits`),
trả góp và thanh toán theo tiến độ
([kiến trúc §9.1](../../plans/reports/261108-1800-pos-multi-industry-architecture.md)).
Nếu mỗi module tự ghi nhận tiền theo cách riêng, quỹ, báo cáo doanh thu và
đối soát ca sẽ lệch nhau.

Lõi tiền của POS đã có sẵn:

- `ReceivedFunds`: một lần nhận tiền (tiền mặt vào két của ca, hoặc chuyển khoản có mã giao dịch);
- `FundsAllocation`: gán tiền đã nhận vào một đơn;
- `LiabilityPayout`: trả lại tiền đã nhận mà chưa dùng;
- `FundsBalance#available`: phần còn lại của một khoản nhận.

## Quyết định

1. **Cọc không phải doanh thu.** Nhận cọc tạo một `ReceivedFunds` không gắn
   workspace hay đơn nào, gắn với bản ghi cọc (`spree_pos_reservation_deposits`).
   Không tạo đơn, không tạo dòng bán, không có thuế lúc nhận.
2. **Khách đến và trả tiền:** phần còn lại của cọc được trừ vào đơn bằng
   `FundsAllocation`, giống cách thu nợ (`Collection`) đã làm. Phần phải thu còn
   lại trả bằng tender bình thường.
3. **Hoàn cọc:** trả lại bằng `LiabilityPayout` từ phần còn lại của khoản nhận.
4. **Mất cọc:** tạo một đơn dịch vụ "phí giữ chỗ" (dòng `ordinary` của sản phẩm
   chi nhánh chọn, giá đã gồm thuế), rồi allocate tiền cọc vào đơn đó và hoàn tất
   đơn. Doanh thu và thuế chỉ phát sinh ở bước này.
5. **Hoàn cọc và mất cọc cần `Approval`** gắn với bản ghi đặt chỗ, theo revision
   và số tiền. Người có quyền duyệt làm trực tiếp; người khác nhận
   `approval_required` và nhập mã duyệt.
6. Mọi lệnh nhận, trừ, hoàn và mất cọc đi qua `CommandExecutor` (idempotent theo key).

## Hệ quả

- Module `deposits` (cọc giữ hàng), trả góp và thanh toán theo tiến độ của bán lẻ
  **dùng cùng mô hình này**: tiền nhận trước là `ReceivedFunds` chưa allocate;
  trừ vào đơn bằng allocation; trả lại bằng payout; phần khách bỏ thành đơn
  dịch vụ có thuế. Không module nào tự thêm bảng tiền riêng.
- Báo cáo "cọc đang giữ" đọc từ các khoản nhận còn `available` của bản ghi cọc
  trạng thái `held`.
- Tiền cọc tiền mặt nằm trong két của ca nhận nó; đối soát ca tính nó như mọi
  khoản nhận khác.
- Hủy đặt chỗ hay đánh dấu không đến không tự xử lý cọc; cọc vẫn `held` cho tới
  khi được hoàn hoặc giữ.
