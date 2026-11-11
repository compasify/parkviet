---
phase: 2
title: "Thiết bị, ghép mã, PIN nhân viên"
status: in-progress
effort: "5 ngày"
dependsOn: []
---

# Phase 2: Thiết bị, ghép mã, PIN nhân viên

## Overview

Máy bếp, máy phục vụ, kiosk, trạm in và máy của chủ quán cần một danh tính bền, không phụ thuộc vào việc ai đang đăng nhập. Phase này thêm `Spree::Pos::Device`, cách ghép bằng mã / QR (QR chứa sẵn địa chỉ server, D5), credential dài hạn, và đăng nhập nhân viên bằng PIN trên máy dùng chung. Quyền vẫn tính theo nhân viên qua `StaffMembership` và `Capabilities` như hiện tại.

Mẫu có sẵn để làm theo: `DisplayPairing` (mã 8 ký tự, TTL 10 phút, lưu digest SHA-256, dùng một lần) và `DisplaySession` (token chỉ lưu digest, có `generation`, thu hồi được).

## Quyết định của phase

1. **Ghép thiết bị:**
   - Quản lý có capability `pos.device.manage` tạo `DevicePairing` cho một chi nhánh và một mode. Với mode `kds` thì kèm trạm bếp; với mode `kiosk` thì kèm quầy.
   - Server trả về mã 8 ký tự và payload QR dạng JSON:

     ```json
     { "v": 1, "kind": "parkviet.device", "url": "https://pos.quan-a.lan", "code": "K7M2Q9XA" }
     ```

     `url` lấy từ cấu hình `POS_PUBLIC_BASE_URL` (phase 6). Nếu chưa cấu hình thì lấy từ `request.base_url`.
   - Thiết bị gọi `POST api/v3/pos_device/pair` kèm mã, platform và tên máy, rồi nhận **device token**. Token chỉ hiện một lần, server chỉ lưu digest.
2. **Credential:**
   - Gửi qua header `Authorization: Device <token>`.
   - Token không hết hạn theo thời gian, chỉ mất hiệu lực khi thu hồi hoặc ghép lại.
   - Mỗi request cập nhật `last_seen_at`, tối đa một lần mỗi 60 giây để tránh ghi DB liên tục.
3. **Mode:**
   - Dùng `Device::MODES = waiter kds expo kiosk print_station owner bridge`, đúng theo plan.md.
   - Mode quyết định endpoint nào thiết bị gọi được **khi chưa có nhân viên đăng nhập**:
     - `kds`, `expo`, `print_station`, `bridge` và `kiosk` chạy bằng danh tính máy;
     - `waiter` và `owner` bắt buộc có nhân viên.
4. **PIN nhân viên:**
   - `StaffMembership.pin_digest`, băm bằng `BCrypt`. PIN dài 4–6 chữ số.
   - Nhân viên tự đặt PIN trên web sau khi đăng nhập bằng mật khẩu. Quản lý chỉ được reset PIN, không xem được.
   - Trên thiết bị `waiter` / `owner`, nhân viên chọn tên mình (danh sách membership active của chi nhánh), nhập PIN, rồi nhận `DeviceStaffSession` với TTL 12 giờ. Session hết hiệu lực khi đăng xuất, khi bị thu hồi, hoặc sau 30 phút không hoạt động (cấu hình theo chi nhánh).
   - Sai PIN 5 lần thì khóa membership đó trên thiết bị đó trong 15 phút, và ghi `AuditEntry` `device.pin_lockout`. Có thêm giới hạn tần suất theo thiết bị (Rack::Attack nếu có; nếu không thì đếm trong DB).
5. **Cách request của thiết bị trở thành request của nhân viên:**
   - `Spree::Api::V3::Admin::Pos::BaseController` thêm một bộ xác thực: khi gặp header `Authorization: Device …` kèm `X-Pos-Staff-Session`, nó đặt `current_user` là nhân viên của session.
   - Mọi kiểm tra `pos_permissions`, `AccessPolicy` và lease giữ nguyên.
   - Thiết bị không có session nhân viên chỉ gọi được namespace `api/v3/pos_device/*`, theo mode.
6. **`editor_id` của lease:**
   - Lease hiện gắn `editor_id` (UUID v4) với tab trình duyệt. Thiết bị dùng một UUID cố định cho mỗi lần cài app, lưu ở secure storage.
   - Vì vậy, đổi nhân viên trên cùng máy vẫn giữ được ý nghĩa của lease: lease = nhân viên + editor.

