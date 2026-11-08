---
phase: 2
title: "Áp hồ sơ, bật/tắt module, chặn lệnh thiết lập"
status: completed
effort: "2 ngày"
dependsOn: [1]
---

# Phase 2: Áp hồ sơ, bật/tắt module, chặn lệnh thiết lập

## Overview

Các lệnh ghi:
- thiết lập ban đầu (onboarding);
- tạo chi nhánh kèm hồ sơ;
- đổi hồ sơ (có diff);
- bật/tắt từng module.

Thêm `ModulePolicy.require!` vào **các lệnh thiết lập mới**, theo đúng ngữ nghĩa của `FeaturePolicy` (D5): tắt chỉ chặn việc mới, mọi đường bán và xử lý dở dang vẫn mở.

## Workflow

### `Spree::Pos::Branches::Create` (mới)

Tách logic tạo chi nhánh hiện ở `BranchesController#create` ra một workflow, để wizard và trang cấu hình dùng chung. Workflow nhận thêm `profile_key` (mặc định là hồ sơ của store, nếu không có thì `khac`), rồi trong một transaction:
1. Từ chối hồ sơ `coming_soon` (`Conflict reason: 'profile_unavailable'`).
2. Tạo `Branch`. Lấy `branch_defaults` của hồ sơ cho các field request không gửi; field request đã gửi thì giữ nguyên.
3. Ghi `branch_modules` = các module của hồ sơ, `reason = "profile:<key>"`.
4. `UnitDefinition.ensure_samples!(store, profile.sample_units)`.
5. Audit `branch.create`, metadata có `profile_key`.

`POST /branches` giữ nguyên hợp đồng cũ, chỉ thêm tham số tùy chọn `profile_key`.

### `Spree::Pos::Onboarding::Setup` (mới)

`POST /api/v3/admin/pos/onboarding`, cần quyền `write_pos_topology`. Body:

```jsonc
{
  "key": "<uuid idempotency>",
  "profile_key": "nha_thuoc",
  "wholesale": false,
  "interests": ["cafe_tra_sua"],          // chỉ nhận hồ sơ coming_soon
  "branch": { "name": "...", "code": "...", "timezone": "Asia/Ho_Chi_Minh",
              "stock_location_id": "sloc_…", "return_window_days": 7, "lot_selection": "fefo" },
  "register": { "name": "Quầy 1" },        // tùy chọn
  "grant_self": true,                       // membership toàn quyền cho người tạo
  "features": ["traceability", "returns"]   // chỉ các cờ người dùng tự tick (D6)
}
```

- Chỉ chạy khi `onboarding.required`. Store đã có store_profile → 409 `already_onboarded`. Muốn đổi về sau thì dùng trang Mô hình kinh doanh.
- Idempotency: dùng `CommandExecutor.call(store:, actor:, key:, payload:, authorize:)` **không có workspace**; tham số `workspace` vốn đã là tùy chọn (`command_executor.rb:13`). Cùng key, khác payload → 409 như các lệnh khác. Cùng key, cùng payload → trả lại kết quả cũ, không tạo thêm.
- Trong một transaction:
  1. Tạo `StoreProfile`.
  2. Gọi `Branches::Create`.
  3. Tạo register nếu có (dùng logic tạo quầy hiện có).
  4. Nếu `grant_self`, tạo membership với mọi `Capabilities::ASSIGNABLE`.
  5. Với mỗi cờ trong `features`, gọi `FeaturePolicy.set!(…, reason: "Thiết lập theo ngành: <key>")`.
- Trả về `{ store_profile, branch, register, features }`. Client sau đó chọn chi nhánh mới làm context.

### `Spree::Pos::Profiles::Preview` / `Apply`

- `POST /branches/:id/profile/preview { profile_key }` trả về:

  ```jsonc
  { "modules": { "enable": ["retail.measured"], "disable": ["retail.traceability"],
                 "in_use": { "retail.traceability": { "tracked_variants": 12, "open_lots": 30 } } },
    "defaults": [ { "field": "lot_selection", "current": "cashier_pick", "profile": "fefo" } ],
    "sample_units": ["vien", "vi"], "recommended_features": ["traceability"] }
  ```

  `in_use` chỉ là cảnh báo. Tắt vẫn được (D5), và UI phải nói rõ: "Việc bán SKU đã cấu hình không đổi; chỉ ẩn màn cấu hình."
