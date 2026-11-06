# Phase 1 — Nhật ký kiểm chứng runtime

> **Cập nhật policy 04/11/2026:** Kết luận lịch sử yêu cầu chặn hoặc giữ đủ tồn trước thu cho mọi đơn POS đã được thay bằng policy bán tại quầy: cảnh báo và cho tiếp tục khi hàng thực tế có tại quầy, đối soát lệch/xung đột online qua tracking stock. Các số liệu spike bên dưới vẫn giữ nguyên; không phải proof giải pháp mới. Xem [quyết định và gate](./pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng).

## Trạng thái

**Đang thực hiện; đã chạy một phần spike backend.** Người dùng yêu cầu POS cơ bản theo Spree, ít sửa backend; tách gói có plan riêng. Không có phê duyệt chạy giao dịch thật hoặc deploy.

## Checkpoint phase 2 — shell ban đầu

- Phase 1 và 2 đều `in-progress`; đã tạo `apps/pos` độc lập, chưa chỉnh root workspace hay backend cho shell. Có màn hình đăng nhập staff dùng Admin SDK, lấy identity bằng `me.get()`, access token chỉ trong instance ở bộ nhớ và xóa instance cục bộ trước logout. Giao diện ghi rõ chưa tạo đơn, kiểm tra tồn hoặc thu tiền.
- `pnpm build` thành công; `pnpm test` chạy 3 unit tests mock SDK thành công. Đây không phải kiểm chứng đăng nhập thật, revoke thật, CORS/cookie, đa tab, responsive hay authorization. Chưa có refresh/session recovery, POS context, router/query, lint/e2e hoặc các gate còn lại; không đánh dấu phase 2 hoàn tất.
- Khi login thành công nhưng lấy identity thất bại, access client bị bỏ; cookie refresh có thể vẫn tồn tại. Khi logout lỗi mạng chỉ khóa phiên trong tab, không chứng minh revoke server. Giao diện thông báo giới hạn này; chưa sử dụng cookie để tự phục hồi phiên.

## Kết quả môi trường

