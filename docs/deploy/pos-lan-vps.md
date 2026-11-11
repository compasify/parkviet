# Triển khai ParkViet POS: server LAN tại quán hoặc VPS

Hướng dẫn cho người lắp đặt. Mỗi quán chạy ParkViet trên **một mini PC trong mạng của quán** (server LAN) hoặc trên **một VPS riêng**. Cả hai dùng cùng một bộ file trong [`deploy/`](../../deploy/):

| File | Vai trò |
|---|---|
| [`docker-compose.prod.yml`](../../deploy/docker-compose.prod.yml) | Stack: `web` (API, `/dashboard`, `/pos`, `/pos-admin`, việc chạy nền), `postgres`, `caddy`, `backup`; tùy chọn `cloudflared` (profile `tunnel`) và `offsite` (profile `offsite`) |
| [`Caddyfile`](../../deploy/Caddyfile) | Reverse proxy và TLS |
| [`.env.prod.example`](../../deploy/.env.prod.example) | Danh sách biến. Bản thật là `deploy/.env.prod`, không commit |
| [`cloudflared/config.example.yml`](../../deploy/cloudflared/config.example.yml) | Tunnel chỉ cho webhook VietQR |
| [`scripts/install-lan.sh`](../../deploy/scripts/install-lan.sh) | Cài lần đầu và cập nhật |
| [`scripts/backup.sh`](../../deploy/scripts/backup.sh), [`scripts/restore.sh`](../../deploy/scripts/restore.sh) | Sao lưu hằng đêm, thử khôi phục, khôi phục |

Image build từ [`server/Dockerfile`](../../server/Dockerfile), gồm API, Spree Dashboard, quầy thu ngân (`apps/pos`, ở `/pos/`) và quản trị POS (`apps/pos-dashboard`, ở `/pos-admin/`). Mọi thứ cùng một origin nên không cần CORS. `spree build --production` của Spree CLI build cùng image này; CLI không có lệnh triển khai, nên stack chạy bằng `docker compose` trên máy đích.

Các lệnh dưới đây chạy trong thư mục `deploy/` của bản checkout, với:

```bash
alias dc='docker compose -f docker-compose.prod.yml --env-file .env.prod'
```

## 1. Chọn nơi chạy

| | Server LAN (mini PC) | VPS |
|---|---|---|
| Mất internet | Vẫn bán, in, bếp chạy bình thường | Không bán được |
| Địa chỉ | `http://192.168.1.10` (IP tĩnh) | `https://pos.ten-quan.vn` |
| TLS | HTTP trong mạng quán (mặc định), hoặc HTTPS bằng CA riêng của Caddy | Let's Encrypt, tự động |
| Webhook VietQR | Cần tunnel (mục 7) | Nhận thẳng |

Khuyến nghị server LAN cho quán có bàn, bếp và trạm in.

## 2. Phần cứng và mạng

Tối thiểu cho một quán:

- Mini PC x86-64, 4 nhân, **8 GB RAM** (một tiến trình Spree cần khoảng 1 GB, Postgres và Caddy thêm 1–2 GB), **SSD 128 GB** trở lên. Không dùng thẻ nhớ hay ổ HDD.
- **UPS** 600 VA trở lên cho mini PC và router: mất điện đột ngột có thể làm hỏng dữ liệu.
- Router có DHCP reservation (giữ IP theo MAC) hoặc đặt IP tĩnh được.
- Ubuntu Server 24.04 LTS, Docker Engine **28.0.1 trở lên** cùng plugin compose (`curl -fsSL https://get.docker.com | sh`; gói `docker.io` của bản phân phối có thể quá cũ).

Mạng:

1. Đặt IP cố định cho mini PC: vào router, mục DHCP reservation, gán IP (ví dụ `192.168.1.10`) cho MAC của mini PC. Không có thì đặt IP tĩnh ngoài dải DHCP trên chính mini PC (netplan).
2. **Wi-Fi riêng cho thiết bị POS**, tách khỏi Wi-Fi khách. Trên LAN mặc định là HTTP, nên ai cùng mạng Wi-Fi có thể nghe lén token thiết bị. Nếu không tách được, bật HTTPS trên LAN (mục 5).
3. Tên `.local` (ví dụ `pos.local`, cần `avahi-daemon` trên mini PC) chạy tốt trên iPhone và máy tính, nhưng nhiều máy Android không phân giải được `.local`. Nên dùng IP.

