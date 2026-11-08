---
phase: 1
title: "Registry module, danh mục hồ sơ, dữ liệu"
status: completed
effort: "2 ngày"
dependsOn: []
---

# Phase 1: Registry module, danh mục hồ sơ, dữ liệu

## Overview

Đưa vào server khái niệm **module** và **hồ sơ ngành**, kèm hai bảng lưu lựa chọn và backfill. Phase này chưa có lệnh ghi nào cho người dùng; chỉ có API đọc và context.

## Registry module

`server/app/services/spree/pos/modules.rb`, module `Spree::Pos::Modules`:

```ruby
Definition = Data.define(:key, :group, :depends_on, :status)   # status: available | planned

register(key: 'retail.units',        group: 'retail', depends_on: [])
register(key: 'retail.measured',     group: 'retail', depends_on: ['retail.units'])
register(key: 'retail.traceability', group: 'retail', depends_on: [])

# Chỉ khai báo tên để hồ sơ "Sắp hỗ trợ" tham chiếu được; không có code, không bật được.
planned 'fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.recipes', 'resources', 'fnb.tables',
        'fnb.postpay', 'fnb.service_charge', 'timed_billing'
```

- Đăng ký trong `server/config/initializers/pos_modules.rb`. Registry bị đóng băng sau khi boot.
- `Modules.available` / `Modules.known?(key)` / `Modules.fetch!(key)` (key lạ → `Conflict reason: 'module_unknown'`).
- Thứ tự `depends_on` được kiểm khi boot: vòng lặp hoặc phụ thuộc vào module `planned` → raise.

## Danh mục hồ sơ ngành

`server/config/pos/business_profiles.yml` (`version: 1`), nạp bởi `Spree::Pos::BusinessProfiles`. Mỗi hồ sơ:

```yaml
nha_thuoc:
  group: retail                 # retail | fnb
  order: 6
  modules: [retail.units, retail.traceability]
  branch_defaults: { return_window_days: 7, lot_selection: fefo }
  display: { catalog_view: list }        # cards | list
  recommended_features: [traceability, returns, refunds]
  sample_units: [vien, vi, hop, chai]    # mã trong UnitDefinition; phải thuộc dimension count/mass/volume
```

- `status` được tính, không ghi tay: `available` khi mọi module đã `available`, ngược lại `coming_soon`.
- Nhãn hiển thị không nằm trong YAML. Client dịch theo key (`profiles.nha_thuoc.label`, `.description`). Sau này app dùng bộ dịch của nó.
- Validate khi boot và trong spec: key `[a-z_]{2,40}`; module đã đăng ký; `branch_defaults` chỉ gồm `return_window_days | lot_selection | variance_threshold | adjustment_approval_threshold` và giá trị qua được validation của `Branch`; `recommended_features` thuộc `FeatureFlag::FEATURES`; `sample_units` đã định nghĩa.
- `sample_units` mở rộng `UnitDefinition.ensure_defaults!`: thêm bảng đơn vị mẫu `server/config/pos/sample_units.yml`, gồm viên, vỉ, hộp, bao, tấm, cây, quyển, ram, bộ, bó, giỏ… (đều dimension `count`). Đơn vị chỉ được tạo khi áp hồ sơ, không tạo cho mọi store.

### Hồ sơ: đề xuất, cần duyệt trước phase 4

