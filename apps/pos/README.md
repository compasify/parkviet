# ParkViet POS

Ứng dụng bán hàng tại quầy của ParkViet, chạy như một trang riêng, ở gốc tên miền của nó (ví dụ `pos.example.com`, khi chạy local là http://localhost:5175). Cách chạy hệ thống xem [README gốc](../../README.md).

## POS là gì

- Bán hàng tại quầy cho **nhiều chi nhánh** của cùng một cửa hàng. Mỗi chi nhánh có thể có **nhiều quầy**, và mỗi quầy có thể mở **nhiều đơn cùng lúc**.
- Hàng được giao ngay tại quầy, không có giao sau.
- **Cần mạng để bán.** POS không có chế độ bán offline. Khi mất mạng, màn hình khóa các thao tác ghi; khi có mạng lại, POS kiểm tra kết quả các thao tác còn dở.
- Phiếu in ra là **"Phiếu bán hàng POS — không phải hóa đơn điện tử"**.
- **Trạng thái hiện tại: sẵn sàng vận hành.** Nên tự thử máy in, máy quét, máy cân và màn hình khách tại cửa hàng trước khi bán đại trà.

## Khái niệm chính

- **Chi nhánh**: điểm bán gắn với một kho hàng và một múi giờ. Mỗi chi nhánh có danh mục hàng bán riêng.
- **Ngành / mô hình kinh doanh**: mỗi chi nhánh thuộc một ngành. Có 13 ngành bán lẻ chọn được; 6 ngành ăn uống – giải trí hiện nhãn **"Sắp hỗ trợ"**, chỉ để ghi nhận nhu cầu, không tạo được chi nhánh. Ngành là cấu hình gợi ý sẵn, không khóa gì:
  - bật các chức năng bán lẻ hợp với ngành: **Quy đổi đơn vị**, **Hàng cân, tem cân**, **Serial, lô, hạn dùng**;
  - gợi ý mặc định của chi nhánh (số ngày trả hàng, cách chọn lô, ngưỡng) và cách mở danh mục hàng (**Thẻ** hoặc **Danh sách**);
  - nêu các chức năng rủi ro ngành đó thường dùng, nhưng không tự bật.

  Cửa hàng có một **ngành chính**, là ngành mặc định khi tạo chi nhánh mới. Đổi ngành, bật hay tắt từng chức năng được về sau. Chi nhánh có từ trước được xếp vào ngành **Khác**, bật cả ba chức năng, nên không đổi gì.
- **Tắt chức năng không làm đổi cách bán SKU đã cấu hình.** Tắt một chức năng ở chi nhánh chỉ ẩn màn cấu hình của nó và chặn thiết lập *mới*: đặt quy đổi mới, tạo hay sửa mẫu tem cân, gán mã tem mới, khai báo tồn đầu kỳ, đưa SKU mới vào theo dõi serial/lô. SKU đã cấu hình vẫn bán, thu tiền, hoàn tất, trả hàng và in phiếu như cũ. Hàng đã theo dõi serial/lô vẫn **nhập thêm**, chuyển kho, kiểm kê và tra cứu được; tab **Nhập hàng** còn hiện chừng nào cửa hàng còn SKU đang theo dõi.
- **Quầy**: một máy bán hàng có một két tiền. Chi nhánh không có quầy vẫn bán được.
- **Ca**: thu ngân phải mở ca tại quầy, kèm **Tiền đầu ca**, trước khi tạo đơn hoặc thu tiền. Mỗi ca thuộc về một nhân viên.
- **Đơn đang bán (tab "Hóa đơn N")**: mỗi đơn là một tab. Một tab có thể đang chờ chuyển khoản trong khi thu ngân bán đơn khác. Mỗi lúc chỉ một tab hoặc một máy được giữ **quyền sửa** một đơn.
- **Quyền theo chi nhánh**: mỗi nhân viên được cấp quyền riêng ở từng chi nhánh (xem [Quyền](#quyền)). Quyền POS không thay thế vai trò truy cập của cửa hàng.
- **Duyệt bởi người thứ hai**: các thao tác rủi ro (ghi nợ, chi tiền hoàn, chênh lệch két, rút tiền khỏi két, điều chỉnh tồn) phải có người khác duyệt hoặc xác nhận. Không ai tự duyệt yêu cầu của chính mình.

## Chức năng

### Bán hàng

- Tìm hàng theo tên, SKU hoặc mã vạch, hoặc quét bằng máy quét. Xem kết quả dạng **Thẻ** hoặc **Danh sách**. Chỉ hàng được cấp cho chi nhánh mới xuất hiện. Nếu một mã khớp nhiều mặt hàng, POS không tự đoán mà để thu ngân chọn.
- **Hàng cân / tem cân**: quét tem EAN-13 in từ cân điện tử. Máy chủ đọc khối lượng hoặc giá trên tem. Dòng hàng tem cân không sửa được số lượng, chỉ xóa được.
- **Đơn vị quy đổi**: bán theo đơn vị bán (kg, lít, lốc, thùng…), quy đổi về đơn vị gốc theo cấu hình của SKU.
- **Hàng theo serial / lô**: quét serial cho từng cái. Lô được chọn tự động theo hạn dùng gần nhất (FEFO), hoặc thu ngân tự chọn nếu chi nhánh cho phép.
- **Tách từng gói cùng mã**: mỗi lần thêm hàng tạo một dòng riêng, nên hai gói cùng mã nhưng khác giá, lô hoặc hạn dùng không bị gộp hay ghi đè nhau. Chỉ gộp khi thu ngân tích ô **gộp** và gói mới trùng mã, giá, đơn vị, lô, hạn dùng; hàng cân và hàng serial không bao giờ gộp. Sửa số lượng, xóa, giảm giá, sửa giá, trả hàng và hoàn tiền đều theo từng gói (trả gói nào hoàn đúng giá gói đó). Quét nhanh từ danh mục vẫn gộp hàng thường cùng giá.
- **Khách hàng**: mặc định là **Khách lẻ**. Có thể tìm khách theo tên, số điện thoại hoặc email, hoặc **Tạo khách nhanh**. Nếu trùng số điện thoại, POS chỉ cảnh báo, không tự gộp hồ sơ.
- **Giảm giá**: giảm theo dòng hoặc **Giảm giá toàn đơn** (theo phần trăm hoặc số tiền VND, kèm lý do). Có thể nhập **Mã voucher / khuyến mại (Spree)**. **Sửa giá bán** của một dòng là quyền riêng. Khi chính sách yêu cầu, thu ngân nhập **Mã duyệt của quản lý**.
- **Ghi chú tại quầy** và **In tạm tính** (phiếu tạm tính, không phải biên nhận thanh toán).
- **Nhiều đơn song song**: **Đơn nháp mới**, **Tạm giữ** / **Mở lại đơn**, **Hủy nháp**, **Đóng tab** (chỉ ẩn khỏi màn hình, đơn vẫn còn). Khi đơn đã ghi nhận thanh toán, hàng, giá và khách bị khóa.

### Thanh toán

- Ba phương thức:
  - **Tiền mặt**: nhập số khách đưa, POS tính tiền thừa.
  - **Chuyển khoản**: thu ngân xác nhận thủ công, nhập mã giao dịch và tài khoản nhận.
  - **VietQR**: POS hiện mã QR có sẵn số tiền và nội dung chuyển khoản. Khi ngân hàng báo nhận tiền (webhook SePay hoặc PayOS), hộp thanh toán tự báo **Ngân hàng đã báo nhận tiền** và thu ngân bấm **Kết thúc**. Nếu khách đã chuyển mà chưa có thông báo, thu ngân mở **Khách đã chuyển nhưng chưa có thông báo từ ngân hàng** và nhập mã giao dịch. Mỗi đơn chỉ có một mã VietQR đang chờ. Hủy khoản thu sẽ trả lại mã QR, nhưng không hủy được khi ngân hàng đã báo nhận tiền.
- VietQR chỉ hiện khi cửa hàng có phương thức thanh toán VietQR với ít nhất một tài khoản nhận tiền đang hoạt động, và chi nhánh đã bật tính năng **Chuyển khoản VietQR**. Phương thức và tài khoản nhận tiền được cài đặt trong trang quản trị (Admin Dashboard), ở **Settings → Payment methods** và **Settings → VietQR**. POS không lưu cấu hình ngân hàng.
- **Chia nhiều phương thức**: chọn nhiều phương thức cho một đơn và nhập số tiền cho từng phương thức.
- **Để chờ, bán đơn khác**: để khoản thu ở trạng thái chờ xác nhận rồi chuyển sang tab khác. Sau đó quay lại bằng **Tiếp tục thanh toán**.
- Sau khi thu đủ: **Hoàn tất đơn**, **In hóa đơn**, **Giao hàng tại quầy**.
- **Tiền chưa phân bổ**: khoản nhận dư hoặc chuyển khoản đến muộn được giữ trong **Sổ tiền đã nhận / nghĩa vụ**, không tự gán sang đơn khác. Người có quyền có thể **Áp tiền chưa dùng vào đơn này**, hoặc hoàn lại cho khách (**Giữ tiền để hoàn** → **Xác nhận đã hoàn**). Trang **Khoản thu cần chú ý** liệt kê các khoản cần xử lý.

### Bán chịu và thu nợ

- Quản lý mở **tài khoản công nợ** cho khách đã xác định, đặt **Hạn mức** và **Số ngày nợ**, và có thể tạm khóa tài khoản. Khách lẻ không được bán chịu.
- Thu ngân bấm **Ghi nợ** để gửi yêu cầu. Quản lý duyệt trên trang **Duyệt**. Sau đó thu ngân bấm **Hoàn tất & ghi nợ**. Mỗi lần duyệt chỉ có hiệu lực cho đúng đơn và đúng số tiền đó.
- Trang **Công nợ khách hàng** cho xem dư nợ, đơn quá hạn và tuổi nợ. Nút **Thu nợ** nhận một khoản tiền rồi phân bổ vào nhiều đơn (mặc định phân bổ đơn cũ trước). Thu nợ không tạo doanh số mới.

### Trả hàng, hoàn tiền, đổi hàng

- Từ **Đơn hàng** hoặc **Trả / đổi hàng**: tìm đơn gốc, chọn số lượng còn trả được và tình trạng hàng (**Bán lại được** / **Hư hỏng**), **Xem trước** giá trị trả, phần giảm nợ và phần được hoàn, rồi **Lập phiếu trả** → **Nhận hàng trả**.
- Các trường hợp cần người duyệt: trả hàng của chi nhánh khác, quá hạn trả của chi nhánh, hoặc hàng hư hỏng. Chi nhánh không đặt số ngày trả hàng thì không nhận trả.
- Nếu đơn còn nợ, giá trị trả được trừ vào nợ trước, phần còn lại mới được hoàn tiền. **Yêu cầu hoàn tiền** (tiền mặt hoặc chuyển khoản) chỉ được ghi nhận khi có người **Xác nhận đã chi**. Tiền mặt hoàn trả được trừ vào két của ca đang mở.
- **Đổi hàng: mở đơn bán mới** tạo một đơn bán mới cho khách. Phần chênh lệch được thu thêm hoặc hoàn lại như bình thường.

### Tồn kho truy xuất (serial / lô / hạn dùng)

Trang **Truy xuất tồn kho** có các tab: **Mặt hàng theo dõi** (khai báo tồn đầu kỳ, đối chiếu khớp tồn), **Lô hàng** (hạn dùng, **Cách ly** / **Giải phóng**), **Tra serial**, **Nhập hàng**, **Chuyển kho**, **Kiểm kê / điều chỉnh** (có duyệt) và **Thu hồi** (tìm lô hoặc serial đã bán cho đơn nào). Hàng theo dõi chỉ bán được khi đã khai báo tồn đầu kỳ và tồn theo lô/serial khớp với tồn kho.

### Ca và sổ quỹ

Trang **Ca & két** có các chức năng sau:

- **Thu/chi tiền mặt**:
  - **Nộp vào két**: ghi ngay.
  - **Lấy ra khỏi két** và **Nộp két sắt**: cần số chứng từ và một người khác xác nhận.
- **Đóng ca** theo ba bước: **1. Kiểm tra** (các việc chặn đóng ca), **2. Đếm két**, **3. Đối chiếu**.
- **Đếm mù**: thu ngân chỉ thấy số **Két cần có** và **Chênh lệch** sau khi đã nhập số tiền đếm được. Chênh lệch vượt ngưỡng của chi nhánh cần lý do và người duyệt khác.
- **Ca đang mở khác**: đóng ca giúp thu ngân vắng mặt.
- **Đối soát tiền mặt đến muộn**: dùng cho tiền phát hiện sau khi đã đóng ca. Ca đã đóng không bị sửa.

### Báo cáo

Trang **Báo cáo** có năm tab: **Doanh số**, **Thực thu**, **Tiền mặt trong két**, **Công nợ**, **Đóng ca**. Có thể lọc theo ngày, quầy và ca, theo múi giờ của chi nhánh. Không có quyền "Xem báo cáo cả chi nhánh" thì chỉ xem được các ca của chính mình. **Xuất CSV** chạy nền: chỉ người tạo tải được file, và file tự xóa sau 24 giờ.

### Biên nhận và in

Trang **Hóa đơn** dùng để tra cứu và in phiếu bán hàng, trả hàng, hoàn tiền và đóng ca. Phiếu in khổ **Cuộn 80mm** hoặc **A4**, có serial, lô và hạn dùng. Lần in đầu là bản gốc, các lần sau in nhãn **"BẢN SAO – lần N"**. Nội dung phiếu đã chốt không thay đổi khi sửa giá hay tên hàng về sau.

### Màn hình khách

Màn hình khách là một cửa sổ hoặc thiết bị riêng, mở ở `/display`, không cần đăng nhập. Màn hình hiện đơn và số tiền cần thanh toán. Khi thanh toán chuyển khoản, màn hình hiện thông tin tài khoản nhận và nội dung chuyển khoản. Với VietQR, màn hình hiện mã QR để khách quét. Thu ngân chủ động chọn đơn cần hiện; chuyển tab không làm đổi nội dung màn hình khách. Khi màn hình không chắc dữ liệu còn mới, nó chỉ hiện "Đang cập nhật…".

### Máy quét

Mỗi quầy có hiệu chỉnh máy quét riêng: ký tự kết thúc (Enter hoặc Tab) và khoảng cách tối đa giữa các phím. Mặc định là Enter, 100 ms. Thiết lập lưu trên trình duyệt của máy đó.

### Quản trị

Cấu hình POS nằm ở [app quản trị POS](../pos-dashboard/README.md) (`apps/pos-dashboard`), không còn trong POS: chi nhánh, quầy, nhân viên & quyền, hàng bán tại chi nhánh kèm đơn vị và mã tem, mẫu tem cân, chức năng chi nhánh, mô hình kinh doanh, hồ sơ chính của cửa hàng, mẫu in hóa đơn và trang thiết lập lần đầu. POS dẫn sang app đó ở các chỗ sau, luôn mở trong tab mới để các hóa đơn đang mở và phiên bán hàng giữ nguyên:

- Menu đầu trang, mục **Cấu hình** (người có quyền quản trị POS của cửa hàng) hoặc **Chức năng chi nhánh** (quản lý chi nhánh có quyền **Cấu hình** tại chi nhánh đang chọn).
- Mục **Cấu hình** trên thanh điều hướng của các trang ngoài màn bán hàng.
- Nút **Đăng nhập quản trị** ở màn đăng nhập. App quản trị đăng nhập riêng bằng tài khoản admin; POS không chuyển phiên qua link.
- Thông báo "Cửa hàng chưa được thiết lập POS" kèm link **Mở trang thiết lập** (xem bước 0 bên dưới).

Khi bản build production không đặt `VITE_POS_DASHBOARD_URL`, các link này bị ẩn.

Khi ngừng hoạt động một chi nhánh, quầy hoặc nhân viên, lịch sử không bị xóa. Muốn kích hoạt lại cần quyền **Khôi phục**. Trang **Tài khoản nợ** dùng để cấu hình công nợ.

## Cách sử dụng

**Phím tắt:** **F2** đưa con trỏ về ô "Tìm hàng hoặc quét mã". **Esc** đóng hộp thoại hoặc bộ chọn chi nhánh. Ngoài hai phím này, POS chưa có phím tắt nào khác.

0. **Thiết lập cửa hàng** (chỉ một lần, khi cửa hàng chưa có chi nhánh POS nào)
   - Thiết lập làm trong app quản trị POS, ở trang **Thiết lập cửa hàng**. Đăng nhập POS bằng tài khoản quản trị cửa hàng thì màn bán hàng hiện "Cửa hàng chưa được thiết lập POS" kèm link **Mở trang thiết lập**. Tài khoản không có quyền chỉ thấy "Nhờ quản trị cửa hàng thiết lập POS." trong hộp chọn chi nhánh. Cửa hàng đã có chi nhánh thì không còn thông báo này.
   - **Bạn kinh doanh gì?**: chọn ngành. Nếu chọn một ngành "Sắp hỗ trợ", POS hỏi bạn có bán thêm hàng hóa không. Bấm **Có, chọn ngành bán lẻ** để đi tiếp với một ngành bán lẻ; ngành đang quan tâm được ghi lại.
   - **Có bán sỉ không?**
   - **Chi nhánh đầu tiên**: tên, mã (tự tạo từ tên, sửa được), múi giờ, **Kho bán hàng**, tên quầy đầu tiên (mặc định "Quầy 1"; để trống nếu chi nhánh bán không cần quầy), và ô **Cấp cho tôi toàn quyền tại chi nhánh này** (tick sẵn). Nếu cửa hàng chưa có kho, tạo kho trong Admin Dashboard rồi bấm **Tải lại danh sách kho**.
   - **Xem trước**: chức năng sẽ bật, mặc định của chi nhánh (sửa được tại chỗ), đơn vị mẫu sẽ thêm, và nhóm **Ngành này thường dùng**. Các ô trong nhóm này để trống; ô nào bạn tick thì chức năng đó được **bật làm mặc định cho cả cửa hàng**.
   - **Tạo cửa hàng**. Quay lại POS và tải lại trang để chọn chi nhánh và quầy mới; mở ca như bước 2.
   - Nếu đã bỏ tick **Cấp cho tôi toàn quyền**: chi nhánh vẫn được chọn, nhưng tài khoản chỉ cấu hình được, chưa mở ca hay bán được. Cấp quyền ở trang **Nhân viên** của app quản trị POS trước khi bán.
   - Mất mạng ở bước cuối: trang hiện "Đang kiểm tra kết quả…". Bấm **Kiểm tra lại**, không nhập lại. Lệnh cũ được gửi lại đúng như trước nên không tạo hai chi nhánh.
   - Đổi ngành hay chức năng về sau: trang **Mô hình kinh doanh** của app quản trị POS.
1. **Đăng nhập, chọn chi nhánh / quầy**
   - Đăng nhập bằng **Email nhân viên** và **Mật khẩu**.
   - Ở hộp **Chọn nơi bán hàng**, chọn chi nhánh. Chỉ cần chọn quầy nếu chi nhánh có nhiều quầy.
   - Muốn đổi sau này, bấm vào chi nhánh / quầy trên thanh đầu trang. Menu ở đó cũng dẫn tới các trang khác.
2. **Mở ca**: ở màn **Bán hàng**, nhập **Tiền đầu ca** rồi bấm **Mở ca**.
3. **Bán một đơn**
   - Bấm **Đơn nháp mới**, rồi quét hoặc tìm hàng và **Thêm vào đơn**.
   - Gắn khách và giảm giá nếu cần.
   - Chọn phương thức, bấm **Thanh toán**.
   - Ở hộp xác nhận, bấm **Xác nhận đã đếm tiền mặt** hoặc **Xác nhận đã thấy chuyển khoản**.
   - Bấm **Hoàn tất đơn** → **In hóa đơn** → **Giao hàng tại quầy**.
4. **Bán nhiều đơn cùng lúc**
   - Đang chờ khách A chuyển khoản thì bấm **Để chờ, bán đơn khác**, rồi **Đơn nháp mới** để bán cho khách B.
   - Bấm tab "Hóa đơn N" để quay lại đơn A, rồi **Tiếp tục thanh toán**.
   - Đơn đã ẩn bằng **Đóng tab** hiện lại khi bấm **Hiện lại các đơn đã đóng giao diện**.
5. **Thanh toán chia phương thức**: bật cả **Tiền mặt** và **Chuyển khoản**, nhập số tiền của từng dòng, bấm **Thanh toán**, rồi xác nhận từng khoản.
6. **Bán chịu**
   - Gắn khách đã có tài khoản công nợ, bấm **Ghi nợ**.
   - Chờ quản lý duyệt trên trang **Duyệt**.
   - Bấm **Kiểm tra duyệt** → **Hoàn tất & ghi nợ**.
7. **Thu nợ**: vào **Công nợ khách hàng**, chọn khách, bấm **Thu nợ**. Nhập hình thức, số tiền và phân bổ vào các đơn, rồi bấm **Ghi nhận thu nợ**. Khoản thu ghi vào ca đang mở của bạn tại chi nhánh (có thể ở quầy khác); nếu quầy đang chọn không có ca của bạn, trang chỉ nhắc mở ca, còn máy chủ từ chối khi bạn không có ca nào.
8. **Trả hàng**
   - Vào **Đơn hàng**, chọn đơn, bấm **Trả / đổi hàng**.
   - Chọn hàng và tình trạng, bấm **Xem trước**, nhập lý do, rồi bấm **Lập phiếu trả** → **Nhận hàng trả**.
   - Nếu được hoàn tiền: bấm **Yêu cầu hoàn tiền**. Khi đã chi tiền cho khách, người có quyền bấm **Xác nhận đã chi**.
9. **Đóng ca**
   - Vào **Ca & két**, bấm **Đóng ca**.
   - Xử lý các việc còn chặn đóng ca.
   - Đếm toàn bộ tiền mặt, nhập vào ô **Tổng tiền mặt đếm được**, bấm **Ghi nhận số đếm**.
   - Xem chênh lệch. Nếu cần, bấm **Gửi lý do & chờ duyệt**.
   - Bấm **Đóng ca**, rồi **In phiếu đóng ca**.
10. **Xem báo cáo**: vào **Báo cáo**, chọn tab, khoảng ngày, quầy và ca. Bấm **Xuất CSV** rồi tải file ở mục **File xuất của bạn**.
11. **Ghép màn hình khách**
    - Trong khung thanh toán, bấm **Kết nối màn hình khách**.
    - Nếu cùng máy: bấm **Mở cửa sổ màn hình khách**.
    - Nếu thiết bị khác: bấm **Tạo mã kết nối thiết bị khác**, rồi nhập mã 8 ký tự trên thiết bị đó ở `/display`.
    - Bấm **Hiện đơn này cho khách** hoặc **Hiện chuyển khoản …**. Bấm **Xóa màn hình khách** trước khi phục vụ khách tiếp theo.
12. **Hiệu chỉnh máy quét**: trong menu đầu trang, bấm **Máy quét**. Quét thử một mã vạch vào ô, rồi bấm **Lưu cho quầy này**.

## Quyền

Quản lý cấp quyền cho từng nhân viên ở từng chi nhánh, tại trang **Nhân viên** của app quản trị POS.

| Quyền (mã) | Tên trên màn hình | Ý nghĩa |
| --- | --- | --- |
| `pos.shift.open` | Mở ca | Mở ca và bán hàng |
| `pos.discount.apply` | Áp dụng giảm giá | Giảm giá dòng và toàn đơn |
| `pos.price.override` | Đổi giá bán | Sửa đơn giá của dòng hàng |
| `pos.customer.write` | Quản lý khách hàng | Tạo, cập nhật khách tại quầy |
| `pos.payment.collect` | Thu tiền | Thu tiền cho đơn |
| `pos.payment.resolve` | Xử lý tiền thừa/trễ | Phân bổ, hoàn tiền chưa phân bổ; đối soát khoản thu cần chú ý |
| `pos.approval.grant` | Duyệt | Duyệt ghi nợ, trả hàng, chi hoàn tiền, chênh lệch đóng ca |
| `pos.workspace.takeover` | Nhận quyền sửa | Tiếp quản quyền sửa đơn đang bị nơi khác giữ |
| `pos.topology.manage` | Cấu hình | Quản lý POS tại chi nhánh |
| `pos.topology.recover` | Khôi phục | Kích hoạt lại chi nhánh, quầy, nhân viên đã ngừng |
| `pos.credit.sell` | Bán ghi nợ | Hoàn tất đơn với phần ghi nợ đã được duyệt |
| `pos.credit.manage` | Cấu hình công nợ | Mở tài khoản công nợ, đặt hạn mức, số ngày nợ |
| `pos.return.process` | Trả hàng & hoàn tiền | Lập phiếu trả, nhận hàng trả, yêu cầu hoàn tiền |
| `pos.cash.move` | Thu/chi tiền mặt trong két | Nộp vào, lấy ra, nộp két sắt trên ca của mình |
| `pos.report.read` | Xem báo cáo cả chi nhánh | Xem báo cáo mọi ca của chi nhánh |
| `pos.report.export` | Xuất báo cáo | Tạo file CSV |
| `pos.inventory.manage` | Quản lý tồn truy xuất | Nhập, chuyển, kiểm kê, khai báo tồn đầu kỳ, cách ly lô/serial |
| `pos.inventory.trace` | Truy xuất lô/serial | Tra lô/serial đã bán cho đơn và khách nào |

**Cần người thứ hai** (người duyệt không được là người yêu cầu):

- Ghi nợ cho khách.
- Trả hàng của chi nhánh khác, trả quá hạn hoặc hàng hư hỏng.
- Chi tiền hoàn.
- Chênh lệch két khi đóng ca vượt ngưỡng của chi nhánh. Nếu chi nhánh không đặt ngưỡng, mọi chênh lệch đều cần duyệt.
- Lấy tiền ra khỏi két, nộp két sắt.
- Điều chỉnh tồn giảm, hoặc điều chỉnh tăng vượt ngưỡng.
- Đối soát tiền mặt đến muộn do chính mình ghi nhận.

Ngoài ra, giảm giá hoặc đổi giá vượt giới hạn cần **Mã duyệt của quản lý**, và đơn có tổng 0 ₫ cần người có quyền duyệt để hoàn tất.

## Khi có sự cố

- **Mất mạng giữa giao dịch**: đầu trang báo "Mất kết nối" và khóa các thao tác ghi. Khi có mạng lại, bấm **Kiểm tra kết quả thao tác** hoặc **Kiểm tra lại khoản thu chưa rõ**. **Không tạo lại đơn hay khoản thu mới.** POS gửi lại đúng thao tác cũ, nên không bị ghi hai lần.
- **"Đang kiểm tra kết quả…"**: POS chưa biết máy chủ đã ghi nhận thao tác hay chưa. Biểu mẫu được giữ nguyên. Bấm **Kiểm tra lại**, đừng nhập lại từ đầu.
- **Đơn chỉ xem, "Chưa nhận quyền sửa"**: đơn đang được sửa ở tab hoặc máy khác. Hãy đóng nơi đó, rồi bấm **Nhận quyền sửa** (khóa tự hết hạn tối đa sau 2 phút). Nếu được cấp quyền, có thể dùng **Tiếp quản quyền sửa**.
- **Khoản thu cần chú ý / đối soát**: tiền đã về nhưng chưa áp vào đơn hoặc chưa xác định được. Xử lý ở **Khoản thu cần chú ý** và **Sổ tiền đã nhận / nghĩa vụ**. Nếu trình duyệt mất dữ liệu, giữ chứng từ và đối soát thủ công. Chỉ bấm **Đã đối soát** sau khi đã đối chiếu.
- **In lỗi hoặc trình duyệt chặn in**: đơn hàng và tiền không thay đổi. Lượt in đã được ghi nhận, nên lần in lại sẽ có nhãn "BẢN SAO".
- **Màn hình khách không phản hồi**: khi màn hình chưa xác nhận đã xóa, POS chặn hiện khách tiếp theo. Bấm **Màn hình khách không phản hồi** để ngắt màn hình đó, rồi kết nối lại. Lưu ý: khách đã chụp thông tin chuyển khoản vẫn có thể chuyển tiền. Khoản đến muộn sẽ vào tiền chưa phân bổ của đơn gốc.
- **Đăng xuất khi còn thao tác chưa rõ kết quả**: POS hỏi xác nhận trước khi đăng xuất. Đơn trên máy chủ không bị xóa.

## Giới hạn hiện tại

- Chuyển khoản thường vẫn do thu ngân xác nhận thủ công. Chỉ VietQR mới được đối soát tự động, qua webhook SePay hoặc PayOS (xem [Thanh toán](#thanh-toán)).
- Chưa có thanh toán thẻ.
- Chỉ in qua hộp thoại in của trình duyệt. Chưa có driver máy in hay ngăn kéo tiền.
- Chưa kiểm thử với máy in, máy quét, máy cân và màn hình khách thật.
- POS chưa có màn hình cấp **Mã duyệt của quản lý** cho giảm giá hoặc đổi giá.
- Ngành ăn uống – giải trí chưa được hỗ trợ (chỉ ghi nhận nhu cầu). Chưa có đơn vị mét, m², m³; vật liệu xây dựng dùng đơn vị đếm (bao, tấm, cây, xe).
- POS luôn làm việc với cửa hàng mặc định của API: client không gửi `X-Spree-Store-Id`, nên một máy chủ chạy nhiều cửa hàng chỉ dùng POS được cho cửa hàng mặc định.
- Chín tính năng rủi ro (bán chịu, trả hàng, hoàn tiền, đổi hàng, đưa hàng vào theo dõi serial/lô, màn hình khách, thu/chi két, xuất báo cáo, chuyển khoản VietQR) **mặc định tắt**. Quản trị cửa hàng bật ở trang **Tính năng** của app quản trị POS; quản lý chi nhánh chỉ tắt được tại chi nhánh của mình. Khi tắt, nút tương ứng bị khóa kèm lý do; việc đang dở (khoản thu chờ, phiếu trả đã lập, hoàn tiền đã yêu cầu, hóa đơn) vẫn xử lý được.

## Dành cho developer

### App quản trị POS riêng

`apps/pos-dashboard` là app quản trị độc lập, chạy ở cổng **5176**. Khung app
dùng `@spree/dashboard-core` và `@spree/dashboard-ui`; logic thuần dùng chung
(bao gồm bộ dựng phiếu in) nằm trong `packages/pos-shared`. Thao tác in qua
trình duyệt, lựa chọn máy in, ca bán hàng, kho, công nợ, máy quét và màn khách
vẫn thuộc POS. Xem [hướng dẫn app quản trị](../pos-dashboard/README.md).

Đặt `VITE_POS_DASHBOARD_URL` trong cấu hình build của POS để các link quản trị
mở đúng app và đúng cửa hàng. Giá trị có thể bao gồm đường dẫn con nếu app quản
trị không chạy ở gốc domain. Trong dev, mặc định là `http://localhost:5176`.
Production không có giá trị mặc định localhost: phải đặt URL công khai và build
lại POS. Không thêm token hay thông tin đăng nhập vào URL hoặc biến `VITE_*`.

Khi gắn origin mới, thêm origin đó vào **Allowed Origins** của cửa hàng để
`StaffSessionOriginGuard` cho phép refresh/logout. App quản trị đăng nhập bằng
phiên admin riêng; không chuyển JWT của màn bán hàng qua link. Hạ tầng static
phải trả `index.html` cho URL app khi tải lại trang và phục vụ API/cookie qua
HTTPS phù hợp.

POS không còn route `/settings*` hay `/setup`; mọi trang cấu hình và thiết lập
lần đầu nằm trong app quản trị, cùng E2E của chúng (`apps/pos-dashboard/e2e`).

Chạy trong thư mục `apps/pos`:

- `pnpm dev`: chạy Vite ở cổng `5175`, phục vụ ở gốc `/`. Chỉ khi cần gắn POS dưới một đường dẫn con mới đặt `VITE_BASE_PATH` (ví dụ `VITE_BASE_PATH=/pos/`). `spree dev` ở thư mục gốc đã tự chạy lệnh này và app quản trị POS (cổng 5176), không cần chạy thêm. Tắt cả hai bằng `SPREE_POS_DEV=0`. Proxy `/api` mặc định trỏ tới `http://localhost:3000`; có thể đổi bằng `VITE_API_PROXY_TARGET` trong `.env.local`. API chạy qua Spree CLI ở thư mục gốc.
- `pnpm lint`, `pnpm typecheck`, `pnpm test` (Vitest), `pnpm build`.
- `pnpm test:e2e`: chạy Playwright trên ba viewport desktop, tablet, mobile với API giả lập. Cổng mặc định là `5174`, có thể đổi bằng `POS_TEST_PORT` (ví dụ `POS_TEST_PORT=5177` khi 5174 bận).
- Test với API thật (nhóm `real API` trong `e2e/full-retail.spec.ts`, `e2e/concurrency-chaos.spec.ts`, `e2e/advanced-goods.spec.ts`) bị bỏ qua mặc định. Cần stack dev đang chạy, database đã migrate và một fixture tổng hợp mới:
  1. Chép `e2e/support/pos-live-fixture.rb` vào `server/log/` (gitignore), chạy ở thư mục gốc `pnpm spree exec bin/rails runner log/pos-live-fixture.rb`. Script chỉ chạy với database cục bộ và chỉ tạo bản ghi mới có nhãn `POS Live <tag>`: chi nhánh có hạn trả hàng, quầy, ca đang mở, năm sản phẩm có tồn và hai nhân viên với quyền tối thiểu cho các journey: thu ngân (bán, trả hàng, chi hoàn tiền, đóng ca; không ghi nợ, thu/chi két hay sửa khách) và quản lý (duyệt, cấu hình đơn vị/tồn đầu kỳ, bật/tắt cờ cấp cửa hàng; không bán). Credential ghi vào `server/log/pos-live/fixture-<tag>.json` (gitignore, chỉ chủ sở hữu đọc được; `server/tmp` của container không gắn ra máy); xóa file sau đợt thử.
  2. `POS_LIVE_REVIEW=1 POS_LIVE_FIXTURE=<đường dẫn JSON> POS_TEST_PORT=5177 pnpm exec playwright test <spec> -g "real API" --project=desktop`. Test bật cờ cần dùng qua `PUT /pos/feature_flags` bằng tài khoản quản lý (mặc định cấp cửa hàng của store dev) và trả lại trạng thái cũ sau mỗi test. Chạy `full-retail` sau cùng vì nó đóng ca của fixture; lượt chạy đầy đủ tiếp theo dùng fixture mới. Đăng nhập API bị giới hạn tần suất (429), test tự chờ. Khi `POS_LIVE_REVIEW=1`, Playwright mở POS ở `http://localhost:<cổng>` thay vì `127.0.0.1`: API chỉ cho làm mới phiên (`/auth/refresh`) từ origin được phép (store dev cho phép `http://localhost`), nên mở ở `127.0.0.1` thì lần tải lại trang đầu tiên sẽ bị 403 và POS quay về màn hình đăng nhập.
  3. Dọn sau khi thử: `pnpm spree exec bin/rails runner log/pos-live-fixture.rb cleanup` tắt lại các mặc định cửa hàng mà tài khoản fixture còn để bật (lượt chạy bị ngắt), hủy nháp chưa thu tiền, hoàn tất nháp đã thu đủ, hủy khoản thu đang chuẩn bị, đếm két đúng số cần có rồi đóng ca; sau đó mọi nhân viên `pos-live-*@example.test` bị tắt membership POS, gỡ vai trò admin, đổi mật khẩu ngẫu nhiên. Chỉ xóa liên kết vai trò của các tài khoản này. Thêm `store-flags-off=returns,refunds` để tắt cả các cờ đó dù ai đã bật.
  4. `e2e/live-api.spec.ts` (cũ) vẫn đọc `server/pos-live-review-credentials.json`; tên file này đã nằm trong `server/.gitignore`.
  5. Thiết lập cửa hàng với API thật nay chạy trong app quản trị: nhóm `real API onboarding` của `apps/pos-dashboard/e2e/setup.spec.ts`, vẫn dùng fixture `pnpm spree exec bin/rails runner log/pos-live-fixture.rb onboarding=2` và các biến `POS_LIVE_REVIEW=1`, `POS_LIVE_ONBOARDING_FIXTURE`. Dọn bằng `cleanup` như ở bước 3.
- Hồi quy server khi tắt module (D5 của plan đa ngành): `pnpm spree rspec spec/requests/spree/pos/ --tag modules_off_rerun` chạy lại các spec bán / tồn kho có nhãn `modules_off_rerun` với shared context `with branch modules off` (`server/spec/support/pos_module_helpers.rb`): mọi chức năng tắt, trừ lúc chạy chính lệnh thiết lập. Hai example kiểm chính lệnh chặn thiết lập (`module_setup`) được bỏ qua ở lượt này.
- `pnpm test:perf`: đo thời gian chuyển tab, tìm hàng, tạo nháp và xác nhận tiền mặt bằng Performance API của trình duyệt (config riêng `tests/performance/playwright.config.ts`, không chạy trong `test:e2e`). Mặc định API giả lập, chỉ đo phía trình duyệt; thêm `POS_PERF_LIVE=1` và biến fixture ở trên để đo với API thật. Kết quả JSON ở `test-results/perf/pos-scenarios.json` (đổi bằng `POS_PERF_OUT`). Số đo không phải năng lực hệ thống.
- Nhãn giao diện nằm ở `src/locales/vi.json`; danh sách quyền nằm ở `src/lib/pos-capabilities.ts`.
