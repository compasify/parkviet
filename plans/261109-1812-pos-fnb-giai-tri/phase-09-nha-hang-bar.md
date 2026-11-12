---
phase: 9
title: "Nhà hàng nâng cao, bar"
status: in-progress
effort: "16 ngày"
dependsOn: [8]
---

# Phase 9: Nhà hàng nâng cao, bar

## Overview

Hai phần cùng mở rộng mô hình bàn của plan 8 cho các ngành phục vụ tại bàn.

| Phần | Nội dung | Effort |
|---|---|---|
| 9A | Nhà hàng nâng cao: expo, course, ghế, buffet, đặt bàn + cọc | 9 ngày |
| 9B | Bar, pub & club | 7 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 9A: Nhà hàng nâng cao: expo, course, ghế, buffet, đặt bàn + cọc

### Overview

Phần này đưa nhà hàng từ bản cơ bản của đợt 2 lên bản đầy đủ. Có năm phần:

- chế độ **chạy bàn / expo (S4)** trong app Flutter;
- **course hold/fire**: món "chờ" chỉ hiện ở expo, và chỉ xuống bếp khi được fire;
- **ghế** trên dòng món, kèm tách bill theo ghế;
- **buffet** qua SaleLine kind `cover`;
- module **`fnb.reservations`**: đặt bàn / phòng, kiểm tra bàn trống, nhận cọc.

Nguồn: research §3.3, §4 (S4), §5.2. S4 không thu tiền (D7). Cọc đi qua lõi tiền hiện có: `ReceivedFunds`, `FundsAllocation`, `LiabilityPayout`.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Expo là **mode `expo` của `Device`** (D3). Trạm `KitchenStation.kind = expo` gom mọi `KitchenTicketItem` của chi nhánh sau khi trạm prep báo `ready`. |
| Q2 | Course là số nguyên trên dòng (`course`). Nhãn khai vị / món chính / tráng miệng đặt theo chi nhánh. Dòng có `course_status = held` thì lệnh báo bếp của phần 8B **không** tạo ticket cho trạm prep; món chỉ hiện ở expo, mục "chờ fire". Lệnh `fire_course` gửi phần chênh lệch của course đó qua cùng đường báo bếp, idempotent theo key. |
| Q3 | `seat` là số nguyên tùy chọn trên dòng. Dòng không có ghế là món dùng chung. Tách bill theo ghế dùng lại workflow tách của phần 8A: món dùng chung chia đều cho các ghế, hoặc để thu ngân chọn ghế. |
| Q4 | Buffet: vé là dòng `cover` (mỗi khách một vé, theo **hạng vé**). Món gọi trong buffet là dòng `menu` giá 0, gắn vào dòng vé, và chỉ được chọn trong thực đơn của hạng vé đó. Thuế của vé lấy theo `TaxCategory` của sản phẩm vé (D8). |
| Q5 | Giới hạn số món mỗi lượt và khoảng cách giữa hai lượt được kiểm ở server khi báo bếp. Hết thời lượng buffet chỉ **cảnh báo** trên bảng bàn của S1, S2 và S4; đơn không bị khóa. |
| Q6 | Cọc là **tiền khách gửi giữ, không phải doanh thu**. Mỗi khoản cọc là một `ReceivedFunds` không gắn workspace, gắn với `Reservation`; số dư chưa dùng hiện ở `FundsBalance#available`.<br>• **Khách đến:** cọc trừ vào đơn bằng `FundsAllocation`, giống cách `Collection` đang làm.<br>• **Hoàn cọc:** dùng `LiabilityPayout`.<br>• **Mất cọc:** tạo một đơn dịch vụ "phí giữ chỗ" (dòng `ordinary`, có thuế), rồi allocate tiền cọc vào đơn đó.<br>Hoàn cọc và mất cọc đều cần `Approval`. |
| Q7 | Mô hình cọc được ghi thành một ADR **dùng chung với module `deposits` của lộ trình bán lẻ** ([kiến trúc §9.1](../reports/261108-1800-pos-multi-industry-architecture.md)). |

### Dữ liệu

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

### Server

1. **Course.**
   - `Spree::Pos::Kitchen::FireCourse(workspace, course, key)`: chuyển dòng `held → fired`, rồi gọi đường báo bếp theo phần chênh lệch của phần 8B.
   - Sửa đường báo bếp để bỏ qua dòng `held`; với các dòng này, chỉ tạo bản ghi "chờ fire" cho trạm expo.
2. **Đã phục vụ.** `Kitchen::MarkServed(ticket_item, key)` chỉ nhận item `ready` và chuyển sang `served`. Phát `kitchen_ticket.updated` và `workspace.updated`.
3. **Guard buffet** trong báo bếp. Mỗi lần báo bếp kiểm tra:
   - món có trong tier;
   - số món trong lượt ≤ `round_item_limit`;
   - lượt mới mở sau `round_interval_minutes`, tính từ ticket buffet gần nhất.

   Vi phạm thì trả `Conflict reason: 'buffet_round_limit'`. Quản lý vượt được bằng approval `buffet.override_round`.
4. **Tách theo ghế.** Workflow tách của phần 8A nhận thêm `by: 'seat'`. Mỗi ghế thành một workspace con, có draft order riêng. Giảm giá cấp đơn được phân bổ lại qua `DiscountIntent`.
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

### Client web (`apps/pos`)

- **Trang Đặt bàn:** timeline theo ngày, mỗi tài nguyên một hàng.
  - Form đặt kiểm tra bàn trống ngay khi nhập.
  - Nút Nhận cọc mở bước tender.
  - Các nút Seat, No-show, Hoàn cọc, Mất cọc (hai nút sau đi qua luồng xin duyệt).