- Trước eject `docker-compose.yml` dùng image dựng sẵn, không mount `./server:/rails`; các thay đổi backend local không có tác dụng.
- Đã chạy `pnpm spree eject`; CLI ghi cấu hình development vào `docker-compose.yml` có mount `./server:/rails`, sau đó **thoát lỗi**: `spawn docker ENOENT` tại bước `docker compose up -d --wait postgres`.
- `command -v docker` không tìm thấy executable; `/usr/local/bin/docker` là symlink tới `/Applications/OrbStack.app/Contents/MacOS/xbin/docker`, nhưng `/Applications/OrbStack.app` không tồn tại. `/Applications/Docker.app` cũng không tồn tại ở đường dẫn này.
- Compose đã bị thay đổi một phần theo lệnh được duyệt. Không có bằng chứng database đã được tạo/seed, app image đã build hay stack đã khởi động; không tuyên bố eject thành công. Không reset, xóa hoặc cố khôi phục database/compose.
- `ck plan check 1 --start` đánh dấu phase 1 `in-progress`; không có phase nào completed.
- Static inspection: `server/config/database.yml` mặc định development `spree_development`, test `spree_test`; `server/spec/rails_helper.rb` ép `RAILS_ENV=test` trước boot. Đây chỉ là source configuration, **không** chứng minh container, kết nối, schema test hay data isolation đã chạy đúng.
- Sau khi cài OrbStack, `docker version` xác nhận client/server 29.8.2; `docker ps` chưa có container chạy. `.env` không khai báo `DATABASE_URL`, `DATABASE_HOST`, `DATABASE_USERNAME` hoặc `DATABASE_PORT`; vẫn cần xác nhận môi trường thực bên trong container trước test. CLI phiên bản cài đặt dùng `spree test` (alias `rspec`) và chạy `db:create` với `RAILS_ENV=test` trước RSpec.
- `pnpm spree exec` đã khởi động PostgreSQL và Mailpit rồi thất bại ở bước build image web, trước khi chạy lệnh kiểm tra môi trường. `server/Gemfile.lock` hiện có `PATH ../spree/spree` từ cấu hình native; Dockerfile build chỉ copy Gemfile/lock, không có `SPREE_PATH` và source local trong build context, nên Bundler frozen phát hiện khác nguồn gem và dừng. Không sửa lockfile có sẵn, chưa tạo test DB hay chạy RSpec; chưa xác minh `DATABASE_URL` bên trong container.
- Người dùng sau đó đã đổi env và bundle; `pnpm spree build` thành công với Spree RubyGems 6.0.2 (khác source local 6.0.1 trước đây). Build cảnh báo ba migration Spree thiếu. Trước Rails boot, one-off container có `DATABASE_URL` vắng, `DATABASE_HOST=postgres`, `DATABASE_NAME`, `DATABASE_NAME_TEST`, `DATABASE_PORT`, `SPREE_PATH` không đặt. Tuy nhiên `server/Gemfile` nạp thêm `server/.env`: test thực tế kết nối `parkviet_v2_test`, không phải `spree_test`. Query trước đó chỉ chứng minh hai tên mặc định không tồn tại, **không chứng minh test DB thực tế chưa tồn tại**. `pnpm spree test spec/models/spree/product_spec.rb`: 1 example, 0 failures. Không chủ động reset hay seed DB; Rails test helper có thể tự chuẩn bị schema test.
- `runtime_contract_spec.rb` lượt đầu: 3 examples, 1 failure do hardcode sai tên test DB; sau khi sửa so sánh cấu hình test với development, chạy lại 3 examples, 0 failures. Đây không phải bằng chứng preflight an toàn trước khi test helper chạy. Runtime schema `spree_line_items.quantity` là integer, `price` decimal(19,4), `spree_prices.amount` decimal(19,4); chưa chứng minh tính toán/rounding hàng cân.
- `pnpm spree test spec/integration/spree/pos`: 4 examples, 0 failures. Spike `sale_line_identity_contract_spec.rb` chạy workflow thực hai lần trên cùng variant, giá thủ công 0.4/0.7 và metadata lot-a/lot-b: hai lần trả cùng line ID, số lượng thành 2, giá và metadata bị ghi đè bởi lần thêm sau. Đây là bằng chứng core upsert hiện tại không giữ được hai gói độc lập, **không** phải proof SaleLine lossless; cần thiết kế và chứng minh seam mới trước phase liên quan. Test không chứng minh FEFO, thuế, tồn kho hay trả hàng.
- Theo quyết định người dùng, tách gói chuyển sang [plan riêng](../../261103-pos-goi-hang-truy-xuat/plan.md), không chặn POS cơ bản dựa trên Spree; không hỗ trợ hoặc hứa hỗ trợ tách gói trong bản cơ bản.
- Người dùng cho phép migrate: `pnpm spree migrate` tự tạo database development `parkviet_v2` trong PostgreSQL OrbStack rồi áp 3 migration Spree; `pnpm spree migrate:status` xác nhận cả ba `up`. CLI cũng ghi 3 file vào `server/db/migrate/` và cập nhật `server/db/schema.rb`. Không áp lên PostgreSQL native; không chạy reset hoặc seed. Trước chạy đã nói sẽ không tạo DB nhưng thực tế CLI tự tạo; ghi nhận sai sót này.
- Sau migration đã xác nhận database `parkviet_pos_spike_20261103` chưa tồn tại và tạo mới qua `pnpm spree exec` với `RAILS_ENV=test`, `DATABASE_NAME_TEST` cố định; test helper chuẩn bị schema trên database spike này, không dùng test DB trước đó. Chạy toàn bộ `spec/integration/spree/pos`: **13 examples, 0 failures**, seed 38676. Không có giao dịch ngân hàng thật; dùng factory/payment method test.
- `checkout_contract_spec.rb`: cart rỗng và cart đủ dữ liệu nhưng thiếu email đều bị chặn, không tạo order; cart đủ điều kiện được đặt và retry trả cùng order ID, duy nhất một order. Đơn nháp staff không email cũng không place được kể cả `payment_pending`, workflow ném `ActiveRecord::RecordInvalid` và order vẫn draft. Do đó khách lẻ không email chưa được hỗ trợ bằng core 6.0.2 nguyên bản; không được điền email giả hoặc tắt validation toàn hệ thống. Kết quả không chứng minh pickup, stock, thu tiền thật hay retry đa tiến trình.
- `permission_contract_spec.rb`: controller orders với role `read_orders` list được, bị 403 `write_orders` khi create; không có credential và JWT customer sai audience bị 401. Shared context stub `current_store`, JWT tự tạo; chưa chứng minh đăng nhập, revoke, cross-store hay mọi direct endpoint/bypass.
- Request spike `staff_auth_contract_spec.rb` sử dụng endpoint thật và staff factory trên database spike: login thành công trả access JWT và cookie HttpOnly, mật khẩu sai bị 401; refresh xoay cookie và từ chối cookie trước khi xoay; logout thu hồi refresh cookie. **Logout không thu hồi ngay access JWT đã cấp**: JWT đó vẫn gọi được `/admin/me` trong test sau logout. Vì vậy phải xóa token và khóa tab cục bộ, xử lý tab khác và không hứa revoke JWT tức thời; chưa chứng minh thời điểm hết hạn hay hành vi nhiều tab. Toàn bộ POS spike: **17 examples, 0 failures**, seed 52094.
- Checkpoint 04/11: request thật với JWT đăng nhập và `X-Spree-Store-Id` cho thấy staff chỉ có role store A bị 403 khi đọc đơn ở store B; staff có quyền đọc ở cả hai store vẫn nhận 404 khi lấy order A trong context B. Đây chỉ là proof cho orders endpoints đã thử, không phải mọi endpoint hoặc cache frontend.
- `location_contract_spec.rb`: coordinator xét cả hai stock location active thuộc store khi variant có stock level, kể cả A hết và B còn hàng. Chưa chứng minh lựa chọn fulfillment cuối cùng, pickup hay kiểm soát strict branch; không thể coi đây là proof POS không fallback.
- `discount_contract_spec.rb`: một coupon giảm flat USD 4 được tính lại sau khi xóa một trong hai dòng và phân bổ vào dòng còn lại. Không chứng minh manual POS discount, VND, thuế hoặc đồng thời.
- `payment_contract_spec.rb`: một payment test chỉ đủ nửa total không đặt được cart. Tạo payment checkout thường thứ hai làm payment checkout thường trước chuyển `invalid` do callback `Spree::Payment#invalidate_old_payments`; tổng valid còn một phần và cart không place. Không suy rộng sang store credit, session gateway hoặc payment đã completed. Split tender, tiền thực nhận và các tình huống lỗi vẫn chưa có proof; chỉ thử synthetic, không giao dịch thật.
- Toàn bộ spike hiện **23 examples, 0 failures**, seed 22348, qua `pnpm spree exec` với `RAILS_ENV=test DATABASE_NAME_TEST=parkviet_pos_spike_20261103`. Một kỳ vọng thử nghiệm ban đầu về hai checkout payment đã thất bại và được thay bằng characterization đúng với callback; không sửa core để ép qua test.
- Người dùng chọn hỗ trợ walk-in không email ngay, chấp nhận thay đổi BE scoped. Đã thêm bảng marker nội bộ `pos_walk_in_orders` với unique FK tới order và decorator chỉ miễn yêu cầu email cho order không customer, không email và có marker do server sở hữu; email được cung cấp vẫn phải hợp lệ. Không tin metadata. Chưa có API hoặc luồng được cấp quyền tạo marker, chưa thể sử dụng từ POS; đây không phải sản phẩm hoàn chỉnh. Migration `20261104000001` đã chạy trên database spike và development `parkviet_v2` qua CLI, `migrate:status` xác nhận `up`; `server/db/schema.rb` đã cập nhật. Không reset hoặc seed.
- Test thực dùng core order workflow và payment method giả: order có marker, không email/customer, có thể place với test payment đủ (và một test `payment_pending` chỉ để nghiên cứu, không phải phê duyệt bán công nợ). Order thường và metadata giả vẫn bị chặn, email sai vẫn bị chặn, customer-associated không được miễn; xóa draft xóa marker. Request Admin tạo order với metadata/attribute giả không tạo marker. Chưa chứng minh các endpoint khác, email/job callbacks, pickup hay an toàn tài chính sản xuất.
- Với preferred branch A hết và B có hàng, coordinator thử riêng vẫn phân bổ B khi truyền hai địa điểm; preferred không đủ là strict branch. Hai cart đặt giữ cùng món cuối theo thứ tự: lần đầu thành công, lần hai thất bại; chưa chứng minh race thực sự hoặc mọi writer.
- Lần chạy đầy đủ mới nhất: **33 examples, 0 failures**, seed 52004 trên database spike. Phase 1 vẫn in-progress; không bật bán/thu tiền hoặc tuyên bố đủ điều kiện vận hành.
- Đọc subscriber `order.placed` thấy newsletter/account creation dùng email khi opt-in; policy đã giữ yêu cầu email nếu `accept_marketing` hoặc `signup_for_an_account` bật, có test. Chưa chứng minh toàn bộ subscribers/extensions. Chạy lại toàn bộ: **34 examples, 0 failures**, seed 31220.
- Chạy toàn bộ suite ứng dụng `spec` trên database spike: **37 examples, 0 failures**, seed 36710 (không phải suite upstream Spree). Chưa có endpoint cấp marker hoặc test end-to-end POS, không coi phase 1 hoàn tất.
- Đã đăng ký quyền riêng `write_pos_orders` và thêm `Pos::CreateWalkInDraft` nội bộ: chỉ staff có quyền trên store tương ứng, không bị deactivate; tạo draft mới qua core và marker trong cùng transaction, không nhận order ID/metadata tùy ý. Test service cho phép đúng actor, từ chối nil/sai store/deactivated và rollback khi tạo marker lỗi; request test xác nhận staff chỉ có quyền POS không thể tạo đơn qua core Admin API (`403`, thiếu `write_orders`). Chưa có route công khai, test đồng thời revoke hay proof cho mọi bypass. Suite app `spec`: **42 examples, 0 failures**, seed 54724.
- Service đọc lại staff từ database trước khi kiểm tra, có test trường hợp object cũ sau khi account bị deactivate; chưa chứng minh revoke đồng thời với transaction. Suite app chạy lại **42 examples, 0 failures**, seed 27690. Quyền mới có nhãn tiếng Việt/Anh; initializer mới có hiệu lực khi API được khởi động lại, không tự restart stack của developer.
- Request test cho thấy sau `staff.deactivate!`, access JWT cũ và refresh cookie đều bị từ chối ở các endpoint đã thử (khác logout thông thường chỉ thu hồi refresh). Chạy toàn bộ `server/spec`: **43 examples, 0 failures**, seed 47845, database spike riêng.
- Service từ chối tạo draft ở lần gọi kế tiếp sau khi gỡ role POS; không coi đây là proof cho race gỡ quyền cùng lúc. Suite `server/spec` mới nhất: **44 examples, 0 failures**, seed 61285.
- Prototype UX trên origin localhost cô lập: sau khi thêm một áo vào Đơn 04, chuyển sang Đơn 01 thấy 3 sản phẩm và khách Nguyễn Thị Lan, chuyển lại Đơn 04 vẫn thấy 1 sản phẩm, 200.000 ₫ và khách lẻ. Console không báo lỗi tại thời điểm kiểm tra. Chỉ là trạng thái trong phiên trang với dữ liệu giả; không phải UAT, không chứng minh lưu server, responsive hay accessibility.
- Đọc source runtime Spree 6.0.2 `Spree::Orders::Complete`: staff draft đi qua `process_payments` trước `finalize_fulfillments`, sau đó mới place; method `payment_covered?` tính cả payment có trạng thái `pending`, `processing`, `completed`. Đây là quan sát source, chưa phải kết luận kết quả giao dịch cụ thể. Test đặt giữ tuần tự hai cart không chứng minh concurrency của draft POS hay mọi writer, và không chứng minh tiền đã thực nhận. Gate stock/tài chính vẫn đóng; cần chứng minh kiểm tồn đúng chi nhánh dưới cạnh tranh trước bất kỳ xử lý tiền và thiết kế recovery/đối soát cho trạng thái chưa chắc chắn, không dựa riêng vào `payment_covered?`.
- Spike `location_contract_spec.rb` với hai staff draft đã tạo sẵn fulfillment cho cùng variant/kho không backorder, `count_on_hand = 1`: gọi core `Orders::Complete` lần lượt với `payment_pending: true` và `notify_customer: false` cho kết quả cả hai thành công, stock level vẫn on-hand 1 nhưng allocated 2. Bốn test location pass, seed 9904. Đây là fixture kiểm chứng đường fulfillment dựng sẵn, không phải mô phỏng đầy đủ luồng tạo POS, không kiểm tranh chấp đồng thời, không chứng minh hành vi cart hay mọi cấu hình. `payment_pending` chỉ bỏ qua tiền trong spike, không phải chấp thuận công nợ. Blocker: không đưa staff draft completion trực tiếp vào POS; phải có bảo đảm strict branch và kiểm/giữ tồn phối hợp mọi writer trước thanh toán, kiểm cạnh tranh và phương án recovery trước khi mở bán.
- Spike riêng với hai reservation active, một thuộc cart và một thuộc order, cùng stock level: private helper `Spree::StockReservations::Reserve#held_by_others` trả `{}` cho mỗi owner, không tính reservation của loại owner còn lại. `where.not` trên cột owner tương ứng loại cả hàng có NULL; đã xác minh bằng test database PostgreSQL, 5 test location pass seed 55644. Đây chỉ là characterization helper của bản 6.0.2, không đủ để kết luận toàn bộ luồng reserve/checkout end-to-end bị oversell; coordinator và các bước khác còn ảnh hưởng. Không dùng seam reservation của order để khẳng định POS/web an toàn nếu chưa có test xuyên owner và giải pháp được chứng minh.
- Sau hai characterization mới, toàn bộ suite ứng dụng `server/spec` trên database spike: **46 examples, 0 failures**, seed 11817. Test pass ghi nhận cả hành vi không an toàn đã quan sát; không có nghĩa gate tồn kho đã pass.
- Spike service trực tiếp: cart reserve thành công món cuối, tiếp đó `Reserve.call(order: draft)` cũng thành công; hai reservation active khác owner cùng stock level với `reserved_count = 2` trong khi on-hand là 1. Các kỳ vọng an toàn ban đầu đã thất bại trước khi test được chuyển thành characterization; suite `server/spec` sau đó 47 examples, 0 failures, seed 35171. Đây là gọi service tuần tự, không phải thử đồng thời hay checkout hoàn chỉnh. Tham số `order:` đã deprecated và dự kiến bị loại ở Spree 6.1; không dựa vào seam này để triển khai POS.
- **Đính chính quan trọng về dữ liệu test:** kiểm tra `spree_dev_tools-1.0.0/lib/spree_dev_tools/rspec/support/database_cleaner.rb` cho thấy mỗi lần chạy suite tự gọi `DatabaseCleaner.clean_with(:truncation)` trước suite. Các lệnh spike ghi trong báo cáo đều chỉ định `DATABASE_NAME_TEST=parkviet_pos_spike_20261103`, vì vậy có xóa dữ liệu bảng của database spike đó, dù không xóa database và không chủ đích chạy reset; không được hiểu các báo cáo trước là không có truncation. Không có bằng chứng từ các lệnh đó rằng development bị truncate. Dừng chạy RSpec cho đến khi loại bỏ được tác động truncate hoặc có phê duyệt phù hợp; mọi thử nghiệm tiếp theo phải bảo toàn dữ liệu.
- Lighthouse trên prototype UX-only tại localhost: accessibility 100/100, best practices 100/100, SEO 75/100 (thiếu meta description). Điểm tự động không thay thế kiểm tra bàn phím, screen reader, responsive hoặc phê duyệt UX. Không áp kết quả này cho ứng dụng POS thực.
- Đã sửa `server/spec/rails_helper.rb`: bỏ nạp hook DatabaseCleaner upstream có `clean_with(:truncation)`, chặn `DatabaseCleaner.clean_with(:truncation/:deletion)`, dùng transactional fixtures và chỉ kiểm tra migration pending thay vì tự chuẩn bị schema. Test guard xác nhận hai chiến lược bị từ chối và ví dụ chạy trong transaction; suite spike **49 examples, 0 failures**, seed 44444. Cơ chế này không phải bảo vệ trước SQL phá hủy trực tiếp hoặc mọi test tự quản lý connection/transaction; không chạy test đa connection chưa có cleanup cô lập và được kiểm chứng. Test order reservation vẫn ghi nhận hành vi không an toàn chứ không phải gate pass.
- Đảo thứ tự gọi reservation: draft trước, cart sau cũng tạo hai lượt giữ cho một đơn vị; 7 test location pass, seed 4215. Cả hai chỉ là gọi service lần lượt, không phải cạnh tranh đồng thời; `order:` là API deprecated.
- Pickup spike dùng fulfillment dựng trong test với pickup provider, kho bật pickup, order walk-in marker không email và không ship/bill address, payment method check thử nghiệm: core place, tạo allocation 1; core fulfill giảm on-hand 1→0 và allocation 1→0; lần fulfill lại bị từ chối và không trừ lần hai. Thử thêm đơn unpaid đặt bằng `payment_pending` chỉ để nghiên cứu: fulfill không force bị từ chối và on-hand vẫn 1. Hai examples pass seed 16320. Không chứng minh tạo fulfillment từ API, đúng routing chi nhánh, POS end-to-end, concurrent stock, notification extensions hoặc phê duyệt công nợ.
- Sandbox characterization: draft có test payment `pending` đủ số tiền, core `Orders::Complete` báo thành công và đặt order trong khi payment vẫn `pending`, tổng completed = 0 (3 test payment pass seed 65350). Không suy ra đã thu tiền từ trạng thái order/coverage; POS phải có receipt/settlement xác thực và quy tắc recovery riêng trước khi mở thu tiền hoặc handover. Chỉ payment method test; không có giao dịch thật.
- Chạy lại toàn bộ suite ứng dụng với guard không truncate: **53 examples, 0 failures**, seed 41040. Các test về over-reservation và payment pending là characterization của giới hạn, không phải bằng chứng sẵn sàng vận hành.
- Mở rộng pickup spike: gọi lại `Orders::Complete` sau khi place với test payment không tạo thêm payment completed hay allocation; hai ví dụ pickup pass seed 42197. Đây là replay tuần tự trên core, không chứng minh xử lý timeout provider hay request đồng thời.
- Suite ứng dụng sau các bổ sung gần nhất: **53 examples, 0 failures**, seed 64279, với guard test nêu trên. Bổ sung hợp đồng dự thảo `pos-contract-decisions.md`; chưa xem đây là endpoint hoặc ADR được phê duyệt.

