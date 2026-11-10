---
phase: 12
title: "Mở ngành đợt 1"
status: pending
effort: "3 ngày"
dependsOn: [6, 7, 8, 9, 10, 11]
---

# Phase 12: Mở ngành đợt 1 — cafe / trà sữa, quán ăn trả trước, căng tin bán nhanh

## Overview

Phase này chốt đợt F1:
- chuyển các module F1 sang `available`;
- mở ba hồ sơ `cafe_tra_sua`, `quan_an` (trả trước) và `cang_tin_tram_dung` (bán nhanh, chưa có thẻ suất ăn);
- thêm vào wizard các bước F&B;
- có checklist phần cứng;
- chạy kịch bản đầu-cuối trên S1 (thu ngân), S3 (KDS), S5 (màn khách) và trạm in;
- viết hướng dẫn cho chủ quán và các bước rollout.

**Điều kiện phát hành:** phase 7 phải phát hành được hóa đơn qua adapter VNPT (nhà cung cấp do khách chọn; VNPT là bên làm trước). Hộ có doanh thu trên 1 tỷ/năm bắt buộc dùng hóa đơn điện tử.

## Quyết định của phase

1. **Module F1 chuyển sang `available`:** `fnb.menu`, `fnb.kitchen`, `fnb.order_number`, `fnb.cup_label`, `fnb.recipes`. Các phase 8–11 đã đăng ký code của chúng; phase này kiểm tra mọi module F1 đều có trong `Modules.available` và có spec.

   Các module `resources`, `fnb.tables`, `fnb.postpay`, `fnb.service_charge`, `timed_billing` vẫn ở `planned`, nên hồ sơ `karaoke_bida`, `bar_pub_club`, `nha_hang` tiếp tục `coming_soon`.
2. **Hồ sơ đợt 1** (`server/config/pos/business_profiles.yml`):

   | Key | Module | `display.surface` | `branch_defaults` | Cờ "thường dùng" |
   |---|---|---|---|---|
   | `cafe_tra_sua` | fnb.menu, fnb.kitchen, fnb.order_number, fnb.cup_label, fnb.recipes | `menu_grid` | `kitchen_send_trigger: on_complete` | vietqr, customer_display |
   | `quan_an` | fnb.menu, fnb.kitchen, fnb.order_number, fnb.recipes, retail.measured | `menu_grid` | `kitchen_send_trigger: on_complete` | vietqr, credit, delivery |
   | `cang_tin_tram_dung` | fnb.menu, fnb.kitchen, fnb.order_number, retail.units | `menu_grid` | `kitchen_send_trigger: on_complete` | vietqr, customer_display |

   - `quan_an` thêm `retail.measured` để bán hải sản theo cân. `fnb.tables` sẽ được thêm vào hồ sơ này ở phase 16.
   - Danh sách cờ trên chỉ là nhãn "thường dùng" và không tự bật cờ nào (D9).
   - Hồ sơ không ghi giờ cắt ngày kinh doanh mặc định: dùng mặc định của phase 1.
3. **Mở rộng validate của `BusinessProfiles`:**
   - `DISPLAY_FIELDS` thêm `surface`, nhận các giá trị `catalog`, `menu_grid` (bản sau thêm `table_grid`, `floor_plan`, `resource_board`, `tab_list`);
   - `BRANCH_DEFAULT_FIELDS` thêm `kitchen_send_trigger`.

   Client chọn surface theo `display.surface` của hồ sơ chi nhánh, còn module vẫn là điều kiện bắt buộc (`menu_grid` cần `fnb.menu`).
4. **Wizard:**
   - Ba hồ sơ đợt 1 chọn được ngay. Ba hồ sơ còn lại giữ nhãn "Sắp hỗ trợ" và giữ luồng hỏi "cửa hàng có bán cả hàng hóa không" như hiện tại.
   - Chọn hồ sơ F&B mở thêm bước **Thiết lập quán**: tạo trạm Bếp và Bar mặc định (căng tin chỉ một trạm), chọn thuế suất mặc định cho món ăn và đồ uống có cồn từ cấu hình thuế của phase 1, chọn trigger báo bếp.
   - Không có thực đơn mẫu; thực đơn nhập ở trang Cài đặt → Thực đơn.