- **Bảng bàn** (phần 8A):
  - ô "Đã đặt" hiện giờ khách đến;
  - cảnh báo buffet: vàng trong 10 phút cuối, đỏ khi quá giờ.
- **Màn đơn:**
  - chọn course và ghế cho từng dòng; nút "Giữ" / "Fire course";
  - chọn hạng vé buffet, mặc định số vé bằng số khách; thực đơn lọc theo hạng vé.
- **Thanh toán:**
  - hiện cọc đã nhận và trừ vào số phải thu;
  - tách bill có thêm lựa chọn "Theo ghế".

### Flutter (`apps/pos-staff`)

- **Mode `expo`:**
  - cột "Chờ fire" theo bàn và course;
  - cột "Đã xong, cần mang ra", có bàn, ghế và thời gian chờ;
  - chạm để đánh dấu đã phục vụ; nút Fire course; lọc theo khu vực.
- **Mode `waiter`:**
  - chọn course và ghế khi gọi món;
  - Fire course;
  - đếm số món buffet còn được gọi trong lượt.
- **Mode `owner`:** chỉ hook ở phần này, gồm danh sách đặt bàn trong ngày và yêu cầu duyệt hoàn / mất cọc nhận qua `approval.requested`. Màn hình đầy đủ ở phần 12C.

### File

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

### Các bước

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

### Kiểm thử

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

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Image Postgres thiếu `btree_gist` | Bước 2 kiểm tra trước. Nếu thiếu, khóa hàng `Resource` và kiểm tra chồng giờ trong transaction. |
| Cọc nằm lâu không xử lý, đối soát quỹ khó | Báo cáo "cọc đang giữ" theo chi nhánh. Đặt chỗ `no_show` vào danh sách cần xử lý. |
| Hold/fire làm bếp bỏ sót món | Expo luôn hiện cột "Chờ fire" kèm thời gian. Course giữ quá ngưỡng thì cảnh báo. |
| Tách theo ghế lệch giảm giá | Phân bổ lại qua `DiscountIntent`; có spec tổng tiền. |

### Tiêu chí xong

- [ ] Expo trên Flutter thấy món xong, đánh dấu đã phục vụ, fire được course; S1 / S2 cập nhật trong ≤ 2 giây.
- [x] Course đang giữ không xuống trạm prep cho tới khi fire.
- [x] Tách bill theo ghế ra đúng tổng.
- [ ] Buffet có hạng vé, thực đơn theo hạng, giới hạn lượt và cảnh báo giờ.
- [x] Đặt bàn có kiểm tra trống. Nhận, trừ, hoàn và mất cọc đều đi qua lõi tiền; hoàn và mất cọc có approval.
- [x] ADR cọc đã commit và ghi rõ `deposits` của bán lẻ dùng chung mô hình.
- [ ] OpenAPI và client Dart đã cập nhật. Spec, e2e và Flutter test đều xanh.

### Kết quả

Đã làm:

- **Dữ liệu.** Ba migration (`20261112020000_add_course_seat_buffet_to_spree_pos_sale_lines`, `…020100_create_spree_pos_course_labels`, `…020200_create_spree_pos_reservations`) đã chạy ở DB dev và test. Bảng hạng buffet và món của hạng nằm trong migration đầu. Dòng bán có `course`, `course_status` (`none | held | fired`), `seat`, `buffet_tier_id`, `buffet_cover_line_id`. Đặt chỗ có bảng tài nguyên giữ (exclusion constraint `btree_gist`) và bảng cọc. Model mới: `BuffetTier`, `BuffetTierItem`, `CourseLabel`, `Reservation`, `ReservationResource` (scope `overlapping`), `ReservationDeposit`.
- **Course.** `Kitchen::FireCourse` chuyển dòng `held → fired` rồi gửi phần chênh lệch qua đường báo bếp, idempotent theo key; fire lại báo `course_not_held`. Báo bếp bỏ qua dòng `held`. Bảng bếp có thêm `held`: các course đang giữ của đơn bàn còn mở, theo bàn và course, kèm tên course (nhãn của chi nhánh, nếu không có thì "Lượt N"), thời điểm giữ và món theo ghế. Phần này chỉ trả cho máy expo hoặc khi xem mọi trạm. Fire được từ thu ngân (`workspaces/:id/courses/:course/fire`) và từ máy expo (`pos_device/kitchen/workspaces/:id/courses/:course/fire`). `EditUnsentLine` đổi được course, ghế và giữ của dòng chưa gửi.
- **Buffet.** `Buffet::SaveTier` tạo và sửa hạng vé. Vé là dòng `cover`, mỗi khách một vé, giá theo sản phẩm vé. Món buffet giá 0 gắn với dòng vé. `Kitchen::BuffetRounds` kiểm tra khi báo bếp: món có trong hạng (`buffet_item_not_in_tier`), số món mỗi lượt và khoảng cách giữa hai lượt (`buffet_round_limit`). Quản lý vượt được bằng approval `buffet.override_round`. Bảng bàn trả `buffet_ends_at`.
- **Tách theo ghế.** `Tables::SplitBySeat` (`split` với `by: seat`) tạo mỗi ghế một đơn ở cùng bàn. Món dùng chung theo ghế thu ngân chọn trong `shared`, nếu không chọn thì về ghế đầu. Giảm giá cấp đơn được chia lại theo tỷ lệ; spec kiểm tổng các bill bằng bill gốc.
- **Đặt chỗ.** Có các workflow `Reservations::Create / Update / Cancel / Seat`, service `Availability` và job `MarkNoShowJob`; job chỉ đổi trạng thái. Đặt trùng giờ báo `reservation_overlap`; thiếu chỗ báo `reservation_capacity`. Ô bàn có trạng thái `reserved` và `next_reservation`. `Seat` mở đơn `dine_in` ở bàn đã đặt; `Workspace#to_pos` có `reservation`. Module `fnb.reservations` đã đăng ký và bật trong hồ sơ `nha_hang`.
- **Cọc** theo `docs/adr/0002-pos-tien-coc-giu-cho.md`:
  - `TakeDeposit` ghi một `ReceivedFunds` không có đơn, vào ca đang mở của người nhận.
  - `ApplyDeposit` trừ vào đơn bằng `FundsAllocation`.
  - `RefundDeposit` hoàn bằng `LiabilityPayout`.
  - `ForfeitDeposit` tạo đơn phí giữ chỗ có thuế, allocate tiền cọc vào đó rồi hoàn tất đơn.
  - Hoàn và mất cọc tiêu thụ approval `reservation.refund_deposit` / `reservation.forfeit_deposit`, gắn với đặt chỗ.
  - Capability mới: `pos.reservation.manage` và `pos.expo.operate`.