## 3. Cài server LAN

```bash
git clone <repo> parkviet && cd parkviet
deploy/scripts/install-lan.sh                    # hỏi địa chỉ, gợi ý IP LAN của máy
# hoặc: deploy/scripts/install-lan.sh http://192.168.1.10
```

Script:

- tạo `deploy/.env.prod` (quyền 600) với secret mới sinh bằng `openssl`, không in secret ra màn hình;
- đặt `POS_PUBLIC_BASE_URL`, `POS_TLS_MODE`, `POS_CADDY_SITE` theo địa chỉ;
- build image (lần đầu mất vài phút), chạy `postgres`, `web`, `caddy`, `backup`, chờ `/up`.

**Chép `deploy/.env.prod` ra một nơi an toàn** (USB của chủ quán, trình quản lý mật khẩu). Mất các khóa `ACTIVE_RECORD_ENCRYPTION_*` thì dữ liệu mã hóa trong bản sao lưu không đọc được.

Sau khi chạy:

1. Lấy link tạo tài khoản quản trị đầu tiên: `dc exec web bin/rails spree:setup:token`, mở link trên trình duyệt.
2. Mở `http://192.168.1.10/pos-admin/`, đăng nhập, chạy thiết lập cửa hàng.
3. Vào **Cài đặt → Thông tin server** (`/pos-admin/<store>/settings/system`): địa chỉ trong QR phải là `http://192.168.1.10`, các dòng tình trạng là "Ổn" (sao lưu sẽ "Cần xem" tới sau đêm đầu).
4. Vào **Thiết bị**, tạo mã ghép và quét QR bằng app ParkViet Nhân viên.
5. Quầy thu ngân mở `http://192.168.1.10/pos/`.

`POS_PUBLIC_BASE_URL` sai (http tới host công khai, có path, có mật khẩu) thì app không khởi động; xem `dc logs web`. Quy tắc giống app: `http://` chỉ cho IP private (10/8, 172.16/12, 192.168/16) hoặc tên `.local`.

## 4. Cài trên VPS

1. Trỏ bản ghi DNS A (và AAAA nếu có) của `pos.ten-quan.vn` về VPS.
2. Firewall của nhà cung cấp (security group) chỉ mở 22, 80, 443. Docker bỏ qua `ufw`, nên dựa vào firewall của nhà cung cấp; compose chỉ publish cổng của Caddy.
3. `deploy/scripts/install-lan.sh https://pos.ten-quan.vn`: script đặt `POS_TLS_MODE=public`, `POS_CADDY_SITE=pos.ten-quan.vn`. Caddy tự lấy và gia hạn chứng chỉ Let's Encrypt.
4. Làm tiếp các bước sau cài như mục 3.

## 5. HTTPS trên LAN (tùy chọn nâng cao)

Dùng khi không tách được Wi-Fi POS khỏi Wi-Fi khách.

1. Trong `.env.prod`: `POS_PUBLIC_BASE_URL=https://192.168.1.10`, `POS_TLS_MODE=internal`, `POS_CADDY_SITE=https://192.168.1.10`. Rồi `dc up -d`.
2. Lấy CA của Caddy: `dc exec caddy cat /data/caddy/pki/authorities/local/root.crt > parkviet-ca.crt`.
3. Cài CA lên **từng** thiết bị:
   - Android: Cài đặt → Bảo mật → Mã hóa và thông tin xác thực → Cài đặt chứng chỉ → Chứng chỉ CA. App ParkViet Nhân viên tin CA người dùng cài (`network_security_config.xml`).
   - iPhone / iPad: gửi file qua AirDrop hoặc mail, cài hồ sơ, rồi bật trong Cài đặt → Cài đặt chung → Giới thiệu → Cài đặt tin cậy chứng nhận.
   - Máy thu ngân (Windows): nhập vào "Trusted Root Certification Authorities".
4. Ghép lại mọi thiết bị (địa chỉ đổi từ http sang https).

