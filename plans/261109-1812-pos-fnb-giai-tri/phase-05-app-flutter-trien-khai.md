---
phase: 5
title: "App Flutter và triển khai server"
status: pending
effort: "13 ngày"
dependsOn: [2, 3, 4]
---

# Phase 5: App Flutter và triển khai server

## Overview

Hai phần cùng là hạ tầng chạy thật: khung app nhiều chế độ với trạm in, và gói triển khai LAN / VPS mà QR ghép thiết bị dùng địa chỉ của nó.

| Phần | Nội dung | Effort |
|---|---|---|
| 5A | Khung app Flutter, trạm in | 9 ngày |
| 5B | Triển khai server LAN / VPS | 4 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 5A: Khung app Flutter, trạm in

### Overview

Phần này dựng app Flutter nhiều chế độ `apps/pos-staff` (package `parkviet_staff`) cho Android và iOS (D3). Bản đầu có đủ phần khung mà mọi chế độ cần:
- cấu hình địa chỉ server;
- ghép thiết bị bằng QR;
- đăng nhập nhân viên bằng PIN;
- vỏ điều hướng theo mode;
- client API sinh từ OpenAPI;
- realtime;
- i18n.

Chế độ đầu tiên chạy thật là **trạm in** (`print_station`): nhận `PrintJob` và in ra máy in Sunmi tích hợp, ESC/POS qua LAN và ESC/POS qua Bluetooth. Các chế độ khác chỉ là màn giữ chỗ, và các phase sau làm thật: KDS ở phần 7A, phục vụ ở phần 8C, chạy bàn ở phần 9A, kiosk ở phần 12B, chủ quán ở phần 12C, bridge ở phần 11C.

### Quyết định

1. **Stack** (bản stable mới nhất tại thời điểm làm, ghi vào `pubspec.yaml`):

   | Việc | Thư viện |
   |---|---|
   | State | `flutter_riverpod` (+ `riverpod_generator`) |
   | Điều hướng | `go_router` |
   | HTTP | `dio` |
   | Model | `freezed` + `json_serializable` |
   | Lưu trữ an toàn | `flutter_secure_storage` |
   | Quét QR | `mobile_scanner` |
   | Giữ màn sáng | `wakelock_plus` |
   | Thông tin máy | `device_info_plus`, `package_info_plus` |
   | i18n | `flutter_localizations` + ARB (`intl`) |

   Phiên bản cụ thể tra bằng tài liệu hiện hành khi làm, không ghi cứng trong plan.
2. **Client API sinh từ `server/openapi/pos-staff.yaml`:**
   - dùng `openapi-generator` target `dart-dio`, output vào `apps/pos-staff/packages/pos_api/` và commit vào repo;
   - script `apps/pos-staff/tool/gen_api.sh` sinh lại client;
   - CI chạy script đó rồi `git diff --exit-code`, lệch thì fail (rủi ro của plan.md).
   - Không viết tay model API.
3. **Lần mở đầu tiên:**
   - **Màn chào** có hai cách: "Quét QR ghép máy", hoặc "Nhập địa chỉ server + mã".
   - QR theo payload `v: 1` của phase 2. App từ chối `v` lạ và `kind` khác `parkviet.device`.
   - Sau khi đổi mã thành công, lưu `server_url`, device token và `editor_id` (UUID v4 tạo một lần) vào secure storage. Gỡ app thì mất ghép.
4. **Kiểm tra server:** trước khi ghép, gọi `GET /up` và `GET api/v3/pos_device/me` (khi đã có token). Lỗi TLS, cleartext hay timeout được báo bằng câu dễ hiểu. Cách cấu hình HTTP / HTTPS trên LAN do phần 5B quyết.
5. **Vỏ theo mode:**
   - `GoRouter` có redirect theo `Device.mode` lấy từ `me`. Mỗi mode là một nhánh route riêng, lazy.
   - `waiter` / `owner` bắt buộc qua màn **chọn nhân viên → PIN**.
   - Các mode chạy bằng danh tính máy vào thẳng màn chính, có nút ẩn "Quản lý" (giữ 3 giây, rồi PIN quản lý) để xem thông tin máy và gỡ ghép.
6. **Realtime:**
   - Viết client Action Cable nhỏ trên `web_socket_channel`. Giao thức Action Cable đơn giản (`welcome`, `ping`, `confirm_subscription`, `message`), nên không phụ thuộc gói bên thứ ba ít người bảo trì.
   - Có backoff khi nối lại. Mỗi lần nối lại thì refetch, giống phía web (phase 3).
7. **Trạm in:**
   - `PrintDocument` v1 → ESC/POS dùng `esc_pos_utils_plus`. Bảng mã tiếng Việt: thử in ra ảnh bitmap từng dòng khi máy in không có codepage tiếng Việt; chế độ này là cấu hình trong `Printer.settings`.
   - `PrintDocument` v1 → TSPL cho máy in tem ly khi `Printer.command_language = tspl` (phần 7B dùng cho tem ly), cùng bộ driver LAN / Bluetooth.
   - Ba driver:
     - `SunmiDriver` qua plugin máy in Sunmi (`sunmi_printer_plus` hoặc AIDL qua platform channel nếu plugin không đủ), chỉ Android;
     - `LanDriver` qua `Socket` TCP 9100;
     - `BluetoothDriver` qua `flutter_blue_plus` (BLE) hoặc SPP, tùy loại máy in. Bluetooth Classic trên iOS chỉ dùng được với máy in MFi, nên iOS chỉ hỗ trợ BLE và LAN.
   - Vòng lặp: nhận `print_job.created` hoặc chờ poll 10 giây → `claim` → in → `report printed / failed`.
   - Trạm in giữ màn sáng bằng `wakelock_plus`. Android có foreground service để vẫn chạy khi màn hình tắt; iOS không chạy nền được, nên app hiện cảnh báo "giữ app mở".

### Cấu trúc thư mục

