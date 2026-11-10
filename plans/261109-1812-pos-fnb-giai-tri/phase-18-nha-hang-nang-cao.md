---
phase: 18
title: "Nhà hàng nâng cao: expo, course, ghế, buffet, đặt bàn + cọc"
status: pending
effort: "9 ngày"
dependsOn: [16]
---

# Phase 18: Nhà hàng nâng cao

## Overview

Phase này đưa nhà hàng từ bản cơ bản của đợt 2 lên bản đầy đủ. Có năm phần:

- chế độ **chạy bàn / expo (S4)** trong app Flutter;
- **course hold/fire**: món "chờ" chỉ hiện ở expo, và chỉ xuống bếp khi được fire;
- **ghế** trên dòng món, kèm tách bill theo ghế;
- **buffet** qua SaleLine kind `cover`;
- module **`fnb.reservations`**: đặt bàn / phòng, kiểm tra bàn trống, nhận cọc.

Nguồn: research §3.3, §4 (S4), §5.2. S4 không thu tiền (D7). Cọc đi qua lõi tiền hiện có: `ReceivedFunds`, `FundsAllocation`, `LiabilityPayout`.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Expo là **mode `expo` của `Device`** (D3). Trạm `KitchenStation.kind = expo` gom mọi `KitchenTicketItem` của chi nhánh sau khi trạm prep báo `ready`. |
| Q2 | Course là số nguyên trên dòng (`course`). Nhãn khai vị / món chính / tráng miệng đặt theo chi nhánh. Dòng có `course_status = held` thì lệnh báo bếp của phase 14 **không** tạo ticket cho trạm prep; món chỉ hiện ở expo, mục "chờ fire". Lệnh `fire_course` gửi phần chênh lệch của course đó qua cùng đường báo bếp, idempotent theo key. |
| Q3 | `seat` là số nguyên tùy chọn trên dòng. Dòng không có ghế là món dùng chung. Tách bill theo ghế dùng lại workflow tách của phase 13: món dùng chung chia đều cho các ghế, hoặc để thu ngân chọn ghế. |
| Q4 | Buffet: vé là dòng `cover` (mỗi khách một vé, theo **hạng vé**). Món gọi trong buffet là dòng `menu` giá 0, gắn vào dòng vé, và chỉ được chọn trong thực đơn của hạng vé đó. Thuế của vé lấy theo `TaxCategory` của sản phẩm vé (D8). |
| Q5 | Giới hạn số món mỗi lượt và khoảng cách giữa hai lượt được kiểm ở server khi báo bếp. Hết thời lượng buffet chỉ **cảnh báo** trên bảng bàn của S1, S2 và S4; đơn không bị khóa. |
| Q6 | Cọc là **tiền khách gửi giữ, không phải doanh thu**. Mỗi khoản cọc là một `ReceivedFunds` không gắn workspace, gắn với `Reservation`; số dư chưa dùng hiện ở `FundsBalance#available`.<br>• **Khách đến:** cọc trừ vào đơn bằng `FundsAllocation`, giống cách `Collection` đang làm.<br>• **Hoàn cọc:** dùng `LiabilityPayout`.<br>• **Mất cọc:** tạo một đơn dịch vụ "phí giữ chỗ" (dòng `ordinary`, có thuế), rồi allocate tiền cọc vào đơn đó.<br>Hoàn cọc và mất cọc đều cần `Approval`. |
| Q7 | Mô hình cọc được ghi thành một ADR **dùng chung với module `deposits` của lộ trình bán lẻ** ([kiến trúc §9.1](../reports/261108-1800-pos-multi-industry-architecture.md)). |

## Dữ liệu

- **`spree_pos_sale_lines`**, thêm cột:
  - `course` (smallint, null);
  - `course_status` (`none | held | fired`, mặc định `none`);
  - `seat` (smallint, null);
  - `buffet_tier_id` (null, chỉ có ở dòng `cover`);
  - `buffet_cover_line_id` (null; trỏ tới dòng `cover` mà món buffet thuộc về).
