---
phase: 6
title: "Thực đơn, công thức, hóa đơn điện tử"
status: pending
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

- [ ] Thêm món với tùy chọn ra đúng giá ở server; hai bộ tùy chọn khác nhau là hai dòng.
- [ ] Combo hiện thành phần trong đơn, trên hóa đơn và trong `to_pos`.
- [ ] Giá theo khung giờ áp đúng, kể cả với khung vắt qua 0h.
- [ ] Món hết bị từ chối, sự kiện `menu.sold_out` được phát, và trạng thái hết tự hết hạn sang ngày kinh doanh mới.
- [ ] Chi nhánh tắt `fnb.menu` vẫn bán được món bằng giá gốc.
- [ ] OpenAPI cập nhật; spec POS và e2e bán lẻ không lỗi mới.

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

- [ ] Bán món có size và tùy chọn trừ đúng nguyên liệu theo đơn vị gốc, idempotent.
- [ ] Thiếu nguyên liệu không chặn việc bán và có ghi discrepancy.
- [ ] Trả hàng hoặc hủy món F&B không nhập lại nguyên liệu; trả hàng bán lẻ không đổi.
- [ ] Có cảnh báo sắp hết, báo cáo tiêu hao và báo cáo lãi gộp theo món.

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

- [ ] Có ghi chú văn bản gốc NĐ 254 / TT 91; trường hóa đơn khớp ghi chú đó.
- [ ] Store chọn được loại hóa đơn; đơn complete tạo hóa đơn qua hàng đợi, không chặn complete.
- [ ] Hóa đơn có thuế suất theo dòng; phí phục vụ và dòng giờ được hỗ trợ trong builder.
- [ ] Khách tự nhập MST qua QR trên bill; thu ngân nhập được tại quầy.
- [ ] Có danh sách hóa đơn lỗi / chưa có, chạy lại được; có cảnh báo mốc 1 tỷ.
- [ ] Adapter sandbox chạy đầy đủ.
- [ ] Adapter VNPT phát hành, tra cứu và hủy được trên môi trường thử của VNPT.
- [ ] Mỗi cửa hàng chọn được nhà cung cấp trong cài đặt; nhà cung cấp chưa có adapter không hiện trong danh sách.
- [ ] Spec POS và e2e web xanh.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
