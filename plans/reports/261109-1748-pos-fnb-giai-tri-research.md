# Báo cáo: POS cho ngành Ăn uống – Giải trí (6 ngành) và các app cần xây

- **Ngày:** 09/11/2026 · **Trạng thái:** research, chưa code, chưa chốt quyết định.
- **Phạm vi:** 6 ngành F&B / giải trí đã có profile `coming_soon` trong `server/config/pos/business_profiles.yml`: **Quán ăn · Cafe, Trà sữa · Karaoke, Bida · Bar, Pub & Club · Căng tin & Trạm dừng nghỉ · Nhà hàng**.
- **Kế thừa:**
  - [Báo cáo ngành hàng thị trường](261108-1700-pos-nganh-hang-thi-truong-research.md): danh sách ngành của từng hãng.
  - [Kiến trúc POS đa ngành](261108-1800-pos-multi-industry-architecture.md): lõi + module + profile; §4.2, §5, §7, §10.2 đã phác F&B.

  Báo cáo này đi sâu ở **mức sản phẩm**, gồm app, màn hình, luồng nghiệp vụ và pháp lý, rồi đề xuất lộ trình. **Các app cho nhân viên phục vụ, bếp/bar và chạy bàn đều có trong lộ trình**, không phần nào bị bỏ.
- **Cách làm:**
  - Đọc trang hướng dẫn và help center của KiotViet, MISA CukCuk, iPOS, Sapo, POS365.
  - Đọc mô tả app trên Google Play / App Store của chính hãng.
  - Đọc trang giá của các hãng.
  - Đọc tài liệu Toast, Square, Lightspeed, TouchBistro, Loyverse, Odoo; mã nguồn Odoo 18 `pos_restaurant`; tài liệu Vyrox / Brunswick (bida), LINQ / Nayax / Cashnet (căng tin).
  - Đọc văn bản pháp luật qua thuvienphapluat, LuatVietnam, EY, VOV.
- **Ký hiệu nguồn:**
  - **[V]** đọc trực tiếp trên trang hoặc tài liệu của hãng;
  - **[3P]** chỉ có nguồn bên thứ ba;
  - **[SL]** là suy luận hoặc đề xuất của nhóm.

  Chưa dùng thử bản demo của hãng nào.

---

## 1. Tóm tắt

1. **Thị trường Việt Nam đã chuẩn hóa một bộ app gồm 4–6 bề mặt.** Cả 5 hãng lớn đều có:
   - app thu ngân;
   - app gọi món cho phục vụ;
   - in phiếu bếp;
   - app quản lý cho chủ;
   - bán được khi mất mạng.

   Các hãng khác nhau ở **màn hình bếp (KDS)**, **QR order tại bàn** và **kiosk**:
   - iPOS có đủ cả ba, nhưng KDS khóa ở gói Advanced;
   - Sapo có app "Bar Bếp" với 5 trạng thái món;
   - KiotViet có KDS nhưng chỉ chạy trên máy tính;
   - CukCuk có app KDS và **app chạy bàn riêng**;
   - POS365 chỉ in bếp.

   ParkViet phải có đủ thu ngân + phục vụ + bếp/bar thì mới được coi là "POS F&B". QR order và kiosk là điểm cạnh tranh.
2. **UI/UX khác nhau theo ngành chủ yếu ở màn bắt đầu và đơn vị đang mở**, không phải ở lõi tiền. Có 5 kiểu màn bán:

   | Màn bán | Ngành |
   |---|---|
   | Lưới món bán nhanh, trả trước | Cafe/trà sữa, căng tin, quán ăn nhỏ |
   | Sơ đồ bàn theo khu/tầng, trả sau | Nhà hàng, quán ăn có bàn |
   | Bảng phòng/bàn chơi có đồng hồ | Karaoke, bida |
   | Danh sách tab | Bar/club |
   | Quẹt thẻ suất ăn | Căng tin công ty/trường |

   Cùng một codebase phục vụ được cả năm kiểu. **"Mode" là cấu hình của thiết bị** (cách Square và Toast làm), không phải app riêng cho từng ngành.
3. **Toàn bộ thị trường dùng chung một mô hình tính giờ:** một **mặt hàng dịch vụ tính giờ** có bảng giá theo khung giờ × loại ngày × loại phòng, kèm block làm tròn. Hãng Việt chưa tài liệu hóa các tính năng sâu hơn:
   - tạm dừng;
   - chuyển phòng mà giữ giá của đoạn cũ;
   - báo hết giờ;
   - cọc;
   - relay đèn bida.

   Đây là khoảng trống để tạo khác biệt. Thiết kế đúng là **phiên chơi gồm nhiều đoạn thời gian** (theo mẫu Vyrox).
4. **Kỳ vọng mặc định về chống gian lận:**
   - hủy món đã báo bếp phải có lịch sử, lý do và người hủy;
   - sửa / in lại / xóa tạm tính và sửa giờ chơi phải có quản lý duyệt.

   Lõi ParkViet đã có `Approval` và `AuditEntry` để dùng lại.
5. **Pháp lý đã đổi so với các report trước.**
   - Từ **01/07/2026**, **NĐ 254/2026/NĐ-CP** thay NĐ 123/2020 và NĐ 70/2025; **TT 91/2026/TT-BTC** thay TT 32/2025.
   - Hộ kinh doanh có doanh thu **> 1 tỷ/năm** phải dùng hóa đơn điện tử có mã hoặc hóa đơn khởi tạo từ máy tính tiền (NĐ 68/2026, sửa bởi NĐ 141/2026).
   - **Thuế GTGT phải đặt theo từng món, không theo đơn:**

     | Loại | Thuế suất đến 31/12/2026 |
     |---|---|
     | Đồ ăn | 8% |
     | Bia rượu, giờ hát karaoke (chịu TTĐB) | 10% |

   - Phí phục vụ là doanh thu chịu thuế. Tip tự nguyện không phải doanh thu (mới có một nguồn, chưa chắc chắn).
6. **Về kỹ thuật, ba thứ hiện chưa có là điều kiện để làm F&B:**
   - **Định danh thiết bị:** máy bếp và máy phục vụ ghép bằng mã/QR; nhân viên đăng nhập bằng PIN trên máy dùng chung.
   - **Đẩy realtime thay cho poll:** server đã có `solid_cable` trong Gemfile và `config/cable.yml`, nhưng `server/app/channels` chưa có channel nào.
   - **In ra máy in nhiệt LAN không qua hộp thoại trình duyệt:** hiện `PrintAdapter` chỉ có adapter trình duyệt.
7. **Đề xuất cho dạng app:**
   - Một codebase React cho mọi bề mặt, cài được như PWA.
   - Bọc bằng **Capacitor** (Android trước) khi cần in ESC/POS qua Bluetooth/LAN, giữ màn hình luôn sáng, chế độ kiosk hoặc nhận thông báo nền.
   - Không viết native riêng. [SL] Mục 6.1 có lý do và phương án thay thế.

---

## 2. Thị trường Việt Nam: mỗi hãng có những bề mặt nào

### 2.1 Bề mặt × hãng