- **`spree_pos_buffet_tiers`**: `branch_id`, `name`, `product_id` (sản phẩm vé), `duration_minutes`, `round_item_limit`, `round_interval_minutes`, `status`.
  - Bảng con `spree_pos_buffet_tier_items`: `buffet_tier_id`, `product_id`, `max_per_round` (null).
- **`spree_pos_course_labels`**: `branch_id`, `position`, `name`. Có sẵn 3 dòng mặc định.
- **`spree_pos_reservations`**:
  - Cột: `branch_id`, `customer_profile_id` (null), `guest_name`, `phone`, `party_size`, `starts_at`, `ends_at`, `source` (`phone | walk_in | online`), `note`, `workspace_id` (gán khi khách đến), `created_by_id`.
  - `status`: `booked | seated | completed | no_show | canceled`.
  - Tài nguyên được giữ nằm ở bảng con `spree_pos_reservation_resources` (`reservation_id`, `resource_id`, `starts_at`, `ends_at`, `active`). Bảng con có exclusion constraint `EXCLUDE USING gist (resource_id WITH =, tstzrange(starts_at, ends_at) WITH &&) WHERE (active)`, cần extension `btree_gist`.
- **`spree_pos_reservation_deposits`**:
  - Cột: `reservation_id`, `received_funds_id`, `amount`, `currency`, `resolution_order_id`, `liability_payout_id`.
  - `status`: `held | applied | refunded | forfeited`.
- **Approval:** thêm `Spree::Pos::Reservation` vào `Approval::SUBJECTS`.
  - Action mới: `reservation.refund_deposit`, `reservation.forfeit_deposit`, `buffet.override_round`.
- **Capabilities** mới (khai báo trong `ASSIGNABLE`): `pos.reservation.manage`, `pos.expo.operate`.
- **Module:**
  - `fnb.reservations` đăng ký `available`.
  - Thêm vào `modules` của hồ sơ `nha_hang`; ở `karaoke_bida` và `bar_pub_club` chỉ là gợi ý (D9).

## Server

1. **Course.**
   - `Spree::Pos::Kitchen::FireCourse(workspace, course, key)`: chuyển dòng `held → fired`, rồi gọi đường báo bếp theo phần chênh lệch của phase 14.
   - Sửa đường báo bếp để bỏ qua dòng `held`; với các dòng này, chỉ tạo bản ghi "chờ fire" cho trạm expo.
2. **Đã phục vụ.** `Kitchen::MarkServed(ticket_item, key)` chỉ nhận item `ready` và chuyển sang `served`. Phát `kitchen_ticket.updated` và `workspace.updated`.
3. **Guard buffet** trong báo bếp. Mỗi lần báo bếp kiểm tra:
   - món có trong tier;
   - số món trong lượt ≤ `round_item_limit`;
   - lượt mới mở sau `round_interval_minutes`, tính từ ticket buffet gần nhất.

   Vi phạm thì trả `Conflict reason: 'buffet_round_limit'`. Quản lý vượt được bằng approval `buffet.override_round`.
4. **Tách theo ghế.** Workflow tách của phase 13 nhận thêm `by: 'seat'`. Mỗi ghế thành một workspace con, có draft order riêng. Giảm giá cấp đơn được phân bổ lại qua `DiscountIntent`.
5. **Đặt chỗ:** `Spree::Pos::Reservations::Create / Update / Cancel / Seat / Availability`.
   - `Seat` mở workspace `service_mode = dine_in` trên tài nguyên đã giữ, chuyển đặt chỗ sang `seated` và phát `resource.updated`.
   - `Availability(branch, starts_at, ends_at, party_size)` trả các tài nguyên còn trống, đủ sức chứa và không ở trạng thái `cleaning`.
   - Job `Reservations::MarkNoShowJob` chạy theo ngưỡng ân hạn của chi nhánh. Job chỉ đổi trạng thái, không tự xử lý cọc.
