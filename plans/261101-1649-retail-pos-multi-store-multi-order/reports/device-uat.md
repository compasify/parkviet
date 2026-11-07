# UAT thiết bị tại quầy: máy in, máy quét, màn hình khách

Mẫu để merchant điền khi thử trên thiết bị thật. Chưa có kết quả nào bên dưới: mọi ô "Kết quả" đang trống cho đến khi chạy thử tại cửa hàng. POS chỉ in qua hộp thoại in của trình duyệt; không có driver gốc, in im lặng hay mở két tiền. Muốn dùng các tính năng đó phải chọn model, duyệt và làm adapter riêng.

## 1. Thông tin lần thử

| Mục | Giá trị |
|---|---|
| Ngày thử | |
| Chi nhánh / quầy (mã) | |
| Người thử (merchant) | |
| Người hỗ trợ kỹ thuật | |
| Phiên bản POS (commit) | |
| Trình duyệt + phiên bản | |
| Hệ điều hành máy quầy | |

## 2. Máy in

| Mục | Máy in 80mm | Máy in A4 |
|---|---|---|
| Hãng / model | | |
| Kết nối (USB / LAN / Bluetooth) | | |
| Driver + phiên bản | | |
| Khổ giấy thật (mm) / lề | | |
| Cài đặt trong hộp thoại in (scale, margins, headers/footers tắt) | | |

Kịch bản (ghi Đạt / Không đạt và ảnh chụp bản in):

| # | Kịch bản | Mong đợi | Kết quả |
|---|---|---|---|
| P1 | In bản gốc sau khi hoàn tất đơn tiền mặt | Có tiền khách đưa, tiền thừa, "Phiếu bán hàng POS — không phải hóa đơn điện tử"; chữ tiếng Việt có dấu đúng, số thẳng cột | |
| P2 | In lại cùng đơn | Đầu phiếu có "BẢN SAO – lần N"; nội dung giống bản gốc; không có thanh toán, xuất kho hay đơn mới | |
| P3 | Đơn chia nhiều phương thức + ghi nợ được duyệt | Từng phương thức, mã giao dịch bị che, dòng "Ghi nợ được duyệt" và hạn | |
| P4 | Hàng có quy đổi đơn vị (thùng → lon), cân điện tử | Dòng quy đổi "1 Thùng = 24 Lon", số lượng cân đúng | |
| P5 | Hàng serial/IMEI, hàng có lô/HSD | Serial/IMEI hoặc lô và HSD in theo từng dòng | |
| P6 | Phiếu tạm tính của đơn chưa thanh toán | Nhãn "TẠM TÍNH – CHƯA THANH TOÁN", không có số chứng từ | |
| P7 | Phiếu trả hàng, phiếu hoàn tiền, phiếu đóng ca | Đúng tiêu đề, số tiền đúng chứng từ | |
| P8 | Trình duyệt chặn in / hủy hộp thoại in | Báo lỗi; đơn và tiền không đổi; in lại ra "BẢN SAO" | |
| P9 | Hết giấy / máy in tắt giữa chừng | Không thu tiền lần hai, không đổi đơn; in lại khi máy sẵn sàng | |
| P10 | A4: cùng đơn in A4 | Bố cục A4, không cắt chữ | |

## 3. Máy quét mã vạch

| Mục | Giá trị |
|---|---|
| Hãng / model | |
| Kết nối (USB HID / Bluetooth) | |
| Ký tự kết thúc cấu hình trên máy quét (Enter / Tab) | |
| Kết quả hiệu chỉnh trong POS (Menu → Máy quét): kết thúc, khoảng cách tối đa (ms) | |
| Bộ gõ tiếng Việt đang bật (Unikey/EVKey/Telex/VNI) | |

| # | Kịch bản | Mong đợi | Kết quả |
|---|---|---|---|
| S1 | Quét 20 mã liên tiếp vào đơn đang mở | Đủ 20 lần, đúng đơn đang chọn | |
| S2 | Quét khi con trỏ trong ô SĐT/tên/mã tham chiếu | Không thêm hàng vào đơn | |
| S3 | Quét khi bộ gõ tiếng Việt đang bật | Không ra ký tự lạ, không thêm nhầm | |
| S4 | Mất mạng giữa lúc quét rồi bấm "Thử lại" | Mỗi lần quét được thêm đúng một lần | |
| S5 | Tem cân (giá/trọng lượng) | Số lượng, giá do máy chủ đọc từ tem; không lấy giá từ máy quét | |
| S6 | Máy quét gửi Tab thay Enter (nếu có) | Sau hiệu chỉnh vẫn nhận đủ mã | |

## 4. Màn hình khách

| Mục | Giá trị |
|---|---|
| Thiết bị (màn hình phụ / tablet) + trình duyệt | |
| Cách mở (cửa sổ từ quầy / nhập mã kết nối) | |
| Khoảng tươi `display_freshness_ttl_seconds` đề xuất (5–120 giây, mặc định 15) | |
| Khoảng tươi merchant duyệt sau thử | |

Khoảng tươi chỉ được bật khác mặc định sau khi merchant duyệt ở bảng này (đặt qua `PATCH /api/v3/admin/pos/branches/:id` trường `display_freshness_ttl_seconds`).

| # | Kịch bản | Mong đợi | Kết quả |
|---|---|---|---|
| D1 | Hiện đơn A + chuyển khoản; thu ngân chuyển sang tab đơn B | Màn hình khách vẫn hiện A | |
| D2 | Rút dây mạng màn hình khách ngay trước khi xóa / hủy đơn / thu xong / kết nối lại | Thông tin chuyển khoản ẩn trong khoảng tươi; "Đang cập nhật…" | |
| D3 | Tắt Wi-Fi màn hình khách | Ẩn ngay | |
| D4 | Màn hình ngủ rồi mở lại | Ẩn trước, chỉ hiện lại sau khi tải trạng thái mới | |
| D5 | Không xác nhận sau khi xóa | Thu ngân không hiện được khách kế; nút "Màn hình khách không phản hồi" ngắt màn hình | |
| D6 | Khách chụp QR/tài khoản rồi chuyển muộn sau khi đã đổi đơn | Khoản tiền vào mục tiền chưa phân bổ của đơn gốc, không gán cho khách sau | |
| D7 | Thời gian thực tế từ khi mất mạng đến khi ẩn (đo bằng đồng hồ) | ≤ khoảng tươi + 1 giây | |

## 5. Kết luận

| Mục | Ghi chú |
|---|---|
| Model được duyệt | |
| Giới hạn đã biết | |
| Việc cần làm trước khi mở bán | |
| Chữ ký merchant / ngày | |
