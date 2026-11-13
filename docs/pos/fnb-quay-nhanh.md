# Quầy nhanh cho cafe và trà sữa

Hướng dẫn cho thu ngân ở chi nhánh bán thực đơn tại quầy mà không có sơ đồ bàn: **Cafe, Trà sữa**, và **Quán ăn** không có bàn phục vụ. Màn bán của thu ngân là `apps/pos`.

## Khi nào màn bán mở quầy nhanh

Màn bán mở **quầy nhanh** khi chi nhánh bật thực đơn và không bật sơ đồ bàn. Chi nhánh có bàn mở bảng bàn ([Bán tại bàn và trả tiền sau](fnb-ban-va-tra-sau.md)). Cửa hàng bán lẻ giữ màn bán theo danh mục như cũ.

Chi nhánh bật **suất ăn và ví** hoặc **hoa hồng tài xế** (Căng tin & Trạm dừng nghỉ) tạm thời vẫn dùng màn bán cũ có tab đơn.

## Bố cục

Nhóm món ở bên trái, lưới món ở giữa, phiếu đơn ở bên phải. Không có bảng bàn và không có tab đơn: phiếu bên phải luôn là đơn của khách đang đứng ở quầy. Thu xong một đơn thì phiếu trống ngay cho khách sau.

- **Ảnh món:** ô món hiện ảnh của món. Nút **Ảnh món** cạnh nút đổi cỡ ô bật hoặc tắt ảnh. Mỗi máy nhớ lựa chọn của mình; ở quầy nhanh ảnh mặc định bật.
- **Thêm món:** món không có tùy chọn thêm bằng một chạm. Món có tùy chọn (đường, đá, topping…) mở bảng tùy chọn tại chỗ. Món hết hàng ghi **Hết món** và không chạm được. Món đang theo giá khung giờ có nhãn giá giờ trên ô.

## Đầu phiếu

- **Số gọi** hiện chữ lớn khi đơn đã có số. Chi nhánh dùng số gọi mà đơn chưa có số thì đầu phiếu ghi là số sẽ có khi thu tiền.
- **Mang đi / Tại quán:** một chạm đổi kiểu phục vụ của đơn.
- **GrabFood / ShopeeFood:** chi nhánh bật đơn từ app giao đồ ăn thì có thêm các nút này, nằm riêng dưới Mang đi / Tại quán. Bấm một nút mở form nhập một đơn mới của app đó; đơn đang trên phiếu không đổi thành đơn app. Vì vậy các nút này vẫn bấm được khi đơn trên phiếu đang khóa sửa, miễn là thu ngân đang giữ ca.
- **Tên khách:** ô tên khách hiện khi chi nhánh dùng số gọi hoặc in tem ly. Tên in trên tem ly và hiện trên bảng gọi số.
- Nút **⋯** mở các thao tác khác của đơn: khách hàng, ghi chú, giảm giá, hủy đơn.

## Thu tiền ngay trên phiếu

Cuối phiếu là tổng tiền và các cách thu:

| Phím | Nút | Việc làm |
|------|-----|----------|
| F1 | **Tiền mặt đủ** | Thu tiền mặt đúng số phải trả và hoàn tất đơn |
| F2 | **VietQR** | Mở màn thu tiền với mã QR cho số còn phải thu (chỉ khi chi nhánh có VietQR) |
| F3 | **Phương thức khác** | Mở màn thu tiền đầy đủ: thẻ, ví, thẻ tiền, chia nhiều phương thức |

- Các nút mệnh giá gợi ý (ví dụ **Khách đưa 50.000**) thu tiền mặt theo tờ khách đưa, hoàn tất đơn và báo tiền thừa.
- Phím F1, F2, F3 không bao giờ mở trợ giúp hay tìm kiếm của trình duyệt. Chúng không làm gì khi đang gõ trong ô nhập, khi một hộp thoại đang mở, hoặc khi đang chọn tùy chọn của món.
- Đơn còn món chưa gửi bếp (chi nhánh gửi bếp bằng tay): **Tiền mặt đủ** và các nút mệnh giá mở màn thu tiền, nơi báo món chưa gửi và có nút **Gửi bếp**. Gửi xong mới thu, vì đơn đã hoàn tất thì bếp không nhận thêm món.
- Đơn đã thu đủ mà chưa hoàn tất (mất mạng giữa chừng): nút F3 ghi **Tiếp tục thanh toán** để hoàn tất trên màn thu tiền.
- Thu tiền cần ca đang mở của chính thu ngân; phiếu ghi rõ khi chưa mở ca.

Thu xong, hóa đơn in như trước (tự in nếu máy bật tự in). Đầu phiếu mới hiện **Số gọi** của đơn vừa thu trong vài giây, kèm tiền thừa và nút in lại hóa đơn, để thu ngân đọc số cho khách.

Ở màn thu tiền (F2, F3), nút **Đơn mới** về quầy với phiếu trống sau khi hoàn tất; **← Đơn** quay lại đơn để gọi thêm món.

## Món trên phiếu

Chạm một dòng để mở công cụ của dòng: tăng giảm số lượng, ghi chú và tùy chọn, giảm giá, bỏ món. Ở quầy nhanh có thêm **Thêm ly giống vậy** (thêm một ly cùng tùy chọn vào chính dòng đó) và, khi chi nhánh in tem ly, **In lại tem** cho ly đã gửi bếp.

## Giữ đơn

**Giữ đơn** đặt đơn đang làm sang **dải đơn chờ** phía trên lưới món và mở phiếu mới cho khách sau. Mỗi ô trong dải ghi số gọi (hoặc mã đơn), tên khách và tổng tiền. Chạm một ô để mở lại đơn đó trên phiếu. Dải hiện mọi đơn đang mở của quầy, trừ phiếu trống máy này mở sẵn cho khách sau; phiếu trống đó được dùng lại thay vì tạo đơn mới. Đơn do máy khác mở luôn nằm trong dải, không bị máy này lấy làm phiếu mới.

Nếu không mở được phiếu mới (mất mạng hoặc máy chủ từ chối), phiếu báo lỗi kèm nút **Thử lại**. Đơn từ kiosk, QR và app giao đồ ăn cũng nằm ở các khay cạnh dải đơn chờ.

## Gửi bếp và bảng gọi số

Chi nhánh có bếp và không gửi bếp tự động khi hoàn tất đơn thì phiếu có nút **Gửi bếp**. Hàng đợi "đang pha / mời nhận" chỉ hiện trên màn khách (bảng gọi số), không nằm trên màn thu ngân. Nút ghim màn khách nằm trong mục **Màn hình khách** ở cuối phiếu.
