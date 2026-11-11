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
- [ ] Ghép máy bằng QR hoặc nhập tay; lưu địa chỉ server và token an toàn; gỡ ghép được.
- [ ] Đăng nhập nhân viên bằng PIN cho mode `waiter` / `owner`.
- [ ] Realtime nối được, nối lại được, có refetch.
- [ ] Trạm in in được qua Sunmi, LAN 9100 và Bluetooth; báo `printed` / `failed` về server.
- [ ] Client API sinh từ OpenAPI, CI fail khi lệch.
- [ ] Toàn bộ chuỗi có bản vi và en.

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

- [ ] Một image phục vụ API, `/dashboard` và `/pos`.
- [ ] Stack production chạy được ở chế độ LAN-HTTP và VPS-HTTPS; có file env mẫu, không có secret trong repo.
- [ ] QR ghép chứa `POS_PUBLIC_BASE_URL`; app Android và iOS ghép được qua HTTP LAN, và từ chối HTTP tới host công khai.
- [ ] Mất internet vẫn bán và in được; VietQR có tunnel hoặc polling, xác nhận tay vẫn còn.
- [ ] Sao lưu hằng đêm và khôi phục đã thử.
- [ ] Có `docs/deploy/pos-lan-vps.md` và trang trạng thái hệ thống.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
