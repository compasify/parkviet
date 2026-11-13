# Nghiên cứu bố cục màn hình bán hàng F&B và giải trí

Ngày: 2026-11-13 (Asia/Saigon). Phạm vi: bố cục màn hình và mẫu UX, không so sánh tính năng.

## Kết luận chính

Các POS nhà hàng có tài liệu tốt đều dùng **hai vùng, không phải ba cột**: thực đơn một bên, phiếu (check/ticket) một bên, còn thanh toán là **một bước riêng** mở đè lên màn hình (Toast, Odoo, Square). Màn hình đầu tiên của chế độ phục vụ bàn là **bảng phòng/bàn**, không phải danh mục hàng (Odoo, SpotOn, KiotViet, Square). Ô bàn phải trả lời được ngay ba câu hỏi: bàn đã ngồi bao lâu, đang bao nhiêu tiền, và có cần xử lý gấp không (Toast, Lightspeed, KiotViet, Square). Nút chính nằm dưới đáy phiếu theo thứ tự "Gửi bếp" rồi "Thanh toán" (Toast, Lightspeed). Các thao tác hiếm như tách đơn, chuyển bàn, đếm khách được đưa vào menu tràn (overflow) (Toast, Odoo).

Màn hình hiện tại của chúng ta có ba cột (danh mục, giỏ, thanh toán) và để sơ đồ bàn ở dạng nút bật/tắt. Đây chính là bố cục bán lẻ. Nên tách thành một luồng F&B riêng: **Bảng bàn → Màn gọi món hai vùng → Màn thanh toán**.

Độ tin cậy: các sản phẩm quốc tế (Toast, Lightspeed K, Square, Odoo, Lavu, SpotOn) có trang trợ giúp chính thức mô tả bằng văn bản nên đáng tin. Các sản phẩm Việt Nam có rất ít tài liệu dạng văn bản. KiotViet là ngoại lệ có hai trang mô tả cụ thể. CukCuk, Sapo, iPOS và POS365 chủ yếu chỉ có trang marketing hoặc hướng dẫn dựa trên ảnh, nên nhiều điểm về họ được đánh dấu **[chưa kiểm chứng]**.

---

## 1. Từng sản phẩm

### Toast POS (tham chiếu mạnh nhất cho màn gọi món)

- **Màn hình đầu:** Chế độ phục vụ bàn mở vào màn "Table Service", có sơ đồ bàn và một khung "Table Details" (danh sách bàn) bật sẵn. Các khu vực phục vụ nằm trên một thanh ở đầu màn hình. Khi phóng to, mỗi ô bàn hiện nhiều dữ liệu với chữ nhỏ. Khi thu nhỏ, ô bàn chỉ hiện dữ liệu quan trọng nhất với chữ to. Nguồn: https://support.toasttab.com/en/article/New-POS-Managing-Tables
- **Ô bàn:** Hiện số khách, đồng hồ thời gian mở check, số bàn kèm khu vực (ví dụ A8), tổng tiền của mọi check trên bàn, và huy hiệu viết tắt tên nhân viên phục vụ. Viền ô bàn có màu của nhân viên đó. Nguồn: như trên.
- **Màn gọi món:** Chi tiết check nằm **bên trái**. Phía trên check có số bàn, tên tab, nhân viên, phí dịch vụ, nút tách, giảm giá và số khách. Bên dưới check là các nút **Hold, Stay, Send**, và dưới cùng là **Print** và **Pay**. Thực đơn chia theo menu, nhóm rồi món, có ô tìm kiếm phía trên lưới món. Chọn một dòng trên check sẽ mở các thao tác đổi số lượng, lặp lại, xóa, đổi course hoặc gửi yêu cầu đặc biệt. Modifier hiện **ở đáy màn hình** và có thể là bắt buộc. Nguồn: https://support.toasttab.com/en/article/New-POS-Experience-Ordering-Screens
- **Send, Stay và Hold:** Send gửi các món đang được tô sáng và quay lại màn bàn. Stay cũng gửi nhưng ở lại màn gọi món. Hold giữ món lại, chưa gửi. Ba nút này chỉ hiện khi check có ít nhất một món. Nguồn: như trên.
- **Open view:** Menu nằm bên trái, nhóm món nằm trên một thanh dọc cuộn được ở bên phải. Lưới mặc định là 8 hàng × 5 cột và chỉnh được, nhưng nhiều ô hơn đồng nghĩa nút nhỏ hơn. Mọi nhóm modifier hiện cùng lúc. Nhóm đã đủ điều kiện có dấu tích xanh, nhóm chưa đủ có dấu X đỏ. Nguồn: https://support.toasttab.com/en/article/Get-Started-Open-View?lang=en_US
- **Ghế:** Check hiện tiêu đề ghế có đánh số theo số khách. Chọn tiêu đề ghế xong thì món thêm sau đó tự gán vào ghế đó. Nguồn: https://support.toasttab.com/en/article/Order-by-Seat
- **Thanh toán:** Là một màn riêng. Check nằm khung trái, các phương thức thanh toán nằm bên phải, và thẻ đã giữ trước (pre-auth) được ưu tiên trên cùng. Dưới đáy có Split evenly, Rewards và Service charge. Sau đó là màn tip, rồi màn biên lai với lựa chọn "No receipt" được ưu tiên. Tách theo ghế hoặc chia đều nằm ở góc trên phải màn tách. Nguồn: https://support.toasttab.com/en/article/New-POS-Managing-Payments và https://support.toasttab.com/en/article/Splitting-Checks-by-Item-1492811097734
- **Giao diện:** Có chế độ sáng và tối, đặt riêng cho từng thiết bị (ví dụ máy ở quầy bar để tối). Nguồn: https://support.toasttab.com/en/article/Setting-Up-the-New-POS-Experience?lang=en_US (chỉ đọc qua kết quả tìm kiếm).
- **Phân biệt món đã gửi và chưa gửi:** Tài liệu chỉ nói Send gửi "các món được tô sáng", tức là món chưa gửi có kiểu hiển thị riêng. Màu cụ thể **[chưa kiểm chứng]**.

