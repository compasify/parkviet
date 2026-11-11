# parkviet

## Giới thiệu ParkViet v2

**ParkViet v2 được xây dựng trên nền tảng [Spree Commerce](https://spreecommerce.org)** — một nền tảng mã nguồn mở dành cho thương mại điện tử. Thay vì xây dựng lại mọi thứ từ đầu, ParkViet sử dụng nền tảng sẵn có của Spree và sẽ thường xuyên cập nhật, bám sát cách tổ chức và phát triển hệ thống của Spree để tiếp nhận các cải tiến, tính năng mới và bản vá bảo mật.

Trọng tâm của ParkViet là **phát triển các ứng dụng và tiện ích phù hợp với thị trường Việt Nam, cách kinh doanh và nhu cầu sử dụng của người Việt**, chẳng hạn như:

- **Ứng dụng bán hàng tại cửa hàng (POS):** hỗ trợ nhân viên tạo đơn và phục vụ khách ngay tại quầy. Xem [chức năng POS](apps/pos/README.md#chức-năng).
- **Các phương thức thanh toán phổ biến tại Việt Nam:** hướng tới tích hợp chuyển khoản ngân hàng, mã QR, ví điện tử và các dịch vụ thanh toán trong nước. Chuyển khoản VietQR đã có qua gem [`spree_vietqr`](https://github.com/compasify/spree_vietqr).
- **Quản lý bán hàng đa kênh tại một nơi:** tập trung đơn hàng, sản phẩm và tồn kho từ website, cửa hàng và các sàn thương mại điện tử, giúp người bán không phải quản lý từng kênh riêng lẻ.
- **Đồng bộ hàng hóa lên nhiều sàn:** hướng tới kết nối Shopee, Lazada, TikTok Shop và website để đăng bán sản phẩm, cập nhật giá và số lượng tồn kho, hạn chế bán vượt số hàng thực có.
- **Tích hợp quản lý quảng cáo:** kết nối các kênh như Facebook, Google và TikTok để theo dõi chi phí, đơn hàng và doanh thu liên quan đến quảng cáo, giúp người bán đánh giá hiệu quả trên cùng một hệ thống.
- **Xử lý đơn hàng in theo yêu cầu (POD):** kết nối đơn vị sản xuất và giao hàng để chuyển mẫu thiết kế, yêu cầu in, theo dõi tiến độ sản xuất, đóng gói và vận chuyển đến khách. Người bán có thể kinh doanh áo, cốc hoặc các sản phẩm cá nhân hóa mà không cần tự giữ hàng sẵn.
- **Kết nối vận chuyển và theo dõi giao hàng:** tạo đơn giao hàng, in vận đơn, theo dõi trạng thái và đối soát tiền thu hộ (COD) với các đơn vị vận chuyển tại Việt Nam.
- **Quản lý nhiều kho và chi nhánh:** theo dõi hàng hóa ở từng địa điểm, điều chuyển hàng giữa các kho và hỗ trợ chọn nơi xuất hàng phù hợp cho mỗi đơn.
- **Chăm sóc khách hàng và khách hàng thân thiết:** lưu lịch sử mua hàng, quản lý điểm thưởng, ưu đãi và hỗ trợ gửi thông báo qua các kênh quen thuộc như Zalo, email hoặc tin nhắn.
- **Hỗ trợ đổi trả và hoàn tiền:** tiếp nhận yêu cầu, theo dõi hàng trả về, cập nhật tồn kho và quản lý việc hoàn tiền để cửa hàng xử lý nhất quán giữa các kênh bán.
- **Kết nối hóa đơn điện tử và phần mềm kế toán:** giảm việc nhập liệu lặp lại, hỗ trợ chuyển thông tin bán hàng sang các công cụ doanh nghiệp đang sử dụng.
- **Bán sỉ và bán cho đại lý:** hỗ trợ bảng giá theo nhóm khách hàng, đơn hàng số lượng lớn và theo dõi công nợ phù hợp với cách kinh doanh của doanh nghiệp.
- **Thống kê, phân tích và báo cáo kinh doanh:** tập trung số liệu từ các kênh bán hàng, kho hàng và quảng cáo, trình bày bằng các báo cáo và biểu đồ dễ hiểu. Nhờ đó, cá nhân và doanh nghiệp có thể nhìn rõ tình hình kinh doanh, theo dõi xu hướng và đưa ra phương án phù hợp dựa trên số liệu thay vì chỉ dựa vào cảm tính. Ví dụ, biểu đồ tăng trưởng đơn hàng và tốc độ bán của từng sản phẩm giúp cân nhắc thời điểm nhập thêm hàng; số liệu về chi phí quảng cáo, đơn hàng và doanh thu giúp quyết định có nên chạy thêm quảng cáo, điều chỉnh ngân sách hay tạm dừng những chiến dịch chưa hiệu quả.

Ví dụ, một cửa hàng có thể quản lý việc bán tại quầy, trên website và trên Shopee trong cùng một hệ thống. Khi có đơn mới, số hàng còn lại được cập nhật giữa các kênh; nhân viên tiếp tục xử lý đóng gói, giao hàng và theo dõi tiền thu về mà không phải nhập lại đơn ở nhiều nơi.

Với một cửa hàng POD, đơn mua áo in thiết kế riêng có thể được chuyển đến đối tác sản xuất, sau đó cập nhật tiến độ in và mã vận đơn về hệ thống để người bán theo dõi từ lúc đặt hàng đến khi khách nhận hàng.

ParkViet sẽ tận dụng những khả năng mở rộng mà Spree hỗ trợ để bổ sung ứng dụng, kết nối dịch vụ và phát triển thêm tính năng khi nhu cầu kinh doanh thay đổi. Hiểu đơn giản: **Spree cung cấp nền tảng thương mại, còn ParkViet tập trung làm cho nền tảng đó phù hợp và dễ sử dụng hơn tại Việt Nam.**

## Câu chuyện sử dụng: bán đồ ăn nhà làm trong chung cư

> Tình huống minh họa, không phải khách hàng thật.

Một gia đình nấu đồ ăn nhà làm bán cho hàng xóm trong khu chung cư. Khách nhắn đặt món qua Facebook và Zalo, người nhà mang đến tận cửa, và phần lớn khách trả sau bằng chuyển khoản.

**Trước đây, khó ở đâu?**

- Đơn nằm rải rác trong nhiều cuộc trò chuyện Facebook, Zalo; dễ sót hoặc nhầm món.
- Ai nợ bao nhiêu ghi trong một cuốn sổ tay, cộng trừ bằng tay.
- Bận nấu nên quên nhắc nợ, ngại nhắc vì không nhớ chính xác đơn nào chưa trả.
- Tiền chuyển khoản về phải dò từng tin báo ngân hàng để biết của ai, trả cho đơn nào.
- Không biết kênh nào bán được nhiều, nên không biết nên tập trung vào đâu.

**Một ngày với ParkViet**

1. **Nhận đơn:** khách nhắn trên Zalo. Người bán mở POS, chọn khách (tìm theo tên, số điện thoại hoặc địa chỉ), thêm món và gắn **nguồn đơn** là Zalo. Khách mới thì nhập luôn địa chỉ, ví dụ "Tòa B, phòng 1203", ngay trên màn hình bán.
2. **Đánh dấu giao hàng:** bật **đơn giao hàng**, gõ tên người nhà sẽ đi giao, thêm phí giao nếu có.
3. **Ghi nợ nhanh:** khách hẹn trả sau, người bán ghi toàn bộ hoặc phần còn lại vào nợ chỉ trong một bước. Khách lần đầu nợ thì tài khoản nợ được mở tự động, hạn mức vẫn được kiểm tra.
4. **In phiếu:** phiếu in tên khách, số điện thoại, địa chỉ, người giao, phí giao và **mã VietQR trả sau** cho đúng số tiền còn nợ. Có thể bấm **Gửi Zalo** để gửi ảnh mã QR cho khách.
5. **Đi giao:** người giao mở trang **Đơn cần giao**, bấm số điện thoại để gọi khi đến nơi, xem số tiền khách còn nợ, giao xong bấm **Đã giao**.
6. **Tiền về:** khách quét mã chuyển khoản. Webhook SePay nhận giao dịch có nội dung `TN<số đơn>` và tự ghi nhận khoản thu, không cần dò tin báo ngân hàng.
7. **Cuối tuần nhắc nợ:** mở **Khách đang nợ**, xem ai nợ bao lâu, lần nhắc gần nhất là khi nào. Bấm **Nhắc nợ qua Zalo** để có sẵn tin nhắn lịch sự liệt kê các đơn chưa trả, kèm một mã QR cho cả số nợ.
8. **Xem kênh nào bán tốt:** báo cáo doanh số **Theo nguồn đơn** cho biết số đơn, doanh số và số còn nợ của Facebook, Zalo và bán trực tiếp.

**Bật gì để dùng được như trên?** (mặc định đều tắt; bật cho cả cửa hàng ở **Cấu hình → Chi nhánh → Chức năng chi nhánh**, chi nhánh nào không dùng thì tắt riêng)

- [ ] `credit`: bán chịu.
- [ ] `quick_credit`: ghi nợ nhanh không cần người duyệt thứ hai.
- [ ] `vietqr`: chuyển khoản VietQR, để in mã trả sau.
- [ ] `delivery`: đơn giao hàng và trang Đơn cần giao.
- [ ] Cấp cho người tạo đơn (kể cả chủ cửa hàng nếu tự đứng bán) quyền **Thu tiền** và **Bán ghi nợ** (`pos.credit.sell`) ở **Cấu hình → Nhân viên & quyền**. Thiếu quyền này thì nút **Ghi nợ** không hiện.
- [ ] Kết nối webhook SePay với tài khoản nhận tiền ở **Settings → VietQR** để khoản thu được ghi tự động.

Đọc thêm: [Bán hàng qua Facebook, Zalo, ship cư dân, hàng treo cửa, thu tiền QR sau](https://parkviet.com/blog/ban-do-an-chung-cu-voi-parkviet).

## Tiến độ phát triển

Cập nhật 08/11/2026. Nhánh phát triển chính là `v2`.

**Nền tảng:** Spree **6.0.3** ([release notes](https://github.com/spree/spree/releases/tag/v6.0.3)). Dự án đã eject, nên API được build từ `server/` và có thể tùy biến trực tiếp.

| Hạng mục | Trạng thái | Chi tiết |
| --- | --- | --- |
| **POS bán tại quầy** (`apps/pos`) | Phase 1–11 đã xong. Sẵn sàng triển khai; UAT thiết bị và quy trình tại cửa hàng do người dùng tự thực hiện khi vận hành. | [Giới thiệu POS](apps/pos/README.md) · [Kế hoạch](plans/261101-1649-retail-pos-multi-store-multi-order/plan.md) |
| **Chuyển khoản VietQR** | Đã có: gem Spree 6, trang quản trị và thanh toán VietQR trên POS. | Gem [`compasify/spree_vietqr`](https://github.com/compasify/spree_vietqr) · [Kế hoạch](plans/261108-0934-vietqr-spree6-pos/plan.md) |
| **Tách từng gói hàng cùng mã khác giá/lô** | Đã có trên POS: mỗi gói là một dòng riêng, chỉ gộp khi thu ngân chọn gộp và cùng giá/lô; sửa, xóa, trả hàng, hoàn tiền theo từng gói. Còn chờ UAT với hàng mẫu tại cửa hàng. Đơn web/admin vẫn gộp theo mã như Spree gốc. | [Kế hoạch](plans/261103-pos-goi-hang-truy-xuat/plan.md) |
| Các mục còn lại ở trên (đa kênh, đồng bộ sàn, quảng cáo, POD, vận chuyển, hóa đơn điện tử…) | Chưa bắt đầu. | — |

### POS đã có những gì?

POS phục vụ nhiều chi nhánh, nhiều quầy, và cho mở nhiều đơn cùng lúc trên một quầy. Mỗi nhóm chức năng có mô tả chi tiết trong README của POS:

- [Bán hàng](apps/pos/README.md#bán-hàng): tìm hoặc quét mã vạch, hàng cân bằng tem EAN-13, đơn vị quy đổi, hàng theo serial/lô, khách hàng, giảm giá, nhiều đơn song song.
  - **Địa chỉ giao hàng của khách:** mỗi khách một địa chỉ dạng chữ tự do, tìm kiếm được, sửa ngay trên màn hình bán; in dưới tên khách trên biên nhận, phiếu tạm tính và phiếu thanh toán; mẫu in có biến `{customer.phone}`, `{customer.address}`.
  - **Đơn giao hàng** (công tắc `delivery`): đánh dấu đơn cần giao, nhập tên người giao và phí giao (nếu có, cộng vào tổng tiền và công nợ). Đơn đã xong vẫn ở trạng thái "Chờ giao" cho đến khi bấm "Đã giao" ở trang **Đơn cần giao** (bấm số điện thoại để gọi, có địa chỉ, số còn nợ/đã trả). Biên nhận in người giao và phí giao.
  - **Nguồn đơn:** mỗi đơn gắn nguồn Tại quầy / Facebook / Zalo / Khác.
- [Thanh toán](apps/pos/README.md#thanh-toán): tiền mặt, chuyển khoản xác nhận tay, VietQR tự đối soát qua webhook SePay/PayOS, chia nhiều phương thức, sổ tiền chưa phân bổ.
  - **VietQR trả sau:** đơn ghi nợ in kèm mã VietQR không hết hạn cho đúng số tiền còn nợ, nội dung chuyển khoản `TN<số đơn>`. Webhook SePay tự ghi nhận khoản thu (trả một phần thì giảm nợ, trả dư thì trừ vào nợ cũ hơn, mỗi giao dịch ngân hàng chỉ ghi một lần, có nhật ký). Tài khoản chỉ dùng PayOS vẫn in được mã nhưng phải ghi nhận thu nợ bằng tay. Nút **Gửi Zalo** mở bảng chia sẻ kèm ảnh QR, máy không hỗ trợ thì chép vào bộ nhớ tạm.
- [Bán chịu và thu nợ](apps/pos/README.md#bán-chịu-và-thu-nợ): hạn mức, duyệt ghi nợ, tuổi nợ, thu nợ cho nhiều đơn.
  - **Ghi nợ nhanh** (công tắc `quick_credit`, cần bật `credit`): thu ngân có quyền bán chịu ghi phần chưa trả vào nợ trong một bước, không cần người thứ hai duyệt. Lần đầu dùng, hệ thống tự mở tài khoản nợ cho khách (hạn mức mặc định 2.000.000 ₫, 30 ngày); vẫn chặn khi vượt hạn mức.
  - **Nhắc nợ:** danh sách **Khách đang nợ** hiện số điện thoại, địa chỉ, số ngày nợ/quá hạn và lần nhắc gần nhất. Nút **Nhắc nợ qua Zalo** soạn sẵn tin nhắn lịch sự liệt kê các đơn chưa trả, kèm một mã VietQR cho toàn bộ số nợ (webhook trừ vào đơn cũ nhất trước). Mỗi lần nhắc đều được ghi lại.
- [Trả hàng, hoàn tiền, đổi hàng](apps/pos/README.md#trả-hàng-hoàn-tiền-đổi-hàng).
- [Tồn kho truy xuất](apps/pos/README.md#tồn-kho-truy-xuất-serial--lô--hạn-dùng): serial, lô, hạn dùng (FEFO), nhập, chuyển, kiểm kê, thu hồi.
- [Ca và sổ quỹ](apps/pos/README.md#ca-và-sổ-quỹ): mở/đóng ca, đếm mù, thu/chi két có người xác nhận.
- [Báo cáo](apps/pos/README.md#báo-cáo): doanh số, thực thu, tiền mặt, công nợ, đóng ca, xuất CSV.
  - Báo cáo doanh số có thêm mục **Theo nguồn đơn** (số đơn, doanh số gộp, số còn nợ), lọc và cột nguồn đơn, cột nguồn trong CSV, chọn nhanh khoảng ngày.
- [Biên nhận và in](apps/pos/README.md#biên-nhận-và-in), [màn hình khách](apps/pos/README.md#màn-hình-khách), [máy quét](apps/pos/README.md#máy-quét).
- [Quản trị](apps/pos/README.md#quản-trị) và [phân quyền](apps/pos/README.md#quyền) theo chi nhánh.

Những gì POS chưa làm được (thẻ, driver máy in, thử với thiết bị thật…) nằm ở mục [Giới hạn hiện tại](apps/pos/README.md#giới-hạn-hiện-tại). Các tính năng rủi ro mặc định tắt; bật cho cả cửa hàng và tắt riêng được ở từng chi nhánh. Các công tắc mới (`quick_credit`, `delivery`) cũng vậy.

### Bán hàng F&B (cafe, quán ăn, căng tin)

Năm ngành ăn uống chọn được khi thiết lập cửa hàng: **Cafe, Trà sữa**, **Quán ăn** (trả tiền trước, hoặc có bàn phục vụ), **Căng tin & Trạm dừng nghỉ**, **Nhà hàng** và **Bar, Pub & Club** (bán theo bàn). Karaoke, bida vẫn là "Sắp hỗ trợ". Sơ đồ bàn, máy phục vụ, trả tiền sau và phí phục vụ xem [Bán tại bàn và trả tiền sau](docs/pos/fnb-ban-va-tra-sau.md). Mọi màn quản trị dưới đây nằm trong bảng quản trị POS (`apps/pos-dashboard`).

1. **Chọn ngành:** ở **Thiết lập cửa hàng**, chọn một trong ba ngành trên. Wizard thêm bước **Thiết lập quán**: đặt tên các khu bếp (Bếp, Quầy pha chế; căng tin chỉ có Bếp; tối đa 4 khu), chọn thuế suất cho đồ ăn, đồ uống và cho rượu, bia, chọn lúc gửi món xuống bếp (khi thanh toán xong, hoặc khi thu ngân bấm Gửi bếp). Chi nhánh đã có thì đổi ngành ở **Cấu hình → Chi nhánh → Mô hình kinh doanh**.
2. **Thực đơn và tùy chọn:** nhập ở trang **Thực đơn**: nhóm món, món (gắn với sản phẩm), nhóm tùy chọn (đường, đá, topping…), giá theo khung giờ. Thu ngân đánh dấu món hết ngay trên lưới thực đơn. Món mới lấy thuế suất đồ ăn, đồ uống đã chọn trong wizard; đổi riêng từng món ở ô **Thuế suất**. Không có thực đơn mẫu.
3. **Khu bếp và máy in:** sửa khu bếp ở tab **Bếp & bar** của chi nhánh, khai báo máy in hóa đơn, máy in bếp, máy in tem ở tab **In ấn**.
4. **Ghép màn bếp, trạm in, màn khách:** tạo thiết bị và mã ghép ở trang **Thiết bị**, rồi ghép app ParkViet Nhân viên ở mode màn bếp hoặc trạm in. Tab **Phần cứng** của chi nhánh (wizard mở thẳng tới đây sau khi tạo quán) đọc từ server xem từng máy in đã in thành công chưa, khu bếp nào chưa có màn hay máy in, trạm in còn liên lạc không, màn khách đã ghép chưa, server có ra được internet không và hóa đơn điện tử đã cấu hình chưa.
5. **Số gọi và tem ly:** quầy bán từ lưới thực đơn; mỗi đơn có số gọi theo ngày kinh doanh (bắt đầu lại từ 1 khi qua giờ cắt ngày), màn khách hiện "Đang làm" / "Mời nhận". Cafe in tem ly cho các món bật **In tem ly**.
6. **Công thức:** gắn nguyên liệu cho món trong trang **Thực đơn**; bán xong thì tồn nguyên liệu được trừ theo công thức.
7. **Hóa đơn điện tử:** cấu hình ở **Cài đặt → Hóa đơn điện tử**. Món đồ ăn, đồ uống và món rượu, bia lên hóa đơn với thuế suất riêng của từng món.

Lệnh và cấu hình kỹ thuật không chép lại ở đây: chạy app, sinh client và in qua LAN / Bluetooth / Sunmi xem [README của ParkViet Nhân viên](apps/pos-staff/README.md); cài server LAN, ghép app trên LAN, đường ra internet và xử lý khi mất mạng xem [Triển khai POS trên LAN hoặc VPS](docs/deploy/pos-lan-vps.md); nhà cung cấp hóa đơn điện tử xem [docs/einvoice-providers.md](docs/einvoice-providers.md).

### VietQR

Gem [`spree_vietqr`](https://github.com/compasify/spree_vietqr) (bản 1.0.0 cho Spree 6, nhánh `master`) được gắn vào dự án dưới dạng git submodule tại `server/vendor/gems/spree_vietqr`. Bản cho Spree 5 vẫn giữ ở tag `v0.1.0-spree5` và nhánh `spree-5-stable`.

- **Cấu hình** trong bảng quản trị: tạo phương thức thanh toán VietQR ở **Settings → Payment methods**, sau đó thêm tài khoản nhận tiền và xem thông báo ngân hàng ở **Settings → VietQR**.
- **Trên POS:** chọn VietQR thì quầy và màn hình khách đều hiện mã QR. Khi webhook SePay hoặc PayOS báo đã nhận tiền, thu ngân bấm **Kết thúc**. Nếu ngân hàng chưa báo, thu ngân có thể nhập mã giao dịch bằng tay. Chi nhánh phải bật tính năng **Chuyển khoản VietQR**.
- **Chưa bật PayOS cho POS:** PayOS lấy chữ số trong số đơn làm `orderCode`, nên cần kiểm tra với số đơn POS trước.

## Spree 6.0 đã cung cấp những gì?

ParkViet v2 không bắt đầu từ con số không. Spree 6.0 đã cung cấp các chức năng nền tảng để vận hành một hệ thống bán hàng, từ quản lý sản phẩm đến xử lý đơn hàng và chăm sóc sau bán:

| Nhóm tính năng | Có thể làm gì? |
| --- | --- |
| **Quản lý sản phẩm** | Tạo sản phẩm với tên, mô tả, hình ảnh và nhiều lựa chọn như kích thước, màu sắc; quản lý mã hàng và giá cho từng lựa chọn. |
| **Danh mục và bộ sưu tập** | Sắp xếp hàng hóa theo nhóm, tạo bộ sưu tập theo mùa hoặc chương trình bán hàng để khách dễ tìm sản phẩm. |
| **Tìm kiếm và lọc sản phẩm** | Tìm theo từ khóa, lọc theo giá, danh mục, lựa chọn sản phẩm và tình trạng còn hàng. |
| **Giá bán và bảng giá** | Quản lý giá theo loại tiền, thị trường, nhóm khách hàng hoặc số lượng mua; hỗ trợ giá ưu đãi và lịch áp dụng bảng giá. |
| **Giỏ hàng và đặt hàng** | Cho khách thêm sản phẩm vào giỏ, nhập địa chỉ, chọn cách nhận hàng và thanh toán để hoàn tất đơn mua. |
| **Quản lý đơn hàng** | Theo dõi thông tin đơn, trạng thái thanh toán và tình hình xử lý giao hàng; hỗ trợ tạo đơn thay khách và hủy đơn theo điều kiện. |
| **Khách hàng** | Quản lý tài khoản, thông tin liên hệ, địa chỉ và lịch sử mua hàng; phân nhóm khách hàng để áp dụng chính sách phù hợp. |
| **Tồn kho và nhiều kho hàng** | Theo dõi số lượng theo từng sản phẩm và địa điểm, giữ hàng trong quá trình thanh toán, điều chuyển hàng và hỗ trợ đặt hàng khi hết hàng nếu được cho phép. |
| **Khuyến mãi và mã giảm giá** | Thiết lập điều kiện ưu đãi, mã giảm giá và các chương trình như giảm giá sản phẩm hoặc miễn phí giao hàng. |
| **Thanh toán và hoàn tiền** | Quản lý phương thức thanh toán, theo dõi giao dịch, thu tiền và hoàn tiền; có cơ chế kết nối thêm các cổng thanh toán. |
| **Giao hàng và xử lý đơn** | Cấu hình khu vực, phương thức và phí giao hàng; chia đơn để giao từng phần, quản lý thông tin theo dõi giao hàng và hỗ trợ nhận hàng tại điểm bán. |
| **Đổi trả và khiếu nại** | Quản lý yêu cầu trả hàng, đổi sản phẩm hoặc xử lý hàng lỗi, thiếu hàng; hỗ trợ nhận lại hàng, nhập lại kho và hoàn tiền theo quy trình. |
| **Thuế và các khoản phí** | Thiết lập thuế theo khu vực, giá đã gồm hoặc chưa gồm thuế và các khoản phí liên quan đến đơn hàng. |
| **Nhiều ngôn ngữ và loại tiền** | Hỗ trợ dịch nội dung sản phẩm, quản lý giá bằng nhiều loại tiền và thiết lập chính sách theo thị trường. |
| **Quản lý kênh bán** | Chọn sản phẩm được bán trên từng kênh, lên lịch hiển thị và ghi nhận đơn hàng theo kênh. Đây là nền tảng để phát triển bán hàng đa kênh, chưa đồng nghĩa với việc đã kết nối các sàn tại Việt Nam. |
| **Trang quản trị và phân quyền** | Có trang quản trị cho nhân viên, với vai trò và quyền truy cập để giới hạn ai được xem hoặc thay đổi từng nhóm thông tin. |
| **Kết nối và mở rộng** | Có các cổng kết nối phần mềm (API) và cơ chế gửi thông báo khi dữ liệu thay đổi, giúp xây dựng ứng dụng riêng hoặc kết nối với dịch vụ bên ngoài. |

Ngoài các chức năng trên, Spree 6.0 còn có khả năng hỗ trợ **sản phẩm số** như tệp tải về, **bán sỉ cho doanh nghiệp** và **mô hình sàn có nhiều người bán**. Việc sử dụng từng mô hình cần được thiết lập phù hợp; một số giải pháp mở rộng hoặc dịch vụ liên quan có thể cần cài thêm, trả phí hoặc có giấy phép riêng.

Tham khảo thêm tại [tài liệu Spree](https://spreecommerce.org/docs), trong đó có hướng dẫn về [sản phẩm](https://spreecommerce.org/docs/developer/core-concepts/products), [tồn kho](https://spreecommerce.org/docs/developer/core-concepts/inventory) và [kênh bán hàng](https://spreecommerce.org/docs/developer/core-concepts/channels).

## Bắt đầu

### Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) đã cài và đang chạy
- Mã nguồn kèm submodule: gem [`spree_vietqr`](https://github.com/compasify/spree_vietqr) (thanh toán chuyển khoản VietQR) nằm ở `server/vendor/gems/spree_vietqr`. Clone bằng `git clone --recurse-submodules`, hoặc chạy `git submodule update --init` trong bản clone sẵn có. Thiếu thư mục này thì API không build được.

### Chạy API Spree

```bash
cd parkviet
pnpm spree dev
```

Lần chạy đầu tiên tự hoàn tất thiết lập — kéo image Spree mới nhất, seed cơ sở dữ liệu và cấu hình khóa API.

Đợi các service khỏe mạnh, sau đó mở:

- **Bảng quản trị:** http://localhost:5173 — tự động khởi động bởi `spree dev`
  - Lần chạy đầu tiên mở liên kết thiết lập để tạo tài khoản quản trị
- **POS (bán tại quầy):** http://localhost:5175 — tự khởi động cùng bảng quản trị khi chạy `spree dev` (tắt bằng `SPREE_POS_DEV=0`)
- **Quản trị POS:** http://localhost:5176 — tự khởi động cùng POS khi chạy `spree dev` (cùng tắt bằng `SPREE_POS_DEV=0`)
- **Bảng người bán (sàn):** http://localhost:5174 — chạy bằng `cd apps/seller-dashboard && pnpm run dev`
- **API cửa hàng:** http://localhost:3000/api/v3/store

### Chạy cửa hàng trực tuyến

Các phụ thuộc đã được cài trong bước thiết lập — chỉ cần khởi động:

```bash
cd apps/storefront
pnpm run dev
```

Mở http://localhost:3001

### Bảng quản trị

`apps/dashboard/` là bảng quản trị của bạn — một ứng dụng React có thể tùy biến (plugin, trang riêng, chỉnh bảng) với tải lại trực tiếp. `spree dev` tự khởi động cùng API; để chạy riêng:

```bash
cd apps/dashboard
pnpm run dev
```

Mở http://localhost:5173 và đăng nhập bằng email và mật khẩu quản trị đã chọn trong lần chạy đầu.

Khi triển khai, image sản xuất sẽ build bảng quản trị và phục vụ tại `/dashboard` trên cùng origin với API (`pnpm spree build --production`).

Để tìm hiểu cách thêm trang, chỉnh bảng hoặc xây plugin, xem [tài liệu bảng quản trị](https://spreecommerce.org/docs/developer/dashboard/overview).

### Chạy không dùng Docker (máy local)

Nếu bạn đã có sẵn PostgreSQL và Redis (ví dụ đã cấu hình trong `server/.env`), có thể chạy trực tiếp mà không cần Docker:

**Yêu cầu:**
- PostgreSQL và Redis đang chạy
- Ruby và Node.js/pnpm
- Đã cấu hình `server/.env` (DATABASE_*, SECRET_KEY_BASE, ...)

**1. Cài gem và migrate cơ sở dữ liệu:**
```bash
cd server
bundle install
bundle exec rails db:migrate
```

**2. Chạy API server:**
```bash
cd server
bundle exec rails server
```
Mở http://localhost:3000

**3. Chạy bảng quản trị:**
```bash
cd apps/dashboard
pnpm dev
```
Mở http://localhost:5173

**4. (Tùy chọn) Chạy tác vụ nền (Solid Queue):**
```bash
cd server
bundle exec rails solid_queue:start
```

> Lưu ý: Solid Queue không chạy trong Puma (để tránh crash fork trên macOS). Đã set `SOLID_QUEUE_IN_PUMA=false` trong `server/.env`.

## Tùy biến API Spree

Thư mục `server/` là API Spree — một ứng dụng Rails đầy đủ phục vụ Store và Admin API (cùng tác vụ nền và email giao dịch) mà cửa hàng trực tuyến và bảng quản trị giao tiếp. Mặc định, dự án chạy từ image Docker dựng sẵn. Để chuyển sang build từ bản sao local:

```bash
pnpm spree eject
```

Lệnh này rebuild image Docker từ `server/` và khởi động lại service. Sau đó bạn có thể:

- **Tùy biến API** bằng cách sửa các tệp trong `server/`
- **Thêm extension** với `spree add <extension>`
- **Thêm tài nguyên mới** với `spree generate model <name> <attributes>`

## Dòng lệnh Spree

Dự án này dùng [`@spree/cli`](https://spreecommerce.org/docs/developer/cli/quickstart) để quản lý API Spree.

### Service

| Lệnh | Mô tả |
|---------|-------------|
| `spree dev` | Chạy ứng dụng ở foreground — truyền log, Ctrl+C dừng. Lần chạy đầu tự hoàn tất thiết lập |
| `spree stop` | Dừng service API |
| `spree upgrade` | Nâng cấp Spree — server, cơ sở dữ liệu và các gói `@spree/*` |
| `spree eject` | Chuyển từ image dựng sẵn sang build từ `server/` |
| `spree build --production` | Build image sản xuất — bao gồm `apps/dashboard` nếu có |
| `spree logs` | Xem log web server |
| `spree logs worker` | Xem log tác vụ nền |
| `spree console` | Mở console backend tương tác |

### Dữ liệu

| Lệnh | Mô tả |
|---------|-------------|
| `spree migrate` | Cài migration Spree đang chờ, sau đó chạy cùng migration của bạn |
| `spree seed` | Seed cơ sở dữ liệu |
| `spree sample-data` | Tải sản phẩm mẫu, danh mục, hình ảnh |

### Người dùng & Khóa API

| Lệnh | Mô tả |
|---------|-------------|
| `spree user create` | Tạo người dùng quản trị |
| `spree api-key create` | Tạo khóa API publishable hoặc secret |
| `spree api-key list` | Liệt kê tất cả khóa API |
| `spree api-key revoke <id>` | Thu hồi khóa API (ID từ `api-key list`) |

### Trình sinh mã

| Lệnh | Mô tả |
|---------|-------------|
| `spree generate model Brand name:string slug:string:uniq` | Sinh model cơ sở dữ liệu mới |
| `spree generate api_resource Brand name:string slug:string:uniq` | Sinh tài nguyên API Spree mới |
| `spree generate subscriber OmsOrderSync order.placed` | Sinh subscriber sự kiện mới |
| `spree generate migration AddPositionToSpreeBrands position:integer` | Sinh migration mới |

### Admin API

Thiết lập dự án tạo khóa secret chỉ đọc vào `.spree/credentials.json` (đã gitignore), nên client Admin API hoạt động ngay. Nếu bỏ qua bước thiết lập, `spree api` sẽ tạo khóa khi dùng lần đầu:

```bash
pnpm spree api get products
pnpm spree api get "orders?q[status_eq]=complete"
pnpm spree api endpoints          # liệt kê endpoint + scope yêu cầu
pnpm spree api status             # hiển thị thông tin xác thực + khả năng kết nối server
```

Khóa mặc định chỉ đọc. Để ghi, tạo khóa secret có scope và truyền qua `SPREE_API_KEY`:

```bash
pnpm spree api-key create --scopes write_products
SPREE_API_KEY=sk_... pnpm spree api post products --data '{"name":"New product","prices":[{"currency":"USD","amount":"29.99"}]}'
```

| Lệnh | Mô tả |
|---------|-------------|
| `spree api get/post/patch/delete <path>` | Gọi Admin API trực tiếp |
| `spree api endpoints` | Liệt kê endpoint Admin API cùng scope yêu cầu |
| `spree auth login --profile <name>` | Lưu thông tin xác thực có tên cho cửa hàng từ xa |

> **Chạy `spree` trực tiếp.** Các lệnh trên dùng `pnpm` vì `@spree/cli` là phụ thuộc local của dự án. Bạn cũng có thể chạy các script package (ví dụ `pnpm run api -- get products`), hoặc cài CLI toàn cục để dùng lệnh `spree` trần:
>
> ```bash
> pnpm add -g @spree/cli
> spree api get products
> ```

## Tìm hiểu thêm

- [Tài liệu Spree](https://spreecommerce.org/docs)
- [Discord Spree](https://discord.spreecommerce.org)
- [Store API Reference](https://spreecommerce.org/docs/api-reference/store-api/introduction)
- [Admin API Reference](https://spreecommerce.org/docs/api-reference/admin-api/introduction)
- [CLI Reference](https://spreecommerce.org/docs/developer/cli/quickstart)
- [Spree GitHub](https://github.com/spree/spree)