6. **Cọc:** `Reservations::TakeDeposit / ApplyDeposit / RefundDeposit / ForfeitDeposit`, mọi lệnh đi qua `CommandExecutor`.
   - `TakeDeposit` dùng tender lõi và ghi `ReceivedFunds` không có workspace.
   - `ApplyDeposit` chạy trong luồng thanh toán của workspace.
   - `RefundDeposit` và `ForfeitDeposit` tiêu thụ approval.
7. **API** dưới `/api/v3/admin/pos/`:
   - `reservations` (CRUD, `availability`, `:id/seat`, `:id/deposits`, `deposits/:id/refund`, `deposits/:id/forfeit`);
   - `workspaces/:id/courses/:course/fire`;
   - `kitchen_ticket_items/:id/served`;
   - `buffet_tiers`.

   Cập nhật `server/openapi/pos-staff.yaml`.

## Client web (`apps/pos`)

- **Trang Đặt bàn:** timeline theo ngày, mỗi tài nguyên một hàng.
  - Form đặt kiểm tra bàn trống ngay khi nhập.
  - Nút Nhận cọc mở bước tender.
  - Các nút Seat, No-show, Hoàn cọc, Mất cọc (hai nút sau đi qua luồng xin duyệt).
- **Bảng bàn** (phase 13):
  - ô "Đã đặt" hiện giờ khách đến;
  - cảnh báo buffet: vàng trong 10 phút cuối, đỏ khi quá giờ.
- **Màn đơn:**
  - chọn course và ghế cho từng dòng; nút "Giữ" / "Fire course";
  - chọn hạng vé buffet, mặc định số vé bằng số khách; thực đơn lọc theo hạng vé.
- **Thanh toán:**
  - hiện cọc đã nhận và trừ vào số phải thu;
  - tách bill có thêm lựa chọn "Theo ghế".

## Flutter (`apps/pos-staff`)

- **Mode `expo`:**
  - cột "Chờ fire" theo bàn và course;
  - cột "Đã xong, cần mang ra", có bàn, ghế và thời gian chờ;
  - chạm để đánh dấu đã phục vụ; nút Fire course; lọc theo khu vực.
- **Mode `waiter`:**
  - chọn course và ghế khi gọi món;
  - Fire course;
  - đếm số món buffet còn được gọi trong lượt.