- **API.** Thêm `reservations` (list, show, create, update, `availability`, `:id/seat`, `:id/cancel`, `:id/deposits`, `deposits/:deposit_id/refund`, `deposits/:deposit_id/forfeit`), `buffet_tiers`, `workspaces/:id/courses/:course/fire`, `workspaces/:id/deposits/apply` và lệnh fire của máy. `pos-staff.yaml` đã cập nhật, gồm mọi trường mới của dòng, bảng bếp, ô bàn, cài đặt bàn và `TableSplitInput` (`by`, `shared`, `new_workspaces`). Client Dart đã sinh lại, không có `InlineObject`.
- **Web `apps/pos`.**
  - Trang `/reservations` (Đặt bàn), có link trong menu tài khoản và thanh trang; chỉ hiện khi bật `fnb.reservations`. Trang có:
    - timeline trong ngày theo bàn;
    - form đặt với danh sách bàn trống theo giờ và số khách;
    - nhận cọc bằng tiền mặt hoặc chuyển khoản;
    - các nút Khách đã đến (mở đơn ở màn bán), Không đến, Hủy, Hoàn cọc, Mất cọc. Hai nút cuối hỏi mã duyệt khi bị `approval_required`.
  - Màn đơn bàn (khi bật bếp) có `CourseSeatPicker`: chọn course, ghế và "giữ" cho món kế tiếp, cùng nút Gọi món cho mỗi course đang giữ. Cũng có `BuffetTierPicker`: thêm vé theo hạng và số khách, chọn vé cho món buffet.
  - Đơn có khách đặt hiện khối cọc với nút "Trừ cọc". Hộp tách đơn có thêm lựa chọn "Theo ghế". Ô bàn hiện lượt đặt kế tiếp, và cảnh báo buffet vàng trong 10 phút cuối, đỏ khi quá giờ.
  - Chuỗi vi / en.
  - Logic chung ở `packages/pos-shared/src/reservations.ts` và `tables.ts` (`buffetTiming`, `next_reservation`).
- **Flutter `apps/pos-staff`.**
  - Expo: mục "Chờ gọi món" theo bàn và course, có nút fire. Mục "Đã xong, cần mang ra" hiện ghế của món. Có lọc theo khu khi có từ hai khu trở lên.
  - Waiter: thanh chọn course, ghế và "giữ, chờ gọi" khi gọi món; dòng đơn hiện ghế và course; nút Gọi cho course đang giữ.
  - Owner (hook): danh sách đặt bàn hôm nay kèm cọc, Hoàn cọc và Giữ cọc có hỏi xác nhận.
  - Chuỗi vi / en.
- **Dashboard.** Hai capability mới có trong nhóm quyền; e2e quản trị đếm 30 quyền.

Lệch so với kế hoạch:

- "Chờ fire" không lưu thành bản ghi riêng cho trạm expo. Bảng bếp tính nó từ các dòng `held` lúc đọc.
- Đánh dấu đã phục vụ dùng lại route serve sẵn có của item (`posKitchenItemServe` / `posDeviceKitchenItemServe`, cả đơn qua `order_serve`). Không thêm `kitchen_ticket_items/:id/served`. Spec kiểm serve idempotent và chỉ báo một lần.
- Cọc là `ReceivedFunds` trực tiếp, bằng tiền mặt hoặc `bank_manual` có mã giao dịch; chưa có VietQR. Nhận cọc cần quyền thu tiền và ca đang mở của chính người nhận (`shift_required`). Khách đến thì cọc không tự trừ: thu ngân bấm "Trừ cọc" (`deposits/apply`) trong luồng thanh toán.
- Giới hạn lượt buffet tính theo số khách của vé (`round_item_limit` × số vé).
- Tách theo ghế: món dùng chung về ghế thu ngân chọn, nếu không chọn thì về ghế đầu. Không chia đều.
- Sản phẩm phí giữ chỗ, thời lượng đặt mặc định, ngưỡng no-show và nhãn course cấu hình qua `table_settings`. Chưa có màn dashboard cho các mục này, cũng chưa có màn cho hạng buffet; hiện chỉ cấu hình được qua API.
- Exclusion constraint dùng `tsrange`, theo kiểu cột `datetime` của Rails, không dùng `tstzrange`.
- Seat cần thêm quyền phục vụ bàn.
- Hồ sơ `bar_pub_club` và `karaoke_bida` không có `fnb.reservations`. Phiên bản file hồ sơ giữ 2.
- Owner hook: người duyệt hoàn / giữ cọc trực tiếp, không qua `approval.requested`. Người không có quyền duyệt nhận `approval_required` và nhập mã duyệt trên web.
- Web: khối "Trừ cọc" là component riêng `reservation-deposit-note.tsx` đặt trên `PaymentPanel`; `payment-panel.tsx` không đổi. Thực đơn ở màn đơn chưa lọc theo hạng vé; server vẫn từ chối món ngoài hạng.
- Waiter chưa đếm số món buffet còn gọi được trong lượt: payload chưa có thông tin lượt hiện tại.
- E2E web đi tới bước thanh toán xong với cọc đã trừ, chưa kiểm in hóa đơn. Bước in dùng lại luồng hoàn tất sẵn có.

