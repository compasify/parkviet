---
phase: 19
title: "Bar, pub & club"
status: pending
effort: "7 ngày"
dependsOn: [16]
---

# Phase 19: Bar, pub & club

## Overview

Phase này làm các tính năng riêng của bar, pub và club ([research §3.5](../reports/261109-1748-pos-fnb-giai-tri-research.md)):

- màn **`tab_list`**: tab mở theo khách hoặc bàn, máy nào cũng thêm món được;
- báo cáo theo **ngày kinh doanh qua 0h** (D8);
- **giá happy hour**, dùng lại giá theo khung giờ của phase 8;
- module **`fnb.bottle_keep`**: sổ gửi rượu;
- module **`fnb.pour_tracking`**: định lượng ml trên chai đang mở;
- **minimum spend** cho bàn VIP;
- **vé vào cửa** quy đổi thành drink credit;
- **tip** để ngoài doanh thu chịu thuế GTGT, kèm báo cáo chia tip;
- **gói bottle service**.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Tab là một workspace có `service_mode = tab`. Tab mang thêm `tab_name` (tên hoặc mô tả khách) và có thể gắn `Resource` (bàn VIP). Thêm món từ bất kỳ máy nào dùng đường "thêm dòng không cần lease" của phase 14. |
| Q2 | Ngày kinh doanh: mọi báo cáo của phase này nhóm theo `Workspace.business_date` (phase 1). Không tính lại ngày từ `created_at`. |
| Q3 | Happy hour **không tạo cơ chế giá mới**. Bảng giá theo khung giờ của phase 8 nhận thêm thuộc tính hiển thị `label` ("Happy hour"). Giá được chốt lúc thêm dòng, theo `database_now`. |
| Q4 | Gửi rượu là **sổ ghi, không đụng tiền** (đã chốt 09/11/2026: chỉ ghi sổ). Bán chai vẫn là dòng bán bình thường. Phần rượu còn lại thì mở phiếu gửi; lần sau rót từ chai gửi thì không phát sinh dòng tiền. |
| Q5 | `fnb.pour_tracking` dùng công thức của phase 11: một shot là công thức "X ml từ variant chai". Chai đang mở là một `OpenBottle` của chi nhánh. Mỗi lần complete đơn, số ml của chai đang mở giảm theo các lần rót. Khi hết chai, hệ thống trừ tồn đúng một chai. |
| Q6 | Minimum spend: lúc tạm tính và lúc thanh toán, nếu `item_total` của tab thấp hơn mức tối thiểu của tài nguyên VIP thì server thêm phần chênh dưới dạng một **`Spree::Fee` có thuế**, nhãn "Phụ thu mức tối thiểu" (cùng kiểu với phí giao hàng ở `deliveries/assign.rb`). Phí này được tính lại mỗi khi đơn thay đổi và không bao giờ âm. |
| Q7 | Vé vào cửa là dòng `cover`, có giá và thuế riêng. Vé kèm **drink credit**, ghi trên tab dưới dạng hạn mức giảm giá cho nhóm đồ uống, áp qua `LineDiscountIntent` với nguồn `cover_credit`. Phần drink credit không dùng hết thì không hoàn. |
| Q8 | Tip không thuộc order nên không vào hóa đơn GTGT. Tiền tip vẫn đi qua `ReceivedFunds`; phần tip là số dư không allocate vào order, gắn `TipRecord`. Chi tip cho nhân viên dùng `LiabilityPayout`, người nhận là nhân viên. Việc tip không phải doanh thu mới có **một nguồn** (research §7), nên phase này có cờ chi nhánh "Ghi tip vào doanh thu" để đổi khi có ý kiến kế toán. |
| Q9 | Gói bottle service là combo của phase 8: một chai cộng mixer và đá, có giá gói. Phần rượu còn lại khi đóng tab được gợi ý mở phiếu gửi rượu. |

## Dữ liệu

- `spree_pos_workspaces` thêm `tab_name` (string, null) và chỉ mục tìm kiếm `lower(tab_name)` theo chi nhánh cho các workspace đang mở.
- `spree_pos_resources` thêm `minimum_spend` (decimal, null) và `minimum_spend_currency`.
- `spree_pos_bottle_keeps`:
  - cột chính: `branch_id`, `customer_profile_id`, `variant_id`, `code` (in trên nhãn chai), `level_percent`, `photo` (Active Storage), `kept_on`, `expires_on`, `source_order_id`, `note`;
  - `status`: `kept | finished | expired | returned`.
- `spree_pos_bottle_keep_events`: `bottle_keep_id`, `kind` (`open | pour | adjust | expire | return`), `level_before`, `level_after`, `ml`, `workspace_id` (null), `actor_id`, `created_at`. Bảng chỉ thêm dòng, không sửa.
- `spree_pos_open_bottles`:
  - cột: `branch_id`, `variant_id`, `capacity_ml`, `remaining_ml`, `opened_at`, `opened_by_id`;
  - `status`: `open | finished`.
