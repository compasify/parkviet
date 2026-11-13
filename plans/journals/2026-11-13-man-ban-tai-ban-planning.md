# 13/11/2026: Lập plan màn bán riêng cho phục vụ tại bàn

## Bối cảnh

Màn bán `apps/pos` dùng chung bố cục ba cột cho bán lẻ và F&B, nên chi nhánh có bàn dùng như bán lẻ. Sau research layout và mockup 8 màn, người dùng chọn làm trước phần bán tại bàn (mockup màn 1–4).

## Phát hiện khi scout

- Dữ liệu bảng bàn (`BoardTable`) đã đủ cho ô bàn mới: thời gian ngồi, số khách, tạm tính, món chưa gửi, gọi thanh toán, tạm tính đã in, đặt trước.
- Dòng món không biết nó thuộc lượt gửi bếp nào. Liên kết có sẵn qua `KitchenTicketItem.sale_line_id` → `KitchenTicket.send_key` → `KitchenSend.send_key`, nên chỉ cần tính thêm một trường, không cần bảng mới.
- `WorkspaceTabs` dài 1853 dòng và trộn trạng thái, lệnh với bố cục. Tách hook trước là điều kiện để hai bố cục dùng chung logic mà không sao chép.
- Tài liệu chủ quán ghi quán ăn có bàn mở thẳng lưới thực đơn; bố cục mới sẽ đổi điều này nếu người dùng đồng ý.

## Quyết định

- Bố cục bàn bật theo module `fnb.tables` và bề mặt hồ sơ, trừ `tab_list` và `resource_board` (bar, karaoke làm sau).
- Dùng lại `PaymentPanel`, `TableOrderBar`, `VoidItemDialog`, `PrebillDialog`; chỉ bố cục là mới.

Plan: [261113-1708-pos-ban-tai-ban-layout](../261113-1708-pos-ban-tai-ban-layout/plan.md).
