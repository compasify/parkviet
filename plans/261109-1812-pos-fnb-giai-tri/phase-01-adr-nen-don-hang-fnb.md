---
phase: 1
title: "ADR và nền đơn hàng F&B"
status: in-progress
effort: "6 ngày"
dependsOn: []
---

# Phase 1: ADR và nền đơn hàng F&B

## Overview

Phase này ghi lại quyết định mở phạm vi sang F&B và đặt vào lõi những trường mà mọi phase sau đều dùng: hình thức phục vụ, kiểu dòng mở rộng được, ngày kinh doanh, thuế suất theo món. Nó cũng mở đường chuyển module từ `planned` sang `available` và khởi tạo hợp đồng OpenAPI mà app Flutter sẽ sinh client từ đó.

Chưa có màn hình F&B nào ở phase này. Chi nhánh bán lẻ giữ nguyên hành vi: `service_mode = counter` và mọi dòng vẫn là `ordinary | measured | tracked`.

## Quyết định của phase

1. **ADR** `docs/adr/0001-pos-fnb-scope.md` ghi:
   - phạm vi mới (6 ngành F&B / giải trí);
   - D1–D10 của plan;
   - lý do đổi câu "Không thêm F&B" ở `plans/261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md` (dòng 38).

   File spec cũ là bản ghi lịch sử nên không viết lại nội dung, chỉ thêm một dòng ghi chú ngay dưới dòng 38 trỏ sang ADR.
2. `service_mode` là thuộc tính của Workspace, đặt khi tạo:
   - Mặc định là `counter`.
   - Đổi được khi đơn chưa có tiền. Đổi qua lệnh riêng, có audit.
   - Đây không phải module: chỉ là một giá trị, các module F&B đọc nó để định tuyến bếp và chọn mẫu in.
3. Kiểu dòng lấy từ registry `Spree::Pos::SaleLineKinds`, không còn là hằng số rải rác.
   - Mỗi kind khai báo `module` sở hữu nó (hoặc `nil` nếu là lõi) và có được phép gộp dòng theo `merge_key` hay không.
   - Phase này chỉ **đăng ký tên** `menu`, `timed`, `cover`, chưa có workflow tạo. Check constraint DB mở rộng để nhận ba giá trị này.
4. **Ngày kinh doanh là lõi (D8):**
   - `Branch.business_day_cutoff` có kiểu `time`, mặc định `04:00`, tính theo `Branch.timezone`.
   - `business_date` được gán **một lần** khi tạo Workspace, và cũng khi mở Shift, từ `Workspace.database_now`. Sau đó không tính lại.
   - Báo cáo và số gọi đọc trường này.
5. **Thuế theo món:**
   - Dùng `Spree::TaxCategory` gắn vào product, và `Spree::TaxRate` gắn với zone của store.
   - Seed tạo hai category: `vat_food` (8% đến 31/12/2026) và `vat_special` (10%, cho bia, rượu, giờ karaoke). Rate 8% có `starts_at` / `expires_at` (kiểm tra xem Spree 6 có hỗ trợ hai cột này không). Nếu không hỗ trợ, thêm bảng lịch thuế suất riêng của POS và một job đổi rate theo ngày.
   - Mức 10% từ 01/01/2027 là bản ghi cấu hình, không phải code.
   - POS chỉ đọc `included_tax_total` / `additional_tax_total` như hiện tại, và thêm phân rã thuế theo thuế suất vào `Workspace#to_pos` và vào biên lai.
6. **Chuyển module sang `available`:**
   - Đổi `planned` → `register` trong `server/config/initializers/pos_modules.rb` ở chính phase làm module đó.
   - Phase này chỉ thêm spec bảo vệ: module `available` phải có ít nhất một route hoặc workflow được khai báo, nếu không thì boot fail.
   - Hồ sơ ngành tự chuyển `coming_soon` → `available` khi đủ module (đã có trong `BusinessProfiles`).