| Bề mặt | KiotViet FnB | MISA CukCuk | iPOS (FABi) | Sapo FnB | POS365 |
|---|---|---|---|---|---|
| Thu ngân trên máy tính / web | Web | PC/POS | Có | PC + app | PC/web |
| Thu ngân trên máy POS Android | Có | Có | Có | Có | Có |
| App phục vụ gọi món (điện thoại, tablet, PDA) | iOS/Android | Có (app Bán hàng) | FABi PDA / Order | Sapo Phục vụ | Dùng chung app thu ngân |
| App chạy bàn (runner) | Thông báo trên app phục vụ | **App riêng** | – | Qua app phục vụ | – |
| KDS bếp/bar | **Chỉ trên máy tính** | App KDS | App KDS (**gói Advanced**) | App Bar Bếp | **Không có, chỉ in** |
| In phiếu bếp | USB / LAN | Có | Bluetooth / USB / LAN | Có, kèm "phiếu kiểm đồ" | LAN / Wi-Fi |
| In tem ly | Có | Có | Có | Có, bật theo hình thức phục vụ | Có |
| Màn hình khách | Chỉ màn QR | Không thấy | **Màn phụ hiện hóa đơn + QR** | Chỉ thiết bị QR03 | Không thấy |
| Kiosk tự order | Không | Không | **FABi SelfOrder** | Không | Không |
| QR order tại bàn | Gói Chuyên nghiệp | Có | O2O | Gói Pro | Không thấy |
| Đặt bàn | Có | Có | Booking (Advanced) | Có | Có, kèm cọc |
| App chủ quán | Có | Có | Có | Có | BOSS |
| Offline | Có | Có | Có (máy POS làm server LAN) | Có | Có |
| Tính giờ | Bước 15 phút | Từ bản R77 | Không thấy | Theo block | Nhiều phương thức cho một phòng |
| GrabFood / ShopeeFood | Gói Chuyên nghiệp | Có | Có | Có | Không thấy |

