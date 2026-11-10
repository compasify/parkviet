# Hoàn tất tích hợp kênh bán hàng POS

## Kết quả

Đã tích hợp kênh có mã `pos` thuộc cửa hàng hiện tại vào luồng bán hàng POS trên Spree 6.0.3. Các nhóm kiểm thử đã chạy đều đạt. Không tạo kênh, xuất bản sản phẩm, chạy migration hoặc sửa dữ liệu development và lịch sử đơn hàng.

Backend tự gắn kênh cho nháp mới và kiểm tra giao của sản phẩm đang được xuất bản, điều kiện được phép bán và hàng cấp cho chi nhánh. Danh mục, mã vạch thường, tem cân, ID biến thể gửi trực tiếp và tăng số lượng đều được bảo vệ phía máy chủ. Thiếu hoặc tắt kênh không được chuyển ngầm sang Online/Wholesale.

Giá dùng ngữ cảnh chuẩn của Spree; khuyến mại theo kênh xét kênh trên đơn. Khi đã chuẩn bị khoản thu, báo giá được giữ nguyên để tiếp tục thanh toán chia nhỏ và khôi phục giao dịch. Hủy khoản thu chuẩn bị duy nhất sẽ bật lại kiểm tra điều kiện bán. Tiền đến muộn gắn với chính giao dịch vẫn xử lý được; tiền không liên quan không được dùng để vượt kiểm tra kênh cho giao dịch mới. Giá hiển thị hàng cân đã khóa dùng đơn vị bán, không nhầm với giá trên đơn vị cơ sở.

Hai giao diện có hướng dẫn tiếng Việt/Anh và không khóa toàn bộ quản trị, ca bán, lịch sử hoặc đường khôi phục thanh toán khi cấu hình kênh thiếu.

## Kiểm chứng đã thực hiện

| Nhóm | Kết quả quan sát |
| --- | --- |
| Backend tập trung, 6 file | 51 ca, không lỗi; seed 57788; task `ba0a9338c` |
| Backend hồi quy liên quan, 17 file | 136 ca, không lỗi; seed 34064; task `ba3a70a8a` |
| Thanh toán, tem cân và dòng hàng khi module tắt | 38 ca, không lỗi; seed 31488; cùng task `ba3a70a8a` |
| Thư viện dùng chung | 188 kiểm thử đạt; typecheck và lint đạt; task `b4ddf8b74` |
| Frontend bán hàng, mã cuối | 180 kiểm thử đạt; typecheck, lint và build đạt; task `bb232195d` |
| Frontend quản trị POS | 34 kiểm thử đạt; typecheck, lint và build đạt; task `b2289c4c2` |
| Playwright bán hàng | 33 ca đạt trên desktop/tablet/mobile; tasks `b089febb6`, `b5563036c` |
| Playwright quản trị | 33 ca đạt trên desktop/tablet/mobile; task `b04356961` |
| Rà soát diff | `git diff --check` đạt; đã gỡ cấu hình kiểm thử tạm và tracing |

Lượt module tắt ghi nhận 298 request chạy khi mọi module chi nhánh đều tắt và 33 lệnh cấu hình chạy khi bật module. Backend được chạy tuần tự qua Spree CLI, không chạy đồng thời các bộ ghi cùng DB.

Các lỗi phát hiện trong quá trình thực hiện đã sửa và có lượt kiểm tra sau sửa: truy vấn DISTINCT kèm thứ tự mặc định, fixture mới sai hợp đồng, helper tái sử dụng headers bị Rails đổi HTTP method và giá hiển thị hàng cân đã khóa. Windows từng khóa file khiến Biome không ghi định dạng; sau chỉnh định dạng, toàn bộ kiểm tra frontend bán hàng đã đạt. Lượt trình duyệt quản trị đầu tiên vướng cổng 5176; lượt đạt dùng cổng riêng 5178 và không dừng server đang có.

## An toàn dữ liệu và phạm vi kiểm chứng

Đã sao lưu trước khi chạy kiểm thử ghi DB và kiểm tra danh mục cả hai archive bằng `pg_restore --list`:

- `backups/spree-development-pre-pos-channel-261110.dump`
- `backups/spree-test-pre-pos-channel-261110.dump`

Danh mục archive tương ứng nằm trong các file `.contents` cùng tên gốc. Giữ nguyên ép `RAILS_ENV=test`, chặn DatabaseCleaner truncation/deletion và transactional fixtures; kiểm thử an toàn DB đã đạt.

Đây là các nhóm hồi quy được chọn, không phải toàn bộ repository test suite. Playwright dùng API fixtures, không phải giao dịch gateway thật. Editor/LSP không xác nhận sạch nên không dùng làm bằng chứng thay cho compiler và kiểm thử. Các cảnh báo Biome schema/deprecation, API Spree cũ và kích thước bundle vẫn còn; không mở rộng thành đợt nâng cấp cấu hình hoặc tối ưu bundle. Chưa commit hoặc stage thay đổi; `.pi/` và backup không được đưa vào commit.

## Thiết lập vận hành còn cần làm

Cửa hàng Shop được kiểm tra ban đầu chỉ có Online/Wholesale; 62 đơn được đánh dấu POS đang thuộc Online, chưa phân loại nháp/đã hoàn tất. Không tự sửa các đơn này.

Quản trị viên cần tạo hoặc bật kênh mã `pos` trong đúng cửa hàng, xuất bản sản phẩm dự kiến bán rồi cấp sản phẩm cho từng chi nhánh. Sau đó tải lại POS để cập nhật trạng thái. Nháp cũ thuộc kênh khác giữ nguyên nguồn; nháp chưa cam kết thanh toán cần tạo lại để bán mới. Không thêm bộ chọn cửa hàng hoặc multi-store/multi-tenant.

Hướng dẫn chi tiết: [docs/pos-sales-channel.md](../../docs/pos-sales-channel.md). Kế hoạch và trạng thái kiểm chứng: [plan.md](../261110-1056-pos-channel/plan.md).
