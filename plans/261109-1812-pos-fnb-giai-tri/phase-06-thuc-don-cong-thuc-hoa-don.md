---
phase: 6
title: "Thực đơn, công thức, hóa đơn điện tử"
status: in-progress
effort: "20 ngày"
dependsOn: [1]
---

# Phase 6: Thực đơn, công thức, hóa đơn điện tử

## Overview

Ba phần chỉ cần nền đơn hàng, chạy ở server và web, và cùng làm việc trên món, giá, thuế và bước complete. Plan này không cần app Flutter.

| Phần | Nội dung | Effort |
|---|---|---|
| 6A | Thực đơn, modifier, combo | 8 ngày |
| 6B | Công thức và trừ kho | 5 ngày |
| 6C | Hóa đơn điện tử | 7 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 6A: Thực đơn, modifier, combo

### Overview

Phần này đưa module `fnb.menu` vào server và vào màn thu ngân web:
- Món là sản phẩm Spree, có thêm một bảng cấu hình phía POS. Size là variant.
- Modifier gồm size, đường, đá, topping, ghi chú, chia theo nhóm có min/max và có giá cộng thêm.
- Có combo, thực đơn theo khung giờ (giá giờ vàng) và báo hết món theo chi nhánh.
- Màn bán `menu_grid` gồm lưới món có ảnh và bảng tùy chọn hiện trên một màn.

**Server luôn tính giá dòng**: giá gốc (hoặc giá theo khung giờ) + Σ(số lượng × giá cộng của tùy chọn). Client không gửi giá.

Phase 1 đã có registry `SaleLineKinds`, `Workspace.service_mode`, `business_date` và thuế theo món qua `TaxCategory`. Phần này thêm kind `menu` vào registry đó.

### Quyết định

1. **Món = `Spree::Product`, size = `Spree::Variant`.** Cấu hình POS nằm ở `spree_pos_menu_items` (một dòng cho mỗi product mỗi store). Thuế suất theo món đọc từ `tax_category` của product mà phase 1 đã chuẩn hóa. Phần này chỉ cho chọn tax category trong màn sửa món.
2. **Modifier là dữ liệu POS, không phải variant Spree.** Một tùy chọn có thể trỏ tới một variant nguyên liệu (`variant_id`, không bắt buộc); phần 6B dùng trường này để trừ kho.
3. **Hai bộ tùy chọn khác nhau là hai dòng.** `SaleLine.build_merge_key` có thêm phần `modifier_signature`, là SHA-256 của danh sách `option_id:quantity` đã sắp xếp cộng ghi chú đã chuẩn hóa. Phần này chỉ được nối vào khi có, để key của dòng bán lẻ cũ giữ nguyên (cùng cách đang làm với `expiry_on`).
4. **Combo là một món có `kind = combo`.** Giá nằm ở dòng combo; thành phần lưu snapshot ở `spree_pos_line_components` và không tạo `LineItem` riêng. Cờ `show_components_on_kds` quyết định phiếu bếp (phần 7A) in món con hay chỉ in tên combo.
5. **Giữ D5 của plan bán lẻ: module không chặn việc bán.** Chi nhánh tắt `fnb.menu` vẫn bán được món như dòng `ordinary` với giá gốc. Chỉ lệnh gắn tùy chọn bị từ chối (`module_disabled`).
6. **Hết món** lưu theo chi nhánh và tự hết hạn ở cuối `business_date`. Thêm món đang hết bị từ chối (`Conflict reason: 'menu_item_sold_out'`) và phát `menu.sold_out` qua `BranchChannel`.
7. **Giá theo khung giờ** được chọn ở thời điểm thêm dòng, theo `Workspace.database_now` và `timezone` của chi nhánh. Dòng đã thêm giữ giá cũ, kể cả khi khung giờ đã qua.

### Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_menu_categories` | `store_id`, `name`, `position`, `color`, `active` | unique `(store_id, name)` |
| `spree_pos_menu_items` | `store_id`, `product_id`, `menu_category_id`, `kind` (`single`/`combo`), `kitchen_category` (key `[a-z_]{2,40}`, phần 7A dùng để định tuyến), `cup_label` (bool, phần 7B), `show_components_on_kds` (bool), `position`, `active` | unique `(store_id, product_id)`; check `kind` |
| `spree_pos_modifier_groups` | `store_id`, `name`, `min_select` (≥ 0), `max_select` (≥ 1), `allow_quantity` (topping ×2), `position` | check `min_select <= max_select` |
| `spree_pos_modifier_options` | `modifier_group_id`, `name`, `price_delta` decimal(10,2) ≥ 0, `variant_id` (nullable), `default_selected`, `position`, `active` | |
| `spree_pos_menu_item_modifier_groups` | `menu_item_id`, `modifier_group_id`, `position` | unique cặp |
| `spree_pos_combo_components` | `menu_item_id` (combo), `variant_id`, `quantity` | check `quantity > 0` |
| `spree_pos_menu_schedules` | `store_id`, `branch_id` (nullable = mọi chi nhánh), `name`, `days_of_week` int[], `starts_at`, `ends_at` (time; cho phép vắt qua 0h) | |
| `spree_pos_menu_schedule_items` | `menu_schedule_id`, `menu_item_id`, `variant_id` (nullable = mọi size), `price` (nullable), `hidden` | |
| `spree_pos_menu_availabilities` | `branch_id`, `menu_item_id`, `sold_out_on` (business_date), `updated_by_type/id` | unique `(branch_id, menu_item_id)` |
| `spree_pos_menu_favorites` | `branch_id`, `menu_item_id`, `position` | unique cặp |
| `spree_pos_line_modifiers` | `sale_line_id`, `modifier_option_id`, `name`, `group_name`, `price_delta`, `quantity` (snapshot) | |
| `spree_pos_line_components` | `sale_line_id`, `variant_id`, `name`, `quantity` (snapshot) | |
| `spree_pos_sale_lines` (sửa) | thêm `note` varchar(200), `modifier_signature` | check `kind` thêm `menu` (qua registry của phase 1) |

Migration: `create_spree_pos_menu_tables`, `add_menu_columns_to_spree_pos_sale_lines`.

### Server

- **Model:** `MenuCategory`, `MenuItem`, `ModifierGroup`, `ModifierOption`, `MenuItemModifierGroup`, `ComboComponent`, `MenuSchedule`, `MenuScheduleItem`, `MenuAvailability`, `MenuFavorite`, `LineModifier`, `LineComponent`. Tất cả dưới `Spree::Pos::`, có `has_prefix_id`.
- **`Spree::Pos::Menu::Pricing.resolve(branch:, variant:, selections:, now:)`** trả về giá gốc đã chọn theo khung giờ, danh sách tùy chọn đã kiểm, `unit_price` và `modifier_signature`. Các lỗi đều là `Conflict`:
  - `modifier_min` / `modifier_max`: nhóm chưa đủ hoặc vượt số lựa chọn;
  - `modifier_unknown`: tùy chọn không thuộc món;
  - `menu_item_hidden`: món bị ẩn trong khung giờ hiện tại.
- **Kind handler `SaleLineKinds::Menu`** (theo giao diện registry của phase 1):
  - dựng merge key;
  - ghi `LineModifier` / `LineComponent`;
  - đặt giá `LineItem` theo đường giá của server. Đường này không đi qua `price_override`, nên không cần `Approval` `workspace.override_price`.

  `ManageLineItem.add` nhận thêm `modifiers: [{option_id, quantity}]` và `note:`. Khi các tham số này có mặt, hoặc khi variant thuộc một `MenuItem`, handler chuyển sang kind `menu`.
- **Workflow mới:**
  - `Workspaces::UpdateLineModifiers` thay bộ tùy chọn của một dòng, tính lại giá và gộp với dòng trùng signature nếu có. Workflow có kiểm revision, lease và snapshot lock như `ManageLineItem`.
  - `Menu::SetSoldOut` bật / tắt hết món và phát `menu.sold_out` sau commit.
- **Controller** (dưới `api/v3/admin/pos/`):
  - `menu_controller#show`: đọc thực đơn cho một chi nhánh, gồm danh mục, món, size, nhóm tùy chọn, giá hiện hành, hết món, món yêu thích và `etag`.
  - CRUD `menu_categories`, `menu_items`, `modifier_groups`, `menu_schedules`.
  - `PUT menu_availabilities`.
  - `PUT menu_favorites`.
  - `PATCH workspaces/:id/items/:item_id/modifiers`.
- **Quyền:**
  - `Capabilities::MANAGE_MENU = 'pos.menu.manage'`;
  - `Capabilities::SET_SOLD_OUT = 'pos.menu.sold_out'`. Thiết bị ở mode `kds` cũng được dùng quyền này.

  Hai quyền thêm vào `ASSIGNABLE`. Mọi lệnh sửa thực đơn đều ghi `AuditEntry` (`menu_item.change`, `menu.sold_out`).
- **Đọc:**
  - `Workspace#to_pos` và `SaleLine#to_pos` thêm `modifiers`, `components`, `note`.
  - `ReceiptBuilder#sale_line` in tùy chọn thành dòng phụ dưới tên món.
  - `DisplayState#line_row` cũng hiện tùy chọn.
- **OpenAPI:** thêm schema `Menu`, `MenuItem`, `ModifierGroup`, `LineModifier` và các endpoint trên vào `server/openapi/pos-staff.yaml`. App Flutter dùng `GET menu` ở phần 7A và 8C.
- **Module:** đổi `fnb.menu` từ `planned` sang `register` trong `config/initializers/pos_modules.rb` (depends_on: []). Profile chỉ chuyển sang `available` ở phần 7D.

### Client web (`apps/pos`)

- **Chọn surface:** `sale.tsx` / `pos-page.tsx` chọn surface theo module và hồ sơ:
  - `menu_grid` khi chi nhánh bật `fnb.menu`;
  - giữ `catalog-search` khi chi nhánh không bật.
- **`components/menu-grid.tsx`:**
  - tab danh mục ở trên, lưới ô có ảnh, giá và nhãn "Hết";
  - hàng "Yêu thích" ở đầu;
  - ô tìm nhanh theo tên / mã; quét mã vạch vẫn đi qua luồng hiện có;
  - phím số chọn nhanh món yêu thích.