7. **OpenAPI:**
   - Tạo `server/openapi/pos-staff.yaml` (OpenAPI 3.1).
   - Phase này mô tả các endpoint mà app Flutter sẽ cần ngay: `context`, `catalog`, `workspaces` (create / show / items), `approvals`. Các phase sau tự thêm endpoint của mình.
   - Request spec kiểm response bằng helper `expect_pos_schema!(response, 'Workspace')`, dùng `json_schemer` (đã có trong `Gemfile.lock` qua Spree, kiểm tra lại trước khi dùng trực tiếp; nếu cần thì thêm bằng `pnpm spree bundle add json_schemer`).

## Dữ liệu

| Bảng | Thay đổi |
|---|---|
| `spree_pos_workspaces` | `service_mode string not null default 'counter'` (check `counter|dine_in|takeaway|delivery|tab|timed`); `business_date date not null` (backfill từ `created_at` theo timezone chi nhánh, cutoff 04:00); index `(branch_id, business_date)` |
| `spree_pos_shifts` | `business_date date not null` (backfill theo `opened_at`); index `(branch_id, business_date)` |
| `spree_pos_branches` | `business_day_cutoff time not null default '04:00'` |
| `spree_pos_sale_lines` | check constraint `kind` mở rộng thành `ordinary|measured|tracked|menu|timed|cover` |

Migration: `add_service_mode_and_business_date_to_pos_workspaces`, `add_business_date_to_pos_shifts`, `add_business_day_cutoff_to_pos_branches`, `widen_pos_sale_line_kinds`. Backfill chạy trong migration theo lô 1.000 dòng. **Sao lưu DB trước khi migrate** (giống `backups/spree_development-pre-vietqr-261108.dump`).

## Server

- `server/app/services/spree/pos/business_day.rb`: `BusinessDay.for(branch, at)` trả về `Date`. Giờ trước cutoff thuộc ngày hôm trước. Có spec cho mốc 23:59, 00:00, 03:59, 04:00 và đổi múi giờ.
- `server/app/services/spree/pos/sale_line_kinds.rb`: `define!`, `fetch!`, `known?`, `mergeable?`. Đăng ký trong `server/config/initializers/pos_modules.rb`, ngay sau các module. `SaleLine` validate `kind` qua registry.
- `workflows/spree/pos/workspaces/create.rb`: nhận `service_mode`, kiểm theo `Workspace::SERVICE_MODES`, gán `business_date`.
- Workflow mới `workflows/spree/pos/workspaces/set_service_mode.rb`:
  - giống `set_order_source.rb`: cần lease, kiểm revision, chặn khi `snapshot_locked?`;
  - audit `workspace.service_mode`.
- `workflows/spree/pos/shifts/open.rb`: gán `business_date`.
- `Workspace#summary` thêm `service_mode` và `business_date`. `to_pos.totals` thêm `taxes: [{ rate, label, amount }]`.
- `services/spree/pos/receipt_builder.rb` và `config/pos/receipt_template_variables.json`: thêm biến `taxes[]` và `business_date`.
- `reports_controller.rb`: lọc và nhóm theo `business_date`, thay cho ngày của `created_at`. Đọc trước để biết báo cáo hiện tính ngày bằng gì.
- Route: `PATCH api/v3/admin/pos/workspaces/:id/service_mode`.
- Seed: `server/db/seeds/pos_tax_categories.rb`, idempotent, chỉ tạo khi store chưa có category cùng mã.

## Client web

- `apps/pos/src/components/workspace-tabs.tsx`:
  - hiện nhãn `service_mode` khi khác `counter`;
  - chỉ cho đổi ở chi nhánh có module `fnb.menu`. Module này chưa available, nên phần UI tồn tại nhưng chưa ai thấy.
