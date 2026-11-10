---
phase: 5
title: "Khung app Flutter, trạm in"
status: pending
effort: "9 ngày"
dependsOn: [2, 3, 4]
---

# Phase 5: Khung app Flutter, trạm in

## Overview

Phase này dựng app Flutter nhiều chế độ `apps/pos-staff` (package `parkviet_staff`) cho Android và iOS (D3). Bản đầu có đủ phần khung mà mọi chế độ cần:
- cấu hình địa chỉ server;
- ghép thiết bị bằng QR;
- đăng nhập nhân viên bằng PIN;
- vỏ điều hướng theo mode;
- client API sinh từ OpenAPI;
- realtime;
- i18n.

Chế độ đầu tiên chạy thật là **trạm in** (`print_station`): nhận `PrintJob` và in ra máy in Sunmi tích hợp, ESC/POS qua LAN và ESC/POS qua Bluetooth. Các chế độ khác chỉ là màn giữ chỗ, và các phase sau làm thật: KDS ở phase 9, phục vụ ở phase 15, chạy bàn ở phase 18, kiosk ở phase 23, chủ quán ở phase 24, bridge ở phase 26.

## Quyết định của phase

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
4. **Kiểm tra server:** trước khi ghép, gọi `GET /up` và `GET api/v3/pos_device/me` (khi đã có token). Lỗi TLS, cleartext hay timeout được báo bằng câu dễ hiểu. Cách cấu hình HTTP / HTTPS trên LAN do phase 6 quyết.
5. **Vỏ theo mode:**
   - `GoRouter` có redirect theo `Device.mode` lấy từ `me`. Mỗi mode là một nhánh route riêng, lazy.
   - `waiter` / `owner` bắt buộc qua màn **chọn nhân viên → PIN**.
   - Các mode chạy bằng danh tính máy vào thẳng màn chính, có nút ẩn "Quản lý" (giữ 3 giây, rồi PIN quản lý) để xem thông tin máy và gỡ ghép.
6. **Realtime:**
   - Viết client Action Cable nhỏ trên `web_socket_channel`. Giao thức Action Cable đơn giản (`welcome`, `ping`, `confirm_subscription`, `message`), nên không phụ thuộc gói bên thứ ba ít người bảo trì.
   - Có backoff khi nối lại. Mỗi lần nối lại thì refetch, giống phía web (phase 3).
7. **Trạm in:**
   - `PrintDocument` v1 → ESC/POS dùng `esc_pos_utils_plus`. Bảng mã tiếng Việt: thử in ra ảnh bitmap từng dòng khi máy in không có codepage tiếng Việt; chế độ này là cấu hình trong `Printer.settings`.
   - `PrintDocument` v1 → TSPL cho máy in tem ly khi `Printer.command_language = tspl` (phase 10 dùng cho tem ly), cùng bộ driver LAN / Bluetooth.
   - Ba driver:
     - `SunmiDriver` qua plugin máy in Sunmi (`sunmi_printer_plus` hoặc AIDL qua platform channel nếu plugin không đủ), chỉ Android;
     - `LanDriver` qua `Socket` TCP 9100;
     - `BluetoothDriver` qua `flutter_blue_plus` (BLE) hoặc SPP, tùy loại máy in. Bluetooth Classic trên iOS chỉ dùng được với máy in MFi, nên iOS chỉ hỗ trợ BLE và LAN.
   - Vòng lặp: nhận `print_job.created` hoặc chờ poll 10 giây → `claim` → in → `report printed / failed`.
   - Trạm in giữ màn sáng bằng `wakelock_plus`. Android có foreground service để vẫn chạy khi màn hình tắt; iOS không chạy nền được, nên app hiện cảnh báo "giữ app mở".

## Cấu trúc thư mục

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

## Server

- Không có endpoint mới.
- Kiểm tra và bổ sung OpenAPI cho mọi endpoint app gọi ở phase này: `pos_device/pair`, `me`, `staff`, `staff_sessions`, `print_jobs/claim`, `print_jobs/:id/report`. Kiểm thêm schema `RealtimeEvent` và `PrintDocument`.
- `device_api/me` trả về `server_time`. App tính độ lệch đồng hồ để hiển thị timer, nhưng không gửi giờ của máy lên làm dữ liệu.

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `apps/pos-staff/**` | create | App Flutter như cấu trúc trên |
| `apps/pos-staff/tool/gen_api.sh` | create | Sinh client từ OpenAPI |
| `.github/workflows/pos-staff-ci.yml` | create | `flutter analyze`, `flutter test`, drift check của client sinh, `flutter build apk --release`, `flutter build ios --no-codesign` (macOS runner) |
| `apps/pos-staff/README.md` | create | Cách chạy, ký app, cấu hình server |
| `server/openapi/pos-staff.yaml` | modify | Bù endpoint còn thiếu |
| `.gitignore` | modify | Build Flutter, `*.jks`, `key.properties` |

## Các bước

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

## Kiểm thử

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

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Plugin Sunmi / Bluetooth không ổn định hoặc bị bỏ bảo trì | Driver nằm sau một interface. Có thể thay bằng platform channel tự viết (Kotlin) mà không đổi vòng lặp in. |
| Máy in rẻ không có font tiếng Việt | Chế độ in ảnh bitmap theo dòng, bật trong cấu hình máy in. |
| iOS không chạy nền cho trạm in | Trạm in khuyến nghị dùng Android. Trên iOS, app cảnh báo và giữ màn sáng. |
| Client sinh từ OpenAPI lệch với server | Drift check trên CI, cộng với request spec kiểm schema (phase 1). |

## Tiêu chí xong

- [ ] App build được cho Android (apk release) và iOS (no-codesign) trên CI.
- [ ] Ghép máy bằng QR hoặc nhập tay; lưu địa chỉ server và token an toàn; gỡ ghép được.
- [ ] Đăng nhập nhân viên bằng PIN cho mode `waiter` / `owner`.
- [ ] Realtime nối được, nối lại được, có refetch.
- [ ] Trạm in in được qua Sunmi, LAN 9100 và Bluetooth; báo `printed` / `failed` về server.
- [ ] Client API sinh từ OpenAPI, CI fail khi lệch.
- [ ] Toàn bộ chuỗi có bản vi và en.
