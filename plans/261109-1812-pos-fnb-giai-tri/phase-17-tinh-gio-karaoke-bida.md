---
phase: 17
title: "Tính giờ karaoke / bida"
status: pending
effort: "9 ngày"
dependsOn: [13, 15]
---

# Phase 17: Tính giờ karaoke / bida (`timed_billing`)

## Overview

Phase này làm module `timed_billing` và màn bắt đầu `resource_board`, rồi mở hồ sơ `karaoke_bida`.

Đơn vị đang mở là phòng / bàn chơi (`Resource` của phase 13) có đồng hồ. Bill gồm giờ chơi và đồ ăn uống gọi thêm. Giờ chơi là một **phiên gồm nhiều đoạn** (theo mẫu Vyrox ở research §3.4). Giá theo khung giờ × loại ngày × loại phòng, có block làm tròn và ngưỡng ân hạn. Đoạn nào vắt qua hai khung giá thì được chia ra; chuyển phòng giữ giá của đoạn cũ; sửa giờ phải có duyệt.

Tạm dừng / tiếp tục, đếm ngược gói giờ trả trước, thẻ nạp giờ, cảnh báo 0h–8h và dòng tiếp viên để ở phase 21. Mô hình dữ liệu của phase này đã chừa chỗ cho các tính năng đó.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Mọi mốc thời gian lấy từ `Workspace.database_now` (plan.md bất biến 3). Client chỉ hiển thị đồng hồ chạy từ `started_at` của server cộng độ lệch đo được khi kết nối. Lệnh "Bắt đầu" không nhận giờ từ client. |
| Q2 | Một phiên (`TimedSession`) gắn với **một SaleLine kind `timed`** của workspace. Đơn vị cơ sở là **phút**, đơn vị bán là **giờ**. Cách làm giống `retail.measured`: `line_item.quantity` = số phút tính tiền, `line_price` = giá một phút, `sale_quantity` = số giờ (4 chữ số thập phân). Vì vậy hóa đơn điện tử xuất được theo giờ (research §5.1). Check constraint `dimension` của `UnitDefinition` thêm `time`, kèm đơn vị `phut` (cơ sở) và `gio` (= 60 phút). |
| Q3 | Khi phiên đang chạy, tiền giờ trên màn hình là **báo giá tạm** (`Timed::Quote` với `now`) và không ghi vào line item. Line item chỉ được ghi khi **dừng phiên**. Chuẩn bị tender (`Tenders` prepare) từ chối nếu workspace còn phiên đang chạy, với `reason: 'timed_session_running'`. Nút "Thanh toán" trên ô phòng làm theo thứ tự: dừng phiên, rồi mở thanh toán. Tạm tính khi đang chạy in nhãn "Tạm tính đến HH:MM". |
| Q4 | Mỗi đoạn (`TimedSegment`) lưu **snapshot giá**: `rate_plan_id`, `price_per_hour` và `rule_id` tại lúc tính. `Timed::Quote` chia đoạn tại mọi ranh giới khung giờ và ranh giới ngày (theo `Branch.timezone`) rồi cộng tiền. Đổi bảng giá sau đó không làm đổi phiên đã dừng. Phiên đang chạy dùng bảng giá hiện hành cho phần chưa dừng. |
| Q5 | Làm tròn áp trên **tổng phút chơi của phiên**, không áp trên từng đoạn. Phần dư ≤ `grace_minutes` thì bỏ; dư hơn thì làm tròn lên một `block_minutes`. Có `minimum_minutes`. Tiền của phần làm tròn tính theo giá của **đoạn cuối**. Ví dụ block 15, ân hạn 5: 62 phút → 60, 66 phút → 75. |
| Q6 | Loại ngày là `weekday`, `weekend` hoặc `holiday`. `SpecialDay` đánh dấu ngày lễ của chi nhánh. Nếu bảng giá không có rule `holiday` thì dùng rule `weekend` cộng `holiday_surcharge_percent` của `SpecialDay` (phụ thu lễ Tết). Cuối tuần là cấu hình theo chi nhánh, mặc định Thứ 7 và Chủ nhật. |
| Q7 | Chuyển phòng (`Timed::MoveResource`): đóng đoạn hiện tại tại `now` và mở đoạn mới trên phòng mới, dùng bảng giá theo `resource_type_code` của phòng mới. Đoạn cũ **giữ giá cũ**. Workspace đổi `resource_id` qua `Tables::Move` của phase 13, trong cùng transaction. |
| Q8 | Gộp phòng dùng `Tables::Merge`: mỗi phiên vẫn chạy riêng, nên bill có nhiều dòng giờ. Tách dùng `Tables::Split`: chuyển phiên cùng SaleLine `timed` của nó sang workspace mới. |
| Q9 | Sửa giờ (`Timed::EditSegment`) đổi `started_at` / `ended_at` của một đoạn đã đóng hoặc `started_at` của đoạn đang chạy. Lệnh cần lý do và `Approval` action `timed.edit_segment`, trừ khi người làm có capability `pos.timed.edit`. Audit ghi giá trị trước / sau. Không cho sửa vượt `now` hoặc làm các đoạn chồng lên nhau. |
| Q10 | Thuế: mặt hàng dịch vụ giờ là một `Spree::Variant` gắn với `RatePlan`, có `TaxCategory` riêng. Giờ hát karaoke dùng tax category 10% (hàng chịu TTĐB); giờ bida dùng mức chung (8% đến 31/12/2026). Đây là cấu hình của phase 1, không viết cứng. |