- `spree_pos_pour_events`: `open_bottle_id`, `sale_line_id`, `ml`, `business_date`. Unique theo (`sale_line_id`, `open_bottle_id`) để trừ một lần duy nhất.
- `spree_pos_tip_records`: `branch_id`, `workspace_id`, `received_funds_id`, `amount`, `currency`, `business_date`, `shift_id`, `status` (`held | paid_out`), `liability_payout_id`.
- `spree_pos_tip_split_rules` theo chi nhánh: `mode` (`equal | by_hours | manual`), danh sách vai trò được chia.
- Approval action mới: `bottle_keep.adjust` (sửa mức rượu), `tab.waive_minimum_spend`.
- Module: đăng ký `fnb.bottle_keep` và `fnb.pour_tracking` là `available`. Thêm hai module này vào hồ sơ `bar_pub_club`, và thêm `fnb.bottle_keep` vào `karaoke_bida`, đều ở dạng gợi ý.

## Server

1. Tab:
   - `Workspaces::Create` nhận `service_mode: 'tab'` và `tab_name`.
   - `GET workspaces?service_mode=tab&q=` tìm tab đang mở theo tên, bàn hoặc số tab.
   - Phát `workspace.updated` cho mọi máy của chi nhánh.
2. `Spree::Pos::Fnb::MinimumSpend.apply!(workspace)` chạy sau mỗi thay đổi dòng và trước khi chụp tạm tính hoặc chuẩn bị tender. Bỏ phụ thu cần approval `tab.waive_minimum_spend`.
3. Drink credit: khi thêm dòng `cover` có `drink_credit`, tạo một intent giảm giá cấp dòng. Intent áp tự động cho đồ uống thuộc nhóm được phép, theo thứ tự thêm món, tới khi hết hạn mức.
4. Gửi rượu: `BottleKeeps::Open` (từ dòng bán hoặc nhập tay), `Pour`, `Adjust` (cần approval), `Return`, `Expire`. Job hằng ngày đánh dấu phiếu quá hạn.
5. Rót: trong `Workspaces::Complete`, sau phần trừ kho theo công thức của phase 11, các dòng có công thức "ml từ chai" tạo `PourEvent` trên chai đang mở của variant đó. Hết chai thì đóng chai và trừ tồn một chai; nếu đã có chai mới mở thì chuyển phần ml còn thiếu sang chai mới. Bước này idempotent theo `sale_line_id`.
6. Tip:
   - Bước tender cho nhập "tip" tách khỏi số phải thu.
   - `Tenders` ghi `TipRecord` cho phần tip của `ReceivedFunds`.
   - `Tips::Payout` tạo `LiabilityPayout` theo quy tắc chia.
   - Báo cáo chia tip đọc theo ca và theo ngày kinh doanh.
7. Báo cáo: doanh thu theo `business_date` và theo khung giờ (gồm happy hour); số tab mở và đóng; số chai mở và số ml đã rót so với số bán; phiếu gửi sắp hết hạn.
8. API dưới `/api/v3/admin/pos/`: `bottle_keeps` (CRUD, `pour`, `adjust`), `open_bottles`, `tips` (danh sách, `payout`), `reports/bar`. Cập nhật `server/openapi/pos-staff.yaml`.

## Client web (`apps/pos`)

- Surface **`tab_list`**:
  - ô tìm kiếm luôn được focus;
  - mỗi tab có tên khách, bàn, giờ mở và tổng tiền;
  - nút "Mở tab" chỉ cần nhập tên.

  Bàn VIP mở từ `floor_plan` của phase 13.
- Màn gọi món của tab ưu tiên nhóm đồ uống và shot. Happy hour đang chạy thì có nhãn trên món.
- Tạm tính hiện dòng phụ thu mức tối thiểu và drink credit còn lại.
- Trang **Gửi rượu**: tìm theo SĐT hoặc mã chai; xem ảnh, mức còn và lịch sử rót; in nhãn chai qua hàng đợi in (`PrintJob`, loại `receipt` dùng mẫu nhãn).
- Thanh toán có ô tip. Trang **Chia tip** cho quản lý ca.

## Flutter (`apps/pos-staff`)

- Mode `waiter`:
  - danh sách tab có tìm kiếm;
  - mở tab mới, thêm món vào tab bất kỳ;
  - rót từ chai gửi bằng cách quét mã chai, cập nhật mức và chụp ảnh.