## Cần để tiếp tục

1. Ghi kết quả baseline test và kiểm tra schema/migrations; phân biệt source 6.0.2 thực chạy với evidence source local 6.0.1 trước đây.
2. Viết và chạy spike trên test DB được xác nhận, lưu kết quả thực và đánh giá các gate phase 1; prototype UX không thay thế runtime evidence.

## Kiểm tra prototype trên trình duyệt

- Đã mở prototype qua HTTP localhost, tạo đơn 04 và thêm hàng mẫu; console không có lỗi tại thời điểm kiểm tra. Nhãn UX-only hiển thị, không có kết nối thanh toán thật.
- Trong phiên trình duyệt chia sẻ, trạng thái khách và số hàng của đơn 04 sau thao tác không khớp với thao tác đã quan sát; chưa xác định nguyên nhân hoặc loại trừ tương tác đồng thời. Cần tái hiện trong phiên kiểm thử cô lập trước khi kết luận; chưa duyệt UX, responsive hoặc accessibility.

## Runtime gates chưa kiểm chứng

Pickup, split sessions và credit placement; receipt/refund/late cash và parent funds conservation; fractional/base-unit price, distinct SaleLine/cumulative return; inventory traceability mọi writer; cross-store/bypass/strict location chưa đủ bằng chứng. Walk-in không email đã thử và bị chặn; auth đã có bằng chứng cục bộ như trên, chưa có proof đa tab hoặc revoke access JWT tức thời.

