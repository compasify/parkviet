---
phase: 24
title: "App chủ quán"
status: pending
effort: "5 ngày"
dependsOn: [3, 5]
---

# Phase 24: App chủ quán (S8, chế độ `owner` của Flutter)

## Overview

Chủ hoặc quản lý mở app Flutter ở chế độ `owner` trên điện thoại của mình. App hiện doanh thu hôm nay theo thời gian thực, các bàn / phòng đang mở, hộp duyệt từ xa (hủy món đã báo bếp, sửa giờ chơi, in lại / hủy tạm tính, giảm giá), danh sách đặt bàn và cảnh báo. App không thu tiền và không sửa đơn (D7); nó chỉ đọc và cấp `Approval`.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Chế độ `owner` là thiết bị **cá nhân**: ghép bằng mã như các mode khác (phase 2), nhưng mỗi lần mở app cần đăng nhập nhân viên (PIN + sinh trắc học của máy qua `local_auth` sau lần đầu). Một thiết bị owner thấy mọi chi nhánh mà nhân viên đó có quyền, không bị gắn một chi nhánh. |
| Q2 | Duyệt từ xa dùng **yêu cầu duyệt** mới. Hiện `Approval` được tạo trực tiếp bởi người duyệt (`approver = current_user` trong `ApprovalsController#create`), tức người duyệt phải đứng ở máy. Phase này thêm `ApprovalRequest`: người cần duyệt gửi yêu cầu (hành động, subject, revision, số tiền, lý do); chủ bấm Đồng ý trên app → server tạo `Approval` với `approver` là chủ, `requester` là người gửi, đi qua đúng các kiểm tra hiện có (`approver_allowed?`, `approver_is_distinct`, TTL ≤ 1 giờ, gắn revision). Máy người gửi nhận sự kiện và tự dùng approval đó. |
| Q3 | Thông báo: khi app mở, nhận qua `BranchChannel` (sự kiện `approval.requested` đã có trong plan). Khi app ở nền: **push qua FCM / APNs chỉ khi server có internet**. Server không giữ khóa FCM / APNs trực tiếp nếu chạy LAN; nó gửi qua một **push relay tùy chọn** (dịch vụ nhỏ do ParkViet vận hành, nhận payload tối thiểu đã ký: loại sự kiện + id, không có tiền hay tên khách). Không có relay hoặc mất internet thì chỉ có thông báo khi mở app; UI ghi rõ điều này. |
| Q4 | Báo cáo dùng lại `Spree::Pos::Reports::Sales` / `Cashbook` / `Closures` hiện có qua endpoint báo cáo đã có; chỉ thêm một endpoint tổng hợp "hôm nay" nhẹ cho màn chính để không gọi 4 báo cáo mỗi lần mở app. |

## Dữ liệu

- `spree_pos_approval_requests`: `store_id`, `branch_id`, `requester_id`, `action` (một trong các action của `Approval`, cộng các action F&B của phase 14 / 17), `subject_type`, `subject_id`, `revision`, `amount`, `currency`, `reason`, `status` (`pending` | `granted` | `declined` | `expired` | `canceled`), `approval_id` (khi granted), `decided_by_id`, `decided_at`, `expires_at` (mặc định 10 phút).
- `spree_pos_push_registrations`: `device_id`, `platform` (`fcm` | `apns`), `token_ciphertext` (Active Record encryption), `enabled`, `last_error`.
- Cấu hình store: `push_relay_url`, `push_relay_key` (mã hóa). Trống thì không gửi push.

## Server

- Workflow `Spree::Pos::ApprovalRequests::Submit`, `Grant`, `Decline`, `Cancel`. `Grant` gọi lại đúng logic tạo `Approval` của `ApprovalsController#create` (tách phần đó ra service `Spree::Pos::Approvals::Issue` để dùng chung; controller cũ gọi service mới, hành vi không đổi).
- Endpoint `api/v3/admin/pos/approval_requests` (create, index theo chi nhánh / trạng thái, grant, decline, cancel). Quyền: grant cần cùng quyền mà action đó yêu cầu khi tạo `Approval` hôm nay.
- `GET api/v3/admin/pos/owner/today?branch_id=`: doanh thu đã complete, số đơn, doanh thu theo nguồn (`by_source`), bàn / phòng đang mở và tạm tính, số ca đang mở, số đơn hủy / món hủy trong ngày kinh doanh (`business_date`, D8).
- `GET api/v3/admin/pos/owner/open_units`: workspace đang mở theo resource, thời gian ngồi, tạm tính, trạng thái bếp chậm.
- Đặt bàn: đọc `api/v3/admin/pos/reservations` của phase 18 (chỉ đọc + xác nhận / hủy đặt bàn).
- Cảnh báo (`Spree::Pos::OwnerAlerts`): món chờ quá ngưỡng, ca chênh lệch tiền khi đóng ca, nhiều món hủy trong 1 giờ, doanh thu lũy kế năm gần mốc 1 tỷ (research §7), máy in / trạm in lỗi (`PrintJob` failed), hóa đơn điện tử lỗi (phase 7). Mỗi cảnh báo phát `owner_alert.created` (sự kiện mới).
- Push: subscriber trên `OutboxEntry` / sự kiện realtime → `Spree::Pos::Push::RelayClient` gửi job nền (Solid Queue), retry có giới hạn, ghi `last_error`.