| Key | Nhóm | Module | View | Hạn trả | Chọn lô | Cờ "thường dùng" | Đơn vị mẫu |
|---|---|---|---|---|---|---|---|
| `tap_hoa_sieu_thi` | retail | units, measured, traceability | list | 7 | fefo | credit, vietqr, customer_display | lốc, thùng, kg |
| `thoi_trang` | retail | — | cards | 7 | — | returns, refunds, exchanges, vietqr | — |
| `dien_tu_dien_may` | retail | traceability | cards | 7 | — | traceability, returns, refunds, exchanges, credit | — |
| `vat_lieu_xay_dung` | retail | units | list | 7 | — | credit, vietqr | bao, tấm, cây, xe |
| `nong_san_thuc_pham` | retail | units, measured, traceability | cards | 1 | fefo | vietqr | kg |
| `nha_thuoc` | retail | units, traceability | list | 7 | fefo | traceability, returns, refunds | viên, vỉ, hộp, chai |
| `xe_may_moc` | retail | traceability | list | 7 | — | traceability, credit | bộ |
| `my_pham` | retail | traceability | cards | 7 | fefo | returns, exchanges | — |
| `noi_that_gia_dung` | retail | units | cards | 7 | — | credit | bộ |
| `me_be` | retail | units, traceability | cards | 7 | fefo | returns, exchanges | hộp, lốc, thùng |
| `sach_van_phong_pham` | retail | units | list | 7 | — | credit | quyển, ram, hộp |
| `hoa_qua_tang` | retail | — | cards | — | — | vietqr | bó, giỏ |
| `khac` | retail | units, measured, traceability | cards | — | — | — | — |
| `quan_an` | fnb | fnb.menu, fnb.kitchen | — | — | — | — | — |
| `cafe_tra_sua` | fnb | fnb.menu, fnb.kitchen, fnb.order_number | — | — | — | — | — |
| `karaoke_bida` | fnb | resources, timed_billing, fnb.menu, fnb.postpay | — | — | — | — | — |
| `bar_pub_club` | fnb | fnb.menu, fnb.kitchen, fnb.postpay, fnb.service_charge | — | — | — | — | — |
| `cang_tin_tram_dung` | fnb | fnb.menu, fnb.kitchen, fnb.order_number, retail.units | — | — | — | — | — |
| `nha_hang` | fnb | fnb.menu, fnb.kitchen, resources, fnb.tables, fnb.postpay, fnb.service_charge | — | — | — | — | — |

"—" ở cột hạn trả nghĩa là để trống: chi nhánh không nhận trả hàng cho tới khi quản lý đặt số ngày (giống hiện tại).

## Dữ liệu

`spree_pos_store_profiles` — prefix `posstoreprof`
- `store_id` (FK, unique, not null), `profile_key` (not null), `profile_version` (int), `wholesale` (bool, default false; chỉ ghi nhận, module `wholesale` làm sau), `interests` (string[], hồ sơ `coming_soon` đã chọn), `onboarded_at`, `changed_by_id`, timestamps.

`spree_pos_branches` — thêm `profile_key` (string, not null, default `'khac'`) và `profile_version` (int, default 1).

`spree_pos_branch_modules` — prefix `posbranchmod`
- `store_id`, `branch_id` (FK, not null), `module_key` (not null), `enabled` (bool, not null), `reason` (≤ 200), `changed_by_id`, timestamps.
- Unique `(branch_id, module_key)`. Không có dòng nghĩa là **tắt**.
- Validate cùng store; `module_key` phải `available`.

Migration `*_create_spree_pos_business_profiles.rb`:
- Tạo hai bảng và thêm hai cột ở branches.
- Backfill: mọi chi nhánh đã có → `profile_key = 'khac'`, mỗi chi nhánh ba dòng `branch_modules` `enabled = true`, `reason = 'backfill'`.
- Store đã có chi nhánh → một dòng `store_profiles` với `profile_key = 'khac'`, `onboarded_at = created_at` của chi nhánh đầu tiên, để store cũ không thấy wizard.
- Dùng SQL thuần trong migration, không gọi model.

## Model / service

- `Spree::Pos::StoreProfile`, `Spree::Pos::BranchModule` (giống `FeatureFlag`: `belongs_to`, `same_store`, `to_pos`).
- `Spree::Pos::ModulePolicy`:
  - `enabled?(branch, key)`;
  - `for_branch(branch)` → `{ 'retail.units' => true, … }` gồm mọi module `available`;
  - `store_enabled?(store, key)` = bật ở ít nhất một chi nhánh active;
  - `require!(branch, key)` / `require_store!(store, key)` → `Conflict reason: 'module_disabled', details: { module: key }`.
- `Branch#to_pos` thêm `profile_key`, `profile_version`.

## API (chỉ đọc)

