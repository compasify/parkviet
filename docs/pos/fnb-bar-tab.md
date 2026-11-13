# Tab quầy bar cho bar, pub và club

Hướng dẫn cho bartender và thu ngân ở chi nhánh **Bar, Pub & Club**: khách gọi đồ nhiều lượt và trả tiền khi về. Màn bán là `apps/pos`.

## Khi nào màn bán mở tab quầy bar

Chi nhánh bật **sơ đồ bàn** và **trả tiền sau** với hồ sơ ngành mở trên danh sách tab (Bar, Pub & Club) mở màn bán phục vụ tại bàn ([Bán tại bàn và trả tiền sau](fnb-ban-va-tra-sau.md)) ở dạng tab: cột các đơn đang mở bên trái, thực đơn ở giữa, phiếu bên phải. Bar không bật sơ đồ bàn vẫn dùng màn bán có tab đơn, với nút **Tab đang mở**.

## Cột tab

Cột trái rộng khoảng 240px và luôn mở cạnh thực đơn. Cột liệt kê mọi đơn đang mở của chi nhánh: các **tab** (đơn theo tên khách, không gắn bàn) và các **đơn tại bàn** (VIP, sofa), mới mở nhất ở trên. Trên cùng là:

- **ô tìm**, nhận con trỏ ngay khi mở màn và giữ con trỏ sau mỗi lần chọn, khi dùng chuột hoặc bàn phím. Trên màn cảm ứng (con trỏ thô) ô tìm không tự nhận con trỏ, để bàn phím ảo không che thực đơn; chạm vào ô khi cần gõ. Gõ tên khách không cần dấu (`tuan` ra **Anh Tuấn**), tên bàn hoặc khu, hoặc số gọi của tab. Còn đúng một dòng khớp thì Enter mở dòng đó;
- **Mở tab**: đã gõ tên trong ô tìm thì mở ngay tab mang tên đó; chưa gõ thì hỏi tên khách. Tab chỉ cần tên. Hai tab đang mở không được trùng tên, kể cả khác hoa thường: mở trùng tên thì màn bán báo và chọn luôn tab đang mở mang tên đó;
- **Sơ đồ bàn**: chuyển sang sơ đồ bàn VIP và sofa (xem dưới).

Mỗi dòng ghi tên khách (với tab) hoặc tên bàn (với đơn tại bàn, kèm khu), giờ mở, tổng tiền và **n chưa gửi** khi còn đồ chưa gửi quầy bar hay bếp. Đơn tại bàn mà khách đã **Gọi thanh toán** có nền xanh lá và ghi chữ **Gọi thanh toán**; tab không gắn bàn nên không có trạng thái này. Dòng đang xem có viền xanh bên trái.

Cột đọc 100 tab mới nhất. Chi nhánh có hơn 100 tab đang mở thì cuối cột ghi số tab cũ hơn chưa hiện; gõ tên vào ô tìm để máy chủ tìm cả các tab đó. Số trên nút **Tab đang mở** (màn nhỏ) đếm mọi tab và đơn tại bàn đang mở.

Chạm một dòng là phiếu đổi sang tab hoặc đơn bàn đó ngay, không qua bảng bàn. Chưa chọn gì thì phiếu ghi **Chưa chọn tab**.

## Gọi đồ, gửi và đóng tab

- **Gọi đồ:** chạm nhóm ở cột danh mục rồi chạm đồ uống. Đồ không có tùy chọn thêm bằng một chạm; đồ có tùy chọn mở bảng tùy chọn tại chỗ.
- **Gửi (n):** gửi n món chưa gửi sang quầy bar hoặc bếp và ở lại tab để gọi tiếp. Bar không có nút **Gửi & ở lại**.
- **Đóng tab** (với tab) hoặc **Thanh toán** (với đơn tại bàn): mở màn thu tiền toàn màn: phụ thu mức chi tiêu tối thiểu của bàn VIP, phần tín dụng đồ uống còn lại của vé vào cửa, ô **Tip** khi thu tiền mặt. Đơn còn món chưa gửi thì màn thu tiền nhắc và có nút gửi. Hoàn tất xong thì màn bán quay về cột tab, không chọn dòng nào, và in hóa đơn khi được yêu cầu.
- **In tạm tính**, giảm giá, ghi chú, khách hàng và **Gửi rượu** (sổ gửi chai, mở ở thẻ trình duyệt mới) nằm trong nút **⋯** của phiếu.

Tab, cũng như đơn tại bàn, là đơn chung của cả chi nhánh: mọi quầy và nhân viên phục vụ thêm đồ, sửa món chưa gửi và gửi đồ vào tab mà không cần giữ quyền sửa, ở màn tab quầy bar cũng như ở màn bán có tab đơn. Thông báo **Đã gửi n món** đếm theo số món máy chủ báo đã gửi. Thu tiền và những việc khác vẫn cần quyền sửa như mọi đơn. Chi nhánh bật khóa sửa chặt thì máy phải bấm **Nhận quyền sửa** trước. Khi khóa sửa tắt, máy đang xem tab tự lấy quyền sửa như ở màn bán tại bàn.

## Sơ đồ bàn VIP

**Sơ đồ bàn** mở bảng bàn của chi nhánh, với các nút lọc, chú thích màu và cách hiện lưới hoặc sơ đồ khu như nhà hàng. Chạm bàn đang có khách mở đơn của bàn đó cạnh cột tab. Chạm bàn trống thì chọn số khách để mở bàn. **← Tab đang mở** ở góc bảng quay lại cột tab.

## Qua nửa đêm

Tab mở trước 0h vẫn nằm trong cột tab sau 0h cho đến khi đóng; cột tab không lọc theo ngày. Doanh thu của tab tính vào ngày kinh doanh lúc mở tab, kể cả khi trả tiền sau nửa đêm.

## Màn nhỏ

- Màn 1366px: cột tab giữ 240px, lưới đồ uống bớt cột chứ không thu nhỏ ô.
- Màn từ 1100px trở xuống (máy tính bảng): cột tab thu thành nút **Tab đang mở** kèm số đơn đang mở ở trên thực đơn. Chạm nút để mở ngăn kéo; ngăn kéo là hộp thoại: phím Tab chỉ đi trong ngăn kéo, phần sau bị che. Chọn một dòng thì ngăn kéo đóng và phiếu hiện dòng đó; chạm ra ngoài hoặc bấm Esc thì ngăn kéo đóng và con trỏ về lại nút **Tab đang mở**. Trên màn cảm ứng ngăn kéo mở mà không bật bàn phím ảo.