## Flutter (`apps/pos-staff`, chế độ `owner`)

- Tab: **Hôm nay** (doanh thu, số đơn, theo nguồn, biểu đồ theo giờ), **Đang mở** (lưới bàn / phòng với đồng hồ và tạm tính, chạm xem dòng), **Duyệt** (badge số yêu cầu; mỗi thẻ hiện ai xin, hành động, món / số tiền / giờ cũ → giờ mới, lý do; Đồng ý cần xác nhận sinh trắc học), **Đặt bàn**, **Cảnh báo**.
- Chọn chi nhánh ở thanh trên; nhớ lựa chọn cuối.
- Realtime khi mở app; kéo xuống để làm mới; khi nhận push thì mở đúng thẻ duyệt.
- Đăng ký push token khi người dùng cho phép; nút tắt push.

## Client web `apps/pos`

- Ở mọi chỗ hiện cần `Approval` (giảm giá, sửa giá, hủy món đã báo bếp, sửa giờ, in lại tạm tính): thêm lựa chọn **"Gửi chủ duyệt"** cạnh luồng quản lý nhập PIN tại chỗ. Gửi xong hiện "Đang chờ duyệt", nghe sự kiện và tự tiếp tục khi được duyệt, hoặc báo bị từ chối.
- Cài đặt store: URL / khóa push relay, trạng thái kết nối.

## File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_approval_requests.rb`, `*_create_spree_pos_push_registrations.rb` | Tạo |
| `server/app/models/spree/pos/approval_request.rb`, `push_registration.rb` | Tạo |
| `server/app/services/spree/pos/approvals/issue.rb` | Tạo, tách từ `approvals_controller.rb` |
| `server/app/controllers/spree/api/v3/admin/pos/approvals_controller.rb` | Sửa: gọi `Approvals::Issue` |
| `server/app/workflows/spree/pos/approval_requests/*.rb` | Tạo |
| `server/app/controllers/spree/api/v3/admin/pos/approval_requests_controller.rb`, `owner_controller.rb`, `push_registrations_controller.rb` | Tạo |
| `server/app/services/spree/pos/owner_alerts.rb`, `push/relay_client.rb`, `server/app/jobs/spree/pos/push_delivery_job.rb` | Tạo |
| `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos-staff/lib/features/owner/` | Tạo |
| `apps/pos/src/components/remote-approval-button.tsx`, `hooks/use-approval-requests.ts` | Tạo |

## Các bước

1. Tách `Approvals::Issue`; chạy lại toàn bộ spec approval hiện có để chứng minh không đổi hành vi.
2. `ApprovalRequest` + workflow + spec (hết hạn, revision đổi làm yêu cầu vô hiệu, người gửi không tự duyệt).
3. Endpoint owner today / open_units dùng lại `Reports::*`; spec so khớp số liệu với báo cáo sales cùng khoảng.
4. Cảnh báo và push relay client (job nền, không chặn lệnh nghiệp vụ).
5. Flutter chế độ owner, sinh trắc học, push.
6. Nút "Gửi chủ duyệt" trên `apps/pos` ở các điểm cần duyệt.

## Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/approvals_spec.rb spec/requests/spree/pos/approval_requests_spec.rb spec/requests/spree/pos/owner_spec.rb spec/workflows/spree/pos/approval_requests/`.
- Spec bảo mật: nhân viên không có quyền duyệt không grant được; yêu cầu của chi nhánh A không hiện cho người chỉ có quyền chi nhánh B.
- Flutter: widget test thẻ duyệt, test realtime với mock channel.
- E2E: thu ngân xin giảm giá → chủ duyệt trên app (giả lập qua API) → thu ngân tiếp tục.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Duyệt nhầm từ xa | Thẻ duyệt hiện đủ thông tin trước / sau; xác nhận sinh trắc học; `Approval` vẫn gắn revision nên đơn đã đổi thì approval vô hiệu. |
| Push lộ dữ liệu ra ngoài | Payload relay chỉ có loại sự kiện + id; app tự gọi server lấy chi tiết. |
| Server LAN không có internet nên không push | Ghi rõ trên UI và tài liệu; vẫn có realtime khi app mở và cùng mạng / có đường vào server. |
| Chủ ở ngoài quán không vào được server LAN | Phase 6 cung cấp tunnel; không có tunnel thì app owner chỉ dùng khi ở quán. |

## Tiêu chí xong

- [ ] Màn Hôm nay khớp số liệu với báo cáo bán hàng cùng ngày kinh doanh.
- [ ] Yêu cầu duyệt từ thu ngân / phục vụ đến app chủ realtime, được duyệt / từ chối, máy gửi tự tiếp tục.
- [ ] Push hoạt động khi có relay và internet; tắt êm khi không có.
- [ ] Spec approval cũ vẫn xanh sau khi tách service.