## Handoff

Không hỗ trợ công cụ compact chủ động trong phiên này. Tiến độ và blocker được lưu tại đây; không bỏ qua phase 1 hoặc tự đánh dấu hoàn tất. Compose đã đổi trong lần eject lỗi được giữ nguyên, không tự hoàn tác.

## Checkpoint 04/11 — context và shell phase 2

- Chưa đánh dấu phase 1 hoặc 2 hoàn tất. Đã thêm `GET /api/v3/admin/pos/context` và shell đọc endpoint đó. Response cố ý để `capabilities`, `branches`, `registers` rỗng và `shift` null. Không tạo đơn, không thu tiền.
- Request spec `server/spec/requests/spree/pos/authentication_spec.rb` chưa chạy: `pnpm spree test` dừng vì Docker Compose không thấy `.env` ở thư mục gốc (`env file ...\.env not found`). Không tạo file này trong phiên.
- App `apps/pos`: `pnpm test` 12 passed, `pnpm typecheck`, `pnpm exec biome check`, `pnpm build` và `pnpm test:e2e` 3 passed (1280, 768, Pixel 5) chỉ trên màn đăng nhập. Chưa đăng nhập thật, chưa đa tab trên API.

## Checkpoint 04/11 — topology và workspace, chưa chạy DB

