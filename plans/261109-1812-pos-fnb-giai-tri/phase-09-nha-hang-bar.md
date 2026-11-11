---
phase: 9
title: "Nhà hàng nâng cao, bar"
status: pending
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
- [ ] Course đang giữ không xuống trạm prep cho tới khi fire.
- [ ] Tách bill theo ghế ra đúng tổng.
- [ ] Buffet có hạng vé, thực đơn theo hạng, giới hạn lượt và cảnh báo giờ.
- [ ] Đặt bàn có kiểm tra trống. Nhận, trừ, hoàn và mất cọc đều đi qua lõi tiền; hoàn và mất cọc có approval.
- [ ] ADR cọc đã commit và ghi rõ `deposits` của bán lẻ dùng chung mô hình.
- [ ] OpenAPI và client Dart đã cập nhật. Spec, e2e và Flutter test đều xanh.

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

- [ ] `tab_list` tìm được tab, mở tab nhanh; máy nào cũng thêm món vào tab được.
- [ ] Báo cáo bar theo ngày kinh doanh qua 0h là đúng.
- [ ] Happy hour áp theo giờ server và có nhãn.
- [ ] Gửi rượu: mở phiếu, rót, sửa có duyệt, hết hạn, in nhãn.
- [ ] Rót theo ml trừ chai đang mở và trừ tồn đúng.
- [ ] Minimum spend và drink credit đúng; bỏ phụ thu có approval.
- [ ] Tip để ngoài doanh thu, có báo cáo chia và chi tip qua payout.
- [ ] OpenAPI, client Dart, spec và e2e đều xanh.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