| Method | Path | Quyền | Trả về |
|---|---|---|---|
| GET | `/api/v3/admin/pos/business_profiles` | như `context#show` | `{ version, modules: [{key, group, status, depends_on}], profiles: [{key, group, order, status, modules, branch_defaults, display, recommended_features, sample_units}] }` |
| GET | `/api/v3/admin/pos/store_profile` | `read_pos_topology` hoặc `write_pos_topology` | Dòng store profile, hoặc `null` nếu chưa thiết lập |

`ContextResolver#call` thêm:
- `modules: ModulePolicy.for_branch(branch)`; khi chưa chọn chi nhánh thì `{}`;
- `profile: { key, version, display }` của chi nhánh đang chọn;
- `onboarding: { required: store chưa có store_profile && không có chi nhánh active, can_setup: write_pos_topology }`.

## Files

| Action | Path |
|---|---|
| create | `server/app/services/spree/pos/modules.rb`, `business_profiles.rb`, `module_policy.rb` |
| create | `server/config/initializers/pos_modules.rb` |
| create | `server/config/pos/business_profiles.yml`, `server/config/pos/sample_units.yml` |
| create | `server/db/migrate/*_create_spree_pos_business_profiles.rb` |
| create | `server/app/models/spree/pos/store_profile.rb`, `branch_module.rb` |
| modify | `server/app/models/spree/pos/branch.rb` (`to_pos`), `unit_definition.rb` (`ensure_samples!(store, codes)`) |
| modify | `server/app/services/spree/pos/context_resolver.rb` |
| create | `server/app/controllers/spree/api/v3/admin/pos/business_profiles_controller.rb`, `store_profiles_controller.rb` |
| modify | `server/config/routes.rb` |
| create | `server/spec/services/spree/pos/business_profiles_spec.rb`, `module_policy_spec.rb`, `server/spec/requests/spree/pos/business_profiles_spec.rb`, `server/spec/migrations/…` (hoặc spec backfill trong `topology_spec.rb`) |

## Success Criteria

- [x] `pnpm spree migrate` chạy sạch. Chi nhánh đã có → `khac` + ba module bật; store có chi nhánh → có `store_profiles`.
- [x] YAML sai (module lạ, default không hợp lệ, cờ lạ, đơn vị lạ) → spec `business_profiles_spec` fail với thông báo chỉ đúng chỗ.
- [x] `GET /pos/business_profiles` trả 19 hồ sơ: 13 `available`, 6 `coming_soon`.
- [x] `GET /pos/context` có `modules`, `profile`, `onboarding`. Toàn bộ spec context / topology hiện có vẫn pass.
- [x] Store khác không đọc được store profile; cashier không có quyền topology vẫn đọc được danh mục hồ sơ, không đọc được store profile (403). Xem "Khác với plan" về mã 404.

## Kết quả (08/11/2026)