### Lightspeed Restaurant (K-Series)

- **Màn hình đầu:** Mặc định vào màn Register. Có thể đặt Floor plan làm màn đầu trong Back Office. Nguồn: https://k-series-support.lightspeedhq.com/hc/articles/360050328394 và https://k-series-support.lightspeedhq.com/hc/articles/360050328494
- **Register:** Gồm ba phần là tóm tắt đơn, bàn phím số và thực đơn. Bấm "Edit order" sẽ thu gọn bàn phím để thấy toàn bộ đơn. Nút Send nằm ở đáy Register và có dạng "Send - x items", tức là hiện số món chưa gửi. Nguồn: https://k-series-support.lightspeedhq.com/hc/articles/360050328394 và https://k-series-support.lightspeedhq.com/hc/articles/360051089273
- **Ô bàn:** Thẻ màu theo chủ sở hữu. Xanh lá là bàn của tôi, cam là bàn của người khác nhưng mở được, đỏ là bàn của người khác và không có quyền mở. Một nút ở góc dưới trái chuyển dữ liệu hiển thị trên bàn giữa bốn lựa chọn: số cover, tổng tiền, thời gian (có **dải đỏ** khi đơn mở đã lâu) và trạng thái course. Nguồn: https://k-series-support.lightspeedhq.com/hc/articles/360050328494
- **Course và ghế:** Món được nhóm theo course, mặc định vào Course 1. Có thể chuyển hiển thị sang nhóm theo ghế. Course chưa gọi có biểu tượng mũi tên trắng, course đã gọi (fire) có ngọn lửa cam, course trước đó được đánh dấu tích xanh. Sau khi gửi, món không chuyển sang course hoặc ghế khác được nữa. Nút Fire course nằm trong Orders → Actions, không nằm trên Register. Nguồn: https://k-series-support.lightspeedhq.com/hc/articles/360051089273

### Square for Restaurants