- Không đánh dấu phase nào hoàn tất. Giữ context và shell đã có; context nay thêm `selection` và danh sách chi nhánh/quầy/ca khi nhân viên có membership. Không cấp quyền bán, tồn hoặc thu tiền. Handover trả từ chối.
- Migration `20261104120000` và `20261104120100` mới viết, chưa chạy. Không sửa `schema.rb` bằng tay. Không tạo `.env`.
- Request/workflow spec mới chưa chạy vì Compose vẫn thiếu `.env` gốc.
- App kiểm tra lại: Biome, typecheck, 16 unit tests, build, e2e 6 passed (đăng nhập và `/pos/settings` khi chưa đăng nhập, viewport 1280 / 768 / Pixel 5). Đây không phải kiểm chứng API thật.
- Mặc định kỹ thuật, không phải chính sách quản lý: lease 120 giây, trang tối đa 100 bản ghi, bố cục trình duyệt hết hạn sau 12 giờ.
- Phase 5 chưa bắt đầu: plan yêu cầu proof phase 1 về giá/thuế/SaleLine trước hàng cân và giảm giá; ngưỡng duyệt chưa được chốt nên không bật thao tác nhạy cảm.

## Checkpoint 04/11 — migrate và spec sau khi có .env

Checkpoint trước nói migration và request spec chưa chạy. Câu đó đã lỗi thời.

- `pnpm spree migrate` báo migrations up to date. `migrate:status` trên `spree_development` cho thấy `20261104000001`, `20261104120000`, `20261104120100` đều `up`. Không reset, không seed.
- `pnpm spree test spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos`: **69 examples, 18 failures**, seed 43341, khoảng 26 giây. Test DB được `db:create` rồi rspec; các bảng POS mới có mặt (lỗi SQL đụng `spree_pos_audit_entries`).

Đã qua (51 examples), gồm characterization SaleLine: thêm cùng variant hai lần (`price` 0.4 rồi 0.7, metadata lot-a rồi lot-b) vẫn là **một** line, quantity 2, giá và metadata bị lần sau ghi đè. Example xanh là bằng chứng core upsert không lossless, không phải proof SaleLine. Các contract location/discount/payment/runtime/permission/staff auth/store isolation và digest lệnh không nằm trong danh sách fail.

18 failures, ba nguyên nhân code:

1. Cả 8 example context: `resource :context` trỏ `ContextsController`. File là `ContextController`. Lỗi `uninitialized constant Spree::Api::V3::Admin::Pos::ContextsController`.
2. Bốn example walk-in/pickup/checkout: trong `Spree::OrderDecorator`, `Pos::WalkInOrder` phân giải thành `Spree::Pos::WalkInOrder` vì module `Spree::Pos` đã tồn tại. `NameError` thay cho miễn email hoặc `Email can't be blank`. Proof walk-in trước đó bị hồi quy.
3. Prefix `pos_branch`, `pos_register`, `pos_approval` chứa `_`. `Spree::PrefixedId.decode_prefixed_id` chỉ `split('_', 2)`, và `prefixed_id?` chỉ nhận `[a-z]+_[A-Za-z0-9]+`. Id `pos_branch_…` không decode. Vì vậy tạo branch trả 201 rồi `find_by_prefix_id!` thất bại; POST approval và POST workspace trả 404 hoặc `RecordNotFound` khi locate register.

Example recover ca còn lỗi spec: `AuditEntry.where(subject:)` vì model không có `belongs_to :subject`; cột là `subject_type`/`subject_id`. Lỗi transaction aborted là hệ quả.

Không đánh dấu phase hoàn tất. Không bắt đầu phase 5. Ngưỡng approval vẫn là câu plan để mở: default tắt hành động nhạy cảm đến khi manager cấu hình, không ngầm unlimited. Câu đó không phải thứ đang chặn lần chạy này.

## Checkpoint 04/11 — sửa ba lỗi rồi chạy lại

- Route `resource :context` khai `controller: 'context'` để khớp `ContextController`.
- `Spree::OrderDecorator` gọi `::Pos::WalkInOrder`, không còn phân giải thành `Spree::Pos::WalkInOrder`.
- Prefix id POS bỏ dấu `_` thừa (`posbranch`, `posregister`, `posapproval`, và cùng kiểu cho shift, workspace, membership, audit, command) để `split('_', 2)` của Spree 6.0.2 giải được. Audit spec dùng `subject_type` và `subject_id`.
- Chạy lại đúng bộ spec: **69 examples, 0 failures**, seed 37947. Không sang phase 5. Không commit, không PR.

## Checkpoint 04/11 — phase 3 bước 9

- Phiên đang mở: tắt chi nhánh hoặc membership không xóa dòng, không đăng xuất, ca và đơn nháp `R123` vẫn hiện. Ghi mới (đơn nháp, tạm giữ, mở ca) bị khóa. Nút mở lại chỉ có khi context có `pos.topology.recover`.
- Context bỏ capability vận hành khi chi nhánh đã tắt hoặc membership không còn `allows?`. `pos.topology.recover` vẫn được cấp trên membership đã tắt. Tạo đơn và park/cancel cũng bị từ chối trong trường hợp đó.
- Playwright `e2e/disable-session.spec.ts`: 2 kịch bản × desktop/tablet/mobile, cùng suite e2e **12 passed**. API trong test là phiên bản có trạng thái của hợp đồng này, không phải cửa hàng thật.
- Rspec cùng bộ request/workflow/integration: **69 examples, 0 failures**, seed 64890. Không đánh dấu checkbox. Không sang phase 5.

## Checkpoint 04/11 — phase 4 bước 10

- Không mock persistence. Hai token thật trên `spree_test`: browser A tạo draft, browser B đọc lại cùng `order_id`; A claim rồi refresh lease, thời điểm hết hạn trên DB lùi ra sau; B park bằng generation cũ bị 409 và revision không đổi; reload vẫn `editing`, cùng đơn.
- 20 workspace `editing` và 200 `parked` ghi bằng `Pos::CreateWalkInDraft` rồi đọc qua API. `limit=1000` bị trần 100, `count` 220. Lật trang `limit=25` đủ 220 id và 220 order, 20 đang mở và 200 tạm giữ. Reload một đơn mỗi trạng thái giữ nguyên status. Payload list không có `line_items`.
- `pnpm spree test spec/requests/spree/pos/workspaces_spec.rb`: **4 examples, 0 failures**, seed 33320. Không đánh dấu checkbox. Không sang phase 5.

