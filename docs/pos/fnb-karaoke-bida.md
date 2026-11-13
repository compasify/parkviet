# Bảng phòng tính giờ cho karaoke và bida

Hướng dẫn cho thu ngân và nhân viên phục vụ ở chi nhánh **Karaoke & Bida**: phòng hát, bàn bida và mọi bàn tính tiền theo giờ chơi. Màn bán là `apps/pos`.

## Khi nào màn bán mở bảng phòng

Chi nhánh bật **sơ đồ bàn** và **tính giờ** mở màn bán phục vụ tại bàn ([Bán tại bàn và trả tiền sau](fnb-ban-va-tra-sau.md)). Bảng đầu tiên là **bảng phòng** khi hồ sơ ngành chọn bảng phòng (Karaoke & Bida). Nút **Lưới bàn · Sơ đồ · Phòng** ở góc bảng đổi cách hiện, và mỗi máy nhớ lựa chọn của mình.

Nhà hàng bật thêm tính giờ cho vài bàn bida vẫn mở lưới bàn hoặc sơ đồ như thường. Ô của bàn đang tính giờ có thêm dòng đồng hồ với chữ **Đang chạy**, **Sắp hết giờ**, **Hết giờ** hoặc **Tạm dừng**. Muốn bật hoặc dừng giờ thì chuyển sang **Phòng**.

Chi nhánh tính giờ mà không bật sơ đồ bàn vẫn dùng màn bán có tab đơn.

## Bảng phòng

Trên cùng là khu vực (tầng, dãy bàn) và các nút lọc **Tất cả · Đang dùng · Trống · Cần xử lý**. **Cần xử lý** gồm phòng còn 10 phút hoặc ít hơn đến hết gói giờ hay giờ hẹn, phòng đã quá giờ, phòng tạm dừng quá lâu, phòng gọi thanh toán và phòng có món chưa gửi bếp.

Mỗi ô phòng có:

- tên phòng và loại (Phòng, Bàn bida, VIP);
- **đồng hồ** chữ to nhất. Giờ mở đếm lên. Phòng mua gói giờ hoặc có giờ hẹn thì đếm ngược đến lúc hết; quá giờ thì hiện dấu **+** và số phút đã quá;
- trạng thái bằng chữ và cách đồng hồ đang đếm, ví dụ **Đang chạy · Đếm lên · 100.000 ₫/giờ**, **Sắp hết giờ · Gói giờ · còn lại**, **Tạm dừng · Tạm dừng từ 14:40**, **Đã dừng lúc 15:10**. Giá mỗi giờ là giá đồng hồ đang tính lúc đọc bảng, đã gồm phụ thu theo ngày; khi gói giờ, thẻ giờ hay phút tặng đang trả cho thời gian thì không hiện giá;
- lý do phòng nằm trong **Cần xử lý**, ghi bằng chữ: **Gọi thanh toán**, **Món chưa gửi bếp**, **Ngồi quá lâu**, **Dừng quá lâu**. Sắp hết giờ và hết giờ đã nằm trong trạng thái của đồng hồ;
- **Giờ · Đồ · Tổng**. Khi đồng hồ còn chạy, tiền giờ là số tạm tính của máy chủ ở lần đọc bảng gần nhất. Khi đã dừng, tiền giờ là số đã chốt vào đơn, và đồng hồ hiện số giờ đã chơi theo máy chủ, không tính lúc tạm dừng.

Màu ô đi kèm chữ, không bao giờ chỉ có màu:

| Màu | Nghĩa |
|-----|-------|
| Trắng | Trống |
| Xanh | Đang chạy |
| Cam | Còn 10 phút hoặc ít hơn |
| Đỏ, nhấp nháy | Hết giờ. Máy bật chế độ giảm chuyển động thì ô không nhấp nháy. |
| Xám, biểu tượng tạm dừng | Tạm dừng |
| Viền đứt | Có khách nhưng đồng hồ không chạy (đã dừng chờ thanh toán, hoặc chưa bật giờ) |
| Xanh ngọc | Đang dọn |
| Xám, viền chấm | Ngừng phục vụ |

Đồng hồ luôn tính theo giờ máy chủ. Máy chỉ đếm tiếp từ lần đọc bảng gần nhất, nên giờ trên máy lệch cũng không làm sai tiền giờ.

## Các nút trên ô phòng

