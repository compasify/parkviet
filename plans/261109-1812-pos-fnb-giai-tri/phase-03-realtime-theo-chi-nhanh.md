---
phase: 3
title: "Realtime theo chi nhánh"
status: completed
effort: "4 ngày"
dependsOn: [2]
---

# Phase 3: Realtime theo chi nhánh

## Overview

KDS, app phục vụ và trạm in cần biết có thay đổi trong khoảng 2 giây; poll 5–30 giây như hiện tại (`refetchInterval` ở `apps/pos/src/hooks/use-deliveries.ts`, `use-receivables.ts`, `use-tenders.ts`…) là không đủ. Phase này mount Action Cable, thêm một kênh cho mỗi chi nhánh, và phát **sự kiện mỏng**. Client nhận sự kiện thì refetch qua API như cũ, nên quyền và dữ liệu vẫn chỉ đi qua API. Poll được giữ làm dự phòng.

Hiện trạng đã kiểm:
- `server/config/application.rb` đã `require 'action_cable/engine'`.
- `Gemfile` đã có `solid_cable`.
- `config/cable.yml`: dev dùng `async`, test dùng `test`, production dùng `solid_cable` (polling 0.1s, giữ 1 ngày).
- Chưa có `server/app/channels`, và routes chưa mount `/cable`.
- `config/database.yml` chưa có khai báo DB / bảng cho Solid Cable. Phải kiểm tra và bổ sung.

## Quyết định của phase

1. **Một kênh cho mỗi chi nhánh:** `Spree::Pos::BranchChannel`, stream `pos:branch:<branch_prefixed_id>`. Không có kênh theo đơn hay theo trạm: client tự lọc theo payload. Cách này giữ số stream thấp.
2. **Ba loại kết nối được chấp nhận** (`server/app/channels/spree/pos/application_cable/connection.rb`):
   - **Nhân viên web:** JWT admin hiện có, đi qua query param `token` vì trình duyệt không gửi được header khi mở WebSocket. Nhân viên chỉ subscribe được chi nhánh mà `AccessPolicy` cho phép.
   - **Thiết bị:** device token của phase 2, đi qua `Sec-WebSocket-Protocol` hoặc query param. Chỉ subscribe được chi nhánh của chính thiết bị.
   - **Thiết bị có session nhân viên:** như thiết bị, nhưng có thêm thông tin nhân viên.

   Khi thiết bị bị thu hồi hoặc `generation` đổi, server ngắt kết nối bằng `ActionCable.server.remote_connections.where(device_id:).disconnect`.
3. **Sự kiện mỏng** chỉ gồm: `{ event, id, branch_id, revision?, lease_generation?, at, refs }`.
   - Không kèm tiền, tên khách hay nội dung món. Client gọi lại API để lấy dữ liệu.
   - Danh sách sự kiện đúng theo plan.md: `workspace.updated`, `kitchen_ticket.updated`, `menu.sold_out`, `payment.requested`, `print_job.created`, `resource.updated`, `approval.requested`. Các phase sau thêm sự kiện của mình vào `EVENTS` (ví dụ `guest_order.created`, `guest_request.created`, `owner_alert.created`, `relay.command`) và cập nhật danh sách trong plan.md.
   - Phase này đã phát `workspace.updated` và `approval.requested`. Các phase sau tự phát sự kiện của mình.
4. **Thời điểm phát:** `Spree::Pos::Realtime.publish(branch, event, payload)` chỉ broadcast **sau khi commit**, dùng `ActiveRecord.after_all_transactions_commit` (Rails 7.2+), tránh báo một thay đổi bị rollback. Lỗi broadcast chỉ được log, không làm fail lệnh.
5. **Dự phòng:** client vẫn poll, nhưng giãn ra 60 giây khi socket đang mở và trở về chu kỳ cũ khi socket rớt. Mỗi lần kết nối lại thì refetch toàn bộ query đang mở, vì có thể đã lỡ sự kiện.

## Dữ liệu

- Không có bảng nghiệp vụ mới.
- Solid Cable cần bảng `solid_cable_messages`. Theo cách cài của gem, có thể đặt trong DB chính hoặc một DB `cable` riêng; chọn **DB chính** để triển khai LAN đơn giản (phase 6). Sửa `config/cable.yml` production thêm `connects_to` nếu cần. Migration: `create_solid_cable_messages`, lấy theo installer của gem.