- **Màn hình đầu:** Bắt đầu từ sơ đồ bàn hoặc tab Checks. Nguồn: https://squareup.com/help/us/en/article/8633-set-up-and-manage-real-time-check-view-for-restaurants
- **Màn gọi món:** Giỏ hàng trực tiếp (live cart) nằm **bên phải**. Trên màn lớn, chi tiết món và modifier mở **cạnh** check chứ không che check. Trên máy nhỏ thì mở toàn màn hình. Nếu chưa chọn modifier bắt buộc thì không rời màn chi tiết được, phải hoàn tất phần được tô sáng rồi mới bấm Done hoặc Add to check. Nguồn: như trên.
- **Ô bàn:** Có thể hiện thời gian kể từ lúc mở check. Bàn chuyển vàng rồi đỏ theo các ngưỡng thời gian do chủ quán đặt. Nguồn: https://squareup.com/help/us/en/article/8146
- **Course:** Mỗi course có biểu tượng fire và hold. Course đầu mặc định gửi ngay, các course sau mặc định giữ lại. Muốn gọi course đang giữ thì bấm fire rồi bấm Send. Nguồn: https://squareup.com/help/us/en/article/6428 và https://squareup.com/help/article/8172-hold-and-fire-courses-with-square-kds-and-square-for-restaurants
- **Bài học từ bản thiết kế lại năm 2024:** Square thêm ảnh vào ô món để "nhập đơn nhanh hơn". Một số người dùng phản hồi rằng thực đơn khó đọc hơn và nút tùy chọn quá nhỏ. Nguồn: https://community.squareup.com/t5/Product-Updates/-Restaurant-POS-redesign-coming-March-5/bc-p/719440 (diễn đàn, mang tính giai thoại).

### Odoo Point of Sale (Restaurant)

- **Màn hình đầu:** Sơ đồ bàn là màn đầu tiên. Có ba nút chuyển nhanh: Plan (sơ đồ), Table (nhập số bàn rồi bấm Jump) và nút tạo đơn trực tiếp không gắn bàn. Nguồn: https://www.odoo.com/documentation/18.0/applications/sales/point_of_sale/restaurant.html
- **Trạng thái bàn:** Có các trạng thái trống, có đặt chỗ lúc 15:15, đặt chỗ đến muộn, có đơn đang chờ, đã gửi bếp, và bàn đã gộp. Muốn gộp thì giữ một bàn rồi kéo sang bàn kia, và các bàn tự tách lại sau khi thanh toán. Nguồn: https://www.odoo.com/documentation/master/applications/sales/point_of_sale/restaurant.html
- **Màn gọi món:** Có nút số bàn ở đầu màn hình để chuyển bàn, nút Order/Send để gửi bếp, menu Actions (Split, Transfer/Merge, Release table, hủy đơn) và nút Payment. Course mới tạo bằng nút Course. Course chưa gọi được gắn nhãn "Pending" cho tới khi bấm "Fire Course N". Nguồn: như trên.
- **Vị trí cụ thể:** Phiếu đơn nằm bên trái, lưới món bên phải, danh mục dạng hàng ngang phía trên **[chưa kiểm chứng; có module bên thứ ba để đổi vị trí]**. Nguồn gián tiếp: https://apps.odoo.com/apps/modules/18.0/pos_screen_pane_position và https://www.odoo.com/forum/help-1/how-to-change-the-pos-product-category-layout-215329

### TouchBistro, Lavu, SpotOn, Loyverse, Clover

- **TouchBistro:** Món nằm góc trên trái, món đã gọi nằm góc trên phải. Người dùng có thể đổi phía trong hồ sơ nhân viên. Lưới món có ba kiểu: danh sách, lưới ảnh và lưới chữ. Nguồn: https://cdn.touchbistro.com/help/articles/taking-orders (đọc qua kết quả tìm kiếm vì trang lỗi SSL khi tải).
- **Lavu:** Màu bàn gồm xám (trống), xanh dương (có đơn), xanh lá (đã in hóa đơn, sắp trống) và **cam (mới gửi bếp một phần, khi dùng Hold & Fire)**. Nút Send gửi bếp, nút Save lưu món không in phiếu bếp, nút Tables ở góc trên trái để quay lại sơ đồ. Nguồn: https://support.lavu.com/en/knowledge/pos-tables-layout-overview. Ghế và course đang chọn hiện bằng hai biểu tượng "Active Seat/Active Course" với nút +/−. Nguồn: https://support.lavu.com/en/knowledge/pos-active-seat-and-course
- **SpotOn Serve:** Đăng nhập xong vào thẳng màn sơ đồ bàn. Có thể chuyển giữa dạng danh sách và dạng thẻ, thu phóng bằng chạm hai lần hoặc chụm ngón. SpotOn Express cho chọn ba cỡ ô. Nguồn: https://spotonteam.atlassian.net/wiki/x/ygJ_iw và https://express-updates.spoton.com/announcements/feature-releases-june-11-2024 (đọc qua kết quả tìm kiếm).
- **Loyverse:** Danh mục là một danh sách thả xuống "All items". Trên điện thoại, lưới có 3 cột và nhấn mạnh ảnh và màu. Trên tablet, có thể tự xếp các trang món. Hai nút chính là Save (lưu open ticket) và Charge. Nguồn: https://help.loyverse.com/help/home-sale-screen-layouts, https://help.loyverse.com/help/how-arrange-sale-screen-loyverse và https://help.loyverse.com/help/open-tickets
- **Clover Dining, Revel, Oracle Simphony:** Không tìm được tài liệu chính thức mô tả bố cục nên không đưa vào bảng.