- **Mode `owner`:** chỉ hook ở phase này, gồm danh sách đặt bàn trong ngày và yêu cầu duyệt hoàn / mất cọc nhận qua `approval.requested`. Màn hình đầy đủ ở phase 24.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_course_seat_buffet_to_spree_pos_sale_lines.rb` |
| Tạo | `server/db/migrate/*_create_spree_pos_buffet_tiers.rb`, `*_create_spree_pos_course_labels.rb`, `*_create_spree_pos_reservations.rb` (gồm `btree_gist`, tài nguyên giữ, cọc) |
| Tạo | `server/app/models/spree/pos/buffet_tier.rb`, `buffet_tier_item.rb`, `course_label.rb`, `reservation.rb`, `reservation_resource.rb`, `reservation_deposit.rb` |
| Tạo | `server/app/workflows/spree/pos/kitchen/fire_course.rb`, `kitchen/mark_served.rb`, `server/app/workflows/spree/pos/reservations/` (create, update, cancel, seat, take_deposit, apply_deposit, refund_deposit, forfeit_deposit) |
| Tạo | `server/app/services/spree/pos/reservations/availability.rb`, `server/app/jobs/spree/pos/reservations/mark_no_show_job.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/reservations_controller.rb`, `buffet_tiers_controller.rb`, `workspaces/courses_controller.rb` |
| Sửa | `server/app/models/spree/pos/approval.rb`, `capabilities.rb`, `sale_line.rb`, `server/config/initializers/pos_modules.rb`, `server/config/pos/business_profiles.yml`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `docs/adr/pos-tien-coc-giu-cho.md` |
| Tạo | `apps/pos/src/pages/reservations.tsx`, `apps/pos/src/hooks/use-reservations.ts`, `apps/pos/src/components/course-seat-picker.tsx`, `apps/pos/src/components/buffet-tier-picker.tsx` |
| Sửa | `apps/pos/src/router.tsx`, `apps/pos/src/components/payment-panel.tsx`, `apps/pos/src/locales/*` |
| Tạo / Sửa | `apps/pos-staff/lib/modes/expo/`, `apps/pos-staff/lib/modes/waiter/` |

## Các bước

1. Viết ADR cọc:
   - cọc là `ReceivedFunds` chưa allocate;
   - trừ vào đơn bằng allocation; hoàn qua payout; mất cọc thì thành đơn dịch vụ;
   - các module `deposits`, trả góp và thanh toán theo tiến độ của bán lẻ dùng cùng mô hình.
2. Kiểm tra `btree_gist` có sẵn trong image Postgres (`pnpm spree db:console`, `\dx`). Viết migration và model.
3. Làm course hold/fire và mark served; sửa đường báo bếp để bỏ qua dòng `held`.
4. Làm buffet: tier, guard lượt, cảnh báo thời lượng.
5. Làm tách bill theo ghế.
6. Làm đặt chỗ, availability, job no-show, cọc và approvals.
7. Làm controller, routes, OpenAPI; sinh lại client Dart.
8. Màn web: Đặt bàn, chọn course / ghế, buffet, cọc trong thanh toán.
9. Flutter: mode expo, bổ sung cho mode waiter.
10. Bật `fnb.reservations` trong registry, cập nhật hồ sơ ngành, chạy toàn bộ kiểm thử.

## Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/reservations_spec.rb`:
  - đặt trùng giờ trên một bàn bị từ chối;
  - availability đúng theo sức chứa và trạng thái;
  - seat mở workspace gắn bàn.
- Workflow spec cọc:
  - nhận cọc không tạo doanh thu và không tạo order;
  - apply trừ đúng `financial.remaining`;
  - refund thiếu approval thì bị từ chối, có approval thì tạo payout;
  - forfeit tạo đơn phí giữ chỗ có thuế, rồi complete.
- Workflow spec course:
  - báo bếp không gửi dòng `held`;
  - fire gửi đúng phần chênh lệch;
  - fire hai lần cùng key chỉ ra một ticket.
- Spec buffet:
  - món ngoài tier bị từ chối;
  - vượt giới hạn lượt bị từ chối nếu không có approval;
  - có approval thì qua.
- Spec tách theo ghế: tổng các bill con bằng bill gốc, kể cả khi có giảm giá cấp đơn.
- E2E web: đặt bàn → nhận cọc → seat → gọi món → thanh toán có trừ cọc → in hóa đơn.
- Flutter integration: item `ready` hiện ở expo qua realtime; bấm served thì S1 cập nhật.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Image Postgres thiếu `btree_gist` | Bước 2 kiểm tra trước. Nếu thiếu, khóa hàng `Resource` và kiểm tra chồng giờ trong transaction. |
| Cọc nằm lâu không xử lý, đối soát quỹ khó | Báo cáo "cọc đang giữ" theo chi nhánh. Đặt chỗ `no_show` vào danh sách cần xử lý. |
| Hold/fire làm bếp bỏ sót món | Expo luôn hiện cột "Chờ fire" kèm thời gian. Course giữ quá ngưỡng thì cảnh báo. |
| Tách theo ghế lệch giảm giá | Phân bổ lại qua `DiscountIntent`; có spec tổng tiền. |

## Tiêu chí xong

- [ ] Expo trên Flutter thấy món xong, đánh dấu đã phục vụ, fire được course; S1 / S2 cập nhật trong ≤ 2 giây.
- [ ] Course đang giữ không xuống trạm prep cho tới khi fire.
- [ ] Tách bill theo ghế ra đúng tổng.
- [ ] Buffet có hạng vé, thực đơn theo hạng, giới hạn lượt và cảnh báo giờ.
- [ ] Đặt bàn có kiểm tra trống. Nhận, trừ, hoàn và mất cọc đều đi qua lõi tiền; hoàn và mất cọc có approval.
- [ ] ADR cọc đã commit và ghi rõ `deposits` của bán lẻ dùng chung mô hình.
- [ ] OpenAPI và client Dart đã cập nhật. Spec, e2e và Flutter test đều xanh.
