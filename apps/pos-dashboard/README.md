# Quản trị ParkViet POS

Ứng dụng quản trị React độc lập, sử dụng Spree dashboard-core/UI **6.0.3**. Ứng dụng
chạy riêng với ứng dụng thu ngân (5175) và Spree Dashboard (5173).

## Phát triển cục bộ

Khởi động API từ thư mục gốc của repository bằng `pnpm spree dev --no-open` (hoặc
sử dụng stack đang chạy), sau đó:

```sh
cd apps/pos-dashboard
pnpm install
pnpm dev
```

Truy cập **http://localhost:5176** và đăng nhập bằng tài khoản nhân viên/quản trị
viên. Cửa hàng đầu tiên mà tài khoản có quyền truy cập sẽ được chọn; dùng bộ chọn
cửa hàng trên thanh bên để chuyển sang cửa hàng khác. Phiên đăng nhập được khôi
phục bằng cookie làm mới HTTP-only của Spree. Để truy cập cấu hình POS, tài khoản
cần có quyền `read_pos_topology` hoặc `write_pos_topology`; quản lý chi nhánh có
quyền `pos.topology.manage` chỉ có thể truy cập phần tính năng và mô hình kinh
doanh của chi nhánh đó.

```sh
pnpm typecheck
pnpm lint
pnpm test
pnpm build
pnpm test:e2e --project desktop
```

Các bài kiểm thử E2E nằm trong `e2e/`; Playwright tự khởi động máy chủ trên cổng
cố định 5176 và chạy với một worker. Không để máy chủ phát triển khác chiếm cổng
này khi chạy bộ kiểm thử. Các dự án desktop, tablet và mobile đều đã được cấu hình.

Ứng dụng thu ngân (`apps/pos`) không còn các trang cài đặt hoặc thiết lập; menu
người dùng, màn hình đăng nhập và thông báo thiết lập của ứng dụng thu ngân sẽ mở
ứng dụng quản trị này trong thẻ mới.

## Biến môi trường công khai khi build

| Biến | Mặc định | Mục đích |
|---|---|---|
| `VITE_SPREE_API_URL` | Để trống | Origin công khai của API; để trống để dùng `/api` cùng origin |
| `VITE_API_PROXY_TARGET` | `http://localhost:3000` | Đích proxy của Vite cho `/api` và `/rails` khi phát triển |
| `VITE_BASE_PATH` | `/` | Đường dẫn gốc công khai, ví dụ `/pos-admin/`; cần build lại khi thay đổi |

Mọi giá trị `VITE_*` đều được nhúng vào các tệp gửi đến trình duyệt. **Không bao
giờ đặt API secret, thông tin đăng nhập cơ sở dữ liệu, token nhân viên hoặc khóa
riêng tư trong các biến VITE.**

Chi nhánh được chọn qua `?branch=...&register=...`; các route tài nguyên chi nhánh
cũng chứa `$branchId`. Khóa cache truy vấn có chứa định danh cửa hàng, và quyền
nhân viên được tải lại khi chuyển cửa hàng. Ứng dụng này không thay đổi schema máy
chủ hay mô hình quyền hạn.

## Triển khai production dưới dạng trang tĩnh riêng

Build bằng `pnpm build` và triển khai `dist/` thành một trang tĩnh riêng, tương tự
cách ứng dụng thu ngân được triển khai trên cổng riêng. `pnpm preview` phục vụ bản
build tại cổng cố định **5176**, với cùng proxy `/api` và `/rails` như `pnpm dev`,
đủ để kiểm tra bản build cục bộ. Việc trỏ tên miền tới cổng là công việc hạ tầng;
không có tên miền nào được khai báo trong mã nguồn.

1. Cấu hình `VITE_SPREE_API_URL` và `VITE_BASE_PATH` công khai **trước khi build**.
   Với cấu hình cùng origin được khuyến nghị, để trống URL API và dùng reverse proxy
   chuyển `/api/*` và `/rails/*` tới Rails. Proxy của Vite chỉ dùng khi phát triển.
2. Phục vụ các tệp tĩnh hiện có như bình thường và chuyển các route ứng dụng về
   `index.html` (SPA fallback), bao gồm `/<store>/settings/receipt-templates/<id>`.
   Nếu triển khai dưới một đường dẫn con, hãy phục vụ tệp tĩnh và áp dụng fallback
   bên dưới cùng đường dẫn gốc đó.
3. Sử dụng HTTPS trong production. Nếu API khác origin, cần cấu hình CORS đúng cho
   các yêu cầu có thông tin xác thực và đăng ký chính xác origin của dashboard
   trong Allowed Origins của Spree để `StaffSessionOriginGuard` hoạt động. Cookie
   làm mới trong production dùng `SameSite=None; Secure` nên cần HTTPS; không bỏ
   qua origin guard hoặc chuyển token làm mới vào bộ nhớ trình duyệt.
4. Kiểm tra đăng nhập, tải lại/làm mới trang, đăng xuất, chuyển cửa hàng và quyền
   truy cập với cấu hình proxy/origin production. Kiểm tra cả URL hình ảnh `/rails`.
5. Đặt biến công khai `VITE_POS_DASHBOARD_URL` của bản build ứng dụng thu ngân thành
   URL của trang này (bao gồm đường dẫn gốc), rồi **build và triển khai lại ứng dụng
   thu ngân**. Chỉ thay đổi môi trường trên máy chủ không cập nhật bundle Vite đã
   build; nếu thiếu biến này, bản production của ứng dụng thu ngân sẽ ẩn các liên
   kết đến trang quản trị.

### Danh sách kiểm tra hạ tầng cho tên miền mới

- Trỏ tên miền tới trang tĩnh (cổng 5176 hoặc nơi lưu trữ `dist/`), bật HTTPS và
  cấu hình SPA fallback như trên.
- Thêm chính xác origin vào **Allowed Origins** của cửa hàng trong Spree. Nếu không,
  `StaffSessionOriginGuard` (`server/config/initializers/staff_session_origin.rb`)
  sẽ từ chối yêu cầu làm mới phiên và đăng xuất, khiến người dùng bị đăng xuất mỗi
  khi tải lại trang.
- Đặt `VITE_POS_DASHBOARD_URL` cho bản build ứng dụng thu ngân và triển khai lại.

### Sau khi triển khai

1. Đăng nhập, tải lại trang và xác nhận phiên đăng nhập vẫn còn.
2. Truy cập trực tiếp một liên kết sâu như `/<store>/settings/receipt-templates`;
   trang phải tải được, không trả về lỗi 404.
3. Đăng xuất và xác nhận các URL được bảo vệ chuyển về trang đăng nhập.
4. Từ ứng dụng thu ngân, mở menu người dùng → Cấu hình: dashboard mở trong thẻ mới
   với cùng cửa hàng và chi nhánh.
5. Đăng nhập bằng tài khoản quản lý chi nhánh: chỉ hiển thị phần Tính năng và Mô
   hình kinh doanh.

Đặt tên miền triển khai trong cấu hình môi trường, không đặt trong mã nguồn ứng
dụng. Xem `AGENTS.md` để biết quy ước về mở rộng và API hook.
