# ADR 0001: Mở phạm vi POS sang F&B và giải trí

Ngày: 2026-11-10
Trạng thái: đã chấp nhận

## Bối cảnh

Đợt bán lẻ đa cửa hàng ghi ranh giới "Không thêm F&B" trong
`plans/261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md`.
Bản ghi đó đúng với đợt đó. Sáu ngành F&B và giải trí (quán ăn, cafe / trà sữa,
karaoke / bida, bar / pub / club, căng tin / trạm dừng, nhà hàng) nay được làm
theo plan `plans/261109-1812-pos-fnb-giai-tri`.

## Quyết định

Giữ nguyên quyết định D1–D10 của plan đó:

1. Mở ngành theo năm đợt F1–F5, không đảo thứ tự research.
2. Thu ngân và màn khách là web. QR order là web, không cần cài app.
3. Phục vụ, bếp, chạy bàn, kiosk, chủ quán và trạm in nằm trong một app Flutter nhiều chế độ.
4. Server có hàng đợi in. Trạm in nhận job. Thu ngân web in bằng adapter trình duyệt. Không làm SDP / CloudPRNT.
5. Mỗi khách chạy server LAN tại quán hoặc VPS riêng. Việc cần internet đi qua hàng đợi gửi ra ngoài.
6. Bản đầu cần kết nối tới server. Hàng đợi offline phía thu ngân để đợt F5. Luật nghiệp vụ chỉ chạy ở server.
7. Tiền chỉ đi qua lõi Workspace → Order → tender → ReceivedFunds. Kiosk là ngoại lệ có kiểm soát.
8. `business_date` và giờ cắt ngày kinh doanh là lõi. Thuế suất theo món là cấu hình `TaxCategory` / `TaxRate`.
9. Code chỉ kiểm tra module, không kiểm tra tên ngành. Module F&B không tự bật cờ rủi ro.
10. Trừ nguyên liệu (`fnb.recipes`) thuộc đợt F1.

Chi nhánh bán lẻ đang chạy giữ nguyên hành vi: `service_mode` mặc định `counter`, dòng bán vẫn là `ordinary`, `measured` hoặc `tracked`.

## Hệ quả

- Câu "Không thêm F&B" trong spec bán lẻ là lịch sử của đợt đó, không phải ranh giới của sản phẩm hiện tại. Spec đó chỉ thêm một dòng trỏ về ADR này.
- Các trường mọi phase sau dùng (`service_mode`, kiểu dòng mở rộng, `business_date`, thuế theo món) nằm ở lõi từ phase 1.
- Mức thuế 8% hết hạn 31/12/2026 và mức 10% từ 01/01/2027 là dữ liệu, không phải nhánh trong code.