| Nút | Việc làm |
|-----|----------|
| **Bắt đầu** | Mở bảng của phòng để chọn gói giờ hoặc quét thẻ giờ, rồi bấm **Bắt đầu tính giờ**. Phòng chưa có đơn thì được mở đơn mới. Ngoài giờ mở cửa của chi nhánh, máy hỏi lại trước khi bật. Phòng đã dừng giờ và đang chờ thanh toán không có nút này, chỉ có **Gọi món** và **Thanh toán**. Phòng đang dọn hoặc ngừng phục vụ không bật giờ được. |
| **Tạm dừng** / **Tiếp tục** | Một chạm. Phòng tạm dừng quá thời gian chi nhánh cho phép cần mã duyệt của quản lý mới tính giờ tiếp được; khi đó **Tiếp tục** mở bảng của phòng để nhập mã hoặc xin duyệt qua điện thoại quản lý. |
| **Gọi món** | Mở đơn của phòng bên cạnh thực đơn. Phòng trống thì hỏi số khách rồi mở đơn. Phòng có nhiều đơn thì chọn đơn. |
| **Thanh toán** | Mở màn thu tiền của đơn. Đồng hồ còn chạy thì máy hỏi trước (xem dưới). |

Người không có quyền bật, dừng giờ thấy câu **Bạn chưa có quyền bật, dừng giờ phòng.** trên bảng. Với họ, nút giờ bị khoá, và nút **Thanh toán** của phòng có đồng hồ đang chạy cũng bị khoá, vì thanh toán phải dừng giờ trước. Khi ca hoặc chi nhánh đang khoá, các nút này cũng khoá.

Chạm vào tên phòng hoặc đồng hồ để mở bảng của phòng. Ở đó có dừng giờ mà không thu tiền, đổi phòng, dùng thẻ giờ, phân công nhân viên phục vụ, và đánh dấu đang dọn hoặc dọn xong.

## Đơn của phòng

Đơn của phòng giống phiếu bàn. Khác ở chỗ đầu phiếu có **dòng tính giờ ghim** gồm:

- đồng hồ, trạng thái bằng chữ, giờ bắt đầu, gói giờ, và giá mỗi giờ khi máy chủ đã báo;
- tiền giờ tạm tính, cập nhật mỗi phút;
- **Tạm dừng** hoặc **Tiếp tục**;
- **Đổi phòng · giữ giá đoạn cũ**: chọn một phòng trống. Đoạn đã chơi ở phòng cũ giữ giá của phòng cũ;
- danh sách các đoạn đã chơi (phòng, giờ vào, giờ ra), mỗi đoạn có nút **Sửa giờ · cần duyệt**: sửa giờ vào (và giờ ra của đoạn đã xong), có lý do và mã duyệt của quản lý. Sửa được cả sau khi đã dừng giờ, kể cả khi đã sang màn thu tiền rồi quay về đơn, cho đến khi đơn được thanh toán.

Khi đồng hồ đã dừng, dòng ghim liệt kê các khoảng giờ đã tính: theo bảng giá, theo gói (tên gói và giá gói, một lần), trả bằng thẻ giờ, và phút tặng (không tính tiền).

Cuối phiếu ghi **Giờ … (tạm tính) + đồ …**. Nút thanh toán ghi **Thanh toán · tạm tính** với tổng gồm cả tiền giờ đến lúc này. Chi nhánh có phí phục vụ hoặc thuế thì nút ghi **Thanh toán · tạm tính, tiền giờ chưa gồm phí, thuế**: phí và thuế trên tiền giờ chỉ có trong số tiền chốt khi dừng giờ.

**Gửi bếp** đưa đồ đã gọi sang quầy bar hoặc bếp rồi về bảng phòng. **Gửi & ở lại** gửi mà vẫn ở lại đơn.

Nút **⋯** của phiếu có **Gửi rượu**, mở sổ gửi rượu trong một tab mới để tìm chai khách gửi, rót và in nhãn mà đơn đang mở không bị mất quyền sửa.

## Thanh toán khi đồng hồ còn chạy

Máy không bao giờ mở màn thu tiền khi đồng hồ của đơn còn chạy hoặc đang tạm dừng. Bấm **Thanh toán** trên ô phòng hay trên phiếu đều mở hộp **Dừng giờ và thanh toán P101?** với tiền giờ tạm tính của máy chủ ngay lúc đó.

- **Dừng giờ và thanh toán**: máy chủ dừng đồng hồ theo giờ của nó và chốt tiền giờ vào đơn, rồi màn thu tiền mở trên đơn đó. Bấm hai lần chỉ dừng một lần.
- **Huỷ**: đồng hồ chạy tiếp, không có gì thay đổi.
- Phòng tạm dừng quá lâu thì phải có mã duyệt của quản lý mới dừng được. Hộp hỏi mã ngay tại chỗ, hoặc xin duyệt qua điện thoại quản lý.
- Đồng hồ đã được máy khác dừng trong lúc hộp đang mở thì màn thu tiền mở luôn.
- Mở màn thu tiền bằng đường khác (liên kết, nút quay lại của trình duyệt) khi đồng hồ còn chạy thì máy quay về đơn và hỏi như trên.

Thu xong, màn hình quay về bảng phòng và in hóa đơn như phục vụ tại bàn.