Lệnh và kết quả:

- `pnpm spree rspec` cho các file mới: `spec/workflows/spree/pos/kitchen/fire_course_spec.rb` (5/0), `kitchen/buffet_rounds_spec.rb` (3/0), `tables/split_by_seat_spec.rb` (3/0), `reservations/deposits_spec.rb` (4/0), `spec/requests/spree/pos/reservations_spec.rb` (6/0), `spec/jobs/spree/pos/reservations/mark_no_show_job_spec.rb` (2/0).
- Spec module và hồ sơ (onboarding, business_profiles request và service, branch_profiles, topology, module_policy, branch_modules): 72/0.
- Spec bàn, bếp và request liên quan: 181/0. Thư mục `workspaces` cùng `tables_spec`: 37/0.
- Sau khi đổi `pos-staff.yaml`: `devices_spec`, `kitchen_board_spec`, `kitchen_spec`, `resource_board_spec`, `tables_spec`, `print_documents_spec`, `split_by_seat_spec`, `reservations_spec`: 45/0. Lần cuối, sau khi thêm path cọc: `reservations_spec`, `tables_spec`, `kitchen_board_spec`: 13/0.
- `packages/pos-shared`: `pnpm test` 280 qua, `pnpm typecheck` sạch, `pnpm lint` sạch (1 info có từ trước).
- `apps/pos`: `pnpm lint` sạch, `pnpm typecheck` sạch, `pnpm test` 287 qua.
  - `playwright test e2e/reservations.spec.ts --project desktop` qua. Luồng: đặt bàn → nhận cọc 50 000 → khách đến → mở đơn → trừ cọc → trả nốt 150 000 tiền mặt → đơn hoàn tất.
  - Chạy cùng `tables`, `table-kitchen-send`, `user-menu`, `fnb-wave2`, `pages-polish`: 15/15.
- `apps/pos-dashboard`: `pnpm typecheck`, `pnpm lint` sạch, `pnpm test` 102 qua. Không chạy e2e dashboard: cổng 5176 đang dùng cho dashboard của developer.
- `apps/pos-staff`: `tool/gen_api.sh` sinh lại client; `flutter analyze` không có lỗi; `flutter test` 133 qua (có `test/modes/table_service_test.dart` mới: course giữ, fire từ waiter, expo fire và lọc khu, owner hoàn / giữ cọc).

Còn mở:

- Chưa đo "S1 / S2 cập nhật trong ≤ 2 giây" khi expo phục vụ món: không có emulator, chưa chạy integration test Flutter qua realtime.
- Thực đơn theo hạng vé ở web và waiter, và bộ đếm món buffet còn lại trong lượt, cần server trả lượt hiện tại của vé.
- Chưa có màn dashboard cho hạng buffet, nhãn course, sản phẩm phí giữ chỗ, thời lượng đặt và ngưỡng no-show.
- Chưa có báo cáo "cọc đang giữ" theo chi nhánh (rủi ro đã ghi ở trên).
- ADR và toàn bộ thay đổi chưa commit; controller sẽ commit. Chưa chạy full rspec / e2e: để GitHub Actions chạy.
- Request spec chưa kiểm schema của câu trả lời hoàn / giữ cọc qua HTTP. Workflow spec đã kiểm các bước này, và schema `Reservation` đã có `fee_workspace_id`.

## Phần 9B: Bar, pub & club

### Overview

Phần này làm các tính năng riêng của bar, pub và club ([research §3.5](../reports/261109-1748-pos-fnb-giai-tri-research.md)):

