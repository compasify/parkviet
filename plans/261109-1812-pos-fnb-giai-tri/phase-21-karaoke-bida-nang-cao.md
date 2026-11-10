---
phase: 21
title: "Karaoke / bida nâng cao"
status: pending
effort: "4 ngày"
dependsOn: [17, 20]
---

# Phase 21: Karaoke / bida nâng cao

## Overview

Phase này bổ sung các tính năng nâng cao cho `timed_billing` (phase 17), theo [research §3.4](../reports/261109-1748-pos-fnb-giai-tri-research.md):

- **tạm dừng / tiếp tục** phiên chơi;
- **gói giờ trả trước**: đếm ngược, báo sắp hết giờ trên bảng phòng và trên các thiết bị;
- **thẻ nạp giờ / nạp tiền**;
- **tiếp viên / nhân viên phục vụ phòng** (chỉ là sổ ghi);
- **cảnh báo giờ hoạt động** (karaoke 0h–8h, cấu hình được);
- **khuyến mãi giờ**: giờ vàng, tặng phút.

Thẻ nạp tiền và thẻ nạp giờ dùng service `StoredValue` của [phase 20](./phase-20-can-tin-the-suat-an.md), nên phải làm sau phase 20. Bảng phase của `plan.md` đã ghi phụ thuộc này.

Relay đèn bida là [phase 26](./phase-26-relay-den-bida.md). Đặt phòng kèm cọc dùng `fnb.reservations` của [phase 18](./phase-18-nha-hang-nang-cao.md).

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | **Tạm dừng** đóng `TimedSegment` đang chạy tại `database_now`. **Tiếp tục** mở segment mới với cùng `RateRule`. Thời gian dừng không tính tiền. Tạm dừng quá `max_pause_minutes` (cấu hình theo chi nhánh) thì cảnh báo. Mỗi lần tạm dừng hoặc tiếp tục đều ghi `AuditEntry`. Dừng dài hơn ngưỡng cần approval `timed.long_pause`, để chặn kiểu "tạm dừng giả" dùng trốn tiền giờ. |
| Q2 | **Gói giờ trả trước** là một sản phẩm dịch vụ có `prepaid_minutes` (ví dụ "Gói 2 giờ"), bán như dòng `timed` có giá gói. Phiên gắn gói thì đếm ngược từ `prepaid_minutes`. Phần chơi quá gói tính theo `RatePlan` như phiên thường. Mốc "sắp hết giờ" (mặc định 10 phút) phát sự kiện `resource.updated` với `alert: 'ending_soon'`. |
| Q3 | **Thẻ nạp tiền** dùng service `Spree::Pos::StoredValue` mà phase 20 đã làm cho ví căng tin: tiền khách gửi giữ là `ReceivedFunds` không có workspace, sổ chỉ thêm, allocation FIFO. Phase này chỉ thêm kind `money` và `minutes`, không đổi hành vi của kind `meal`. |
| Q4 | **Thẻ nạp giờ** giữ số phút, không giữ số tiền. Khi bán thẻ, tiền vào `StoredValue` kèm `minutes`. Khi trừ phút vào một phiên, số tiền được allocate là `phút × (giá thẻ / tổng phút)` (giá mỗi phút cố định lúc bán thẻ). Nhờ vậy tiền chỉ thành doanh thu khi dịch vụ đã được dùng. |
| Q5 | **Tiếp viên** (đã chốt 09/11/2026: chỉ ghi sổ): `AttendantAssignment` ghi nhân viên, phòng, giờ bắt đầu và giờ kết thúc. Bản ghi này không tạo dòng tiền và không vào hóa đơn. Phase chỉ có báo cáo giờ phục vụ theo nhân viên. |
| Q6 | **Giờ hoạt động** là cấu hình theo chi nhánh (`operating_windows` theo ngày trong tuần). Hồ sơ `karaoke_bida` gợi ý chặn mở phiên từ 0h đến 8h. Mở phiên ngoài khung chỉ **cảnh báo** và yêu cầu xác nhận, không chặn cứng, vì quy định vẫn chưa được xác nhận (research §7). |
| Q7 | **Khuyến mãi giờ:**<br>• Giờ vàng là `RateRule` có giá thấp hơn trong một khung giờ, kèm nhãn hiển thị; không thêm cơ chế mới.<br>• Tặng phút là `TimedPromotion`, theo điều kiện "chơi ≥ X phút thì tặng Y phút" hoặc "đặt gói thì tặng Y phút", và được áp khi chốt giá phiên.<br>Phút tặng hiện thành một đoạn giá 0 trên bill, để hóa đơn vẫn ghi đúng tổng số giờ. |