Nguồn [V]:
- KiotViet: [màn hình bếp](https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/fnb-che-bien/man-hinh-bep/), [app phục vụ](https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/huong-dan-bar-cafe-nha-hang/ung-dung-kiotviet-pos-bar-cafe-nha-hang/), [phí dịch vụ](https://www.kiotviet.vn/phi-dich-vu).
- CukCuk: [cukcuk-pos](https://www.cukcuk.vn/cukcuk-pos/), [KDS](http://helpv2.cukcuk.com/en/kb/how-can-the-chef-view-all-items-sent-to-kitchen-bar-if-the-restaurant-has-multiple-kitchens-bars/), [app Chạy bàn](https://play.google.com/store/apps/details?id=vn.com.misa.cukcuktv).
- iPOS: [FABi](https://play.google.com/store/apps/details?id=com.ipos.fabi), [FABi KDS](https://play.google.com/store/apps/details?id=com.ipos.fabikds), [SelfOrder](https://play.google.com/store/apps/details?id=com.ipos.fabiselforder.app), [buffet](https://ipos.vn/en/mo-hinh-nha-hang-buffet/).
- Sapo: [Bar Bếp](https://play.google.com/store/apps/details?id=com.sapo.fnb.kitchen), [phiếu kiểm đồ](https://www.sapo.vn/cap-nhat-tinh-nang/phieu-kiem-do), [bảng giá](https://www.sapo.vn/bang-gia-sapo-fnb.html).
- POS365: [app](https://play.google.com/store/apps/details?id=vn.pos365.cashierspos365), [nhà hàng](https://www.pos365.vn/nganh-nghe/phan-mem-quan-ly-nha-hang).

### 2.2 Chi tiết đáng học từ từng hãng

- **KiotViet** [V]:
  - Màn bếp có cột "Chờ chế biến" với 3 tab: *Ưu tiên*, *Theo món* (gộp cùng món trên mọi bàn) và *Theo phòng/bàn*. Cột "Đã xong / Chờ cung ứng" cho bấm xong theo từng suất hoặc tất cả.
  - Bếp báo được *hết món* và *Không nhận gọi thêm*.
  - Thu ngân xem được *Lịch sử báo bếp*, gồm giờ và số món tăng/giảm.
  - Phục vụ bấm *Yêu cầu thanh toán* thì yêu cầu được đẩy về thu ngân.
  - Một bàn mở được nhiều đơn ("Thêm đơn mới").
  - Topping có giá: giá dòng = giá gốc + Σ(số lượng topping × đơn giá topping). Ghi chú không làm đổi giá.
- **CukCuk** [V]:
  - KDS trả món theo order, theo bếp hoặc theo từng món; cho trả một phần và xem công thức chế biến.
  - **App Chạy bàn** cho runner biết món nào đã xong và mang ra bàn nào.
  - Sửa, in lại hay xóa tạm tính phải có quản lý xác nhận. Sửa giờ vào của dịch vụ tính giờ cũng có tùy chọn bắt quản lý xác nhận.
  - Block tính giờ nhỏ nhất là 1 phút. Có "Lịch đặc biệt" cho ngày lễ.
- **iPOS** [V]:
  - **Máy POS chạy dịch vụ nền làm server trong mạng LAN** cho PDA, KDS và kiosk.
  - KDS có trạng thái "chờ quá lâu" và báo cáo thời gian chế biến.
  - Buffet: thực đơn theo hạng vé, giới hạn số món mỗi lượt gọi.
  - Kiosk phải cùng mạng LAN với máy POS.
- **Sapo** [V]:
  - App Bar Bếp lọc phiếu theo **hình thức phục vụ** (tại bàn / mang đi / giao / GrabFood). Trạng thái món: *Món mới → Đang chế biến → Ra đồ → Trả món / Hủy chế biến*. Lý do hủy được gửi về app phục vụ.
  - **Phiếu kiểm đồ** liệt kê các món của đơn để kiểm khi ra món và trước khi thanh toán.
  - Hóa đơn điện tử cho dòng tính giờ xuất được theo đơn vị giờ.
  - Khách quét QR trên bill để tự nhập thông tin xuất hóa đơn điện tử.
- **POS365** [V]:
  - Sơ đồ bàn có 4 trạng thái: trống / có khách / chờ món / đã thanh toán.
  - Tự tách phiếu: đồ ăn xuống bếp, đồ uống lên bar.
  - **Cân điện tử cho hải sản**, tính theo kg và thời giá.
  - Quán bia theo dõi vỏ chai theo ca.
  - Buffet có bộ đếm giờ, cảnh báo bàn sắp hết thời gian.
  - Thu ngân chỉ được thu tiền; chỉ quản lý được hủy bill.

### 2.3 Giá và cách khóa tính năng theo gói

| Hãng | Giá (tháng) | Tính năng bị khóa ở gói cao |
|---|---|---|
| KiotViet | 270k / 330k / 490k, 1 chi nhánh | QR menu, website đặt món, GrabFood/ShopeeFood, kiểm tra bàn trống: từ gói Chuyên nghiệp. AI: gói Cao cấp. Gói thấp nhất giới hạn 3 tài khoản. |
| CukCuk | 199k / 299k / 499k, trả theo năm | Kho, công nợ: từ gói Professional. CRM: gói Enterprise. Bảng so sánh là ảnh nên không đọc được gói nào có KDS. |
| Sapo | 249k / 399k (mua từ 2 năm: 170k / 249k) + phí khởi tạo 1–1,5 triệu | QR order, giá vốn kho, không giới hạn thiết bị: gói Pro. |
| iPOS | Không công bố | **KDS, PDA, Booking, CRM: bundle Advanced.** |
| POS365 | 1,95 triệu/năm, không chia gói | – |

Phần cứng thường đi kèm [V]:
- Máy POS Sunmi (T2, D3 Pro) hoặc iAP (5,2–6,9 triệu).
- Tablet Samsung làm PDA (≈3,6 triệu).
- Máy in nhiệt 80mm USB/LAN (0,95–1,55 triệu).
- Máy in tem ly (≈1,95 triệu).
- Két tiền (≈0,9 triệu).
- Loa báo chuyển khoản (≈0,4 triệu).
- Màn QR.
- Combo trọn bộ 7–17,8 triệu (CukCuk), combo karaoke–bida 14,2 triệu.

---

## 3. UI/UX theo từng ngành

Mỗi ngành mô tả 4 điểm: mô hình vận hành, màn bán chính, luồng đặc thù, thiết bị.

Nhãn **[bắt buộc]** là thiếu thì chủ quán không chuyển sang dùng. Nhãn **[nâng cao]** là điểm cạnh tranh.

Phân loại này tổng hợp từ ba research con [V/3P]; phần sắp xếp là [SL].

### 3.1 Cafe, Trà sữa

- **Mô hình:** đa số **trả trước tại quầy**: gọi → trả → pha → gọi số / dán tem ly. Một phần là quán ngồi, trả sau. Giờ cao điểm đơn nhỏ dồn dập; một đơn có nhiều ly, mỗi ly một tùy chọn riêng.
- **Màn bán:** **lưới món có ảnh, nhóm theo danh mục**, đặt ở bên trái; giỏ ở bên phải. Chạm vào món mở **bảng tùy chọn** gồm size, đường, đá, topping, ghi chú, hiện đủ trên một màn và không cuộn nhiều bước. Nút "Thêm ly giống vậy". Phím tắt cho các món bán chạy.
- **Luồng:**
  - [bắt buộc]
    - Modifier có nhóm min/max, có nhóm bắt buộc, có giá cộng thêm.
    - Hai ly khác topping là hai dòng.
    - Số gọi theo ngày.
    - **In tem ly**: mỗi ly một tem ghi tên món, tùy chọn, số gọi, tên khách.
    - Phiếu pha chế gửi quầy bar.
    - Thanh toán QR / tiền mặt.
    - Trừ nguyên liệu theo công thức, có công thức riêng cho từng size (KiotViet [V]).
  - [nâng cao]
    - Màn khách hiện số đang gọi (Order Status Screen như Odoo [V]).
    - Kiosk tự order (iPOS [V]).
    - QR order tại bàn cho quán ngồi.
    - Tích điểm.
    - Đơn GrabFood/ShopeeFood vào thẳng màn bar.
    - Combo.
    - Giá giờ vàng.
- **Thiết bị:** máy POS + máy in bill + **máy in tem**; tablet bar hoặc máy in bar; màn khách (đã có `customer-display`); tùy chọn kiosk, thẻ rung.

### 3.2 Quán ăn (bún phở, cơm, quán nhậu)

- **Mô hình:** hai kiểu song song:
  - quán nhỏ trả trước, gần giống cafe;
  - quán có bàn hoặc quán nhậu: **gọi nhiều đợt, trả sau**.

  Có nhiều đơn mang đi / giao hàng. Quán nhậu thường có **hải sản tính theo cân** và **vỏ chai / két bia**.
- **Màn bán:**
  - quán nhỏ: lưới món;
  - quán có bàn: **danh sách bàn dạng lưới ô** (nhanh hơn sơ đồ kéo-thả), lọc trống / có khách / chờ món.

  Chạm vào bàn thì vào đơn của bàn đó. Nút "Mang đi" và "Giao hàng" luôn có trên màn.
- **Luồng:**
  - [bắt buộc]
    - Mở bàn, gọi món, **báo bếp theo đợt**: chỉ gửi phần chênh lệch kể từ lần trước.
    - Hủy món đã báo bếp kèm lý do, có in phiếu hủy.
    - Chuyển bàn, gộp bàn.
    - In tạm tính.
    - Thanh toán, ghi nợ khách quen (đã có `credit`).
    - **Món bán theo cân / định lượng**: dùng lại `retail.measured`.
    - Đơn giao hàng: đã có `deliveries` và nguồn đơn `order_source`.
  - [nâng cao]
    - Theo dõi vỏ chai / két theo ca (POS365 [V]).
    - Tách bill.
    - QR order.
    - Nhận đơn từ GrabFood/ShopeeFood.
- **Thiết bị:** máy POS hoặc tablet thu ngân; **điện thoại phục vụ**; máy in bếp LAN; tùy chọn cân điện tử.

### 3.3 Nhà hàng (phục vụ bàn, Á/Âu, buffet)

- **Mô hình:** phục vụ đầy đủ, nhiều khu / tầng, nhiều trạm bếp (nóng, lạnh, bar), có đặt bàn và cọc. Có thể ra món theo **course** (khai vị → món chính → tráng miệng). Có thể tính phí phục vụ. Hóa đơn thường cần xuất cho công ty.
- **Màn bán:**
  - **Sơ đồ bàn theo khu/tầng**, đúng vị trí và hình dạng (Odoo: số ghế, hình, màu [V]).
  - Màu trạng thái: trống / có khách / đã gọi món / chờ món quá lâu / yêu cầu thanh toán / đã đặt.
  - Ô bàn hiện số khách, thời gian ngồi và tổng tạm tính.
- **Luồng:**
  - [bắt buộc]
    - Số khách.
    - Gọi món theo đợt; mỗi trạm bếp nhận đúng món của mình (`ProductStationRoute`).
    - KDS hoặc phiếu theo trạm.
    - Chuyển, gộp, tách bàn; tách bill theo món, chia đều hoặc theo ghế.
    - Phí phục vụ (Spree `Fee`).
    - In tạm tính có quyền.
    - Đặt bàn kèm cọc (POS365 [V]); kiểm tra bàn trống khi nhận đặt (KiotViet [V]).
    - Hóa đơn điện tử có MST công ty.
  - [nâng cao]
    - **Course hold/fire**: món "chờ" chỉ hiện ở màn expo, bấm fire mới xuống bếp (Toast [V]).
    - Gọi món theo ghế (Toast, TouchBistro [V]).
    - Màn expo / chạy bàn.
    - **Buffet**: vé theo hạng, thực đơn theo vé, giới hạn số món mỗi lượt, đếm giờ bàn (iPOS, POS365 [V]).
    - QR order tại bàn.
    - Đặt bàn online.
- **Thiết bị:** máy thu ngân; **điện thoại / tablet phục vụ**; **tablet KDS cho từng trạm** (hoặc máy in từng trạm); màn expo; máy in bill; tùy chọn tablet đặt bàn ở lễ tân.

### 3.4 Karaoke, Bida

- **Mô hình:** đơn vị đang mở là **phòng / bàn chơi có đồng hồ**. Bill gồm giờ chơi và đồ ăn uống gọi thêm. Giá theo khung giờ, loại ngày và loại phòng. Phiên chơi kéo dài, có thể qua ca và qua đêm.
- **Màn bán:** **bảng phòng/bàn (resource board)**:
  - mỗi ô hiện tên phòng, loại, **đồng hồ chạy**, tiền giờ tạm tính và tiền đồ uống;
  - lọc "Đang hát / Sắp hết giờ / Trống / Đã đặt / Đang dọn" (KiotViet có 4 trạng thái đầu [V]; "Đang dọn" là [SL]).

  Thao tác chính có ngay trên ô: *Bắt đầu*, *Tạm dừng*, *Gọi món*, *Chuyển phòng*, *Thanh toán*.
- **Luồng:**
  - [bắt buộc]
    - **Dòng tính giờ**:
      - lưu **danh sách đoạn thời gian**, không chỉ một cặp start/end;
      - bảng giá theo khung giờ × loại ngày (thường / cuối tuần / lễ) × loại phòng;
      - block làm tròn và **ngưỡng ân hạn** (Sapo [V]);
      - **chia đoạn khi giờ chơi vắt qua hai khung giá**.
    - **Chuyển phòng giữ giá của đoạn cũ** [SL, không hãng Việt nào tài liệu hóa].
    - Gộp / tách phòng.
    - **Sửa giờ phải có quản lý duyệt và lưu nhật ký** (CukCuk [V]).
    - Phụ thu lễ Tết.
    - Hóa đơn điện tử ghi số lượng theo giờ.
    - Thuế 10% cho giờ hát karaoke (xem §7).
  - [nâng cao]
    - Tạm dừng / tiếp tục.
    - Đếm ngược cho gói giờ trả trước, báo sắp hết giờ (Vyrox [V]).
    - Đặt phòng kèm cọc.
    - Khuyến mãi giờ (giờ vàng, tặng phút).
    - Thẻ nạp giờ / nạp tiền.
    - QR hoặc tablet gọi món trong phòng.
    - **Relay đèn bàn bida**: bắt đầu thì bật, kết thúc thì tắt, có ân hạn (Vyrox, Brunswick [V]; hãng Việt chưa thấy).
    - Dòng tiếp viên gắn nhân viên.
    - Giải đấu, cọc cơ.
    - Cảnh báo giờ hoạt động karaoke (0h–8h, NĐ 54/2019) [3P].
- **Thiết bị:** máy thu ngân có bảng phòng; điện thoại phục vụ phòng; máy in / màn bar; tùy chọn QR hoặc tablet trong phòng. Bida có thêm **bộ relay mạng** (HLK-SW16, Shelly…) **kèm contactor** cho tải đèn lớn, và **bridge LAN** để vẫn tắt/bật được khi mất internet [3P].

### 3.5 Bar, Pub & Club

- **Mô hình:** **tab** mở theo bàn hoặc theo khách, gọi thêm nhiều lần, nhiều quầy bar dùng chung một tab. Ca đêm qua 0h. Bàn VIP có minimum spend. Khách gửi rượu.
- **Màn bán:**
  - **danh sách tab**: tên hoặc mô tả khách, bàn, giờ mở, tổng tiền; tìm nhanh theo tên;
  - với club có bàn VIP: sơ đồ khu vực (Quầy bar / VIP / Sảnh / Sân vườn — KiotViet [V]).

  Màn gọi món ưu tiên đồ uống và shot.
- **Luồng:**
  - [bắt buộc]
    - Mở tab, thêm món từ bất kỳ máy nào.
    - **Ngày kinh doanh có giờ cắt sau 0h** (Toast mặc định 4:00 [V]), lưu `business_date` trên đơn ngay khi tạo.
    - Giá theo khung giờ (happy hour).
    - Chia bill.
    - Định mức nguyên liệu.
    - Phí phục vụ.
    - Thuế 10% cho bia rượu.
  - [nâng cao]
    - **Định lượng ml / shot** trên chai đang mở (module Odoo [V]).
    - **Gửi rượu**: khách, chai, mức còn, ngày gửi, hạn, ảnh, lịch sử rót (POS lớn không có sẵn; BottleKeep là app riêng [V]).
    - **Minimum spend**: nếu bill thấp hơn mức tối thiểu thì thêm dòng phụ thu bù [SL].
    - Vé vào cửa, quy đổi được thành drink credit.
    - Cọc bàn VIP: ở Việt Nam cọc bằng tiền mặt / QR thay cho pre-auth thẻ [SL].
    - Tip.
    - Gói bottle service.
- **Thiết bị:** máy POS cho từng quầy bar; điện thoại phục vụ; màn hoặc máy in bar; máy quét vé / QR ở cửa; tùy chọn máy in nhãn chai gửi.

### 3.6 Căng tin & Trạm dừng nghỉ

- **Mô hình:**
  - **Căng tin công ty / trường / bệnh viện:** bán suất cố định giờ cao điểm. Thanh toán bằng **thẻ nhân viên / học sinh** hoặc ví trả trước, hoặc **ghi nợ theo công ty**, cuối kỳ xuất bảng kê. Có thể có trợ giá: công ty trả một phần, nhân viên trả phần còn lại.
  - **Trạm dừng nghỉ / quán cơm bình dân:** nhiều khách cùng lúc khi xe đến, bán cả cơm suất và hàng đóng gói, mạng yếu.
- **Màn bán:**
  - **lưới món rất lớn, ít thao tác** (KiotViet "ít thao tác", nhiều quầy trên một tài khoản [V]);
  - **ô quét thẻ / mã vạch luôn sẵn sàng**;
  - **âm báo khác nhau cho thẻ hợp lệ / quẹt trùng / thẻ lỗi** (Yousoft [3P]).
- **Luồng:**
  - [bắt buộc]
    - Bán nhanh.
    - Bán chung hàng đóng gói có mã vạch: dùng lại lõi bán lẻ (`retail.units`).
    - Ví trả trước hoặc tài khoản nhân viên; giới hạn suất mỗi ngày, chặn quẹt trùng.
    - **Công nợ và bảng kê theo công ty**: mở rộng `credit` đã có.
    - Báo cáo theo ca / quầy.
    - **Bán được khi mạng yếu** (trạm dừng).
  - [nâng cao]
    - Đặt suất trước, dự báo số suất.
    - Trợ giá chia phần công ty / nhân viên.
    - Phụ huynh nạp tiền và nhận cảnh báo số dư (LINQ, thẻ SSC + MoMo [V]).
    - Kiosk.
    - Hoa hồng theo xe / nhà xe ở trạm dừng: chưa thấy phần mềm nào công bố, cần phỏng vấn.
- **Thiết bị:** máy POS kèm **đầu đọc RFID/NFC hoặc máy quét QR**; máy quét mã vạch; màn khách; tùy chọn màn bếp, kiosk.

### 3.7 Tóm tắt: màn bán và module theo ngành

| Ngành | Màn bán đầu tiên (`surface`) | Đơn vị đang mở | Module bắt buộc | Nâng cao |
|---|---|---|---|---|
| Cafe, Trà sữa | `menu_grid` | Đơn trả trước | menu, kitchen, order_number, **cup_label** | recipes, kiosk, qr_order, customer display gọi số |
| Quán ăn | `menu_grid` hoặc `table_grid` | Đơn hoặc bàn | menu, kitchen; tables + postpay nếu có bàn; `retail.measured` | recipes, qr_order, vỏ chai |
| Nhà hàng | `floor_plan` | Bàn | menu, kitchen (nhiều trạm), resources, tables, postpay, service_charge, **reservations** | courses, seats, buffet (`cover`), qr_order, expo |
| Karaoke, Bida | `resource_board` | Phòng / bàn chơi có đồng hồ | resources, timed_billing, menu, postpay | kitchen, reservations + cọc, prepaid_time, **iot_relay**, qr_order trong phòng |
| Bar, Pub & Club | `tab_list` (+ `floor_plan` cho VIP) | Tab | menu, kitchen (trạm bar), postpay, service_charge, **business_day** | bottle_keep, pour_tracking, min_spend, cover (vé), tips |
| Căng tin & Trạm dừng | `menu_grid` + quét | Đơn trả trước | menu, order_number, `retail.units`, **meal_accounts** (ví / thẻ / công nợ công ty) | kitchen, preorder suất, subsidy, kiosk |

Module **in đậm** chưa có trong danh sách 9 module F&B đang đăng ký ở `config/initializers/pos_modules.rb`. Xem §5.

---

## 4. Các app / bề mặt cần xây

Yêu cầu là app cho nhân viên order và app cho bếp **phải có trong kế hoạch**. Dưới đây là toàn bộ bề mặt, đều đưa vào lộ trình ở §8. Chỉ khác nhau ở thứ tự làm.

| # | Bề mặt | Người dùng | Thiết bị | Màn chính | Ghi chú |
|---|---|---|---|---|---|
| S1 | **Thu ngân F&B** | Thu ngân, quản lý ca | PC / máy POS Android / tablet | 5 surface ở §3.7 + thanh toán + ca | Mở rộng `apps/pos` hiện có; lõi tiền, ca, sổ quỹ dùng lại 100% |
| S2 | **App phục vụ (order tại bàn)** | Phục vụ | Điện thoại / PDA | Sơ đồ / lưới bàn → gọi món → báo bếp → yêu cầu thanh toán → nhận thông báo "món đã xong" | Không thu tiền ở bản đầu; thu tại bàn bằng QR để sau. **Có trong lộ trình** |
| S3 | **KDS bếp / bar** | Đầu bếp, pha chế | Tablet treo tường / máy POS phụ | Ticket theo trạm; các tab Ưu tiên / Theo món (All-day) / Theo bàn; bump, recall; hết món; timer vàng/đỏ | Định danh thiết bị, không cần người đăng nhập. **Có trong lộ trình** |
| S4 | **Expo / chạy bàn** | Runner, trưởng ca | Tablet ở pass / điện thoại | Món đã xong cần mang ra bàn nào; fire course | Có thể là một chế độ của S3 (Toast, Square) hoặc app riêng (CukCuk) |
| S5 | **Màn khách / gọi số** | Khách | Màn phụ, TV | Hóa đơn + QR thanh toán (đã có); **thêm số đang gọi / đã xong** | Mở rộng `customer-display` hiện có |
| S6 | **QR order tại bàn / phòng** | Khách | Điện thoại khách (web, không cài) | Menu → gọi → gửi phục vụ duyệt hoặc gửi thẳng bếp → gọi thanh toán | Dùng storefront Next.js hoặc web nhẹ; cần chống spam (mã bàn có phiên) |
| S7 | **Kiosk tự order** | Khách | Tablet / màn đứng | Chọn món + tùy chọn → trả QR → nhận số | Chế độ kiosk khóa máy |
| S8 | **App chủ quán** | Chủ, quản lý | Điện thoại | Doanh thu realtime, bàn đang mở, duyệt hủy món / sửa giờ / in lại, đặt bàn | Phần duyệt (`Approval`) giá trị nhất; báo cáo dùng lại `reports` |

### 4.1 Luồng chính giữa các bề mặt (nhà hàng)

```text
Khách vào → Phục vụ (S2) mở bàn 5, 4 khách
         → gọi món đợt 1 → [Báo bếp] ─┬─▶ KDS bếp nóng (S3): phở ×2
                                        └─▶ KDS bar (S3): trà đá ×4
KDS bếp bump "xong" ─▶ Expo (S4) / S2 nhận thông báo "Bàn 5: phở ×2 xong"
Phục vụ gọi thêm đợt 2 → [Báo bếp] → ticket mới (chỉ phần chênh lệch)
Phục vụ hủy 1 phở chưa làm → lý do + quyền → KDS hiện yêu cầu hủy + phiếu hủy
Khách gọi thanh toán → S2 [Yêu cầu thanh toán] ─▶ Thu ngân (S1) / S5 hiện QR
Thu ngân thu → lõi tender → ReceivedFunds → complete → HĐĐT → đóng bàn
```

Toàn bộ vẫn theo bất biến của lõi: **Workspace → đúng một draft Order → tender → ReceivedFunds → complete** ([kiến trúc §2](261108-1800-pos-multi-industry-architecture.md)). S2, S3, S4 **không thu tiền**. Chúng chỉ ghi dòng hàng và trạng thái bếp qua API của server.

---

## 5. Module: đối chiếu với danh sách đang đăng ký

Hiện `pos_modules.rb` đăng ký ở trạng thái `planned`: `fnb.menu`, `fnb.kitchen`, `fnb.order_number`, `fnb.recipes`, `resources`, `fnb.tables`, `fnb.postpay`, `fnb.service_charge`, `timed_billing`.

### 5.1 Điều chỉnh module đã có trong danh sách

| Module | Bổ sung sau research |
|---|---|
| `fnb.menu` | Modifier group có min/max, bắt buộc, giá cộng; **công thức theo size**; combo có món con (KDS bật/tắt hiển thị món con); thực đơn theo khung giờ; **thuế suất theo món** (8% / 10%) |
| `fnb.kitchen` | Trạm (prep / **expo**), định tuyến theo danh mục bếp **và theo hình thức phục vụ** (Sapo); ticket bất biến theo từng lần báo bếp, **chỉ gửi phần chênh lệch** (snapshot "đã gửi" như `last_order_preparation_change` của Odoo [V]); trạng thái món *mới → đang làm → xong → đã phục vụ / hủy*; recall; All-day; timer vàng/đỏ; **báo hết món** đồng bộ về S1, S2, S6; phiếu hủy; **phiếu kiểm đồ**; máy in là đường dự phòng cho KDS |
| `fnb.order_number` | Số theo chi nhánh × **ngày kinh doanh**; in trên bill, tem ly; hiện trên S5 |
| `fnb.recipes` | Trừ nguyên liệu khi complete, idempotent; công thức theo size / modifier; Sapo cảnh báo sắp hết kho |
| `resources` | Thêm trạng thái **đang dọn**; loại table / room / billiard / VIP |
| `fnb.tables` | Nhiều đơn trên một bàn (KiotViet); chuyển / gộp / tách; số khách; **ghế và course là tùy chọn** |
| `fnb.postpay` | **Yêu cầu thanh toán** từ S2; in tạm tính có quyền; đơn qua ca |
| `fnb.service_charge` | Phí phục vụ là dòng chịu thuế (Spree `Fee`); vé vào cửa / buffet là SaleLine kind `cover` |
| `timed_billing` | **Phiên gồm nhiều đoạn**: chia theo khung giá, tạm dừng, chuyển phòng; block + ân hạn; lịch đặc biệt; sửa giờ qua `Approval`; HĐĐT xuất theo đơn vị giờ; đếm ngược cho gói trả trước |

### 5.2 Module mới đề xuất

| Module | Ngành | Nội dung | Dựa trên |
|---|---|---|---|
| `fnb.cup_label` | Cafe, trà sữa | Tem ly cho từng ly | Mẫu in (`ReceiptTemplateSchema` + `label_format` đã có) |
| `fnb.reservations` | Nhà hàng, karaoke, bar | Đặt bàn / phòng, kiểm tra trống, cọc | `resources` + cọc. Dùng chung thiết kế `deposits` của lộ trình bán lẻ; cần ADR |
| `fnb.qr_order` | Mọi ngành có chỗ ngồi | Phiên QR theo bàn, đơn chờ phục vụ duyệt | S6 |
| `fnb.kiosk` | Cafe, căng tin, đồ ăn nhanh | Tự order, trả QR, nhận số | S7, VietQR đã có |
| `fnb.business_day` | Bar, karaoke, mọi quán mở qua 0h | Giờ cắt ngày kinh doanh theo chi nhánh; `business_date` lưu trên đơn, ca, số gọi, báo cáo | Lõi. **Có thể nên đưa vào lõi** thay vì module, vì ca và báo cáo đều dùng |
| `fnb.meal_accounts` | Căng tin | Thẻ / ví trả trước, hạn mức suất / ngày, công nợ theo công ty, trợ giá | `credit` + `CustomerProfile` |
| `fnb.bottle_keep` | Bar, karaoke | Sổ gửi rượu | Bảng riêng, không đụng tiền |
| `fnb.pour_tracking` | Bar | Định lượng ml trên chai mở | `recipes` |
| `resources.iot_relay` | Bida | Bật / tắt đèn theo sự kiện phiên | Bridge LAN; nằm ngoài đường tiền |
| `fnb.delivery_platforms` | Quán ăn, cafe | Nhận đơn GrabFood / ShopeeFood | `order_source` + `deliveries` đã có; cần API đối tác |

Dùng lại nguyên module bán lẻ: `retail.measured` (hải sản theo cân), `retail.units` (căng tin), `credit` (ghi nợ khách quen), `vietqr`, `customer_display`, `deliveries`, `order_source`.

---

## 6. Kiến trúc kỹ thuật bổ sung cho F&B

Phần này nối tiếp [kiến trúc §7](261108-1800-pos-multi-industry-architecture.md) và trả lời các điểm §10.2 để lại.

### 6.1 Một codebase, nhiều bề mặt, đóng gói bằng PWA rồi Capacitor [SL]

| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Một SPA React (`apps/pos`), mỗi bề mặt là một entry hoặc route, cài như PWA; bọc Capacitor khi cần native** (đề xuất) | Dùng lại 100% hook, SDK, i18n, mẫu in, logic hiển thị; một bộ test; ra mắt nhanh | PWA trên iOS hạn chế về in Bluetooth và chạy nền; cần plugin Capacitor cho ESC/POS |
| B. Viết app native riêng (React Native / Flutter) cho phục vụ và bếp | Trải nghiệm native, in Bluetooth tốt | Hai codebase UI; viết lại form, i18n, mẫu in; trái tinh thần DRY của kiến trúc đã chốt |
| C. Theo mô hình iPOS: một máy POS làm server LAN cho PDA / KDS | Chạy tốt khi mất internet | Lõi tiền và luật nghiệp vụ phải chạy ở máy cục bộ, trái nguyên tắc "luật chỉ ở server"; rất tốn công (Toast cũng cần thiết bị hub cắm dây [V]) |

**Đề xuất A.**
- Tách bundle: S2 và S3 lazy-load, không kéo code thu ngân.
- Mỗi thiết bị cấu hình **mode** (`cashier` / `waiter` / `kds` / `expo` / `display` / `kiosk`) giống "mode" của Square và Toast.
- Android là nền tảng chính: máy POS Sunmi và tablet Samsung đang phổ biến nhất ở Việt Nam [V].

Kiến trúc trước đã ghi F&B "chủ yếu là app". Phương án A vẫn là app (cài từ Play / APK qua Capacitor), chỉ không viết lại UI.

### 6.2 Định danh và ghép thiết bị

Cách làm theo Square device code và Lightspeed KDS connection code [V]:

- Quản lý tạo **mã ghép một lần (mã / QR)** cho từng thiết bị.
- Thiết bị đổi mã lấy một **device credential dài hạn**, lưu trong secure storage của Capacitor, hoặc IndexedDB nếu chạy PWA.
- Mỗi thiết bị là một bản ghi `Device`, gắn chi nhánh, mode, trạm bếp và quầy.
- Thu hồi được từng máy.
- KDS và màn khách chạy bằng danh tính máy.
- S1 và S2 cần thêm nhân viên đăng nhập **bằng PIN trên máy dùng chung**. Quyền vẫn tính theo nhân viên (`StaffMembership`, `Capabilities`).

Màn khách hiện đã có `DisplayPairing` / `DisplaySession`, có thể dùng làm mẫu.

### 6.3 Realtime

- Server đã có `solid_cable` trong Gemfile và `config/cable.yml` (production dùng solid_cable trên Postgres, dev dùng async), nhưng **chưa có channel nào**. Client vẫn poll (ví dụ `refetchInterval` 5–30 giây ở `use-receivables`, `use-deliveries`).
- Đề xuất **mỗi chi nhánh một kênh**, phát sự kiện mỏng:
  - `workspace.updated`;
  - `kitchen_ticket.updated`;
  - `item.sold_out`;
  - `payment.requested`.

  Client nhận sự kiện thì refetch qua API như cách Odoo "sync rồi notify qua bus" [V]. Giữ poll làm dự phòng khi websocket rớt.
- KDS cần độ trễ khoảng ≤ 2 giây. Cần đo `polling_interval: 0.1s` của Solid Cable dưới tải thật.

### 6.4 Gửi bếp và xung đột nhiều máy

- Mỗi dòng ghi **số lượng đã gửi bếp**. Khi bấm "Báo bếp", server tính phần chênh lệch (thêm hoặc hủy) và tạo `KitchenTicket` bất biến, **idempotent theo key** (lõi đã có `CommandReceipt`).
- Nhiều phục vụ cùng sửa một bàn: lõi đã có `revision` và `lease`. F&B cần **nới lease theo dòng**, hoặc cho thêm món không cần lease mà vẫn kiểm tra theo revision. Đây là điểm thiết kế lớn nhất của S2, vì hiện một workspace chỉ có một người giữ lease 120 giây.
- Đơn đã có tiền thì khóa snapshot (bất biến hiện có). Gọi thêm món sau khi đã thanh toán một phần thì cần quy tắc riêng; Odoo chặn sửa đơn đã paid [V].

### 6.5 In bếp

| Đường | Dùng khi | Ghi chú |
|---|---|---|
| Trình duyệt → **Epson ePOS-Print / Star WebPRNT** trong LAN | S1 / S2 web đang mở | Không cần native; máy in phải hỗ trợ (dòng TM-m30, mC-Print…) |
| **Capacitor plugin ESC/POS** (TCP 9100, Bluetooth) | Máy in nhiệt giá rẻ phổ biến ở Việt Nam (Xprinter…) | Máy in bếp iTP / KV838 thường in ESC/POS qua LAN [V] |
| **Server Direct Print (Epson) / CloudPRNT (Star)**: máy in tự kéo job | Đơn từ QR / kiosk / Grab khi không có máy POS nào mở | Mỗi máy in chỉ thuộc một hệ thống SDP [V] |

Ranh giới cũ giữ nguyên: **nội dung phiếu là snapshot ở server, cách in do adapter**. Thêm một **hàng đợi in ở server có trạng thái** để biết phiếu nào in lỗi và cho in lại. KDS và máy in theo trạm định tuyến theo cùng một bảng `ProductStationRoute`.

### 6.6 Offline

- Mọi hãng Việt đều quảng cáo bán được khi mất mạng [V]. Toast cần hub cắm dây; Loyverse để open ticket không đồng bộ giữa các máy khi offline [V].
- Đề xuất theo từng bậc [SL]:
  1. **Bản đầu:** S2 / S3 / S6 cần mạng, và UI ghi rõ điều đó. Đồng hồ tính giờ ở S1 **chạy theo thời gian server**, nên mất mạng không làm sai giờ: `started_at` lưu ở server, client chỉ hiển thị.
  2. **Bản sau:** S1 có **hàng đợi lệnh offline** cho đơn trả trước tại quầy. Đơn có `uuid` do client sinh, gửi lại idempotent. Thanh toán QR vẫn cần mạng để đối soát. Đây chính là cách tiếp cận đã nêu ở plan VietQR.
  3. Không làm server LAN (phương án C) trừ khi khách hàng trạm dừng / karaoke yêu cầu rõ.
- Relay đèn bida cần bridge LAN riêng để vẫn tắt/bật khi mất internet.

### 6.7 Ngày kinh doanh, thuế theo món, hóa đơn điện tử

- **`business_date`** gán khi mở đơn, theo giờ cắt của chi nhánh. Ca, số gọi và báo cáo đọc trường này, không tính lại từ `created_at` (bài học từ Square [3P]).
- **Thuế suất theo món** qua `TaxCategory` của Spree: đồ ăn 8%, bia rượu / giờ karaoke 10%. **Ngày 01/01/2027 phải đổi được bằng cấu hình**, không sửa code.
- **Hóa đơn điện tử:**
  - phát hành khi complete qua một nhà cung cấp (MISA / Viettel / VNPT…, chưa chọn);
  - có hàng đợi chạy lại khi lỗi, và báo cáo đơn chưa có hóa đơn;
  - khi không có thông tin người mua thì ghi "Bán cho người tiêu dùng";
  - khách quét QR trên bill để tự nhập MST (Sapo [V]);
  - mỗi địa điểm in tên và địa chỉ riêng.

---

## 7. Pháp lý và vận hành (cập nhật đến 09/11/2026)

| Quy định | POS phải làm gì | Nguồn |
|---|---|---|
| **NĐ 254/2026/NĐ-CP** (hiệu lực 01/07/2026) thay NĐ 123/2020 và NĐ 70/2025; **TT 91/2026/TT-BTC** thay TT 32/2025 | Mọi trích dẫn pháp lý trong plan / spec phải theo bộ văn bản mới | [EY](https://www.ey.com/vi_vn/technical/tax/tax-and-law-updates/nghi-dinh-254-2026-nd-cp-ve-hoa-don-dien-tu-va-chung-tu-dien-tu), [LuatVietnam](https://luatvietnam.vn/thue-phi-le-phi/bang-so-sanh-nghi-dinh-254-2026-va-nghi-dinh-123-2020-nd-cp-nd-cp-ve-hoa-don-chung-tu-dien-tu-565-110463-article.html) [3P] |
| HĐĐT khởi tạo từ máy tính tiền áp dụng cho ăn uống, nhà hàng, giải trí. Đơn vị đã dùng loại hóa đơn khác **được tiếp tục dùng** | Hỗ trợ cả hai loại: HĐ có mã từng lần và HĐ máy tính tiền; loại hóa đơn là cấu hình theo cửa hàng | [VOV](https://vov.vn/kinh-te/nhieu-truong-hop-khong-phai-su-dung-hoa-don-dien-tu-tu-ngay-17-post1312057.vov) [3P] |
| Giao dịch **22h–6h** được lập hóa đơn chậm nhất ngày làm việc kế tiếp nếu chưa có phần mềm tự động (Điều 9) | Hàng đợi phát hành; mặc định vẫn phát hành ngay | [ihoadon](https://ihoadon.vn/hddt/diem-moi-ve-hoa-don-theo-nghi-dinh-254-2026-nd-cp.html) [3P, cần đọc nguyên văn] |
| Bỏ thuế khoán từ 01/01/2026 (NQ 198/2025/QH15). Hộ **≤ 1 tỷ/năm** không chịu GTGT / TNCN; hộ **> 1 tỷ** phải dùng HĐĐT (NĐ 68/2026, sửa bởi NĐ 141/2026, hồi tố 01/01/2026) | Theo dõi doanh thu lũy kế trong năm, cảnh báo khi gần mốc 1 tỷ; xuất sổ doanh thu để kê khai | [thuvienphapluat](https://thuvienphapluat.vn/phap-luat-nha-dat/nghi-dinh-1412026ndcp-sua-doi-nghi-dinh-68-ve-thue-ho-kinh-doanh-ca-nhan-kinh-doanh-moi-nhat-16945.html), [Tạp chí Công Thương](https://tapchicongthuong.vn/chinh-thuc--nang-nguong-chiu-thue-voi-ho-kinh-doanh-len-1-ty-dong-nam--ap-dung-tu-1-1-2026-514336.htm) [3P, nhiều nguồn khớp nhau] |
| **GTGT 8%** đến 31/12/2026 (NQ 204/2025/QH15, NĐ 174/2025); hàng chịu TTĐB (bia, rượu, **karaoke**) vẫn **10%** | Thuế theo món; một hóa đơn có nhiều thuế suất; đổi được bằng cấu hình | [thuvienphapluat](https://thuvienphapluat.vn/ma-so-thue/phap-luat-thue/nam-2026-con-ap-dung-muc-thue-suat-thue-gtgt-8-hay-khong-989951-218063.html), [karaoke](https://thuvienphapluat.vn/hoi-dap-phap-luat/tu-172025-kinh-doanh-dich-vu-karaoke-co-duoc-giam-thue-vat-khong-138055508.html) [3P] |
| Phí phục vụ là doanh thu chịu GTGT; tip tự nguyện trả nhân viên không phải doanh thu | Phí phục vụ là dòng chịu thuế; tip để ngoài hóa đơn GTGT, có báo cáo chia tip | [ketoanthuanthien](https://ketoanthuanthien.vn/?p=10669) [3P, **một nguồn, chưa chắc**] |
| Karaoke không hoạt động 0h–8h (NĐ 54/2019, sửa bởi NĐ 148/2024) | Tùy chọn cảnh báo khi mở phiên sau 0h | [LuatVietnam](https://luatvietnam.vn/van-hoa/nghi-dinh-54-2019-nd-cp-ve-kinh-doanh-dich-vu-karaoke-174772-d1.html) [3P, chưa xác nhận bản sửa đổi] |

---

## 8. Lộ trình đề xuất

Tất cả bề mặt S1–S8 đều có mặt trong lộ trình. Thứ tự dựa trên ba tiêu chí:
- ngành nào mở được sớm nhất với ít module nhất;
- phần nào là điều kiện cho phần sau;
- mức rủi ro trên đường tiền.

| Đợt | Nội dung | Bề mặt | Ngành mở được |
|---|---|---|---|
| **F0. Nền** | ADR đổi phạm vi "không F&B" (`product-and-architecture.md`); `Workspace.service_mode`; registry SaleLine kind; `business_date`; thuế theo món; **`Device` + ghép mã + PIN**; **channel realtime theo chi nhánh**; hàng đợi in ở server + adapter ePOS / ESC/POS; vỏ Capacitor Android | Hạ tầng cho S1–S8 | – |
| **F1. Trả trước tại quầy** | `fnb.menu` (modifier, combo, thuế theo món), `fnb.kitchen` bản phiếu in + **KDS (S3) bản đầu**, `fnb.order_number`, `fnb.cup_label`, màn khách gọi số (S5) | S1 `menu_grid`, **S3**, S5 | Cafe / trà sữa, quán ăn trả trước, căng tin (bán nhanh, chưa có thẻ) |
| **F2. Bàn và trả sau** | `resources`, `fnb.tables`, `fnb.postpay`, `fnb.service_charge`; **App phục vụ (S2)**; báo bếp theo phần chênh lệch; hủy món kèm lý do và `Approval`; tạm tính; chuyển / gộp / tách; nới lease cho nhiều phục vụ; `fnb.recipes` | S1 `floor_plan` / `table_grid`, **S2**, S3 đầy đủ (trạm, All-day, recall, hết món) | Quán ăn có bàn, nhà hàng bản cơ bản, bar dạng bàn |
| **F3. Tính giờ** | `timed_billing` (nhiều đoạn, khung giá, block / ân hạn, chuyển phòng, sửa giờ có duyệt), surface `resource_board`, trạng thái "đang dọn" | S1 `resource_board`, S2 phục vụ phòng | Karaoke, bida |
| **F4. Nâng cao theo ngành** | Nhà hàng: **Expo / chạy bàn (S4)**, course hold/fire, ghế, buffet (`cover`), `fnb.reservations` + cọc. Bar: `tab_list`, bottle_keep, min_spend, vé vào cửa. Căng tin: `fnb.meal_accounts`. Karaoke: tạm dừng, đếm ngược, gói giờ | **S4**, S1 `tab_list` | Nhà hàng đầy đủ, bar / club, căng tin công ty |
| **F5. Kênh khách** | **QR order (S6)**, **Kiosk (S7)**, `fnb.delivery_platforms` (Grab / Shopee), **App chủ quán (S8)** (duyệt, realtime), relay đèn bida, offline queue cho S1 | **S6, S7, S8** | Mọi ngành |

Ghi chú:
- **F1 trước F2** vì không cần nhiều phục vụ cùng sửa một đơn, nên chưa đụng đến lease. Ngành cafe cũng là ngành được mọi hãng nhắc nhiều nhất.
- **App phục vụ (S2) nằm ở F2, KDS (S3) có ngay từ F1.** Cả hai đều có trong kế hoạch. KDS đến trước vì quán trả trước đã cần bếp nhận phiếu.
- Mỗi đợt có plan riêng trong `plans/`. HĐĐT khởi tạo từ máy tính tiền là một plan dùng chung với bán lẻ: chọn nhà cung cấp, hàng đợi phát hành.

---

## 9. Rủi ro

1. **Lease một người / một workspace** hiện là bất biến chống ghi đè. Nới ra cho nhiều phục vụ cùng sửa một bàn là thay đổi lớn nhất ở lõi. Cần thiết kế cùng `revision` và chạy lại bộ test bán hàng.
2. **Trừ nguyên liệu và thu tiền** phải đi qua workflow tồn của Spree, idempotent. Hủy món đã làm không nhập lại kho.
3. **Thời gian tính giờ** phải lấy theo đồng hồ server (`database_now` đã có). Client chỉ hiển thị, nếu không sẽ bị chỉnh giờ máy để gian lận.
4. **In ấn:** máy in giá rẻ ở Việt Nam đa phần chỉ có ESC/POS, không có ePOS / WebPRNT. Vì vậy vỏ Capacitor gần như bắt buộc cho in bếp qua LAN / Bluetooth.
5. **Realtime trên Solid Cable** chưa được đo tải. Nếu nhiều chi nhánh cùng mở KDS, cần đo độ trễ và chi phí ghi Postgres.
6. **Pháp lý:** nội dung bắt buộc của HĐ máy tính tiền theo NĐ 254 / TT 91, mức 8% sau 31/12/2026, và thuế cho phí phục vụ / tip đều mới dựa trên nguồn thứ cấp.
7. **Phạm vi:** 6 ngành × 8 bề mặt là khối việc lớn. Phải giữ nguyên tắc "module không đụng tiền, code không hỏi ngành" để không thành 6 sản phẩm riêng.

## 10. Hạn chế của báo cáo

- Chưa dùng thử bản demo nào. Mô tả UI dựa trên tài liệu hướng dẫn, mô tả app trên chợ ứng dụng và trang marketing.
- Bảng tính năng theo gói của CukCuk và Sapo là ảnh, không đọc được. iPOS không công bố giá.
- Help center của POS365 và iPOS gần như không có nội dung F&B. Thông tin về karaoke / bida của hai hãng này chủ yếu lấy từ nguồn bên thứ ba.
- Hãng Việt không tài liệu hóa các tính năng tạm dừng giờ, chuyển phòng giữ giá, gửi rượu, relay đèn, hoa hồng tài xế. Không có tài liệu không có nghĩa là họ không có các tính năng này.
- Chưa đọc nguyên văn NĐ 254/2026 và TT 91/2026.

## 11. Câu hỏi chưa giải quyết

1. **Thứ tự ngành:** có đồng ý mở cafe / trà sữa, quán ăn trả trước và căng tin ở F1 trước, rồi đến nhà hàng / bàn, rồi karaoke / bida không? Hay có khách hàng cụ thể ở ngành khác cần ưu tiên?
2. **Dạng app:** chấp nhận phương án A (một codebase React, PWA + Capacitor Android) hay muốn app native riêng cho phục vụ / bếp? Có cần iOS cho app phục vụ ngay từ đầu không?
3. **Offline:** bản đầu chấp nhận S2 / S3 cần mạng không? Có khách trạm dừng / karaoke ở nơi mạng yếu cần offline thật không?
4. **Phần cứng mục tiêu:** dòng máy POS / máy in nào cần hỗ trợ trước (Sunmi, Xprinter ESC/POS, Epson ePOS)? Câu trả lời quyết định adapter in.
5. **Nhà cung cấp HĐĐT** (MISA / Viettel / VNPT / khác) cho cả bán lẻ và F&B?
6. **Căng tin:** thẻ nhân viên là RFID có sẵn của công ty hay QR do hệ thống cấp? Trợ giá và trừ lương có trong phạm vi không?
7. **Trạm dừng:** hoa hồng tài xế / phụ xe tính theo xe, theo khách hay theo phần trăm doanh thu? Cần phỏng vấn chủ trạm.
8. **Gửi rượu, tiếp viên:** có trong phạm vi không, hay chỉ là sổ ghi nội bộ?