### KiotViet FnB (nguồn Việt Nam rõ nhất)

- **Màn thu ngân trên web và máy tính:** Cột trái là danh sách phòng bàn. Có lọc theo khu vực, tìm bàn không phân biệt dấu, bộ đếm "đang dùng/tổng", lọc Tất cả/Sử dụng/Còn trống, và hai ô "Mang về" và "Giao đi". Tab Thực đơn ở cùng vùng trái, ưu tiên món yêu thích, lọc tối đa hai cấp nhóm, chạm vào món để thêm vào đơn ở **vùng bên phải**. Tùy chọn "Mở thực đơn khi chọn bàn" mặc định **tắt**. Nguồn: https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/huong-dan-bar-cafe-nha-hang/ban-hang-bar-cafe-nha-hang/
- **Trạng thái bàn:** Gồm trống, đang dùng (có ít nhất một order), đang chọn, đã in tạm tính, có yêu cầu thanh toán, đã gộp, và sắp đến giờ đặt trước. Nguồn: như trên.
- **Ô bàn:** Hiện tên bàn, tổng tiền, thời gian hoạt động, tên khách, ghi chú, số món và số khách. Có biểu tượng cho bàn đặt trước, bàn **lỗi in chế biến**, hàng tính giờ (đang tính hoặc đã dừng) và bàn gộp. Bàn đã yêu cầu thanh toán có nền **xanh lá**, bàn đã in tạm tính có nền **vàng cam**. Nguồn: https://www.kiotviet.vn/phan-mem-kiotviet-danh-cho-nha-hang-cafe-quan-an-nang-cap-giao-dien-thu-ngan-moi/
- **Đơn hàng:** Hàng tính giờ được phân biệt với món thường và dừng hoặc tiếp tục được bằng một cú bấm. Tên bàn nằm ở góc trên trái đơn, bấm vào để chuyển hoặc gộp bàn. Nút "Tách ghép đơn" bị ẩn nếu nhân viên không có quyền. Nguồn: như trên và https://www.kiotviet.vn/cap-nhat-mhtn-21-01-2019/
- **Thanh toán (ứng dụng di động):** Số tiền theo từng hình thức và **mã QR chuyển khoản hiện ngay trên giao diện chính**. Nút In tạm tính có ngay trên màn thanh toán. Khách, khuyến mại và phụ thu được tách thành dòng riêng. Nguồn: như trên.
- **Nút "Thông báo" (gửi bếp) và "Thanh toán" ở đáy đơn bên phải:** **[chưa kiểm chứng]**, dựa trên hiểu biết chung về sản phẩm. Bài blog của KiotViet chỉ xác nhận có bước "chọn Xác nhận và gửi thông báo xuống bếp". Nguồn: https://www.kiotviet.vn/menu-dien-tu-la-gi-loi-ich-khi-su-dung-menu-dien-tu-trong-nha-hang-quan-cafe

### MISA CukCuk, Sapo FnB, iPOS FABi, POS365