```text
apps/pos-staff/
  pubspec.yaml               # name: parkviet_staff
  lib/
    main.dart, app.dart, router.dart
    core/        # config, secure_storage, api_client, realtime, errors, server_time
    pairing/     # màn chào, quét QR, nhập tay
    auth/        # chọn nhân viên, PIN, session
    modes/
      print_station/  # vòng lặp in, drivers/, escpos_renderer.dart
      kds/ waiter/ expo/ kiosk/ owner/ bridge/   # giữ chỗ
    l10n/        # app_vi.arb, app_en.arb
  packages/pos_api/          # client sinh từ OpenAPI
  tool/gen_api.sh
  test/, integration_test/
  android/, ios/
```

### Server

- Không có endpoint mới.
- Kiểm tra và bổ sung OpenAPI cho mọi endpoint app gọi ở phần này: `pos_device/pair`, `me`, `staff`, `staff_sessions`, `print_jobs/claim`, `print_jobs/:id/report`. Kiểm thêm schema `RealtimeEvent` và `PrintDocument`.
- `device_api/me` trả về `server_time`. App tính độ lệch đồng hồ để hiển thị timer, nhưng không gửi giờ của máy lên làm dữ liệu.

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `apps/pos-staff/**` | create | App Flutter như cấu trúc trên |
| `apps/pos-staff/tool/gen_api.sh` | create | Sinh client từ OpenAPI |
| `.github/workflows/pos-staff-ci.yml` | create | `flutter analyze`, `flutter test`, drift check của client sinh, `flutter build apk --release`, `flutter build ios --no-codesign` (macOS runner) |
| `apps/pos-staff/README.md` | create | Cách chạy, ký app, cấu hình server |
| `server/openapi/pos-staff.yaml` | modify | Bù endpoint còn thiếu |
| `.gitignore` | modify | Build Flutter, `*.jks`, `key.properties` |

### Các bước

1. `flutter create --org vn.parkviet --project-name parkviet_staff --platforms android,ios apps/pos-staff`. Đặt `minSdk` theo yêu cầu của Sunmi SDK và `mobile_scanner`; đặt iOS deployment target theo `mobile_scanner`.
2. Sinh `packages/pos_api`, viết `core/api_client.dart`:
   - interceptor gắn `Authorization: Device`, `X-Pos-Staff-Session` và `Idempotency-Key` cho lệnh ghi;
   - đọc lỗi 409 theo `render_pos_conflict` (`reason`, `current_revision`).
3. Làm ghép máy (QR + nhập tay), secure storage, `me`.
4. Làm chọn nhân viên + PIN, tự đăng xuất sau thời gian không hoạt động.
5. Làm client realtime và trạng thái kết nối dùng chung.
6. Làm trạm in: renderer ESC/POS, 3 driver, vòng lặp claim / report, màn trạng thái (máy in, job gần nhất, lỗi), in thử.
7. Làm i18n vi / en cho mọi chuỗi. Không có chuỗi cứng trong widget.
8. Làm CI và README. Ghi cách ký Android (keystore ngoài repo) và iOS (team / profile của chủ dự án).

### Kiểm thử

- `cd apps/pos-staff && flutter analyze && flutter test`:
  - unit test cho parser payload QR (v lạ, kind lạ, URL không phải http/https);
  - renderer ESC/POS so byte với fixture từ `server/spec/fixtures/print_documents/*.json`;
  - client Action Cable với server giả;
  - interceptor lỗi 409.
- `flutter test integration_test` trên emulator Android:
  - ghép bằng mã nhập tay với server dev;
  - đăng nhập PIN;
  - trạm in nhận job in thử và báo `printed` (driver LAN trỏ tới một TCP server giả).
- Thử tay trên thiết bị thật nếu có: Sunmi (máy in tích hợp), một máy Xprinter LAN, một máy in Bluetooth, một iPhone (ghép + PIN + LAN). Ghi rõ máy nào chưa thử.
- Hồi quy server: `pnpm spree rspec spec/requests/spree/pos/device_api_spec.rb spec/requests/spree/pos/print_jobs_spec.rb`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Plugin Sunmi / Bluetooth không ổn định hoặc bị bỏ bảo trì | Driver nằm sau một interface. Có thể thay bằng platform channel tự viết (Kotlin) mà không đổi vòng lặp in. |
| Máy in rẻ không có font tiếng Việt | Chế độ in ảnh bitmap theo dòng, bật trong cấu hình máy in. |
| iOS không chạy nền cho trạm in | Trạm in khuyến nghị dùng Android. Trên iOS, app cảnh báo và giữ màn sáng. |
| Client sinh từ OpenAPI lệch với server | Drift check trên CI, cộng với request spec kiểm schema (phase 1). |

### Tiêu chí xong

- [ ] App build được cho Android (apk release) và iOS (no-codesign) trên CI.
- [x] Ghép máy bằng QR hoặc nhập tay; lưu địa chỉ server và token an toàn; gỡ ghép được.
- [x] Đăng nhập nhân viên bằng PIN cho mode `waiter` / `owner`.
- [x] Realtime nối được, nối lại được, có refetch.
- [ ] Trạm in in được qua Sunmi, LAN 9100 và Bluetooth; báo `printed` / `failed` về server.
- [x] Client API sinh từ OpenAPI, CI fail khi lệch.
- [x] Toàn bộ chuỗi có bản vi và en.

### Kết quả

Đã làm:

