# Nhà cung cấp hóa đơn điện tử cho POS

POS xuất hóa đơn điện tử (HĐĐT) cho mỗi đơn hoàn tất qua một **adapter** của nhà cung cấp
(VNPT, Viettel, MISA, …). Căn cứ pháp lý và các quy tắc nghiệp vụ nằm ở
[`legal/hddt-nd254-tt91.md`](legal/hddt-nd254-tt91.md).

Hiện chỉ có adapter **thử nghiệm** (`sandbox`). Chưa có adapter thật vì chưa có tài liệu API
công khai, tài khoản thử của nhà cung cấp và đăng ký sử dụng HĐĐT với cơ quan thuế.

## Luồng phát hành

1. `Spree::Pos::Workspaces::Complete` gọi `Einvoices::Enqueue` trong cùng giao dịch hoàn tất
   đơn. Nếu cửa hàng đặt loại hóa đơn khác `none`, bước này tạo một dòng `spree_pos_einvoices`
   (`pending`) cùng ảnh chụp dòng hàng, rồi xếp một mục outbox `einvoice.issue`. Nhà cung cấp
   lỗi hay chưa cấu hình cũng không chặn việc hoàn tất đơn.
2. `DispatchOutboxJob` (chạy mỗi phút) giao mục đó cho `Einvoices::Issue`, theo cơ chế sau:
   - Issue nhận hóa đơn bằng cách chuyển sang `issuing`, commit, rồi gọi `adapter.issue` **bên
     ngoài mọi giao dịch**. Kết quả cũng được commit riêng.
   - Khi lỗi, lịch thử lại là 1, 5, 15, 60 phút, sau đó cứ 6 giờ một lần.
   - Lỗi có `retryable: false` sẽ chờ người sửa, rồi bấm "Thử lại" trên trang Hóa đơn điện tử.
3. Khi khách không đưa thông tin và máy chủ có địa chỉ công khai (`POS_PUBLIC_BASE_URL`), Issue
   chờ thêm 10 phút (không quá cuối ngày). Trong thời gian đó khách quét QR trên hóa đơn bán
   hàng để tự nhập thông tin.

## Thêm một adapter

1. Tạo `server/app/services/spree/pos/einvoices/<tên>_provider.rb`, kế thừa
   `Spree::Pos::Einvoices::Provider`:
   - `self.label` là tên hiển thị trên màn hình cài đặt. `self.credential_fields` liệt kê tên
     các trường đăng nhập, ví dụ `%w[username password]`.
   - `issue(invoice)` trả về `Provider::Result`. `invoice` là `Spree::Pos::Einvoice` đã có
     `lines_snapshot`, `totals_snapshot`, `buyer`, `seller`, `template_code` và `symbol`.
   - Gửi `invoice.prefixed_id` làm khóa chống trùng nếu nhà cung cấp hỗ trợ, để lần thử lại
     sau một câu trả lời bị mất không tạo hóa đơn thứ hai. Nếu nhà cung cấp không hỗ trợ, hãy
     gọi `status(invoice)` trước khi gửi lại.
   - Khi lỗi, ném `Provider::Error.new(message, code:, retryable:)`. Không đưa thông tin đăng
     nhập vào thông báo lỗi. Issue vẫn che các giá trị này trước khi lưu, nhưng không nên dựa
     vào việc đó.
   - Adapter không ghi cơ sở dữ liệu.
   - Nếu nhà cung cấp tra cứu được mã số thuế, đặt `self.tax_code_lookup?` là true và cài
     `lookup_tax_code`.
2. Đăng ký adapter trong `server/config/initializers/pos_einvoice_providers.rb`:
   `Spree::Pos::Einvoices.register('vnpt', 'Spree::Pos::Einvoices::VnptProvider')`. Màn hình
   cài đặt chỉ cho chọn nhà cung cấp đã đăng ký.
3. Viết spec cho adapter với HTTP giả lập (dự án chưa có WebMock hay VCR; thêm bằng
   `pnpm spree bundle add`, hoặc dùng stub cho client HTTP). Spec không được gọi máy chủ thật
   và không chứa thông tin đăng nhập thật.

## Thông tin đăng nhập

- Thông tin đăng nhập được lưu trong `spree_pos_einvoice_settings.credentials`, mã hóa bằng
  Active Record Encryption, và chỉ ghi được, không đọc lại được qua API.
- Màn hình cài đặt không bao giờ hiển thị lại các giá trị đã lưu.
- Nhật ký kiểm toán và tham số log không chứa các giá trị này.
- Không ghi thông tin đăng nhập vào mã nguồn, seed hay file `.env` được commit.

## Adapter thử nghiệm

`sandbox` không gọi ra ngoài. Nó trả số hóa đơn bằng id hóa đơn và mã tra cứu tính từ id,
nên kết quả không đổi giữa các lần chạy. Ở môi trường production, adapter này chỉ được đăng ký
khi đặt `POS_EINVOICE_SANDBOX=on`. Nút "Phát hành thử" trên màn hình cài đặt chỉ hoạt động với
adapter thử nghiệm và không lưu hóa đơn nào.