## Dữ liệu

- `spree_pos_timed_segments`:
  - thêm `ended_reason` (`pause | move | stop | split_window`);
  - thêm `promotion_id` (null) cho đoạn tặng.
- `spree_pos_timed_sessions`:
  - thêm `prepaid_minutes` (null) và `package_line_id` (null);
  - thêm `stored_value_account_id` (null), khi phiên trừ vào thẻ giờ.
- `spree_pos_timed_promotions`: `branch_id`, `name`, `kind` (`bonus_after | bonus_with_package`), `threshold_minutes`, `bonus_minutes`, `resource_kinds`, `active_windows`, `status`.
- `spree_pos_stored_value_accounts` (phase 20): thêm kind `money | minutes` và cột `card_digest` (thẻ nạp in QR hoặc RFID, lưu digest như `MealCard`).
- `spree_pos_stored_value_entries` (phase 20): dùng cột `minutes` cho thẻ giờ.
- `spree_pos_attendant_assignments`: `branch_id`, `resource_id`, `timed_session_id`, `staff_id`, `started_at`, `ended_at`, `note`.
- `spree_pos_branches`: thêm `operating_windows` (jsonb) và `max_pause_minutes`.
- Approval action mới: `timed.long_pause` và `stored_value.adjust`.

## Server

1. `TimedSessions::Pause` và `TimedSessions::Resume` (idempotent theo key):
   - kiểm tra đúng trạng thái;
   - đóng hoặc mở segment;
   - phát `resource.updated`.

   Tiếp tục sau một lần dừng dài cần approval.
2. Job `TimedSessions::AlertJob` chạy mỗi phút:
   - với phiên có gói: phát `ending_soon` và `ended_package`;
   - với phiên đang dừng quá ngưỡng: phát `pause_too_long`.

   Job chỉ đọc và phát sự kiện, không đổi tiền.
3. Bộ tính giá phiên (phase 17):
   - trừ `prepaid_minutes` trước, phần dư tính theo `RateRule`;
   - áp `TimedPromotion` cuối cùng;
   - kết quả là danh sách đoạn có giá, kể cả đoạn tặng giá 0.
4. `StoredValue`:
   - các lệnh `TopUp`, `Spend`, `Refund`, `Adjust` cho kind `money | minutes`;
   - tender kind `stored_value` cho thẻ tiền;
   - lệnh `TimedSessions::ApplyMinutesCard`, trừ phút khi chốt phiên.
5. `AttendantAssignments`:
   - `start` và `stop`, gọi từ S1 hoặc S2;
   - báo cáo tổng giờ theo nhân viên và theo ngày kinh doanh.
6. `OperatingHours.check(branch, at)`: dùng khi mở phiên. Trả `warning: 'outside_operating_hours'` trong response, không phải `Conflict`.
7. API dưới `/api/v3/admin/pos/`:
   - `timed_sessions/:id/pause` và `timed_sessions/:id/resume`;
   - `timed_promotions`;
   - `stored_value_accounts`, gồm `top_ups`, `refund`, `adjust`;
   - `attendant_assignments`;
   - `reports/attendants`.

   Cập nhật `server/openapi/pos-staff.yaml`.

## Client web (`apps/pos`)

- Ô phòng trên `resource_board`:
  - nút Tạm dừng / Tiếp tục;
  - đồng hồ hiện "đang dừng" khi phiên đang tạm dừng;
  - đếm ngược khi có gói;
  - viền vàng khi sắp hết giờ, đỏ khi đã hết gói;
  - bộ lọc "Sắp hết giờ" dùng cờ `ending_soon` lấy từ server.
- Khi mở phiên:
  - chọn gói giờ hoặc quẹt thẻ giờ;
  - mở ngoài khung giờ hoạt động thì hiện hộp xác nhận.
- Bill hiện từng đoạn: tên khung giá, phút và tiền. Đoạn tặng ghi "Tặng".
- Trang **Thẻ nạp**: bán thẻ (mở bước tender), tra số dư, lịch sử.
- Trang **Khuyến mãi giờ**.
- Báo cáo **Tiếp viên**.

## Flutter (`apps/pos-staff`)

- Mode `waiter` (phục vụ phòng):
  - tạm dừng / tiếp tục, nếu có quyền;
  - gán tiếp viên;
  - nhận thông báo "Phòng 5 còn 10 phút" qua realtime.
