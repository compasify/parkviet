---
phase: 26
title: "Relay đèn bida"
status: pending
effort: "4 ngày"
dependsOn: [5, 17]
---

# Phase 26: Relay đèn bida (`resources.iot_relay`)

## Overview

Bàn bida bật đèn khi phiên chơi bắt đầu và tắt đèn khi kết thúc, có thời gian ân hạn để khách dọn cơ. Relay nằm **ngoài đường tiền**: lỗi relay không bao giờ chặn mở phiên, tính giờ hay thanh toán. Giờ chơi vẫn tính theo `TimedSession` / `TimedSegment` ở server (phase 17), không theo trạng thái đèn.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Hai loại relay ở bản đầu: **Shelly** (HTTP local API, Gen2 RPC `Switch.Set`) và **HLK-SW16** (TCP, 16 kênh, lệnh nhị phân). Interface `Spree::Pos::Relays::Driver` (`set(channel, on)`, `state(channel)`), mỗi loại một driver; thêm loại khác chỉ là thêm driver. |
| Q2 | **Ai gửi lệnh:** nếu server chạy LAN cùng mạng với relay (D5), server gửi trực tiếp từ job nền. Nếu server là VPS, server không với tới relay; một thiết bị Flutter mode `bridge` đặt ở quán nhận lệnh qua `BranchChannel` và gửi ra relay trong LAN, rồi báo kết quả về server. Mỗi `RelayDevice` ghi rõ `executor` (`server` \| `bridge`). |
| Q3 | Sự kiện: `TimedSession` bắt đầu / tiếp tục → bật; tạm dừng (phase 21) → giữ đèn theo cấu hình (`pause_light`: `on` \| `off`); kết thúc / thanh toán → hẹn tắt sau `grace_seconds` (mặc định 120). Mở lại phiên trong ân hạn thì hủy lệnh tắt. |
| Q4 | **Điều khiển tay:** nhân viên có quyền bật / tắt đèn từng bàn trên bảng phòng, ghi `AuditEntry` (`relay.manual`). Bật tay khi bàn không có phiên thì hiện cảnh báo "đèn bật không có phiên" sau 5 phút (chống bật đèn chơi chui). |
| Q5 | **An toàn điện:** relay chỉ đóng / ngắt mạch điều khiển; tải đèn bàn bida lớn phải qua **contactor** do thợ điện lắp. Plan chỉ ghi yêu cầu này vào tài liệu cài đặt và màn cấu hình; phần mềm không thay được yêu cầu điện. Mặc định khi relay mất điều khiển: giữ nguyên trạng thái, không tự tắt giữa trận. |

## Dữ liệu

- `spree_pos_relay_devices`: `store_id`, `branch_id`, `name`, `driver` (`shelly` \| `hlk_sw16`), `address` (host:port trong LAN), `credentials_ciphertext` (nếu Shelly bật mật khẩu), `executor` (`server` \| `bridge`), `bridge_device_id` (Device mode `bridge`), `status` (`online` \| `offline` \| `disabled`), `last_seen_at`, `last_error`.
- `spree_pos_relay_channels`: `relay_device_id`, `channel` (số kênh), `resource_id` (unique), `pause_light`, `grace_seconds`.
- `spree_pos_relay_commands`: `relay_channel_id`, `desired_state` (on/off), `reason` (`session_start` \| `session_resume` \| `session_pause` \| `session_end` \| `manual`), `run_at`, `status` (`queued` \| `sent` \| `confirmed` \| `failed` \| `canceled`), `attempts`, `error`, `actor_id`. Idempotent theo (`relay_channel_id`, sự kiện nguồn).

## Server

- Subscriber trên sự kiện tính giờ của phase 17 (`resource.updated` / sự kiện phiên) → `Spree::Pos::Relays::Schedule` tạo `RelayCommand` (lệnh tắt có `run_at = now + grace`).
- `Spree::Pos::RelayCommandJob` (Solid Queue): với `executor = server` gọi driver, đọc lại `state` để xác nhận; với `executor = bridge` phát sự kiện `relay.command` (mới) trên `BranchChannel` chỉ tới thiết bị bridge của chi nhánh.
- Endpoint cho bridge: `POST api/v3/admin/pos/relay_commands/:id/result` (xác thực bằng credential thiết bị mode `bridge`, phase 2).
- Retry 3 lần cách 5 giây; thất bại thì `failed`, phát `owner_alert.created` (phase 24) và hiện biểu tượng lỗi trên ô bàn của bảng phòng.
- Health check mỗi phút cho relay `server` và heartbeat của bridge; quá 2 phút không thấy thì `offline`.
- Endpoint nhân viên: CRUD relay / kênh, kiểm thử bật tắt (`test`), bật / tắt tay một bàn. Quyền mới `pos.relay.manage` (cấu hình) và `pos.relay.operate` (bật tắt tay).

