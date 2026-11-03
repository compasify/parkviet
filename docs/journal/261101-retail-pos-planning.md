# Nhật ký kỹ thuật — Lập kế hoạch retail POS

**Ngày:** 01/11/2026  
**Trạng thái:** Kế hoạch đã sửa theo các corrections được duyệt sau review; đang chờ cho phép triển khai, chưa triển khai.

## Phạm vi đã xác nhận

Người dùng đồng ý lập kế hoạch triển khai đầy đủ, **không phải cho phép triển khai**. POS cần hỗ trợ nhiều chi nhánh, mỗi chi nhánh nhiều quầy, nhiều tab đơn hàng đồng thời; thêm khách hàng, giảm giá và chọn phương thức thanh toán. Mỗi quầy có một ngăn kéo tiền.

Thanh toán bao gồm tiền mặt, chuyển khoản xác nhận thủ công, thẻ qua thiết bị ngoài, chia nhiều phương thức và bán chịu theo cấu hình của quản lý. Hàng cân, đơn vị và quy đổi, serial/IMEI, lô và hạn sử dụng đều là yêu cầu bắt buộc, không phải phần tùy chọn để bỏ qua.

## Tài liệu và quyết định

- Thư mục kế hoạch: `plans/261101-1649-retail-pos-multi-store-multi-order/`.
- Đặc tả chuẩn để đối chiếu: `plans/261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md`.
- Đã có báo cáo nghiên cứu VietQR; tích hợp nhà cung cấp xác nhận thanh toán tự động không phải điều kiện chặn kế hoạch.

## Các cổng rủi ro phải giải quyết trước khi triển khai

- Chốt cách biểu diễn hàng cân/quy đổi trên lõi số lượng nguyên, bảo toàn độ chính xác giá và tiền.
- Ràng buộc định tuyến kho theo chi nhánh; không âm thầm lấy hàng từ chi nhánh khác.
- Tách rõ thanh toán đang chờ với đã thanh toán: `pending != paid`.
- Bảo đảm truy xuất serial/IMEI, lô, hạn sử dụng ở mọi luồng ghi tồn kho, không chỉ màn hình POS.
- Làm rõ công nợ khi bán chịu, trả hàng và hoàn tiền để tránh sai số dư hoặc hoàn trùng.

## Giới hạn phiên làm việc

Phiên này chỉ lập kế hoạch và ghi nhật ký; không thay đổi mã ứng dụng, không deploy, không chạy migration. Chưa chạy kiểm thử runtime, nên chưa có bằng chứng xác nhận hệ thống hoạt động. Bước tiếp theo là con người duyệt kế hoạch và các cổng rủi ro trước khi cho phép triển khai.

## Cập nhật 03/11/2026 — Hoàn thiện kế hoạch sau review

Người dùng yêu cầu tiếp tục hoàn thiện kế hoạch và đã duyệt áp dụng toàn bộ corrections, **chưa duyệt implementation**. Ngày tạo nhật ký vẫn là 01/11/2026; nội dung phía trên được giữ làm lịch sử phiên trước.

### Các corrections đã đồng bộ

Canonical specs và phase docs của kế hoạch đã được đồng bộ cho 8 điểm:

1. Tiền thừa hoặc đến trễ được xử lý bằng allocate/payout resolution cho `ReceivedFunds` chưa allocated; không tạo Return/Refund giả.
2. Bảo toàn parent `ReceivedFunds` xuyên các trạng thái child refund, reserved, unknown, reversal và reallocation.
3. Tiền mặt đã nhận nhưng xác nhận muộn phải reconcile variance/custody của ca gốc đã đóng; không đếm trùng vào opening/safe của ca S2.
4. Giữ identity `SaleLine` bất biến; ánh xạ lossless các measured packages cùng variant.
5. Tính return entitlement/residual lũy kế: 5 × 0,4 VND, trả 1 + 1 + 3 phải cấp đủ tổng 2 VND.
6. Advanced-goods work packages xuyên phases 1/5/6/8 là bắt buộc.
7. Phases 6–7 chỉ chạy sandbox; pilot thật cần approval riêng.
8. Display phải giới hạn độ cũ của dữ liệu cục bộ, kiểm tra ACK đúng generation hiện tại và có các ca offline/sleep.

### Bằng chứng và giới hạn

- `plans/261101-1649-retail-pos-multi-store-multi-order/plan.md` có 11 phases, tất cả pending; `ck plan status` báo 0/11 completed, 11 pending.
- `ck plan validate ... --strict` đã chạy thành công sau correction: 0 errors, 0 warnings. Đã đọc lại index, toàn bộ 11 phase và canonical specs: không còn mâu thuẫn tài liệu chưa xử lý trong sweep này. Kiểm tra cơ học 18 Markdown docs/57 local links/phase schemas và dependencies/307 proposed Create paths có owner duy nhất trả 0 errors.
- Test matrix gồm 44 cases (A6/W9/F21/I8) là requirements, **không phải kết quả kiểm thử runtime**.
- Chỉ có tài liệu, chưa có POS app/prototype. Runtime compatibility, goods và payment spikes là các gates của phase 1, chưa chạy.
- Thiết bị, precision và các policy về credit/discount/refund/variance vẫn cần cấu hình. Bước tiếp theo là bàn giao plan để review và xin authorization riêng trước khi triển khai; source/runtime proofs vẫn thuộc phase 1 chưa chạy.
- `plans/` đang bị `.gitignore` ignore; không sửa ignore hoặc force-add. Phiên này không code/install/eject/migrate/deploy, không git stage/commit.
