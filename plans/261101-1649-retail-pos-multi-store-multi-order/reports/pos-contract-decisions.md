# Hợp đồng POS — bản dự thảo phase 1

Tài liệu này là hợp đồng đề xuất, **không khẳng định endpoint đã tồn tại hoặc gate đã đạt**. Bằng chứng thực nghiệm và giới hạn nằm tại `runtime-spike-results.md`.

## Ranh giới và quyền

- Tất cả ghi POS chỉ qua endpoint staff chuyên biệt, kiểm JWT, store và permission tại server; không tin store, marker walk-in, giá, trạng thái thanh toán hoặc tồn do client khai báo. Mỗi hành động tài chính cần permission riêng và audit actor; không cấp `write_orders` tổng quát cho thu ngân để lách wrapper.
- `Pos::CreateWalkInDraft` hiện chỉ là service nội bộ; route, đồng bộ thu hồi quyền và kiểm bypass chưa được chứng minh. Marker walk-in không được cấp cho order có sẵn do client chỉ định.
- Core Admin API có thể là writer độc lập. Không coi khóa chỉ trong POS là bảo vệ toàn hệ thống; phải kiểm website, admin, imports, điều chỉnh và chuyển kho khi định nghĩa vùng khóa.

## Tồn kho và pickup — gate đóng

### Quyết định nghiệp vụ đã xác nhận 04/11/2026

- **Bán trực tiếp tại quầy, hàng thực tế đã có trước mặt:** không chặn thanh toán chỉ vì tồn hệ thống không đủ; cảnh báo thu ngân và cho tiếp tục. Không yêu cầu quản lý duyệt chỉ vì cảnh báo này. Không bắt buộc giữ đủ tồn trước thu tiền cho đơn loại này. Không suy diễn hàng có thật từ số liệu hay từ một đơn giao sau.
- Tồn được đọc theo chi nhánh/kho được phép; không âm thầm fallback kho khác. Khi không đọc được tồn, hiển thị **không xác định**, cảnh báo và cho tiếp tục theo policy tại quầy, đồng bộ/đối soát tồn sau; không báo đủ hay giả đã kiểm. POS cần mạng để bắt đầu bán: tình huống không đọc được tồn không cấp phép bắt đầu giao dịch offline. Trước vận hành cần chứng minh lưu dấu, recovery và stock effects.
- Mỗi cảnh báo/tiếp tục và chênh lệch phải có dấu vết phục vụ tracking stock/đối soát: đơn, dòng/variant, chi nhánh/kho, lượng bán, số liệu và thời điểm kiểm tra, người thực hiện; không ghi đè dữ liệu tồn để che sai lệch. Số tồn là snapshot có thể đổi khi đơn online đến đồng thời, không phải cam kết có hàng.
- Xung đột với đơn online được chuyển cho quy trình tracking stock: phát hiện, đối soát, người phụ trách xử lý và lưu kết quả; có thể nhập bù theo chứng từ thực tế hoặc xử lý đơn online, không tự giả định hàng đã nhập. Giao sau không thuộc POS siêu thị cơ bản; đồng bộ đơn giao sau cho ngành ăn uống là nhu cầu tương lai chưa thiết kế. Không tự áp policy tại quầy cho đơn đó.
- Đây là **quyết định nghiệp vụ đã chốt, không phải proof implementation**. Trước mở bán thật cần chứng minh cảnh báo và dấu vết bền vững, đúng kho, tác động tồn chính xác một lần, retry/recovery, đối soát và race POS/online. Thanh toán và fulfillment vẫn đóng đến khi các gate liên quan đạt và được phép.

### Seam kỹ thuật còn phải qualify