Ở chế độ `internal` server không gửi HSTS, nên quay lại `http://` sau này không khóa trình duyệt.

Lưu ý: ở chế độ này trình duyệt chặn lời gọi HTTP từ trang HTTPS, nên adapter in Epson ePOS / Star WebPRNT của quầy cần máy in hỗ trợ HTTPS; nếu không, in qua trạm in.

## 6. App ParkViet Nhân viên trên LAN

- Android cho phép cleartext (`android/app/src/main/res/xml/network_security_config.xml`), iOS bật `NSAllowsLocalNetworking`. App chỉ nhận `http://` khi host là IP private hoặc tên `.local`; `http://` tới tên miền công khai bị từ chối ngay ở bước ghép.
- iOS hỏi quyền "Mạng cục bộ" lần đầu: phải cho phép, nếu không app không tới được server và máy in LAN.
- Đổi `POS_PUBLIC_BASE_URL` (đổi IP, chuyển sang HTTPS, chuyển lên VPS) thì **phải ghép lại mọi thiết bị**: địa chỉ cũ nằm trong máy.

## 7. Ra internet: VietQR, hóa đơn điện tử, đơn nền tảng

- **Webhook VietQR (SePay / PayOS)** vào `POST /webhooks/payments/<provider>`, có kiểm chữ ký hoặc API key. Trên VPS thì đặt webhook thẳng vào `https://pos.ten-quan.vn/webhooks/payments/sepay`.
- **Server LAN** không nhận được webhook từ internet. Dùng Cloudflare Tunnel, chỉ mở đúng path webhook:
  1. Làm theo đầu file [`deploy/cloudflared/config.example.yml`](../../deploy/cloudflared/config.example.yml): tạo tunnel, route DNS `pay.<tên-miền>`, chép `config.yml` và file credentials vào `deploy/cloudflared/` (đã gitignore).
  2. Thêm `pay.<tên-miền>` vào `POS_EXTRA_HOSTS` trong `.env.prod`.
  3. `dc --profile tunnel up -d`.
  4. Đặt webhook của SePay / PayOS là `https://pay.<tên-miền>/webhooks/payments/sepay` (hoặc `payos`), thử một giao dịch nhỏ; trang **Thông tin server** hiện thời điểm nhận thông báo gần nhất.
- **Không có tunnel:** chưa có đối soát bằng polling (chưa có client tra giao dịch của SePay / PayOS trong repo). Thu ngân **xác nhận chuyển khoản bằng tay**, luôn dùng được.
- **Hóa đơn điện tử, đơn nền tảng** là việc gửi ra ngoài, đi qua hàng đợi (outbox). Mất internet thì đơn vẫn complete; trang **Thông tin server** hiện số việc đang chờ, có mạng lại thì tự gửi.

## 8. Mất internet

Server LAN và mọi thiết bị cùng mạng quán, nên khi router mất WAN:

| Vẫn chạy | Chờ có mạng |
|---|---|
| Bán, thu tiền mặt, complete đơn | Tự xác nhận VietQR (xác nhận tay vẫn được) |
| Trạm in, máy in LAN / Bluetooth, KDS, realtime | Việc chờ gửi ra ngoài (hóa đơn điện tử, đơn nền tảng) |
| Sao lưu hằng đêm vào ổ của mini PC | Bản sao off-site (`offsite`) |

**Checklist thử sau khi lắp** (ghi ngày thử vào sổ bàn giao):

1. Rút dây WAN của router (giữ LAN và Wi-Fi).
2. Quầy bán một đơn tiền mặt và complete; trạm in in phiếu; bếp nhận ticket.
3. Trang **Thông tin server** vẫn mở được; cơ sở dữ liệu, việc chạy nền, realtime "Ổn".
4. Cắm lại WAN. Trong vài phút, "Chờ gửi ra ngoài" về 0 việc chờ.

## 9. Sao lưu và khôi phục