- Mode `kds` của trạm `bar` dùng như phase 9, không có thay đổi riêng.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_tab_name_to_spree_pos_workspaces.rb`, `*_add_minimum_spend_to_spree_pos_resources.rb`, `*_create_spree_pos_bottle_keeps.rb`, `*_create_spree_pos_open_bottles.rb`, `*_create_spree_pos_tip_records.rb` |
| Tạo | `server/app/models/spree/pos/bottle_keep.rb`, `bottle_keep_event.rb`, `open_bottle.rb`, `pour_event.rb`, `tip_record.rb`, `tip_split_rule.rb` |
| Tạo | `server/app/services/spree/pos/fnb/minimum_spend.rb`, `server/app/workflows/spree/pos/bottle_keeps/*.rb`, `server/app/workflows/spree/pos/tips/payout.rb`, `server/app/services/spree/pos/fnb/pour_tracker.rb` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/bottle_keeps_controller.rb`, `open_bottles_controller.rb`, `tips_controller.rb` |
| Sửa | `server/app/workflows/spree/pos/workspaces/create.rb`, `workspaces/complete.rb`, workflow tender (thêm tip), `server/app/models/spree/pos/approval.rb`, `server/config/initializers/pos_modules.rb`, `server/config/pos/business_profiles.yml`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos/src/components/tab-list.tsx`, `apps/pos/src/pages/bottle-keeps.tsx`, `apps/pos/src/pages/tips.tsx`, `apps/pos/src/hooks/use-bottle-keeps.ts` |
| Sửa | `apps/pos/src/components/payment-panel.tsx`, `apps/pos/src/router.tsx`, `apps/pos/src/locales/*` |
| Sửa | `apps/pos-staff/lib/modes/waiter/` |

## Các bước

1. Thêm `tab_name` và tìm kiếm tab; làm surface `tab_list`.
2. Gắn nhãn happy hour vào bảng giá theo khung giờ của phase 8; viết spec chốt giá theo giờ server.
3. Làm minimum spend bằng `Spree::Fee`, kèm approval bỏ phụ thu.
4. Làm vé vào cửa `cover` và drink credit.
5. Làm sổ gửi rượu và nhãn chai.
6. Làm chai đang mở và rót, gắn vào complete.
7. Làm tip: nhập khi thanh toán, `TipRecord`, chia và chi tip; thêm cờ chi nhánh "Ghi tip vào doanh thu".
8. Làm báo cáo theo ngày kinh doanh.
9. Làm API, OpenAPI, sinh lại client Dart, cập nhật mode waiter.
10. Bật hai module mới trong registry và hồ sơ.

## Kiểm thử

- Spec ngày kinh doanh: đơn mở 23:30 và đóng 01:30 với giờ cắt 04:00 thuộc cùng một `business_date`; báo cáo đếm đúng một lần.
- Spec minimum spend:
  - tab dưới mức thì có phụ thu bằng phần chênh, chịu thuế;
  - thêm món làm phụ thu giảm, vượt mức thì phụ thu mất;
  - bỏ phụ thu cần approval.
- Spec drink credit: credit chỉ áp cho nhóm đồ uống được phép và không vượt hạn mức.
- Spec rót: complete hai lần không trừ hai lần; hết chai thì trừ tồn đúng một chai.
- Spec gửi rượu: `adjust` thiếu approval thì bị từ chối; lịch sử chỉ thêm, không sửa.
- Spec tip: tip không làm đổi `order.total` và không có trên hóa đơn điện tử; chi tip tạo `LiabilityPayout`; sổ quỹ ca khớp.
- E2E web: mở tab → hai máy cùng thêm món → tạm tính có phụ thu tối thiểu → thanh toán có tip → báo cáo.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Cách hạch toán tip chưa chắc về pháp lý | Có cờ chi nhánh. Nghiệp vụ mặc định ghi rõ nguồn và để kế toán xác nhận trước khi phát hành. |
| Sai lệch ml giữa đo thật và công thức | Báo cáo "ml bán so với ml chai đã mở" để quản lý kiểm. Sửa mức chai cần approval. |
| Minimum spend tính lại nhiều lần gây đổi revision liên tục | Chỉ ghi phí khi giá trị đổi, so trước khi update. |
| Ảnh chai gửi làm phình dung lượng server LAN | Nén ảnh ở client, giới hạn kích thước, xóa ảnh khi phiếu đã kết thúc quá N ngày. |

## Tiêu chí xong

- [ ] `tab_list` tìm được tab, mở tab nhanh; máy nào cũng thêm món vào tab được.
- [ ] Báo cáo bar theo ngày kinh doanh qua 0h là đúng.
- [ ] Happy hour áp theo giờ server và có nhãn.
- [ ] Gửi rượu: mở phiếu, rót, sửa có duyệt, hết hạn, in nhãn.
- [ ] Rót theo ml trừ chai đang mở và trừ tồn đúng.
- [ ] Minimum spend và drink credit đúng; bỏ phụ thu có approval.
- [ ] Tip để ngoài doanh thu, có báo cáo chia và chi tip qua payout.
- [ ] OpenAPI, client Dart, spec và e2e đều xanh.