- `apps/pos-staff`: app Flutter `parkviet_staff` (Flutter 3.32.5, Dart 3.8), Riverpod + go_router, mỗi mode là một thư viện deferred. Android `minSdk 23`, `compileSdk 36`, NDK 27, AGP 8.9.1; iOS deployment target 12.0. Quyền camera, Bluetooth, foreground service `connectedDevice` đã khai báo; Info.plist có mô tả camera và Bluetooth.
- Client API `packages/pos_api` sinh bằng openapi-generator 7.27.0 (`dart-dio`, built_value) qua `tool/gen_api.sh`. `PrintDocument` giữ dạng `JsonObject` vì `oneOf` của block không có discriminator; app đọc nó theo schema. Generator không coi `$ref` tới object `additionalProperties: true` là model nên sinh sai code builder lồng nhau: `tool/templates` sửa template đó, còn trường `JsonObject` được sửa bằng một bước perl trong `gen_api.sh`. Chạy sinh hai lần cho kết quả giống hệt.
- `core/api_client.dart`: interceptor gắn `Authorization: Device`, `X-Pos-Staff-Session`, `Idempotency-Key` (UUID mới cho mỗi lệnh ghi, giữ key của caller); lỗi đổi thành `AppFailure`, 409 đọc `details.reason` và `current_revision`. Timeout, TLS, cleartext, không tới được server được tách riêng.
- Ghép máy bằng QR (`v`, `kind`, URL chỉ http/https) hoặc nhập tay; kiểm `/up` trước khi ghép; token và địa chỉ server nằm trong secure storage; `me` đo độ lệch đồng hồ từ `server_time`; 401 xoá ghép và báo máy đã bị thu hồi; gỡ ghép trong trang quản lý (giữ 3 giây trên thanh tiêu đề + PIN quản lý, kiểm quyền `pos.device.manage`).
- Chọn nhân viên + PIN cho `waiter` / `owner`, tự đăng xuất sau 5 phút không chạm hoặc khi phiên hết hạn.
- Client Action Cable: subprotocol `actioncable-v1-json` + token, watchdog ping, nối lại có backoff + jitter, phát `subscribed` sau mỗi lần xác nhận để màn hình refetch; `reject_subscription` hoặc `disconnect` không nối lại thì dừng.
- Trạm in: chuyển `PrintDocument` thành lệnh in giống `packages/pos-shared` print-commands; renderer ESC/POS (text bỏ dấu hoặc in ảnh từng dòng khi `codepage: bitmap`) và TSPL; driver LAN 9100, Sunmi, Bluetooth (Classic SPP qua platform channel Kotlin trên Android, BLE trên Android và iOS); vòng lặp claim / in / report theo `print_job.created`, sau mỗi lần subscribe và mỗi 10 giây; report giữ lại khi mất server và gửi trước lần claim kế; 409 `print_claim_stale` thì bỏ. Màn trạng thái có máy in, job gần nhất, lỗi server, nút in thử; Android giữ màn sáng và chạy foreground service, iOS có cảnh báo.
- Chuỗi giao diện vi / en trong `lib/l10n` (89 khoá mỗi bản).
- `server/openapi/pos-staff.yaml`: bù request/response cho `pair`, `staff`, `staff_sessions`, `context`; `DeviceSession` có `branch`, `register_id`, `kitchen_station_id`, `staff`, `server_time`; thêm `ErrorResponse`, tham số path `id` còn thiếu. Không có endpoint mới, không đổi controller (`me` đã có `server_time`).
- `.github/workflows/pos-staff-ci.yml`: drift check của client, build_runner, `flutter analyze`, `flutter test`, `flutter build apk --release`, `flutter build ios --release --no-codesign` trên macOS. `.gitignore` thêm build Flutter, `*.jks`, `*.keystore`, `key.properties`. `apps/pos-staff/README.md`: chạy app, cấu hình server, sinh client, ký Android (keystore ngoài repo + `key.properties`) và iOS.

Kiểm thử đã chạy:

- `flutter analyze`: No issues found.
- `flutter test`: 74 test pass. Gồm parser payload QR (v lạ, kind lạ, URL không phải http/https, URL có userinfo/query/fragment, thiếu mã); interceptor và lỗi 409 qua adapter giả; lệnh in giống test của web; ESC/POS so byte với golden của 8 fixture `server/spec/fixtures/print_documents/*.json` ở khổ 80mm và 58mm, cùng chế độ bitmap; TSPL; Action Cable với server WebSocket thật chạy local (welcome, subscribe, message, nối lại, bị từ chối); vòng lặp in với queue và driver giả; driver LAN với `ServerSocket` local; redirect của router; ghép máy, máy bị thu hồi, offline.
- `bash tool/gen_api.sh` chạy lại: `lib`, `pubspec.*` của `pos_api` không đổi.
- `flutter build apk --release` trên máy này: build được (`app-release.apk`, ký bằng debug key vì không có `key.properties`). Ổ C gần đầy nên lần build này dùng `GRADLE_USER_HOME=D:\Work\parkviet\.gradle-home-pos-staff`, ngoài repo, có thể xoá.
- Hồi quy server (11/11/2026): `device_api_spec`, `print_jobs_spec`, `devices_spec` và `spec/services/spree/pos/print_documents_spec.rb` đã chạy trong lượt `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/ spec/services/spree/pos/ spec/models/spree/pos/` (738 ví dụ) khi kiểm phần 6A. Không lỗi nào do `pos-staff.yaml` của phần này. Lỗi duy nhất là `devices_spec` "every path has a route": `GET system_status` của phần 5B được thêm vào `pos-staff.yaml` và `routes.rb` lúc lệnh đang chạy. Chạy lại `devices_spec` sau đó: 3/3 qua.

Còn mở:

- Build trên CI chưa chạy (chưa push); build iOS chưa chạy vì không có macOS. Tiêu chí build để mở tới khi workflow chạy xanh.
- `integration_test/app_test.dart` đã viết (ghép bằng mã nhập tay, PIN, trạm in in qua LAN tới TCP server giả và báo `printed`) nhưng chưa chạy: máy này không có emulator Android. Chạy với các `--dart-define` ghi ở đầu file.
- Chưa thử trên thiết bị thật: Sunmi, Xprinter LAN, máy in Bluetooth, iPhone. Tiêu chí in qua Sunmi / LAN / Bluetooth để mở tới khi thử xong; phần LAN và báo `printed` / `failed` mới được kiểm bằng test.
- `flutter_blue_plus` ghim bản 1.x (BSD-3) vì 2.x cần licence trả phí cho dùng thương mại.
- Gỡ ghép trên máy chỉ xoá token ở máy; thu hồi trên server làm ở dashboard.
- Kiểm PIN quản lý mở rồi đóng một phiên nhân viên của chính người đó; nếu server chỉ cho một phiên mỗi người trên máy, phiên đang mở của người đó có thể bị thay.
- Setting `drawer` của máy in chưa dùng (chưa có lệnh mở két trong tài liệu in). Nhãn TSPL lấy kích thước theo nội dung.