- màn **`tab_list`**: tab mở theo khách hoặc bàn, máy nào cũng thêm món được;
- báo cáo theo **ngày kinh doanh qua 0h** (D8);
- **giá happy hour**, dùng lại giá theo khung giờ của phần 6A;
- module **`fnb.bottle_keep`**: sổ gửi rượu;
- module **`fnb.pour_tracking`**: định lượng ml trên chai đang mở;
- **minimum spend** cho bàn VIP;
- **vé vào cửa** quy đổi thành drink credit;
- **tip** để ngoài doanh thu chịu thuế GTGT, kèm báo cáo chia tip;
- **gói bottle service**.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Tab là một workspace có `service_mode = tab`. Tab mang thêm `tab_name` (tên hoặc mô tả khách) và có thể gắn `Resource` (bàn VIP). Thêm món từ bất kỳ máy nào dùng đường "thêm dòng không cần lease" của phần 8B. |
| Q2 | Ngày kinh doanh: mọi báo cáo của phần này nhóm theo `Workspace.business_date` (phase 1). Không tính lại ngày từ `created_at`. |
| Q3 | Happy hour **không tạo cơ chế giá mới**. Bảng giá theo khung giờ của phần 6A nhận thêm thuộc tính hiển thị `label` ("Happy hour"). Giá được chốt lúc thêm dòng, theo `database_now`. |
| Q4 | Gửi rượu là **sổ ghi, không đụng tiền** (đã chốt 09/11/2026: chỉ ghi sổ). Bán chai vẫn là dòng bán bình thường. Phần rượu còn lại thì mở phiếu gửi; lần sau rót từ chai gửi thì không phát sinh dòng tiền. |
| Q5 | `fnb.pour_tracking` dùng công thức của phần 6B: một shot là công thức "X ml từ variant chai". Chai đang mở là một `OpenBottle` của chi nhánh. Mỗi lần complete đơn, số ml của chai đang mở giảm theo các lần rót. Khi hết chai, hệ thống trừ tồn đúng một chai. |
| Q6 | Minimum spend: lúc tạm tính và lúc thanh toán, nếu `item_total` của tab thấp hơn mức tối thiểu của tài nguyên VIP thì server thêm phần chênh dưới dạng một **`Spree::Fee` có thuế**, nhãn "Phụ thu mức tối thiểu" (cùng kiểu với phí giao hàng ở `deliveries/assign.rb`). Phí này được tính lại mỗi khi đơn thay đổi và không bao giờ âm. |
| Q7 | Vé vào cửa là dòng `cover`, có giá và thuế riêng. Vé kèm **drink credit**, ghi trên tab dưới dạng hạn mức giảm giá cho nhóm đồ uống, áp qua `LineDiscountIntent` với nguồn `cover_credit`. Phần drink credit không dùng hết thì không hoàn. |
| Q8 | Tip không thuộc order nên không vào hóa đơn GTGT. Tiền tip vẫn đi qua `ReceivedFunds`; phần tip là số dư không allocate vào order, gắn `TipRecord`. Chi tip cho nhân viên dùng `LiabilityPayout`, người nhận là nhân viên. Việc tip không phải doanh thu mới có **một nguồn** (research §7), nên phần này có cờ chi nhánh "Ghi tip vào doanh thu" để đổi khi có ý kiến kế toán. |
| Q9 | Gói bottle service là combo của phần 6A: một chai cộng mixer và đá, có giá gói. Phần rượu còn lại khi đóng tab được gợi ý mở phiếu gửi rượu. |

### Dữ liệu

- `spree_pos_workspaces` thêm `tab_name` (string, null) và chỉ mục tìm kiếm `lower(tab_name)` theo chi nhánh cho các workspace đang mở.
- `spree_pos_resources` thêm `minimum_spend` (decimal, null) và `minimum_spend_currency`.
- `spree_pos_bottle_keeps`:
  - cột chính: `branch_id`, `customer_profile_id`, `variant_id`, `code` (in trên nhãn chai), `level_percent`, `photo` (Active Storage), `kept_on`, `expires_on`, `source_order_id`, `note`;
  - `status`: `kept | finished | expired | returned`.
- `spree_pos_bottle_keep_events`: `bottle_keep_id`, `kind` (`open | pour | adjust | expire | return`), `level_before`, `level_after`, `ml`, `workspace_id` (null), `actor_id`, `created_at`. Bảng chỉ thêm dòng, không sửa.
- `spree_pos_open_bottles`:
  - cột: `branch_id`, `variant_id`, `capacity_ml`, `remaining_ml`, `opened_at`, `opened_by_id`;
  - `status`: `open | finished`.
- `spree_pos_pour_events`: `open_bottle_id`, `sale_line_id`, `ml`, `business_date`. Unique theo (`sale_line_id`, `open_bottle_id`) để trừ một lần duy nhất.
- `spree_pos_tip_records`: `branch_id`, `workspace_id`, `received_funds_id`, `amount`, `currency`, `business_date`, `shift_id`, `status` (`held | paid_out`), `liability_payout_id`.
- `spree_pos_tip_split_rules` theo chi nhánh: `mode` (`equal | by_hours | manual`), danh sách vai trò được chia.
- Approval action mới: `bottle_keep.adjust` (sửa mức rượu), `tab.waive_minimum_spend`.
- Module: đăng ký `fnb.bottle_keep` và `fnb.pour_tracking` là `available`. Thêm hai module này vào hồ sơ `bar_pub_club`, và thêm `fnb.bottle_keep` vào `karaoke_bida`, đều ở dạng gợi ý.

### Server

1. Tab:
   - `Workspaces::Create` nhận `service_mode: 'tab'` và `tab_name`.
   - `GET workspaces?service_mode=tab&q=` tìm tab đang mở theo tên, bàn hoặc số tab.
   - Phát `workspace.updated` cho mọi máy của chi nhánh.
2. `Spree::Pos::Fnb::MinimumSpend.apply!(workspace)` chạy sau mỗi thay đổi dòng và trước khi chụp tạm tính hoặc chuẩn bị tender. Bỏ phụ thu cần approval `tab.waive_minimum_spend`.
3. Drink credit: khi thêm dòng `cover` có `drink_credit`, tạo một intent giảm giá cấp dòng. Intent áp tự động cho đồ uống thuộc nhóm được phép, theo thứ tự thêm món, tới khi hết hạn mức.
4. Gửi rượu: `BottleKeeps::Open` (từ dòng bán hoặc nhập tay), `Pour`, `Adjust` (cần approval), `Return`, `Expire`. Job hằng ngày đánh dấu phiếu quá hạn.
5. Rót: trong `Workspaces::Complete`, sau phần trừ kho theo công thức của phần 6B, các dòng có công thức "ml từ chai" tạo `PourEvent` trên chai đang mở của variant đó. Hết chai thì đóng chai và trừ tồn một chai; nếu đã có chai mới mở thì chuyển phần ml còn thiếu sang chai mới. Bước này idempotent theo `sale_line_id`.
6. Tip:
   - Bước tender cho nhập "tip" tách khỏi số phải thu.
   - `Tenders` ghi `TipRecord` cho phần tip của `ReceivedFunds`.
   - `Tips::Payout` tạo `LiabilityPayout` theo quy tắc chia.
   - Báo cáo chia tip đọc theo ca và theo ngày kinh doanh.