## Checkpoint 04/11 — phase 4 bước 11

- Lệnh đúng plan: `pnpm spree rspec spec/workflows/spree/pos/workspace_commands_spec.rb spec/requests/spree/pos/workspaces_spec.rb`. CLI ghi `spree rspec` sẽ bỏ ở Spree 7, nhưng lệnh vẫn chạy. **6 examples, 0 failures**, seed 65005.
- App: `pnpm test` trong `apps/pos` — 3 files, **16 passed**. `pnpm test:e2e` — **12 passed**.
- Không sửa code. Không đánh dấu checkbox. Không sang phase 5.

## Checkpoint review và sửa phase 1–4 — 04/11

- Tiếp tục giữ tất cả phase chưa hoàn tất và chưa mở phase 5. Command executor kiểm tra authorization trước replay và lần nữa trong transaction; digest gắn workspace và loại lệnh, kiểm lại receipt sau khi lấy lock. Đã thêm request tests revoke membership, dùng cùng key cho hai workspace và chuyển trạng thái park/reopen/cancel.
- Frontend có retry cùng key sau lỗi mạng trong vòng đời tab, phân trang workspace theo chi nhánh/quầy, chọn thêm tab trong trang, không tự chuyển tab đang chọn khi command khác hoàn tất, và thử phục hồi staff session từ refresh cookie khi mở route được bảo vệ. Chưa chứng minh các luồng này qua nhiều browser với API thật.
- `spree exec` xác nhận Rails test kết nối database `spree_test` tại `postgres` và không có migration pending. Chạy request/workflow/integration POS qua CLI, dùng transactional fixtures và guard hiện có: **75 examples, 0 failures**, seed 56053. Không reset hoặc migrate database trong checkpoint này.
- POS frontend qua Corepack pnpm 10.33.4: **19 unit tests passed**, build/typecheck pass; Playwright **12 passed**, chủ yếu mock, backend web không chạy và có log proxy refresh bị từ chối. Corepack dùng version được root khai báo, cài dependencies từ cache offline; pnpm 12 trước đó từ chối lockfile theo minimum release age, nên kết quả Corepack không chứng minh policy pnpm 12 đã pass.
- Còn blocker: lease chưa gắn định danh browser/editor, chưa heartbeat/claim an toàn và test race hai connection; uncertain command key chưa tồn tại qua reload; danh sách và layout chưa khôi phục đầy đủ; approval chưa bind subject; selector topology còn giới hạn; proof phase 1 và E2E thật chưa hoàn thành. Không xem test xanh là phê duyệt bán hàng, thu tiền hoặc stock.

## Checkpoint tiếp tục — lease và approval

- Lease thêm digest editor ID tạo riêng mỗi page, không trả ID/digest trong DTO. Claim lease còn hiệu lực bởi editor khác cần takeover rõ ràng và capability; generation/holder/editor/expiry được kiểm khi mutation. Heartbeat chỉ cho editor đang chọn; API dùng clock của PostgreSQL. Thêm test hai editor cùng staff, takeover có quyền, stale editor và claim sau expiry. Chưa có test cạnh tranh hai connection hoặc E2E API/browser thật; reload tạo editor ID mới, do đó phải chờ expiry hoặc nhờ takeover khi lease cũ còn hạn.
- Approval mới yêu cầu workspace cùng branch và requester được phép; consume kiểm subject, requester, action, amount, currency, revision hiện hành và quyền hiện hành. Có lock workspace trước approval. Chưa nối approval vào discount/phase 5.
- Migration `20261104120200` chỉ thêm cột nullable `lease_editor_digest`. Đã áp riêng trên `spree_test`; sau khi được người dùng cho phép, đã chạy `pnpm spree migrate` trên `spree_development`, migration thành công. Không reset hoặc seed. Schema do CLI cập nhật.
- Test POS request/workflow/integration sau lease và approval: **77 examples, 0 failures**, seed 24083. Frontend: **19 unit tests**, build/typecheck, lint và **15 Playwright mocked** đều pass; có log proxy refresh bị từ chối vì backend web không chạy. Playwright mock hai trang browser xác nhận UI read-only và takeover trên ba viewport; chưa phải proof API thật.
- Còn mở: retry key/intent chưa sống qua reload; phục hồi layout, selector phân trang, kiểm thử browser/API thật, race hai connection và proof phase 1. Không đánh dấu phase 1–4 hoàn tất, không mở thu tiền hoặc phase 5.

## Checkpoint tiếp tục — receipt và selector

- Lưu idempotency key cùng fingerprint intent theo staff/store trong `sessionStorage` (TTL 12 giờ); không lưu token hoặc editor ID. Retry sau reload dùng lại key; nếu editor ID mới làm digest conflict thì tra receipt scoped actor/store và kiểm lại membership trước khi trả kết quả. Receipt vắng không được coi là bằng chứng request cũ không thể commit. Đã test receipt bị từ chối sau revoke và unit test lưu/xóa key; chưa có E2E thật mô phỏng commit rồi mất response/reload.
- Selector chi nhánh/quầy có endpoint read-only được scope theo membership, tìm kiếm và phân trang; context giữ cả bản ghi đang chọn ngay cả khi ngoài 100 bản ghi đầu. Request test kiểm tra pagination, tìm kiếm và truy cập branch không được cấp.
- Sau thay đổi: bộ POS request/workflow/integration **78 examples, 0 failures**, seed 44659; frontend **20 unit tests**, build/typecheck, lint và **15 Playwright mocked** pass. Playwright vẫn báo proxy refresh không kết nối do backend web không chạy.
- Còn mở: E2E thật qua API, race hai connection, phục hồi layout đầy đủ, kiểm thử retry sau reload thực tế và các proof phase 1 liên quan. Không coi phase 1–4 hoặc phase 5 đã hoàn tất; financial/stock gates vẫn đóng.

## Kiểm thử API thật — đang điều tra

