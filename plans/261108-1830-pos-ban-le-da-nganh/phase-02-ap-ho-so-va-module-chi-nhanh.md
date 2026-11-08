---
phase: 2
title: "Áp hồ sơ, bật/tắt module, chặn lệnh thiết lập"
status: pending
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

- [ ] Onboarding tạo đủ store profile, chi nhánh, module, quầy, membership và cờ trong một transaction. Retry cùng key không tạo trùng; khác payload → 409. Gọi lần hai sau khi đã thiết lập → 409 `already_onboarded`.
- [ ] Hồ sơ `coming_soon` → 409 `profile_unavailable`; được ghi vào `interests` khi gửi qua trường đó.
- [ ] Cờ rủi ro chỉ bật khi có tên trong `features`; mỗi cờ có audit `feature_flag.change` với lý do đúng.
- [ ] `POST /branches` không có `profile_key` vẫn hoạt động y như cũ (spec topology hiện có pass), và chi nhánh nhận hồ sơ chính của store.
- [ ] Preview trả đúng diff; Apply chỉ áp những default được chọn; `expected_profile_key` lệch → 409.
- [ ] Tắt `retail.traceability` ở chi nhánh A: lệnh nhập tồn đầu kỳ và đổi SKU sang tracked → 409 `module_disabled`. **Bán, thu tiền, hoàn tất, trả hàng một SKU tracked đã có tồn vẫn pass**; spec sale có serial / lô chạy lại trên chi nhánh đã tắt module.
- [ ] Tắt `retail.measured`: quét tem cân của SKU đã cấu hình vẫn bán được; tạo hoặc sửa mẫu tem → 409.
- [ ] Bật `retail.measured` thì tự bật `retail.units`; tắt `retail.units` khi `measured` còn bật → 409 `module_required_by`.
- [ ] Quản lý chi nhánh (`pos.topology.manage`) bật / tắt được module của chi nhánh mình, không làm được ở chi nhánh khác (403).
