---
phase: 16
title: "Mở ngành đợt 2"
status: pending
effort: "2 ngày"
dependsOn: [15]
---

# Phase 16: Mở ngành đợt 2 (bàn và trả sau)

## Overview

Phase này chốt đợt F2. Ba hồ sơ ngành chuyển sang dùng được, có cấu hình thiết bị và trạm hướng dẫn sẵn, có kịch bản e2e chạy chung S1 + S2 + S3, có tài liệu cho chủ quán và kế hoạch phát hành:

- **quán ăn có bàn** (`quan_an` bật thêm phần bàn);
- **nhà hàng cơ bản** (`nha_hang`);
- **bar dạng bàn** (`bar_pub_club`).

Tính năng nâng cao của nhà hàng và bar (expo / course / ghế / buffet / đặt bàn, tab, gửi rượu) nằm ở phase 18 và 19.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | `quan_an` đã mở ở phase 12 cho kiểu trả trước. Hồ sơ có thêm khóa `optional_modules: [resources, fnb.tables, fnb.postpay, fnb.service_charge]`. Wizard và trang Mô hình kinh doanh hỏi "Quán có bàn phục vụ không?"; trả lời có thì bật các module đó qua đúng đường `BranchModules` đã có (có audit `branch_module.change`). `optional_modules` không ảnh hưởng `status` của hồ sơ. |
| Q2 | `bar_pub_club` thêm `resources` và `fnb.tables` vào `modules` để bán theo bàn ở đợt này. `tab_list` và các module riêng của bar đến ở phase 19. |
| Q3 | `display.surface` của hồ sơ: `nha_hang` → `floor_plan`; `bar_pub_club` → `table_grid`; `quan_an` → `menu_grid`, chuyển sang `table_grid` khi bật bàn. Validator của `BusinessProfiles` thêm khóa `surface`, với giá trị thuộc `menu_grid|table_grid|floor_plan|resource_board|tab_list`. |
| Q4 | Hồ sơ vẫn không tự bật cờ rủi ro (plan.md D9). `recommended_features` của ba hồ sơ chỉ là gợi ý: `vietqr`, `customer_display`, `credit` (quán ăn). |
| Q5 | Wizard **bắt chọn quầy ghi sổ cho bàn** (`Branch.table_register_id`, phase 13) khi bật `fnb.tables`, và tạo sẵn trạm `Bếp` + `Bar` với `StationRoute` mặc định theo danh mục món. Quản lý sửa lại được. |
| Q6 | Phát hành theo cờ module: chi nhánh chưa bật module F2 không thấy gì mới. Không cần cờ phát hành riêng. |

## Dữ liệu

- Không thêm bảng.
- `server/config/pos/business_profiles.yml`: cập nhật `quan_an`, `nha_hang`, `bar_pub_club` theo Q1–Q4, gồm `display.surface`, `branch_defaults` (`service_charge_rate` gợi ý 5% cho `nha_hang`, để trống ở hai hồ sơ còn lại) và `optional_modules`. Tăng `version` của file.

## Server

- `Spree::Pos::BusinessProfiles`: đọc và validate `optional_modules` (module đã đăng ký, không trùng `modules`) và `display.surface`.
- `Onboarding` / `Profiles::Apply`: nhận thêm `answers: { has_tables: true }`. Khi `has_tables` thì bật `optional_modules`, yêu cầu `table_register_id`, tạo `KitchenStation` mặc định và `StationRoute` theo danh mục. Mọi việc chạy trong một transaction và idempotent theo key như hiện tại.
- Diff hồ sơ (plan bán lẻ D7) hiện thêm các module tùy chọn và trạm mặc định để người dùng chọn áp.
- Seed demo `server/db/seeds/pos_fnb_demo.rb`, chạy bằng `pnpm spree seed` với `POS_FNB_DEMO=1`: 2 khu, 12 bàn, 30 món có modifier, 2 trạm, 1 máy in giả lập `escpos_lan` tới `127.0.0.1:9100`. Seed chỉ chạy ở development.

## Client

- Web `apps/pos`: wizard và trang Mô hình kinh doanh có câu hỏi bàn và chọn quầy ghi sổ; bỏ nhãn "Sắp hỗ trợ" của ba hồ sơ.
- Flutter `apps/pos-staff`: màn đầu tiên sau khi ghép thiết bị hiện danh sách kiểm tra: máy in đã nhận, trạm đã chọn, nhân viên có PIN.

## Kịch bản e2e S1 + S2 + S3

`server/spec/integration/spree/pos/fnb_wave2_scenario_spec.rb` (API, không UI) và `apps/pos/e2e/fnb-wave2.spec.ts` (web, kèm hai client API giả làm S2 và S3):

