# UAT truy xuất: hàng cân, quy đổi, serial, lô

Mẫu cho merchant và kỹ thuật điền khi thử tại cửa hàng. Chưa có kết quả nào bên dưới. Kiểm thử tự động tương ứng: `apps/pos/e2e/advanced-goods.spec.ts` (mock và API dev), backend `spec/integration/spree/pos/traceability_spec.rb`. UAT này kiểm trên hàng và thiết bị thật, không thay test tự động.

## 1. Thông tin

| Mục | Giá trị |
|---|---|
| Ngày, chi nhánh, quầy | |
| Người thử / người hỗ trợ | |
| Phiên bản POS (commit), phiên bản API | |
| Máy cân / máy in tem (hãng, model) | |
| Máy quét | |

## 2. Cấu hình trước khi thử

| # | Việc | Người làm | Xong |
|---|---|---|---|
| C1 | Bật cấp cửa hàng `traceability`, `returns` (Cài đặt → Chức năng chi nhánh), ghi lý do | Quản trị | |
| C2 | Mẫu tem cân của chi nhánh (prefix, độ dài mã, đơn vị g, số lẻ, dung sai giá) khớp cấu hình máy cân | Quản trị + kỹ thuật | |
| C3 | Mã tem (label code) cho từng SKU cân; đơn vị bán kg, cơ sở g | Quản trị | |
| C4 | SKU quy đổi (ví dụ thùng 24 chai): tỷ lệ, giá thùng chia hết cho 24 hay không | Quản trị | |
| C5 | SKU serial: đếm serial thực tế, nhập tồn đầu kỳ khớp số tồn hệ thống | Kho | |
| C6 | SKU lô: đếm theo lô/HSD, nhập tồn đầu kỳ khớp | Kho | |

## 3. Kịch bản

| # | Kịch bản | Mong đợi | Kết quả |
|---|---|---|---|
| T1 | Cân 2 gói cùng SKU, in 2 tem, quét cả hai | 2 dòng riêng, mỗi dòng đúng khối lượng và tiền theo tem | |
| T2 | Quét lại đúng tem đã quét (cùng gói) | Dòng mới chỉ khi là lần cân mới; hỏi lại nhân viên nếu nghi trùng | |
| T3 | Tem sai số kiểm / giá lệch quá dung sai | Từ chối, không thêm dòng, thông báo tiếng Việt | |
| T4 | Bán thùng 24 chai và lẻ 3 chai | Đúng số chai cơ sở, giá, hóa đơn ghi quy đổi | |
| T5 | Bán 2 serial, quét trùng 1 serial | Từ chối serial trùng; hóa đơn in đúng serial | |
| T6 | Serial đã bán / ở chi nhánh khác | Từ chối, không thu tiền | |
| T7 | Bán 3 hộp có 2 lô (lô gần hạn còn 2) | FEFO: 2 hộp lô gần hạn + 1 hộp lô sau; hóa đơn in lô/HSD | |
| T8 | Lô hết hạn / đang cách ly | Không được chọn bán | |
| T9 | Giao hàng tại quầy hai lần (bấm lại) | Tồn chỉ trừ một lần | |
| T10 | Trả 200 g của gói thứ nhất | Trả đúng dòng gói 1, giá trị theo đơn giá gói 1 | |
| T11 | Trả 1 serial | Serial về kho, bán lại được; không trả lại được lần hai | |
| T12 | Trả 1 hộp lô đã hết hạn | Nhận về nhưng cách ly, không bán lại | |
| T13 | Tra cứu thu hồi theo lô | Liệt kê đơn/khách đã mua lô đó, chỉ trong quyền được cấp | |
| T14 | Nhập kho, chuyển kho, kiểm kê hàng serial/lô | Tồn theo lô/serial khớp tổng tồn | |
| T15 | Tắt `traceability` ở chi nhánh | Không nhập tồn đầu/đổi kiểu theo dõi được; bán, trả, nhập, chuyển vẫn chạy | |

## 4. Đối soát sau thử

| Mục | Hệ thống | Đếm thực tế | Lệch | Ghi chú |
|---|---|---|---|---|
| Tồn từng serial | | | | |
| Tồn từng lô | | | | |
| Tổng khối lượng hàng cân đã bán/trả | | | | |
| Tiền bán/trả theo hóa đơn | | | | |

## 5. Kết luận

| Mục | Ghi chú |
|---|---|
| SKU đủ điều kiện bán (danh sách) | |
| SKU chưa đủ điều kiện / lý do | |
| Lỗi phát hiện | |
| Chữ ký merchant / kỹ thuật / ngày | |