## Dữ liệu

Migration `add_time_dimension_to_pos_unit_definitions`: mở check constraint thêm `time`, seed `phut` và `gio`.

Migration `create_spree_pos_rate_plans_and_rules`:
- `spree_pos_rate_plans`: `store_id`, `branch_id`, `name`, `resource_type_code`, `variant_id` (dịch vụ giờ, quyết định thuế), `block_minutes` (1–60, mặc định 15), `grace_minutes` (0–block, mặc định 5), `minimum_minutes` (mặc định 0), `status` (`active|archived`), `version`. Mỗi `(branch_id, resource_type_code)` chỉ có một plan active (partial unique).
- `spree_pos_rate_rules`: `rate_plan_id`, `day_type` (`weekday|weekend|holiday`), `start_minute`, `end_minute` (0–1440; `end < start` nghĩa là qua 0h), `price_per_hour` (decimal), `position`. Validation: các rule cùng `day_type` phủ kín 24 giờ, không chồng nhau.
- `spree_pos_special_days`: `branch_id`, `date`, `name`, `holiday_surcharge_percent` (nullable). Unique `(branch_id, date)`.
- `spree_pos_branches.weekend_days` (jsonb, mặc định `[6,0]`).

Migration `create_spree_pos_timed_sessions_and_segments`:
- `spree_pos_timed_sessions`: `workspace_id`, `sale_line_id` (unique), `resource_id`, `status` (`running|paused|stopped`), `started_at`, `stopped_at`, `planned_end_at` (nullable: giờ dự kiến kết thúc nhập khi bắt đầu; phase 21 dùng cho gói trả trước), `billed_minutes`, `amount`, `quote_version`. Index `(resource_id, status)`. Mỗi `resource_id` có tối đa một phiên `running|paused` (partial unique), nên một phòng không chạy hai đồng hồ.
- `spree_pos_timed_segments`: `timed_session_id`, `resource_id`, `kind` (`play|pause`), `started_at`, `ended_at` (nullable khi đang chạy), `rate_plan_id`, `rate_plan_version`, `edited` (boolean). Check `ended_at > started_at`.
- `spree_pos_timed_quote_lines` (ghi khi dừng, để in và xuất hóa đơn): `timed_session_id`, `segment_id`, `from`, `to`, `day_type`, `price_per_hour`, `minutes`, `amount`.

## Server

- Model `RatePlan`, `RateRule`, `SpecialDay`, `TimedSession`, `TimedSegment`, `TimedQuoteLine`.
- `Spree::Pos::Timed::Quote.call(session, now:)`: hàm thuần, không ghi. Nó chia đoạn theo rule và ngày, áp Q5 và Q6, rồi trả về các dòng báo giá cùng tổng. Đây là phần có nhiều spec nhất: qua 0h, qua ranh giới khung giá, sang ngày lễ, chuyển phòng giữa chừng, block 1 phút, `minimum_minutes`.
- Workflow `app/workflows/spree/pos/timed/`:
  - `start.rb`: tạo SaleLine `timed` (qua `LineBuilder` của phase 14) và phiên, rồi mở đoạn `play`. Nếu phòng chưa có workspace thì mở bàn bằng `Tables::Open` với `service_mode: 'timed'`.
  - `stop.rb`: đóng đoạn, chạy `Quote`, ghi `TimedQuoteLine`, rồi cập nhật line item (số phút, giá một phút) và `sale_quantity` (giờ). Lệnh tăng `revision` và idempotent.
  - `move_resource.rb`, `edit_segment.rb` (Q7, Q9).
