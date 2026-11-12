---
phase: 11
title: "Tính giờ, karaoke, bida"
status: pending
effort: "17 ngày"
dependsOn: [5, 8, 10]
---

# Phase 11: Tính giờ, karaoke, bida

## Overview

Cả ba phần thuộc module `timed_billing`: tính giờ cơ bản, tính năng nâng cao, và relay đèn bida.

| Phần | Nội dung | Effort |
|---|---|---|
| 11A | Tính giờ karaoke / bida | 9 ngày |
| 11B | Karaoke / bida nâng cao | 4 ngày |
| 11C | Relay đèn bida | 4 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 11A: Tính giờ karaoke / bida

### Overview

Phần này làm module `timed_billing` và màn bắt đầu `resource_board`, rồi mở hồ sơ `karaoke_bida`.

Đơn vị đang mở là phòng / bàn chơi (`Resource` của phần 8A) có đồng hồ. Bill gồm giờ chơi và đồ ăn uống gọi thêm. Giờ chơi là một **phiên gồm nhiều đoạn** (theo mẫu Vyrox ở research §3.4). Giá theo khung giờ × loại ngày × loại phòng, có block làm tròn và ngưỡng ân hạn. Đoạn nào vắt qua hai khung giá thì được chia ra; chuyển phòng giữ giá của đoạn cũ; sửa giờ phải có duyệt.

Tạm dừng / tiếp tục, đếm ngược gói giờ trả trước, thẻ nạp giờ, cảnh báo 0h–8h và dòng tiếp viên để ở phần 11B. Mô hình dữ liệu của phần này đã chừa chỗ cho các tính năng đó.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Mọi mốc thời gian lấy từ `Workspace.database_now` (plan.md bất biến 3). Client chỉ hiển thị đồng hồ chạy từ `started_at` của server cộng độ lệch đo được khi kết nối. Lệnh "Bắt đầu" không nhận giờ từ client. |
| Q2 | Một phiên (`TimedSession`) gắn với **một SaleLine kind `timed`** của workspace. Đơn vị cơ sở là **phút**, đơn vị bán là **giờ**. Cách làm giống `retail.measured`: `line_item.quantity` = số phút tính tiền, `line_price` = giá một phút, `sale_quantity` = số giờ (4 chữ số thập phân). Vì vậy hóa đơn điện tử xuất được theo giờ (research §5.1). Check constraint `dimension` của `UnitDefinition` thêm `time`, kèm đơn vị `phut` (cơ sở) và `gio` (= 60 phút). |
| Q3 | Khi phiên đang chạy, tiền giờ trên màn hình là **báo giá tạm** (`Timed::Quote` với `now`) và không ghi vào line item. Line item chỉ được ghi khi **dừng phiên**. Chuẩn bị tender (`Tenders` prepare) từ chối nếu workspace còn phiên đang chạy, với `reason: 'timed_session_running'`. Nút "Thanh toán" trên ô phòng làm theo thứ tự: dừng phiên, rồi mở thanh toán. Tạm tính khi đang chạy in nhãn "Tạm tính đến HH:MM". |
| Q4 | Mỗi đoạn (`TimedSegment`) lưu **snapshot giá**: `rate_plan_id`, `price_per_hour` và `rule_id` tại lúc tính. `Timed::Quote` chia đoạn tại mọi ranh giới khung giờ và ranh giới ngày (theo `Branch.timezone`) rồi cộng tiền. Đổi bảng giá sau đó không làm đổi phiên đã dừng. Phiên đang chạy dùng bảng giá hiện hành cho phần chưa dừng. |
| Q5 | Làm tròn áp trên **tổng phút chơi của phiên**, không áp trên từng đoạn. Phần dư ≤ `grace_minutes` thì bỏ; dư hơn thì làm tròn lên một `block_minutes`. Có `minimum_minutes`. Tiền của phần làm tròn tính theo giá của **đoạn cuối**. Ví dụ block 15, ân hạn 5: 62 phút → 60, 66 phút → 75. |
| Q6 | Loại ngày là `weekday`, `weekend` hoặc `holiday`. `SpecialDay` đánh dấu ngày lễ của chi nhánh. Nếu bảng giá không có rule `holiday` thì dùng rule `weekend` cộng `holiday_surcharge_percent` của `SpecialDay` (phụ thu lễ Tết). Cuối tuần là cấu hình theo chi nhánh, mặc định Thứ 7 và Chủ nhật. |
| Q7 | Chuyển phòng (`Timed::MoveResource`): đóng đoạn hiện tại tại `now` và mở đoạn mới trên phòng mới, dùng bảng giá theo `resource_type_code` của phòng mới. Đoạn cũ **giữ giá cũ**. Workspace đổi `resource_id` qua `Tables::Move` của phần 8A, trong cùng transaction. |
| Q8 | Gộp phòng dùng `Tables::Merge`: mỗi phiên vẫn chạy riêng, nên bill có nhiều dòng giờ. Tách dùng `Tables::Split`: chuyển phiên cùng SaleLine `timed` của nó sang workspace mới. |
| Q9 | Sửa giờ (`Timed::EditSegment`) đổi `started_at` / `ended_at` của một đoạn đã đóng hoặc `started_at` của đoạn đang chạy. Lệnh cần lý do và `Approval` action `timed.edit_segment`, trừ khi người làm có capability `pos.timed.edit`. Audit ghi giá trị trước / sau. Không cho sửa vượt `now` hoặc làm các đoạn chồng lên nhau. |
| Q10 | Thuế: mặt hàng dịch vụ giờ là một `Spree::Variant` gắn với `RatePlan`, có `TaxCategory` riêng. Giờ hát karaoke dùng tax category 10% (hàng chịu TTĐB); giờ bida dùng mức chung (8% đến 31/12/2026). Đây là cấu hình của phase 1, không viết cứng. |

### Dữ liệu