- Mode `owner`: duyệt yêu cầu dừng dài và điều chỉnh thẻ, qua `approval.requested`. Màn duyệt chung thuộc phase 24.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_pause_package_to_spree_pos_timed_sessions.rb`, `*_create_spree_pos_timed_promotions.rb`, `*_extend_spree_pos_stored_value_accounts.rb`, `*_create_spree_pos_attendant_assignments.rb`, `*_add_operating_windows_to_spree_pos_branches.rb` |
| Tạo | `server/app/models/spree/pos/timed_promotion.rb`, `attendant_assignment.rb` |
| Tạo | `server/app/workflows/spree/pos/timed_sessions/pause.rb`, `resume.rb`, `apply_minutes_card.rb`, `server/app/services/spree/pos/operating_hours.rb`, `server/app/jobs/spree/pos/timed_sessions/alert_job.rb` |
| Sửa | Bộ tính giá phiên của phase 17, `server/app/services/spree/pos/stored_value.rb` và `stored_value_account.rb` (kind mới), workflow tender (`stored_value`), `server/app/models/spree/pos/approval.rb`, `server/config/routes.rb`, `server/config/pos/business_profiles.yml`, `server/openapi/pos-staff.yaml` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/timed_promotions_controller.rb`, `stored_value_accounts_controller.rb`, `attendant_assignments_controller.rb` |
| Tạo | `apps/pos/src/pages/stored-value.tsx`, `apps/pos/src/pages/timed-promotions.tsx`, `apps/pos/src/hooks/use-stored-value.ts` |
| Sửa | Component ô phòng của `resource_board` (phase 17), `apps/pos/src/router.tsx`, `apps/pos/src/locales/*` |
| Sửa | `apps/pos-staff/lib/modes/waiter/` |

## Các bước

1. Làm tạm dừng / tiếp tục, kèm audit và approval cho lần dừng dài.
2. Làm gói giờ trả trước và job cảnh báo.
3. Thêm kind `money` và `minutes` vào `StoredValue`; làm thẻ giờ trừ vào phiên.
4. Làm khuyến mãi giờ: nhãn giờ vàng trên `RateRule` và `TimedPromotion` tặng phút.
5. Làm sổ tiếp viên và báo cáo.
6. Làm cảnh báo giờ hoạt động.
7. Làm API, OpenAPI, sinh lại client Dart; màn web và mode waiter.

## Kiểm thử

- Spec tạm dừng: phiên 19:00–21:00 dừng 20:00–20:15 thì chỉ tính 105 phút. Dừng và tiếp tục với cùng key chỉ ghi một lần. Tiếp tục sau lần dừng dài mà không có approval thì bị từ chối.
- Spec gói: gói 120 phút chơi 135 phút thì tính gói cộng 15 phút theo khung giá. Job phát `ending_soon` đúng một lần ở mốc 110 phút.
- Spec thẻ giờ: thẻ 600 phút giá 500.000 dùng 90 phút thì allocate 75.000 và còn 510 phút. Không đủ phút thì phần còn lại tính tiền.
- Spec khuyến mãi: chơi ≥ 120 phút tặng 15 phút, đoạn tặng giá 0 xuất hiện trên bill. Hóa đơn điện tử ghi tổng số giờ.
- Spec giờ hoạt động: mở phiên lúc 0:30 trả warning, không trả lỗi.
- Spec hồi quy: toàn bộ spec ví căng tin (kind `meal`) vẫn xanh.
- E2E web: mở phòng có gói, tạm dừng, tiếp tục, nhận cảnh báo sắp hết giờ, thanh toán có đoạn tặng.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Tạm dừng bị lạm dụng để giảm tiền | Có audit, có approval khi dừng lâu, có báo cáo số lần dừng theo nhân viên. |
| Thêm kind mới làm hỏng ví căng tin | Logic theo kind tách riêng; chạy lại toàn bộ spec của phase 20. |
| Job cảnh báo chạy trễ khi server LAN yếu | Client tự đếm ngược theo `ends_at` mà server trả về; job chỉ phát sự kiện để báo các thiết bị khác. |

## Tiêu chí xong

- [ ] Tạm dừng / tiếp tục tính đúng tiền, có audit, và có duyệt khi dừng lâu.
- [ ] Gói giờ đếm ngược. S1 và app phục vụ nhận cảnh báo sắp hết giờ.
- [ ] Thẻ nạp tiền và thẻ nạp giờ đi qua lõi tiền; doanh thu chỉ ghi khi đã dùng dịch vụ.
- [ ] Sổ tiếp viên và báo cáo giờ phục vụ.
- [ ] Mở phiên ngoài giờ hoạt động có cảnh báo.
- [ ] Giờ vàng và tặng phút hiện đúng trên bill và hóa đơn.
- [ ] OpenAPI, spec và e2e đều xanh; spec ví của phase 20 không hồi quy.