- `PUT /branches/:id/profile { profile_key, expected_profile_key, apply_modules: true, apply_defaults: ["lot_selection"], reason }`
  - `expected_profile_key` lệch → 409 `profile_conflict`.
  - Chỉ áp những default có tên trong `apply_defaults` (D7).
  - Lock chi nhánh; audit `branch_profile.change` gồm from / to, danh sách module đã đổi, default đã áp.
- Đổi hồ sơ chính của store: `PUT /store_profile { profile_key, wholesale, interests, reason }`. Lệnh này chỉ đổi mặc định cho chi nhánh **mới**, không động vào chi nhánh đã có.

### `Spree::Pos::BranchModules::Set`

- `PUT /branches/:id/modules/:key { enabled, reason }`. Lý do bắt buộc, tối đa 200 ký tự.
- Quyền: `write_pos_topology`, hoặc `pos.topology.manage` tại chính chi nhánh đó. Bật module không mở ra rủi ro tiền, nên quản lý chi nhánh cũng tự bật được, khác với `FeatureFlag`.
- Bật module thì bật luôn các `depends_on` (trả về danh sách đã bật thêm). Tắt module mà có module khác đang bật phụ thuộc vào nó → 409 `module_required_by`.
- Chỉ audit khi có thay đổi (`branch_module.change`).

## Chặn lệnh thiết lập mới (D5)

| Lệnh | Điều kiện thêm | Module |
|---|---|---|
| `PUT /pos/units/variant`, khi đổi `tracked_mode` sang khác `none` | `ModulePolicy.require!(branch, 'retail.traceability')`, chạy cùng `FeaturePolicy.require_store!(:traceability)` đang có (`units_controller.rb:70`) | traceability |
| `PUT /pos/units/variant`, khi đổi sang đơn vị bán có tỷ lệ ≠ 1, hoặc đơn vị bán khác đơn vị gốc | `require!(branch, 'retail.units')`; chỉ khi **thay đổi** so với bản ghi hiện tại | units |
| `PUT /pos/units/variant`, khi đặt `label_code` mới hoặc chuyển sang bán theo khối lượng / thể tích lẻ | `require!(branch, 'retail.measured')` | measured |
| `POST/PATCH /branches/:id/label_formats` | `require!(branch, 'retail.measured')` | measured |
| `POST /pos/inventory/opening_balances`, `POST /pos/inventory/receipts` | `require!(branch, 'retail.traceability')`, cạnh `FeaturePolicy.require!` (`inventory/open_balance.rb:21`) | traceability |

**Không** chặn:
- thêm hàng vào đơn, quét tem cân, chọn lô / serial, tender, complete, trả hàng;
- chuyển kho, kiểm kê, cách ly, tra cứu, thu hồi;
- đọc dữ liệu, sửa cấu hình SKU về `none` / về đơn vị gốc;
- replay một lệnh đã chạy.

Lý do: sửa cấu hình về `none` hoặc về đơn vị gốc là thu hẹp, không mở thêm.

Thứ tự trong lệnh: chặn sau khi executor đã loại trường hợp replay, trước mọi thao tác ghi; giống chỗ đang gọi `FeaturePolicy.require!`.

## Files

| Action | Path |
|---|---|
| create | `server/app/workflows/spree/pos/branches/create.rb`, `onboarding/setup.rb`, `profiles/preview.rb`, `profiles/apply.rb`, `branch_modules/set.rb` |
| modify | `server/app/controllers/spree/api/v3/admin/pos/branches_controller.rb` (`create` gọi workflow; action `profile_preview`, `profile`) |
| create | `server/app/controllers/spree/api/v3/admin/pos/onboarding_controller.rb`, `branch_modules_controller.rb` |
| modify | `server/app/controllers/spree/api/v3/admin/pos/store_profiles_controller.rb` (`update`) |
| modify | `server/app/controllers/spree/api/v3/admin/pos/units_controller.rb`, `label_formats_controller.rb`, `server/app/workflows/spree/pos/inventory/open_balance.rb`, `receive_traceability.rb` |
| modify | `server/config/routes.rb` |
| create | `server/spec/requests/spree/pos/onboarding_spec.rb`, `branch_modules_spec.rb`, `branch_profiles_spec.rb` |
| modify | `server/spec/requests/spree/pos/topology_spec.rb`, `traceability_spec.rb`, `scale_labels_spec.rb` |

## Success Criteria

