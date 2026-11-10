---
phase: 28
title: "Hoa hồng tài xế / phụ xe ở trạm dừng"
status: pending
effort: "4 ngày"
dependsOn: [12, 16]
---

# Phase 28: Hoa hồng tài xế / phụ xe ở trạm dừng (`fnb.vehicle_commission`)

## Overview

Trạm dừng nghỉ thường trả hoa hồng cho tài xế hoặc phụ xe đưa khách vào ăn và mua hàng. Phase này ghi nhận **lượt xe**, gắn các đơn bán trong lượt đó vào xe, tính hoa hồng và chi tiền cho tài xế từ ngăn kéo qua luồng chi tiền đã có.

Cách tính đã chốt ngày 09/11/2026 là **cả hai**:
- **theo xe**: mỗi lượt xe một khoản cố định, có thể khác nhau theo loại xe (16, 29, 45 chỗ);
- **theo khách**: số khách × đơn giá.

Một quy tắc có thể dùng một trong hai cách hoặc cả hai cộng lại. Hoa hồng theo % doanh thu không có trong lựa chọn đã chốt. Nếu cần thì thêm loại quy tắc `revenue_percent` theo cùng mô hình, không phải đổi bảng.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Hoa hồng là **chi phí của quán**, không giảm doanh thu đơn và không đụng hóa đơn điện tử. Đơn của khách vẫn tính đủ giá. |
| Q2 | **Lượt xe** (`VehicleVisit`) do thu ngân hoặc nhân viên đón xe mở. Lượt gồm biển số, nhà xe, loại xe, tên và số điện thoại tài xế / phụ xe, số khách (nhập hoặc sửa được đến khi chốt), giờ đến. Lượt tự đóng sau `visit_window_minutes` (mặc định 60 phút) hoặc khi bấm "Xe đã đi". |
| Q3 | Đơn bán được gắn vào một lượt xe đang mở bằng nút chọn xe trên màn bán (`Workspace.vehicle_visit_id`). Gắn hay đổi lượt chỉ làm được trước khi complete. Số khách để tính hoa hồng là số nhập trên lượt, không suy ra từ số đơn. |
| Q4 | Quy tắc hoa hồng (`CommissionRule`) gắn với chi nhánh và có thể gắn riêng nhà xe. Mỗi quy tắc có: `per_vehicle_amount` theo loại xe, `per_guest_amount`, điều kiện tối thiểu (số khách hoặc doanh thu tối thiểu của lượt), và thời gian hiệu lực. Quy tắc riêng của nhà xe được ưu tiên hơn quy tắc chung của chi nhánh. |
| Q5 | Khi chốt lượt, server tính hoa hồng và lưu **snapshot** gồm quy tắc, số khách, doanh thu lượt và số tiền. Sửa quy tắc sau đó không làm đổi lượt đã chốt. |
| Q6 | Chi hoa hồng bằng tiền mặt đi qua `CashMovementRequest` kind `cash_out` có lý do "Hoa hồng xe <biển số>". Luồng duyệt có sẵn của request này được giữ nguyên. Một lượt chỉ chi được một lần (unique theo `vehicle_visit_id`). Chi bằng chuyển khoản thì chỉ ghi nhận "đã chi" kèm mã giao dịch, không đụng ngăn kéo. |
| Q7 | Sửa số khách hoặc số tiền **sau khi chốt** cần `Approval` action `vehicle_visit.adjust`, và có ghi `AuditEntry`. |

## Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_bus_operators` (nhà xe) | `store_id`, `name`, `phone`, `note`, `status` | unique `(store_id, name)` |
| `spree_pos_vehicle_visits` | `store_id`, `branch_id`, `bus_operator_id` (nullable), `plate`, `vehicle_type` (`seat_16|seat_29|seat_45|other`), `driver_name`, `driver_phone`, `guest_count`, `arrived_at`, `closed_at`, `status` (`open|closed|paid|voided`), `business_date`, `opened_by_id`, `commission_snapshot jsonb`, `commission_amount`, `paid_at`, `payout_method` (`cash|transfer`), `cash_movement_request_id`, `transfer_reference` | index `(branch_id, business_date)`, `(branch_id, plate, status)` |
| `spree_pos_commission_rules` | `store_id`, `branch_id`, `bus_operator_id` (nullable), `per_vehicle_amounts jsonb` (theo `vehicle_type`), `per_guest_amount`, `min_guests`, `min_revenue`, `starts_on`, `ends_on`, `status` | check ít nhất một trong hai khoản lớn hơn 0 |
| `spree_pos_workspaces` (sửa) | `vehicle_visit_id` (nullable, FK) | index |