- **CukCuk:** Khóa học thu ngân chính thức có các bài "Layout – Order Interface" và "Select Table – Take Order", nhưng nội dung nằm trong video. Nguồn: https://academy.misa.vn/cukcuk---tutorial-for-cashier. Với dịch vụ tính giờ, nhân viên bấm "Set time" để nhập giờ vào. Thời gian được làm tròn lên theo block (ví dụ block 15 phút thì 2 giờ 6 phút thành 2 giờ 15 phút). Thu ngân bấm "Adjust time" để sửa giờ, và có thể bật yêu cầu quản lý xác nhận khi sửa giờ. Nguồn: http://helpv2.cukcuk.com/en/kb/thiet-lap-dich-vu-tinh-tien-theo-thoi-gian-nhu-the-nao/. Bố cục sơ đồ bàn và màu trạng thái **[chưa kiểm chứng]**.
- **Sapo FnB:** Sapo tách vai trò thành ba ứng dụng: Thu ngân, Phục vụ và Bar/Bếp. Sơ đồ bàn chia theo phòng và tầng, có trạng thái trống, đang phục vụ và đã đặt. Giờ chơi bida được quy đổi theo block và vẫn đếm khi mất mạng. Nguồn: https://play.google.com/store/apps/details?id=com.sapo.fnb, https://www.sapo.vn/phan-mem-quan-ly-quan-bida.html và https://www.sapo.vn/blog/phan-mem-thu-ngan-nha-hang. Bố cục màn gọi món **[chưa kiểm chứng]**.
- **iPOS FABi:** Trang Play chỉ mô tả là "giao diện thân thiện" và có màn hình phụ hiển thị hóa đơn kèm QR cho khách. Một tài liệu nội bộ của khách hàng mô tả luồng "chọn khu vực → chọn bàn → tích món → xác nhận/in". Nguồn: https://play.google.com/store/apps/details?id=com.ipos.fabi và https://docs.google.com/document/d/1TrTwcQChCfxGVy_xPjQECJVhiSxFZtsJ/export?format=pdf. Bố cục **[chưa kiểm chứng]**.
- **POS365 (karaoke/bida):** Chỉ có bài review của bên thứ ba nói phần mềm hiện tình trạng phòng, thời gian đã thuê và thời gian còn lại. Nguồn: https://phongvu.vn/cong-nghe/top-phan-mem-tinh-tien-karaoke-tot-gia-re/ và https://tinhte.vn/thread/3477373. **[chưa kiểm chứng]**.

### Phần mềm tính giờ (bida/karaoke)

- **Union POS:** Có hai loại đồng hồ. Open timer đếm lên cho tới khi nhân viên dừng, phù hợp bàn bida và karaoke vãng lai. Set timer đếm ngược, khóa giá trước và chuyển **cam rồi đỏ** khi sắp hết giờ. Đồng hồ hiện trực tiếp trên sơ đồ bàn và trên ô check. Đóng check khi đồng hồ còn chạy sẽ hỏi dừng đồng hồ và đóng check trong một bước. Nguồn: https://getunion.com/?p=31188
- **Module Odoo cho khu chơi game:** Khi hết gói giờ cố định, nhãn đơn nhấp nháy và hiện popup "Timer Over" để chọn tính tiền hoặc gia hạn. Nguồn: https://apps.odoo.com/apps/modules/19.0/pos_gaming_zone_management
- **CueFlow:** Có nút tạm dừng và tiếp tục đồng hồ trên từng bàn. Nguồn: https://www.capterra.com/p/10047006/Snooker-Club-Management-Software/ (trang niêm yết, độ tin cậy thấp).

---

## 2. Bảng so sánh

| Sản phẩm | Màn đầu | Phiếu nằm | Danh mục | Nút chính | Trạng thái bàn | Modifier | Thanh toán | Độ tin cậy |
|---|---|---|---|---|---|---|---|---|
| Toast | Sơ đồ bàn + danh sách | Trái | Menu trái, nhóm trên thanh dọc phải (Open view) | Hold, Stay, Send rồi Print, Pay dưới phiếu | Giờ, khách, tiền, nhân viên; mật độ đổi theo zoom | Đáy màn hoặc cột chung; tích xanh/X đỏ | Màn riêng: phiếu trái, phương thức phải | Cao |
| Lightspeed K | Register (đặt được Floor) | Trên/trái kèm bàn phím | Lưới thực đơn | "Send - x items" ở đáy | Thẻ màu theo chủ sở hữu; dải đỏ khi lâu | Không rõ | Không rõ | Cao |
| Square | Sơ đồ hoặc tab Checks | Phải | Lưới yêu thích và thư viện | Add to check, Send | Vàng/đỏ theo ngưỡng giờ | Mở cạnh phiếu; chặn rời màn nếu thiếu | Không rõ | Cao |
| Odoo | Sơ đồ bàn | Trái [cvk] | Hàng ngang trên [cvk] | Order/Send, Actions, Payment | Đặt chỗ, muộn, chờ, gộp | Popup [cvk] | Màn riêng [cvk] | Trung bình |
| TouchBistro | Sơ đồ [cvk] | Phải (đổi được) | Thanh menu, lưới ảnh/chữ/danh sách | Send | Màu theo khu vực | Không rõ | Không rõ | Trung bình |
| Lavu | Sơ đồ | Không rõ | Không rõ | Send, Save | Xám/xanh/lá/cam (gửi một phần) | Không rõ | Không rõ | Cao |
| KiotViet FnB | Danh sách phòng bàn (trái) | Phải | Tab Thực đơn, 2 cấp nhóm | Thông báo, Thanh toán [cvk] | Lá = yêu cầu TT; vàng cam = đã tạm tính; biểu tượng lỗi in và tính giờ | Không rõ | QR và số tiền ngay trên màn | Trung bình đến cao |
| CukCuk, Sapo, FABi, POS365 | Sơ đồ bàn | [cvk] | [cvk] | [cvk] | Trống, đang dùng, đặt trước | [cvk] | [cvk] | Thấp |
| Union (tính giờ) | Sơ đồ có đồng hồ | Không rõ | Không rõ | Start Timer | Đồng hồ đếm ngược cam rồi đỏ | Không áp dụng | Đóng check kèm dừng giờ | Trung bình |