5. **Checklist phần cứng** là một trang trong cài đặt (`pages/settings/hardware.tsx`). Trang đọc trạng thái thật từ server, không đánh dấu tay:
   - máy in hóa đơn, máy in bếp, máy in tem đã khai báo và đã in thử thành công (`PrintJob` gần nhất `printed`);
   - mỗi trạm có KDS hoặc máy in;
   - trạm in (`print_station`) đang online, theo `last_seen_at` của Device;
   - màn khách đã ghép (DisplaySession còn hạn);
   - địa chỉ server và kết nối internet ra ngoài cho VietQR / hóa đơn điện tử (health của phase 6);
   - hóa đơn điện tử đã cấu hình (phase 7).

## Server

- Bật đăng ký `available` cho module F1 trong `config/initializers/pos_modules.rb`, và kiểm thứ tự `depends_on` khi boot.
- Sửa `business_profiles.yml` và `business_profiles.rb` như quyết định 2 và 3.
- Workflow `Onboarding::Setup` nhận thêm `fnb_setup: { stations:, tax_categories:, kitchen_send_trigger: }`. Workflow gọi workflow tạo trạm của phase 9 và ghi `AuditEntry` `onboarding.fnb_setup`. Tạo lại không nhân đôi trạm (idempotency key của lệnh onboarding).
- `GET /pos/hardware_status?branch_id=` tổng hợp checklist từ Printer, PrintJob, Device, DisplaySession, KitchenStation, cấu hình hóa đơn điện tử và health. Quyền: `Capabilities::MANAGE`.
- OpenAPI: thêm `HardwareStatus`; cập nhật enum của hồ sơ và module.

## Client web (`apps/pos`)

- `components/setup/profile-picker.tsx`: ba hồ sơ đợt 1 hết nhãn "Sắp hỗ trợ" nhờ `status` từ server, không sửa danh sách cứng.
- Bước mới `components/setup/setup-fnb-step.tsx`; `setup-preview-step.tsx` hiện thêm trạm, thuế và trigger.
- Trang `pages/settings/hardware.tsx`, có lối vào từ `business-model.tsx` và thông báo sau wizard.
- `locales`: nhãn và mô tả của 3 hồ sơ (`profiles.cafe_tra_sua.*`…), bước thiết lập quán, checklist.

## Kịch bản đầu-cuối

Môi trường gồm server LAN (phase 6) seed sẵn, thu ngân web, một app Flutter ở mode `kds`, một app ở mode `print_station` và một màn khách.

| # | Kịch bản | Kỳ vọng |
|---|---|---|
| 1 | Cafe: 3 ly (2 cùng tùy chọn, 1 khác), trả VietQR khớp webhook | 2 dòng; số gọi 1; ticket ở trạm Bar; 3 tem ly; màn khách "Đang làm" → bump → "Mời nhận" → Đã giao; nguyên liệu trừ đúng |
| 2 | Cafe: khách trả tiền mặt, máy in bếp tắt | Bán xong; PrintJob `failed` hiện ở checklist; in lại được khi bật máy |
| 3 | Quán ăn trả trước: 1 phở + 1 bia + 0,8 kg ốc theo cân | Phở tới Bếp, bia tới Bar; dòng cân dùng `retail.measured`; hóa đơn có 2 mức thuế (8% / 10%) |
| 4 | Căng tin: 30 đơn liên tiếp, có hàng đóng gói quét mã vạch | Số gọi liên tục; thao tác dưới 3 chạm cho một suất; hàng đóng gói trừ tồn như bán lẻ |
| 5 | Qua giờ cắt ngày kinh doanh khi quán đang mở | Số gọi bắt đầu lại từ 1; báo cáo theo `business_date` |
| 6 | Hóa đơn điện tử: mất internet trên server LAN | Bán vẫn xong; hóa đơn nằm trong hàng đợi và tự phát hành khi có mạng |
| 7 | Chi nhánh bán lẻ cùng store | Không thấy thay đổi nào; e2e bán lẻ không lỗi mới |

- Kịch bản 1–5 viết thành Playwright `apps/pos/e2e/fnb-wave1.spec.ts`. Phần KDS và trạm in kiểm bằng API cộng `flutter test integration_test/wave1_test.dart` trên emulator, với máy in giả là một TCP server nhận ESC/POS ở cổng 9100, chạy trong test.
- Kịch bản 6 và kiểm thử trên phần cứng thật (Sunmi T2 có máy in tích hợp, Xprinter LAN, máy in tem) chạy tay theo checklist, rồi ghi kết quả vào mục Kết quả của phase.

## Tài liệu và rollout