- [x] Onboarding tạo đủ store profile, chi nhánh, module, quầy, membership và cờ trong một transaction. Retry cùng key không tạo trùng; khác payload → 409. Gọi lần hai sau khi đã thiết lập → 409 `already_onboarded`.
- [x] Hồ sơ `coming_soon` → 409 `profile_unavailable`; được ghi vào `interests` khi gửi qua trường đó.
- [x] Cờ rủi ro chỉ bật khi có tên trong `features`; mỗi cờ có audit `feature_flag.change` với lý do đúng.
- [x] `POST /branches` không có `profile_key` vẫn hoạt động y như cũ (spec topology hiện có pass), và chi nhánh nhận hồ sơ chính của store.
- [x] Preview trả đúng diff; Apply chỉ áp những default được chọn; `expected_profile_key` lệch → 409.
- [x] Tắt `retail.traceability` ở chi nhánh A: lệnh nhập tồn đầu kỳ và đổi SKU sang tracked → 409 `module_disabled`. **Bán, thu tiền, hoàn tất, trả hàng một SKU tracked đã có tồn vẫn pass**; spec sale có serial / lô chạy lại trên chi nhánh đã tắt module.
- [x] Tắt `retail.measured`: quét tem cân của SKU đã cấu hình vẫn bán được; tạo hoặc sửa mẫu tem → 409.
- [x] Bật `retail.measured` thì tự bật `retail.units`; tắt `retail.units` khi `measured` còn bật → 409 `module_required_by`.
- [x] Quản lý chi nhánh (`pos.topology.manage`) bật / tắt được module của chi nhánh mình, không làm được ở chi nhánh khác (403).

## Kết quả (08/11/2026)

Đã làm:
- `Spree::Pos::Branches::Create` (`server/app/workflows/spree/pos/branches/create.rb`): hồ sơ mặc định là hồ sơ của store; store chưa có hoặc key của store không còn trong danh mục thì dùng `khac`. Key do request gửi phải có trong danh mục (`profile_unknown`) và `available` (`profile_unavailable`). Trong một transaction: tạo chi nhánh với `branch_defaults` của hồ sơ cho các field request không gửi (field đã gửi, kể cả `null`, giữ nguyên), `profile_version = BusinessProfiles.version`, ghi các module của hồ sơ (`reason = "profile:<key>"`, `changed_by` là người tạo), `UnitDefinition.ensure_samples!`, rồi audit `branch.create` với metadata `{ profile_key, profile_version, modules, defaults }`. `POST /branches` gọi workflow này; tham số `profile_key` là tùy chọn.
- `Spree::Pos::Branches::Attributes`: phần đọc tham số chi nhánh tách khỏi `BranchesController` (create, update và onboarding dùng chung), hành vi như cũ: stock location của store khác → 404, `lot_selection` / ngưỡng điều chỉnh sai → 409.
- `Spree::Pos::Onboarding::Setup` + `POST /api/v3/admin/pos/onboarding` (`write_pos_topology`): chạy qua `CommandExecutor` không có workspace. Trong block (tức là sau khi đã loại replay), workflow khóa dòng store, rồi từ chối khi store đã có store profile **hoặc** đã có chi nhánh active (`already_onboarded`, đúng nghĩa `onboarding.required`). Sau đó lần lượt tạo `StoreProfile` (audit `store_profile.change`, `from: null`, `reason: 'onboarding'`), gọi `Branches::Create`, tạo quầy, tạo membership và bật cờ. Quầy được tạo bằng record và audit (`register.create`) giống `POST /registers`. Membership được tạo bằng record và audit (`membership.create`) giống `POST /memberships`, với mọi `Capabilities::ASSIGNABLE`. Mỗi cờ trong `features` đi qua `FeaturePolicy.set!` với lý do `"Thiết lập theo ngành: <key>"`. Một bước lỗi thì không ghi gì.
- `Spree::Pos::Profiles::Preview` / `Apply` + `POST /branches/:id/profile/preview`, `PUT /branches/:id/profile`. Apply khóa dòng chi nhánh (`branch.lock!`, như `PUT /branches/:id`), kiểm `expected_profile_key` sau khi đã khóa, chỉ áp `apply_defaults` đã chọn, chỉ đổi module khi `apply_modules: true` (đặt đúng bằng module của hồ sơ). Apply tạo đơn vị mẫu còn thiếu, audit `branch_profile.change` (from, to, module đã bật/tắt, default đã áp, đơn vị mẫu đã thêm, lý do), và audit thêm `branch_module.change` cho từng module đổi.
- `Spree::Pos::Profiles::UpdateStore` + `PUT /store_profile` (`write_pos_topology`): chỉ đổi mặc định cho chi nhánh mới, không chạm chi nhánh đã có. Audit `store_profile.change` chỉ khi có thay đổi.
- `Spree::Pos::BranchModules::Set` + `PUT /branches/:id/modules/:key`: bật thì bật cả `depends_on` (đệ quy) và trả danh sách `also_enabled`. Tắt mà module khác đang bật cần nó → 409 `module_required_by`. Khóa dòng chi nhánh. Audit `branch_module.change` cho từng module thực sự đổi (module bật kèm có `required_by`); gọi lặp không ghi gì. Quyền: `write_pos_topology` hoặc `pos.topology.manage` tại chính chi nhánh đó.
- Chặn thiết lập mới (D5), đặt cùng chỗ `FeaturePolicy` (sau khi loại replay, trước mọi thao tác ghi):
  - `PUT /units/variant`, `retail.traceability`: `tracked_mode` mới khác `none` và khác bản ghi.
  - `PUT /units/variant`, `retail.units`: cấu hình mới là quy đổi (đơn vị bán ≠ đơn vị gốc hoặc tỷ lệ ≠ 1:1) **và** khác bản ghi ở sale/base/price unit hoặc tỷ lệ (hoặc chưa có bản ghi).
  - `PUT /units/variant`, `retail.measured`: chuyển **vào** đơn vị bán `mass`/`volume` (bản ghi cũ không có hoặc là `count`), hoặc đặt `label_code` khác rỗng và khác bản ghi.
  - `POST` / `PATCH /branches/:id/label_formats` (`disable` không chặn), `retail.measured`.
  - `inventory/opening_balances` (cạnh `FeaturePolicy.require!`) và `inventory/receipts`, `retail.traceability`.
  - Không chạm `Tenders::Guard`, `workspaces/complete.rb`, `tenders/*`, `funds/*`, ca, công nợ, trả hàng.