- Lệnh tính giờ chạy không cần lease, giống `append_items`, và kiểm tra `can_edit_workspace?` cùng capability mới `pos.timed.operate`. Lệnh vẫn đi qua `ensure_snapshot_editable!`.
- Guard tender: thêm kiểm tra Q3 vào `Tenders::Guard`. Đây là guard theo dữ liệu, chạy cả khi module tắt (plan bán lẻ D5).
- `ResourceState` (phase 13) thêm `timed: { status, started_at, planned_end_at, quote_amount }` và trạng thái `playing` / `ending_soon` (còn ≤ 10 phút tới `planned_end_at`). `reserved` lấy từ phase 18 khi có.
- `Workspace#to_pos`: dòng `timed` có `session` gồm các đoạn và báo giá tạm.
- Receipt / prebill: `ReceiptBuilder` in giờ vào, giờ ra, số giờ và từng khung giá. Thêm biến tương ứng vào `config/pos/receipt_template_variables.json`.
- Approval action `timed.edit_segment`. Capability `pos.timed.operate`, `pos.timed.edit`, `pos.rate_plan.manage`.
- Module `timed_billing` chuyển sang `register`; hồ sơ `karaoke_bida` có `display.surface: resource_board`, thêm `resources`, `fnb.kitchen` vào `optional_modules` (phase 16 Q1) và tăng `version` của YAML.
- Realtime: start / stop / move / edit phát `resource.updated` và `workspace.updated`.
- Endpoint: `rate_plans` (CRUD + rules), `special_days`, `resources/:id/timed_sessions` (start), `timed_sessions/:id/stop|move|segments/:segment_id`, `timed_sessions/:id/quote`. Cập nhật OpenAPI.

## Client web (`apps/pos`)

- Surface `resource_board`: lưới ô phòng / bàn chơi. Mỗi ô có tên, loại, **đồng hồ chạy**, tiền giờ tạm, tiền đồ uống và trạng thái màu kèm nhãn.
- Lọc: Đang chơi / Sắp hết giờ / Trống / Đã đặt (ẩn khi chưa có phase 18) / Đang dọn.
- Hành động ngay trên ô: **Bắt đầu**, **Gọi món**, **Chuyển phòng**, **Thanh toán**. Nút **Tạm dừng** thêm ở phase 21.
- Màn đơn của phòng: dòng giờ mở ra danh sách đoạn. Mỗi đoạn có nút "Sửa giờ" (xin duyệt).
- Cài đặt `/settings/branches/$branchId/rate-plans`: bảng giá theo loại phòng, lưới khung giờ × loại ngày, block / ân hạn / tối thiểu, ngày lễ. Có ô xem thử: nhập giờ vào / ra và xem tiền.
- Đồng hồ trên màn chạy bằng `requestAnimationFrame` / interval 1 giây từ dữ liệu server, không gọi API mỗi giây. Báo giá tạm refetch mỗi 60 giây hoặc khi có sự kiện.

## App Flutter (`apps/pos-staff`)