## Phần 5B: Triển khai server LAN / VPS

### Overview

Mỗi khách chạy ParkViet trên **server LAN tại quán** (mini PC) hoặc trên **VPS riêng** (D5). Phần này đóng gói một cấu hình triển khai chạy được ở cả hai nơi:
- một image gồm API, dashboard và POS web;
- địa chỉ công khai cấu hình được, và địa chỉ này được nhúng vào QR ghép thiết bị;
- quy tắc HTTP / HTTPS cho LAN;
- sao lưu và health check;
- đường ra internet cho những việc bắt buộc cần internet: webhook VietQR, hóa đơn điện tử, đơn nền tảng.

Hiện trạng đã kiểm:
- `server/Dockerfile` build API kèm `apps/dashboard`, phục vụ cùng origin ở `/dashboard`. **`apps/pos` chưa có trong image.**
- `render.yaml` mô tả một web service cùng Postgres, health check `/up`.
- `docker-compose.yml` là cấu hình dev (bind mount).
- Docs Spree CLI ở `node_modules/@spree/docs/dist/developer/cli/` chỉ có `quickstart.md` và `admin-api.md`. Phải đọc để biết CLI có lệnh build / deploy production không, trước khi tự viết compose.

### Quyết định

1. **Một image** cho cả hai nơi triển khai:
   - Thêm stage build `apps/pos` (Vite, `VITE_BASE_PATH=/pos/`) vào `server/Dockerfile`, đi theo mẫu stage `dashboard`.
   - Rails phục vụ file tĩnh ở `/pos`.
   - Cùng origin với API, nên không cần CORS. Token realtime trong query (phase 3) cũng đi cùng origin.
2. **Compose cho production** `deploy/docker-compose.prod.yml` gồm `web` (Puma + Solid Queue trong Puma, như hiện tại), `postgres`, `caddy` (reverse proxy) và tùy chọn `cloudflared`. File `.env.prod.example` liệt kê biến, không chứa giá trị thật.
3. **Địa chỉ công khai:**
   - `POS_PUBLIC_BASE_URL` là địa chỉ mà thiết bị dùng để gọi tới server: ví dụ `http://192.168.1.10` hoặc `http://pos.local` trên LAN, `https://pos.quan-a.vn` trên VPS.
   - QR ghép (phase 2) dùng giá trị này.
   - Trang "Thông tin server" trong cài đặt web hiện địa chỉ này cùng trạng thái các kết nối ra ngoài.
4. **HTTP hay HTTPS:**
   - **VPS:** bắt buộc HTTPS. Caddy tự lấy chứng chỉ Let's Encrypt.
   - **LAN:** mặc định **HTTP trên IP tĩnh hoặc tên `.local`**. Lý do: chứng chỉ tự ký buộc phải cài CA lên từng thiết bị, quá khó với chủ quán. App Flutter cho phép cleartext như sau:
     - Android: `network_security_config.xml` cho phép cleartext. Android không giới hạn theo dải IP được, nên app chỉ chấp nhận URL `http://` khi host là IP private (10/8, 172.16/12, 192.168/16) hoặc tên `.local`. Kiểm tra này nằm trong code ghép máy.
     - iOS: `NSAppTransportSecurity` → `NSAllowsLocalNetworking = true`, cùng `NSLocalNetworkUsageDescription`.
   - Tùy chọn nâng cao: HTTPS trên LAN bằng Caddy `tls internal`, kèm hướng dẫn cài CA. Bật bằng biến môi trường.
   - Web `apps/pos` trên LAN chạy HTTP. Nhờ vậy adapter Epson / Star (phase 4) gọi HTTP tới máy in mà không bị chặn mixed content.
5. **Ra internet:**
   - **Webhook VietQR:** bật `cloudflared` tunnel cho riêng path webhook (ingress rule chỉ cho path đó). Không có tunnel thì dùng **polling** nhà cung cấp (SePay / PayOS có API tra giao dịch), qua job `server/app/jobs/spree/pos/poll_bank_transactions_job.rb` nếu gem VietQR chưa có. Kiểm trong plan VietQR trước khi viết. Xác nhận tay vẫn luôn còn.
   - **Hóa đơn điện tử và đơn nền tảng** là lời gọi ra ngoài: đi qua hàng đợi chạy lại (phần 6C, 7C). Mất internet thì đơn vẫn complete bình thường.
   - Trang trạng thái hiện số việc đang chờ gửi ra ngoài.
6. **Sao lưu:**
   - Service `backup` chạy `pg_dump` hằng đêm vào volume `backups/`, giữ 14 bản.
   - Tùy chọn đẩy lên S3-compatible (`rclone`) khi có internet.
   - Có script khôi phục, và hướng dẫn **thử khôi phục** mỗi quý.
7. **Health:** dùng `/up` (đã có) cho Caddy và Docker healthcheck. Thêm `GET api/v3/admin/pos/system_status` (quyền quản lý), trả về:
   - phiên bản;
   - trạng thái DB và Solid Queue;
   - độ trễ realtime gần nhất;
   - số `PrintJob` lỗi;
   - số việc chờ gửi ra ngoài;
   - thời điểm sao lưu gần nhất.

### Server

- `server/Dockerfile`: stage `pos`, copy `dist` vào `public/pos`. Kiểm route catch-all không nuốt mất `/pos/*`.
- `server/config/routes.rb`: fallback SPA cho `/pos/*` → `public/pos/index.html`.
- `server/app/controllers/spree/api/v3/admin/pos/system_status_controller.rb`.
- `server/config/initializers/pos_public_url.rb`: đọc và validate `POS_PUBLIC_BASE_URL`, dùng ở phase 2.
- `config/environments/production.rb`: `config.hosts` nhận IP LAN và tên `.local`; `assume_ssl` / `force_ssl` theo biến `POS_TLS_MODE` (`none|internal|public`).
- OpenAPI: `SystemStatus`.

### Client

