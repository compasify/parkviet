# Quyết định walk-in không email — 04/11/2026

## Quyết định

Người dùng chọn hỗ trợ khách lẻ không email ngay; cho phép thay đổi backend giới hạn POS, không tạo email giả và không tắt validation website. Spree 6.0.2 yêu cầu email cả khi hoàn tất cart và khi place staff draft. POS chọn hướng staff draft; cart checkout website không bị sửa.

## Seam đã kiểm thử

`Pos::WalkInOrder` là marker nội bộ một-một với order, không dựa vào `metadata` do client ghi. `Spree::OrderDecorator#require_email` giữ hành vi core trừ order đã có marker, không customer, không email và không bật marketing hoặc tạo tài khoản. Với email được nhập, validation định dạng và độ dài của core vẫn chạy. Marker bị xóa cùng draft. Đã thử core completion bằng payment method test; không chứng minh thu tiền thật, pickup hoặc concurrent stock.

## Chưa được phép dùng từ POS

- Chưa có endpoint cấp marker. Service nội bộ `Pos::CreateWalkInDraft` chỉ tạo draft mới và marker trong cùng transaction; kiểm `write_pos_orders` trên store và staff chưa bị vô hiệu hóa. Đã test quyền sai store, vô hiệu hóa, actor, rollback và quyền POS không ghi được qua core orders API. Endpoint tương lai vẫn cần xác thực JWT, kiểm request/CSRF, race revoke, và ngăn bypass trước khi nối UI.
- Không cấp `write_orders` rộng cho thu ngân chỉ để vượt gate; kiểm các đường Admin API khác và dùng permission POS riêng khi triển khai endpoint.
- Chưa kiểm chứng notification/email jobs khi không email, pickup/địa chỉ, payment recovery hoặc các hành vi xuất/đồng bộ. Không phát hành tính năng cho vận hành cho đến khi có proof.
- Decorator gọi private method của Spree 6.0.2; test regression là bắt buộc khi nâng Spree. Migration phải áp trước khi chạy code với đơn không email.