- Tài liệu Spree cài trong dự án mô tả placement tăng allocation, fulfillment mới giảm `count_on_hand`; over-allocation có thể xuất hiện khi allocation vượt on-hand. Không giả định tồn âm, tự bật backorder, tắt tracking, force fulfillment hay sửa trực tiếp counter là cách đáp ứng policy. Cần test trên runtime và cấu hình thực tế, xác định cách lưu giao dịch khi thiếu tồn và theo dõi/đối soát đơn online mà không tạo stock effect kép.
- Các writer vẫn có thể chạy đồng thời: đo race và ghi nhận kết quả, không tuyên bố không oversell. Không giữ khóa DB qua lệnh gọi payment provider; sau timeout cần trạng thái phục hồi và đối soát, không lặp thu tiền mù.
- Không dùng `preferred_stock_location` làm cam kết strict branch. Không dùng `Reserve.call(order:)` để bảo vệ POS: đã deprecated và thử nghiệm cart/order cho thấy giữ trùng. Không trực tiếp dùng core staff draft completion như bảo đảm chống oversell.
- Pickup thử nghiệm dựng sẵn fulfillment chỉ chứng minh đường hẹp place → fulfill → retry; chưa chứng minh routing, tranh chấp, mọi writer hoặc trả hàng.

## Tiền — gate đóng

### Quyết định phương thức và phục hồi 04/11/2026

- Phạm vi ban đầu gồm **tiền mặt** và **chuyển khoản cá nhân do nhân viên kiểm tra, xác nhận thủ công**. Tạo/hiển thị QR và tự động xác nhận theo QR để nghiệp vụ riêng sau khi chức năng POS hoàn thành; không giả provider/ngân hàng tự xác nhận.
- Sau khi nhân viên xác nhận đã thực nhận, hệ thống phải lưu evidence và xử lý hoàn tất đơn độc lập. Nếu server đã ghi nhận tiền nhưng hoàn tất đơn lỗi, hiển thị `đã ghi nhận tiền — đơn chưa hoàn tất`, giữ bằng chứng và cho khôi phục với cùng định danh, không yêu cầu khách trả lại hay ghi tiền lần hai. Hoàn tiền phải là hành động riêng có phân quyền, xác nhận thực chi và audit.
- Khi chưa biết server đã nhận lệnh xác nhận hay chưa, hiển thị `chưa xác định — cần kiểm tra`, không hiển thị đã đồng bộ, không tạo lệnh thu mới. Tra cứu authoritative server theo mã thao tác; chỉ gửi lại cùng key, cùng payload khi contract server cho phép replay an toàn; nếu thiếu, bị từ chối, hết retention, xung đột hoặc không thể chứng minh trạng thái thì giữ attention để đối soát có thẩm quyền, không đoán lệnh cũ thất bại.
- Có thể lưu **hàng đợi phục hồi cục bộ** bền qua reload/đóng browser và đồng bộ khi mạng trở lại, nhưng đây chỉ là lời khai/intent chưa được server xác nhận, không phải sổ tiền hoặc chứng cứ ngân hàng. `sessionStorage` intent 12 giờ hiện tại chỉ cho workspace và không phù hợp làm financial ledger. Không xóa bản chưa giải quyết theo TTL, logout hay đổi tài khoản; chỉ xóa sau server xác nhận bền vững hoặc quy trình giải quyết có audit. Browser storage có thể bị xóa/evict, máy hỏng hoặc bị sửa; phải có quy trình dự phòng thủ công và không hứa chống mất dữ liệu tuyệt đối.
- Thiết kế implementation cần lưu tối thiểu operation ID/key, store/branch/register/workspace, staff gốc, snapshot revision/hash, loại thu, số tiền/currency, thời điểm nhận và evidence tối thiểu đã được duyệt; không lưu access/refresh token, thông tin thẻ, mật khẩu, số tài khoản đầy đủ hoặc ảnh nhạy cảm. Trạng thái đồng bộ lại phải kiểm identity, quyền và context trên server; quyền bị thu hồi, đổi staff/store hoặc dữ liệu không khớp thì không gửi dưới danh tính khác, giữ để manager xử lý. Cross-tab/reload phải tránh gửi đúp; server vẫn là ranh giới xác thực và idempotency.
- POS cần mạng để bắt đầu bán. Nếu mất mạng giữa giao dịch hoặc sau khi nhận tiền, giữ thông tin phục hồi và xử lý/đồng bộ lại khi có mạng; không tự thu tiền lần hai hoặc khẳng định server đã lưu. Khách đã cầm hàng; câu trả lời chưa xác nhận rõ có cho khách rời quầy khi tiền/đơn chưa được server xác nhận hay cần ai duyệt, nên chưa mặc định chính sách giao hàng ngoại lệ. Chưa bật thanh toán, giao hàng hoặc giao dịch tiền thật; cần server financial ledger, API tra cứu/replay, quyền, thử nghiệm sự cố và go/no-go riêng.

