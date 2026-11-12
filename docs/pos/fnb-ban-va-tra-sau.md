# Bán tại bàn và trả tiền sau

Hướng dẫn cho chủ quán dùng ba ngành phục vụ tại bàn: **Quán ăn** có bàn, **Nhà hàng** và **Bar, Pub & Club** (bán theo bàn). Mọi màn quản trị dưới đây nằm trong bảng quản trị POS (`apps/pos-dashboard`). Màn bán của thu ngân là `apps/pos`; máy phục vụ, màn bếp và trạm in là app ParkViet Nhân viên (`apps/pos-staff`).

## 1. Chọn ngành

- **Cửa hàng mới:** ở **Thiết lập cửa hàng**, chọn **Nhà hàng** hoặc **Bar, Pub & Club**: hai ngành này luôn có bàn. Chọn **Quán ăn** thì bước **Thiết lập quán** hỏi "Quán có bàn phục vụ không?"; trả lời có thì chi nhánh bật thêm sơ đồ bàn, gọi món tại bàn, trả tiền sau và phí phục vụ.
- **Chi nhánh đã có:** đổi ngành ở **Cấu hình → Chi nhánh → Mô hình kinh doanh**. Bản xem trước liệt kê module sẽ bật, hỏi về bàn khi ngành cho chọn, và đề nghị tạo khu bếp mặc định nếu chi nhánh chưa có khu nào. Không có gì tự áp khi chưa bấm áp dụng.
- **Quầy ghi đơn tại bàn:** phục vụ tại bàn cần một quầy. Đơn bàn được ghi vào ca đang mở ở quầy đó, và thu ngân của quầy đó nhận tiền các bàn. Wizard dùng quầy đầu tiên của chi nhánh (đặt tên ở bước Chi nhánh); trang Mô hình kinh doanh bắt chọn một quầy nếu chi nhánh chưa có. Đổi lại ở tab **Sơ đồ bàn** của chi nhánh.
- **Gửi bếp:** nhà hàng và bar mặc định gửi bếp khi phục vụ hoặc thu ngân bấm **Báo bếp**. Mỗi lần báo bếp chỉ gửi phần món mới gọi thêm. Đổi ở tab **Bếp & bar**.
- **Phí phục vụ:** nhà hàng gợi ý 5%. Sửa mức phí và loại thuế của phí ở tab **Sơ đồ bàn**. Để trống thì không thu.

## 2. Sơ đồ bàn

Ở tab **Sơ đồ bàn** của chi nhánh:

1. Tạo khu (Tầng 1, Sân vườn…) với kích thước lưới.
2. Thêm bàn: tên, số chỗ, hình (chữ nhật, tròn), vị trí và kích thước trên lưới.
3. Kéo bàn trên sơ đồ để xếp lại.

Nhà hàng mở màn bán trên sơ đồ khu. Bar mở trên lưới ô bàn. Quán ăn có bàn vẫn mở thẳng lưới thực đơn, và nút **Sơ đồ bàn** mở các bàn. Mỗi máy có thể đổi qua lại giữa ô bàn và sơ đồ; máy nhớ lựa chọn của mình.

## 3. Khu bếp và chuyển món

Ở tab **Bếp & bar**:

- Khi tạo quán có bàn, chi nhánh được tạo sẵn hai khu **Bếp** và **Bar**. Món có nhóm bếp `do_uong` đi thẳng tới Bar. Món khác đi tới khu mặc định (Bếp).
- Thêm quy tắc chuyển món theo món cụ thể hoặc theo nhóm bếp, và theo kiểu phục vụ nếu cần. Nhóm bếp của món đặt trong trang **Thực đơn**.
- Mỗi khu có thể có màn bếp, máy in bếp, hoặc cả hai. Hai mốc giờ của khu cho biết khi nào món chuyển vàng (chờ lâu) và đỏ (trễ).
- Khu **Ra món** (expo) gom món đã làm xong của các khu khác để kiểm trước khi mang ra bàn. Ở khu Bếp hoặc Bar, chọn khu ra món trong ô **Trạm ra món (expo)**.
- **Lý do hủy món đã gửi bếp:** chọn những lý do phục vụ được dùng, và thêm lý do riêng của quán. "Khác" kèm ghi chú luôn có trên máy. Hủy món đã báo bếp cần quyền hủy hoặc quản lý duyệt; khu bếp nhận phiếu hủy.

## 4. Máy in

Khai báo máy in ở tab **In ấn**, rồi gán máy in bếp cho từng khu ở tab **Bếp & bar**.

Máy in ESC/POS qua mạng LAN cần một **trạm in**: một máy Android chạy ParkViet Nhân viên ở mode trạm in, cùng mạng với máy in. Trạm in nhận lệnh in từ server và in phiếu bếp, phiếu hủy món, phiếu tạm tính và phiếu gọi món. Tab **Phần cứng** cho biết từng máy in đã in thành công chưa, và khu bếp nào chưa có màn bếp hay máy in.

