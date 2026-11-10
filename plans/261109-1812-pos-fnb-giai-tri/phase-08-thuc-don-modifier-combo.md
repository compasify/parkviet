---
phase: 8
title: "Thực đơn, modifier, combo"
status: pending
effort: "8 ngày"
dependsOn: [1]
---

# Phase 8: Thực đơn, modifier, combo (`fnb.menu`)

## Overview

Phase này đưa module `fnb.menu` vào server và vào màn thu ngân web:
- Món là sản phẩm Spree, có thêm một bảng cấu hình phía POS. Size là variant.
- Modifier gồm size, đường, đá, topping, ghi chú, chia theo nhóm có min/max và có giá cộng thêm.
- Có combo, thực đơn theo khung giờ (giá giờ vàng) và báo hết món theo chi nhánh.
- Màn bán `menu_grid` gồm lưới món có ảnh và bảng tùy chọn hiện trên một màn.

**Server luôn tính giá dòng**: giá gốc (hoặc giá theo khung giờ) + Σ(số lượng × giá cộng của tùy chọn). Client không gửi giá.

Phase 1 đã có registry `SaleLineKinds`, `Workspace.service_mode`, `business_date` và thuế theo món qua `TaxCategory`. Phase này thêm kind `menu` vào registry đó.

## Quyết định của phase

1. **Món = `Spree::Product`, size = `Spree::Variant`.** Cấu hình POS nằm ở `spree_pos_menu_items` (một dòng cho mỗi product mỗi store). Thuế suất theo món đọc từ `tax_category` của product mà phase 1 đã chuẩn hóa. Phase này chỉ cho chọn tax category trong màn sửa món.
2. **Modifier là dữ liệu POS, không phải variant Spree.** Một tùy chọn có thể trỏ tới một variant nguyên liệu (`variant_id`, không bắt buộc); phase 11 dùng trường này để trừ kho.
3. **Hai bộ tùy chọn khác nhau là hai dòng.** `SaleLine.build_merge_key` có thêm phần `modifier_signature`, là SHA-256 của danh sách `option_id:quantity` đã sắp xếp cộng ghi chú đã chuẩn hóa. Phần này chỉ được nối vào khi có, để key của dòng bán lẻ cũ giữ nguyên (cùng cách đang làm với `expiry_on`).
4. **Combo là một món có `kind = combo`.** Giá nằm ở dòng combo; thành phần lưu snapshot ở `spree_pos_line_components` và không tạo `LineItem` riêng. Cờ `show_components_on_kds` quyết định phiếu bếp (phase 9) in món con hay chỉ in tên combo.
5. **Giữ D5 của plan bán lẻ: module không chặn việc bán.** Chi nhánh tắt `fnb.menu` vẫn bán được món như dòng `ordinary` với giá gốc. Chỉ lệnh gắn tùy chọn bị từ chối (`module_disabled`).
6. **Hết món** lưu theo chi nhánh và tự hết hạn ở cuối `business_date`. Thêm món đang hết bị từ chối (`Conflict reason: 'menu_item_sold_out'`) và phát `menu.sold_out` qua `BranchChannel`.
7. **Giá theo khung giờ** được chọn ở thời điểm thêm dòng, theo `Workspace.database_now` và `timezone` của chi nhánh. Dòng đã thêm giữ giá cũ, kể cả khi khung giờ đã qua.

## Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_menu_categories` | `store_id`, `name`, `position`, `color`, `active` | unique `(store_id, name)` |
| `spree_pos_menu_items` | `store_id`, `product_id`, `menu_category_id`, `kind` (`single`/`combo`), `kitchen_category` (key `[a-z_]{2,40}`, phase 9 dùng để định tuyến), `cup_label` (bool, phase 10), `show_components_on_kds` (bool), `position`, `active` | unique `(store_id, product_id)`; check `kind` |
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

## Server

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
- **OpenAPI:** thêm schema `Menu`, `MenuItem`, `ModifierGroup`, `LineModifier` và các endpoint trên vào `server/openapi/pos-staff.yaml`. App Flutter dùng `GET menu` ở phase 9 và 15.
- **Module:** đổi `fnb.menu` từ `planned` sang `register` trong `config/initializers/pos_modules.rb` (depends_on: []). Profile chỉ chuyển sang `available` ở phase 12.

## Client web (`apps/pos`)

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

## File

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

## Các bước

1. Viết migration và model, kèm spec model: validation min/max, ràng buộc unique, snapshot không đổi khi tùy chọn gốc bị sửa.
2. Viết `Menu::Pricing`, kèm spec cho khung giờ vắt qua 0h, size, topping có số lượng, nhóm bắt buộc, món ẩn.
3. Viết kind handler `menu` và nối vào `ManageLineItem.add`. Spec bắt buộc: merge key của dòng `ordinary` / `measured` / `tracked` không đổi (so với giá trị cố định trong spec).
4. Viết `UpdateLineModifiers`, kèm spec về gộp dòng và về lỗi khi snapshot đã khóa.
5. Viết hết món: workflow, sự kiện `menu.sold_out`, tự hết hạn theo `business_date`.
6. Viết controller, route, quyền và audit; cập nhật OpenAPI. Request spec kiểm response theo schema (cách kiểm do phase 5 dựng).
7. Viết ReceiptBuilder và DisplayState: hiện tùy chọn trên hóa đơn và trên màn khách.
8. Viết client: `use-menu`, `menu-grid`, `modifier-sheet`, sửa `order-lines`, trang cài đặt thực đơn.
9. Đăng ký `fnb.menu` là module `available`, rồi chạy lại toàn bộ spec POS và e2e bán lẻ.

## Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/menu_item_spec.rb spec/services/spree/pos/menu/pricing_spec.rb`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/manage_line_item_spec.rb spec/workflows/spree/pos/workspaces/update_line_modifiers_spec.rb`
- `pnpm spree rspec spec/requests/spree/pos/menu_spec.rb spec/requests/spree/pos/menu_availabilities_spec.rb`
- Hồi quy: `pnpm spree rspec spec/requests/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`
- Web: `pnpm --dir apps/pos lint typecheck test`. E2E mới `apps/pos/e2e/fnb-menu.spec.ts` chạy 4 tình huống:
  - thêm 2 ly khác topping → 2 dòng;
  - "Thêm ly giống vậy" → số lượng 2;
  - món hết bị từ chối;
  - giá giờ vàng.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Đổi merge key làm vỡ việc gộp dòng bán lẻ | Signature chỉ được nối vào khi có; spec cố định giá trị key cũ |
| Giá dòng không đi qua `price_override` thì thành lỗ hổng đặt giá tùy ý | Client không gửi được giá: giá chỉ đến từ `Menu::Pricing` với dữ liệu server. Còn giảm giá tay vẫn đi qua `Approval` như hiện tại |
| Thực đơn lớn làm chậm lưới | Một endpoint đọc có `etag`; ảnh dùng URL thu nhỏ của Spree |

## Tiêu chí xong

- [ ] Thêm món với tùy chọn ra đúng giá ở server; hai bộ tùy chọn khác nhau là hai dòng.
- [ ] Combo hiện thành phần trong đơn, trên hóa đơn và trong `to_pos`.
- [ ] Giá theo khung giờ áp đúng, kể cả với khung vắt qua 0h.
- [ ] Món hết bị từ chối, sự kiện `menu.sold_out` được phát, và trạng thái hết tự hết hạn sang ngày kinh doanh mới.
- [ ] Chi nhánh tắt `fnb.menu` vẫn bán được món bằng giá gốc.
- [ ] OpenAPI cập nhật; spec POS và e2e bán lẻ không lỗi mới.