1. Quản lý chọn hồ sơ `nha_hang`, có bàn, chọn quầy ghi sổ.
2. Thu ngân mở ca. Phục vụ (S2) mở bàn 5 với 4 khách và gọi đợt 1: phở ×2 (bếp), trà đá ×4 (bar).
3. KDS bếp và bar nhận đúng món; bump xong; S2 nhận `ready`.
4. Phục vụ gọi đợt 2; báo bếp chỉ gửi phần thêm. Hủy 1 phở chưa làm có lý do và duyệt; trạm bếp nhận phiếu hủy.
5. Phục vụ yêu cầu thanh toán; thu ngân thấy yêu cầu, in tạm tính, thu tiền VietQR / tiền mặt.
6. Đơn complete; bàn về trống; báo cáo có phí phục vụ và thuế theo món.

Kịch bản Flutter `apps/pos-staff/integration_test/wave2_waiter_kds_test.dart` chạy bước 2–4 trên emulator với server test.

## File

| Hành động | File |
|---|---|
| Sửa | `server/config/pos/business_profiles.yml`, `server/app/services/spree/pos/business_profiles.rb`, `server/app/workflows/spree/pos/onboarding/*.rb`, `server/app/workflows/spree/pos/profiles/*.rb` |
| Tạo | `server/db/seeds/pos_fnb_demo.rb`, `server/spec/integration/spree/pos/fnb_wave2_scenario_spec.rb` |
| Sửa | `apps/pos/src/components/setup/*`, `apps/pos/src/pages/settings/*business-model*`, `apps/pos/src/locales/*` |
| Tạo | `apps/pos/e2e/fnb-wave2.spec.ts`, `apps/pos-staff/integration_test/wave2_waiter_kds_test.dart`, `apps/pos-staff/lib/features/setup/device_checklist.dart` |
| Tạo | `docs/pos/fnb-ban-va-tra-sau.md` (hướng dẫn chủ quán: sơ đồ bàn, trạm, máy in, ghép thiết bị phục vụ / bếp, giới hạn iOS chạy nền) |

## Các bước

1. Cập nhật YAML và validator; spec `business_profiles_spec` khẳng định ba hồ sơ `available`, còn `karaoke_bida` vẫn `coming_soon` cho tới phase 17.
2. Câu hỏi bàn trong onboarding / áp hồ sơ, trạm mặc định.
3. Seed demo.
4. Kịch bản API, rồi e2e web, rồi integration Flutter.
5. Tài liệu `docs/pos/fnb-ban-va-tra-sau.md`, có liên kết từ README docs nếu đã có mục POS.
6. Chạy thử trên phần cứng thật: một Sunmi làm thu ngân + trạm in, một tablet Android làm KDS, một iPhone và một điện thoại Android làm S2, một máy in ESC/POS LAN ở bếp, server LAN của phase 6.

## Kiểm thử

- `pnpm spree rspec spec/services/spree/pos/business_profiles_spec.rb spec/workflows/spree/pos/onboarding/ spec/integration/spree/pos/fnb_wave2_scenario_spec.rb`.
- Hồi quy toàn bộ: `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/workflows/spree/pos/ spec/integration/spree/pos/`.
- Web: `pnpm --dir apps/pos lint`, `typecheck`, `test`, `test:e2e`.
- Flutter: `flutter analyze`, `flutter test`, `flutter test integration_test`, build `apk` và `ios --no-codesign`.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Chi nhánh `quan_an` trả trước đang chạy bị đổi màn bán khi cập nhật hồ sơ | Diff hồ sơ không tự áp (plan bán lẻ D7); bật bàn là lựa chọn chủ động. |
| Chủ quán quên tạo trạm / máy in, nên món không tới bếp | Q5 tạo trạm mặc định. Báo bếp khi trạm không có KDS và không có máy in trả cảnh báo rõ, không lặng lẽ bỏ qua. |
| Giới hạn chạy nền trên iOS | Ghi rõ trong tài liệu; khuyến nghị Android cho máy phục vụ dùng chung. |

## Tiêu chí xong

- [ ] `quan_an` (có bàn), `nha_hang`, `bar_pub_club` chọn được trong wizard và tạo được chi nhánh.
- [ ] Kịch bản 6 bước xanh ở API, e2e web và integration Flutter.
- [ ] Chạy thử trên phần cứng thật không lỗi chặn; các lỗi nhỏ ghi lại trong phase.
- [ ] Tài liệu cho chủ quán đã có và liên kết đúng.
- [ ] Chi nhánh bán lẻ và chi nhánh đợt 1 không đổi hành vi.