- Đã tạo fixture development riêng có nhãn `POS Review e795bd452a`, gồm staff, role, stock location, branch, register, membership và shift; sử dụng store mặc định, không giao dịch tiền hay tồn kho thật. Các lần chạy đã tạo thêm draft tổng hợp; chưa xóa dữ liệu.
- Test browser thật đã có lần nhận HTTP 200 khi takeover nhưng nút sửa vẫn bị khóa; lần khác thao tác nhầm draft cũ do tìm kiếm không tự chọn tab. Test hiện chọn rõ draft vừa tạo ở cả hai browser, nhưng lần chạy đó vẫn gặp HTTP 200 takeover và nút bị khóa. Nguyên nhân chưa được xác nhận, không coi test pass.
- Trong lúc điều tra, các liên kết package trực tiếp trong `apps/pos/node_modules` biến mất ngoài thao tác của phiên này; `pnpm exec playwright --version` không chạy. Chưa khôi phục dependency hoặc thay đổi lockfile. Cần kiểm tra môi trường trước khi chạy tiếp.
- File credential thử `server/pos-live-review-credentials.json` và dữ liệu fixture vẫn tồn tại để tiếp tục kiểm thử. Một snapshot Playwright khi login chậm từng chứa mật khẩu tài khoản thử; coi credential này là đã lộ và không dùng ngoài môi trường thử. Không đưa artifact vào commit; cần thu hồi tài khoản thử và xử lý file khi kết thúc kiểm thử.

## Kết quả điều tra takeover thật

- Root cause: lambda authorization trong `ClaimLease` gán lại biến `takeover` của request bằng kết quả kiểm tra capability. Người có quyền takeover vì vậy có thể claim lease còn hiệu lực mà không yêu cầu takeover rõ ràng. Đã đổi tên biến kiểm quyền, giữ nguyên cờ request. Test request bổ sung xác nhận trường hợp có capability nhưng `takeover: false` phải trả 409 và không tăng generation; test này đỏ trước sửa và xanh sau sửa.
- Test desktop qua API development thật: **1 passed**. Hai browser chọn đúng draft vừa tạo; claim thường trả 409, takeover rõ ràng trả 200, thao tác editor cũ trả 409. Đây không chứng minh race đồng thời hai connection hay commit-then-timeout.
- Sau sửa: POS request/workflow/integration **78 examples, 0 failures**, seed 46126; frontend **20 unit tests**, lint và build pass; Playwright mặc định **15 passed, 3 skipped** (ba trường hợp live được opt-in, không tính là mock proof).
- Các liên kết dependency đã xuất hiện trở lại mà phiên này không cài lại. Người dùng cho biết đang tự chạy `apps/pos`; không dừng hoặc khởi động lại tiến trình của họ.
- Các gate phase 1–4 còn mở: race hai connection, commit-then-timeout/reload, phục hồi layout đầy đủ và proof tài chính/tồn kho. Chưa mở phase 5, bán hàng hoặc thu tiền.

## Layout theo wireframe

- Đã đối chiếu `assets/pos-wireframes.html` và đưa shell về tông xanh, dải đơn, vùng tìm hàng/giỏ và cột thông tin đơn/thanh toán; màn hình hẹp chuyển thành một cột. Context chi nhánh/quầy và thao tác lease/đơn nháp vẫn dùng API hiện có.
- Ô tìm hàng, khách hàng, giá, giảm giá và thanh toán chỉ là các vùng chưa khả dụng; không dùng dữ liệu giả, không bật tìm sản phẩm, tạo dòng hàng hoặc giao dịch. Đây chưa phải bản triển khai đầy đủ wireframe.
- Kiểm tra ảnh Playwright desktop/mobile và assertion không tràn ngang ở desktop/tablet/mobile; test lease mock **3 passed**, frontend unit **20 passed**, lint và build pass; bộ Playwright trước đó **15 passed, 3 skipped**. Kiểm thử bố cục này dùng API mock, không phải bằng chứng giao dịch thật.

## Phase 4 — commit mất response và gửi đồng thời

- Kiểm thử desktop với API development thật: tạo draft, chuyển tiếp request tới server và đợi 201 rồi chủ động làm mất response cùng các retry SDK; reload trang, retry cùng intent. Trước khi sửa test phát hiện SDK sinh `Idempotency-Key` header mới dù body có key cũ, backend ưu tiên header, dẫn đến tạo draft khác. Các lần tái hiện lỗi đã tạo draft tổng hợp bổ sung trong fixture `POS Review`; không xóa dữ liệu.
- Truyền key bền vững qua option `idempotencyKey` của Admin SDK cho command và heartbeat. Backend từ chối 422 nếu header và key trong body cùng có nhưng khác nhau. Sau reload, server trả 409 do editor mới khác editor của request đã commit; client tra receipt và hiện đúng draft, **không** tự nhận lại lease của editor cũ. API thật: bài kiểm thử recovery pass; không lưu editor ID hoặc token vào intent storage.
- Hai HTTP client riêng gửi đồng thời hai lệnh park cùng revision/generation trên draft tổng hợp vừa được tiếp quản: một 200, một 409; kết quả parked có revision tăng đúng một. Đây là bằng chứng hai request được phát đồng thời, **không** chứng minh hai transaction PostgreSQL thực sự chồng lấn hoặc race hai claim trên hai connection.
- Bộ API thật desktop **2 passed** sau sửa; POS backend **79 examples, 0 failures**, seed 20060; frontend **21 unit tests**, build/lint pass. Playwright mặc định chạy song song backend test từng có 3 timeout route anonymous, chạy lại riêng **15 passed, 6 skipped**; các test live được opt-in và đã chạy riêng ở trên.
- Còn mở: race lease có đồng bộ hai connection/transaction và cleanup an toàn; phục hồi đầy đủ tab/layout qua pagination, request đến muộn và các scenario W01–W05 chưa được chứng minh trọn vẹn. Phase 4 vẫn chưa hoàn tất; phase 1 và các gate bán hàng/thanh toán/tồn kho tiếp tục đóng.

## Phase 4 — lock PostgreSQL và phục hồi trang