- Migration dữ liệu `20261108210000_backfill_spree_pos_khac_branch_modules`: SQL thuần, idempotent. Chi nhánh `khac` không có dòng `branch_modules` nào nhận ba module bật, `reason = 'backfill'`. Chi nhánh đã có dòng hoặc thuộc hồ sơ khác giữ nguyên. `down` không làm gì (dữ liệu).
- Spec helper `server/spec/support/pos_module_helpers.rb` (nạp trong `rails_helper.rb`).

Khác với plan:
- Idempotency key: dùng header `Idempotency-Key` hoặc `idempotency_key` trong body như mọi lệnh POS (`BaseController#idempotency_key`), không dùng field `key`. Thiếu key → 422 `parameter_invalid`.
- Kết quả onboarding thêm `membership` (null khi không `grant_self`) và `modules`. `features` là giá trị hiệu lực của **mọi** cờ tại chi nhánh mới (`FeaturePolicy.for_branch`). `grant_self` thiếu thì coi là `false`; client nên gửi `true` (ô tick sẵn).
- `register.code` là tùy chọn; mặc định `<29 ký tự đầu mã chi nhánh>-1`.
- `interests` chỉ nhận hồ sơ `coming_soon`. Hồ sơ `available` → 409 `interest_invalid`, key lạ → `profile_unknown`.
- Chặn `PUT /units/variant` theo module **của chi nhánh trong request** (`ModulePolicy.require!(branch, …)`), đúng bảng chặn của phase này, chứ không theo "bật ở ít nhất một chi nhánh active" như ở bảng rủi ro của `plan.md`. Lý do:
  - lệnh này đã cần chi nhánh và `pos.topology.manage` tại đó;
  - client ẩn màn cấu hình theo module của chi nhánh đang chọn;
  - với chi nhánh active, điều kiện chi nhánh đã bao gồm điều kiện cấp store.
- Định nghĩa "thiết lập mới" của `retail.measured` là chuyển **vào** bán theo khối lượng/thể tích. Đổi giữa hai đơn vị đo (kg → g) không cần `measured`, nhưng vẫn cần `units` nếu cấu hình mới là quy đổi. Xóa `label_code`, giữ nguyên cấu hình, về đơn vị gốc 1:1, về `none` đều không bị chặn.
- `PUT /branches/:id/profile`:
  - `reason` bắt buộc, tối đa 200 ký tự (`reason_required`, `reason_invalid`);
  - `apply_modules` mặc định `false`;
  - field trong `apply_defaults` mà hồ sơ đích không có default → 409 `default_invalid` (`details.fields`);
  - thiếu `expected_profile_key` cũng là lệch (409 `profile_conflict`, `details.current_profile_key`);
  - không qua `CommandExecutor` (giống các lệnh topology khác); retry sau khi đã áp sẽ nhận `profile_conflict`, client đọc lại rồi quyết.