- Tiền và giá biểu diễn decimal chính xác theo đơn vị tiền tệ; không dùng float JavaScript làm nguồn sự thật, không tự giả định VND luôn làm tròn theo một quy tắc chưa được phê duyệt.
- `order.placed`, payment `pending`/`processing` hoặc số tiền khách dự kiến đưa không chứng minh đã nhận tiền. Chỉ receipt/settlement đã được xác thực, gắn giao dịch và đối soát phù hợp mới cho phép hiển thị đã thu; tách khoản thực thu, áp vào đơn, tiền thừa và nghĩa vụ phải trả.
- Mọi lệnh có tác dụng tài chính cần idempotency key gắn actor/store/operation/request hash; retry cùng key và cùng nội dung trả kết quả đã ghi, cùng key khác nội dung phải xung đột. Timeout không chứng minh thất bại; trạng thái `unknown` cần tra soát và không thu lại tự động.
- Split tender, công nợ, hoàn tiền, chuyển tiền và recovery chưa có proof end-to-end; không bật chỉ vì core có payment hay `payment_pending`.

## Trạng thái mạng trên header — quyết định 06/11/2026

- Người dùng chốt: trạng thái mạng hiển thị bằng icon trên thanh header của POS. Shell hiện đã có chỉ báo kết nối (`apps/pos/src/components/pos-shell.tsx`, `connection-status`), dựa trên sự kiện online/offline của browser và lỗi request; khi mất kết nối, thao tác ghi bị khóa và hiện thông báo.
- Icon chỉ báo kết nối, không phải bằng chứng server đã nhận lệnh. Trạng thái `chưa xác định — cần kiểm tra` và hàng đợi phục hồi tiền vẫn theo mục Tiền ở trên, triển khai tại phase 6.

## Phiên nhân viên — quyết định 06/11/2026

- Logout thu hồi refresh token và xóa access token trong memory. Access JWT đã cấp vẫn hợp lệ tới khi hết hạn (`Spree::Api::Config[:jwt_expiration]`, mặc định 1 giờ); người dùng chấp nhận rủi ro này, không thêm denylist.
- Hạ tầng triển khai (same-origin hay khác domain) chưa chốt; CORS và SameSite cookie quyết định tại phase 11.

## Dự thảo HTTP và đồng bộ

- ID ngoài API phải là prefixed ID. Phản hồi chứa revision server; ghi từ client cung cấp revision đã đọc. Mismatch trả `409`, trạng thái đang xử lý bất đồng bộ trả `202` kèm định danh theo dõi, dữ liệu/nghiệp vụ không hợp lệ trả `422`. Auth và permission dùng `401`/`403`; không tiết lộ tài nguyên store khác.
- Các mã trên là contract dự kiến, chưa xác minh endpoint, mô hình revision, hay concurrency; cần request specs cho replay, khác payload, đổi quyền, store chéo và failure ở từng bước trước khi nối UI.

## Điều kiện thoát phase

Phase 1 theo phạm vi đã điều chỉnh đóng theo [checklist mới](../phase-01-contracts-and-ux-validation.md#success-criteria); các proof cảnh báo/đối soát, đúng branch, sandbox finance/recovery và UX thực tiếp tục chặn capability tại phase phụ trách, không chuyển thành pass khi phase 1 đóng. Những phần không khả thi theo core cần ADR và gate tương ứng; không tự coi proof hẹp là triển khai xong.
