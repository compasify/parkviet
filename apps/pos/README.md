# POS đang phát triển

POS preview: hỗ trợ đơn nháp và tìm catalog chỉ đọc; chưa hỗ trợ thêm dòng, bán hàng hoặc thu tiền. Không dùng để vận hành bán hàng.

Trong thư mục này: `pnpm install`, rồi `pnpm dev`. API chạy qua Spree CLI ở thư mục gốc (`pnpm spree …`), không chạy stack thứ hai và không dùng `spree dev --app pos`. Dev proxy mặc định trỏ đến `http://localhost:3000`; có thể đặt `VITE_API_PROXY_TARGET` trong `.env.local`. Mở đường dẫn `/pos/`.

Đăng nhập dùng Admin SDK và tài khoản staff thật. Access token chỉ ở bộ nhớ. Refresh dùng cookie HttpOnly và một lượt làm mới tại một thời điểm; BroadcastChannel chỉ báo khóa phiên, không gửi token. `GET /api/v3/admin/pos/context` trả danh tính, chi nhánh được phép và ca đang mở. Nhân viên cần `read_pos_orders` hoặc `write_pos_orders` để đọc context. Quyền đó không cấp `write_orders`.

Cấu hình chi nhánh/quầy dùng `write_pos_topology`. Mở ca dùng `write_pos_shifts` cùng capability `pos.shift.open`. Đơn nháp dùng `write_pos_workspaces` và `write_pos_orders`. Chuyển đơn sang quầy khác bị từ chối. Lease kỹ thuật mặc định 120 giây; trang danh sách tối đa 100 bản ghi. Bố cục trình duyệt chỉ giữ id, hết hạn sau 12 giờ, và bị xóa khi đăng xuất.

Danh mục của chi nhánh mặc định rỗng. Staff có `write_pos_topology` có thể cấp sản phẩm cùng store bằng `POST /api/v3/admin/pos/branches/:branch_id/products` với `{ "product_id": "prod_…" }`, hoặc bỏ bằng `DELETE /api/v3/admin/pos/branches/:branch_id/products/:product_id`. Chức năng này chưa có giao diện quản trị. Staff có `read_pos_orders` và membership đang hoạt động ở chi nhánh có thể tìm hàng qua `/pos/catalog?branch_id=…&q=…`; đây chỉ là danh sách tham khảo, không trả giá hay cho thêm hàng. Số on-hand là số tồn vật lý tại kho chi nhánh, không trừ allocation/reservation và không đảm bảo có thể bán. Chưa có chức năng thu tiền.

Đăng xuất lỗi mạng chỉ khóa tab. JWT access đã cấp không bị thu hồi ngay khi logout. Các phase và gate an toàn chưa hoàn tất; xem báo cáo runtime trong plan để biết bằng chứng và giới hạn hiện tại. Chỉ dùng với môi trường phát triển đáng tin cậy.