## Server

- `server/app/channels/spree/pos/application_cable/connection.rb`, `channel.rb`, `branch_channel.rb`.
- `server/app/services/spree/pos/realtime.rb`: `publish`, `stream_name(branch)`, danh sách `EVENTS` đã đóng băng (sự kiện lạ thì raise).
- Route: `mount ActionCable.server => '/cable'` trong `server/config/routes.rb`. Kiểm `allowed_request_origins` cho origin của `apps/pos` (port 5175 ở dev) và cho app (app không gửi Origin, nên cho phép thiếu Origin khi xác thực bằng device token).
- Gọi `Realtime.publish('workspace.updated')` từ `CommandExecutor` sau mỗi lệnh workspace thành công. Đây là một điểm duy nhất, không rải vào từng workflow. Đọc `server/app/services/spree/pos/command_executor.rb` để chọn đúng hook.
- `approval.requested`: phát từ `approvals_controller.rb#create`.
- Spec dùng adapter `test` và `have_broadcasted_to`.
- OpenAPI: mô tả kênh trong `x-realtime` của `server/openapi/pos-staff.yaml` (tên stream, payload schema `RealtimeEvent`), để Flutter sinh được kiểu.

## Client web

- `apps/pos/src/lib/realtime.ts`: client Action Cable (`@rails/actioncable`, thêm vào `apps/pos/package.json`), có backoff khi nối lại và trạng thái `connected | connecting | offline`.
- `apps/pos/src/hooks/use-branch-events.ts`:
  - `useBranchEvents(branchId)` subscribe và map sự kiện → `queryClient.invalidateQueries` (query client có ở `apps/pos/src/lib/query-client.ts`);
  - bảng map đặt trong code: `workspace.updated` → `['workspace', id]` và danh sách workspace; `approval.requested` → danh sách duyệt.