[cvk] = chưa kiểm chứng.

## 3. Trả lời tám câu hỏi

1. **Màn đầu:** Năm trên sáu sản phẩm có tài liệu mở vào sơ đồ hoặc danh sách bàn. Chỉ Lightspeed mặc định vào Register, và họ vẫn cho đặt sơ đồ làm màn đầu.
2. **Bố cục gọi món:** Phiếu nằm bên phải ở Square, TouchBistro và KiotViet, nằm bên trái ở Toast và Odoo. Không có chuẩn chung, nhưng người dùng Việt Nam quen KiotViet với phiếu bên phải. Nút gửi bếp và thanh toán luôn nằm **dưới đáy phiếu**. Tách đơn và chuyển bàn nằm trong menu tràn hoặc Actions.
3. **Trạng thái bàn:** Có ba mẫu màu. Mẫu thứ nhất tô theo vòng đời đơn (Lavu, KiotViet). Mẫu thứ hai tô theo thời gian ngồi (Square vàng/đỏ, Lightspeed dải đỏ). Mẫu thứ ba tô theo chủ sở hữu (Lightspeed, Toast). Thông tin thường có trên ô bàn là thời gian, tiền, số khách và các biểu tượng ngoại lệ (lỗi in, đặt trước, tính giờ).
4. **Modifier:** Trên màn rộng, modifier mở **cạnh phiếu** để vẫn thấy tổng tiền (Square), hoặc hiện ở vùng đáy (Toast). Modifier bắt buộc chặn việc thêm món và đánh dấu nhóm còn thiếu bằng màu (Toast, Square).
5. **Thanh toán:** Là màn riêng, phiếu ở bên trái và phương thức ở bên phải, phương thức ưu tiên đặt to nhất (Toast). Ở Việt Nam, QR chuyển khoản hiện ngay không cần bấm mở (KiotViet).
6. **Món đã gửi và chưa gửi:** Nút gửi mang số lượng món chưa gửi (Lightspeed). Món chưa gửi được tô sáng (Toast). Course có trạng thái chờ, đã gọi và xong (Lightspeed, Odoo, Square). Sau khi gửi, món bị khóa, không chuyển course hoặc ghế được nữa (Lightspeed).
7. **Bảng tính giờ:** Phân biệt đồng hồ đếm lên và đếm ngược, đồng hồ đếm ngược chuyển cam rồi đỏ (Union). Hết giờ thì nhấp nháy kèm popup (Odoo). Dừng và tiếp tục chỉ cần một cú bấm, trạng thái đang tính hoặc đã dừng phân biệt bằng màu (KiotViet). Giờ được làm tròn theo block và sửa giờ cần quyền (CukCuk, Sapo).
8. **Công thái học chạm:** Vùng chạm tối thiểu là 44pt theo Apple, 48dp theo Material, và 44×44 CSS px theo WCAG 2.5.5 mức AAA (https://adrianroselli.com/2019/06/target-size-and-2-5-5.html, https://dequeuniversity.com/resources/wcag2.1/2.5.5-target-size). Mật độ lưới là đánh đổi rõ ràng giữa số ô và cỡ nút (Toast). Nên cho chọn cỡ ô (SpotOn có ba cỡ). Ảnh trên ô món có thể làm giảm khả năng đọc (phản hồi về Square). Giao diện tối nên đặt theo từng thiết bị (Toast).

---

## 4. Mẫu layout nên áp dụng

Kích thước giả định là màn ngang rộng 1366–1920px. Các số đo là điểm khởi đầu và cần thử trên máy thật.

1. **Màn đầu F&B là Bảng bàn toàn màn hình, không phải danh mục.** Đầu màn có tab khu vực hoặc tầng kèm số "đang dùng/tổng". Cạnh đó là các chip lọc Tất cả, Đang dùng, Trống, Cần xử lý. Các ô cố định "Mang về" và "Giao đi" đặt đầu lưới. Chạm vào bàn thì mở màn gọi món. Bỏ nút bật/tắt "floor" và thanh tab workspace ở chế độ F&B. (Theo Odoo, SpotOn, KiotViet và Toast.)

2. **Ô bàn có bốn dòng thông tin cố định:** tên bàn, thời gian đã ngồi (to nhất), tổng tiền và số khách. Biểu tượng ngoại lệ (lỗi in bếp, đặt trước, tính giờ đang chạy, bàn gộp) nằm ở góc ô. Màu nền theo vòng đời đơn chỉ dùng tối đa năm trạng thái: trống (trung tính), đang phục vụ (xanh dương), đã tạm tính (vàng cam), yêu cầu thanh toán (xanh lá) và gửi bếp một phần (viền cam). Thời gian quá ngưỡng thì hiện **dải đỏ** dưới thời gian, không đổi màu nền, để màu nền và cảnh báo thời gian không lẫn vào nhau. Ngưỡng do cửa hàng cấu hình. (Theo KiotViet, Lavu, Square và Lightspeed.)

3. **Màn gọi món chỉ có hai vùng.** Bố cục từ trái sang phải là rail danh mục dọc khoảng 120px, lưới món co giãn theo phần còn lại, rồi phiếu cố định **bên phải** rộng 380–440px. Bỏ cột thanh toán riêng. Chọn bên phải vì đây là thói quen người dùng KiotViet và Square, và vì nút "Thanh toán" ở góc dưới phải hợp với tay phải. Nếu cần, có thể cho đổi phía giống TouchBistro.

4. **Thanh trên của màn gọi món** gồm nút "← Bàn" để về bảng bàn, tên bàn (chạm vào để chuyển hoặc gộp bàn), số khách (chạm để sửa), thời gian đã ngồi, nhân viên phục vụ, loại đơn và ô tìm món. Các thao tác hiếm đưa vào menu "⋯" ở góc phải phiếu: tách đơn, gộp đơn, giảm giá, phụ phí, khách hàng, hủy đơn. (Theo Toast, Odoo và KiotViet.)

5. **Ô món ưu tiên chữ:** tên tối đa hai dòng, cỡ 15–16px đậm, giá ở dòng dưới. Ảnh tắt theo mặc định. Màu danh mục hiện bằng một dải mỏng ở mép ô. Kích thước tối thiểu 120×80px, tức là vượt mức 44px. Có ba mức mật độ (thoáng, vừa, dày), lưu theo từng thiết bị. Món đang có trong phiếu thì hiện huy hiệu số lượng trên ô. Món hết hàng thì làm mờ ô, không ẩn. (Theo Toast, SpotOn và phản hồi về Square.)

6. **Đáy phiếu có hai nút chính to, đặt cố định.** Nút trái là **"Gửi bếp (n)"**, với n là số món chưa gửi, và bị vô hiệu khi n bằng 0. Nút phải là **"Thanh toán · tổng tiền"** và là nút chính. Phía trên hai nút có một hàng nút phụ nhỏ hơn: "Tạm tính", "Giữ món" (hold), "Gửi & ở lại". Mặc định, gửi bếp xong thì quay về bảng bàn. "Gửi & ở lại" giữ người dùng ở màn gọi món, giống cặp Send và Stay của Toast. (Theo Toast và Lightspeed.)

7. **Phiếu nhóm món theo lượt gửi và phân biệt rõ món đã gửi với món chưa gửi.** Món chưa gửi nằm trên cùng, nền tô nhạt, có nhãn "Mới" và sửa hoặc xóa tự do được. Món đã gửi nằm dưới tiêu đề "Lượt 2 · 19:42", chữ màu thường và có biểu tượng khóa. Sửa món đã gửi phải nhập lý do hủy. Khi bật course hoặc ghế, tiêu đề nhóm trở thành course hoặc ghế. Mỗi course có biểu tượng chờ (mũi tên), đã gọi (lửa cam) hoặc xong (tích xanh), kèm nút "Gọi món" ngay trên tiêu đề course. Chạm vào tiêu đề ghế để chọn ghế đang nhập. (Theo Lightspeed, Toast, Square và Odoo.)

8. **Modifier mở thành tấm trượt thay chỗ lưới món, còn phiếu vẫn hiện bên phải.** Không dùng popup che phiếu. Nhóm bắt buộc nằm trên cùng, có dấu X đỏ cho tới khi chọn đủ. Nút "Thêm vào đơn" bị khóa khi còn thiếu nhóm bắt buộc. Món không có modifier thì chạm một lần là thêm thẳng vào phiếu. (Theo Square và Toast.)

9. **Thanh toán là một màn đè lên màn gọi món, không phải một cột luôn hiện.** Bên trái là phiếu rút gọn kèm khuyến mại và phụ thu tách dòng. Bên phải là các nút phương thức, trong đó QR chuyển khoản hiện sẵn kèm số tiền, cùng bàn phím tiền mặt có các mệnh giá gợi ý. Dưới đáy có "Chia đều", "Tách theo món", "Tách theo ghế" và "In tạm tính". Thanh toán xong thì về bảng bàn. (Theo Toast và KiotViet.)

10. **Tài nguyên tính giờ (karaoke, bida) dùng cùng Bảng bàn nhưng ô có đồng hồ lớn.** Ô hiện đồng hồ hh:mm đếm lên, hoặc đếm ngược với gói giờ, và đồng hồ đếm ngược chuyển **cam khi còn 10 phút, đỏ khi hết giờ** kèm nhấp nháy. Ô đang tạm dừng có màu xám và biểu tượng tạm dừng. Tiền giờ tạm tính nằm ngay dưới đồng hồ. Trong phiếu, dòng tính giờ được ghim lên đầu, có nút dừng/tiếp tục một chạm và nút sửa giờ cần quyền. Bấm "Thanh toán" khi đồng hồ còn chạy sẽ hỏi "Dừng giờ và thanh toán?" trong một bước. Giao diện tối là tùy chọn theo từng máy, dành cho quầy bar hoặc karaoke thiếu sáng. (Theo Union, Odoo, KiotViet, CukCuk và Toast.)

## 5. Rủi ro khi áp dụng

- Giữ một màn chung cho cả bán lẻ và F&B sẽ tiếp tục đẩy F&B về kiểu bán lẻ. Cần một route hoặc một layout F&B riêng, dùng lại logic chung trong `packages/pos-shared`. Nên tái sử dụng dữ liệu và hành vi, không tái sử dụng bố cục.
- Rail danh mục dọc sẽ quá dài nếu có hơn 20 danh mục. Lúc đó cần cho cuộn rail hoặc gộp hai cấp nhóm như KiotViet.
- Trên màn 1366px, phiếu rộng 420px cộng rail 120px chỉ còn khoảng 820px cho lưới, tức 5–6 cột ô 120px. Nếu thiếu chỗ thì nên giảm số cột thay vì thu nhỏ ô.

## 6. Giới hạn của nghiên cứu

- Không xem được ảnh chụp màn hình hay video. Mọi kết luận dựa trên văn bản trợ giúp, nên màu sắc và vị trí chính xác của các sản phẩm Việt Nam (trừ KiotViet) chưa được xác minh.
- Trang trợ giúp của TouchBistro lỗi SSL và trang SpotOn trả về nội dung rỗng, nên chỉ dựa vào đoạn trích trong kết quả tìm kiếm.
- Không tìm được tài liệu bố cục của Clover Dining, Revel và Oracle Simphony.
- Không có nghiên cứu đo lường nào (tốc độ nhập đơn, tỷ lệ chạm nhầm) cho riêng POS. Các số đo ô món ở mục 4 là suy luận từ hướng dẫn nền tảng và cần thử trên máy thật.

## Câu hỏi còn mở

1. Phiếu đặt bên phải dựa trên thói quen KiotViet. Có cần phỏng vấn nhanh 2–3 thu ngân thực tế để xác nhận không?
2. Có cần chế độ "quầy nhanh" (cafe mang đi, không bàn) mở thẳng màn gọi món như Toast Quick Order không, hay luôn đi qua bảng bàn?
3. Ngưỡng cảnh báo thời gian ngồi và thời điểm chuyển cam cho đồng hồ đếm ngược nên đặt mặc định bao nhiêu, và cấu hình theo chi nhánh hay theo loại bàn?
4. Có muốn ước lượng nhanh mất bao lâu để chụp lại màn KiotViet, Sapo và CukCuk bằng tài khoản dùng thử nhằm xác minh các điểm chưa kiểm chứng không?
