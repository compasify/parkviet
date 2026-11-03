# Hợp đồng POS — bản dự thảo phase 1

Tài liệu này là hợp đồng đề xuất, **không khẳng định endpoint đã tồn tại hoặc gate đã đạt**. Bằng chứng thực nghiệm và giới hạn nằm tại `runtime-spike-results.md`.

## Ranh giới và quyền

- Tất cả ghi POS chỉ qua endpoint staff chuyên biệt, kiểm JWT, store và permission tại server; không tin store, marker walk-in, giá, trạng thái thanh toán hoặc tồn do client khai báo. Mỗi hành động tài chính cần permission riêng và audit actor; không cấp `write_orders` tổng quát cho thu ngân để lách wrapper.
- `Pos::CreateWalkInDraft` hiện chỉ là service nội bộ; route, đồng bộ thu hồi quyền và kiểm bypass chưa được chứng minh. Marker walk-in không được cấp cho order có sẵn do client chỉ định.
- Core Admin API có thể là writer độc lập. Không coi khóa chỉ trong POS là bảo vệ toàn hệ thống; phải kiểm website, admin, imports, điều chỉnh và chuyển kho khi định nghĩa vùng khóa.

## Tồn kho và pickup — gate đóng

- Một giao dịch POS chỉ xuất kho chi nhánh/quầy được chọn và được phép; nếu không đủ tồn thì từ chối, không tự chuyển sang kho khác hoặc backorder, trừ khi chính sách tương lai được duyệt riêng.
- Quyết định còn ở mức thiết kế: kiểm số lượng khả dụng và giữ/allocate phải có khóa phù hợp giữa các writer, đọc lại sau khóa và bảo đảm atomic với thay đổi tồn. Không giữ khóa DB qua lệnh gọi payment provider; sau timeout, phải có trạng thái phục hồi và đối soát, không lặp thu tiền mù.
- Không dùng `preferred_stock_location` làm cam kết strict branch. Không dùng `Reserve.call(order:)` để bảo vệ POS: đã deprecated và thử nghiệm cart/order cho thấy giữ trùng. Không trực tiếp dùng core staff draft completion như bảo đảm chống oversell.
- Pickup thử nghiệm dựng sẵn fulfillment chỉ chứng minh đường hẹp place → fulfill → retry; chưa chứng minh routing, tranh chấp, mọi writer hoặc trả hàng.

## Tiền — gate đóng

- Tiền và giá biểu diễn decimal chính xác theo đơn vị tiền tệ; không dùng float JavaScript làm nguồn sự thật, không tự giả định VND luôn làm tròn theo một quy tắc chưa được phê duyệt.
- `order.placed`, payment `pending`/`processing` hoặc số tiền khách dự kiến đưa không chứng minh đã nhận tiền. Chỉ receipt/settlement đã được xác thực, gắn giao dịch và đối soát phù hợp mới cho phép hiển thị đã thu; tách khoản thực thu, áp vào đơn, tiền thừa và nghĩa vụ phải trả.
- Mọi lệnh có tác dụng tài chính cần idempotency key gắn actor/store/operation/request hash; retry cùng key và cùng nội dung trả kết quả đã ghi, cùng key khác nội dung phải xung đột. Timeout không chứng minh thất bại; trạng thái `unknown` cần tra soát và không thu lại tự động.
- Split tender, công nợ, hoàn tiền, chuyển tiền và recovery chưa có proof end-to-end; không bật chỉ vì core có payment hay `payment_pending`.

## Dự thảo HTTP và đồng bộ

- ID ngoài API phải là prefixed ID. Phản hồi chứa revision server; ghi từ client cung cấp revision đã đọc. Mismatch trả `409`, trạng thái đang xử lý bất đồng bộ trả `202` kèm định danh theo dõi, dữ liệu/nghiệp vụ không hợp lệ trả `422`. Auth và permission dùng `401`/`403`; không tiết lộ tài nguyên store khác.
- Các mã trên là contract dự kiến, chưa xác minh endpoint, mô hình revision, hay concurrency; cần request specs cho replay, khác payload, đổi quyền, store chéo và failure ở từng bước trước khi nối UI.

## Điều kiện thoát phase

Không đánh dấu phase 1 hoàn tất chỉ bằng suite xanh: cần evidence theo checklist phase, đặc biệt tranh chấp last-unit xuyên writer, strict branch, sandbox finance/recovery, UX đa đơn/responsive và quyết định của người vận hành. Những phần không khả thi theo core cần ADR được chấp nhận và gate capability tương ứng đóng; không tự coi proof hẹp là triển khai xong.