- Hook `useRealtimeStatus()` cấp chu kỳ poll động cho các hook đang có `refetchInterval`. Sửa lần lượt `use-tenders.ts`, `use-deliveries.ts`, `use-display.ts`, `use-receivables.ts`, `use-returns.ts`, `use-shift-close.ts`, `use-inventory.ts`, `use-reports.ts`.
- Chấm trạng thái kết nối nhỏ ở thanh trên (`components/pos-page.tsx`).

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/app/channels/spree/pos/**` | create | Connection, BranchChannel |
| `server/app/services/spree/pos/realtime.rb` | create | Publish sau commit |
| `server/app/services/spree/pos/command_executor.rb`, `approvals_controller.rb` | modify | Phát sự kiện |
| `server/config/routes.rb`, `server/config/cable.yml`, `server/config/environments/*.rb` | modify | Mount, origins |
| `server/db/migrate/*_create_solid_cable_messages.rb` | create | Bảng Solid Cable |
| `server/openapi/pos-staff.yaml` | modify | `x-realtime` |
| `apps/pos/src/lib/realtime.ts`, `hooks/use-branch-events.ts` | create | Client |
| `apps/pos/src/hooks/use-*.ts` (8 file có `refetchInterval`) | modify | Poll động |
| `server/script/pos_realtime_bench.rb` | create | Bài đo độ trễ |

## Các bước

1. Cài Solid Cable cho production; kiểm `pnpm spree rails runner` có tạo được bảng.
2. Viết connection và channel, kèm spec channel cho 3 loại kết nối và các ca bị từ chối.
3. Viết `Realtime`, gắn vào `CommandExecutor` và approvals.
4. Viết client web, thay poll cố định bằng poll động.
5. **Đo:**
   - chạy stack ở chế độ production trên máy dev (`RAILS_ENV=production` qua `pnpm spree exec`);
   - mở 20 kết nối giả lập và phát 50 sự kiện/giây trong 2 phút;
   - ghi p50 / p95 từ lúc commit đến lúc client nhận.

   Mục tiêu p95 ≤ 2 giây. Nếu không đạt, ghi kết quả và đề xuất chuyển adapter (ví dụ Redis) trong phần Kết quả của phase.

## Kiểm thử

- `pnpm spree rspec spec/channels/spree/pos/branch_channel_spec.rb spec/services/spree/pos/realtime_spec.rb`
- Request spec: một lệnh workspace thành công thì broadcast đúng một `workspace.updated`; lệnh lỗi hoặc rollback thì không broadcast gì.
- `pnpm --dir apps/pos test`: unit test cho bảng map sự kiện → query key và cho poll động.
- `pnpm --dir apps/pos test:e2e`: hai tab cùng chi nhánh; tab A thêm món thì tab B thấy trong 2 giây mà không cần reload.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Token đặt trong query string bị ghi vào log | Lọc `token` trong `filter_parameters` và trong log của proxy (phase 6). |
| Solid Cable trên Postgres chậm khi nhiều chi nhánh | Bài đo ở bước 5. Sự kiện mỏng giữ dung lượng nhỏ. Adapter là cấu hình, đổi được. |
| Lỡ sự kiện khi rớt mạng | Mỗi lần kết nối lại thì refetch toàn bộ. Poll vẫn còn. |

## Tiêu chí xong

- [x] `/cable` chạy với JWT nhân viên và device token; sai chi nhánh bị từ chối.
- [x] Sự kiện phát sau commit, không mang dữ liệu nhạy cảm.
- [x] Web nhận `workspace.updated` và refetch; poll tự giãn hoặc trở lại theo trạng thái socket (chỉ với poll có sự kiện phủ, xem Kết quả).
- [x] Có số đo p50 / p95 ghi trong phase.
- [x] Spec POS và e2e web xanh (một test timeout khi chạy full, chạy lại riêng thì xanh, xem Kết quả).

## Kết quả

**Bài đo** (`server/script/pos_realtime_bench.rb`, `RAILS_ENV=production`, Solid Cable trên DB chính, 20 socket thiết bị, 50 sự kiện/giây trong 120 giây): p50 59,3 ms, p95 106,2 ms, p99 118,7 ms, max 318,2 ms, từ lúc commit đến lúc nhận; 120000/120000 lượt tới nơi. Đạt mục tiêu p95 ≤ 2 giây, chưa cần đổi adapter. Bài đo chạy trước các bản sửa sau review và chỉ đo đường socket, không đo tải refetch.

**Kiểm thử:** rspec full 714 example, 0 failure; `apps/pos` 231 unit test xanh; e2e full ba project 327 xanh, 26 bỏ qua, 1 timeout (`feature-recovery.spec.ts:126` trên tablet, chạy lại riêng 8/8 xanh); e2e hai tab với API thật xanh 3/3. Lượt đo được trên stack development mất 1884 ms, sát ngưỡng 2 giây, chủ yếu do server dev trả lời chậm.

**Khác với kế hoạch ban đầu:**
- Bảng `solid_cable_messages` đã có sẵn nên không thêm migration. `/cable` do engine Action Cable tự mount trước mọi route nên không sửa `routes.rb`.
- Sự kiện có thêm `lease_generation`, vì giành quyền sửa không đổi `revision` và client cần biết mình đã mất bản nháp.
- Chỉ `useWorkspaceCredit` chuyển sang poll động. Giữ nguyên poll của VietQR, trả hàng, chốt ca, yêu cầu tiền mặt và màn khách vì chưa có sự kiện nào báo các thay đổi đó; giãn 60 giây sẽ làm thu ngân chờ lâu.
- JWT chỉ kiểm khi kết nối; membership, thiết bị và session được kiểm lại mỗi 5 phút. Socket nối lại không tính là hoạt động của session nhân viên.
- Thu hồi hoặc ghép lại thiết bị ngắt socket từ `Spree::Pos::Device`.

**Còn lại:**
- `approval.requested` phát khi quản lý cấp duyệt, và `apps/pos` chưa có màn hình dùng sự kiện này.
- Các thay đổi không qua `CommandExecutor` chưa phát sự kiện: `Approvals::Revoke`, các job khôi phục, `AllocateTraceability.expire_stale!`, webhook VietQR, `ReceiveTransfer`.
- Proxy production phải chuyển tiếp WebSocket của `/cable` (phase 6).
- `apps/pos/e2e/support/pos-live-fixture.rb` chưa publish sản phẩm lên kênh POS, nên e2e thật có quét mã cần thêm `Spree::ProductPublication`.