## Dữ liệu

| Bảng | Cột chính |
|---|---|
| `spree_pos_devices` | `store_id`, `branch_id`, `name`, `mode`, `platform` (`android|ios|web`), `app_version`, `kitchen_station_id` (nullable, FK thêm ở phase 9), `register_id` (nullable), `token_digest` unique, `generation`, `status` (`active|revoked`), `last_seen_at`, `paired_by_id`, `revoked_by_id`, `revoked_at`, `settings jsonb` |
| `spree_pos_device_pairings` | `store_id`, `branch_id`, `mode`, `code_digest` unique, `expires_at`, `consumed_at`, `device_id` (khi ghép lại máy cũ), `created_by_id`, `attrs jsonb` |
| `spree_pos_device_staff_sessions` | `device_id`, `staff_id`, `token_digest` unique, `expires_at`, `last_active_at`, `ended_at`, `end_reason` |
| `spree_pos_staff_memberships` | thêm `pin_digest`, `pin_set_at` |
| `spree_pos_device_pin_failures` | `device_id`, `staff_membership_id`, `failed_at`; index `(device_id, staff_membership_id, failed_at)` |

Migration: `create_pos_devices`, `create_pos_device_pairings`, `create_pos_device_staff_sessions`, `add_pin_to_pos_staff_memberships`, `create_pos_device_pin_failures`.

## Server

- Model: `server/app/models/spree/pos/device.rb`, `device_pairing.rb`, `device_staff_session.rb`. Viết theo mẫu `display_pairing.rb` / `display_session.rb`.
- Workflow `server/app/workflows/spree/pos/devices/`:
  - `pairing.rb`: tạo mã;
  - `pair.rb`: đổi mã lấy token. Thao tác này atomic, mã chỉ dùng một lần;
  - `revoke.rb`;
  - `rename.rb`;
  - `staff_sign_in.rb`: kiểm PIN, lockout, tạo session;
  - `staff_sign_out.rb`;
  - `set_pin.rb` / `reset_pin.rb`.
- Bộ xác thực `server/app/services/spree/pos/device_authenticator.rb` dùng chung cho staff API, cho namespace thiết bị và cho channel realtime (phase 3).
- Controller:
  - `api/v3/admin/pos/devices_controller.rb`: `index`, `create_pairing`, `update`, `revoke`. Capability `pos.device.manage`.
  - `api/v3/admin/pos/staff_pins_controller.rb`: `PUT` PIN của chính mình, `DELETE` reset (chỉ quản lý).
  - `server/app/controllers/spree/pos/device_api/base_controller.rb`: xác thực bằng `Device`, có helper `require_mode!`.
  - `device_api/pairings_controller.rb`: `POST pair`, không cần auth.
  - `device_api/staff_sessions_controller.rb`: `GET staff` (danh sách tên, không kèm dữ liệu nhạy cảm), `POST`, `DELETE`.
  - `device_api/me_controller.rb`: trả về thông tin máy, mode, chi nhánh, trạm và `server_time`.
- Route: `api/v3/pos_device/*`, đặt cạnh `api/v3/pos_display/*` trong `server/config/routes.rb`.
- Capability mới trong `server/app/models/spree/pos/capabilities.rb`: `DEVICE_MANAGE = 'pos.device.manage'`, đưa vào `ASSIGNABLE`.
- Audit: `device.paired`, `device.revoked`, `device.staff_sign_in`, `device.staff_sign_out`, `device.pin_lockout`, `staff.pin_set`, `staff.pin_reset`.
- OpenAPI: thêm schema `Device`, `DevicePairing`, `DeviceStaffSession` và các endpoint `pos_device/*` vào `server/openapi/pos-staff.yaml`.

## Client web

- Trang mới `apps/pos/src/pages/settings/devices.tsx`:
  - danh sách thiết bị theo chi nhánh: tên, mode, trạm, lần cuối thấy, trạng thái;
  - nút "Ghép thiết bị": chọn mode → hiện QR và mã kèm đồng hồ đếm 10 phút;
  - thu hồi, đổi tên.