- Preview thêm `branch_id`, `from`, `to`, `profile_version`.
  - `in_use` có một mục cho mỗi module sẽ tắt, kể cả khi đếm ra 0. Theo module: traceability `{ tracked_variants, open_lots, serials_in_stock }`; measured `{ measured_variants, labelled_variants, label_formats }`; units `{ converted_variants }`. Phạm vi đếm là SKU thuộc danh mục của chi nhánh và kho của chi nhánh.
  - `sample_units` chỉ gồm đơn vị store chưa có.
  - `recommended_features` chỉ gồm cờ hồ sơ gợi ý đang **tắt** ở chi nhánh.
  - Quyền: `read_pos_topology` hoặc `write_pos_topology`.
- `PUT /store_profile`:
  - `reason` bắt buộc;
  - store chưa thiết lập (không store profile, không chi nhánh active) → 409 `onboarding_required`;
  - store đang chạy mà chưa có store profile (tạo chi nhánh trong khoảng giữa hai phase) thì được tạo store profile, `onboarded_at = now`;
  - `wholesale` không phải boolean → 409 `parameter_invalid`;
  - không gửi `wholesale` / `interests` thì giữ nguyên.
- `PUT /branches/:id/modules/:key`: module `planned` → 409 `module_unavailable`; `enabled` không phải boolean → `module_value_invalid`; lý do bắt buộc (`reason_required`, `reason_invalid`). Route nhận key có dấu chấm (`constraints: { id: %r{[^/]+} }`).
- Thêm `GET /branches/:id/modules` (không có trong plan) cho trang Mô hình kinh doanh: trả trạng thái và dòng cài đặt của một chi nhánh bất kỳ, không chỉ chi nhánh đang chọn trong context. Quyền: `read_pos_topology`, `write_pos_topology`, hoặc `pos.topology.manage` tại chi nhánh đó.
- `inventory/receipts` bị chặn đúng như plan. Hệ quả: chi nhánh tắt `retail.traceability` không nhận thêm hàng serial/lô qua POS cho SKU đã tracked, dù vẫn bán, chuyển kho, kiểm kê được. Xem "Còn mở".
- `CommandExecutor` ghi outcome `conflict` (không phải `feature_disabled`) cho `module_disabled`; không sửa executor.

Quyết định spec helper: **bật mặc định**. `Spree::Pos::Branch.after_create` (chỉ trong spec) ghi thẳng vào bảng các module của hồ sơ của chi nhánh (`khac` → cả ba), `reason = 'spec default'`, không audit. Example nói về chính các dòng module thì opt out bằng `pos_modules: :default`, giống `pos_features: :default`. `set_pos_module(branch, key, enabled)` để sắp xếp dữ liệu. Chọn cách này vì nó giữ nguyên mọi spec cũ cấu hình đơn vị / tem cân / tồn truy xuất trên chi nhánh tự dựng (traceability, scale labels, traceable inventory, integration…); opt in sẽ phải sửa hàng chục spec. Chỉ thêm metadata `pos_modules: :default` vào ba spec của phase 1 vốn tự tạo dòng module: `module_policy_spec.rb` và `create_spree_pos_business_profiles_spec.rb` (cấp describe), một example của `business_profiles_spec.rb`. `Branches::Create` dùng `find_or_initialize_by`, nên chạy được cả khi helper đã ghi dòng.

Kiểm thử:
- `pnpm spree migrate`: sạch; `db/schema.rb` chỉ đổi dòng version. DB dev: 8 chi nhánh đều đã có dòng module (24 dòng `backfill`), nên migration không chèn thêm dòng nào. `pnpm spree rails db:test:prepare` rồi mới chạy spec.
- Spec mới và spec đã sửa: `pnpm spree rspec spec/requests/spree/pos/onboarding_spec.rb spec/requests/spree/pos/branch_modules_spec.rb spec/requests/spree/pos/branch_profiles_spec.rb spec/requests/spree/pos/topology_spec.rb spec/requests/spree/pos/traceability_spec.rb spec/requests/spree/pos/scale_labels_spec.rb spec/requests/spree/pos/business_profiles_spec.rb spec/services/spree/pos/module_policy_spec.rb spec/migrations/ spec/workflows/spree/pos/unit_normalization_spec.rb`: 51 examples, 0 failures. Lần chạy đầu fail 1 example (spec tem cân mới thiếu payment method thủ công cho tiền mặt); đã thêm `check_payment_method` vào spec.
- `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/migrations/`: 284 examples, 0 failures (seed 14501; trước khi dọn rubocop cũng 284/0, seed 49573).
- `pnpm spree rspec spec/workflows/spree/pos/`: 154 examples, 0 failures.
- `pnpm spree rspec spec/integration/spree/pos/`: 88 examples, 0 failures.
- Rubocop trên file mới: còn `Metrics/ParameterLists` (keyword args, giống `OpenBalance`, `Credit::Configure`) và độ phức tạp của `Branches::Attributes.call` (chuyển nguyên từ controller). Các file cũ còn offense có từ trước (CRLF, dòng dài).

