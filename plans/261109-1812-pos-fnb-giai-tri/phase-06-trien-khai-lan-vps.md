---
phase: 6
title: "Triển khai server LAN / VPS"
status: pending
effort: "4 ngày"
dependsOn: [2, 5]
---

# Phase 6: Triển khai server LAN / VPS

## Overview

Mỗi khách chạy ParkViet trên **server LAN tại quán** (mini PC) hoặc trên **VPS riêng** (D5). Phase này đóng gói một cấu hình triển khai chạy được ở cả hai nơi:
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

## Quyết định của phase

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
   - **Hóa đơn điện tử và đơn nền tảng** là lời gọi ra ngoài: đi qua hàng đợi chạy lại (phase 7, 25). Mất internet thì đơn vẫn complete bình thường.
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

## Server

- `server/Dockerfile`: stage `pos`, copy `dist` vào `public/pos`. Kiểm route catch-all không nuốt mất `/pos/*`.
- `server/config/routes.rb`: fallback SPA cho `/pos/*` → `public/pos/index.html`.
- `server/app/controllers/spree/api/v3/admin/pos/system_status_controller.rb`.
- `server/config/initializers/pos_public_url.rb`: đọc và validate `POS_PUBLIC_BASE_URL`, dùng ở phase 2.
- `config/environments/production.rb`: `config.hosts` nhận IP LAN và tên `.local`; `assume_ssl` / `force_ssl` theo biến `POS_TLS_MODE` (`none|internal|public`).
- OpenAPI: `SystemStatus`.

## Client

- Web: `apps/pos/src/pages/settings/system.tsx` hiện địa chỉ server, chế độ TLS, trạng thái realtime / in / gửi ra ngoài / sao lưu.
- Flutter (`apps/pos-staff`):
  - kiểm `http://` chỉ cho host private, như quyết định 4;
  - `android/app/src/main/res/xml/network_security_config.xml`;
  - `ios/Runner/Info.plist` (`NSAllowsLocalNetworking`, `NSLocalNetworkUsageDescription`, `NSCameraUsageDescription`, `NSBluetoothAlwaysUsageDescription`).

## File

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

## Các bước

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

## Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/system_status_spec.rb spec/initializers/pos_public_url_spec.rb`
- `cd apps/pos-staff && flutter test`: kiểm tra URL (ví dụ `http://192.168.1.10` được nhận, `http://example.com` bị từ chối, `https://example.com` được nhận).
- Thử tay theo checklist trong `docs/deploy/pos-lan-vps.md`:
  - rút dây WAN của router, thu ngân vẫn bán tiền mặt và trạm in vẫn in;
  - cắm lại thì các việc chờ gửi ra ngoài chạy hết.
- Hồi quy: `pnpm --dir apps/pos build` với `VITE_BASE_PATH=/pos/`; `pnpm --dir apps/pos test:e2e`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| HTTP trên LAN để lộ token trong mạng Wi-Fi của quán | Khuyến nghị Wi-Fi riêng cho thiết bị POS, tách khỏi Wi-Fi khách; có tùy chọn `tls internal`. Ghi rõ trong hướng dẫn. |
| Mini PC hỏng làm mất dữ liệu | Sao lưu hằng đêm, đẩy ra ngoài khi có mạng, thử khôi phục định kỳ. |
| IP của mini PC đổi làm thiết bị mất kết nối | Hướng dẫn đặt IP tĩnh / DHCP reservation. Trên VPS thì dùng tên miền. Đổi `POS_PUBLIC_BASE_URL` cần ghép lại máy: ghi trong hướng dẫn. |
| Tunnel mở rộng bề mặt tấn công | Ingress chỉ cho path webhook, có xác thực chữ ký webhook như gem VietQR đang làm. |

## Tiêu chí xong

- [ ] Một image phục vụ API, `/dashboard` và `/pos`.
- [ ] Stack production chạy được ở chế độ LAN-HTTP và VPS-HTTPS; có file env mẫu, không có secret trong repo.
- [ ] QR ghép chứa `POS_PUBLIC_BASE_URL`; app Android và iOS ghép được qua HTTP LAN, và từ chối HTTP tới host công khai.
- [ ] Mất internet vẫn bán và in được; VietQR có tunnel hoặc polling, xác nhận tay vẫn còn.
- [ ] Sao lưu hằng đêm và khôi phục đã thử.
- [ ] Có `docs/deploy/pos-lan-vps.md` và trang trạng thái hệ thống.