- Service `backup` chạy `pg_dump -Fc` mỗi đêm sau `BACKUP_AT` (mặc định 02:30 giờ Việt Nam) vào `deploy/backups/`, giữ `BACKUP_KEEP` bản (mặc định 14). File dở dang không bao giờ mang tên bản sao lưu hợp lệ, và mỗi bản được `pg_restore --list` kiểm trước khi giữ.
- Sao lưu ngay: `dc run --rm --no-deps --entrypoint /bin/sh backup /scripts/backup.sh once`.
- **Off-site:** điền `RCLONE_*` trong `.env.prod` (bucket S3-compatible), `dc --profile offsite up -d`. Mỗi giờ chép các bản 3 ngày gần nhất khi có mạng. Service `offsite` chỉ nhận các biến `RCLONE_*` khai báo trong `docker-compose.prod.yml`; remote cần thêm khóa (region, ACL) thì thêm vào đó.
- **Thử khôi phục mỗi quý:** `scripts/restore.sh --drill backups/parkviet-<ngày>.dump`. Script khôi phục vào DB tạm `parkviet_restore_drill`, đếm store và đơn, rồi xóa DB tạm; DB đang chạy không bị đụng tới. Ghi kết quả vào sổ bàn giao.
- **Khôi phục thật** (mini PC hỏng, dữ liệu sai): trên máy mới, cài như mục 3 nhưng dùng lại `.env.prod` đã cất (cùng khóa mã hóa), chép bản sao lưu vào `deploy/backups/`, rồi `scripts/restore.sh --replace backups/parkviet-<ngày>.dump` (gõ `RESTORE` để xác nhận). Script chép file nguồn ra chỗ tạm và kiểm nó đọc được, dừng `web`, lưu một bản an toàn của dữ liệu hiện có (không xóa bản cũ nào), khôi phục, chạy lại `web`, rồi in tên bản an toàn. Nếu lỗi sau khi DB đã bị xóa, `web` vẫn dừng và script in tên bản an toàn cùng lệnh `scripts/restore.sh --replace backups/<bản an toàn>` để đưa dữ liệu cũ về. File sao lưu chỉ chủ sở hữu (root) đọc được: chạy script bằng `sudo` nếu cần.

## 10. Cập nhật phiên bản

```bash
cd parkviet/deploy
dc run --rm --no-deps --entrypoint /bin/sh backup /scripts/backup.sh once
cd .. && git pull
deploy/scripts/install-lan.sh --update
```

Migration chạy khi `web` khởi động. Trang **Thông tin server** hiện phiên bản (`git describe`) đang chạy. Cập nhật ngoài giờ bán: `web` khởi động lại mất khoảng một phút.

## 11. Xử lý sự cố

| Hiện tượng | Kiểm |
|---|---|
| App báo không tới được server | Thiết bị cùng Wi-Fi POS? IP của mini PC còn đúng (`ip a`)? `dc ps` thấy `web` healthy? |
| App từ chối địa chỉ `http://...` | Host không phải IP private hay `.local`. Dùng IP LAN, hoặc `https://` cho server trên internet |
| Mini PC đổi IP | Đặt lại DHCP reservation như cũ. Nếu buộc phải đổi IP: sửa `POS_PUBLIC_BASE_URL`, `dc up -d`, ghép lại mọi thiết bị |
| `web` không khởi động, log có `POS_PUBLIC_BASE_URL` / `POS_TLS_MODE` | Sửa giá trị theo thông báo: scheme phải khớp chế độ TLS. Bỏ trống `POS_TLS_MODE` thì `http://` là `none`, `https://` là `public` |
| `web` không khởi động, log có `change-me` | Một secret trong `.env.prod` còn giá trị mẫu: tạo giá trị mới như ghi chú trong `.env.prod.example` (khóa mã hóa thì không đổi khi đã có dữ liệu) |
| Trang trắng, lỗi 403 khi mở bằng một tên khác | Rails chỉ nhận các host đã khai báo: thêm tên đó vào `POS_EXTRA_HOSTS` (trên LAN, IP private và tên `.local` luôn được nhận) |
| Webhook VietQR không về | `dc --profile tunnel logs cloudflared`; webhook phải đúng `/webhooks/payments/sepay` hoặc `payos` |
| "Sao lưu: Cần xem" | `dc logs backup`; ổ đầy (`df -h`)? |
| "Việc chạy nền: Cần xem" | `dc logs web`; `/jobs` (tài khoản `MISSION_CONTROL_*`) để xem việc lỗi |