Cho phase 3/4 (mọi path dưới `/api/v3/admin/pos`, body JSON, kết quả bọc trong `data`, lỗi 409 có `error.details.reason`):
- `POST /onboarding`, header `Idempotency-Key`. Body:
  `{ profile_key, wholesale?, interests?: [coming_soon keys], branch: { name, code, timezone, stock_location_id, receiving_stock_location_id?, receiving_note?, return_window_days?, variance_threshold?, display_freshness_ttl_seconds?, lot_selection?, adjustment_approval_threshold? }, register?: { name, code? }, grant_self?: bool, features?: [feature] }`
  → 201 `{ store_profile, branch, register|null, membership|null, features: {feature: bool}, modules: {key: bool} }`. Replay cùng key và payload → cùng body.
  Lỗi:
  - 409: `already_onboarded`, `profile_unavailable`, `profile_unknown`, `interest_invalid`, `feature_unknown`, `parameter_invalid`; key dùng lại với payload khác (message `Idempotency key was reused with a different payload.`, không có reason).
  - 422: validation chi nhánh/quầy; thiếu key.
  - 404: stock location của store khác.
  - 403: thiếu `write_pos_topology`.
- `POST /branches`: như cũ, thêm `profile_key?`. Lỗi mới: 409 `profile_unavailable` / `profile_unknown`.
- `POST /branches/:id/profile/preview { profile_key }` → `{ branch_id, from, to, profile_version, modules: { enable: [], disable: [], in_use: { <key>: {counts} } }, defaults: [{ field, current, profile }], sample_units: [], recommended_features: [] }`.
- `PUT /branches/:id/profile { profile_key, expected_profile_key, reason, apply_modules?: bool, apply_defaults?: [field] }` → `{ branch, modules: {key: bool}, applied: { modules: { enabled: [], disabled: [] }, defaults: [{ field, from, to }], sample_units: [] } }`. Lỗi 409: `profile_conflict` (`details.current_profile_key`), `profile_unavailable`, `profile_unknown`, `default_invalid`, `reason_required`, `reason_invalid`. 403 nếu thiếu `write_pos_topology`.
- `GET /branches/:id/modules` → `{ branch_id, modules: {key: bool}, settings: [{ module, enabled, branch_id, reason, changed_by_id, changed_by_name, changed_at }] }`.
- `PUT /branches/:id/modules/:key { enabled: bool, reason }` → `{ branch_id, module, enabled, changed, also_enabled: [], modules: {key: bool} }`. Lỗi 409: `module_required_by` (`details.module`, `details.required_by`), `module_unknown`, `module_unavailable`, `module_value_invalid`, `reason_required`, `reason_invalid`. 403 ở chi nhánh không quản lý.
- `PUT /store_profile { profile_key, reason, wholesale?, interests? }` → store profile (`to_pos`). Lỗi 409: `onboarding_required`, `profile_unavailable`, `profile_unknown`, `interest_invalid`, `reason_required`, `parameter_invalid`.
- Lệnh thiết lập bị chặn trả 409 `{ reason: 'module_disabled', module: '<key>' }`. UI nên ẩn màn cấu hình theo `context.modules`, nhưng vẫn xử lý 409 này.

Còn mở:
- Nhận hàng truy xuất (`inventory/receipts`) bị chặn khi tắt `retail.traceability` (theo plan/D5). Chi nhánh tắt module mà vẫn còn SKU tracked sẽ không nhập thêm được hàng serial/lô cho SKU đó qua POS. Cần chốt lại: giữ chặn, hay chỉ chặn SKU chưa từng nhập ở chi nhánh.
- Chưa có spec chạy hai phiên onboarding đồng thời (race). Đã khóa dòng store, và `store_profiles.store_id` là unique, nhưng chưa có race spec hai connection.