## Flutter (`apps/pos-staff`, chế độ `bridge`)

- Màn tối giản: tên chi nhánh, danh sách relay và trạng thái, nhật ký 50 lệnh gần nhất.
- Nhận `relay.command`, gửi HTTP (Shelly) hoặc TCP socket (HLK-SW16) trong LAN, báo kết quả.
- Chạy nền: Android foreground service + `wakelock_plus`; khuyến nghị thiết bị Android cắm sạc cố định. iOS không hỗ trợ chạy nền lâu dài nên mode `bridge` chỉ bật trên Android (ghi rõ trong màn ghép thiết bị).
- Khi mất kết nối server, bridge **không tự đổi** trạng thái relay.

## Client web `apps/pos`

- Cài đặt chi nhánh → Relay: thêm relay, chọn driver, địa chỉ, executor, gán kênh ↔ bàn, nút kiểm thử, cảnh báo contactor.
- Bảng phòng (phase 17): biểu tượng đèn trên ô bàn (bật / tắt / lỗi / offline), menu bật / tắt tay.

## File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_relay_devices.rb`, `*_relay_channels.rb`, `*_relay_commands.rb` | Tạo |
| `server/app/models/spree/pos/relay_device.rb`, `relay_channel.rb`, `relay_command.rb` | Tạo |
| `server/app/services/spree/pos/relays/driver.rb`, `shelly_driver.rb`, `hlk_sw16_driver.rb`, `schedule.rb` | Tạo |
| `server/app/jobs/spree/pos/relay_command_job.rb`, `relay_health_job.rb` | Tạo |
| `server/app/subscribers/spree/pos/relay_session_subscriber.rb` | Tạo, đăng ký trong `config/initializers/spree.rb` |
| `server/app/controllers/spree/api/v3/admin/pos/relay_devices_controller.rb`, `relay_commands_controller.rb` | Tạo |
| `server/config/initializers/pos_modules.rb`, `capabilities.rb`, `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos-staff/lib/features/bridge/`, `android/.../BridgeForegroundService.kt` | Tạo |
| `apps/pos/src/pages/settings/relays.tsx`, `components/resource-light-indicator.tsx` | Tạo |

## Các bước

1. Migration, model, driver Shelly / HLK-SW16 với spec dùng server giả (WEBrick / TCP server trong spec).
2. `Schedule` + subscriber: spec bật khi bắt đầu, tắt sau ân hạn, hủy tắt khi mở lại trong ân hạn.
3. Job chạy lệnh, retry, health, cảnh báo.
4. Đường bridge: sự kiện, endpoint kết quả, Flutter mode `bridge` (Android).
5. UI cài đặt và chỉ báo đèn trên bảng phòng.
6. Tài liệu lắp đặt: contactor, IP tĩnh cho relay, cùng VLAN với server / bridge.

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/relays/ spec/jobs/spree/pos/relay_command_job_spec.rb spec/requests/spree/pos/relay_devices_spec.rb`.
- Spec quan trọng: relay lỗi không làm hỏng mở phiên / thanh toán (lệnh tính giờ vẫn thành công, chỉ ghi `failed`).
- Flutter: unit test mã hóa lệnh HLK-SW16; integration test với Shelly giả lập.
- Thử thật trên một Shelly Plus 1 và một HLK-SW16 trước khi đánh dấu xong.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Đèn tắt giữa trận do lỗi | Chỉ tắt theo sự kiện kết thúc; mất điều khiển thì giữ nguyên trạng thái; có điều khiển tay. |
| Chơi chui bằng cách bật đèn tay | Bật tay có audit và cảnh báo khi không có phiên. |
| VPS không với tới relay | Executor `bridge` trên Android tại quán. |
| Tải điện lớn làm hỏng relay | Bắt buộc contactor, ghi trên màn cấu hình và tài liệu. |

## Tiêu chí xong

- [ ] Bắt đầu phiên bật đèn, kết thúc tắt sau ân hạn, với cả executor server và bridge.
- [ ] Lỗi relay hiện trên bảng phòng và gửi cảnh báo, không chặn nghiệp vụ.
- [ ] Bật / tắt tay có quyền và audit.
- [ ] Đã thử trên thiết bị thật hai loại relay.