- Web: `apps/pos/src/pages/settings/system.tsx` hiện địa chỉ server, chế độ TLS, trạng thái realtime / in / gửi ra ngoài / sao lưu.
- Flutter (`apps/pos-staff`):
  - kiểm `http://` chỉ cho host private, như quyết định 4;
  - `android/app/src/main/res/xml/network_security_config.xml`;
  - `ios/Runner/Info.plist` (`NSAllowsLocalNetworking`, `NSLocalNetworkUsageDescription`, `NSCameraUsageDescription`, `NSBluetoothAlwaysUsageDescription`).

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/Dockerfile` | modify | Stage build `apps/pos` |
| `deploy/docker-compose.prod.yml`, `deploy/Caddyfile`, `deploy/.env.prod.example` | create | Stack production |
| `deploy/cloudflared/config.example.yml` | create | Tunnel chỉ cho webhook |
| `deploy/scripts/backup.sh`, `restore.sh`, `install-lan.sh` | create | Sao lưu, khôi phục, cài mini PC |
| `server/config/routes.rb`, `config/environments/production.rb`, `config/initializers/pos_public_url.rb` | modify / create | URL, host, TLS |
| `server/app/controllers/spree/api/v3/admin/pos/system_status_controller.rb` | create | Trạng thái hệ thống |
| `apps/pos/src/pages/settings/system.tsx` | create | Trang thông tin server |
| `apps/pos-staff/android/.../network_security_config.xml`, `ios/Runner/Info.plist`, `lib/pairing/*` | modify | Cleartext an toàn |
| `docs/deploy/pos-lan-vps.md` | create | Hướng dẫn cho người lắp đặt |

### Các bước

1. Đọc `node_modules/@spree/docs/dist/developer/cli/quickstart.md` và docs deploy của Spree (có thể qua MCP `spree-docs`) để biết cách chạy production mà dự án hỗ trợ. Nếu CLI có lệnh tương ứng thì dùng, không tự chế lại.
2. Thêm stage `apps/pos` vào Dockerfile; build thử image và mở `/pos`.
3. Viết compose production, Caddyfile, file env mẫu; chạy thử trên một máy Linux (hoặc VM) ở chế độ LAN-HTTP và VPS-HTTPS.
4. Viết `POS_PUBLIC_BASE_URL` và nối vào QR ghép.
5. Cấu hình cleartext trong app Flutter, rồi thử ghép một máy Android và một iPhone vào server LAN qua HTTP.
6. Làm tunnel webhook và / hoặc polling VietQR; thử một giao dịch thật hoặc sandbox.
7. Làm sao lưu và khôi phục, rồi thử khôi phục vào DB trống.
8. Làm system status và trang web.
9. Viết `docs/deploy/pos-lan-vps.md`, gồm:
   - phần cứng tối thiểu (mini PC, RAM, SSD, UPS);
   - đặt IP tĩnh trên router;
   - các bước cài;
   - cập nhật phiên bản;
   - sao lưu / khôi phục;
   - xử lý sự cố mất internet.

### Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/system_status_spec.rb spec/initializers/pos_public_url_spec.rb`
- `cd apps/pos-staff && flutter test`: kiểm tra URL (ví dụ `http://192.168.1.10` được nhận, `http://example.com` bị từ chối, `https://example.com` được nhận).
- Thử tay theo checklist trong `docs/deploy/pos-lan-vps.md`:
  - rút dây WAN của router, thu ngân vẫn bán tiền mặt và trạm in vẫn in;
  - cắm lại thì các việc chờ gửi ra ngoài chạy hết.
- Hồi quy: `pnpm --dir apps/pos build` với `VITE_BASE_PATH=/pos/`; `pnpm --dir apps/pos test:e2e`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| HTTP trên LAN để lộ token trong mạng Wi-Fi của quán | Khuyến nghị Wi-Fi riêng cho thiết bị POS, tách khỏi Wi-Fi khách; có tùy chọn `tls internal`. Ghi rõ trong hướng dẫn. |
| Mini PC hỏng làm mất dữ liệu | Sao lưu hằng đêm, đẩy ra ngoài khi có mạng, thử khôi phục định kỳ. |
| IP của mini PC đổi làm thiết bị mất kết nối | Hướng dẫn đặt IP tĩnh / DHCP reservation. Trên VPS thì dùng tên miền. Đổi `POS_PUBLIC_BASE_URL` cần ghép lại máy: ghi trong hướng dẫn. |
| Tunnel mở rộng bề mặt tấn công | Ingress chỉ cho path webhook, có xác thực chữ ký webhook như gem VietQR đang làm. |

### Tiêu chí xong

- [x] Một image phục vụ API, `/dashboard` và `/pos`.
- [ ] Stack production chạy được ở chế độ LAN-HTTP và VPS-HTTPS; có file env mẫu, không có secret trong repo.
- [ ] QR ghép chứa `POS_PUBLIC_BASE_URL`; app Android và iOS ghép được qua HTTP LAN, và từ chối HTTP tới host công khai.
- [ ] Mất internet vẫn bán và in được; VietQR có tunnel hoặc polling, xác nhận tay vẫn còn.
- [ ] Sao lưu hằng đêm và khôi phục đã thử.
- [x] Có `docs/deploy/pos-lan-vps.md` và trang trạng thái hệ thống.

### Kết quả

Spree CLI: `spree build --production` chỉ build cùng image như `docker build -f server/Dockerfile .`; CLI không có lệnh deploy. Docs deploy của Spree (`deployment/docker.md`) chạy production bằng docker compose thường với reverse proxy chỉ mở 80/443, nên phần này viết compose riêng theo mẫu đó.

Đã làm:

- **Image** (`server/Dockerfile`): stage `pos-web` build `apps/pos` (`VITE_BASE_PATH=/pos/`, `VITE_POS_DASHBOARD_URL=/pos-admin/`) và `apps/pos-dashboard` (`VITE_BASE_PATH=/pos-admin/`), cài `packages/pos-shared` trước. Stage cuối copy vào `/rails/pos-web`, `/rails/pos-admin`, đặt `POS_WEB_DIST_PATH`, `POS_ADMIN_DIST_PATH`, `PARKVIET_VERSION`. `.dockerignore` loại `.env`, `deploy/.env.prod`, `apps/pos-staff`, `dist`, `backups`, `plans`.
- **Phục vụ SPA:** `Spree::Pos::SellingAppController` (`/pos`, `/pos/*path`) và `Spree::Pos::AdminAppController` (`/pos-admin`, `/pos-admin/*path`) kế thừa `Spree::Dashboard::SpaController`: fallback `index.html` (no-cache), asset có hash cache immutable, chặn path ra ngoài thư mục; 404 khi biến chưa đặt (dev). Route đặt trước `root`, không đè `/api`, `/cable`, `/dashboard`.
- **Địa chỉ công khai:** `server/lib/parkviet/pos_public_url.rb` + `config/initializers/pos_public_url.rb`. Chuẩn hoá `POS_PUBLIC_BASE_URL` thành origin; từ chối scheme khác http(s), userinfo, path, query, fragment, và `http://` tới host không private; `POS_TLS_MODE` (`none|internal|public`) phải khớp scheme. Giá trị sai làm boot lỗi. QR ghép (`DeviceAuthenticator.public_base_url`) dùng giá trị này, chưa đặt thì dùng `request.base_url` như cũ.
- **`production.rb`:** `assume_ssl` / `force_ssl` theo `POS_TLS_MODE` (chưa đặt thì giữ `RAILS_ASSUME_SSL` / `RAILS_FORCE_SSL`); khi có `POS_PUBLIC_BASE_URL` thì bật host authorization: host của URL, `SPREE_HOST`, `POS_EXTRA_HOSTS`; chế độ `none` / `internal` nhận thêm mọi IPv4 private và tên `.local`; `/up` được miễn. `default_url_options` lấy host từ URL công khai.
- **Stack** `deploy/`: `docker-compose.prod.yml` (`postgres` không mở cổng, `web`, `caddy` 80/443, `backup`; `cloudflared` và `offsite` (rclone) theo profile), `Caddyfile` (3 chế độ TLS chọn bằng `POS_TLS_MODE`, `stream_close_delay` cho WebSocket), `.env.prod.example` (chỉ placeholder `change-me`), `cloudflared/config.example.yml` (ingress chỉ `^/webhooks/payments/(sepay|payos)$`, còn lại 404). `.gitignore` thêm `deploy/.env.prod` và file tunnel thật.
- **Script:** `backup.sh` (`once` / `loop`; `pg_dump -Fc` vào file `.partial`, kiểm bằng `pg_restore --list`, đổi tên, giữ `BACKUP_KEEP` bản; loop chạy sau `BACKUP_AT` mỗi ngày một lần), `restore.sh` (`--drill` khôi phục vào DB tạm, kiểm schema / stores / orders rồi xoá; `--replace` bắt gõ `RESTORE`, dừng web, sao lưu an toàn, khôi phục, kiểm, chạy lại web), `install-lan.sh` (đoán IP LAN, sinh secret bằng openssl không in ra, `.env.prod` chmod 600, `--update`).
- **System status:** `GET /api/v3/admin/pos/system_status` (`Spree::Pos::SystemStatus`), quyền `read_pos_topology` / `write_pos_topology`, `Cache-Control: no-store`. Trả phiên bản; URL công khai và chế độ TLS; DB (độ trễ); Solid Queue (process còn heartbeat, việc sẵn sàng và tuổi việc cũ nhất, việc lỗi); realtime (đo bằng một lần pub/sub qua adapter Action Cable); in (job chờ, tuổi job cũ nhất, lỗi 24 giờ); việc chờ gửi ra ngoài (`OutboxEntry` pending/processing/failed); VietQR (webhook gần nhất, số chưa khớp); sao lưu (số file `parkviet-*.dump` và thời điểm mới nhất trong `POS_BACKUP_DIR`). Schema `SystemStatus` trong `server/openapi/pos-staff.yaml`.
- **Trang web:** `apps/pos-dashboard` `/<store>/settings/system` (`src/pages/system-status.tsx`, `hooks/use-system-status.ts`), mục "Thông tin server" trong cài đặt và nav, tự làm mới 30 giây, đánh dấu "cần chú ý" khi DB / job / realtime lỗi, realtime > 2 giây, có job in / gửi lỗi, sao lưu cũ hơn 36 giờ hoặc chưa cấu hình. Chuỗi vi / en.
- **`apps/pos`:** `VITE_POS_DASHBOARD_URL` nhận path tương đối (`/pos-admin/`) và ghép với origin hiện tại.
- **Flutter:** `normalizeServerUrl` từ chối `http://` tới host không phải IPv4 private hoặc `.local` (lỗi `insecureUrl`, chuỗi `pairingInsecureUrl`); `network_security_config.xml` (cho cleartext, tin CA hệ thống và CA người dùng cài cho `tls internal`) và tham chiếu trong `AndroidManifest.xml`; `Info.plist` thêm `NSLocalNetworkUsageDescription`, `NSAllowsLocalNetworking` (camera và Bluetooth đã có).
- **Docs:** `docs/deploy/pos-lan-vps.md`: chọn LAN / VPS, phần cứng (4 nhân, 8 GB RAM, SSD 128 GB, UPS), IP tĩnh / DHCP reservation, cài LAN và VPS, HTTPS trên LAN và cài CA, ghép app, đường ra internet, checklist mất internet, sao lưu / đẩy ra ngoài / thử khôi phục hằng quý, cập nhật, xử lý sự cố.

Khác với plan:

- Trang thông tin server nằm ở `apps/pos-dashboard`, không ở `apps/pos/src/pages/settings/system.tsx`: đây là việc của người quản trị, đã có kiểm quyền theo capability ở đó. Trang chỉ hiện cho người có `read_pos_topology` / `write_pos_topology`.
- SPA không copy vào `public/pos` mà phục vụ qua controller kế thừa `SpaController` của `spree_dashboard` (cùng cách `/dashboard`), để có fallback deep link và cache header đúng. Image cũng mang luôn POS quản trị ở `/pos-admin`, vì nút sang quản trị của `apps/pos` cần cùng origin.
- Validator ở `server/lib/parkviet/` (ngoài autoload) vì `production.rb` cần nó trước khi autoload chạy; initializer chỉ gọi nó để boot lỗi sớm.
- **Không viết job polling VietQR:** gem `spree_vietqr` chỉ nhận webhook (SePay, PayOS, có kiểm chữ ký), chưa có client tra giao dịch. Không tự chế client nhà cung cấp. Đường đi hiện tại: tunnel cho webhook, hoặc xác nhận tay. Polling để mở.
- Độ trễ realtime là phép đo pub/sub phía server mỗi lần gọi status, không phải số đo từ thiết bị.
- `apps/pos-staff/test/session_test.dart` đổi URL test `http://pos.test` thành `http://pos.local` vì kiểm tra mới từ chối host công khai qua HTTP.

Lệnh đã chạy:

- `pnpm spree rspec spec/initializers/pos_public_url_spec.rb spec/requests/spree/pos/system_status_spec.rb spec/requests/spree/pos/web_apps_spec.rb`: 24 ví dụ, 0 lỗi. `devices_spec`, `device_api_spec`, `print_documents_spec`: 21 ví dụ, 0 lỗi. Sau khi rubocop sửa style (`ENV.fetch`, modifier if), chạy lại (sau khi migration của phần thực đơn chạy song song đã được áp) `pnpm spree rspec spec/initializers/pos_public_url_spec.rb spec/requests/spree/pos/system_status_spec.rb spec/requests/spree/pos/web_apps_spec.rb spec/requests/spree/pos/devices_spec.rb`: 27 ví dụ, 0 lỗi.
- `pnpm spree exec rubocop` trên file server mới: không lỗi.
- Boot production thử bằng `pnpm spree exec` với `RAILS_ENV=production bin/rails runner`: chế độ LAN (`http://192.168.1.10`, `none`) → `force_ssl=false`, hosts gồm IP, dải private, `.local`, QR `http://192.168.1.10`; chế độ VPS (`https://pos.example.vn`, `public`) → `force_ssl`/`assume_ssl` true, hosts chỉ tên miền; chưa đặt → không bật host authorization; `http://` tới host công khai → boot lỗi `Invalid` như mong muốn.
- `flutter analyze`: No issues found. `flutter test`: 76 pass.
- `apps/pos-dashboard`: `pnpm typecheck` qua, `pnpm test` 15 file / 87 test qua, biome trên file đổi sạch, `pnpm build` qua (cả với `VITE_BASE_PATH=/pos-admin/`).
- `apps/pos`: vitest `pos-dashboard-url` 7 qua; `pnpm build` với `VITE_BASE_PATH=/pos/ VITE_POS_DASHBOARD_URL=/pos-admin/` qua, `index.html` nạp `/pos/assets/...`.
- `docker build --target pos-web -f server/Dockerfile .`: qua (~2 phút), `/out/pos` và `/out/pos-admin` có `index.html` và asset đúng base. Image đã xoá, không push.
- `docker build -f server/Dockerfile .` (image đầy đủ): **lỗi** ở bước `assets:precompile` có sẵn của stage `build`: `config/initializers/spree.rb` dòng 50 gọi `ActiveRecord::Base.connection.table_exists?(:spree_pos_discount_intents)` trong `after_initialize`, mà lúc build không có DB (`ActiveRecord::ConnectionNotEstablished`). Lỗi có từ commit trước, không do phần này; stage `pos-web` và các stage trước đã qua. Không sửa vì file thuộc phần khuyến mãi và đang có agent khác làm song song. Cách sửa gợi ý: bỏ qua kiểm tra khi `SECRET_KEY_BASE_DUMMY` được đặt, hoặc rescue `ActiveRecord::ConnectionNotEstablished` / `ActiveRecord::NoDatabaseError`, hoặc đăng ký adjuster không phụ thuộc bảng. Không có image nào được tạo hay push.
- Thử sao lưu / khôi phục trong container `postgres:18-alpine` dùng xong bỏ, dữ liệu từ một bản dump dev: `backup.sh once` ba lần với `BACKUP_KEEP=2` giữ đúng 2 bản; khôi phục vào DB trống 6 giây, schema `20261110180500`, 7 store, 62 đơn, khớp nguồn.
- Playwright `e2e/system-status.spec.ts --project desktop` (4 test) **chưa chạy được**: cổng 5176 đang do Vite dev server của người dùng giữ. Không dừng process đó.

Review: phát hiện và cách sửa

- `.dockerignore` chỉ loại `backups` ở gốc: thêm `**/backups`, `deploy/cloudflared/` (cả file config mẫu, image không cần), `deploy/.env*`. Kiểm bằng build context xuất ra thư mục local (`FROM scratch`, `COPY deploy`, `--output type=local`, không tạo image): `deploy/` chỉ còn `Caddyfile`, `docker-compose.prod.yml`, `scripts/`; `deploy/backups/` và `apps/pos/backups/` tạo thử đều bị loại.
- `restore.sh --replace`: bản an toàn chạy `backup.sh once` có prune, có thể xoá chính file đang khôi phục sau khi DB đã bị drop. Giờ `backup.sh once --no-prune` không xoá gì; file nguồn được chép ra file tạm và kiểm bằng `pg_restore --list` trước khi dừng `web`; script đọc tên bản an toàn từ log, bản an toàn lỗi thì chạy lại `web` và dừng trước DROP; trap `ERR` sau DROP in tên bản an toàn và lệnh khôi phục.
- `spree.rb`: rescue quanh `table_exists?(:spree_pos_discount_intents)` chỉ nuốt lỗi khi có `SECRET_KEY_BASE_DUMMY` (lúc precompile); ngoài ra raise, DB sập lúc boot thì boot lỗi thay vì chạy thiếu adjuster POS.
- `production.rb`: chế độ `internal` tắt HSTS (`ssl_options` gộp `hsts: false`), quay về HTTP không khoá trình duyệt.
- `apps/pos-staff`: `android:allowBackup="false"` và `dataExtractionRules` (`res/xml/data_extraction_rules.xml`) loại mọi miền khỏi cloud backup và chuyển máy (Android 12+). `forgetPreviousInstall` (`lib/core/secure_storage.dart`, gọi trong `main.dart`): lần chạy đầu sau khi cài, không có cờ `installed` trong SharedPreferences thì xoá hết secure storage (Keychain iOS còn sau khi gỡ app). Thêm `shared_preferences` thành dependency trực tiếp (đã có trong lock, cùng bản 2.5.3). Test `test/secure_storage_test.dart`.
- `isPrivateHost` (Dart) từ chối octet IPv4 có số 0 đứng đầu (`010.0.0.1`, `172.016.0.1`); server vốn đã từ chối qua `IPAddr`. Test mới.
- `pos_public_url.rb`: có `POS_PUBLIC_BASE_URL` mà không có `POS_TLS_MODE` thì lấy chế độ từ scheme (`http` → `none`, `https` → `public`), nên SSL và danh sách host luôn theo địa chỉ, không âm thầm mở dải private cho địa chỉ `https`. Spec thêm 2 ví dụ.
- `backup.sh`: `umask 077`, file dump chỉ chủ sở hữu đọc được.
- Vòng in: `LanDriver` coi timeout khi đóng socket sau khi flush xong là đã in (không báo lỗi để rồi in lại); có seam `connect` để test. Báo cáo chờ gửi nằm trong `PendingPrintReport` của provider `pendingPrintReportProvider` (keepAlive), không mất khi `printLoop` dựng lại vì đổi phiên hay realtime. Test: socket treo lúc đóng (đã in), socket treo lúc flush (lỗi), báo cáo giữ lại được loop mới gửi trước lần claim đầu.
- `packageManager: pnpm@10.33.4` (khớp gốc repo, `apps/pos-dashboard`, `apps/storefront`) cho `apps/pos` và `packages/pos-shared`; corepack trong stage `pos-web` giờ dùng đúng bản này. Không đổi lockfile.
- `SystemStatus`: kết quả probe realtime được cache 30 giây (`Rails.cache`, Solid Cache ở production), các tab đang poll dùng chung một lần đo; `measured_at` là lúc đo. Webhook VietQR: model không có cột store, chỉ nối store qua `payment_method` (`store_id`); số đếm giờ lấy sự kiện của các phương thức VietQR của store cộng sự kiện chưa gắn phương thức (bị từ chối hoặc chưa khớp trước khi xác định được phương thức), giống danh sách webhook events của admin. Sự kiện không có phương thức vẫn hiện ở mọi store.
- Nhỏ: CI `pos-staff-ci.yml` chạy push / pull_request mọi nhánh, lọc theo path. `offsite` chỉ nhận các biến `RCLONE_*` thay vì cả `.env.prod`; ghim `cloudflare/cloudflared:2026.10.7`, `rclone/rclone:1.75.2`. `install-lan.sh` giữ cổng khác 443 trong `POS_CADDY_SITE` ở chế độ public. Initializer `production_secrets.rb`: production (trừ lúc precompile) không boot khi `SECRET_KEY_BASE`, `POSTGRES_PASSWORD`, ba khoá `ACTIVE_RECORD_ENCRYPTION_*` hoặc `MISSION_CONTROL_PASSWORD` còn giá trị bắt đầu bằng `change-me`; chỉ nêu tên biến. Khoá `RCLONE_*` không bị kiểm vì `offsite` là tuỳ chọn.
- Docs `docs/deploy/pos-lan-vps.md` cập nhật: HSTS ở `internal`, chế độ TLS suy từ scheme, lỗi `change-me`, biến của `offsite`, hành vi mới của `restore.sh --replace` (file dump chỉ root đọc được).
- `docker build -f server/Dockerfile .` (image đầy đủ) giờ **qua**: controller đã kiểm sau khi sửa `spree.rb`.

Lệnh đã chạy sau review: `pnpm spree rspec spec/initializers/pos_public_url_spec.rb spec/requests/spree/pos/system_status_spec.rb spec/requests/spree/pos/web_apps_spec.rb`: 28 ví dụ, 0 lỗi (cả seed 10784 từng lộ lỗi do test cache stub `Rails.cache` khi controller auth nạp lần đầu; test đó giờ gọi thẳng service). `flutter analyze`: No issues found. `flutter test`: 82 pass. `pnpm --dir apps/pos exec tsc --noEmit`: qua. `bash -n` cho `backup.sh`, `restore.sh`, `install-lan.sh`: qua; chạy `backup.sh` với `pg_dump` giả: `--no-prune` giữ bản cũ, `once` thường vẫn prune, tham số lạ thoát 2. Shellcheck không có trên máy.

Còn mở:

- Chưa chạy stack trên mini PC hay VM Linux thật ở chế độ LAN-HTTP, chưa chạy VPS với Let's Encrypt; `Caddyfile` chưa được `caddy validate`. Tiêu chí stack production để mở.
- Chưa ghép Android / iPhone thật qua HTTP LAN; cần kiểm `NSAllowsLocalNetworking` với địa chỉ IP trên iOS (ATS có thể chỉ miễn cho tên `.local`, khi đó cần thêm `NSExceptionDomains` hoặc dùng `tls internal`). Tiêu chí ghép để mở; phần từ chối HTTP tới host công khai đã có test ở app và server.
- Chưa thử tunnel cloudflared và giao dịch VietQR thật / sandbox; polling chưa làm (không có client tra giao dịch). Checklist rút WAN chưa chạy tay. Tiêu chí mất internet để mở.
- Service `backup` dạng loop chưa quan sát qua đêm; khôi phục mới thử trong container tạm, chưa trên stack thật. Tiêu chí sao lưu để mở.
- Client Dart `packages/pos_api` cần sinh lại bằng `tool/gen_api.sh` vì `pos-staff.yaml` đổi (drift check CI sẽ báo).
- `pnpm --dir apps/pos test:e2e` đầy đủ chưa chạy.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
