# Kênh bán hàng POS

## Thiết lập vận hành

POS dùng kênh có **mã `pos` thuộc cửa hàng hiện tại**. Không dùng tên hiển thị để nhận diện kênh, không tự chuyển sang Online hoặc Wholesale nếu cấu hình thiếu.

1. Trong Spree Dashboard, chọn đúng cửa hàng và mở **Settings → Sales channels**.
2. Tạo kênh với mã `pos` và bật hoạt động. Tên hiển thị có thể là “Point of Sale”.
3. Xuất bản những sản phẩm muốn bán tại quầy lên kênh này. Kiểm tra lịch bắt đầu và kết thúc xuất bản nếu có.
4. Trong app quản trị POS, mở **Hàng bán tại chi nhánh** và cấp sản phẩm cho từng chi nhánh.
5. Quay lại POS hoặc tải lại trang để cập nhật trạng thái cấu hình.

Ứng dụng không tự tạo kênh, tự xuất bản toàn bộ danh mục hoặc thay đổi dữ liệu cũ. Một sản phẩm phải đồng thời đang được xuất bản trên kênh POS, còn được phép bán và được cấp cho chi nhánh mới bán được. Tồn kho vẫn lấy từ kho của chi nhánh.

## Giá và khuyến mại

Danh mục, tem cân và thêm hàng dùng bộ giải giá theo ngữ cảnh của Spree, bao gồm kênh POS, thay vì chỉ lấy giá cơ sở. Khi có đơn, ngữ cảnh giá lấy từ chính đơn đó. Các quy tắc khuyến mại theo kênh kiểm tra kênh trên đơn; không cần giả lập Store API bằng header `X-Spree-Channel`.

Giá cơ sở vẫn là giá dự phòng theo quy tắc chuẩn của Spree khi không có bảng giá phù hợp. Có thể cấu hình catalog mặc định của kênh và bảng giá của catalog trong Spree. Những chính sách không giới hạn theo kênh vẫn áp dụng theo hành vi chuẩn của Spree.

Giá đã ghi trên dòng hàng không bị đổi hàng loạt bởi thay đổi cấu hình kênh. Snapshot đã khóa bởi khoản thu được giữ nguyên; hệ thống không định giá lại giao dịch đã bắt đầu thanh toán.

## Khi thiếu hoặc tắt kênh

POS và app quản trị hiển thị hướng dẫn cấu hình bằng tiếng Việt/Anh. Backend từ chối tạo nháp mới, thêm hàng và tăng số lượng; không chỉ ẩn sản phẩm ở giao diện. Mã vạch thường, mã tem cân và ID sản phẩm gửi trực tiếp đều chịu kiểm tra phía máy chủ.

Có thể tiếp tục xem lịch sử, mở ca, giảm số lượng, gỡ hàng hoặc hủy nháp chưa thu tiền. Nháp có khoản thu đã chuẩn bị, chưa rõ kết quả hoặc đã xác nhận vẫn được tiếp tục xử lý và hoàn tất theo các kiểm tra thanh toán hiện hữu. Việc chuẩn bị khoản thu khóa báo giá nhưng không đồng nghĩa đã nhận tiền.

Nếu sản phẩm bị gỡ xuất bản trước khoản thu đầu tiên, phải gỡ sản phẩm khỏi đơn trước khi bắt đầu thanh toán. Việc phân bổ tiền không liên quan vào một nháp chưa cam kết cũng phải qua kiểm tra kênh; tiền đến muộn của chính giao dịch đó vẫn có đường xử lý.

## Đơn nháp và lịch sử trước thay đổi

Đơn POS tạo mới được gắn kênh `pos` bởi backend. Client không được chọn kênh tùy ý. Những đơn/nháp cũ giữ nguyên kênh gốc, kể cả khi từng được gắn Online.

Không thể thêm hàng hoặc tăng số lượng cho nháp cũ thuộc kênh khác; hãy tạo nháp POS mới. Vẫn có thể hủy nháp cũ chưa thu tiền hoặc xử lý tiếp khoản thu đã bắt đầu. Sửa nguồn của đơn lịch sử là một công việc dữ liệu riêng, không nằm trong tích hợp này.

## Giới hạn phạm vi

Thay đổi này không thêm lựa chọn cửa hàng trên màn bán hàng và không bật multi-store/multi-tenant. App quản trị POS tiếp tục dùng cửa hàng trong route của Spree; màn bán hàng tiếp tục dùng cơ chế chọn cửa hàng hiện có của API.