- **`components/modifier-sheet.tsx`:**
  - size, các nhóm tùy chọn và ghi chú trên một màn, không chia bước;
  - nhóm bắt buộc được đánh dấu; nút Thêm bị khóa cho tới khi đủ min;
  - giá tạm hiển thị chỉ để xem, giá thật lấy từ response;
  - nút **"Thêm ly giống vậy"** trên dòng đã có trong `order-lines.tsx`: gửi lại đúng bộ tùy chọn, server gộp thành số lượng +1.
- **`order-lines.tsx`:** hiện tùy chọn dưới tên món, có nút sửa tùy chọn để mở lại `modifier-sheet`.
- **Trang `pages/settings/menu.tsx`:**
  - quản lý danh mục, món (gắn product có sẵn hoặc tạo mới qua Admin API), nhóm tùy chọn, combo, khung giờ, món yêu thích;
  - bật / tắt hết món.
  - Menu cài đặt có lối vào qua `modules/registry.ts` (`menuUi`).
- **`hooks/use-menu.ts`:**
  - đọc menu kèm `etag`;
  - nhận `menu.sold_out` qua hook realtime của phase 3 rồi refetch; poll 60 giây làm dự phòng.
- **i18n:** `locales/vi`, `locales/en`: khóa `menu.*`.

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/db/migrate/*_create_spree_pos_menu_tables.rb` | tạo | 12 bảng ở trên |
| `server/db/migrate/*_add_menu_columns_to_spree_pos_sale_lines.rb` | tạo | `note`, `modifier_signature` |
| `server/app/models/spree/pos/menu_*.rb`, `modifier_*.rb`, `combo_component.rb`, `line_modifier.rb`, `line_component.rb` | tạo | model |
| `server/app/models/spree/pos/sale_line.rb` | sửa | merge key có signature; `to_pos` thêm modifiers |
| `server/app/services/spree/pos/menu/pricing.rb` | tạo | tính giá dòng |
| `server/app/services/spree/pos/sale_line_kinds/menu.rb` | tạo | kind handler |
| `server/app/workflows/spree/pos/workspaces/manage_line_item.rb` | sửa | tham số `modifiers`, `note` |
| `server/app/workflows/spree/pos/workspaces/update_line_modifiers.rb` | tạo | sửa tùy chọn |
| `server/app/workflows/spree/pos/menu/set_sold_out.rb` | tạo | hết món |
| `server/app/controllers/spree/api/v3/admin/pos/menu_*_controller.rb`, `modifier_groups_controller.rb`, `workspaces/item_modifiers_controller.rb` | tạo | API |
| `server/app/models/spree/pos/capabilities.rb` | sửa | 2 quyền |
| `server/app/services/spree/pos/receipt_builder.rb`, `display_state.rb` | sửa | in và hiện tùy chọn |
| `server/config/initializers/pos_modules.rb` | sửa | đăng ký `fnb.menu` |
| `server/config/routes.rb` | sửa | route |
| `server/openapi/pos-staff.yaml` | sửa | hợp đồng |
| `apps/pos/src/components/menu-grid.tsx`, `modifier-sheet.tsx` | tạo | màn bán |
| `apps/pos/src/pages/settings/menu.tsx`, `hooks/use-menu.ts` | tạo | quản lý thực đơn |
| `apps/pos/src/pages/sale.tsx`, `components/pos-page.tsx`, `order-lines.tsx`, `modules/registry.ts`, `router.tsx` | sửa | chọn surface, hiện tùy chọn |

### Các bước

1. Viết migration và model, kèm spec model: validation min/max, ràng buộc unique, snapshot không đổi khi tùy chọn gốc bị sửa.
2. Viết `Menu::Pricing`, kèm spec cho khung giờ vắt qua 0h, size, topping có số lượng, nhóm bắt buộc, món ẩn.
3. Viết kind handler `menu` và nối vào `ManageLineItem.add`. Spec bắt buộc: merge key của dòng `ordinary` / `measured` / `tracked` không đổi (so với giá trị cố định trong spec).
4. Viết `UpdateLineModifiers`, kèm spec về gộp dòng và về lỗi khi snapshot đã khóa.
5. Viết hết món: workflow, sự kiện `menu.sold_out`, tự hết hạn theo `business_date`.
6. Viết controller, route, quyền và audit; cập nhật OpenAPI. Request spec kiểm response theo schema (cách kiểm do phần 5A dựng).
7. Viết ReceiptBuilder và DisplayState: hiện tùy chọn trên hóa đơn và trên màn khách.
8. Viết client: `use-menu`, `menu-grid`, `modifier-sheet`, sửa `order-lines`, trang cài đặt thực đơn.
9. Đăng ký `fnb.menu` là module `available`, rồi chạy lại toàn bộ spec POS và e2e bán lẻ.

### Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/menu_item_spec.rb spec/services/spree/pos/menu/pricing_spec.rb`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/manage_line_item_spec.rb spec/workflows/spree/pos/workspaces/update_line_modifiers_spec.rb`
- `pnpm spree rspec spec/requests/spree/pos/menu_spec.rb spec/requests/spree/pos/menu_availabilities_spec.rb`
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`
- Web: `pnpm --dir apps/pos lint typecheck test`. E2E mới `apps/pos/e2e/fnb-menu.spec.ts` chạy 4 tình huống:
  - thêm 2 ly khác topping → 2 dòng;
  - "Thêm ly giống vậy" → số lượng 2;
  - món hết bị từ chối;
  - giá giờ vàng.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Đổi merge key làm vỡ việc gộp dòng bán lẻ | Signature chỉ được nối vào khi có; spec cố định giá trị key cũ |
| Giá dòng không đi qua `price_override` thì thành lỗ hổng đặt giá tùy ý | Client không gửi được giá: giá chỉ đến từ `Menu::Pricing` với dữ liệu server. Còn giảm giá tay vẫn đi qua `Approval` như hiện tại |
| Thực đơn lớn làm chậm lưới | Một endpoint đọc có `etag`; ảnh dùng URL thu nhỏ của Spree |

### Tiêu chí xong

- [x] Thêm món với tùy chọn ra đúng giá ở server; hai bộ tùy chọn khác nhau là hai dòng.
- [x] Combo hiện thành phần trong đơn, trên hóa đơn và trong `to_pos`.
- [x] Giá theo khung giờ áp đúng, kể cả với khung vắt qua 0h.
- [x] Món hết bị từ chối, sự kiện `menu.sold_out` được phát, và trạng thái hết tự hết hạn sang ngày kinh doanh mới.
- [x] Chi nhánh tắt `fnb.menu` vẫn bán được món bằng giá gốc.
- [x] OpenAPI cập nhật; spec POS và e2e bán lẻ không lỗi mới.

### Kết quả

Trạng thái 11/11/2026: code đã viết đủ, web và server đều đã kiểm. Migration đã chạy; `schema.rb` chỉ thêm 12 bảng, 2 cột của `spree_pos_sale_lines` và khóa ngoại của chúng.

**Đã làm**

- Server:
  - Hai migration `20261111150000_create_spree_pos_menu_tables` (12 bảng) và `20261111150100_add_menu_columns_to_spree_pos_sale_lines` (`note`, `modifier_signature`).
  - 12 model `Spree::Pos::Menu*`, `Modifier*`, `ComboComponent`, `LineModifier`, `LineComponent`.
  - `Menu::Pricing`, `Menu::Reader` (đọc thực đơn kèm `etag`), kind handler `SaleLineKinds::Menu`, và tham số `modifiers` / `note` trong `ManageLineItem.add`.
  - Workflow `UpdateLineModifiers`, `Menu::SetSoldOut` và `Menu::Save`. `Save` lo CRUD danh mục, món, nhóm tùy chọn, khung giờ và món yêu thích, kèm `AuditEntry`.
  - Controller dưới `api/v3/admin/pos/`, route, quyền `pos.menu.manage` / `pos.menu.sold_out`.
  - Tùy chọn và thành phần combo hiện trong `to_pos`, trên hóa đơn (`ReceiptBuilder`, `TemplateData`) và trên màn khách (`DisplayState`).
  - Hợp đồng OpenAPI trong `pos-staff.yaml`. `fnb.menu` chuyển từ `planned` sang `register`.
- `apps/pos`: `menu-grid`, `modifier-sheet`, `use-menu`, sửa tùy chọn và nút "Thêm ly giống vậy" trong `order-lines`, khóa i18n `menu*`.
- `apps/pos-dashboard`: trang `/menu` (`pages/menu.tsx`, `hooks/use-menu-admin.ts`), mục nav và nhóm quyền.
- `packages/pos-shared`: hai quyền mới, module `fnb.menu`, kiểu dữ liệu menu, dòng phụ trên hóa đơn.

**Sửa trong lần kiểm này**

- `menu-grid.tsx`: phím số chọn món yêu thích không chạy, vì code coi popup của các ô sửa dòng là đang mở, trong khi popup đó nằm trong `<details>` đang đóng. Giờ chỉ popup không nằm trong `<details>` đóng mới chặn phím.
- `Menu::Save`: không cho gắn tax category của store khác vào món, vì bảng `spree_tax_categories` có `store_id`.
- Hai test web viết theo hành vi cũ: `realtime.test.ts` dùng `menu.sold_out` làm ví dụ sự kiện lạ (nay là sự kiện thật), và `pos-administration.test.ts` đếm 20 quyền (nay là 22).
- Biome: format lại các file menu mới và bỏ `!` trong `menu-selection.test.ts`.
- Đóng hai khoảng trống tác giả đã liệt kê:
  - fixture e2e có thêm `PATCH …/items/:id/modifiers`, kèm e2e "đổi tùy chọn thì tính lại giá và gộp với dòng trùng";
  - `manage_line_item_spec` kiểm thành phần combo trong payload hóa đơn và dòng in `- Khoai tây ×2`.

**Sửa khi chạy spec server**

- `schema.rb`: Postgres của máy dev dump lại các check constraint cũ theo dạng khác (`ARRAY[...]::text[]`), nghĩa không đổi. Đã trả 67 dòng đó về đúng bản đã commit, nên diff chỉ còn phần thêm.
- Spree 6.0.2 không còn master: `product.variants` gồm mọi variant, `default_variant` là variant đầu, `product.master` chỉ còn là alias deprecated, và `includes(master: …)` lỗi vì không có association đó. Thêm `MenuItem#sizes(now:)`: lấy mọi variant theo `position`, bỏ variant hết hạn bán, và bỏ master cũ khi có variant có tùy chọn (cùng luật với `CatalogReader`). `Menu::Reader` và `MenuItemsController` dùng chung hàm này.
- Ảnh món: product của Spree 6 có `primary_media` và `media` (`Spree::Media`, `has_one_attached :attachment`), không có `images`. `Reader#image_url` giờ đọc `primary_media || media.first`; preload thêm `primary_media`.
- Fixture `menu_item!`: variant mặc định của product là size đầu, mỗi size có option value riêng nên `options_text` ra đúng `Size: M` / `Size: L`. Bản cũ để variant mặc định nằm cạnh các size, nên `size(item, 1)` trả về size M.
- `manage_line_item_spec`: chuỗi cố định của merge key viết `0.25e5`, nhưng ActiveSupport in `BigDecimal` là `25000.0`. Code merge key không đổi so với bản commit; đã sửa chuỗi trong spec.
- Các spec dùng `travel_to` thiếu `include ActiveSupport::Testing::TimeHelpers` (`manage_line_item_spec`, `menu_spec`, `menu_availabilities_spec`).
- Hai spec bán sản phẩm thường "Nước suối" chưa nhập kho cho chi nhánh, nên Spree từ chối số lượng. Đã nhập 10 trước khi bán.
- `branch_profiles_spec`: đổi hồ sơ của store không được đổi module của chi nhánh hiện có. Spec cũ kiểm "mọi module bật", sai khi `fnb.menu` đã đăng ký nhưng không thuộc hồ sơ `khac`. Giờ spec so với trạng thái trước lệnh.
- Các điểm cần kiểm đã rõ: `Spree::TaxCategory` có `prefixed_id` (`taxcat_…`) và `find_by_prefix_id`; cột `time` đọc lại thành `2000-01-01 HH:MM UTC`, giờ và phút không lệch; mốc 04:00 của `menu_availabilities_spec` chạy đúng.

**Lệch so với plan, đã chấp nhận**

- Trang quản lý thực đơn nằm trong `apps/pos-dashboard`, không phải `apps/pos/src/pages/settings/menu.tsx`, vì `apps/pos/AGENTS.md` cấm màn cài đặt ở app bán.
- Không có mục `menuUi` trong registry. Lối vào là nav của dashboard.
- Quầy không gửi `If-None-Match`. Quầy refetch khi nhận `menu.sold_out` và poll 60 giây. Server vẫn trả 304 khi client gửi etag.

**Lệnh đã chạy**

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `pnpm spree migrate`, rồi `pnpm spree exec bin/rails db:test:prepare` | 2 migration chạy xong; `schema.rb` +186/−1 (dòng version) |
| 2 | `pnpm spree rspec spec/models/spree/pos/menu_item_spec.rb spec/services/spree/pos/menu/pricing_spec.rb` | 15/15 qua (lần đầu 4 lỗi do fixture size) |
| 3 | `pnpm spree rspec spec/workflows/spree/pos/workspaces/manage_line_item_spec.rb spec/workflows/spree/pos/workspaces/update_line_modifiers_spec.rb` | 14/14 qua (lần đầu 5 lỗi: `travel_to`, kho, chuỗi merge key) |
| 4 | `pnpm spree rspec spec/requests/spree/pos/menu_spec.rb spec/requests/spree/pos/menu_availabilities_spec.rb` | 9/9 qua (lần đầu 6 lỗi `travel_to`) |
| 5 | spec module / hồ sơ (`business_profiles`, `module_policy`, `sale_line_kinds`, `branch_modules`, `branch_profiles`, `onboarding`, `topology`) | 57 ví dụ; 1 lỗi ở `branch_profiles_spec`, đã sửa spec; chạy lại trong lệnh 6 |
| 6 | `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/ spec/services/spree/pos/ spec/models/spree/pos/` | 738 ví dụ, 1 lỗi: `devices_spec` "every path has a route" thấy `GET system_status` trong `pos-staff.yaml` mà chưa có route. Một phiên khác (phần 5B) đang thêm endpoint này và sửa `routes.rb` / `pos-staff.yaml` lúc lệnh đang chạy. Chạy lại `devices_spec` sau đó: 3/3 qua |
| 7 | Web | Không chạy lại: response và OpenAPI không đổi hình dạng |
| 7 | `pnpm --dir packages/pos-shared test`, `typecheck` | 247/247 qua; tsc sạch |
| 7 | `apps/pos`: `typecheck`, `test`, `lint` | tsc sạch; 255/255 qua sau khi sửa 2 test cũ; biome sạch |
| 7 | `apps/pos-dashboard`: `vite build` (sinh lại `routeTree.gen.ts`), `typecheck`, `test`, `lint` | build qua; tsc sạch; 86/86 qua; biome sạch (chỉ còn thông tin lệch phiên bản schema `biome.json` có từ trước) |
| 8 | `playwright test e2e/fnb-menu.spec.ts --project desktop` | 5/5 qua (4 tình huống của plan và tình huống đổi tùy chọn) |
| 8 | `playwright test e2e/catalog-search.spec.ts e2e/branch-modules.spec.ts e2e/receipts-display.spec.ts --project desktop` | 14/14 qua |

**Còn mở**

- Chưa có spec nào gắn ảnh thật cho món; `image_url` mới được kiểm khi không có ảnh (trả `nil`).
- Rubocop còn báo trên các file menu đã viết trước đó (không phải dòng sửa lần này): `Layout/HashAlignment` ở `menu_item.rb:19`, `Metrics/ParameterLists` ở 3 helper của `pos_menu_helpers.rb`, `Layout/LineLength` ở `update_line_modifiers_spec.rb:36` và `menu_spec.rb:163,165`.
- Chưa có e2e cho trang `/menu` của dashboard.
- Chưa có e2e tablet/mobile cho `menu-grid` / `modifier-sheet`.

## Phần 6B: Công thức và trừ kho

### Overview

Bán một ly trà sữa size L, thêm trân châu, thì kho phải trừ đúng lượng trà, sữa, đường và trân châu. Phần này gồm:
- công thức cho từng **variant** (size) và cho từng **tùy chọn modifier**;
- trừ nguyên liệu **khi complete**, idempotent;
- cảnh báo nguyên liệu sắp hết;
- dữ liệu giá vốn để báo cáo lãi gộp theo món.

Research xếp `fnb.recipes` ở F2, nhưng plan chuyển nó lên F1 (D10) vì với cafe đây là tính năng bắt buộc.

### Quyết định

1. **Món không theo dõi tồn kho; chỉ nguyên liệu mới theo dõi.**
   - Variant của món bật `fnb.recipes` để `track_inventory = false`, nên Spree không trừ kho món khi placed.
   - Nguyên liệu là variant thường, có tồn ở stock location của chi nhánh. Đơn vị đi qua `retail.units`: ví dụ công thức khai báo theo ml / g, còn nhập kho theo chai / bao.
2. **Trừ kho chạy trong transaction của `Workspaces::Complete`**, ngay sau khi đơn placed, bằng `StockIntegration.adjust!(location, variant, -qty, reason)`. Lý do chọn đường này:
   - nguyên liệu không phải dòng của đơn, nên không đi qua shipment;
   - `adjust!` đã khóa `StockLevel` và đi qua cổng `writing`.
3. **Thiếu nguyên liệu không chặn việc bán.** Quán cafe không thể từ chối ly nước vì sổ kho lệch. Tồn có thể âm; mỗi lần tồn âm ghi một `StockDiscrepancy` (model đã có) để kiểm kho xử lý.

   Bước 1 phải kiểm `adjust!` có cho tồn âm không, tức `backorderable` / ràng buộc của `StockLevel`. Nếu không cho, ghi phần thiếu vào discrepancy thay vì trừ.
4. **Idempotent:** bảng `recipe_consumptions` có unique `(sale_line_id, ingredient_variant_id, source_key)`. Complete chạy lại, hoặc gọi lại sau Conflict, không trừ hai lần.
5. **Hủy hoặc trả món đã làm không nhập lại kho.**
   - Trả hàng một món F&B không hoàn nguyên liệu, vì variant món không theo dõi tồn.
   - Hủy dòng trước complete không ảnh hưởng gì, vì chưa trừ kho.
6. **Nguyên liệu theo lô / serial** (`tracked_mode != 'none'`) bị từ chối khi lưu công thức (`Conflict reason: 'recipe_ingredient_tracked'`). FEFO cho nguyên liệu để sau.
7. **Công thức có version.** Sửa công thức tạo version mới; `recipe_consumptions` lưu `recipe_version` và giá vốn snapshot (`cost_price` của nguyên liệu lúc trừ).

### Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_recipes` | `store_id`, `owner_type` (`Spree::Variant` / `Spree::Pos::ModifierOption`), `owner_id`, `version`, `active` | unique `(owner_type, owner_id, version)`; mỗi owner có một bản `active` (partial unique) |
| `spree_pos_recipe_ingredients` | `recipe_id`, `ingredient_variant_id`, `quantity` decimal(12,4) > 0, `unit_code` | unique `(recipe_id, ingredient_variant_id)` |
| `spree_pos_recipe_consumptions` | `store_id`, `branch_id`, `workspace_id`, `order_id`, `sale_line_id`, `ingredient_variant_id`, `stock_location_id`, `base_quantity`, `recipe_id`, `recipe_version`, `source_key` (`variant`, `modifier:<option_id>`, `component:<variant_id>`), `unit_cost`, `business_date` | unique `(sale_line_id, ingredient_variant_id, source_key)` |
| `spree_pos_stock_alerts` | `branch_id`, `variant_id`, `min_quantity` (đơn vị gốc) | unique `(branch_id, variant_id)` |

Migration: `create_spree_pos_recipe_tables`, `create_spree_pos_stock_alerts`.

### Server

- **Model:** `Recipe`, `RecipeIngredient`, `RecipeConsumption`, `StockAlert`.
- **`Spree::Pos::Recipes::Expand.call(sale_line)`** trả về danh sách `(ingredient, base_quantity, source_key, recipe)` theo ba nguồn:
  - công thức của variant × số lượng dòng;
  - Σ công thức của từng tùy chọn × số lượng tùy chọn × số lượng dòng (đọc `LineModifier` của phần 6A);
  - combo: công thức của từng `LineComponent`.

  Đổi đơn vị qua `UnitNormalizer` / `VariantUnit` hiện có.
- **`Spree::Pos::Recipes::Consume.call(workspace)`** được gọi trong `Workspaces::Complete` sau `Inventory::AllocateTraceability.commit!`, khi chi nhánh bật `fnb.recipes`. Workflow:
  - ghi `RecipeConsumption` và trừ qua `StockIntegration.adjust!`;
  - ghi `StockDiscrepancy` khi tồn âm;
  - sau commit, phát cảnh báo khi tồn xuống dưới `StockAlert.min_quantity` (`AuditEntry` `stock.low` + mục trong báo cáo; realtime dùng sự kiện của phase 3 nếu đã có kênh).
- **Workflow `Recipes::Save`:** tạo version mới, kiểm nguyên liệu không tracked, kiểm đơn vị thuộc dimension của nguyên liệu. Ghi `AuditEntry` `recipe.change`.
- **Controller:**
  - `recipes_controller`: `GET/PUT` theo owner (`variant_id` hoặc `modifier_option_id`), xem lịch sử version;
  - `stock_alerts_controller`;
  - báo cáo mới trong `Spree::Pos::Reports`: `ingredient_usage` (tiêu hao theo ngày kinh doanh / nguyên liệu / món) và `menu_margin` (doanh thu − giá vốn theo món). Cả hai đọc từ `recipe_consumptions` và theo khung `reports/base.rb`.
- **Quyền:** dùng lại `Capabilities::INVENTORY_MANAGE` cho công thức và ngưỡng cảnh báo; dùng lại `REPORT_READ` / `REPORT_EXPORT` cho báo cáo.
- **Module:** đăng ký `fnb.recipes` (depends_on: `fnb.menu`, `retail.units`). Bật module thì mặc định đặt `track_inventory = false` cho variant món. Có cảnh báo và cần xác nhận khi variant đang có tồn > 0.
- **OpenAPI:** thêm `Recipe`, `StockAlert` và hai loại báo cáo mới.

### Client web (`apps/pos`)

- **Tab Công thức** trong màn sửa món (`pages/settings/menu.tsx`):
  - mỗi size một bảng nguyên liệu: chọn variant, số lượng, đơn vị;
  - mỗi tùy chọn có công thức riêng nếu cần;
  - hiện giá vốn ước tính theo `cost_price` hiện tại.
- **Trang Nguyên liệu sắp hết:** đặt ngưỡng; danh sách nằm trong mục kho.
- **`pages/reports.tsx`** thêm hai báo cáo "Tiêu hao nguyên liệu" và "Lãi gộp theo món", có xuất file theo cơ chế export hiện có.

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/db/migrate/*_create_spree_pos_recipe_tables.rb`, `*_create_spree_pos_stock_alerts.rb` | tạo | dữ liệu |
| `server/app/models/spree/pos/recipe.rb`, `recipe_ingredient.rb`, `recipe_consumption.rb`, `stock_alert.rb` | tạo | model |
| `server/app/services/spree/pos/recipes/expand.rb` | tạo | khai triển công thức |
| `server/app/workflows/spree/pos/recipes/consume.rb`, `save.rb` | tạo | trừ kho, lưu công thức |
| `server/app/workflows/spree/pos/workspaces/complete.rb` | sửa | gọi `Recipes::Consume` |
| `server/app/services/spree/pos/reports/ingredient_usage.rb`, `menu_margin.rb`, `reports.rb` | tạo / sửa | báo cáo |
| `server/app/controllers/spree/api/v3/admin/pos/recipes_controller.rb`, `stock_alerts_controller.rb` | tạo | API |
| `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | sửa | module, route, hợp đồng |
| `apps/pos/src/components/recipe-editor.tsx`, `pages/settings/stock-alerts.tsx`, `hooks/use-recipes.ts` | tạo | web |
| `apps/pos/src/pages/settings/menu.tsx`, `pages/reports.tsx` | sửa | tab công thức, báo cáo |

### Các bước

1. Đọc `StockIntegration.adjust!` và `Spree::StockLevel` để xác nhận cách tồn âm (quyết định 3), rồi ghi kết luận vào phần này.
2. Viết migration, model và `Recipes::Save`. Spec: version tăng; chặn nguyên liệu tracked; chặn đơn vị sai dimension.
3. Viết `Recipes::Expand`. Spec cho size, tùy chọn có số lượng, combo, đổi đơn vị (ml → chai).
4. Viết `Recipes::Consume` và nối vào `Complete`. Spec:
   - trừ đúng lượng;
   - complete lặp không trừ hai lần;
   - tồn âm ghi discrepancy và không chặn việc bán;
   - module tắt thì không trừ.
5. Viết spec hồi quy: trả hàng món F&B không nhập lại nguyên liệu; trả hàng bán lẻ vẫn nhập lại như cũ.
6. Viết cảnh báo sắp hết và hai báo cáo, cộng controller và OpenAPI.
7. Viết web: trình sửa công thức, ngưỡng cảnh báo, báo cáo.

### Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/recipes/expand_spec.rb spec/workflows/spree/pos/recipes/`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/complete_spec.rb spec/requests/spree/pos/recipes_spec.rb spec/requests/spree/pos/reports_spec.rb`
- Hồi quy kho và trả hàng: `pnpm spree rspec spec/requests/spree/pos/returns_spec.rb spec/services/spree/pos/stock_integration_spec.rb`
- Web: `pnpm --dir apps/pos lint typecheck test`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Trừ kho trong transaction làm chậm complete khi đơn có nhiều ly | Gom theo nguyên liệu trước khi `adjust!`; mỗi nguyên liệu khóa một `StockLevel` |
| Deadlock khi hai máy complete cùng lúc trên cùng nguyên liệu | Khóa `StockLevel` theo thứ tự `variant_id` tăng dần |
| Chủ quán bật module khi món đang có tồn | Cảnh báo kèm xác nhận; không tự xóa tồn |

### Tiêu chí xong

- [x] Bán món có size và tùy chọn trừ đúng nguyên liệu theo đơn vị gốc, idempotent.
- [x] Thiếu nguyên liệu không chặn việc bán và có ghi discrepancy.
- [x] Trả hàng hoặc hủy món F&B không nhập lại nguyên liệu; trả hàng bán lẻ không đổi.
- [x] Có cảnh báo sắp hết, báo cáo tiêu hao và báo cáo lãi gộp theo món.

### Kết quả

Trạng thái 11/11/2026: code đã viết đủ; spec server, test web và lint đã chạy. Migration đã chạy; `schema.rb` +281/−3 (dòng version, check constraint cũ của `spree_pos_export_requests` và index cũ của `spree_pos_stock_discrepancies`). Chưa commit.

**Kết luận về tồn âm (bước 1)**

Đọc `spree_core-6.0.3` trong container:

- `StockIntegration.adjust!` gọi `StockLocation#adjust`, tức tạo `StockMovement` kiểu `adjusted` với số lượng nguyên khác 0.
- `Spree::StockLevel` chặn `count_on_hand < 0` khi số tồn giảm xuống dưới 0, trừ khi ghi có `force`. Chỉ `unstock(force: true)` (kiểu `shipped`, đường của shipment) mới ép được. `backorderable` không liên quan.
- Điều chỉnh vẫn áp vào `StockLevel` cả khi variant không theo dõi tồn.
- `Variant#handle_track_inventory_change` (after_update_commit) xóa tồn còn lại khi tắt theo dõi tồn.

Vậy `adjust!` **không** cho tồn âm. `Recipes::Consume` trừ tối đa tới 0 (`min(cần, max(tồn, 0))`) và ghi phần thiếu vào `StockDiscrepancy` với `source = 'recipe'`. Việc bán không bị chặn. Đây là nhánh dự phòng của quyết định 3.

**Đã làm**

- Server:
  - Migration `20261111160000_create_spree_pos_recipe_tables`: `spree_pos_recipes`, `spree_pos_recipe_ingredients`, `spree_pos_recipe_consumptions`, kèm unique và check như bảng Dữ liệu. Migration này cũng thêm cột `source` (`handover` / `recipe`) cho `spree_pos_stock_discrepancies` và dựng lại index mở theo `(fulfillment_id, variant_id, source)`.
  - Migration `20261111160100_create_spree_pos_stock_alerts`: bảng `spree_pos_stock_alerts`; check `chk_pos_export_requests_report` thêm `ingredient_usage` và `menu_margin`.
  - Model `Recipe`, `RecipeIngredient`, `RecipeConsumption`, `StockAlert`. `StockDiscrepancy` có `SOURCES`, scope `handover` và trả `source` trong `to_pos`.
  - Service `Spree::Pos::Recipes`: quyền đọc / sửa, owner hợp lệ, đổi đơn vị (`base_quantity`) và giá vốn trên một đơn vị tồn (`unit_cost`).
  - `Recipes::Expand`: ba nguồn `variant`, `modifier:<id>`, `component:<id>`; gộp theo `(nguyên liệu, nguồn)`.
  - Workflow `Recipes::Save`: version tăng dần; chặn nguyên liệu tracked, sai dimension, lượng không đổi ra số nguyên, trùng dòng, tự làm nguyên liệu, quá 50 dòng. Ghi `AuditEntry` `recipe.change`.
  - `Recipes::Consume`: gọi trong `Workspaces::Complete` ngay sau `Inventory::AllocateTraceability.commit!`. Khóa `StockLevel` theo `variant_id` tăng dần. Ghi `AuditEntry` `stock.low` khi tồn vượt xuống dưới ngưỡng.
  - `Recipes::SetStockAlert`: đặt ngưỡng; để trống thì bỏ ngưỡng.
  - Báo cáo `ingredient_usage` và `menu_margin` (chung lớp `Reports::Grouped`), có xuất file.
  - Controller `recipes_controller` (GET/PUT) và `stock_alerts_controller` (GET/PUT); route; OpenAPI trong `pos-staff.yaml` (`/recipes`, `/stock_alerts`, hai báo cáo, schema `Recipe`, `RecipeOwner`, `StockAlert`, `IngredientUsageRow`, `MenuMarginRow`).
  - `fnb.recipes` chuyển từ `planned` sang `register` (depends_on `fnb.menu`, `retail.units`).
  - `Orders::Handover` và `RecoverReturnOperationJob` chỉ đụng discrepancy `source = 'handover'`.
- `packages/pos-shared`: module `fnb.recipes` (nhãn vi / en), `REPORT_TYPES` thêm hai báo cáo, `reportTypesFor(modules)` chỉ hiện hai tab đó khi chi nhánh bật `fnb.recipes`.
- `apps/pos-dashboard`:
  - `components/recipe-editor.tsx`: nút "Công thức" trên từng món của `/menu`. Hộp thoại chọn size hoặc tùy chọn, rồi hiện bảng nguyên liệu (tìm hàng, số lượng, đơn vị), version, giá vốn ước tính và lượng trừ theo đơn vị tồn. Khi size còn tồn, hộp thoại hỏi xác nhận rồi mới gửi `confirm_stock_write_off`.
  - `pages/stock-alerts.tsx` (`/stock-alerts`, mục Kho): danh sách ngưỡng của chi nhánh, mục sắp hết xếp trước; thêm, sửa, bỏ ngưỡng.
  - `components/product-search.tsx`: tách ô tìm hàng từ `menu.tsx` để dùng chung.
  - Hai route báo cáo `reports/ingredient_usage`, `reports/menu_margin`; cột tiền, cột phần trăm, cột Có/Không. Quyền mới trong `pos-access.ts` (`canManageRecipes`, `runsRecipes`), mục nav và khóa i18n `recipes.*`, `stockAlerts.*`, `report*`.

**Lệch so với plan, đã chấp nhận**

- `track_inventory = false` được đặt khi **lưu công thức đầu tiên của một size**, không phải khi bật module. Bật module không biết món nào là đồ pha chế, và đặt hàng loạt sẽ đụng cả hàng bán lẻ. Nếu size còn tồn, server trả 409 `recipe_variant_has_stock` (kèm `on_hand`), và chỉ lưu khi người dùng xác nhận. Spree sau đó tự xóa tồn đó (xem kết luận trên), nên câu "không tự xóa tồn" trong bảng Rủi ro chỉ đúng tới lúc xác nhận.
- Đổi đơn vị chạy **một lần khi lưu**: dòng nguyên liệu lưu sẵn `base_quantity` (số nguyên theo đơn vị tồn) và `base_unit_code`. Lượng phải đổi ra số nguyên, nếu không thì trả `recipe_quantity_inexact`. Khi bán, code chỉ nhân lượng đã lưu, không đổi đơn vị.
- "ml → chai" không đổi được vì hai đơn vị khác dimension (thể tích và cái). Spec dùng l → ml và thùng → chai (pack ratio của `VariantUnit`).
- Tùy chọn hoặc thành phần combo **không có công thức** mà trỏ tới variant có theo dõi tồn sẽ trừ 1 đơn vị tồn của variant đó (ví dụ topping bán như hàng đóng gói). Nếu variant không theo dõi tồn thì không trừ gì.
- `StockDiscrepancy` thêm cột `source`. Thiếu theo công thức không gắn với giao hàng, nên `Handover` không được tự đóng nó, và job phục hồi không được thử giao lại. Discrepancy công thức gắn với fulfillment đầu tiên của đơn.
- `stock.low` chỉ là `AuditEntry`; không phát realtime, vì phase 3 chưa có kênh sự kiện kho. Báo cáo tiêu hao có `shortages` / `open_shortages` trong phần tổng.
- Biến thể không theo dõi tồn vẫn có dòng `RecipeConsumption` (để báo cáo giá vốn) nhưng không đổi kho.
- Giao diện nằm trong `apps/pos-dashboard`, không phải `apps/pos` (theo `apps/pos/AGENTS.md`). Trình sửa công thức là hộp thoại trên `/menu`, không phải tab trong màn sửa món. Món combo không có nút công thức: combo trừ theo công thức của từng thành phần. Người quản lý thực đơn xem được công thức; chỉ quản lý kho (`pos.inventory.manage`) hoặc quản trị store mới sửa được.
- OpenAPI ghi hai đường báo cáo cụ thể (`/reports/ingredient_usage`, `/reports/menu_margin`), vì `devices_spec` dò route theo từng đường.
- File spec khác plan: không có `returns_spec.rb` và `stock_integration_spec.rb`. Spec hồi quy trả hàng F&B nằm trong `complete_spec.rb`; hồi quy bán lẻ chạy `returns_refunds_spec`, `traceability_spec`, `fulfillment_returns_spec`. Hai báo cáo được kiểm trong `recipes_spec.rb`.

**Lệnh đã chạy**

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `pnpm spree migrate`, rồi `pnpm spree exec bin/rails db:test:prepare` | 2 migration chạy xong. Dump đã viết lại 63 check constraint và 3 điều kiện `where` của index sang dạng khác; đã trả về đúng bản đã commit. Check xuất file mới viết theo cùng kiểu đó |
| 2 | `pnpm spree rspec spec/services/spree/pos/recipes/expand_spec.rb spec/workflows/spree/pos/recipes/ spec/workflows/spree/pos/workspaces/complete_spec.rb` | 18/18 qua |
| 3 | `pnpm spree rspec spec/requests/spree/pos/recipes_spec.rb` | 4/4 qua (schema OpenAPI, ngưỡng, hai báo cáo, xuất `menu_margin`) |
| 4 | Hồi quy: `reports`, `devices`, `returns_refunds`, `traceability`, `fulfillment_returns`, `credit_sales`, `business_profiles` ×2, `module_policy`, `sale_line_kinds`, `branch_modules`, `branch_profiles`, `onboarding`, `topology`, `menu`, `operational_metrics` | 123 ví dụ, 7 lỗi, đều do danh sách module nay có `fnb.recipes`. Đã sửa kỳ vọng; chạy lại 7 file: 54/54 qua |
| 5 | `pnpm spree rspec spec/workflows/spree/pos/ spec/integration/spree/pos/ spec/requests/spree/pos/settlement_spec.rb spec/requests/spree/pos/workspaces_spec.rb spec/requests/spree/pos/menu_availabilities_spec.rb` | 357/357 qua |
| 6 | `pnpm spree exec bundle exec rubocop -a` trên các file server mới | Đã sửa layout. Còn `Metrics/ParameterLists` ở `Save.call`, `SetStockAlert.call`, `Consume`, `IngredientUsage` và helper `ingredient!` (cùng kiểu các workflow có sẵn). `complete.rb` vẫn còn các cảnh báo Metrics như trước khi sửa |
| 7 | Chạy lại lệnh 2, 3 và `devices_spec` sau rubocop | 25/25 qua |
| 8 | `packages/pos-shared`: `test`, `typecheck`, `lint` | 248/248 qua; tsc sạch; biome sạch |
| 9 | `apps/pos`: `typecheck`, `test`, `lint` | tsc sạch; 256/256 qua; biome sạch |
| 10 | `apps/pos-dashboard`: `vite build` (sinh lại `routeTree.gen.ts`), `typecheck`, `test`, `lint` | build qua; tsc sạch; 87/87 qua; biome sạch sau khi format 4 file mới |
| 11 | `playwright test e2e/reports.spec.ts e2e/shell-access.spec.ts --project desktop` | Chưa chạy: cổng 5176 bị một vite dev server khác giữ suốt hơn 5 phút chờ (`reuseExistingServer: false`); không dừng tiến trình đó |

**Còn mở**

- Chưa có màn xử lý discrepancy `recipe`; mới thấy được qua báo cáo tiêu hao (`open_shortages`) và API.
- Công thức lưu sẵn lượng theo đơn vị tồn. Nếu sau này đổi đơn vị gốc hoặc pack ratio của nguyên liệu, công thức cũ không tự tính lại; phải lưu lại công thức.
- Giá vốn lấy `cost_price` hiện tại lúc trừ kho; chưa có giá vốn bình quân.
- Chưa có e2e cho trình sửa công thức và trang `/stock-alerts`. Chưa chạy lại e2e báo cáo của dashboard (lệnh 11).

## Phần 6C: Hóa đơn điện tử

### Overview

Mục tiêu: phát hành hóa đơn điện tử (HĐĐT) cho mọi đơn complete, gửi qua một nhà cung cấp, có hàng đợi chạy lại, và dùng chung cho cả bán lẻ lẫn F&B. Phần này cần làm vì:
- hộ kinh doanh doanh thu > 1 tỷ / năm bắt buộc dùng HĐĐT (NĐ 68/2026, sửa bởi NĐ 141/2026);
- F&B và giải trí thuộc nhóm dùng hóa đơn khởi tạo từ máy tính tiền;
- từ 01/07/2026, NĐ 254/2026 và TT 91/2026 thay bộ văn bản cũ (research §7).

**Nhà cung cấp do khách hàng chọn** (đã chốt 09/11/2026): mỗi cửa hàng chọn nhà cung cấp trong cài đặt, nên server phải có nhiều adapter. Phần này làm interface, hàng đợi, adapter `sandbox` (hành vi thật nhưng chỉ ghi trong DB) và **adapter VNPT**, vì khách thường dùng VNPT. Adapter của MISA, Viettel và các bên khác viết thêm theo cùng interface khi có khách cần, mỗi adapter một commit.

### Quyết định

1. **Đọc văn bản gốc trước khi chốt trường dữ liệu.** Bước 1 của phần là đọc NĐ 254/2026/NĐ-CP và TT 91/2026/TT-BTC từ nguồn chính thức (Công báo / vbpl.vn, hoặc bản trên thuvienphapluat). Ghi vào `docs/legal/hddt-nd254-tt91.md`:
   - nội dung bắt buộc của HĐ khởi tạo từ máy tính tiền;
   - nội dung bắt buộc của HĐ có mã;
   - quy định thời điểm lập (gồm ngoại lệ 22h–6h ở Điều 9);
   - cách ghi khi người mua không lấy hóa đơn.

   Các tên trường dưới đây là bản nháp và sửa theo ghi chú đó.
2. **Hai loại hóa đơn**, cấu hình theo store (`StoreProfile.einvoice_type`):

   | Giá trị | Loại |
   |---|---|
   | `cash_register` | HĐ khởi tạo từ máy tính tiền |
   | `coded` | HĐ có mã từng lần |
   | `none` | Không phát hành, mặc định cho đơn vị dưới ngưỡng |

   Theo dõi doanh thu lũy kế trong năm và cảnh báo trên dashboard khi đạt 80% và 100% của mốc 1 tỷ. Phần cảnh báo này chỉ đọc báo cáo, không đổi hành vi bán.
3. **Phát hành sau complete, không chặn complete.**
   - `Workspaces::Complete` ghi một `OutboxEntry` `einvoice.issue` **trong cùng transaction**. Model này đã có, với cơ chế `record!` và `DispatchOutboxJob` claim bằng SKIP LOCKED.
   - Một handler mới gọi adapter. Lỗi thì chạy lại với backoff (1, 5, 15, 60 phút, rồi mỗi 6 giờ) cho đến khi thành công hoặc có người hủy.
   - Mất internet trên server LAN (phần 5B) thì đơn vẫn complete, và hóa đơn được phát hành khi có mạng lại.
4. **Người mua:**
   - Mặc định là đơn không có thông tin người mua. Dòng chữ ghi trên hóa đơn ("Người mua không lấy hóa đơn" hoặc "Bán cho người tiêu dùng") chốt theo bước 1 và đặt trong cấu hình, không viết cứng.
   - Khi khách cần hóa đơn công ty, thu ngân nhập MST, tên, địa chỉ, email; hoặc khách **tự nhập qua QR trên bill**.
   - Server có `GET /pos_einvoice/:token` (trang web nhỏ, token ký, hết hạn theo cấu hình, mặc định đến cuối ngày kinh doanh), tra MST qua API của nhà cung cấp nếu có.
   - Khách gửi thông tin trước khi hóa đơn được phát hành thì hóa đơn mang thông tin đó. Nếu đã phát hành thì làm điều chỉnh / thay thế theo quy định ghi ở bước 1. Bản đầu cho quản lý làm thủ công, có audit.
5. **Dòng hóa đơn:**
   - Lấy từ snapshot đơn, kèm thuế suất **theo dòng** (phase 1, `TaxCategory`).
   - Dòng tính giờ (phần 11A) có đơn vị "giờ", số lượng thập phân 2 chữ số.
   - Phí phục vụ (phần 8A) là một dòng chịu thuế.
   - Tip không vào hóa đơn (phần 9B).
6. **Địa điểm:** mỗi chi nhánh có thể in tên và địa chỉ riêng (`Branch` / `StoreProfile`), cùng **ký hiệu mẫu số / ký hiệu hóa đơn** riêng. Nhà cung cấp cấp ký hiệu, cấu hình ở mức chi nhánh.
7. **Interface adapter** `Spree::Pos::Einvoice::Provider` gồm:
   - `issue(invoice) → { provider_ref, number, symbol, lookup_code, issued_at }`;
   - `status(invoice)`;
   - `cancel(invoice, reason)`;
   - `lookup_tax_code(mst)` (tùy chọn).

   Adapter được đăng ký qua registry `Spree::Pos::Einvoice.providers`, giống cách Spree đăng ký payment method. Thông tin đăng nhập nhà cung cấp lưu mã hóa bằng Active Record encryption (đã cấu hình khóa trong env).

### Dữ liệu

| Bảng | Cột chính |
|---|---|
| `spree_pos_einvoices` | `store_id`, `branch_id`, `order_id` unique, `workspace_id`, `invoice_type`, `provider`, `status` (`pending|issuing|issued|failed|canceled|adjusted`), `buyer jsonb` (mst, name, address, email, buyer_note), `lines_snapshot jsonb`, `totals_snapshot jsonb`, `provider_ref`, `number`, `symbol`, `lookup_code`, `issued_at`, `attempts`, `next_attempt_at`, `last_error`, `buyer_token_digest`, `buyer_token_expires_at` |
| `spree_pos_einvoice_settings` | `store_id`, `branch_id` (nullable = mặc định store), `provider`, `credentials` (encrypted), `template_code`, `symbol`, `seller_name`, `seller_address`, `consumer_label`, `status` |
| `spree_pos_store_profiles` | thêm `einvoice_type` (`none|cash_register|coded`, mặc định `none`) |

Migration: `create_pos_einvoices`, `create_pos_einvoice_settings`, `add_einvoice_type_to_pos_store_profiles`. Index: `(store_id, status, next_attempt_at)`.

### Server

- `server/app/services/spree/pos/einvoice.rb` (registry), `einvoice/provider.rb` (interface), `einvoice/sandbox_provider.rb`, `einvoice/vnpt_provider.rb` (adapter VNPT, dùng web service hóa đơn của VNPT theo tài liệu tích hợp họ cấp cho đối tác), `einvoice/builder.rb` (snapshot dòng + thuế từ order và `Workspace#to_pos`).
- `server/app/workflows/spree/pos/einvoices/`:
  - `enqueue.rb`, gọi trong `workspaces/complete.rb`;
  - `issue.rb` (idempotent theo `order_id`: đã `issued` thì bỏ qua);
  - `update_buyer.rb`;
  - `cancel.rb`;
  - `retry.rb`.
- `DispatchOutboxJob` hiện chỉ đánh dấu processed. Thêm bảng định tuyến `event_type → handler` và handler `einvoice.issue`. Không đổi hành vi của các event_type đang có.
- Controller:
  - `api/v3/admin/pos/einvoices_controller.rb` (`index` có lọc "chưa có hóa đơn" / "lỗi", `show`, `update_buyer`, `retry`, `cancel`), capability mới `pos.einvoice.manage`;
  - `api/v3/admin/pos/einvoice_settings_controller.rb`;
  - `server/app/controllers/spree/pos/einvoice_buyer_controller.rb`: trang công khai cho khách tự nhập MST, có rate limit.
- Mẫu in: biến `einvoice.lookup_code`, `einvoice.lookup_url`, `einvoice.buyer_qr` trong `config/pos/receipt_template_variables.json`. QR tự nhập MST in trên bill khi store bật `einvoice_type`.
- Báo cáo: "Đơn chưa có hóa đơn" theo `business_date` / chi nhánh trong `reports_controller.rb`. Thêm "Doanh thu lũy kế năm" để cảnh báo mốc 1 tỷ.
- Audit: `einvoice.issued`, `einvoice.failed`, `einvoice.buyer_updated`, `einvoice.canceled`.
- OpenAPI: `Einvoice`, `EinvoiceSettings`.

### Client web

- `apps/pos/src/pages/settings/einvoice.tsx`: chọn loại hóa đơn, nhà cung cấp, thông tin đăng nhập (chỉ ghi, không hiện lại), ký hiệu theo chi nhánh, nút "Phát hành thử" (sandbox).
- `payment-panel.tsx`: ô "Khách lấy hóa đơn" (MST, tên, địa chỉ, email) trước khi kết thúc.
- `pages/orders.tsx` / `pages/receipt.tsx`: trạng thái hóa đơn của đơn, thêm thông tin người mua, phát hành lại.
- `apps/pos/src/pages/einvoices.tsx`: danh sách lỗi / chưa có hóa đơn, chạy lại hàng loạt.
- Trang khách tự nhập MST: HTML do server render, không thuộc `apps/pos`, để chạy được trên điện thoại khách mà không cần cài gì.

### File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `docs/legal/hddt-nd254-tt91.md` | create | Ghi chú văn bản gốc |
| `server/db/migrate/*` (3 file) | create | Như bảng Dữ liệu |
| `server/app/models/spree/pos/einvoice.rb`, `einvoice_setting.rb`, `store_profile.rb` | create / modify | Model |
| `server/app/services/spree/pos/einvoice*.rb` | create | Registry, adapter, builder |
| `server/app/workflows/spree/pos/einvoices/*.rb`, `workspaces/complete.rb` | create / modify | Phát hành |
| `server/app/jobs/spree/pos/dispatch_outbox_job.rb` | modify | Định tuyến handler |
| `server/app/controllers/spree/api/v3/admin/pos/einvoices_controller.rb`, `einvoice_settings_controller.rb`, `spree/pos/einvoice_buyer_controller.rb` | create | API, trang khách |
| `server/config/pos/receipt_template_variables.json` | modify | Biến hóa đơn |
| `apps/pos/src/pages/settings/einvoice.tsx`, `pages/einvoices.tsx`, `components/payment-panel.tsx` | create / modify | UI |
| `server/openapi/pos-staff.yaml` | modify | Schema |

### Các bước

1. Đọc NĐ 254/2026 và TT 91/2026 từ nguồn chính thức, viết `docs/legal/hddt-nd254-tt91.md`, rồi sửa danh sách trường của phần.
2. Viết migration, model và cấu hình.
3. Viết builder dòng và thuế, có spec cho đơn 8% + 10%, đơn có phí phục vụ, và dòng giờ (khi phần 11A chưa có thì dùng fixture).
4. Viết adapter sandbox và interface.
5. Gắn `enqueue` vào `complete.rb` và handler outbox. Spec: complete khi adapter lỗi vẫn thành công, hóa đơn ở trạng thái `failed` và được chạy lại.
6. Làm trang khách tự nhập MST và QR trên bill.
7. Làm UI cấu hình, danh sách lỗi, ô người mua ở thanh toán.
8. Làm báo cáo đơn chưa có hóa đơn và doanh thu lũy kế năm.
9. Viết adapter VNPT trong một commit riêng: lấy tài liệu tích hợp và tài khoản thử của VNPT, map trường từ builder, xử lý mã lỗi và chạy lại, rồi thử phát hành, tra cứu và hủy trên môi trường thử của VNPT. Spec của adapter dùng response mẫu ghi lại từ môi trường thử, không gọi mạng.
10. Ghi trong `docs/` cách thêm adapter cho nhà cung cấp khác (interface, đăng ký vào registry, spec mẫu).

### Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/einvoices/ spec/services/spree/pos/einvoice/ spec/requests/spree/pos/einvoices_spec.rb spec/requests/spree/pos/einvoice_buyer_spec.rb`
- Các ca phải có:
  - phát hành lặp lại vẫn chỉ ra một hóa đơn;
  - hai worker cùng claim thì chỉ một worker gọi adapter;
  - token tự nhập MST hết hạn hoặc sai thì bị từ chối;
  - store `none` thì không tạo outbox;
  - thông tin đăng nhập không xuất hiện trong response hay log.
- Hồi quy đường tiền: `pnpm spree rspec spec/workflows/spree/pos/workspaces/complete_spec.rb spec/integration/spree/pos/`.
- `pnpm --dir apps/pos test test:e2e`: thanh toán có nhập MST, đơn hiện trạng thái "Đã phát hành" với adapter sandbox.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Hiểu sai nội dung bắt buộc vì mới đọc qua nguồn thứ cấp | Bước 1 đọc văn bản gốc. Tên trường và nhãn là cấu hình. Nhờ kế toán của khách đầu tiên duyệt mẫu. |
| Phát hành trùng khi chạy lại | Unique `order_id` và trạng thái `issuing` có khóa. Adapter gửi mã tham chiếu idempotent (`order.prefixed_id`) nếu nhà cung cấp hỗ trợ. |
| Treo hàng đợi khi mất internet kéo dài | Backoff có trần. Báo cáo "chưa có hóa đơn" và cảnh báo trên trang trạng thái hệ thống (phần 5B). |
| Lộ thông tin đăng nhập nhà cung cấp | Mã hóa cột; API chỉ ghi, không đọc lại; lọc khỏi log. |

### Tiêu chí xong

- [ ] Có ghi chú văn bản gốc NĐ 254 / TT 91; trường hóa đơn khớp ghi chú đó. *(Đã có ghi chú và trường khớp ghi chú, nhưng ghi chú dựa trên nguồn thứ cấp: chưa mở được toàn văn chính thức.)*
- [x] Store chọn được loại hóa đơn; đơn complete tạo hóa đơn qua hàng đợi, không chặn complete.
- [x] Hóa đơn có thuế suất theo dòng; phí phục vụ và dòng giờ được hỗ trợ trong builder.
- [x] Khách tự nhập MST qua QR trên bill; thu ngân nhập được tại quầy.
- [x] Có danh sách hóa đơn lỗi / chưa có, chạy lại được; có cảnh báo mốc 1 tỷ.
- [x] Adapter sandbox chạy đầy đủ.
- [ ] Adapter VNPT phát hành, tra cứu và hủy được trên môi trường thử của VNPT.
- [x] Mỗi cửa hàng chọn được nhà cung cấp trong cài đặt; nhà cung cấp chưa có adapter không hiện trong danh sách.
- [ ] Spec POS và e2e web xanh.

### Kết quả

Trạng thái 11/11/2026: code server, `packages/pos-shared`, `apps/pos-dashboard` và `apps/pos` đã viết xong. Spec server, test web, typecheck và lint đã chạy. E2e Playwright chưa chạy được (xem lệnh 12). Chưa commit.

**Kết luận pháp lý** (chi tiết và nguồn S1–S27 trong [`docs/legal/hddt-nd254-tt91.md`](../../docs/legal/hddt-nd254-tt91.md))

- **Nguồn đã đọc.** Không mở được toàn văn chính thức. thuvienphapluat trả 403, và không tìm thấy bản trên vanban.chinhphu.vn hay congbao.chinhphu.vn. Mỗi điểm đều dựa trên ít nhất hai nguồn thứ cấp: công văn 4831/CT-CS của Cục Thuế [S2], KPMG [S3], Forvis Mazars [S4], Crowe [S17], rồi tới blog của MISA, einvoice.vn và các bên khác. Điểm nào chỉ có một nguồn được đánh dấu **[CHƯA XÁC MINH]**.
- **Hiệu lực.** NĐ 254/2026 và TT 91/2026 ban hành 30/06/2026, có hiệu lực từ 01/07/2026, thay NĐ 123/2020, NĐ 70/2025 và TT 32/2025 [S1]–[S5]. NĐ 141/2026 sửa NĐ 68/2026: hộ kinh doanh có doanh thu **trên** 1 tỷ đồng/năm phải dùng HĐĐT; quy định áp dụng hồi tố từ 01/01/2026 [S8], [S9].
- **Đối tượng.** F&B, bán lẻ và vui chơi giải trí thuộc nhóm dùng hóa đơn khởi tạo từ máy tính tiền (NĐ 254, Điều 6 khoản 1 điểm c). Cơ sở đã đăng ký loại hóa đơn khác thì không bắt buộc chuyển [S12], [S13].
- **Hóa đơn MTT.** Không bắt buộc chữ ký số. Chỉ ghi thông tin người mua khi người mua yêu cầu (MST, số định danh hoặc số điện thoại). Dữ liệu phải gửi cơ quan thuế trong ngày [S14], [S15].
- **Người mua không đưa thông tin.** Ghi đúng cụm "Bán cho người tiêu dùng" (Phụ lục, điểm 4b). Không dùng "Người mua không lấy hóa đơn" [S2], [S15].
- **Ký hiệu.** Mẫu số là 1 chữ số. Ký hiệu có 6 ký tự: `C`/`K`, hai số năm, `M` cho MTT hoặc `T`, rồi 2 ký tự tự đặt. Số hóa đơn tối đa 8 chữ số, do nhà cung cấp cấp [S5], [S19], [S20].
- **Thời điểm lập.** Ngoại lệ ban đêm 22h–6h có tồn tại, nhưng chỉ áp dụng cho người bán không có phần mềm lập hóa đơn tự động. POS là phần mềm tự động, nên phải lập ngay [S2], [S22]–[S24].
- **Xử lý sai sót.** Từ 01/07/2026 không còn thủ tục hủy hóa đơn đã lập; chỉ còn điều chỉnh hoặc thay thế [S27]. Hóa đơn MTT lập sai thì lập hóa đơn thay thế [S14], [S26].
- **Thuế suất.** Ghi theo từng dòng. Mức 8% áp dụng tới hết 31/12/2026 [S10], [S11].
- **Chưa xác minh.** Phí phục vụ và tiền boa.

**Đã làm**

- Server:
  - **Migration.**
    - `20261111170000_create_spree_pos_einvoices`. Các cột: `relation` (`original` / `replacement`), `original_einvoice_id`, buyer, seller, lines và totals dạng jsonb, `payment_method`, `currency`, `template_code`, `symbol`, `number`, `cqt_code`, `lookup_code`, `lookup_url`, `issued_at`, `signed_at`, `sent_to_cqt_at`, `attempts`, `next_attempt_at`, `last_error`, `buyer_token_expires_at`, `buyer_submitted_at`, `canceled_at`, `cancel_reason`. Unique `order_id` chỉ cho hóa đơn gốc; index `(store_id, status, next_attempt_at)`; có check constraint.
    - `20261111170100_create_spree_pos_einvoice_settings`. `credentials` mã hóa bằng Active Record Encryption. Thêm `seller_tax_code`, `lookup_url`, `buyer_link_hours`. Có một dòng mặc định cho store và một dòng riêng cho từng chi nhánh.
    - `20261111170200_add_einvoice_type_to_spree_pos_store_profiles`.
  - **Model.** Thêm `Einvoice` và `EinvoiceSetting`. `StoreProfile` có thêm `einvoice_type`. `Capabilities` có thêm `pos.einvoice.manage`. `ReceiptSnapshot#to_pos` thêm khối `einvoice`, đọc trực tiếp từ hóa đơn.
  - **Registry và adapter.**
    - Registry nằm ở `Spree::Pos::Einvoices` (`register`, `catalog`, `provider_for`).
    - `Einvoices::Provider` là interface: `issue`, `status`, `cancel`, `lookup_tax_code`, `credential_fields`, kèm `Result` và `Error` có `retryable`.
    - `SandboxProvider` sinh số hóa đơn, mã CQT và mã tra cứu tất định, và tra được MST.
    - Adapter được đăng ký trong `config/initializers/pos_einvoice_providers.rb`. Ở production, sandbox chỉ được đăng ký khi đặt `POS_EINVOICE_SANDBOX=on`.
  - **Builder.**
    - Mỗi dòng có thuế suất riêng, lấy từ `TaxLine`. Tổng thuế được cộng theo từng mức thuế suất.
    - Đơn vị lấy từ catalog đơn vị. Dòng tính giờ dùng đơn vị "giờ", số lượng làm tròn 2 chữ số.
    - Phí cấp đơn là dòng riêng có thuế: phí giao hàng, và phí phục vụ (kind `surcharge`).
    - Hình thức thanh toán là TM, CK hoặc TM/CK.
  - **Workflow.**
    - `Enqueue` chạy trong transaction của `Complete`, trước `ReceiptBuilder`. Builder lỗi thì snapshot để trống và Issue dựng lại sau, nên complete không bao giờ bị chặn.
    - `Issue`:
      - nhận hóa đơn bằng cách chuyển sang `issuing` rồi commit; gọi adapter ngoài mọi transaction; ghi kết quả bằng một commit riêng;
      - claim treo quá 10 phút thì coi như worker đã chết;
      - lịch thử lại 1, 5, 15, 60 phút, sau đó cứ 6 giờ;
      - che thông tin đăng nhập trong `last_error`;
      - audit `einvoice.issued`, và `einvoice.failed` chỉ ở lần lỗi đầu.
    - `UpdateBuyer` (quầy hoặc khách), `Replace` (hóa đơn thay thế cho hóa đơn đã phát hành, đánh dấu bản gốc `replaced`), `Cancel` (chỉ bản chưa gửi nhà cung cấp), `Retry` (tối đa 100 hóa đơn).
    - `SaveSettings`: thông tin đăng nhập chỉ ghi; payload chỉ lưu HMAC; nhà cung cấp phải đã đăng ký; audit `einvoice_settings.change` không chứa giá trị bí mật.
  - **Outbox.** `DispatchOutboxJob` có thêm bảng `HANDLERS`, hiện chỉ một mục là `einvoice.issue`. Mỗi lượt giữ entry 15 phút; handler có thể hẹn lại entry sang `available_at` muộn hơn; handler ném lỗi thì entry quay lại `pending` sau 5 phút. Các event_type khác vẫn được đánh dấu processed như trước.
  - **Controller và route.**
    - `einvoices_controller`: `index` (lọc `outstanding`, từng trạng thái, số đơn), `show`, `summary`, `update_buyer`, `retry_issue`, `cancel`, `replace`.
    - `einvoice_settings_controller`: `show`, `update`, `sample` (route `einvoice_settings/test`).
    - `Spree::Pos::EinvoiceBuyerController` phục vụ `GET/POST /pos_einvoice/:token`: HTML không JavaScript, token ký có hạn, rate limit 30 lần/phút, CSP chặt, `no-store`, có nút tra MST.
  - **Bill.** Thêm biến `einvoice.lookup_code`, `einvoice.lookup_url`, `einvoice.buyer_qr`. Footer tự in QR "Quét mã để nhập thông tin xuất hóa đơn" khi liên kết còn mở. Golden mới `sale-einvoice.json`; renderer TypeScript cũng cập nhật để khớp.
  - **Khác.** Context trả `einvoice_type`. `filter_parameters` thêm `credentials`. OpenAPI `pos-staff.yaml` có 9 đường mới, 8 schema mới và `Context.einvoice_type`.
- `packages/pos-shared`: capability `pos.einvoice.manage` (nhãn vi / en); `PosContext.einvoice_type`; `ReceiptSnapshot.einvoice`; biến và QR trong renderer; nhãn `receiptEinvoiceBuyerCaption`.
- `apps/pos-dashboard`:
  - `/settings/einvoice` (trong mục Cài đặt, chỉ cho quản trị store):
    - loại hóa đơn;
    - nhà cung cấp, chỉ gồm các bên đã đăng ký;
    - thông tin đăng nhập kiểu password, chỉ ghi, có ghi chú "Đã lưu";
    - mẫu số, ký hiệu, người bán, nhãn người tiêu dùng, trang tra cứu, thời hạn liên kết, trạng thái, cấu hình theo store hoặc theo chi nhánh;
    - nút "Phát hành thử" cho sandbox.
  - `/einvoices` (nhóm Bán hàng):
    - mặc định hiện hóa đơn chưa phát hành, có lọc trạng thái và tìm số đơn;
    - thử lại từng hóa đơn hoặc tất cả hóa đơn lỗi;
    - sửa thông tin người mua, hủy (có xác nhận và lý do), lập hóa đơn thay thế;
    - thẻ tóm tắt doanh thu năm so với mốc 1 tỷ, cảnh báo ở 80% và 100%.
  - Quyền mới trong `pos-access.ts` (`canManageEinvoices`), nav, nhóm quyền và khóa i18n `einvoices.*`, `einvoiceSettings.*`.
- `apps/pos`:
  - `payment-panel.tsx` có mục "Khách lấy hóa đơn" (có thể thu gọn), hiện khi `context.einvoice_type !== 'none'`. Mục gồm MST, tên, địa chỉ, email, điện thoại, số định danh, hộ chiếu, quốc tịch, ghi chú. Thông tin được gửi kèm `einvoice_buyer` trong cả bốn đường complete, kể cả bán nợ.
  - Lỗi `einvoice_buyer_invalid` được báo theo tên trường.
  - E2e `e2e/einvoice-buyer.spec.ts` và fixture `retail-api.ts` (`einvoiceType`, từ chối MST thiếu tên hoặc địa chỉ).
- Docs: [`docs/einvoice-providers.md`](../../docs/einvoice-providers.md) mô tả luồng phát hành, cách thêm adapter và quy tắc lưu thông tin đăng nhập.

**Lệch so với plan, đã chấp nhận**

- **Unique `order_id`.** Ràng buộc chỉ áp cho hóa đơn gốc (partial index). Hóa đơn thay thế là một dòng riêng, có `original_einvoice_id`, theo ghi chú pháp lý mục 7 và 11.
- **Trạng thái.** Thêm `replaced`. `canceled` chỉ dùng cho hóa đơn chưa gửi nhà cung cấp, vì không còn thủ tục hủy hóa đơn đã lập. Chưa làm hóa đơn điều chỉnh: trạng thái `adjusted` có nhưng chưa có luồng nào dùng.
- **Token người mua.** Không có cột `buyer_token_digest`. Token là `signed_id` có `purpose` và `expires_at`. Hạn mặc định là cuối ngày kinh doanh, hoặc theo `buyer_link_hours`.
- **Thời gian chờ thông tin người mua.** Khi khách chưa đưa thông tin và server có địa chỉ công khai, Issue chờ 10 phút (không quá cuối ngày lịch), để thông tin khách nhập qua QR kịp vào hóa đơn gốc. Không có địa chỉ công khai thì phát hành ngay và bill không in QR.
- **Cài đặt.** Bảng thêm `seller_tax_code`, `lookup_url`, `buyer_link_hours`. Buyer thêm `personal_id`, `phone`, `passport_no`, `nationality`, theo ghi chú pháp lý.
- **Tên module.** Registry là `Spree::Pos::Einvoices` (số nhiều, cùng tên namespace với workflow). Spec nằm trong `einvoices/`, không phải `einvoice/`.
- **Báo cáo.** "Chưa có hóa đơn" và "doanh thu lũy kế" là `GET /einvoices?status=outstanding` và `GET /einvoices/summary`, không nằm trong `reports_controller`. Doanh thu năm là tổng `spree_orders.total` của đơn POS đã hoàn tất theo `business_date`, **chưa trừ trả hàng**.
- **Giao diện.** Cài đặt và danh sách nằm ở `apps/pos-dashboard` (theo `apps/pos/AGENTS.md`). `apps/pos` chỉ có ô người mua lúc thanh toán. Chưa thêm trạng thái hóa đơn vào `orders.tsx` / màn bill; bill đọc thông tin hóa đơn trực tiếp qua `ReceiptSnapshot#to_pos`.
- **Phí phục vụ.** Spree 6.0.3 không có kind `service_charge` trong `Spree::Fee::KINDS`. Builder coi `surcharge` là phí phục vụ. Phần 8A cần ghi phí phục vụ bằng kind này.
- **Spec doanh thu.** Spree giới hạn mỗi đơn dưới 100 triệu, nên spec cảnh báo 1 tỷ hạ mốc xuống bằng `stub_const`.
- **Adapter VNPT.** Không viết, vì không tìm được tài liệu API công khai và không có tài khoản thử. Interface và hướng dẫn đã sẵn cho việc thêm sau.

**Lệnh đã chạy**

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `pnpm spree migrate`, rồi `pnpm spree exec bin/rails db:test:prepare` | 3 migration chạy xong. Dump viết lại 67 dòng check constraint cũ; đã trả về đúng bản đã commit, nên diff `schema.rb` chỉ có phần thêm |
| 2 | `pnpm spree rspec spec/services/spree/pos/einvoices/ spec/workflows/spree/pos/einvoices/` | Lần đầu lỗi 3: đơn vị 'Cái', audit lỗi bị ghi hai lần, kind phí không hợp lệ. Đã sửa; lần sau qua hết |
| 3 | `pnpm spree rspec spec/requests/spree/pos/einvoices_spec.rb spec/requests/spree/pos/einvoice_buyer_spec.rb` | Lỗi YAML trong `pos-staff.yaml` (một dòng mô tả bị xuống dòng) và giới hạn 100 triệu/đơn. Đã sửa; 6/6 và 6/6 qua |
| 4 | `pnpm spree rspec spec/services/spree/pos/print_documents_spec.rb` | Lần đầu ghi golden `sale-einvoice.json`. Đã xem lại; chạy lại 20/20 qua |
| 5 | Hồi quy: `complete_spec`, `system_status`, `onboarding`, `topology`, `topology_access`, `printers`, `devices`, `settlement`, `return_recovery`, `settlement_recovery`, `traceable_inventory`×2, `concurrency_faults`, `fulfillment_returns`, `spec/integration/spree/pos/`, `spec/models/spree/pos/`, `receipt_store_profile`, `receipts_displays`, `receipt_templates`, `receipt_template_schema` | 318/318 qua |
| 6 | `pnpm spree exec bundle exec rubocop -a` trên file server mới | Đã sửa layout. Còn `Metrics/ParameterLists` ở `Replace.call` và `SaveSettings.call`, và `Naming/PredicateMethod` ở `cancel` (cùng kiểu workflow có sẵn). `complete.rb` vẫn còn các cảnh báo Metrics như trước khi sửa |
| 7 | Chạy lại lệnh 2–4 cùng `devices_spec` sau rubocop | 48/49 qua. Ca còn lỗi là `print_documents_spec.rb:144` (schema dùng chung): `pos-staff.yaml` vừa có thêm `invert` cho khối text và các kind in bếp do phiên song song thêm, `schema.json` chưa cập nhật theo. Không do phần này (lệnh 4 đã qua trước thay đổi đó) |
| 8 | `packages/pos-shared`: `typecheck`, `test`, `lint` | tsc sạch; 250/250 qua, gồm golden `sale-einvoice` ở phía TypeScript; biome sạch sau khi format 2 file |
| 9 | `apps/pos-dashboard`: `vite build` (sinh lại `routeTree.gen.ts`), `typecheck`, `test`, `lint` | build qua; tsc sạch; 88/88 qua; biome sạch |
| 10 | `apps/pos`: `typecheck`, `test`, `lint` | tsc sạch; 256/256 qua (đã sửa số capability từ 22 lên 23); biome sạch |
| 11 | Đã kiểm `server/config/recurring.yml` | `DispatchOutboxJob` vẫn chạy mỗi phút; không đổi |
| 12 | `pnpm --dir apps/pos exec playwright test e2e/einvoice-buyer.spec.ts --project desktop` | Chưa chạy được: máy chưa cài trình duyệt Playwright (`chromium_headless_shell-1248` không có). Cài cần tải về, chưa được phép nên không cài |

**Còn mở**

- **Adapter VNPT** và các nhà cung cấp thật khác (MISA, Viettel):
  - cần tài liệu tích hợp, tài khoản thử và response mẫu để viết spec;
  - cần xác nhận nhà cung cấp có khóa chống trùng hay không.
- **Đăng ký sử dụng HĐĐT** với cơ quan thuế và lấy mẫu số, ký hiệu thật từ nhà cung cấp. Đây là việc của từng cửa hàng; mẫu tờ khai theo TT 91 chưa được đối chiếu.
- **Đối chiếu toàn văn chính thức** của NĐ 254 và TT 91 (Điều 9 khoản 5, Điều 10 khoản 4, Phụ lục điểm 4 và 9), và nhờ kế toán của khách đầu tiên duyệt mẫu.
- **Ký tự đầu của ký hiệu MTT** là `C` hay `K` dưới TT 91. Ký hiệu mặc định `C<yy>MYY` / `C<yy>TYY` chỉ dùng tạm khi chưa cấu hình.
- **Tiền boa và phí phục vụ** trên hóa đơn: hỏi kế toán. Builder hiện đưa phí phục vụ vào hóa đơn và không có dòng tip, vì phần 9B chưa có.
- **Hóa đơn điều chỉnh** (01/BK-ĐCTT) và **thông báo sai sót 04/SS** chưa làm; mới có hóa đơn thay thế.
- **Quy tắc thời điểm lập.** `issued_at` lấy theo nhà cung cấp, không phải thời điểm complete; phụ thuộc nhà cung cấp có cho truyền thời điểm lập hay không. Chưa có cảnh báo "gần cuối ngày mà hóa đơn MTT chưa gửi", và chưa nối vào trang trạng thái hệ thống, vì file đó thuộc phiên song song.
- **QR trên bill** chỉ in khi server có `POS_PUBLIC_BASE_URL`.
- **Doanh thu năm** chưa trừ trả hàng.
- **Thông tin người mua ở trình duyệt.** Buyer nhập tại quầy đi cùng intent complete, mà intent này được lưu trong trình duyệt để phục hồi giao dịch tiền. Vì vậy thông tin người mua nằm trong storage của trình duyệt tới khi lệnh xong.
- **E2e.** Chưa chạy `e2e/einvoice-buyer.spec.ts` (lệnh 12). Chưa có e2e cho `/einvoices` và `/settings/einvoice` của dashboard. Chưa chạy full suite.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