- Hook `apps/pos/src/hooks/use-devices.ts` (react-query, theo mẫu `use-display.ts`).
- Mục "PIN đăng nhập trên máy dùng chung" trong trang tài khoản / cài đặt cá nhân. Quản lý reset PIN ở trang thành viên.
- Thư viện QR: dùng lại thư viện đang dùng để vẽ VietQR ở `customer-display`.
- Route mới trong `apps/pos/src/router.tsx`: `/settings/devices`. i18n `devices.*`.

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/db/migrate/*` (5 file) | create | Như bảng Dữ liệu |
| `server/app/models/spree/pos/device*.rb`, `staff_membership.rb` | create / modify | Model, PIN |
| `server/app/workflows/spree/pos/devices/*.rb` | create | Ghép, thu hồi, PIN, session |
| `server/app/services/spree/pos/device_authenticator.rb` | create | Xác thực dùng chung |
| `server/app/controllers/spree/api/v3/admin/pos/base_controller.rb` | modify | Nhận `Device` + session nhân viên |
| `server/app/controllers/spree/api/v3/admin/pos/devices_controller.rb`, `staff_pins_controller.rb` | create | API quản lý |
| `server/app/controllers/spree/pos/device_api/*.rb` | create | API cho thiết bị |
| `server/config/routes.rb`, `server/app/models/spree/pos/capabilities.rb` | modify | Route, capability |
| `server/openapi/pos-staff.yaml` | modify | Schema thiết bị |
| `apps/pos/src/pages/settings/devices.tsx`, `apps/pos/src/hooks/use-devices.ts`, `apps/pos/src/router.tsx` | create / modify | UI quản lý |

## Các bước

1. Đọc `display_pairing.rb`, `display_session.rb`, `workflows/spree/pos/displays/*`, `display_views_controller.rb` để chép đúng cách băm, TTL và thu hồi.
2. Viết migration và model, kèm spec model.
3. Viết workflow ghép và thu hồi, rồi controller của thiết bị.
4. Viết PIN: đặt, reset, đăng nhập, lockout.
5. Sửa `BaseController` để nhận thiết bị + session nhân viên. Chạy lại toàn bộ request spec POS.
6. Làm trang Thiết bị trên web, cập nhật OpenAPI.

## Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/device_spec.rb spec/workflows/spree/pos/devices/`
- `pnpm spree rspec spec/requests/spree/pos/devices_spec.rb spec/requests/spree/pos/device_api_spec.rb`
- Các ca phải có:
  - mã hết hạn bị từ chối;
  - mã dùng lần hai bị từ chối;
  - hai thiết bị đổi cùng một mã đồng thời thì chỉ một máy thành công (dùng `pos_race_helpers.rb`);
  - token đã thu hồi trả 401;
  - sai PIN lần thứ 5 thì khóa;
  - session nhân viên không vượt quyền của membership;
  - máy `kds` không có session gọi `workspaces` thì trả 403.
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/` (đăng nhập bằng mật khẩu không đổi); `pnpm --dir apps/pos typecheck test`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Lộ device token thì cho truy cập lâu dài | Token chỉ có quyền theo mode. Hành động có tiền luôn cần session nhân viên. Thu hồi có hiệu lực ngay, và `generation` tăng để ngắt kênh realtime. |
| PIN 4 số dễ đoán | Lockout theo thiết bị và membership. PIN chỉ dùng được trên thiết bị đã ghép, không dùng được qua web. |
| Sửa `BaseController` làm hỏng luồng đăng nhập hiện có | Chỉ đi nhánh mới khi header là `Device`. Toàn bộ request spec POS chạy lại. |

## Tiêu chí xong

- [x] Quản lý tạo QR ghép; QR chứa `url` server và mã một lần.
- [x] Thiết bị đổi mã lấy token; server chỉ lưu digest; thu hồi có hiệu lực ngay.
- [x] Nhân viên đặt PIN trên web và đăng nhập bằng PIN trên thiết bị; khóa sau 5 lần sai.
- [x] Request từ thiết bị + session nhân viên đi qua đúng kiểm tra quyền hiện có.
- [x] Trang Thiết bị trên web chạy được; OpenAPI có đủ endpoint.
- [ ] Spec POS và e2e web xanh.

## Review 11/11/2026

Đã review và sửa. Spec POS xanh 629/629; e2e `apps/pos-dashboard` xanh sau khi cập nhật spec cũ. Ô cuối còn mở vì e2e `apps/pos` chưa ổn định: lần chạy đầy đủ còn vài test fail, chủ yếu timeout khi máy tải nặng, và chưa có lần nào xanh trọn bộ.

Trang Thiết bị nằm ở `apps/pos-dashboard`, không ở `apps/pos` như mục Client web ghi. Danh sách PIN lấy từ `GET /pos/staff_pins`.