## 5. Ghép máy phục vụ, màn bếp, trạm in

1. Ở trang **Thiết bị**, tạo thiết bị ở mode **Phục vụ**, **Màn bếp**, **Màn ra món** hoặc **Máy trạm in**, rồi lấy mã ghép (QR hoặc mã chữ).
2. Trên máy, mở ParkViet Nhân viên, quét QR hoặc nhập địa chỉ server và mã.
3. Màn đầu tiên sau khi ghép là danh sách kiểm tra:
   - máy phục vụ: chi nhánh đã có nhân viên đặt PIN chưa;
   - màn bếp hoặc ra món: đã chọn khu chưa, và khu có máy in chưa.

   Bấm **Bắt đầu dùng** để vào mode của máy.
4. Máy phục vụ hỏi nhân viên và PIN. Nhân viên cần quyền phục vụ bàn. Đặt PIN cho nhân viên trên trang quản trị.

Phục vụ mở bàn, nhập số khách, gọi món theo đợt và báo bếp. Phục vụ nhận tin khi món của bàn mình xong, và bấm **Yêu cầu thanh toán**. Thu ngân thấy bàn "Gọi thanh toán" trên sơ đồ, in tạm tính, rồi thu tiền mặt hoặc VietQR. Thu xong, bàn về trống.

## 6. iOS và Android

iOS dừng app khi app chạy nền hoặc khi màn hình tắt. iPhone làm máy phục vụ vẫn dùng được khi app đang mở, nhưng không nhận tin "món xong" khi app nằm nền. Trạm in và màn bếp trên iOS phải luôn mở app ở màn hình chính.

**Khuyến nghị:** dùng máy Android cho máy phục vụ dùng chung, màn bếp và trạm in.

## 7. Khách gọi món qua QR trên bàn

1. Bật module **Gọi món qua QR** của chi nhánh và tính năng **Gọi món qua QR** (`qr_order`). Cần cả hai.
2. Ở tab **Sơ đồ bàn**, phần **Gọi món qua QR**, chọn cách nhận đơn: **Chờ nhân viên duyệt rồi mới vào bếp** (mặc định) hoặc **Gửi thẳng vào bếp trong hạn mức**. Kiểu thứ hai bắt buộc nhập hạn mức tiền mỗi đơn, và có thể đặt số món tối đa. Đơn vượt hạn mức vẫn chờ duyệt.
3. Ở thẻ **Mã QR tại bàn**, tạo mã cho từng bàn. Có thể in tem ra máy in hóa đơn của chi nhánh, hoặc chỉ hiện mã để lưu ảnh hay sao chép đường dẫn. Đường dẫn chỉ hiện một lần. **Tạo mã mới** làm tem cũ, và mọi điện thoại đã quét tem cũ, ngừng dùng được ngay. Dùng khi tem bị chụp lại, hoặc khi cần in lại.
4. Ở trang **Thực đơn**, bỏ chọn **Khách được gọi món này qua QR tại bàn** với món không bán qua QR.

Khách quét mã, xem thực đơn và giá, chọn món, tùy chọn, ghi chú rồi gửi đơn; khách cũng gọi được phục vụ hoặc tính tiền. Bàn chưa mở thì khách chỉ xem thực đơn. Đơn chờ duyệt hiện ở khay **Đơn từ QR** trên màn bán (`apps/pos`) và nút **Đơn từ QR** trên máy phục vụ; duyệt thì món vào đơn của bàn và báo bếp, từ chối thì cần lý do và khách đọc được lý do. Người duyệt cần quyền **Duyệt / từ chối món khách gọi qua QR**. Khách không trả tiền qua QR: thu ngân vẫn thu như đơn bàn.

## 8. Dữ liệu thử trên máy phát triển

Seed demo tạo một nhà hàng mẫu cho cửa hàng mặc định:

- chi nhánh `demo-nha-hang`, ngành Nhà hàng;
- quầy "Quầy 1" ghi đơn bàn;
- 2 khu với 12 bàn;
- 30 món, có tùy chọn;
- hai khu Bếp và Bar;
- một máy in ESC/POS LAN giả lập ở `127.0.0.1:9100`.

Lệnh chạy, chỉ ở môi trường development:

```bash
POS_FNB_DEMO=1 pnpm spree seed
```

Máy in demo gắn với một trạm in giữ chỗ chưa ai ghép. Muốn in thật, ghép một trạm in, rồi chọn trạm đó cho máy in ở tab **In ấn**. Seed bỏ qua cửa hàng đã có chi nhánh `demo-nha-hang`. Nội dung seed ở [`server/db/seeds/pos_fnb_demo.rb`](../../server/db/seeds/pos_fnb_demo.rb).

Chạy ứng dụng, sinh client và in qua LAN / Bluetooth / Sunmi: xem [README của ParkViet Nhân viên](../../apps/pos-staff/README.md). Cài server LAN: xem [Triển khai POS trên LAN hoặc VPS](../deploy/pos-lan-vps.md).