- `apps/pos/src/pages/settings/branch-settings.tsx`: trường "Giờ chốt ngày kinh doanh".
- Biên lai (`pages/receipt.tsx`): bảng thuế theo thuế suất.
- i18n: `apps/pos/src/locales/*`, các key `serviceMode.*` và `businessDay.*`.

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `docs/adr/0001-pos-fnb-scope.md` | create | ADR phạm vi F&B |
| `plans/261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md` | modify | Một dòng ghi chú trỏ sang ADR |
| `server/db/migrate/*_add_service_mode_and_business_date_to_pos_workspaces.rb` và 3 migration còn lại | create | Như bảng Dữ liệu |
| `server/app/services/spree/pos/business_day.rb`, `sale_line_kinds.rb` | create | Như mục Server |
| `server/app/models/spree/pos/workspace.rb`, `sale_line.rb`, `shift.rb`, `branch.rb` | modify | Validate, summary |
| `server/app/workflows/spree/pos/workspaces/create.rb`, `set_service_mode.rb`, `shifts/open.rb` | modify / create | Gán và đổi trường |
| `server/config/initializers/pos_modules.rb` | modify | Đăng ký kind, guard module available |
| `server/openapi/pos-staff.yaml` | create | Hợp đồng ban đầu |
| `server/spec/support/pos_schema_helpers.rb` | create | `expect_pos_schema!` |
| `server/db/seeds/pos_tax_categories.rb` | create | Thuế 8% / 10% |

## Các bước

1. Viết ADR, rồi thêm dòng ghi chú vào spec cũ.
2. Sao lưu DB dev, viết migration kèm backfill, chạy `pnpm spree migrate`.
3. Làm `BusinessDay`, `SaleLineKinds`, validate model.
4. Sửa workflow create / open shift, thêm `set_service_mode`.
5. Thêm thuế theo món: seed, phân rã thuế, biến mẫu in.
6. Viết `pos-staff.yaml` cho các endpoint đã liệt kê, viết helper schema, gắn vào request spec của các endpoint đó.
7. Làm phần UI web: giờ chốt, nhãn service mode, bảng thuế.

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/business_day_spec.rb spec/services/spree/pos/sale_line_kinds_spec.rb`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/ spec/requests/spree/pos/workspaces_spec.rb spec/requests/spree/pos/reports_spec.rb`
- Spec migration: workspace tạo lúc 01:30 giờ Việt Nam được backfill vào ngày hôm trước.
- Spec thuế: một đơn có món 8% và món 10% thì `taxes` ra hai dòng và tổng bằng `included_tax_total + additional_tax_total`.
- Toàn bộ hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/integration/spree/pos/` và `pnpm --dir apps/pos test:e2e`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Backfill `business_date` sai làm lệch báo cáo cũ | Spec trên dữ liệu mẫu qua 0h. So sánh tổng doanh thu theo ngày trước và sau migrate trên bản dump dev. |
| Spree 6 không có rate theo thời gian | Bước 5 kiểm trước. Nếu không có, dùng bảng `spree_pos_tax_rate_schedules` và job `ApplyTaxRateScheduleJob` chạy lúc 00:05. |
| Đổi `service_mode` sau khi đã báo bếp làm lệch định tuyến | Phase 9 chặn đổi khi đã có `KitchenTicket`. Phase này chặn khi snapshot đã khóa. |

## Tiêu chí xong

- [x] ADR đã merge, spec cũ có dòng trỏ sang ADR.
- [x] Workspace và Shift có `business_date` đúng theo cutoff; báo cáo nhóm theo trường này.
- [x] `service_mode` tạo và đổi được, có audit; bán lẻ luôn là `counter`.
- [x] Registry `SaleLineKinds` có 6 kind; DB nhận `menu`, `timed`, `cover`.
- [x] Một đơn có hai thuế suất in ra đúng bảng thuế; đổi rate bằng dữ liệu, không sửa code.
- [x] `pos-staff.yaml` có các endpoint lõi; request spec của các endpoint đó kiểm schema.
- [ ] Toàn bộ spec POS và e2e web xanh.

## Review 11/11/2026

Đã review và sửa. Spec POS xanh 629/629; e2e `apps/pos-dashboard` xanh sau khi cập nhật spec cũ. Ô cuối còn mở vì e2e `apps/pos` chưa ổn định: lần chạy đầy đủ còn vài test fail, chủ yếu timeout khi máy tải nặng, và chưa có lần nào xanh trọn bộ.
