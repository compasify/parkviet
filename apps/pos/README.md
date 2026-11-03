# POS đang phát triển

Shell thử nghiệm, chưa hỗ trợ tạo đơn, tồn kho hoặc thu tiền; không dùng để bán hàng.
Chạy `pnpm install` rồi `pnpm dev` trong thư mục này; API hiện có chạy qua Spree CLI ở thư mục gốc. Dev proxy mặc định trỏ đến `http://localhost:3000`, có thể đặt `VITE_API_PROXY_TARGET` trong `.env.local`. Mở đường dẫn `/pos/`.

Đăng nhập dùng Admin SDK và tài khoản staff thật, access token chỉ ở bộ nhớ; không đặt secret key trong trình duyệt. Hiện chưa có refresh, phục hồi phiên, điều phối nhiều tab, POS context hoặc kiểm chứng bảo mật end-to-end. Reload yêu cầu đăng nhập lại; không coi phase 2 hoàn tất. Chỉ dùng với môi trường phát triển đáng tin cậy.