7. Báo cáo: doanh thu theo `business_date` và theo khung giờ (gồm happy hour); số tab mở và đóng; số chai mở và số ml đã rót so với số bán; phiếu gửi sắp hết hạn.
8. API dưới `/api/v3/admin/pos/`: `bottle_keeps` (CRUD, `pour`, `adjust`), `open_bottles`, `tips` (danh sách, `payout`), `reports/bar`. Cập nhật `server/openapi/pos-staff.yaml`.

### Client web (`apps/pos`)

- Surface **`tab_list`**:
  - ô tìm kiếm luôn được focus;
  - mỗi tab có tên khách, bàn, giờ mở và tổng tiền;
  - nút "Mở tab" chỉ cần nhập tên.

  Bàn VIP mở từ `floor_plan` của phần 8A.
- Màn gọi món của tab ưu tiên nhóm đồ uống và shot. Happy hour đang chạy thì có nhãn trên món.
- Tạm tính hiện dòng phụ thu mức tối thiểu và drink credit còn lại.
- Trang **Gửi rượu**: tìm theo SĐT hoặc mã chai; xem ảnh, mức còn và lịch sử rót; in nhãn chai qua hàng đợi in (`PrintJob`, loại `receipt` dùng mẫu nhãn).
- Thanh toán có ô tip. Trang **Chia tip** cho quản lý ca.

### Flutter (`apps/pos-staff`)

- Mode `waiter`:
  - danh sách tab có tìm kiếm;
  - mở tab mới, thêm món vào tab bất kỳ;
  - rót từ chai gửi bằng cách quét mã chai, cập nhật mức và chụp ảnh.