Đã làm:
- Registry `Spree::Pos::Modules` (`server/app/services/spree/pos/modules.rb`): `define!` kiểm đồ thị phụ thuộc (key sai dạng, phụ thuộc module lạ, phụ thuộc module `planned`, vòng lặp → `Modules::Invalid` nêu tên module) rồi đóng băng. `available`, `available_keys`, `known?`, `available?`, `find`, `fetch!` (key lạ → `Conflict reason: 'module_unknown'`). Đăng ký trong `config/initializers/pos_modules.rb` bằng `config.to_prepare`, nên chạy lại sau mỗi lần reload code ở development.
- `Spree::Pos::BusinessProfiles` nạp `server/config/pos/business_profiles.yml` (`version: 1`, 19 hồ sơ đúng bảng đã duyệt), validate khi boot (cùng `to_prepare`). `errors_for(hash)` trả danh sách lỗi dạng `<key>.<field>: …` để spec kiểm catalog sai mà không sửa file; `build` raise `BusinessProfiles::Invalid` gồm mọi lỗi. Kiểm thêm: field lạ, `order` trùng, module thiếu phụ thuộc trong cùng hồ sơ (`retail.measured` cần `retail.units`). `status` tính từ registry. Validate không chạm DB (dùng hằng số chung với `Branch`: `LOT_SELECTIONS`, `RETURN_WINDOW_DAYS`, `PROFILE_KEY_FORMAT`), nên boot trên DB trống vẫn được; spec đối chiếu thêm từng `branch_defaults` với validation thật của `Branch`.
- Đơn vị mẫu `server/config/pos/sample_units.yml` và `UnitDefinition.ensure_samples!(store, codes)`: tạo đơn vị được nêu cùng đơn vị gốc của nó (ví dụ `pack` kéo theo `chai`), đơn vị đã có thì giữ nguyên, gọi lại không tạo thêm, mã lạ → `ArgumentError`. `ensure_defaults!` giữ nguyên hành vi (8 đơn vị như cũ, chuyển sang hằng `DEFAULTS`).
- Migration `20261108183000_create_spree_pos_business_profiles`: bảng `spree_pos_store_profiles` (unique `store_id`, FK store và admin user, `interests` string[]), `spree_pos_branch_modules` (unique `(branch_id, module_key)`, FK store, chi nhánh, admin user, `reason` ≤ 200), cột `profile_key` (≤ 40, not null, default `khac`) và `profile_version` (not null, default 1, check ≥ 1) ở `spree_pos_branches`. Backfill bằng SQL thuần, idempotent (`CreateSpreePosBusinessProfiles.backfill_sql`). `down` xóa hai bảng và hai cột.
- Model `StoreProfile` (prefix `posstoreprof`), `BranchModule` (prefix `posbranchmod`; chỉ nhận module `available`, cùng store). `Branch#to_pos` thêm `profile_key`, `profile_version`.
- `ModulePolicy`: `for_branch` (một query, mọi module `available`; `{}` khi không có chi nhánh), `enabled?`, `store_enabled?` (chỉ tính chi nhánh active của store), `require!`, `require_store!` → `Conflict reason: 'module_disabled', details: { module: key }`. Chưa gắn vào controller nào (phase 2).
- API: `GET /api/v3/admin/pos/business_profiles` (quyền như context: `read_pos_orders | read_pos_topology | write_pos_topology`) và `GET /api/v3/admin/pos/store_profile` (`read_pos_topology | write_pos_topology`). `ContextResolver#call` thêm `modules`, `profile: { key, version, display }` (null khi chưa chọn chi nhánh; key không còn trong danh mục thì trả `display: {}`), `onboarding: { required, can_setup }`.

Khác với plan:
- Chọn lô: giá trị hợp lệ chỉ có `fefo | cashier_pick`, cột not null default `fefo`, không có giá trị "chưa đặt". Ô "—" ở cột chọn lô (thoi_trang, dien_tu_dien_may, vat_lieu_xay_dung, xe_may_moc, noi_that_gia_dung, sach_van_phong_pham, hoa_qua_tang, khac) → **bỏ field** khỏi `branch_defaults`: hồ sơ không có ý kiến, chi nhánh mới giữ default cột (`fefo`), đổi hồ sơ không đề xuất gì.
- Hạn trả "—" (hoa_qua_tang, khac): cũng **bỏ field**, không ghi `return_window_days: null`. Chi nhánh mới vẫn không nhận trả hàng (cột mặc định null), nhưng đổi hồ sơ sẽ không đề xuất tắt trả hàng của chi nhánh đang có.
- Mã đơn vị: lốc = `pack`, thùng = `case`, kg = `kg`, chai = `chai` (đơn vị mặc định); mới: `vien` Viên, `vi` Vỉ, `hop` Hộp, `bao` Bao, `tam` Tấm, `cay` Cây, `xe` Xe, `quyen` Quyển, `ram` Ram, `bo` Bộ, `bo_hoa` Bó, `gio` Giỏ. Đều dimension `count`, `base_code` = chính nó, hệ số 1, precision 0.
- Mọi `recommended_features` của bảng đều có trong `FeatureFlag::FEATURES`; không phải bỏ cờ nào.
- Prefix `posstoreprof`, `posbranchmod` giữ nguyên (Spree chỉ yêu cầu `[a-z]+`, không giới hạn độ dài).
- YAML có khóa `profiles:` dưới `version:` (thay vì hồ sơ ở cấp đầu). Hồ sơ F&B có `display: {}`. Module `planned` thuộc group `fnb` (gồm cả `resources`, `timed_billing`).
- API bọc trong `data` như các endpoint POS khác: `{ data: { version, modules, profiles } }`, `{ data: <store profile> | null }`.
- `store_profile` là resource số ít theo store hiện tại, không có id, nên không có đường nào trả 404 cho bản ghi của store khác: store chưa thiết lập nhận `null` (không bao giờ thấy dòng của store khác), staff của store khác nhận 403. Spec khẳng định cả hai.
- `Branch` thêm validation `lot_selection` (inclusion), `adjustment_approval_threshold` (số nguyên ≥ 0), `profile_key`, `profile_version`. Trước đây hai field đầu chỉ có check constraint ở DB.
- `spec/requests/spree/pos/authentication_spec.rb`: danh sách key của context thêm `modules`, `profile`, `onboarding`.
- Spec backfill ở `server/spec/migrations/create_spree_pos_business_profiles_spec.rb`, chạy chính SQL của migration trên dữ liệu spec tạo.