Migration `add_time_dimension_to_pos_unit_definitions`: mở check constraint thêm `time`, seed `phut` và `gio`.

Migration `create_spree_pos_rate_plans_and_rules`:
- `spree_pos_rate_plans`: `store_id`, `branch_id`, `name`, `resource_type_code`, `variant_id` (dịch vụ giờ, quyết định thuế), `block_minutes` (1–60, mặc định 15), `grace_minutes` (0–block, mặc định 5), `minimum_minutes` (mặc định 0), `status` (`active|archived`), `version`. Mỗi `(branch_id, resource_type_code)` chỉ có một plan active (partial unique).
- `spree_pos_rate_rules`: `rate_plan_id`, `day_type` (`weekday|weekend|holiday`), `start_minute`, `end_minute` (0–1440; `end < start` nghĩa là qua 0h), `price_per_hour` (decimal), `position`. Validation: các rule cùng `day_type` phủ kín 24 giờ, không chồng nhau.
- `spree_pos_special_days`: `branch_id`, `date`, `name`, `holiday_surcharge_percent` (nullable). Unique `(branch_id, date)`.
- `spree_pos_branches.weekend_days` (jsonb, mặc định `[6,0]`).

Migration `create_spree_pos_timed_sessions_and_segments`:
- `spree_pos_timed_sessions`: `workspace_id`, `sale_line_id` (unique), `resource_id`, `status` (`running|paused|stopped`), `started_at`, `stopped_at`, `planned_end_at` (nullable: giờ dự kiến kết thúc nhập khi bắt đầu; phần 11B dùng cho gói trả trước), `billed_minutes`, `amount`, `quote_version`. Index `(resource_id, status)`. Mỗi `resource_id` có tối đa một phiên `running|paused` (partial unique), nên một phòng không chạy hai đồng hồ.
- `spree_pos_timed_segments`: `timed_session_id`, `resource_id`, `kind` (`play|pause`), `started_at`, `ended_at` (nullable khi đang chạy), `rate_plan_id`, `rate_plan_version`, `edited` (boolean). Check `ended_at > started_at`.
- `spree_pos_timed_quote_lines` (ghi khi dừng, để in và xuất hóa đơn): `timed_session_id`, `segment_id`, `from`, `to`, `day_type`, `price_per_hour`, `minutes`, `amount`.

### Server

- Model `RatePlan`, `RateRule`, `SpecialDay`, `TimedSession`, `TimedSegment`, `TimedQuoteLine`.
- `Spree::Pos::Timed::Quote.call(session, now:)`: hàm thuần, không ghi. Nó chia đoạn theo rule và ngày, áp Q5 và Q6, rồi trả về các dòng báo giá cùng tổng. Đây là phần có nhiều spec nhất: qua 0h, qua ranh giới khung giá, sang ngày lễ, chuyển phòng giữa chừng, block 1 phút, `minimum_minutes`.
- Workflow `app/workflows/spree/pos/timed/`:
  - `start.rb`: tạo SaleLine `timed` (qua `LineBuilder` của phần 8B) và phiên, rồi mở đoạn `play`. Nếu phòng chưa có workspace thì mở bàn bằng `Tables::Open` với `service_mode: 'timed'`.
  - `stop.rb`: đóng đoạn, chạy `Quote`, ghi `TimedQuoteLine`, rồi cập nhật line item (số phút, giá một phút) và `sale_quantity` (giờ). Lệnh tăng `revision` và idempotent.
  - `move_resource.rb`, `edit_segment.rb` (Q7, Q9).
- Lệnh tính giờ chạy không cần lease, giống `append_items`, và kiểm tra `can_edit_workspace?` cùng capability mới `pos.timed.operate`. Lệnh vẫn đi qua `ensure_snapshot_editable!`.
- Guard tender: thêm kiểm tra Q3 vào `Tenders::Guard`. Đây là guard theo dữ liệu, chạy cả khi module tắt (plan bán lẻ D5).
- `ResourceState` (phần 8A) thêm `timed: { status, started_at, planned_end_at, quote_amount }` và trạng thái `playing` / `ending_soon` (còn ≤ 10 phút tới `planned_end_at`). `reserved` lấy từ phần 9A khi có.
- `Workspace#to_pos`: dòng `timed` có `session` gồm các đoạn và báo giá tạm.
- Receipt / prebill: `ReceiptBuilder` in giờ vào, giờ ra, số giờ và từng khung giá. Thêm biến tương ứng vào `config/pos/receipt_template_variables.json`.
- Approval action `timed.edit_segment`. Capability `pos.timed.operate`, `pos.timed.edit`, `pos.rate_plan.manage`.
- Module `timed_billing` chuyển sang `register`; hồ sơ `karaoke_bida` có `display.surface: resource_board`, thêm `resources`, `fnb.kitchen` vào `optional_modules` (phần 8D Q1) và tăng `version` của YAML.
- Realtime: start / stop / move / edit phát `resource.updated` và `workspace.updated`.
- Endpoint: `rate_plans` (CRUD + rules), `special_days`, `resources/:id/timed_sessions` (start), `timed_sessions/:id/stop|move|segments/:segment_id`, `timed_sessions/:id/quote`. Cập nhật OpenAPI.

### Client web (`apps/pos`)

- Surface `resource_board`: lưới ô phòng / bàn chơi. Mỗi ô có tên, loại, **đồng hồ chạy**, tiền giờ tạm, tiền đồ uống và trạng thái màu kèm nhãn.
- Lọc: Đang chơi / Sắp hết giờ / Trống / Đã đặt (ẩn khi chưa có phần 9A) / Đang dọn.
- Hành động ngay trên ô: **Bắt đầu**, **Gọi món**, **Chuyển phòng**, **Thanh toán**. Nút **Tạm dừng** thêm ở phần 11B.
- Màn đơn của phòng: dòng giờ mở ra danh sách đoạn. Mỗi đoạn có nút "Sửa giờ" (xin duyệt).
- Cài đặt `/settings/branches/$branchId/rate-plans`: bảng giá theo loại phòng, lưới khung giờ × loại ngày, block / ân hạn / tối thiểu, ngày lễ. Có ô xem thử: nhập giờ vào / ra và xem tiền.
- Đồng hồ trên màn chạy bằng `requestAnimationFrame` / interval 1 giây từ dữ liệu server, không gọi API mỗi giây. Báo giá tạm refetch mỗi 60 giây hoặc khi có sự kiện.