- Mode `kds` của trạm `bar` dùng như phần 7A, không có thay đổi riêng.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_tab_name_to_spree_pos_workspaces.rb`, `*_add_minimum_spend_to_spree_pos_resources.rb`, `*_create_spree_pos_bottle_keeps.rb`, `*_create_spree_pos_open_bottles.rb`, `*_create_spree_pos_tip_records.rb` |
| Tạo | `server/app/models/spree/pos/bottle_keep.rb`, `bottle_keep_event.rb`, `open_bottle.rb`, `pour_event.rb`, `tip_record.rb`, `tip_split_rule.rb` |
| Tạo | `server/app/services/spree/pos/fnb/minimum_spend.rb`, `server/app/workflows/spree/pos/bottle_keeps/*.rb`, `server/app/workflows/spree/pos/tips/payout.rb`, `server/app/services/spree/pos/fnb/pour_tracker.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/bottle_keeps_controller.rb`, `open_bottles_controller.rb`, `tips_controller.rb` |
| Sửa | `server/app/workflows/spree/pos/workspaces/create.rb`, `workspaces/complete.rb`, workflow tender (thêm tip), `server/app/models/spree/pos/approval.rb`, `server/config/initializers/pos_modules.rb`, `server/config/pos/business_profiles.yml`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos/src/components/tab-list.tsx`, `apps/pos/src/pages/bottle-keeps.tsx`, `apps/pos/src/pages/tips.tsx`, `apps/pos/src/hooks/use-bottle-keeps.ts` |
| Sửa | `apps/pos/src/components/payment-panel.tsx`, `apps/pos/src/router.tsx`, `apps/pos/src/locales/*` |
| Sửa | `apps/pos-staff/lib/modes/waiter/` |

### Các bước

1. Thêm `tab_name` và tìm kiếm tab; làm surface `tab_list`.
2. Gắn nhãn happy hour vào bảng giá theo khung giờ của phần 6A; viết spec chốt giá theo giờ server.
3. Làm minimum spend bằng `Spree::Fee`, kèm approval bỏ phụ thu.
4. Làm vé vào cửa `cover` và drink credit.
5. Làm sổ gửi rượu và nhãn chai.
6. Làm chai đang mở và rót, gắn vào complete.
7. Làm tip: nhập khi thanh toán, `TipRecord`, chia và chi tip; thêm cờ chi nhánh "Ghi tip vào doanh thu".
8. Làm báo cáo theo ngày kinh doanh.
9. Làm API, OpenAPI, sinh lại client Dart, cập nhật mode waiter.
10. Bật hai module mới trong registry và hồ sơ.

### Kiểm thử

- Spec ngày kinh doanh: đơn mở 23:30 và đóng 01:30 với giờ cắt 04:00 thuộc cùng một `business_date`; báo cáo đếm đúng một lần.
- Spec minimum spend:
  - tab dưới mức thì có phụ thu bằng phần chênh, chịu thuế;
  - thêm món làm phụ thu giảm, vượt mức thì phụ thu mất;
  - bỏ phụ thu cần approval.
- Spec drink credit: credit chỉ áp cho nhóm đồ uống được phép và không vượt hạn mức.
- Spec rót: complete hai lần không trừ hai lần; hết chai thì trừ tồn đúng một chai.
- Spec gửi rượu: `adjust` thiếu approval thì bị từ chối; lịch sử chỉ thêm, không sửa.
- Spec tip: tip không làm đổi `order.total` và không có trên hóa đơn điện tử; chi tip tạo `LiabilityPayout`; sổ quỹ ca khớp.
- E2E web: mở tab → hai máy cùng thêm món → tạm tính có phụ thu tối thiểu → thanh toán có tip → báo cáo.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Cách hạch toán tip chưa chắc về pháp lý | Có cờ chi nhánh. Nghiệp vụ mặc định ghi rõ nguồn và để kế toán xác nhận trước khi phát hành. |
| Sai lệch ml giữa đo thật và công thức | Báo cáo "ml bán so với ml chai đã mở" để quản lý kiểm. Sửa mức chai cần approval. |
| Minimum spend tính lại nhiều lần gây đổi revision liên tục | Chỉ ghi phí khi giá trị đổi, so trước khi update. |
| Ảnh chai gửi làm phình dung lượng server LAN | Nén ảnh ở client, giới hạn kích thước, xóa ảnh khi phiếu đã kết thúc quá N ngày. |

### Tiêu chí xong

- [x] `tab_list` tìm được tab, mở tab nhanh; máy nào cũng thêm món vào tab được.
- [x] Báo cáo bar theo ngày kinh doanh qua 0h là đúng.
- [x] Happy hour áp theo giờ server và có nhãn.
- [x] Gửi rượu: mở phiếu, rót, sửa có duyệt, hết hạn, in nhãn.
- [x] Rót theo ml trừ chai đang mở và trừ tồn đúng.
- [x] Minimum spend và drink credit đúng; bỏ phụ thu có approval.
- [x] Tip để ngoài doanh thu, có báo cáo chia và chi tip qua payout.
- [ ] OpenAPI, client Dart, spec và e2e đều xanh.

### Kết quả

Đã làm:

- **Dữ liệu.** Sáu migration: `20261112040000_add_tab_name_to_spree_pos_workspaces`, `…040100_add_minimum_spend_to_spree_pos_resources`, `…040200_create_spree_pos_bottle_keeps` (kèm bảng sự kiện), `…040300_create_spree_pos_open_bottles` (kèm `pour_events`), `…040400_create_spree_pos_tip_records` (kèm `tip_split_rules`), `…040500_add_happy_hour_and_drink_credit_to_spree_pos_menu`. Model mới: `BottleKeep`, `BottleKeepEvent` (chỉ đọc sau khi ghi), `OpenBottle`, `PourEvent`, `TipRecord`, `TipSplitRule`. Approval mới: `bottle_keep.adjust`, `tab.waive_minimum_spend`. Module `fnb.bottle_keep` và `fnb.pour_tracking` đã đăng ký; hồ sơ `bar_pub_club` gợi ý cả hai, `karaoke_bida` gợi ý `fnb.bottle_keep`.
- **Tab.** `Tabs::Open` mở tab chỉ với tên, trên ca của người mở (waiter thì trên ca của quầy bàn); tên trùng với tab đang mở báo `tab_name_taken`. `GET workspaces?service_mode=tab&q=` tìm theo tên, bàn hoặc số gọi. Máy nào cũng thêm món vào tab qua đường thêm dòng không cần lease. Báo cáo đếm tab mở 23:30, trả 01:30 đúng một lần, vào ngày mở.
- **Happy hour.** Khung giờ thực đơn có `price_label`; dòng bán ghi nhãn theo giờ server lúc thêm dòng. Web hiện nhãn trên ô món và trên dòng đơn; dashboard có ô nhãn ở khung giờ.
- **Minimum spend.** `Fnb::MinimumSpend` thêm `Spree::Fee` có thuế bằng phần chênh, tính lại sau mỗi thay đổi dòng và chỉ ghi khi giá trị đổi. Bỏ phụ thu (`workspaces/:id/minimum_spend`) cần approval gắn với phí; đặt lại thì không cần. Dashboard nhập mức tối thiểu ở tài nguyên và ngày giữ chai ở cài đặt bar.
- **Drink credit.** Món vé `cover` có `drink_credit` và nhóm đồ uống được áp. `Fnb::DrinkCredit` áp giảm giá cấp dòng nguồn `cover_credit` theo thứ tự thêm món, không vượt hạn mức, không áp cho đồ ăn; bỏ một ly đã trả bằng credit thì credit chuyển sang ly kế. Tạm tính và bản in có dòng phụ thu và drink credit còn lại.
- **Gửi rượu.** Có `BottleKeeps::Open` (kèm ảnh), `Pour` (không bao giờ làm mức tăng, về 0 thì `finished`), `Adjust` (cần approval gắn revision của phiếu), `Close` (trả khách), `Label` (tài liệu in loại `receipt`, có QR mã chai) và `ExpireJob` chạy hằng ngày (`config/recurring.yml`). Lịch sử chỉ thêm dòng. Web có trang **Gửi rượu**: tìm theo SĐT hoặc mã, xem ảnh, mức và lịch sử, rót, sửa mức, in nhãn, trả chai.
- **Rót.** Công thức nhận đơn vị ml từ variant chai. `Fnb::PourTracker` chạy trong `Workspaces::Complete`: ghi `PourEvent` trên chai đang mở, hết chai thì đóng chai, trừ tồn một chai và chuyển phần thiếu sang chai kế; idempotent theo dòng bán. `open_bottles` cho mở và đóng chai bằng tay.
- **Tip.** Tender tiền mặt và `bank_manual` nhận `tip_amount`. Phần tip là số dư không allocate của `ReceivedFunds`, có `TipRecord`, không đổi `order.total` và không lên hóa đơn điện tử. `Tips::Payout` chia đều, theo giờ hoặc nhập tay, tạo `LiabilityPayout` cho từng nhân viên. Cờ chi nhánh `tips_as_revenue`. Web có ô tip trong hộp thanh toán (tiền khách đưa phải đủ cả tip) và trang **Chia tip**.
- **Báo cáo.** `reports/bar`: doanh thu theo ngày kinh doanh và theo giờ, tab mở và đóng, chai đã mở, ml rót so với ml bán, phiếu gửi sắp hết hạn, tip.
- **API.** `bottle_keeps` (list, show, create, `pour`, `adjust`, `label`, `return`), `open_bottles`, `tips` (list kèm nhân viên được chia, `payout`), `reports/bar`, `workspaces/:id/minimum_spend`. `pos-staff.yaml` có tab, phiếu gửi, rót và `Context.modules`; client Dart đã sinh lại.
- **Web `apps/pos`.** Surface `tab_list` (ô tìm luôn focus, tên, bàn, giờ mở, tổng, "Mở tab" chỉ cần tên); màn gọi món của tab xếp đồ uống lên đầu; tên tab hiện trên thẻ đơn. Sửa thêm một lỗi: danh sách tab nằm dưới khóa cache của workspace nên mọi lệnh ghi sau khi mở danh sách đều hỏng (`writeWorkspaceToCache` nay bỏ qua dữ liệu khác dạng).
- **Flutter `apps/pos-staff`.** Waiter có danh sách tab có tìm kiếm, mở tab mới, gọi món vào tab, và màn rót từ chai gửi (quét hoặc gõ mã, kéo mức, nhập ml, ảnh từ khung quét). Các nút bar chỉ hiện khi module bật.

Lệch so với kế hoạch:

- Tab mở qua workflow riêng `Tabs::Open`, không sửa `Workspaces::Create`.
- Tip chỉ nhận ở tiền mặt và `bank_manual`; cách trả khác báo `tip_invalid`.
- Chi tip tạo `LiabilityPayout` ở trạng thái giữ chỗ; tiền ra khi xác nhận bốn mắt như các khoản chi khác.
- `tips_as_revenue` hiện chỉ là cờ đọc trong báo cáo; chưa đổi cách hạch toán.
- Job hết hạn không ghi dòng audit riêng; sự kiện `expire` ghi người mở phiếu làm actor.
- Nhãn chai là tài liệu in loại `receipt`, không có mẫu nhãn riêng.
- Hồ sơ bar dùng surface `tab_list` và gợi ý `fnb.bottle_keep`; `fnb.pour_tracking` phải bật tay.
- Minimum spend không tự tính lại khi sửa mức ở tài nguyên; tính lại ở lần đổi dòng kế tiếp.
- `open_bottles` đóng chai chưa có trong `pos-staff.yaml` (chỉ web dùng).
- Trang Chia tip nằm ở `apps/pos` theo bảng file của phần này, dù trang quản trị khác ở dashboard.
- Không thêm capability mới; dashboard vẫn đếm 30 quyền.
- E2E web dùng thế giới giả lập: mở tab, phụ thu tối thiểu và drink credit ở tạm tính, thanh toán tiền mặt có tip. Bước "hai máy cùng thêm món" và báo cáo được kiểm ở server spec.

Lệnh và kết quả:

- `pnpm spree rspec` các file mới: `spec/workflows/spree/pos/tabs/open_spec.rb` 5/0, `spec/workflows/spree/pos/fnb/bar_billing_spec.rb` 10/0, `spec/services/spree/pos/fnb/pour_tracker_spec.rb` 5/0, `spec/requests/spree/pos/bottle_keeps_spec.rb` 7/0.
- Chạy chung các spec liên quan (thư mục `fnb`, `tabs`, `workspaces`, cùng `tables`, `menu`, `recipes`, `reports`, `table_settings`, `kitchen`, `table_kitchen`, `print_documents`, `menu_item` và các spec module, hồ sơ): 193/0.
- `packages/pos-shared`: `pnpm test` 280 qua, typecheck và lint sạch.
- `apps/pos`: `pnpm lint`, `pnpm typecheck` sạch, `pnpm test` 289 qua. `playwright test --project desktop`: `bar-tabs` (mới) 2/2; `tables`, `fnb-wave1`, `fnb-wave2`, `table-kitchen-send`, `reservations` cùng `bar-tabs` 17/17; `split-tender`, `full-retail`, `feature-flags`, `fnb-menu` 27 qua, 1 bỏ qua (cần API thật).
- `apps/pos-dashboard`: typecheck, lint sạch, `pnpm test` 103 qua. Không chạy e2e dashboard: cổng 5176 đang dùng cho dashboard của developer. Không đổi route nên không cần build.
- `apps/pos-staff`: `tool/gen_api.sh` sinh lại client; `flutter analyze` sạch; `flutter test` 137 qua (có `test/modes/waiter/bar_screens_test.dart` mới).

Còn mở:

- Gợi ý mở phiếu gửi rượu khi đóng tab có gói bottle service (Q9) chưa làm; gói bottle service vẫn dùng combo sẵn có.
- E2E dashboard (cài đặt bar, mức tối thiểu, nhãn happy hour, drink credit) chưa chạy vì cổng 5176. Đây là lý do tiêu chí "spec và e2e đều xanh" chưa tick.
- Chưa thử với máy in nhãn và điện thoại thật (quét mã chai, ảnh); chưa pilot ở quán.
- Kế toán chưa xác nhận cách ghi tip; cờ `tips_as_revenue` chưa đổi hạch toán.
- Ảnh chai giới hạn 2 MB và chỉ nhận kiểu ảnh; chưa nén ở client và chưa dọn ảnh của phiếu đã kết thúc.
- Toàn bộ thay đổi chưa commit; controller sẽ commit. Chưa chạy full rspec / e2e: để GitHub Actions chạy.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