Kiểm thử:
- `pnpm spree migrate`: sạch. DB dev: 8 chi nhánh → `khac`, 24 dòng module (`enabled`, `backfill`), 1 store profile với `onboarded_at` = `created_at` của chi nhánh đầu tiên. `pnpm spree migrate:rollback` rồi `pnpm spree migrate`: chạy được; sau rollback `db/schema.rb` trùng HEAD, sau migrate lại diff chỉ gồm hai bảng, hai cột, check constraint và FK mới.
- `pnpm spree rails db:test:prepare` để nạp schema mới vào DB test.
- `pnpm spree rspec spec/services/spree/pos/business_profiles_spec.rb spec/services/spree/pos/module_policy_spec.rb spec/migrations/create_spree_pos_business_profiles_spec.rb spec/requests/spree/pos/business_profiles_spec.rb spec/requests/spree/pos/authentication_spec.rb`: 42 examples, 0 failures.
- `pnpm spree rspec spec/requests/spree/pos/topology_spec.rb spec/requests/spree/pos/topology_access_spec.rb spec/requests/spree/pos/branch_only_sessions_spec.rb spec/requests/spree/pos/feature_flags_spec.rb spec/requests/spree/pos/sale_lines_spec.rb spec/requests/spree/pos/scale_labels_spec.rb spec/requests/spree/pos/traceability_spec.rb`: 59 examples, 0 failures.
- `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/migrations/`: 268 examples, 0 failures (seed 57896). Hai lần chạy trước đó bị chồng lên nhau trên cùng DB test và cùng fail 1 example `operational_metrics_spec.rb:27` (`lock_waits.waiting` = 1, đếm session đang chờ khóa trong `pg_stat_activity`); chạy riêng file đó và chạy lại toàn bộ một mình đều pass.
- `pnpm spree rspec spec/workflows/spree/pos/`: 154 examples, 0 failures.
- Sau khi thêm initializer đã chạy `pnpm spree restart` để server dev nạp registry.

Còn lại cho phase 2:
- Chưa có lệnh ghi nào: onboarding, `Branches::Create`, đổi hồ sơ, bật/tắt module, audit `branch_profile.change` / `branch_module.change` / `store_profile.change`.
- `ModulePolicy.require!` chưa gắn vào units, label formats, nhập tồn.
- Chi nhánh tạo bằng `POST /branches` sau migration này nhận `profile_key = 'khac'` nhưng **không có dòng module** (tức module tắt). Phase 1 chưa chặn gì nên chưa ảnh hưởng, nhưng phase 2 phải ghi module khi tạo chi nhánh trước khi bật chặn, và xử lý các chi nhánh tạo trong khoảng giữa (chạy lại `backfill_sql` hoặc cho `khac`).
- Chi nhánh tạo trong spec cũng không có dòng module. Khi phase 2 bật chặn, spec cũ cấu hình SKU / mẫu tem / nhập tồn cần bật module (ví dụ hook giống `pos_feature_helpers.rb`).
- Chưa chạy `spec/integration/spree/pos/` (race spec).