- Chế độ `waiter` có thêm tab **Phòng** khi chi nhánh bật `timed_billing`. Tab này cùng dữ liệu `resource_board`, ô có đồng hồ.
- Phục vụ phòng: gọi món vào phòng (dùng lại luồng gọi món của phase 15), Bắt đầu / Dừng phiên nếu có `pos.timed.operate`, chuyển phòng, yêu cầu thanh toán. Không thu tiền.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_time_dimension_to_pos_unit_definitions.rb`, `*_create_spree_pos_rate_plans_and_rules.rb`, `*_create_spree_pos_timed_sessions_and_segments.rb` |
| Tạo | `server/app/models/spree/pos/{rate_plan,rate_rule,special_day,timed_session,timed_segment,timed_quote_line}.rb`, `server/app/services/spree/pos/timed/quote.rb`, `server/app/workflows/spree/pos/timed/{start,stop,move_resource,edit_segment}.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/{rate_plans,special_days,timed_sessions}_controller.rb` |
| Sửa | `server/app/models/spree/pos/{unit_definition,branch,capabilities,approval,workspace}.rb`, `server/app/services/spree/pos/{resource_state,receipt_builder}.rb`, `server/app/workflows/spree/pos/tenders/guard.rb`, `server/config/pos/{business_profiles.yml,receipt_template_variables.json}`, `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos/src/components/{resource-board,resource-tile,timed-line,segment-edit-dialog}.tsx`, `apps/pos/src/pages/settings/rate-plans.tsx`, `apps/pos/src/hooks/use-timed.ts`, `apps/pos/src/lib/timed-clock.ts` (+ `.test.ts`) |
| Tạo | `apps/pos-staff/lib/features/waiter/rooms/**`, `apps/pos-staff/test/features/waiter/rooms/**` |

## Các bước

1. Dimension `time`, đơn vị phút / giờ; spec `UnitNormalizer` với giờ.
2. Bảng giá, rule, ngày lễ, kèm validation phủ kín 24 giờ.
3. `Timed::Quote` và bộ spec bảng (table-driven): ít nhất 25 trường hợp, gồm qua 0h, khung giá, lễ, chuyển phòng, block / ân hạn / tối thiểu, Q5.
4. Start / stop / move / edit; guard tender; spec race "hai người bấm Bắt đầu cùng một phòng" (partial unique index chặn).
5. `ResourceState`, receipt và hóa đơn theo giờ.
6. Web: `resource_board`, đơn của phòng, trang bảng giá.
7. Flutter: tab Phòng.
8. Mở hồ sơ `karaoke_bida`, có kịch bản: bắt đầu phòng VIP 21:30, gọi bia, chuyển sang phòng thường 22:40, dừng 23:55, thu tiền. Bill có đúng hai đoạn giá, bia thuế 10%, giờ hát thuế 10%.

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/timed/quote_spec.rb spec/workflows/spree/pos/timed/ spec/requests/spree/pos/timed_sessions_spec.rb spec/requests/spree/pos/rate_plans_spec.rb spec/integration/spree/pos/timed_race_spec.rb spec/integration/spree/pos/karaoke_scenario_spec.rb`.
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`.
- Web: `pnpm --dir apps/pos typecheck`, `test` (gồm `timed-clock.test.ts`), `test:e2e` (`e2e/karaoke.spec.ts`).
- Flutter: `flutter analyze`, `flutter test`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Sai tiền khi qua 0h hoặc đổi khung giá | `Quote` là hàm thuần có spec bảng; tính theo `Branch.timezone`. |
| Gian lận bằng chỉnh giờ máy | Q1: giờ chỉ từ server; sửa giờ cần duyệt và có audit. |
| Spree `LineItem.quantity` là số nguyên | Dùng phút làm đơn vị cơ sở như `retail.measured` dùng gam; giá một phút có thể lẻ, đã được hỗ trợ (`line_price` theo đơn vị cơ sở). |
| Quên dừng phiên trước khi thu tiền | Guard tender chặn; nút Thanh toán tự dừng phiên trước. |
| Phiên chạy qua ca | Đơn chưa có tiền chuyển ca theo `ShiftRebind` (phase 13); phiên giữ nguyên các đoạn. |

## Tiêu chí xong

- [ ] Bảng giá theo khung giờ × loại ngày × loại phòng, có block, ân hạn, tối thiểu, ngày lễ và phụ thu.
- [ ] Phiên nhiều đoạn chia đúng tại ranh giới giá và ngày; chuyển phòng giữ giá đoạn cũ.
- [ ] Sửa giờ cần duyệt, có audit, không chồng đoạn.
- [ ] Bill và hóa đơn ghi giờ chơi theo đơn vị giờ, đúng thuế suất theo cấu hình.
- [ ] `resource_board` trên web và tab Phòng trên Flutter có đồng hồ và các hành động trên ô.
- [ ] Hồ sơ `karaoke_bida` chọn được; kịch bản karaoke xanh.
