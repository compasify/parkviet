---
phase: 11
title: "Công thức và trừ kho"
status: pending
effort: "5 ngày"
dependsOn: [8]
---

# Phase 11: Công thức và trừ kho (`fnb.recipes`)

## Overview

Bán một ly trà sữa size L, thêm trân châu, thì kho phải trừ đúng lượng trà, sữa, đường và trân châu. Phase này gồm:
- công thức cho từng **variant** (size) và cho từng **tùy chọn modifier**;
- trừ nguyên liệu **khi complete**, idempotent;
- cảnh báo nguyên liệu sắp hết;
- dữ liệu giá vốn để báo cáo lãi gộp theo món.

Research xếp `fnb.recipes` ở F2, nhưng plan chuyển nó lên F1 (D10) vì với cafe đây là tính năng bắt buộc.

## Quyết định của phase

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

## Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_recipes` | `store_id`, `owner_type` (`Spree::Variant` / `Spree::Pos::ModifierOption`), `owner_id`, `version`, `active` | unique `(owner_type, owner_id, version)`; mỗi owner có một bản `active` (partial unique) |
| `spree_pos_recipe_ingredients` | `recipe_id`, `ingredient_variant_id`, `quantity` decimal(12,4) > 0, `unit_code` | unique `(recipe_id, ingredient_variant_id)` |
| `spree_pos_recipe_consumptions` | `store_id`, `branch_id`, `workspace_id`, `order_id`, `sale_line_id`, `ingredient_variant_id`, `stock_location_id`, `base_quantity`, `recipe_id`, `recipe_version`, `source_key` (`variant`, `modifier:<option_id>`, `component:<variant_id>`), `unit_cost`, `business_date` | unique `(sale_line_id, ingredient_variant_id, source_key)` |
| `spree_pos_stock_alerts` | `branch_id`, `variant_id`, `min_quantity` (đơn vị gốc) | unique `(branch_id, variant_id)` |

Migration: `create_spree_pos_recipe_tables`, `create_spree_pos_stock_alerts`.

## Server

- **Model:** `Recipe`, `RecipeIngredient`, `RecipeConsumption`, `StockAlert`.
- **`Spree::Pos::Recipes::Expand.call(sale_line)`** trả về danh sách `(ingredient, base_quantity, source_key, recipe)` theo ba nguồn:
  - công thức của variant × số lượng dòng;
  - Σ công thức của từng tùy chọn × số lượng tùy chọn × số lượng dòng (đọc `LineModifier` của phase 8);
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

## Client web (`apps/pos`)

- **Tab Công thức** trong màn sửa món (`pages/settings/menu.tsx`):
  - mỗi size một bảng nguyên liệu: chọn variant, số lượng, đơn vị;
  - mỗi tùy chọn có công thức riêng nếu cần;
  - hiện giá vốn ước tính theo `cost_price` hiện tại.
- **Trang Nguyên liệu sắp hết:** đặt ngưỡng; danh sách nằm trong mục kho.
- **`pages/reports.tsx`** thêm hai báo cáo "Tiêu hao nguyên liệu" và "Lãi gộp theo món", có xuất file theo cơ chế export hiện có.

## File

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

## Các bước

1. Đọc `StockIntegration.adjust!` và `Spree::StockLevel` để xác nhận cách tồn âm (quyết định 3), rồi ghi kết luận vào phase này.
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

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/recipes/expand_spec.rb spec/workflows/spree/pos/recipes/`
- `pnpm spree rspec spec/workflows/spree/pos/workspaces/complete_spec.rb spec/requests/spree/pos/recipes_spec.rb spec/requests/spree/pos/reports_spec.rb`
- Hồi quy kho và trả hàng: `pnpm spree rspec spec/requests/spree/pos/returns_spec.rb spec/services/spree/pos/stock_integration_spec.rb`
- Web: `pnpm --dir apps/pos lint typecheck test`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Trừ kho trong transaction làm chậm complete khi đơn có nhiều ly | Gom theo nguyên liệu trước khi `adjust!`; mỗi nguyên liệu khóa một `StockLevel` |
| Deadlock khi hai máy complete cùng lúc trên cùng nguyên liệu | Khóa `StockLevel` theo thứ tự `variant_id` tăng dần |
| Chủ quán bật module khi món đang có tồn | Cảnh báo kèm xác nhận; không tự xóa tồn |

## Tiêu chí xong

- [ ] Bán món có size và tùy chọn trừ đúng nguyên liệu theo đơn vị gốc, idempotent.
- [ ] Thiếu nguyên liệu không chặn việc bán và có ghi discrepancy.
- [ ] Trả hàng hoặc hủy món F&B không nhập lại nguyên liệu; trả hàng bán lẻ không đổi.
- [ ] Có cảnh báo sắp hết, báo cáo tiêu hao và báo cáo lãi gộp theo món.
