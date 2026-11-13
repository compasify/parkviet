# Quầy nhanh cho cafe, trà sữa, căng tin và trạm dừng

Hướng dẫn cho thu ngân ở chi nhánh bán thực đơn tại quầy mà không có sơ đồ bàn: **Cafe, Trà sữa**, **Căng tin & Trạm dừng nghỉ**, và **Quán ăn** không có bàn phục vụ. Màn bán của thu ngân là `apps/pos`.

## Khi nào màn bán mở quầy nhanh

Màn bán mở **quầy nhanh** khi chi nhánh bật thực đơn và không bật sơ đồ bàn. Chi nhánh có bàn mở bảng bàn ([Bán tại bàn và trả tiền sau](fnb-ban-va-tra-sau.md)). Cửa hàng bán lẻ giữ màn bán theo danh mục như cũ.

Chi nhánh bật **suất ăn và ví** hoặc **hoa hồng tài xế** cũng mở quầy nhanh, với ô mã suất ăn và dải xe ở trạm (xem [Căng tin và trạm dừng](#căng-tin-và-trạm-dừng)). Chi nhánh trả tiền sau hoặc tính giờ (tab quầy bar, phòng karaoke, bida) vẫn dùng màn bán có tab đơn.

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
- Phím F1, F2, F3 không bao giờ mở trợ giúp hay tìm kiếm của trình duyệt. Chúng không làm gì khi đang gõ trong ô nhập, khi một hộp thoại đang mở, hoặc khi đang chọn tùy chọn của món. Ô mã suất ăn để trống không tính là đang gõ, nên ở căng tin F1 vẫn thu được khi con trỏ nằm sẵn trong ô mã.
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

## Căng tin và trạm dừng

### Ô mã suất ăn

Chi nhánh bật **suất ăn và ví** có ô **Mã nhân viên / tên** ở đầu phiếu, luôn sẵn cho mọi đơn. Con trỏ nằm sẵn trong ô: chạm món hay nút trên quầy xong, con trỏ quay về ô; thu xong một đơn, ô sẵn sàng cho người ăn kế tiếp. Thu ngân đang gõ ở ô khác (tên khách) hay đang mở hộp thoại thì con trỏ không bị kéo về.

- Quét thẻ hoặc gõ mã rồi **Enter**: suất được ghi vào đơn trên phiếu, kèm âm báo hợp lệ. Máy quét gõ phím rất nhanh và kết thúc bằng Enter; các ký tự luôn vào ô mã, phím F1–F3 không nuốt ký tự nào.
- Gõ tên: ô liệt kê những người khớp để chọn.
- Mã là mã vạch sản phẩm thì món được thêm như quét mã ở quầy.
- Suất trùng, hết suất trong ngày, ngoài giờ ăn hay tài khoản bị khóa: dòng chữ đỏ ngay dưới ô ghi lý do, kèm âm báo trùng hoặc lỗi. Không có hộp thoại nào bật lên. Nút **Âm báo** bật hoặc tắt âm trên máy này.

Ghi suất xong, dưới đầu phiếu hiện tên người ăn, mã và nhóm, số dư ví, số suất còn trong ngày, phần **công ty trả** và phần **người ăn trả**. Cách thu:

- Nút trên thẻ người ăn **Trả … bằng ví và hoàn tất** trừ phần người ăn vào ví rồi hoàn tất đơn; phần công ty ghi vào công nợ của công ty.
- Cuối phiếu ghi thêm dòng **Người ăn trả**. **Tiền mặt đủ** (F1) và các nút mệnh giá chỉ thu phần này, rồi hoàn tất đơn với phần công ty ghi nợ.
- Công ty tạm ngừng nhận suất: tiền mặt mở màn thu tiền, nơi báo lý do. Đơn công ty trả hết thì **Tiếp tục thanh toán** (F3) hoặc nút **Hoàn tất suất ăn** trên thẻ người ăn hoàn tất đơn.
- Trong lúc mã đang được tra và ghi, rồi tải phần chia của đơn, cuối phiếu ghi **Đang kiểm suất ăn…** và nút tiền mặt chờ, để không thu nhầm cả phần của công ty; F1 bấm lúc này không thu gì. Không đọc được phần chia thì phiếu ghi lý do kèm nút **Thử lại**.
- Đơn trên phiếu đổi hoặc đã thu xong trong lúc mã đang tra: suất không được ghi vào đơn khác, ô mã báo đỏ để quét lại.

### Xe ở trạm

Chi nhánh bật **hoa hồng tài xế** có dải **Xe đang ở trạm** phía trên lưới món. Mỗi xe đang ở trạm ghi biển số, nhà xe, số khách và số đơn đã gắn.

- **+ Lượt xe** mở form ghi biển số, loại xe và số khách khi xe vào trạm. Nút này và **Chốt lượt** chỉ hiện với nhân viên có quyền vận hành hoặc quản lý lượt xe; nhân viên khác vẫn gắn đơn vào xe được.
- Chạm một xe để gắn đơn trên phiếu vào xe đó; chạm lần nữa để bỏ. Giá đơn không đổi: hoa hồng không phải giảm giá.
- **Chốt lượt** khi xe rời trạm: bấm lần nữa vào **Xe … đã đi — chốt** để xác nhận. Còn đơn gắn xe chưa thanh toán trên phiếu hoặc trong dải đơn chờ của quầy thì bước xác nhận báo số đơn đó, vì đơn chưa thanh toán không được tính hoa hồng. Xe đã chốt rời khỏi dải; việc chi hoa hồng cho tài xế làm ở trang **Lượt xe**.
- Phiếu trống đã gắn xe không bị lấy làm phiếu cho khách sau; nó nằm trong dải đơn chờ.