Migration: `create_pos_bus_operators_and_vehicle_visits`, `create_pos_commission_rules`, `add_vehicle_visit_to_pos_workspaces`.

Số điện thoại tài xế là dữ liệu cá nhân: chỉ hiện cho người có quyền `pos.vehicle_visit.manage`, và không có trong file xuất trừ khi người xuất có quyền đó.

## Server

- Model `BusOperator`, `VehicleVisit`, `CommissionRule` (có `has_prefix_id`).
- Workflow trong `server/app/workflows/spree/pos/vehicle_visits/`:
  - `open.rb`: mở lượt; cảnh báo nếu cùng biển số đã có lượt mở trong ngày;
  - `attach_workspace.rb`: gắn hoặc bỏ gắn đơn; từ chối khi đơn đã complete (`Conflict reason: 'workspace_completed'`);
  - `close.rb`: chốt lượt, chọn quy tắc, tính doanh thu lượt từ các đơn đã complete, lưu snapshot;
  - `pay.rb`: tạo `CashMovementRequest` `cash_out` hoặc ghi chuyển khoản; idempotent theo key;
  - `adjust.rb`: sửa sau chốt, dùng `Approval` `vehicle_visit.adjust`;
  - `void.rb`: hủy lượt chưa chi.
- Job tự đóng lượt quá `visit_window_minutes` (dùng Solid Queue đã có).
- Service `Spree::Pos::VehicleCommission::Calculator`: `per_vehicle_amounts[vehicle_type] + per_guest_amount × guest_count`, kiểm điều kiện tối thiểu. Spec phủ các tổ hợp.
- Báo cáo `Spree::Pos::Reports::VehicleCommissions` theo ngày kinh doanh, nhà xe và biển số: số lượt, số khách, doanh thu lượt, hoa hồng, đã chi / chưa chi, tỷ lệ hoa hồng trên doanh thu. Xuất CSV qua `export_file.rb`.
- Capability: `pos.vehicle_visit.operate` (mở lượt, gắn đơn), `pos.vehicle_visit.manage` (quy tắc, nhà xe, chi, sửa).
- API dưới `api/v3/admin/pos/`: `vehicle_visits` (index, create, `:id/close`, `:id/pay`, `:id/adjust`, `:id/void`), `workspaces/:id/vehicle_visit`, `bus_operators`, `commission_rules`. Cập nhật `server/openapi/pos-staff.yaml`.
- Sự kiện realtime: phát `workspace.updated` khi gắn đơn. Không thêm sự kiện mới.
- Module `fnb.vehicle_commission` đăng ký là `available`, thêm vào `optional_modules` của hồ sơ `cang_tin_tram_dung`.

## Client web (`apps/pos`)

- Thanh "Xe đang ở trạm" trên màn bán: danh sách lượt đang mở (biển số, nhà xe, số khách, thời gian còn lại). Có nút "Xe mới" và nút gắn đơn đang mở vào một xe.
- Màn "Lượt xe": lọc theo ngày và trạng thái, chốt lượt, xem tính toán, chi tiền (mở luồng chi tiền ngăn kéo có sẵn), sửa có duyệt.
- Cài đặt: nhà xe, quy tắc hoa hồng (bảng theo loại xe + đơn giá theo khách).
- Báo cáo hoa hồng xe ở trang Báo cáo.

## File