- `server/spec/manual/pos_lease_race_probe.rb` là probe development opt-in, chỉ nhận fixture `POS Review` đã cấp phép, không xóa dữ liệu. Probe tạo draft tổng hợp mới, cho lease hết hạn, giữ row lock và xác nhận hai backend PID PostgreSQL khác nhau cùng bị block trước khi nhả lock. Kết quả: **một claim thành công, một conflict**, generation cuối 2 (`posworkspace_PQNMcnNFWw`). Lần đầu probe timeout vì transaction giữ snapshot thống kê cũ; sau `pg_stat_clear_snapshot()` chạy lại thành công. Lần timeout cũng đã tạo một draft thử; cả hai được giữ lại.
- Lưu ID tab đang chọn và trang cùng scope staff/store/branch/register; sau reload tải lại danh sách từ server và không khôi phục lease từ browser. Khi đổi context, response cũ không được chuyển focus sang đơn của context mới. Trên cùng context, response tạo draft đến muộn không đổi tab đang xem. Không lưu token/editor ID hay nội dung đơn.
- Playwright mock kiểm tra chọn tab trang 2, reload và tiếp tục chỉ đọc, cùng response tạo đơn đến muộn: **3 passed** desktop/tablet/mobile. Hai test desktop API thật sau thay đổi **2 passed**; một lượt thử trước đó gặp timeout danh sách sau reload, lượt lặp 3 lần có 1 timeout và 2 pass, chưa xác định được nguyên nhân; lượt cuối pass với timeout quan sát 20 giây. UI đã hiển thị rõ trạng thái đang tải/lỗi thay vì trình bày lỗi như danh sách rỗng.
- Sau thay đổi frontend: **21 unit tests**, build, lint pass; Playwright mặc định **18 passed, 6 skipped** (test live opt-in). Backend gần nhất vẫn **79 examples, 0 failures**, seed 20060; probe trên không phải RSpec và không tác động dữ liệu test.
- Chưa đóng phase 4: trang đã lưu chỉ là vị trí, chưa tự tìm lại tab nếu tập dữ liệu thay đổi làm đơn chuyển trang; close-view/khôi phục toàn bộ các tab, cảnh báo ý định chưa gửi và đầy đủ W01–W05 vẫn cần hoàn thiện. Test chậm/ngắt quãng ở API thật cần điều tra thêm; chưa mở phase 5 hoặc các gate kinh doanh.

## Phase 4 — tiếp tục phục hồi và bảo vệ intent

- Tab đang chọn nếu không còn trên trang đã lưu được lấy trực tiếp theo ID từ server, chỉ ghim khi branch/register khớp; không khôi phục lease. Test mock desktop/tablet/mobile đổi trang của draft và xác nhận revision/status mới từ server.
- Đóng view không xóa draft; danh sách view đã đóng được lưu theo layout có scope/TTL, có thể hiện lại. Test reload và hiện lại là mock, chưa chứng minh đầy đủ 20 view trải nhiều trang hoặc quyền bị thu hồi khi khôi phục.
- Cảnh báo intent chưa rõ kết quả sau reload, cảnh báo rời trang và xác nhận logout; giữ khóa qua mất phiên ngoài ý muốn. Nút tra command receipt chỉ xóa khóa khi nhận được receipt; 404/lỗi không chứng minh lệnh cũ sẽ không commit. Retry gặp lỗi xác định sau một lần mất kết quả vẫn giữ khóa. Test mock xác nhận các nhánh này trên ba kích thước; test API thật xác nhận commit rồi mất response, reload, retry cùng key và khôi phục receipt.
- Kiểm thử: unit **29 passed**, build/lint pass; Playwright mock cuối **18 passed, 6 skipped**; gate backend phase 4 **13 examples, 0 failures**, seed 46901. API thật desktop cuối **2 passed**; một lượt trước đó 1 pass/1 timeout khi phục hồi phiên sau reload, nguyên nhân chưa xác định. Hai lượt Playwright chạy song song từng tranh cổng kiểm thử nên kết quả lỗi của lượt đó không dùng làm bằng chứng nghiệp vụ. Test route anonymous hiện mock refresh 401 để không phụ thuộc độ trễ API thật, không thay thế test auth thật.
- Fixture review: đã deactivate staff tổng hợp và đổi mật khẩu ngẫu nhiên; xóa riêng file credential được tạo. Không xóa draft/records. Lần đổi mật khẩu đầu bị validation từ chối vì quá 72 ký tự, lần sau thành công. Không khẳng định JWT đã cấp bị thu hồi tức thời; các lần thử API thật sau này cần fixture mới được cấp phép.
- Đánh giá tại checkpoint: W04 và nền tảng F04 có bằng chứng server/API thật; W01/W03 end-to-end còn phụ thuộc catalog, scan và thanh toán ở các phase sau. **Đính chính W02:** checkpoint bước 10 phía trên đã kiểm 20 editing/200 parked trên database/API thật; còn thiếu test browser 20 view/overflow/reload và phục hồi toàn bộ view cùng khách/lines/discount. W05 còn thiếu kiểm chứng toàn bộ các tổ hợp logout/đóng/hủy với server; A02/A04 và lỗi reload không ổn định cần rà soát thêm. Phase 4 chưa hoàn tất; phase 5 đã có checkpoint triển khai độc lập, còn gate bán hàng/thanh toán/tồn kho tiếp tục đóng. Xem [bàn giao phase 1–4](./phase-01-04-handoff.md).

## Phase 5 — ghi chú, giá catalog và approval sau đổi khách

- Ghi chú POS là cột riêng `note` trên workspace (migration `20261104124000`), đi qua workspace command có revision/lease/idempotency; nội dung trống xóa ghi chú, tối đa 1000 ký tự, workspace không `editing` bị từ chối. Không ghi vào `customer_note`/`internal_note` của đơn gốc. Migration đã áp trên test và development qua Spree CLI.
- Approval discount tạo ở revision cũ bị từ chối (409, không consume) sau khi gắn khách làm revision tăng; approval mới theo revision hiện hành được consume và tổng giảm đúng. Test nằm trong `server/spec/requests/spree/pos/workspace_discounts_spec.rb`.
- Catalog DTO thêm `price`/`compare_at_price`/`currency` từ `price_in` theo tiền tệ mặc định của store; UI hiển thị giá, phân biệt tồn chưa rõ và không coi on-hand là số có thể bán. Chưa có ảnh/variant options.
- Sau thay đổi: POS backend **111 examples, 0 failures** (request/workflow/integration); frontend **29 unit tests**, lint, build pass; Playwright **21 passed, 6 skipped** (live API opt-in). Hàng cân/quy đổi/serial-lô/SaleLine, price override, scanner nối giao dịch, concurrency hai connection và khóa snapshot phase 6 vẫn chưa có proof; không mở thu tiền/giao hàng.
