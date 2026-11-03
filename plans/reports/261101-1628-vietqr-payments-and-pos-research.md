# Research: Payment method VietQR và ứng dụng POS cho Spree 6

**Ngày nghiên cứu:** 01/11/2026, Asia/Ho_Chi_Minh.  
**Trạng thái:** Báo cáo để duyệt hướng tiếp cận; **không phải implementation plan**. Chưa viết code, cài gem, migrate hay thay đổi cấu hình dịch vụ.  
**Phạm vi:** Gem VietQR có thể tái sử dụng/public; website; POS bán hàng có nhân viên thu ngân và màn hình QR cho khách. POS tự phục vụ hoàn toàn là một yêu cầu khác, chưa giả định có trong phạm vi.

## Mục lục

1. [Kết luận và đề xuất](#1-kết-luận-và-đề-xuất)
2. [Cơ sở nghiên cứu và mức độ xác minh](#2-cơ-sở-nghiên-cứu-và-mức-độ-xác-minh)
3. [VietQR, SePay và các lựa chọn](#3-vietqr-sepay-và-các-lựa-chọn)
4. [Đánh giá gem cũ](#4-đánh-giá-gem-cũ)
5. [Tương thích với Spree hiện tại](#5-tương-thích-với-spree-hiện-tại)
6. [Kiến trúc payment method mới](#6-kiến-trúc-payment-method-mới)
7. [Các luồng website và POS](#7-các-luồng-website-và-pos)
8. [Thiết kế ứng dụng POS](#8-thiết-kế-ứng-dụng-pos)
9. [Đối soát, ngoại lệ và hoàn tiền](#9-đối-soát-ngoại-lệ-và-hoàn-tiền)
10. [Bảo mật, độ tin cậy và vận hành](#10-bảo-mật-độ-tin-cậy-và-vận-hành)
11. [Phạm vi sản phẩm và điều kiện phát hành](#11-phạm-vi-sản-phẩm-và-điều-kiện-phát-hành)
12. [Nguồn tham khảo](#12-nguồn-tham-khảo)
13. [Các quyết định cần xác nhận](#13-các-quyết-định-cần-xác-nhận)

## 1. Kết luận và đề xuất

**Khả thi. Nên xây lại phần tích hợp Spree 6, tái sử dụng ý tưởng và phần thuần nghiệp vụ của gem cũ, không port nguyên trạng.**

Đề xuất chính:

- Một payment method **VietQR**, một backend quản lý yêu cầu thanh toán và đối soát dùng chung cho website/POS.
- Hai chế độ ban đầu: **xác nhận thủ công** và **tự động qua SePay Bank Webhooks**. Chuẩn bị điểm mở rộng cho payOS, chưa cần triển khai ngay.
- Ưu tiên **PaymentSession** để biểu diễn mỗi yêu cầu QR, cả khi QR không có session bên ngân hàng. Session thủ công là session nội bộ, không phải phiên ủy quyền ngân hàng.
- Website trả tiền cho `Cart`; POS có thể trả tiền cho `Order` dạng draft. Cùng dùng payment method và logic settlement, không tạo hai hệ thống xác nhận tiền.
- POS nên là **React web app online-first**, giao diện riêng cho thu ngân, cùng backend Spree; không cần native app/Electron để nhận QR.
- Không tự đánh dấu paid từ thao tác “Tôi đã chuyển khoản”, ảnh biên lai, QR đã quét hay redirect thành công.
- MVP chỉ tự khớp khi **đúng mã yêu cầu + đúng tài khoản/VA + đúng số tiền + đúng phạm vi kết nối**. Thiếu/thừa/chuyển trễ đưa vào đối soát, chưa tự cộng ví như gem cũ.

**Trade-off quan trọng:** dùng session cho chế độ manual đồng nghĩa yêu cầu chưa được nhân viên xác nhận vẫn có thể là cart chưa thành order. Dashboard cần màn hình “Yêu cầu VietQR chờ xác nhận”, không thể chỉ nhìn danh sách Orders. Nếu muốn website luôn tạo order trước rồi mới chờ chuyển khoản, xem phương án direct ở mục 5.1; đây là quyết định sản phẩm cần duyệt.

## 2. Cơ sở nghiên cứu và mức độ xác minh

Đã đọc:

- Gem tại `/Users/hienbt/Work/shop/gems/spree_vietqr`: model, allocation, QR generation, provider SePay/payOS, webhook processing, confirmation, admin, migrations và cách tổ chức specs.
- Trang Payments anh cung cấp [S1], tài liệu Payments/Custom Payment Method/Channels được cài trong `node_modules/@spree/docs/dist/`.
- Source local tại `spree/spree/core`, `spree/spree/api`; storefront hiện tại và cấu trúc dashboard.
- Tài liệu chính thức SePay về webhook, xác thực, retry, QR; tài liệu payOS và VietQR.io. Các nguồn đọc trực tiếp, đọc từ bản docs local hoặc tham khảo qua kết quả tìm kiếm được phân biệt ở mục 12; một số đường dẫn cũ không truy cập được đã không dùng làm bằng chứng.

Mốc phiên bản:

| Thành phần | Bằng chứng tại thời điểm đọc |
|---|---|
| Backend | `server/Gemfile.lock`: Spree **6.0.1**, Rails **8.1.4**, path gems từ `../spree/spree` |
| Source Spree tham chiếu | HEAD `b2d033f450`, ngày 01/11/2026; đây là mốc source tham chiếu, không khẳng định container đang chạy đúng commit này |
| Website | `apps/storefront`: Next.js 16, React 19, `@spree/sdk` 6.x |
| Dashboard | `apps/dashboard`: Vite + React, `@spree/dashboard` và Admin SDK |
| Gem cũ | Gemspec cho phép `spree >= 5.4.0`, nhưng code dùng API/lifecycle Spree 5.x |

**Giới hạn:** nghiên cứu tĩnh và tài liệu, chưa chạy integration test, chưa liên kết ngân hàng, chưa gửi giao dịch thật, chưa đo độ trễ POS. Trang dịch vụ có thể đổi giá/chính sách; không coi thông tin marketing là SLA đã kiểm chứng. Không đọc/chép credentials của shop cũ vào report.

## 3. VietQR, SePay và các lựa chọn

### 3.1 QR chỉ là chỉ dẫn thanh toán, không phải bằng chứng nhận tiền

QR chuyển khoản chứa ngân hàng, tài khoản, số tiền và nội dung. App ngân hàng quét để điền thông tin; khách vẫn cần xác nhận chuyển tiền. **Tạo QR không tự tạo callback và không tự biết tiền đã vào.**

Phải phân biệt:

1. **QR chuyển khoản VietQR:** nhận vào tài khoản ngân hàng; đối soát thủ công hoặc qua dịch vụ đọc giao dịch.
2. **SePay Bank Webhooks:** đẩy biến động giao dịch của tài khoản đã liên kết; ứng dụng tự khớp với yêu cầu thanh toán.
3. **SePay Payment Gateway:** sản phẩm cổng thanh toán riêng, có vòng đời đơn và IPN riêng; không dùng lẫn payload/xác thực với Bank Webhooks.
4. **VietQRPay/NAPAS merchant QR:** luồng thanh toán merchant/acquiring; không đồng nhất với việc sinh ảnh QR chuyển khoản bằng URL. SePay cũng quảng bá sản phẩm này [S13–S15].

`vietqr.io` là **VietQR Kit by Casso**, không phải tên gọi thay thế cho toàn bộ mạng lưới NAPAS. Những dịch vụ có chữ “VietQR” không mặc nhiên dùng chung API, credentials hay điều kiện thương mại.

### 3.2 So sánh phương án

| Phương án | QR | Xác nhận tiền | Ưu điểm | Hạn chế / phù hợp |
|---|---|---|---|---|
| Manual + QR chuyển khoản | Tự sinh hoặc dịch vụ ảnh | Nhân viên kiểm tra tài khoản nhận | Ít phụ thuộc, dễ dùng cho shop nhỏ | Chậm, cần quyền và audit; không dựa vào biên lai khách |
| SePay Bank Webhooks | QR theo tài khoản/VA và mã yêu cầu | Webhook giao dịch đã xác thực | Phù hợp yêu cầu hiện tại, dùng chung web/POS | Phải xử lý ngân hàng/VA, khớp mã, retry, đối soát |
| payOS payment link | API trả link và **chuỗi QR payload** | Webhook + API trạng thái link | Có payment-link identity; hợp mô hình session | Thêm adapter/credentials, quy tắc orderCode, onboarding riêng |
| SePay Payment Gateway | Cổng thanh toán / QR từ gateway | IPN của gateway | Có thể mở rộng thêm NAPAS/thẻ sau này | Là tích hợp khác; không đưa vào adapter Bank Webhooks |
| Kết nối trực tiếp ngân hàng / acquiring | Theo hợp đồng | Theo API/ngân hàng | Có thể phù hợp quy mô lớn | Hồ sơ, chi phí, chứng nhận và vận hành riêng |

**Khuyến nghị:** manual + SePay Bank Webhooks trước. Chọn payOS nếu ưu tiên payment link có API tra cứu trạng thái ngay từ đầu. Chỉ chọn acquiring/NAPAS merchant QR khi nhu cầu kinh doanh và hợp đồng yêu cầu, không cần để đáp ứng QR chuyển khoản hiện tại.

### 3.3 Các chi tiết thực tế cần thiết kế đúng

- SePay hỗ trợ HMAC-SHA256, API Key, OAuth 2.0 và không xác thực. **Production chọn HMAC** nếu cấu hình tài khoản hỗ trợ đúng tài liệu hiện hành [S4]. Gem cũ có HMAC, không phải mặc nhiên sai vì một số hướng dẫn cũ chỉ nói API Key.
- SePay yêu cầu HTTP `200/201`, JSON `{"success": true}`, hoàn tất trong 30 giây [S5]. Nên ACK sau khi ghi nhận bền vững, xử lý nghiệp vụ bằng job.
- Tài liệu retry mới mô tả 1 lần đầu + 7 lần retry, tổng khoảng **33 phút**, kèm cutoff dự phòng 5 giờ [S6]. Một số trang cũ chỉ nói “tối đa 5 giờ”; không được dựa vào retry thay cho đối soát.
- Không được suy từ “app của nhiều ngân hàng quét được QR” thành “SePay đọc được giao dịch của từng ngân hàng đó”. **Khả năng quét** và **khả năng liên kết tài khoản nhận** là hai danh sách khác nhau.
- Theo hướng dẫn SePay hiện hành, một số ngân hàng/loại tài khoản bắt buộc VA; VietinBank cá nhân/hộ kinh doanh cần nội dung có `SEVQR`; VA theo nội dung cần `TKP` + mã VA [S7]. Cần profile tài khoản cụ thể, không ghép mã đơn giống nhau cho mọi ngân hàng.
- VA có thể chứa chữ, tài khoản có số 0 đầu. Lưu dưới dạng string, không ép thành số hoặc xóa hết ký tự không phải số.
- VietQR.io Quick Link công bố giới hạn **10 QR / 10 giây / IP** [S10]. Nếu server proxy ảnh cho nhiều quầy có thể dồn vào một IP; không giả định endpoint công cộng là tài nguyên vô hạn.
- Quick Link và API generate có giới hạn nội dung khác nhau [S10–S11]. Thiết kế mã ASCII ngắn theo giới hạn chặt nhất của adapter/ngân hàng; kiểm tra trên app thật.
- Tên tài khoản hiển thị trên ảnh không phải xác minh danh tính người thụ hưởng của ngân hàng [S10]. Khách cần đối chiếu người nhận hiện trong app ngân hàng.

**Chi phí:** trang SePay gateway tại thời điểm tìm kiếm quảng bá QR banking 200–500đ/giao dịch và QR NAPAS 0,3% [S13]. Đây **không phải báo giá đã xác nhận cho gói Bank Webhooks của shop**. Chưa xác minh trọn bộ phí gói, VAT, giới hạn tài khoản/API, phí vượt mức, giá payOS hay SLA. Không nên chọn nhà cung cấp dựa trên chữ “miễn phí” của một khuyến mãi cũ.

## 4. Đánh giá gem cũ

### 4.1 Những ý tưởng nên giữ

- Tách provider adapter và normalize giao dịch trước khi khớp.
- Snapshot tài khoản, amount, transfer content theo yêu cầu để reload không đổi nơi nhận tiền.
- Lưu sự kiện webhook, trạng thái xử lý, khả năng retry và xử lý không khớp.
- Có kiểm tra tài khoản/số tiền thay vì chỉ dựa vào order number.
- HMAC trên raw body + kiểm tra timestamp của SePay.
- Soft-disable tài khoản đã có lịch sử, không xóa mất dấu vết đối soát.

### 4.2 Những phần cần thay hoặc kiểm tra lại trước khi public

| Phát hiện từ code | Hệ quả | Hướng đề xuất |
|---|---|---|
| `payment.state`, `order.payment_state`, `payment.complete!` | Không phù hợp lifecycle/status và settlement Spree 6 | Dùng PaymentSession + workflow chính thức |
| `Spree::Admin::*`, ERB partial/table registration | Không dùng được nguyên trạng với React dashboard | Admin API + dashboard plugin |
| Ràng buộc `Mmo::DeliverOrderJob`, topup, audit log, `MMO_ORDER_EXPIRY_MINUTES` | Gem dính nghiệp vụ shop cũ | Loại khỏi core; tích hợp qua hook/event riêng của host |
| `amount_cents` thực tế chứa số VND; nhiều `.to_i` | Tên sai đơn vị, nguy cơ cắt mất phần lẻ/đổi tiền sai | VND-only có validation; BigDecimal/string ở biên API, integer VND ở adapter |
| Index `(provider, provider_transaction_id)` không `unique`; duplicate check là query trước xử lý | Chưa có hàng rào DB chống cùng giao dịch chạy đồng thời | Ledger giao dịch canonical + unique constraint và settlement lock |
| Underpayment tự cộng ví; kiểm tra duplicate diễn ra trước lock | Cần kiểm thử race riêng, không suy từ lock order rằng cộng ví luôn exactly-once | Không auto-credit trong MVP; tách sổ tiền nhận và đối soát |
| Webhook secrets/API keys là cột string thường | Có thể lộ trong DB dump | Encryption thật sự + masked read + secret rotation |
| Retry admin parse lại payload mà không có guard xác minh rõ tại entry point | Có thể đưa event chưa xác thực trở lại nghiệp vụ nếu không khóa trạng thái/quyền | Chỉ retry event verified; attestation thủ công là thao tác riêng có audit |
| Scope admin/fallback chọn payment method không gắn chặt store | Không phù hợp extension dùng chung nhiều cấu hình | Store/connection-scoped lookup, không fallback “method active đầu tiên” |
| Allocation hết hạn tính từ `order.created_at` | Giỏ/đơn cũ có thể hết hạn ngay khi mở QR | TTL từ lúc phát hành yêu cầu, policy riêng cho late payment |
| Tái sử dụng allocation không đồng nghĩa snapshot amount luôn khớp giỏ mới | QR có thể chứa giá trị cũ sau thay đổi giỏ | Version/amount snapshot và server-side drift guard |
| payOS `qrCode` được sử dụng như URL khi bắt đầu HTTP; nếu không thì sinh QR fallback | API payOS thật trả **raw QR string**; tự dựng lại có thể mất thông tin provider | Tách `qr_payload` và `qr_image_url`, render đúng payload gốc |
| Dựng payOS orderCode bằng cách bỏ chữ của `order.number`, rồi reconstruct `R...` | Gắn với format nội bộ, dễ va chạm giữa các attempt | Provider reference riêng, ánh xạ trực tiếp tới session |
| Specs stub Spree/ActiveRecord thay vì boot ứng dụng thật | Có unit tests nhưng chưa chứng minh migration/API/payment lifecycle hoạt động | Dummy app + request/workflow/integration specs trên Spree 6 |
| Gemspec chỉ đặt `spree >= 5.4.0`, migration dùng JSONB/partial index | Công bố tương thích rộng hơn bằng chứng | Dải phiên bản hẹp; ghi rõ database hỗ trợ |

Đây là **đánh giá tĩnh cho mục đích tái thiết kế**, không phải kết luận mọi vấn đề trên đã tái hiện thành lỗi production. Không đề xuất sửa trực tiếp gem đang phục vụ shop cũ trong đợt nghiên cứu này.

## 5. Tương thích với Spree hiện tại

### 5.1 Direct và session đều hợp lệ, chọn theo ngữ nghĩa sản phẩm

| Cách | Luồng | Khi nên dùng |
|---|---|---|
| Direct | Tạo payment → complete cart → payment pending → staff/webhook xác nhận sau | Muốn nhận order trước khi tiền về; chuyển khoản kiểu invoice/pay-later |
| Session | Tạo yêu cầu QR → xác minh tiền → settle payment → complete cart/order | Muốn QR là một payment attempt rõ ràng, nhất quán website/POS |

**Đề xuất mặc định: session cho cả manual/SePay.** Manual session chỉ giữ chỉ dẫn chuyển khoản; không gọi `:authorized` giả để báo ngân hàng đã giữ tiền. Người có quyền xác nhận mới tạo bằng chứng cho settlement.

Nếu chọn direct cho manual, phải **ép capture policy phù hợp** để checkout không tự chuyển payment thành completed. `authorize` success ở đây chỉ là chấp nhận chờ chuyển khoản, không chứng minh tiền. Chế độ này cũng cần thiết kế adapter webhook riêng vì core generic webhook trông đợi một PaymentSession.

### 5.2 Các thành phần tái sử dụng được

- `PaymentMethod` khai báo `session_required?`, `source_required? = false`, session class, availability VND, icon và short API type ổn định `vietqr`.
- `PaymentSession` có `owner` là Cart hoặc Order; payment liên kết bằng `response_code == external_id`.
- `PaymentSession#settle_payment!(captured: true)` là đường ghi nhận tiền có lock và chống race với frontend/webhook. Không gán `order.payment_status = 'paid'`.
- `Spree::Payments::HandleWebhook` và các workflow complete cart/order làm nền; extension bổ sung kiểm tra và orchestration thay vì fork toàn bộ core.
- Có sales channel `pos`; tạo order qua Admin API có `channel_id`. Channel phục vụ phân phối/ghi nhận nguồn bán, **không thay cho phân quyền thu ngân** [S3].

### 5.3 Khoảng trống thực tế không nên bỏ qua

**Generic webhook chưa “cắm SePay là chạy”:** trong source local, `spree/spree/api/app/controllers/spree/api/v3/webhooks/payments_controller.rb:25–54`:

- Trả `head :ok`, không có JSON `success: true`.
- Enqueue bằng `set(wait: 30.seconds)`; độ trễ này không phù hợp trải nghiệm quầy nếu cộng thêm độ trễ ngân hàng.
- Chỉ truyền payment method, action, session ID sang job; metadata/raw transaction không được giữ qua đường này.
- Nhánh lỗi tổng quát cũng ACK 200; không thể dựa riêng vào phản hồi HTTP để biết nghiệp vụ đã thành công.

**Đề xuất:** endpoint tiếp nhận SePay thuộc extension, namespace riêng theo connection/payment-method identity; xác thực, lưu event/transaction và queue bền vững, trả đúng ACK. Job gọi lại settlement/completion của Spree sau kiểm tra. Đây là adapter ingress có lý do cụ thể, không phải viết lại toàn bộ payment engine. Nếu core tương lai hỗ trợ ACK/scheduling tùy provider, có thể chuyển sang endpoint chung.

**POS thiếu API session tương ứng:** source đã đọc có session endpoints dưới Store API carts; Admin Orders Payments hỗ trợ create/capture/void, không cung cấp bộ create/read/confirm session cho draft order tương đương. POS dùng draft order sẽ cần API staff bổ sung, không gọi Store API bằng admin JWT rồi kỳ vọng cùng semantics.

**Hai điểm skill/docs không khớp source local:**

1. Skill nói capture amount “in cents”. Source `payments/capture.rb:16–20,50–58` dùng **BigDecimal theo đơn vị currency**; Integer là bridge cũ theo hundredths. Admin API parse `:decimal`. Không truyền Ruby integer `250000` và giả định là 250.000 VND. Dùng decimal canonical/BigDecimal đúng contract.
2. Skill nói preferences là YAML plaintext. Source `PaymentMethod` hiện include `SecretPreferences`: preference loại `:password` được tách sang `secret_preferences`, **chỉ mã hóa khi Active Record encryption keys đã cấu hình**. Không copy ví dụ `api_key: :string` vào production; cũng không giả định model receiving account tùy biến tự được mã hóa.

**Môi trường:** `docker-compose.yml` mặc định không mount `./server:/rails`; file dev có mount. Lockfile có path gems nhưng chưa xác minh stack thực chạy bằng compose nào. Khi bắt đầu code cần kiểm tra setup backend/mount trước; không tự eject hoặc sửa source Spree upstream trong nghiên cứu này.

## 6. Kiến trúc payment method mới

### 6.1 Ranh giới trách nhiệm

```text
Website (Store SDK)                  POS (staff session / Admin SDK)
        |                                         |
Cart + PaymentSession                 Draft Order + PaymentSession
        +--------------------+--------------------+
                             |
                    VietQR payment method
                  QR instructions + snapshot
                             |
        +--------------------+--------------------+
        |                                         |
SePay webhook / reconciliation           Staff manual attestation
        |                                         |
Verified bank transaction               Permission + evidence + audit
        +--------------------+--------------------+
                             |
                Match / lock / settle exactly once
                             |
              Spree payment + complete cart/order
                             |
                 Status API -> website / POS
```

Ba lớp không được nhập làm một:

- **Tiền:** đã có giao dịch thực hoặc nhân viên được quyền xác nhận nhận tiền.
- **Đơn:** đã hoàn tất các yêu cầu về giá, thuế, kho, địa chỉ/fulfillment và placement.
- **Giao hàng:** đóng gói, xuất kho, bàn giao tại quầy theo workflow fulfillment.

Có thể tiền đã về nhưng chưa đặt được đơn. Hệ thống phải hiển thị trạng thái này để xử lý, không báo mất tiền hoặc yêu cầu trả lại lần nữa.

### 6.2 Mô hình dữ liệu đề xuất — chưa chốt schema

| Thành phần | Vai trò |
|---|---|
| VietQR PaymentMethod | Cấu hình merchant-facing, mode `manual` hoặc `sepay`, visibility và currency |
| ReceivingAccount / ProviderConnection | Danh tính ngân hàng/VA, liên kết provider, secrets mã hóa; không gắn credential riêng cho từng order |
| VietQR PaymentSession | Yêu cầu thanh toán; snapshot tài khoản, mã, số tiền/currency, thời điểm phát hành, expiry, owner |
| BankTransaction | Sổ giao dịch thực đã nhận, independent với HTTP delivery và payment attempt |
| WebhookDelivery / Event | Dấu vết từng lần gửi, kết quả authentication/processing, retry, lỗi; raw data có kiểm soát |
| ManualConfirmation | Người xác nhận, lúc xác nhận, amount, tài khoản, bank reference, lý do/bằng chứng |

Không cần giữ `PaymentAllocation` như một lifecycle độc lập nếu nó chỉ lặp thông tin của PaymentSession. Có thể lưu snapshot bên session và quan hệ typed cần thiết. Chỉ thêm allocation khi thật sự cần routing nhiều tài khoản. `external_data` đang được Store API serialize, vì vậy **chỉ chứa dữ liệu an toàn để trả khách**; không chứa secrets, toàn bộ bank payload hay số dư.

Đề xuất ban đầu mỗi cấu hình payment method có một provider connection và một tài khoản nhận được chọn rõ ràng. Nếu cần khác tài khoản web/quầy, tạo cấu hình hoặc mapping theo điểm bán có kiểm soát. Không cần `random`, quota waterfall hay round-robin trong MVP.

### 6.3 Mã yêu cầu và contract frontend

- Mỗi attempt có reference riêng; không lấy `order.number` làm identity duy nhất. Trong checkout chưa có Order, và một đơn có thể có nhiều attempt.
- Reference ngắn, ASCII, khó đoán, không chứa email/điện thoại. Prefix và quy tắc phải khớp cấu hình bóc mã của SePay.
- Tránh prefix mơ hồ hoặc substring matching. Nếu nội dung có nhiều reference hợp lệ, đưa vào review thay vì chọn bừa.
- Không tái sử dụng reference của yêu cầu cũ cho yêu cầu mới hoặc quầy khác.
- Refresh cùng yêu cầu, cùng giỏ và snapshot không đổi phải trả lại cùng chỉ dẫn; sửa giá/hàng/discount cần version mới. QR chuyển khoản đã lộ không thể thật sự thu hồi từ ngân hàng.

Frontend nên nhận một **public payment-instructions contract** dùng chung, ví dụ:

```json
{
  "session_id": "ps_example",
  "amount": "250000",
  "currency": "VND",
  "bank_bin": "970436",
  "account_number": "EXAMPLE_ACCOUNT",
  "account_name": "TEN CHU TAI KHOAN",
  "transfer_content": "PVEXAMPLE",
  "qr_payload": null,
  "qr_image_url": "https://trusted-provider.example/qr/example.png",
  "expires_at": "2026-11-01T10:00:00Z",
  "confirmation_mode": "automatic"
}
```

Đây là ví dụ contract, không phải endpoint đang tồn tại hoặc dữ liệu để chuyển tiền. `qr_payload` và `qr_image_url` là hai kiểu khác nhau; adapter phải cung cấp ít nhất một kiểu hợp lệ. Không nhét raw payload vào thuộc tính URL. payOS nên render đúng raw payload do API trả về [S12].

**QR rendering:** MVP có thể dùng dịch vụ ảnh có whitelist domain; giữ ngân hàng/tài khoản/nội dung dạng text để copy khi ảnh lỗi. Nếu cần tự sinh QR cục bộ để giảm phụ thuộc, phải xác minh encoder chuẩn VietQR/CRC và test app ngân hàng trước. Không chỉ dùng thư viện tạo hình QR rồi giả định nội dung bên trong đã đúng chuẩn.

### 6.4 Settlement và vòng đời yêu cầu

- Amount server tính từ số còn phải thu sau store credit/gift card, gồm phí/thuế/delivery; client không được tự đặt amount thấp hơn để mua đủ hàng.
- VND-only ban đầu; từ chối currency khác và số tiền lẻ không hợp lệ. Adapter SePay nhận integer VND; không nhân/chia 100 theo thói quen USD.
- `complete_payment_session` từ browser chỉ đọc bằng chứng server/provider đã xác minh. Không coi `session_result: "success"` là chứng từ; khi chưa nhận tiền giữ waiting, không biến mỗi lần poll thành `failed`.
- Tiền đã nhận mới settle `captured: true`. Không dùng lựa chọn `capture_method` của store để biến “đã hiển thị QR” thành “đã thu tiền”.
- Không cho generic staff capture VietQR bypass yêu cầu bằng chứng. Nếu hỗ trợ capture cho manual, phải nối vào cùng manual-confirmation policy và audit, không trả success vô điều kiện như gem cũ.
- Paid session và cart/order completion phải có cơ chế phục hồi riêng. Job retry phải xử lý được trạng thái “settled nhưng placement chưa xong”, không dừng chỉ vì payment đã completed.

## 7. Các luồng website và POS

### 7.1 Website + tự động SePay

1. Hoàn tất thông tin checkout/delivery, xác minh tổng tiền và điều kiện mua trước khi phát hành QR; áp dụng reservation policy phù hợp.
2. Tạo session, trả instructions. Trang QR hiển thị amount, tài khoản, nội dung, hạn chờ và trạng thái server.
3. Khách quét bằng app ngân hàng, xác nhận chuyển khoản.
4. SePay gửi webhook: verify → persist → ACK đúng JSON → job normalize/match.
5. Job kiểm tra currency, amount, connection/account/VA, reference, snapshot version, tình trạng owner; ghi nhận giao dịch và settle một lần.
6. Complete cart qua workflow Spree; frontend poll hoặc nhận thông báo, lấy kết quả completion và chuyển trang.
7. Nếu khách đóng tab, backend vẫn tiếp tục. Khi mở lại, lấy đúng order hoặc thông báo đang xử lý, không tạo QR mới tùy tiện.

**Mobile cùng thiết bị:** hỗ trợ tải ảnh QR và copy thông tin; hướng dẫn mở ngân hàng/chọn QR từ thư viện nếu app đó có hỗ trợ. Không cam kết mọi ngân hàng có cùng deeplink hoặc đọc ảnh. Nút “Tôi đã chuyển khoản” chỉ yêu cầu kiểm tra lại/trợ giúp, không xác nhận paid.

Storefront hiện có `src/lib/data/payment.ts` cho create/update/complete session và direct payment. Cần bổ sung QR UI, public status/recovery và gateway mapping (`src/lib/utils/payment-gateway.ts` chưa có VietQR), không cần thay checkout engine toàn bộ.

### 7.2 Website + thủ công

1. Tạo manual session, hiển thị cùng instructions và thông báo rõ “Chờ cửa hàng xác nhận”.
2. Nhân viên thấy yêu cầu trong màn hình đối soát, kiểm tra **lịch sử tiền vào phía người nhận**.
3. Người có quyền nhập/chọn bank reference, số tiền, tài khoản và bằng chứng/lý do; server kiểm tra trạng thái, quyền, amount và idempotency.
4. Tạo manual confirmation rồi dùng cùng settlement/completion với tự động.

Không bắt buộc phải có webhook event mới xác nhận thủ công được. Ngược lại, “manual match event đã verified” và “tự xác nhận ngoài provider” phải là hai hành động rõ ràng, không biến event có chữ ký sai thành event hợp lệ bằng nút Retry.

Nếu người mua không muốn chờ tại trang, cung cấp link xem trạng thái có token/ownership đúng. Đối với manual chờ lâu, cần duyệt cách tạo order trước tiền và thời hạn giữ kho; session-first không mặc nhiên giải quyết được vận hành này.

### 7.3 POS + tự động

1. Nhân viên đăng nhập, chọn điểm bán/kho/quầy được phép, tạo draft order gắn channel POS.
2. Thêm sản phẩm, xác định giá/giảm giá/thuế, lựa chọn nhận tại quầy. Server tính lại tổng.
3. Khởi tạo session cho draft order qua staff API bổ sung. Giao diện khóa các chỉnh sửa ảnh hưởng tiền trong lúc chờ; sửa phải hủy/supersede yêu cầu theo policy.
4. Hiển thị QR lớn trên màn hình thu ngân hoặc màn hình khách chỉ đọc. Khách quét bằng điện thoại.
5. Backend nhận tiền, settle và complete draft order bằng workflow Order phù hợp. POS chỉ quan sát kết quả.
6. Khi tiền đã xác nhận và order sẵn sàng, nhân viên bàn giao hàng qua fulfillment, in biên nhận và mở giao dịch tiếp theo.

Không trừ kho một lần trong code POS rồi lại để workflow Spree trừ lần nữa. Order placement và handover dùng các bước stock/fulfillment của Spree, chọn đúng location. Không dùng `payment_pending: true` làm đường tắt để báo bán hàng đã thu tiền.

### 7.4 POS + thủ công hoặc sự cố webhook

- Chỉ nhân viên/manager được cấp quyền mới thấy “Xác nhận đã nhận tiền”; bắt buộc kiểm tra phía tài khoản nhận.
- Ghi người xác nhận/quầy/số tiền/reference và lý do fallback. Thu ngân không được sửa tài khoản thụ hưởng.
- Webhook đến sau manual confirmation phải reconcile vào chứng từ đã có, không settle lần hai. Nếu không chứng minh được là cùng giao dịch, đưa vào review, không tự bỏ qua mọi khoản đến sau.
- Nếu chuyển sang cash, phải đánh dấu attempt QR đã superseded và theo dõi tiền về trễ; không tái dùng màn hình QR cũ cho đơn kế tiếp.

## 8. Thiết kế ứng dụng POS

### 8.1 Hình thức triển khai

| Lựa chọn | Đánh giá |
|---|---|
| Thêm trang POS trong dashboard | Nhanh để thử nghiệm, tái sử dụng staff auth; cần layout tối ưu quầy, tránh biến thành màn admin nhiều thao tác |
| **App riêng `apps/pos` + backend Spree chung** | **Đề xuất cho sản phẩm POS**: tách UX/quyền/phát hành khỏi back office, dễ có customer display |
| Native/Electron | Chỉ cân nhắc khi printer/cash drawer/OS integration thực tế yêu cầu |

Stack phù hợp: React + TypeScript + Vite, TanStack Query/Router, i18next, UI primitives dùng chung khi phù hợp license/version. Website tiếp tục Next.js; không cần ép POS dùng Next.js hoặc sao chép toàn bộ dashboard framework. App POS riêng không đồng nghĩa thêm một payment server riêng.

**Online-first** là lựa chọn an toàn ban đầu. Có thể cache catalog/giữ nháp, nhưng mất mạng không được chuyển QR thành paid hay cam kết tồn kho. PWA/offline đầy đủ là sản phẩm bổ sung có bài toán sync/conflict riêng.

### 8.2 Chức năng tối thiểu có giá trị sử dụng

- Staff login/logout, khóa quầy khi không dùng; chọn điểm bán/kho được cấp quyền.
- Tìm sản phẩm theo tên/SKU/barcode; scanner USB kiểu bàn phím là lựa chọn đơn giản nếu thiết bị hỗ trợ.
- Giỏ bán: số lượng, xóa dòng, giá server, giảm giá theo quyền, tổng tiền VND.
- Khách vãng lai hoặc chọn khách; yêu cầu email/địa chỉ phải thiết kế đúng POS, không tạo email/địa chỉ giả để vượt checkout.
- Tạm giữ và mở lại giao dịch; không mất session khi reload.
- QR động theo giao dịch; màn hình chờ/đã nhận tiền/cần đối soát/mất kết nối phân biệt rõ.
- Tự động nhận trạng thái, manual confirm theo quyền; thông báo âm thanh chỉ là phụ, không thay bằng chứng backend.
- Lịch sử đơn/attempt và biên nhận in bằng browser ban đầu. Receipt POS không mặc nhiên là hóa đơn điện tử hợp lệ; tích hợp hóa đơn là phạm vi riêng cần đối chiếu kế toán/quy định.
- Màn hình khách chỉ đọc, hiển thị QR và kết quả thanh toán, không có nút xác nhận hay quyền staff.

Cash, chia tiền nhiều phương thức, hoàn/đổi tại quầy, ca thu ngân, cash drawer, printer ESC/POS, loyalty, cân điện tử và offline sync **không tự động nằm trong MVP QR**. Cần xác nhận riêng vì ảnh hưởng data model và test matrix.

### 8.3 API cần có: có sẵn và còn thiếu

| Nhu cầu | Có sẵn / cần bổ sung |
|---|---|
| Catalog, tồn kho, khách hàng | Tận dụng Admin/Store APIs đúng quyền; không đưa secret API key vào SPA |
| Tạo/sửa draft order và gắn `channel_id` | Có Admin Orders API; staff server-side policy phải giới hạn điểm bán/quyền giá |
| Complete/capture/void theo lifecycle Spree | Có API/workflow; không đồng nghĩa đã đủ policy VietQR |
| Session QR cho Cart website | Có Store API payment sessions; thêm implementation VietQR |
| Session QR cho draft Order POS | **Cần staff API mới** gọi cùng payment method với Order owner |
| List yêu cầu manual, chi tiết transaction, confirm/match/retry | **Cần Admin API extension** và dashboard UI |
| Read payment status cho customer display | **Cần capability token chỉ đọc** hoặc endpoint public tối thiểu, bound một attempt |
| Cancel/supersede attempt QR | **Cần policy/API extension**; core không có Store session-cancel endpoint tổng quát |

Các API bổ sung ở đây là đề xuất khả năng, **chưa phải contract endpoint đã triển khai**. Với POS có thể dùng Rails staff endpoints trực tiếp; chỉ thêm BFF riêng nếu cần. Không buộc phải dựng thêm Node payment service.

Staff sử dụng phiên đăng nhập admin với role tối thiểu, không dùng tài khoản customer thay thu ngân. Cấu hình channel/kho/terminal phải được server kiểm tra; `X-Spree-Channel: pos` không cấp quyền sửa giá hay bỏ kiểm tra địa chỉ/kho. Tránh cấp `write_orders` quá rộng rồi chỉ ẩn nút trên UI.

**Cập nhật trạng thái:** bắt đầu bằng polling endpoint Spree của mình khoảng 2–3 giây khi đang chờ, backoff khi tab ẩn/mạng lỗi; không poll SePay từ từng quầy. Khoảng này là cấu hình đề xuất, không phải SLA. SSE/WebSocket có thể thêm khi đo cho thấy cần, vẫn phải reconnect và resync bằng HTTP. Customer-display token không được là cart token hoặc admin JWT.

## 9. Đối soát, ngoại lệ và hoàn tiền

### 9.1 Policy đề xuất cho bản đầu

| Tình huống | Hành vi an toàn |
|---|---|
| Đúng reference/account/amount, attempt còn hợp lệ | Tự settle, complete và cập nhật UI |
| Webhook retry cùng transaction ID | Ghi nhận delivery nếu cần; không cộng tiền/settle lại |
| Hai giao dịch thật khác ID cho cùng QR | Giao dịch thứ hai là tiền nhận thêm, **không phải duplicate delivery**; review/hoàn tiền |
| Chuyển thiếu | Ghi ledger, báo thiếu, không báo paid; MVP chưa tự cộng dồn nhiều lần chuyển |
| Chuyển thừa | Ghi nguyên số tiền nhận và khoản lệch; review, không tự cộng ví hoặc âm thầm cắt thành đúng amount |
| Khác account/bank/VA hoặc provider connection | Không tự khớp dù amount và nội dung giống |
| Sai/thiếu/nhiều mã yêu cầu trong nội dung | Unmatched/review; không khớp chỉ bằng số tiền |
| Chuyển vào QR cũ, hết hạn hoặc sau đổi phương thức | Lưu như tiền đã nhận cần review; không áp vào attempt/quầy hiện tại |
| Đơn canceled / hàng không còn / giá đã thay đổi | Giữ ledger, dừng giao hàng; xử lý paid-but-unplaced hoặc hoàn tiền |
| Staff confirm và webhook tới đồng thời | Cùng idempotent settlement; reconcile evidence để không ghi nhận hai khoản cho một giao dịch |
| Mất webhook, nhận sau nhiều phút | Job đối soát API/import + cảnh báo; timeout UI không đồng nghĩa chưa nhận tiền |
| Job chết sau nhận tiền nhưng trước complete | Retry từ trạng thái bền vững; không bắt khách thanh toán lại |
| Khách mở nhiều tab, thu ngân double-click | Tái sử dụng attempt hợp lệ hoặc idempotency key; không tạo nhiều reference cùng lúc ngoài ý muốn |

**Expiry trên website không ngăn ngân hàng nhận tiền.** Session canceled/expired chỉ là trạng thái ứng dụng; ảnh QR đã lưu vẫn có thể chuyển được. Chỉ mô tả “QR không còn được hệ thống tự khớp” khi không có provider-side cancellation thực sự. Không hứa hủy tiền, hoàn tiền hay khóa chuyển khoản chỉ bằng việc ẩn QR.

Policy strict-exact-match giảm tự động hóa ở các ca lệch tiền, đổi lại đơn giản và dễ kiểm toán hơn. Sau này có thể cộng dồn nhiều giao dịch/cho phép overpayment, nhưng phải thiết kế allocation sổ tiền riêng và hỗ trợ khách vãng lai. Không lấy logic wallet đặc thù shop cũ làm mặc định cho tất cả merchant.

### 9.2 Idempotency cần hai lớp

1. **Giao dịch ngân hàng:** unique theo identity ổn định, ví dụ store + provider + provider connection/company + environment + external transaction ID. Không dùng webhook URL hoặc payment method instance làm khóa duy nhất nếu một connection có thể gửi vào nhiều endpoint.
2. **Settlement:** unique mapping giao dịch → yêu cầu/payment, khóa owner và kiểm tra lại dưới lock. Core session settlement giúp chống payment double-completion nhưng không thay ledger cho từng khoản chuyển thật.

Nếu cùng tài khoản bị theo dõi bởi hai provider, external IDs sẽ khác nhau. MVP nên giới hạn một nguồn tự động authoritative trên mỗi tài khoản; nếu cho phép nhiều nguồn phải có thêm đối soát bank reference/canonical identity. Không giả định dedup theo provider ID tự giải quyết được cross-provider duplicate.

Manual không có provider transaction ID cần attestation riêng; bank reference và account giúp khớp lại khi webhook tới. Không có đủ dữ kiện thì review, không tạo “giao dịch SePay giả” để lấp chỗ trống.

### 9.3 Hoàn tiền là một luồng tiền khác

QR thu tiền không tự cấp quyền chuyển tiền ra hoặc reverse giao dịch. Nút void/cancel chưa nhận tiền khác với refund sau nhận tiền.

MVP đề xuất **hoàn tiền thủ công có chứng từ**, không cung cấp dummy `credit` luôn thành công. Nếu chưa có outbound-transfer adapter và xác nhận ngân hàng, UI/API không được báo “đã hoàn” chỉ vì người dùng bấm refund. Cần thiết kế workflow request/approval/evidence và nối vào Refund ledger của Spree đúng lúc tiền hoàn được xác nhận.

payOS có API payout được mô tả trong tài liệu hiện hành [S12], nhưng không thể suy rằng mọi tài khoản thu QR đã có quyền dùng payout. Không tự động hoàn về tài khoản suy đoán từ nội dung chuyển khoản. Refund tự động, duyệt hai người và xử lý tiền phí là phạm vi riêng.

## 10. Bảo mật, độ tin cậy và vận hành

### 10.1 Những bất biến bắt buộc

- Một khoản chuyển thật không được trả cho hai order; một webhook replay không được cộng tiền hai lần.
- Không có endpoint public nào nhận `paid=true` hay amount từ browser rồi settle trực tiếp.
- Lookup session/transaction/account phải scope bằng store + connection + quyền/ownership; không tìm global theo order number rồi chọn payment method fallback.
- Staff chỉ được xác nhận giao dịch tại điểm bán/phạm vi được cấp; quyền sửa tài khoản, xem secrets, confirm và refund tách riêng nếu cần.
- Không downgrade HMAC sang “none”/API Key tự động khi verify lỗi. API Key, nếu hỗ trợ tương thích, phải là mode cấu hình rõ ràng.
- SePay HMAC dùng raw bytes, timestamp window, constant-time compare; lưu hash/raw body có kiểm soát. Xác thực của payOS theo scheme riêng, không áp timestamp scheme SePay cho payOS.
- Retry nội bộ dùng record đã được xác thực lúc nhận, payload bất biến và dấu vết verification; không yêu cầu timestamp cũ còn trong cửa sổ 5 phút, cũng không cho retry event rejected thành verified.
- Lọc secrets/cookie/authorization/signature nhạy cảm khi log; raw bank payload có thể chứa tên, số tài khoản, số dư. Hạn chế quyền đọc và retention.

### 10.2 Nhận webhook bền vững

Luồng phù hợp: giới hạn request → xác thực → persist event/transaction → bảo đảm job sẽ được xử lý → ACK. Nếu persistence/enqueue thất bại, không báo success giả. Nếu event đã persist và business matching thất bại, có thể ACK và retry nội bộ, không phụ thuộc provider gọi vô hạn.

Nếu queue và application DB không chung transaction, cần outbox/recovery sweep hoặc cơ chế tương đương để vá khoảng “đã lưu event nhưng chưa enqueue”. Job phải kiểm tra kết quả workflow, không coi “không raise exception” là đơn đã complete. Thử lại phần placement sau khi settlement thành công phải là một đường phục hồi được kiểm thử.

Webhook giao dịch không đảm bảo thứ tự [S6]. Lưu transaction time theo timezone Việt Nam khi provider gửi local time, không diễn giải bằng timezone server tùy ý. `gateway` là tên ngân hàng, cần map alias → BIN có chủ đích; không xóa chữ rồi bỏ qua bank check khi chuỗi thành rỗng.

### 10.3 Cấu hình và vận hành merchant

- Merchant nhập tài khoản/VA của mình; hướng dẫn liên kết SePay, cấu hình prefix và webhook URL, chọn đúng tài khoản và auth mode.
- Chạy test delivery và giao dịch thật giá trị nhỏ trước khi bật tự động. Event test/mock không được làm paid order thật.
- Secrets dùng encrypted storage và yêu cầu encryption keys ở production; hỗ trợ rotate theo connection, không tắt tài khoản rồi làm mất khả năng verify giao dịch đang chờ.
- Dashboard có yêu cầu chờ, event lỗi/unmatched, giao dịch lệch tiền, retry có quyền, manual match và audit.
- Có job đối soát định kỳ bằng API nếu gói hỗ trợ, hoặc quy trình import statement/manual khi không có API. Dùng khoảng thời gian chồng lấn + dedup để tránh mất giao dịch khi trễ, không chỉ lấy bản ghi mới nhất.
- Theo dõi: tuổi yêu cầu pending, độ trễ event → payment/order, lỗi chữ ký, queue lag, unmatched, amount mismatch, paid-but-unplaced, manual fallback và đối soát chưa xong.
- Payment jobs không nên bị backlog sau image/import jobs. Dùng queue ưu tiên/capacity có đo lường; chưa cần thêm Redis chỉ để nhận QR.

### 10.4 Trải nghiệm và hiệu năng

POS cần phản hồi nhanh từ lúc **backend nhận event**, nhưng tổng thời gian còn phụ thuộc ngân hàng/provider. Không hứa “tiền về trong 1–2 giây” khi chưa đo. Đo các mốc riêng: bank transfer → provider webhook → durable ingress → settlement → order completion → POS update.

Polling 2–3 giây chỉ thêm độ trễ UI tương ứng, không cải thiện tốc độ ngân hàng. Customer display, browser reload, background tab và reconnect đều phải resync trạng thái. Màu xanh/âm báo/biên nhận chỉ dựa vào trạng thái server đã xác nhận, không optimistic paid.

## 11. Phạm vi sản phẩm và điều kiện phát hành

### 11.1 Phân tách để có thể dùng lại/public

| Sản phẩm | Chứa | Không chứa |
|---|---|---|
| Gem VietQR backend | PaymentMethod/session, QR instructions, SePay adapter, ledger, staff/public API phù hợp, jobs, permissions/events | Code shop MMO, React views, terminal-specific workflow |
| Dashboard integration | Cấu hình receiving account/connection, pending requests, đối soát, confirm/audit | Thanh toán xử lý ở client |
| Shared frontend contract / QR component | Kiểu instructions/status, render QR/text, trạng thái chờ | Secrets, provider matching, quyền tự settle |
| POS app | Sales UI, staff session, terminal flow, customer display, receipt | Payment gateway backend thứ hai |

Không nhất thiết phát hành npm package cho shared QR component ngay. Có thể giữ interface nhỏ trong dự án rồi tách khi website/POS đã cho thấy nhu cầu dùng chung thực sự. Backend gem và dashboard plugin có thể version độc lập nhưng cần compatibility matrix.

Ưu tiên hỗ trợ đúng **Spree 6.0.x / Rails 8.1 / PostgreSQL** đã được test trước. Nếu muốn public hỗ trợ MySQL/SQLite, migration phải portable và CI phải chạy chúng; không tự quảng cáo hỗ trợ chỉ vì Rails có adapter. Tương tự, không khai báo `spree >= 5.4` cho code chỉ test trên 6.0.1. Với shop cũ, giữ nhánh 5.x hoặc coi migration dữ liệu là công việc riêng.

### 11.2 Phạm vi khuyến nghị để duyệt

**Payment foundation:** VND, một tài khoản nhận được cấu hình rõ ràng, manual + SePay Bank Webhooks, QR theo attempt, audit/idempotency, đối soát ngoại lệ, website flow và API đủ cho POS dùng cùng core.

**POS cơ bản:** bán hàng trực tiếp cho một merchant, nhân viên đăng nhập, chọn kho/quầy, sản phẩm/giỏ, khách vãng lai, QR, trạng thái nhận tiền, manual fallback, order/receipt/handover; online-first.

**Chưa đưa vào mặc định:** payOS implementation, SePay gateway/NAPAS acquiring, split tender cash+QR, tự cộng ví, auto-refund/payout, routing theo quota, offline sale, quản lý ca tiền mặt đầy đủ, hóa đơn điện tử, marketplace seller settlement hay SaaS multi-tenant. Đây là các chiều mở rộng, không phải yêu cầu ngầm của QR payment method.

### 11.3 Bằng chứng cần có trước khi dùng thật/public

Không phải danh sách bước coding; đây là tiêu chí đánh giá thiết kế và sản phẩm sau này:

- RSpec thực với Spree app: session owner Cart/Order, đúng VND unit, settlement/capture/refund semantics, permissions, migrations.
- Request/integration: chữ ký đúng/sai, raw body, API Key mode nếu có, đúng ACK SePay, timestamp/replay, secret rotation và store isolation.
- Concurrency: webhook kép, worker kép, manual và auto đua nhau, double-click, hai tab, session cũ và session mới.
- Resilience: chết job trước/sau settle, placement fail, queue outage, webhook tới trễ, reconcile lặp, đã nhận tiền nhưng hết kho.
- Playwright: web desktop/mobile và POS/customer display; reload/reconnect; không đủ quyền; ảnh QR lỗi; webhook đóng đơn khi browser đã đóng.
- QR thử trên các app ngân hàng thực tế đã chọn, gồm tài khoản thường/VA phù hợp, số 0 đầu, nội dung bắt buộc và amount.
- Có vận hành đối soát, cảnh báo, hướng dẫn merchant, database/version matrix, license, dummy app và CI. Không mang credentials, tên miền nội bộ hay dữ liệu khách hàng từ shop cũ sang repo public.

## 12. Nguồn tham khảo

### 12.1 Tài liệu chính thức

Các trang web được đọc tại thời điểm nghiên cứu; đa số không có ngày xuất bản đáng tin cậy. Với Spree, đối chiếu thêm bản docs cài tại dự án và source local. S2–S3 được đọc từ bản Markdown cài local; URL dưới là trang tương ứng để người đọc tra cứu.

- **[S1] Spree — Payments:** https://spreecommerce.org/docs/developer/core-concepts/payments — direct/session, webhook, settlement, payment vs order.
- **[S2] Spree — Custom Payment Method:** https://spreecommerce.org/docs/developer/how-to/custom-payment-method — đọc bản local `node_modules/@spree/docs/dist/developer/how-to/custom-payment-method.md`.
- **[S3] Spree — Channels:** https://spreecommerce.org/docs/developer/core-concepts/channels — đọc bản local `node_modules/@spree/docs/dist/developer/core-concepts/channels.md`.
- **[S4] SePay — Xác thực webhook:** https://developer.sepay.vn/vi/sepay-webhooks/xac-thuc — HMAC, API Key, OAuth.
- **[S5] SePay — Tích hợp webhook:** https://developer.sepay.vn/vi/sepay-webhooks/tich-hop-webhook — payload, ACK và dedup ID.
- **[S6] SePay — Xử lý lỗi:** https://developer.sepay.vn/vi/sepay-webhooks/xu-ly-loi — retry 33 phút, cutoff, unordered delivery, test events.
- **[S7] SePay — Tạo mã VietQR:** https://developer.sepay.vn/vi/tien-ich-khac/tao-qr-code — QR URL, VA, `SEVQR`, `TKP`.
- **[S8] SePay — QR và trang thanh toán:** https://developer.sepay.vn/vi/sepay-webhooks/tao-qr-va-form-thanh-toan — tham khảo luồng QR + webhook + polling từ kết quả tìm kiếm.
- **[S9] SePay — Webhook security:** https://developer.sepay.vn/en/sepay-webhooks/bao-mat — tham khảo raw data, validation, reconciliation từ kết quả tìm kiếm.
- **[S10] VietQR Kit by Casso — Quick Link:** https://www.vietqr.io/qr-dong — định dạng QR ảnh, tài khoản string, thông tin hiển thị, rate limit.
- **[S11] VietQR Kit by Casso — Generate API:** https://www.vietqr.io/generate — tham số/giới hạn và QR text/data URL từ kết quả tìm kiếm.
- **[S12] payOS — API và signature:** https://payos.vn/docs/api/ ; https://payos.vn/docs/tich-hop-webhook/kiem-tra-du-lieu-voi-signature/ — payment link, raw QR payload, query status, webhook, cancellation, payout riêng.
- **[S13] SePay — Payment Gateway:** https://sepay.vn/cong-thanh-toan-truc-tuyen.html — thông tin sản phẩm/giá quảng bá từ kết quả tìm kiếm, chưa phải báo giá cho shop.
- **[S14] SePay — Giới thiệu cổng thanh toán:** https://developer.sepay.vn/vi/cong-thanh-toan/gioi-thieu — phân biệt VietQR transfer, NAPAS và thẻ từ kết quả tìm kiếm.
- **[S15] SePay — Cổng NAPAS:** https://sepay.vn/cong-thanh-toan-napas.html — mô hình merchant QR và điều kiện sản phẩm từ kết quả tìm kiếm.

### 12.2 Bằng chứng source quan trọng

Paths bên dưới tương đối với `/Users/hienbt/Work/parkviet`, trừ gem cũ đã ghi root riêng ở mục 2.

| Tệp | Nội dung đã đối chiếu |
|---|---|
| `server/Gemfile.lock:1–82` | Phiên bản và path gems |
| `spree/spree/core/app/models/spree/payment_method.rb:16,23–28,135–200,271–293` | Secret preferences, money contract, sessions, webhook và capture policy |
| `spree/spree/core/app/models/concerns/spree/secret_preferences.rb:1–19` | Mã hóa chỉ khi có encryption keys |
| `spree/spree/core/app/models/spree/payment_session.rb:14–25,58–93,143–189` | Cart/Order owner, payment identity và settlement locking |
| `spree/spree/core/app/workflows/spree/payments/capture.rb:16–20,50–58` | BigDecimal đơn vị currency; Integer legacy hundredths |
| `spree/spree/api/app/controllers/spree/api/v3/webhooks/payments_controller.rb:25–54` | ACK rỗng, delay 30 giây, dữ liệu chuyển sang job |
| `spree/spree/core/app/jobs/spree/payments/handle_webhook_job.rb:10–19` | Context store và args workflow |
| `spree/spree/core/app/workflows/spree/payments/handle_webhook.rb:46–88` | Settlement và complete owner; cần hiểu guard khi phục hồi |
| `spree/spree/api/app/controllers/spree/api/v3/store/carts/payment_sessions_controller.rb` | Session APIs cho Store Cart |
| `spree/spree/api/app/controllers/spree/api/v3/admin/orders/payments_controller.rb` | Admin payment create/capture/void |
| `spree/spree/api/app/controllers/spree/api/v3/admin/orders_controller.rb:18–74,92–145` | Draft order/channel/complete |
| `spree/spree/core/app/workflows/spree/carts/complete.rb` và `orders/complete.rb` | Cart → Order, stock và placement |
| `spree/spree/api/app/serializers/spree/api/v3/payment_session_serializer.rb:5–23` | Public external_data và Cart/Order ID bridge |
| `apps/storefront/src/lib/data/payment.ts` | Các server actions hiện có |
| `apps/storefront/src/lib/utils/payment-gateway.ts:12–59` | Registry frontend chưa có VietQR |

Bằng chứng gem cũ, tương đối với `/Users/hienbt/Work/shop/gems/spree_vietqr`:

- `app/models/spree/payment_method/vietqr.rb` — direct authorize/capture và API cũ.
- `app/services/spree_vietqr/confirm_payment.rb:23–66,113–129,200–208` — status cũ, thiếu/thừa → ví, dependency MMO.
- `app/models/spree_vietqr/webhook_event.rb:32–39` và `db/migrate/20260522000001_create_spree_vietqr_webhook_events.rb:29–32` — query duplicate và index không unique.
- `app/controllers/spree/admin/webhook_events_controller.rb:60–89` — retry verification guard cần thiết kế lại, fallback method và scope.
- `db/migrate/20260523000001_create_spree_vietqr_receiving_accounts.rb:24–28` — secrets cột thường.
- `app/services/spree_vietqr/allocate_payment_account.rb:140–154` — refresh snapshot và mốc TTL.
- `app/services/spree_vietqr/generate_qr.rb:13–31` — raw QR khác URL; so với payOS response [S12].
- `app/services/spree_vietqr/providers/sepay.rb:11–23` — HMAC phù hợp scheme SePay hiện hành.
- `spec/spec_helper.rb:12–39` — stub thay vì Rails/Spree integration app.

## 13. Các quyết định cần xác nhận

Các câu dưới đây là đầu vào để **sau khi anh duyệt mới tạo plan**:

1. **Thứ tự tạo đơn website:** đồng ý session-first, nhận tiền/xác nhận rồi tạo order; hay phải luôn có order chờ chuyển khoản ngay sau checkout? Đặc biệt quan trọng với manual chờ lâu.
2. **Provider ban đầu:** manual + SePay Bank Webhooks, payOS để sau có phù hợp không? Shop sẽ dùng ngân hàng nào, tài khoản cá nhân/hộ kinh doanh/doanh nghiệp, có VA không?
3. **Người dùng POS:** nhân viên thu ngân của shop hay kiosk cho khách tự phục vụ? Report đang giả định thu ngân + customer display chỉ đọc.
4. **Quy mô quầy:** một hay nhiều chi nhánh/kho/quầy; dùng chung tài khoản nhận hay tài khoản riêng? Đây không đồng nghĩa phải multi-tenant.
5. **Thanh toán ngoài QR:** bản POS đầu chỉ QR hay cần cash/COD/split tender? Có quyền bán chịu không?
6. **Quyền manual:** thu ngân nào cũng được confirm hay chỉ manager; cần hai người duyệt từ ngưỡng tiền nào?
7. **Policy ngoại lệ:** đồng ý strict-exact-match và review thiếu/thừa/chuyển trễ, không auto-credit ví? Hạn chờ và thời gian giữ kho mong muốn?
8. **POS UX/thiết bị:** app riêng `apps/pos` có phù hợp; thiết bị tablet/PC, scanner, màn hình khách, printer nào cần hỗ trợ ngay?
9. **Phạm vi public:** phát hành gem dùng chung Spree 6 ngay, hay chứng minh nội bộ trước rồi đóng gói? Có cần hỗ trợ Spree 5.x/MySQL/SQLite ngay không?
10. **Onboarding thương mại:** chưa xác minh chính xác ngân hàng hỗ trợ cho loại tài khoản của shop, gói API/đối soát, phí thực tế, test/production isolation và SLA. Cần kiểm tra trong tài khoản/hợp đồng trước khi chốt provider.

**Bước tiếp theo đề nghị:** anh duyệt hoặc điều chỉnh các lựa chọn trên; sau đó mới lập implementation plan riêng cho payment foundation, website integration và POS. Báo cáo này không tự khởi động các công việc đó.