| Đường dẫn | Hành động | Nội dung |
|---|---|---|
| `server/db/migrate/*_create_pos_bus_operators_and_vehicle_visits.rb`, `*_create_pos_commission_rules.rb`, `*_add_vehicle_visit_to_pos_workspaces.rb` | tạo | Bảng và cột |
| `server/app/models/spree/pos/bus_operator.rb`, `vehicle_visit.rb`, `commission_rule.rb` | tạo | Model |
| `server/app/workflows/spree/pos/vehicle_visits/*.rb` | tạo | Mở, gắn đơn, chốt, chi, sửa, hủy |
| `server/app/services/spree/pos/vehicle_commission/calculator.rb` | tạo | Tính hoa hồng |
| `server/app/jobs/spree/pos/close_stale_vehicle_visits_job.rb` | tạo | Tự đóng lượt |
| `server/app/services/spree/pos/reports/vehicle_commissions.rb` | tạo | Báo cáo |
| `server/app/controllers/spree/api/v3/admin/pos/vehicle_visits_controller.rb`, `bus_operators_controller.rb`, `commission_rules_controller.rb` | tạo | API |
| `server/app/models/spree/pos/capabilities.rb`, `approval.rb` | sửa | Capability, action `vehicle_visit.adjust`, subject `VehicleVisit` |
| `server/app/models/spree/pos/workspace.rb` | sửa | `belongs_to :vehicle_visit`, trả trong `summary` |
| `server/config/initializers/pos_modules.rb`, `server/config/pos/business_profiles.yml`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | sửa | Module, hồ sơ, route, hợp đồng |
| `apps/pos/src/components/vehicle-visit-bar.tsx`, `pages/vehicle-visits.tsx`, `pages/settings/vehicle-commission.tsx`, `hooks/use-vehicle-visits.ts`, `modules/registry.ts`, `locales/*` | tạo / sửa | UI |

## Các bước

1. Viết migration và model, kèm spec validation và quyền xem số điện thoại.
2. Viết `Calculator`, có spec cho theo xe, theo khách, cả hai, điều kiện tối thiểu, và quy tắc riêng của nhà xe được ưu tiên.
3. Viết các workflow `open`, `attach_workspace`, `close`, `void`, kèm job tự đóng.
4. Viết `pay` qua `CashMovementRequest`, đảm bảo idempotent và chỉ chi một lần cho mỗi lượt; viết `adjust` có `Approval`.
5. Làm báo cáo và xuất CSV.
6. Làm API, OpenAPI và UI web, rồi bật module trong hồ sơ trạm dừng.

## Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/vehicle_visit_spec.rb spec/services/spree/pos/vehicle_commission/ spec/workflows/spree/pos/vehicle_visits/ spec/requests/spree/pos/vehicle_visits_spec.rb`
- Spec chính:
  - hoa hồng không làm đổi tổng đơn hay hóa đơn điện tử;
  - chi hai lần cho một lượt chỉ tạo một `CashMovementRequest`;
  - sửa quy tắc sau khi chốt không đổi snapshot;
  - sửa sau chốt mà không có `Approval` bị từ chối;
  - gắn đơn đã complete bị từ chối.
- E2E web: xe mới → gắn 3 đơn → complete → chốt lượt → chi tiền mặt → tiền mong đợi trong ngăn kéo giảm đúng số hoa hồng.
- Chạy lại `pnpm --dir apps/pos lint`, `typecheck`, `test`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Khai khống số khách để lấy hoa hồng | Sửa sau chốt phải có duyệt; báo cáo tỷ lệ hoa hồng / doanh thu theo nhà xe để phát hiện bất thường; có điều kiện doanh thu tối thiểu. |
| Thu ngân quên gắn đơn vào xe | Thanh "Xe đang ở trạm" luôn hiện khi có lượt mở; doanh thu lượt chỉ dùng cho điều kiện tối thiểu và báo cáo, không quyết định số tiền khi quy tắc chỉ tính theo xe / khách. |
| Chi tiền mặt làm lệch ngăn kéo | Đi qua `CashMovementRequest` và đối soát ca có sẵn; không có đường chi tiền riêng. |
| Lộ số điện thoại tài xế | Ẩn theo quyền, và lọc khỏi file xuất. |

## Tiêu chí xong

- [ ] Mở, gắn đơn, chốt, chi và sửa lượt xe chạy đúng quyền và duyệt.
- [ ] Tính đúng hoa hồng theo xe, theo khách và cả hai; snapshot không đổi khi sửa quy tắc.
- [ ] Chi tiền mặt đi qua luồng chi tiền ngăn kéo; mỗi lượt chỉ chi một lần.
- [ ] Báo cáo theo nhà xe và biển số xuất được CSV.
- [ ] Spec và e2e xanh; OpenAPI đã cập nhật.