### App Flutter (`apps/pos-staff`)

- Chế độ `waiter` có thêm tab **Phòng** khi chi nhánh bật `timed_billing`. Tab này cùng dữ liệu `resource_board`, ô có đồng hồ.
- Phục vụ phòng: gọi món vào phòng (dùng lại luồng gọi món của phần 8C), Bắt đầu / Dừng phiên nếu có `pos.timed.operate`, chuyển phòng, yêu cầu thanh toán. Không thu tiền.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_time_dimension_to_pos_unit_definitions.rb`, `*_create_spree_pos_rate_plans_and_rules.rb`, `*_create_spree_pos_timed_sessions_and_segments.rb` |
| Tạo | `server/app/models/spree/pos/{rate_plan,rate_rule,special_day,timed_session,timed_segment,timed_quote_line}.rb`, `server/app/services/spree/pos/timed/quote.rb`, `server/app/workflows/spree/pos/timed/{start,stop,move_resource,edit_segment}.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/{rate_plans,special_days,timed_sessions}_controller.rb` |
| Sửa | `server/app/models/spree/pos/{unit_definition,branch,capabilities,approval,workspace}.rb`, `server/app/services/spree/pos/{resource_state,receipt_builder}.rb`, `server/app/workflows/spree/pos/tenders/guard.rb`, `server/config/pos/{business_profiles.yml,receipt_template_variables.json}`, `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos/src/components/{resource-board,resource-tile,timed-line,segment-edit-dialog}.tsx`, `apps/pos/src/pages/settings/rate-plans.tsx`, `apps/pos/src/hooks/use-timed.ts`, `apps/pos/src/lib/timed-clock.ts` (+ `.test.ts`) |
| Tạo | `apps/pos-staff/lib/features/waiter/rooms/**`, `apps/pos-staff/test/features/waiter/rooms/**` |

### Các bước

1. Dimension `time`, đơn vị phút / giờ; spec `UnitNormalizer` với giờ.
2. Bảng giá, rule, ngày lễ, kèm validation phủ kín 24 giờ.
3. `Timed::Quote` và bộ spec bảng (table-driven): ít nhất 25 trường hợp, gồm qua 0h, khung giá, lễ, chuyển phòng, block / ân hạn / tối thiểu, Q5.
4. Start / stop / move / edit; guard tender; spec race "hai người bấm Bắt đầu cùng một phòng" (partial unique index chặn).
5. `ResourceState`, receipt và hóa đơn theo giờ.
6. Web: `resource_board`, đơn của phòng, trang bảng giá.
7. Flutter: tab Phòng.
8. Mở hồ sơ `karaoke_bida`, có kịch bản: bắt đầu phòng VIP 21:30, gọi bia, chuyển sang phòng thường 22:40, dừng 23:55, thu tiền. Bill có đúng hai đoạn giá, bia thuế 10%, giờ hát thuế 10%.

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/timed/quote_spec.rb spec/workflows/spree/pos/timed/ spec/requests/spree/pos/timed_sessions_spec.rb spec/requests/spree/pos/rate_plans_spec.rb spec/integration/spree/pos/timed_race_spec.rb spec/integration/spree/pos/karaoke_scenario_spec.rb`.
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`.
- Web: `pnpm --dir apps/pos typecheck`, `test` (gồm `timed-clock.test.ts`), `test:e2e` (`e2e/karaoke.spec.ts`).
- Flutter: `flutter analyze`, `flutter test`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Sai tiền khi qua 0h hoặc đổi khung giá | `Quote` là hàm thuần có spec bảng; tính theo `Branch.timezone`. |
| Gian lận bằng chỉnh giờ máy | Q1: giờ chỉ từ server; sửa giờ cần duyệt và có audit. |
| Spree `LineItem.quantity` là số nguyên | Dùng phút làm đơn vị cơ sở như `retail.measured` dùng gam; giá một phút có thể lẻ, đã được hỗ trợ (`line_price` theo đơn vị cơ sở). |
| Quên dừng phiên trước khi thu tiền | Guard tender chặn; nút Thanh toán tự dừng phiên trước. |
| Phiên chạy qua ca | Đơn chưa có tiền chuyển ca theo `ShiftRebind` (phần 8A); phiên giữ nguyên các đoạn. |

### Tiêu chí xong

- [x] Bảng giá theo khung giờ × loại ngày × loại phòng, có block, ân hạn, tối thiểu, ngày lễ và phụ thu.
- [x] Phiên nhiều đoạn chia đúng tại ranh giới giá và ngày; chuyển phòng giữ giá đoạn cũ.
- [x] Sửa giờ cần duyệt, có audit, không chồng đoạn.
- [x] Bill và hóa đơn ghi giờ chơi theo đơn vị giờ, đúng thuế suất theo cấu hình.
- [ ] `resource_board` trên web và tab Phòng trên Flutter có đồng hồ và các hành động trên ô. (Web xong; tab Phòng trên Flutter còn mở, xem Kết quả.)
- [x] Hồ sơ `karaoke_bida` chọn được; kịch bản karaoke xanh.

### Kết quả

**Đã làm**

- Dữ liệu: ba migration `20261112070000_add_time_dimension_to_pos_unit_definitions`, `20261112070100_create_spree_pos_rate_plans_and_rules` và `20261112070200_create_spree_pos_timed_sessions_and_segments`. Dimension `time` có đơn vị `phut` / `gio`. Thêm bảng giá, rule, ngày lễ, `branches.weekend_days`, phiên, đoạn và dòng báo giá. Partial unique index chặn hai đồng hồ trên một phòng. `schema.rb` từ 216 lên 223 check constraint.
- Model `RatePlan` (có version: plan đã dùng để tính tiền thì lưu thành bản mới, bản cũ chuyển `archived`), `RateRule` (phủ kín 24 giờ, cho qua 0h), `SpecialDay`, `TimedSession`, `TimedSegment`, `TimedQuoteLine`.
- `Timed::Quote` là hàm thuần, kèm `RateBook` đọc plan và ngày lễ với số query cố định. Quote chia đoạn tại ranh giới khung giá và ngày theo `Branch.timezone`. Làm tròn áp trên tổng phút của phiên; phần làm tròn tính theo giá đoạn cuối. Có tối thiểu, ngày lễ dùng rule `holiday` hoặc giá cuối tuần cộng phụ thu.
- Workflow `timed/{start,stop,move_resource,edit_segment,save_rate_plan,save_special_day,guard}`. Ghi chú:
  - Start mở đơn `service_mode: 'timed'` qua `Tables::Open` khi phòng chưa có đơn.
  - Dòng `timed` đếm phút, bán theo giờ.
  - Khi đang chạy, dòng giữ 1 phút giá 0 nên tổng đơn không chứa báo giá tạm. Stop ghi số phút tính tiền, giá một phút và `sale_quantity` theo giờ.
  - Move và Stop không cần lease.
  - EditSegment cần lý do và `Approval` `timed.edit_segment`, hoặc capability `pos.timed.edit`. Audit ghi giá trị trước / sau. Lệnh chặn sửa vượt `now` và chặn chồng đoạn. Nếu phiên đã dừng thì tính tiền lại.
- Guard:
  - `Tenders::Guard.tracked_guard!` từ chối khi còn phiên chạy (`timed_session_running`). Guard này chạy trên mọi đường thanh toán.
  - Dòng `timed` không sửa số lượng, không xoá, không đổi giá tay. Giảm giá dòng vẫn được, nhưng cần duyệt.
  - Huỷ đơn thì dừng các đồng hồ của đơn.
  - `Tables::Move` / `Split` mang phiên theo đơn.
- `ResourceState` thêm `timed` và trạng thái `playing` / `ending_soon`; query budget của `resource_board_spec` vẫn giữ. `Workspace#to_pos` gắn `timed_session` vào dòng giờ.
- In: `ReceiptBuilder` và `TemplateData` in phòng, giờ vào / ra và từng khung giá. Hóa đơn điện tử xuất dòng giờ theo đơn vị "giờ".
- Capability `pos.timed.operate`, `pos.timed.edit`, `pos.rate_plan.manage`.
- Module và hồ sơ:
  - Module `timed_billing` đã đăng ký.
  - `business_profiles.yml` lên version 3. `karaoke_bida` mở, có `display.surface: resource_board`, module `resources, fnb.tables, timed_billing, fnb.menu, fnb.kitchen, fnb.postpay, fnb.bottle_keep`, `kitchen_send_trigger: manual`.
- Endpoint và route:
  - `resources/:id/timed_sessions`
  - `timed_sessions/:id` (show), `quote`, `stop`, `move`, `segments/:segment_id`
  - `rate_plans` (index / create / update / preview)
  - `rate_plans/special_days` (CRUD), `rate_plans/weekend_days`
- `server/openapi/pos-staff.yaml`: thêm schema `ResourceBoardTimed`, trường `timed` của ô và hai trạng thái mới. Đã sinh lại client Dart (`tool/gen_api.sh`).
- `packages/pos-shared`: capability, module `timed_billing`, surface `resource_board`, trạng thái ô, `BoardTimed`, kiểu `PosLineTimedSession`, nhãn vi/en.
- `apps/pos` (màn thu ngân):
  - Surface `resource_board` dùng lại `TableFloor` / `TableTile`. Ô có đồng hồ chạy và tiền giờ tạm.
  - Panel phòng (`timed-panel.tsx`) có Bắt đầu, đồng hồ, báo giá server refetch 60 giây, Dừng giờ, Chuyển phòng và lời báo lỗi riêng.
  - Đồng hồ tick 1 giây từ `started_at` của server cộng độ lệch đo từ `server_now`; không gọi API mỗi giây.
  - Dòng giờ trong giỏ bị khoá sửa và hiện số phút chơi cùng các khung giá sau khi dừng.
  - Thêm `lib/timed-clock.ts`, test và `hooks/use-timed.ts`.
- `apps/pos-dashboard`:
  - Tab "Giá giờ" `/branches/$branchId/rate-plans`. Tab có danh sách và phiên bản bảng giá, form khung giờ × loại ngày, kiểm tra phủ 24 giờ ngay trên form, ngày cuối tuần, ngày lễ kèm phụ thu và ô tính thử.
  - Quyền vào tab theo `timed_billing` + `pos.rate_plan.manage`.
  - `capability-groups.ts` có 3 quyền mới; số checkbox trong `e2e/administration.spec.ts` đổi 33 → 36.

**Lệnh đã chạy**

| Lệnh | Kết quả |
|---|---|
| `pnpm spree rspec spec/services/spree/pos/timed/quote_spec.rb` | 36 ví dụ, 0 lỗi (20 ca bảng + ca thêm) |
| `pnpm spree rspec spec/workflows/spree/pos/timed/` | 15 ví dụ, 0 lỗi |
| `pnpm spree rspec spec/integration/spree/pos/timed_race_spec.rb spec/integration/spree/pos/karaoke_scenario_spec.rb` | 3 ví dụ, 0 lỗi |
| `pnpm spree rspec spec/requests/spree/pos/timed_sessions_spec.rb spec/requests/spree/pos/rate_plans_spec.rb` | 7 ví dụ, 0 lỗi |
| `pnpm spree rspec spec/requests/spree/pos/resource_board_spec.rb spec/requests/spree/pos/devices_spec.rb spec/services/spree/pos/print_documents_spec.rb spec/requests/spree/pos/timed_sessions_spec.rb` | 26 ví dụ, 0 lỗi |
| Lô liên quan (spec `timed` + bàn + workspaces + sale lines/guards + unit normalization + authentication + in/hóa đơn + credit + ví + bar + module/profile/onboarding/topology, 30 đường dẫn) | 329 ví dụ, 0 lỗi |
| `pnpm --dir apps/pos typecheck` / `lint` / `test` | sạch / sạch / 310 test qua |
| `pnpm --dir apps/pos exec playwright test e2e/karaoke.spec.ts e2e/tables.spec.ts --project desktop` | 3 qua |
| `pnpm --dir apps/pos exec playwright test e2e/reservations.spec.ts e2e/bar-tabs.spec.ts e2e/table-kitchen-send.spec.ts e2e/fnb-wave2.spec.ts e2e/branch-modules.spec.ts --project desktop` | 14 qua. Lần chạy đầu `reservations` hỏng một lần vì timing `toHaveURL`, chạy riêng và chạy lại cả lô đều qua. |
| `pnpm --dir apps/pos-dashboard typecheck` / `lint` / `test` | sạch / sạch / 125 test qua |
| `pnpm --dir packages/pos-shared typecheck` / `lint` / `test` | sạch / sạch / 281 test qua |
| `apps/pos-staff`: `tool/gen_api.sh`, `flutter analyze`, `flutter test` | sinh lại client / không có lỗi / 137 test qua |

**Lệch so với plan**

- Trang bảng giá đặt ở `apps/pos-dashboard` (`/branches/$branchId/rate-plans`), không ở `apps/pos/src/pages/settings`. Lý do: quy tắc của repo là cài đặt nằm ở dashboard.
- `special_days` là route con của `rate_plans_controller`, không có controller riêng.
- `resource_board` dùng lại `TableFloor` / `TableTile` cùng `timed-panel.tsx`, không tạo `resource-board` / `resource-tile` / `timed-line` / `segment-edit-dialog`. Các hành động nằm ở panel khi chọn ô, không đặt ngay trên ô. Bộ lọc Đang chơi / Sắp hết giờ đi theo bộ lọc trạng thái sẵn có.
- `receipt_template_variables.json` không đổi: phòng, giờ vào / ra và khung giá in thành dòng ghi chú của dòng giờ.
- Bộ spec bảng của `Quote` có 20 ca bảng cùng các ví dụ riêng, tổng 36 ví dụ. Plan yêu cầu ít nhất 25 ca bảng; các ca thêm phủ phần còn lại (qua 0h, lễ, chuyển phòng, block 1 phút, tối thiểu).
- Spec dịch vụ hồ sơ và module dùng `treat_as_planned('timed_billing')` cho các ca "sắp có" / interest, vì giờ không còn hồ sơ nào sắp có. `resources.iot_relay` là module `planned` thay chỗ.

**Còn mở**

- Tab **Phòng** cho waiter trong `apps/pos-staff` (Flutter) chưa làm. Mới có contract `resource_board` cùng client Dart đã sinh lại. Các endpoint `timed_sessions` chưa có trong `pos-staff.yaml`.
- Nút "Sửa giờ" theo từng đoạn trên màn đơn của `apps/pos` chưa làm; mới có API cùng spec duyệt và audit.
- Nút "Thanh toán" trên ô phòng tự dừng phiên rồi mở thanh toán chưa làm. Hiện guard chặn thanh toán và màn báo cần dừng giờ trước.
- Nhãn "Tạm tính đến HH:MM" trên phiếu tạm tính khi phiên còn chạy chưa làm.
- Playwright của `apps/pos-dashboard` không chạy, vì cổng 5176 do dev server của developer giữ. Đã đổi số checkbox 33 → 36 nhưng chưa chạy. Fixture `e2e/support/business-profiles.ts` vẫn ở version 2 với karaoke "sắp có"; các test interest của `setup.spec` / `business-model.spec` dựa vào nó, nên cần đổi cùng lúc khi chạy được e2e dashboard.
- Thuế bida 8% chưa có spec riêng. Kịch bản karaoke kiểm 10% cho giờ hát và bia.
- Full suite rspec và e2e chưa chạy local, theo quy định; CI chạy.

## Phần 11B: Karaoke / bida nâng cao

### Overview

Phần này bổ sung các tính năng nâng cao cho `timed_billing` (phần 11A), theo [research §3.4](../reports/261109-1748-pos-fnb-giai-tri-research.md):

- **tạm dừng / tiếp tục** phiên chơi;
- **gói giờ trả trước**: đếm ngược, báo sắp hết giờ trên bảng phòng và trên các thiết bị;
- **thẻ nạp giờ / nạp tiền**;
- **tiếp viên / nhân viên phục vụ phòng** (chỉ là sổ ghi);
- **cảnh báo giờ hoạt động** (karaoke 0h–8h, cấu hình được);
- **khuyến mãi giờ**: giờ vàng, tặng phút.

Thẻ nạp tiền và thẻ nạp giờ dùng service `StoredValue` của [phần 10A](./phase-10-can-tin-tram-dung.md), nên phải làm sau phần 10A. Bảng phase của `plan.md` đã ghi phụ thuộc này.

Relay đèn bida là [phần 11C](./phase-11-tinh-gio-giai-tri.md). Đặt phòng kèm cọc dùng `fnb.reservations` của [phần 9A](./phase-09-nha-hang-bar.md).

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | **Tạm dừng** đóng `TimedSegment` đang chạy tại `database_now`. **Tiếp tục** mở segment mới với cùng `RateRule`. Thời gian dừng không tính tiền. Tạm dừng quá `max_pause_minutes` (cấu hình theo chi nhánh) thì cảnh báo. Mỗi lần tạm dừng hoặc tiếp tục đều ghi `AuditEntry`. Dừng dài hơn ngưỡng cần approval `timed.long_pause`, để chặn kiểu "tạm dừng giả" dùng trốn tiền giờ. |
| Q2 | **Gói giờ trả trước** là một sản phẩm dịch vụ có `prepaid_minutes` (ví dụ "Gói 2 giờ"), bán như dòng `timed` có giá gói. Phiên gắn gói thì đếm ngược từ `prepaid_minutes`. Phần chơi quá gói tính theo `RatePlan` như phiên thường. Mốc "sắp hết giờ" (mặc định 10 phút) phát sự kiện `resource.updated` với `alert: 'ending_soon'`. |
| Q3 | **Thẻ nạp tiền** dùng service `Spree::Pos::StoredValue` mà phần 10A đã làm cho ví căng tin: tiền khách gửi giữ là `ReceivedFunds` không có workspace, sổ chỉ thêm, allocation FIFO. Phần này chỉ thêm kind `money` và `minutes`, không đổi hành vi của kind `meal`. |
| Q4 | **Thẻ nạp giờ** giữ số phút, không giữ số tiền. Khi bán thẻ, tiền vào `StoredValue` kèm `minutes`. Khi trừ phút vào một phiên, số tiền được allocate là `phút × (giá thẻ / tổng phút)` (giá mỗi phút cố định lúc bán thẻ). Nhờ vậy tiền chỉ thành doanh thu khi dịch vụ đã được dùng. |
| Q5 | **Tiếp viên** (đã chốt 09/11/2026: chỉ ghi sổ): `AttendantAssignment` ghi nhân viên, phòng, giờ bắt đầu và giờ kết thúc. Bản ghi này không tạo dòng tiền và không vào hóa đơn. Phase chỉ có báo cáo giờ phục vụ theo nhân viên. |
| Q6 | **Giờ hoạt động** là cấu hình theo chi nhánh (`operating_windows` theo ngày trong tuần). Hồ sơ `karaoke_bida` gợi ý chặn mở phiên từ 0h đến 8h. Mở phiên ngoài khung chỉ **cảnh báo** và yêu cầu xác nhận, không chặn cứng, vì quy định vẫn chưa được xác nhận (research §7). |
| Q7 | **Khuyến mãi giờ:**<br>• Giờ vàng là `RateRule` có giá thấp hơn trong một khung giờ, kèm nhãn hiển thị; không thêm cơ chế mới.<br>• Tặng phút là `TimedPromotion`, theo điều kiện "chơi ≥ X phút thì tặng Y phút" hoặc "đặt gói thì tặng Y phút", và được áp khi chốt giá phiên.<br>Phút tặng hiện thành một đoạn giá 0 trên bill, để hóa đơn vẫn ghi đúng tổng số giờ. |

### Dữ liệu

- `spree_pos_timed_segments`:
  - thêm `ended_reason` (`pause | move | stop | split_window`);
  - thêm `promotion_id` (null) cho đoạn tặng.
- `spree_pos_timed_sessions`:
  - thêm `prepaid_minutes` (null) và `package_line_id` (null);
  - thêm `stored_value_account_id` (null), khi phiên trừ vào thẻ giờ.
- `spree_pos_timed_promotions`: `branch_id`, `name`, `kind` (`bonus_after | bonus_with_package`), `threshold_minutes`, `bonus_minutes`, `resource_kinds`, `active_windows`, `status`.
- `spree_pos_stored_value_accounts` (phần 10A): thêm kind `money | minutes` và cột `card_digest` (thẻ nạp in QR hoặc RFID, lưu digest như `MealCard`).
- `spree_pos_stored_value_entries` (phần 10A): dùng cột `minutes` cho thẻ giờ.
- `spree_pos_attendant_assignments`: `branch_id`, `resource_id`, `timed_session_id`, `staff_id`, `started_at`, `ended_at`, `note`.
- `spree_pos_branches`: thêm `operating_windows` (jsonb) và `max_pause_minutes`.
- Approval action mới: `timed.long_pause` và `stored_value.adjust`.

### Server

1. `TimedSessions::Pause` và `TimedSessions::Resume` (idempotent theo key):
   - kiểm tra đúng trạng thái;
   - đóng hoặc mở segment;
   - phát `resource.updated`.

   Tiếp tục sau một lần dừng dài cần approval.
2. Job `TimedSessions::AlertJob` chạy mỗi phút:
   - với phiên có gói: phát `ending_soon` và `ended_package`;
   - với phiên đang dừng quá ngưỡng: phát `pause_too_long`.

   Job chỉ đọc và phát sự kiện, không đổi tiền.
3. Bộ tính giá phiên (phần 11A):
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

### Client web (`apps/pos`)

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

### Flutter (`apps/pos-staff`)

- Mode `waiter` (phục vụ phòng):
  - tạm dừng / tiếp tục, nếu có quyền;
  - gán tiếp viên;
  - nhận thông báo "Phòng 5 còn 10 phút" qua realtime.
- Mode `owner`: duyệt yêu cầu dừng dài và điều chỉnh thẻ, qua `approval.requested`. Màn duyệt chung thuộc phần 12C.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_pause_package_to_spree_pos_timed_sessions.rb`, `*_create_spree_pos_timed_promotions.rb`, `*_extend_spree_pos_stored_value_accounts.rb`, `*_create_spree_pos_attendant_assignments.rb`, `*_add_operating_windows_to_spree_pos_branches.rb` |
| Tạo | `server/app/models/spree/pos/timed_promotion.rb`, `attendant_assignment.rb` |
| Tạo | `server/app/workflows/spree/pos/timed_sessions/pause.rb`, `resume.rb`, `apply_minutes_card.rb`, `server/app/services/spree/pos/operating_hours.rb`, `server/app/jobs/spree/pos/timed_sessions/alert_job.rb` |
| Sửa | Bộ tính giá phiên của phần 11A, `server/app/services/spree/pos/stored_value.rb` và `stored_value_account.rb` (kind mới), workflow tender (`stored_value`), `server/app/models/spree/pos/approval.rb`, `server/config/routes.rb`, `server/config/pos/business_profiles.yml`, `server/openapi/pos-staff.yaml` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/timed_promotions_controller.rb`, `stored_value_accounts_controller.rb`, `attendant_assignments_controller.rb` |
| Tạo | `apps/pos/src/pages/stored-value.tsx`, `apps/pos/src/pages/timed-promotions.tsx`, `apps/pos/src/hooks/use-stored-value.ts` |
| Sửa | Component ô phòng của `resource_board` (phần 11A), `apps/pos/src/router.tsx`, `apps/pos/src/locales/*` |
| Sửa | `apps/pos-staff/lib/modes/waiter/` |

### Các bước

1. Làm tạm dừng / tiếp tục, kèm audit và approval cho lần dừng dài.
2. Làm gói giờ trả trước và job cảnh báo.
3. Thêm kind `money` và `minutes` vào `StoredValue`; làm thẻ giờ trừ vào phiên.
4. Làm khuyến mãi giờ: nhãn giờ vàng trên `RateRule` và `TimedPromotion` tặng phút.
5. Làm sổ tiếp viên và báo cáo.
6. Làm cảnh báo giờ hoạt động.
7. Làm API, OpenAPI, sinh lại client Dart; màn web và mode waiter.

### Kiểm thử

- Spec tạm dừng: phiên 19:00–21:00 dừng 20:00–20:15 thì chỉ tính 105 phút. Dừng và tiếp tục với cùng key chỉ ghi một lần. Tiếp tục sau lần dừng dài mà không có approval thì bị từ chối.
- Spec gói: gói 120 phút chơi 135 phút thì tính gói cộng 15 phút theo khung giá. Job phát `ending_soon` đúng một lần ở mốc 110 phút.
- Spec thẻ giờ: thẻ 600 phút giá 500.000 dùng 90 phút thì allocate 75.000 và còn 510 phút. Không đủ phút thì phần còn lại tính tiền.
- Spec khuyến mãi: chơi ≥ 120 phút tặng 15 phút, đoạn tặng giá 0 xuất hiện trên bill. Hóa đơn điện tử ghi tổng số giờ.
- Spec giờ hoạt động: mở phiên lúc 0:30 trả warning, không trả lỗi.
- Spec hồi quy: toàn bộ spec ví căng tin (kind `meal`) vẫn xanh.
- E2E web: mở phòng có gói, tạm dừng, tiếp tục, nhận cảnh báo sắp hết giờ, thanh toán có đoạn tặng.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Tạm dừng bị lạm dụng để giảm tiền | Có audit, có approval khi dừng lâu, có báo cáo số lần dừng theo nhân viên. |
| Thêm kind mới làm hỏng ví căng tin | Logic theo kind tách riêng; chạy lại toàn bộ spec của phần 10A. |
| Job cảnh báo chạy trễ khi server LAN yếu | Client tự đếm ngược theo `ends_at` mà server trả về; job chỉ phát sự kiện để báo các thiết bị khác. |

### Tiêu chí xong

- [ ] Tạm dừng / tiếp tục tính đúng tiền, có audit, và có duyệt khi dừng lâu.
- [ ] Gói giờ đếm ngược. S1 và app phục vụ nhận cảnh báo sắp hết giờ.
- [ ] Thẻ nạp tiền và thẻ nạp giờ đi qua lõi tiền; doanh thu chỉ ghi khi đã dùng dịch vụ.
- [ ] Sổ tiếp viên và báo cáo giờ phục vụ.
- [ ] Mở phiên ngoài giờ hoạt động có cảnh báo.
- [ ] Giờ vàng và tặng phút hiện đúng trên bill và hóa đơn.
- [ ] OpenAPI, spec và e2e đều xanh; spec ví của phần 10A không hồi quy.

## Phần 11C: Relay đèn bida

### Overview

Bàn bida bật đèn khi phiên chơi bắt đầu và tắt đèn khi kết thúc, có thời gian ân hạn để khách dọn cơ. Relay nằm **ngoài đường tiền**: lỗi relay không bao giờ chặn mở phiên, tính giờ hay thanh toán. Giờ chơi vẫn tính theo `TimedSession` / `TimedSegment` ở server (phần 11A), không theo trạng thái đèn.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Hai loại relay ở bản đầu: **Shelly** (HTTP local API, Gen2 RPC `Switch.Set`) và **HLK-SW16** (TCP, 16 kênh, lệnh nhị phân). Interface `Spree::Pos::Relays::Driver` (`set(channel, on)`, `state(channel)`), mỗi loại một driver; thêm loại khác chỉ là thêm driver. |
| Q2 | **Ai gửi lệnh:** nếu server chạy LAN cùng mạng với relay (D5), server gửi trực tiếp từ job nền. Nếu server là VPS, server không với tới relay; một thiết bị Flutter mode `bridge` đặt ở quán nhận lệnh qua `BranchChannel` và gửi ra relay trong LAN, rồi báo kết quả về server. Mỗi `RelayDevice` ghi rõ `executor` (`server` \| `bridge`). |
| Q3 | Sự kiện: `TimedSession` bắt đầu / tiếp tục → bật; tạm dừng (phần 11B) → giữ đèn theo cấu hình (`pause_light`: `on` \| `off`); kết thúc / thanh toán → hẹn tắt sau `grace_seconds` (mặc định 120). Mở lại phiên trong ân hạn thì hủy lệnh tắt. |
| Q4 | **Điều khiển tay:** nhân viên có quyền bật / tắt đèn từng bàn trên bảng phòng, ghi `AuditEntry` (`relay.manual`). Bật tay khi bàn không có phiên thì hiện cảnh báo "đèn bật không có phiên" sau 5 phút (chống bật đèn chơi chui). |
| Q5 | **An toàn điện:** relay chỉ đóng / ngắt mạch điều khiển; tải đèn bàn bida lớn phải qua **contactor** do thợ điện lắp. Plan chỉ ghi yêu cầu này vào tài liệu cài đặt và màn cấu hình; phần mềm không thay được yêu cầu điện. Mặc định khi relay mất điều khiển: giữ nguyên trạng thái, không tự tắt giữa trận. |

### Dữ liệu

- `spree_pos_relay_devices`: `store_id`, `branch_id`, `name`, `driver` (`shelly` \| `hlk_sw16`), `address` (host:port trong LAN), `credentials_ciphertext` (nếu Shelly bật mật khẩu), `executor` (`server` \| `bridge`), `bridge_device_id` (Device mode `bridge`), `status` (`online` \| `offline` \| `disabled`), `last_seen_at`, `last_error`.
- `spree_pos_relay_channels`: `relay_device_id`, `channel` (số kênh), `resource_id` (unique), `pause_light`, `grace_seconds`.
- `spree_pos_relay_commands`: `relay_channel_id`, `desired_state` (on/off), `reason` (`session_start` \| `session_resume` \| `session_pause` \| `session_end` \| `manual`), `run_at`, `status` (`queued` \| `sent` \| `confirmed` \| `failed` \| `canceled`), `attempts`, `error`, `actor_id`. Idempotent theo (`relay_channel_id`, sự kiện nguồn).

### Server

- Subscriber trên sự kiện tính giờ của phần 11A (`resource.updated` / sự kiện phiên) → `Spree::Pos::Relays::Schedule` tạo `RelayCommand` (lệnh tắt có `run_at = now + grace`).
- `Spree::Pos::RelayCommandJob` (Solid Queue): với `executor = server` gọi driver, đọc lại `state` để xác nhận; với `executor = bridge` phát sự kiện `relay.command` (mới) trên `BranchChannel` chỉ tới thiết bị bridge của chi nhánh.
- Endpoint cho bridge: `POST api/v3/admin/pos/relay_commands/:id/result` (xác thực bằng credential thiết bị mode `bridge`, phase 2).
- Retry 3 lần cách 5 giây; thất bại thì `failed`, phát `owner_alert.created` (phần 12C) và hiện biểu tượng lỗi trên ô bàn của bảng phòng.
- Health check mỗi phút cho relay `server` và heartbeat của bridge; quá 2 phút không thấy thì `offline`.
- Endpoint nhân viên: CRUD relay / kênh, kiểm thử bật tắt (`test`), bật / tắt tay một bàn. Quyền mới `pos.relay.manage` (cấu hình) và `pos.relay.operate` (bật tắt tay).

### Flutter (`apps/pos-staff`, chế độ `bridge`)

- Màn tối giản: tên chi nhánh, danh sách relay và trạng thái, nhật ký 50 lệnh gần nhất.
- Nhận `relay.command`, gửi HTTP (Shelly) hoặc TCP socket (HLK-SW16) trong LAN, báo kết quả.
- Chạy nền: Android foreground service + `wakelock_plus`; khuyến nghị thiết bị Android cắm sạc cố định. iOS không hỗ trợ chạy nền lâu dài nên mode `bridge` chỉ bật trên Android (ghi rõ trong màn ghép thiết bị).
- Khi mất kết nối server, bridge **không tự đổi** trạng thái relay.

### Client web `apps/pos`

- Cài đặt chi nhánh → Relay: thêm relay, chọn driver, địa chỉ, executor, gán kênh ↔ bàn, nút kiểm thử, cảnh báo contactor.
- Bảng phòng (phần 11A): biểu tượng đèn trên ô bàn (bật / tắt / lỗi / offline), menu bật / tắt tay.

### File

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

### Các bước

1. Migration, model, driver Shelly / HLK-SW16 với spec dùng server giả (WEBrick / TCP server trong spec).
2. `Schedule` + subscriber: spec bật khi bắt đầu, tắt sau ân hạn, hủy tắt khi mở lại trong ân hạn.
3. Job chạy lệnh, retry, health, cảnh báo.
4. Đường bridge: sự kiện, endpoint kết quả, Flutter mode `bridge` (Android).
5. UI cài đặt và chỉ báo đèn trên bảng phòng.
6. Tài liệu lắp đặt: contactor, IP tĩnh cho relay, cùng VLAN với server / bridge.

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/relays/ spec/jobs/spree/pos/relay_command_job_spec.rb spec/requests/spree/pos/relay_devices_spec.rb`.
- Spec quan trọng: relay lỗi không làm hỏng mở phiên / thanh toán (lệnh tính giờ vẫn thành công, chỉ ghi `failed`).
- Flutter: unit test mã hóa lệnh HLK-SW16; integration test với Shelly giả lập.
- Thử thật trên một Shelly Plus 1 và một HLK-SW16 trước khi đánh dấu xong.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Đèn tắt giữa trận do lỗi | Chỉ tắt theo sự kiện kết thúc; mất điều khiển thì giữ nguyên trạng thái; có điều khiển tay. |
| Chơi chui bằng cách bật đèn tay | Bật tay có audit và cảnh báo khi không có phiên. |
| VPS không với tới relay | Executor `bridge` trên Android tại quán. |
| Tải điện lớn làm hỏng relay | Bắt buộc contactor, ghi trên màn cấu hình và tài liệu. |

### Tiêu chí xong

- [ ] Bắt đầu phiên bật đèn, kết thúc tắt sau ân hạn, với cả executor server và bridge.
- [ ] Lỗi relay hiện trên bảng phòng và gửi cảnh báo, không chặn nghiệp vụ.
- [ ] Bật / tắt tay có quyền và audit.
- [ ] Đã thử trên thiết bị thật hai loại relay.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