- Thêm mục **"Bán hàng F&B (cafe, quán ăn, căng tin)"** trong `README.md`, cùng chỗ với hướng dẫn chức năng hiện có. Nội dung:
  - chọn hồ sơ;
  - nhập thực đơn và tùy chọn;
  - trạm bếp và máy in;
  - ghép KDS / trạm in / màn khách;
  - số gọi và tem ly;
  - công thức;
  - hóa đơn điện tử.

  Lệnh và cấu hình kỹ thuật thì link sang tài liệu phase 5 và 6, không chép lại.
- Rollout:
  1. Bật ở một quán thử: cafe, trên server LAN.
  2. Theo dõi 1 tuần các chỉ số: độ trễ KDS, PrintJob failed, discrepancy nguyên liệu, hóa đơn trong hàng đợi.
  3. Mở cho mọi khách mới.

  Rollback là chuyển module về `planned`. Dữ liệu được giữ nguyên, và chi nhánh đã chọn hồ sơ F&B vẫn bán được như bán lẻ (D5).

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/config/initializers/pos_modules.rb` | sửa | module F1 `available` |
| `server/config/pos/business_profiles.yml`, `server/app/services/spree/pos/business_profiles.rb` | sửa | hồ sơ, validate `surface`, `kitchen_send_trigger` |
| `server/app/workflows/spree/pos/onboarding/setup.rb`, `attributes.rb` | sửa | bước thiết lập quán |
| `server/app/controllers/spree/api/v3/admin/pos/hardware_status_controller.rb`, `server/app/services/spree/pos/hardware_status.rb` | tạo | checklist |
| `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | sửa | route, hợp đồng |
| `apps/pos/src/components/setup/setup-fnb-step.tsx`, `pages/settings/hardware.tsx` | tạo | wizard, checklist |
| `apps/pos/src/components/setup/profile-picker.tsx`, `setup-preview-step.tsx`, `pages/setup.tsx`, `pages/settings/business-model.tsx`, `locales/*` | sửa | wizard |
| `apps/pos/e2e/fnb-wave1.spec.ts`, `apps/pos-staff/integration_test/wave1_test.dart` | tạo | đầu-cuối |
| `README.md` | sửa | hướng dẫn chủ quán |

## Các bước

1. Viết spec boot: mọi module F1 `available`, hồ sơ đợt 1 `available`, ba hồ sơ còn lại `coming_soon`.
2. Viết validate `surface` và `kitchen_send_trigger`, kèm spec YAML hợp lệ / không hợp lệ.
3. Viết bước wizard F&B ở server và client. Spec: onboarding idempotent; hồ sơ bán lẻ không qua bước này.
4. Viết checklist phần cứng (service, endpoint, trang).
5. Viết kịch bản đầu-cuối tự động 1–5 và 7; chạy kịch bản 6 và phần cứng thật bằng tay.
6. Viết `README.md`. Xác nhận adapter VNPT của phase 7 phát hành được hóa đơn trên cửa hàng thử. Khách dùng nhà cung cấp khác thì chờ adapter tương ứng.
7. Rollout quán thử, rồi ghi kết quả.

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/business_profiles_spec.rb spec/services/spree/pos/modules_spec.rb spec/requests/spree/pos/onboarding_spec.rb spec/requests/spree/pos/hardware_status_spec.rb`
- Toàn bộ server: `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`
- Web: `pnpm --dir apps/pos lint typecheck test test:e2e`
- Flutter: `flutter analyze && flutter test && flutter test integration_test/wave1_test.dart` trong `apps/pos-staff`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Khách dùng nhà cung cấp hóa đơn điện tử chưa có adapter | Bản đầu chỉ có VNPT. Khách dùng bên khác thì viết thêm adapter theo interface của phase 7 trước khi mở cho khách đó |
| Phần cứng thật khác máy giả lập (font, khổ giấy, TSPL) | Bắt buộc chạy checklist phần cứng thật trước khi rollout |
| Hồ sơ `quan_an` đổi module ở phase 16 | Đổi hồ sơ ra diff (D7 của plan bán lẻ), không ghi đè chi nhánh đang chạy |

## Tiêu chí xong

- [ ] Ba hồ sơ đợt 1 chọn được trong wizard và tạo được chi nhánh F&B có trạm bếp và thuế.
- [ ] Kịch bản 1–7 đạt; kết quả phần cứng thật được ghi lại.
- [ ] Checklist phần cứng phản ánh trạng thái thật.
- [ ] `README.md` có hướng dẫn F&B đợt 1.
- [ ] Phát hành được hóa đơn qua adapter VNPT.
- [ ] Quán thử chạy 1 tuần không có lỗi chặn.
