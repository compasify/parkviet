---
phase: 20
title: "Căng tin: tài khoản suất ăn, ví, công nợ công ty"
status: pending
effort: "7 ngày"
dependsOn: [12]
---

# Phase 20: Căng tin, tài khoản suất ăn, ví, công nợ công ty

## Overview

Phase này làm module **`fnb.meal_accounts`** cho căng tin công ty, trường và bệnh viện ([research §3.6](../reports/261109-1748-pos-fnb-giai-tri-research.md)). Phạm vi:

- tài khoản suất ăn gắn với người dùng và công ty;
- nhận diện người ăn bằng **mã nhân viên / học sinh** (gõ hoặc tìm theo tên); thẻ để sau;
- ví trả trước, nạp tiền qua lõi tender;
- hạn mức suất mỗi ngày, chặn ghi suất trùng;
- âm báo khác nhau cho hợp lệ, trùng suất và lỗi;
- công nợ trả sau theo công ty, dùng lại `credit` đang có, xuất bảng kê theo kỳ;
- trợ giá: công ty trả một phần, nhân viên trả phần còn lại;
- màn bán có ô nhập mã luôn sẵn sàng.

Phụ huynh nạp tiền và cảnh báo số dư thấp chỉ được chuẩn bị điểm nối (hook); kênh nạp tiền online để sau.

Câu hỏi mở 2 đã chốt ngày 09/11/2026: **chưa làm thẻ** (RFID hay QR), để phát triển sau. Phase này để sẵn điểm nối cho thẻ (mục "Để sau" ở cuối). Phần còn lại theo mặc định của plan:
- **có** trợ giá;
- trừ lương **chỉ xuất bảng kê**, không tích hợp hệ thống lương.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Tài khoản suất ăn (`MealAccount`) gắn với một `CustomerProfile`. Tài khoản có thể thuộc một **đơn vị chi trả** (`MealSponsor`, là công ty hoặc trường). Bản thân đơn vị chi trả là một `CustomerProfile` có `CreditAccount`, và công nợ của đơn vị đi qua `ReceivableEntry` như ghi nợ hiện có. |
| Q2 | **Chưa có thẻ.** Người ăn được nhận diện bằng `employee_code` (gõ vào ô nhập rồi Enter) hoặc tìm theo tên. Mọi lệnh nhận diện đi qua một service duy nhất `MealAccounts::Resolve(store, input)`, để sau này thêm thẻ chỉ cần thêm một cách tra trong service này, không sửa luồng bán. |
| Q3 | Ví trả trước là **tiền khách gửi giữ, không phải doanh thu**.<br>• **Nạp tiền:** đi qua lõi tender và tạo `ReceivedFunds` không gắn workspace, cùng mô hình với tiền cọc của [phase 18](./phase-18-nha-hang-nang-cao.md).<br>• **Trừ ví khi bán:** dùng tender kind mới `meal_wallet`, tạo `FundsAllocation` từ các lần nạp cũ nhất trước (FIFO).<br>• **Hoàn số dư khi nghỉ việc:** dùng `LiabilityPayout`, cần approval. |
| Q4 | Trả sau theo công ty dùng đường **ghi nợ sẵn có** (`credit`). Mỗi lần ghi suất không cần quản lý duyệt, vì hạn mức đã được duyệt trước trên `CreditAccount` của đơn vị chi trả. Lệnh dùng cơ chế tự duyệt như `quick_credit` nhưng giới hạn cho tender `meal_sponsor`, nên không cần bật `quick_credit` cho cả chi nhánh. |
| Q5 | Trợ giá chia **một đơn thành hai lần thanh toán**:<br>• phần đơn vị trả (`sponsor`) đi theo Q4;<br>• phần nhân viên trả đi bằng ví, tiền mặt hoặc QR.<br>Phần trợ giá có thể là số tiền cố định hoặc phần trăm theo suất, và có trần theo ngày. Hóa đơn điện tử vẫn là **một hóa đơn** cho cả đơn. |
| Q6 | Hạn mức tính theo `business_date`: số suất mỗi ngày, có thể giới hạn theo bữa (khung giờ). Cùng tài khoản được ghi suất lại trong vòng `duplicate_window_seconds` (mặc định 60 giây) thì bị từ chối với `reason: 'meal_duplicate_swipe'`. Server là bên quyết định; client chỉ phát âm báo theo `reason`. |
| Q7 | Màn bán của căng tin là `menu_grid` (phase 8) có **ô nhập luôn giữ focus**. Chuỗi kết thúc bằng Enter: nếu khớp `employee_code` thì gắn tài khoản vào đơn, còn không thì coi như quét mã vạch sản phẩm theo `retail.units`. Khi có thẻ, đầu đọc kiểu bàn phím gõ vào đúng ô này. |

## Dữ liệu

- **`spree_pos_meal_sponsors`**
  - Cột: `store_id`, `customer_profile_id` (đơn vị chi trả), `credit_account_id`, `name`, `statement_day` (ngày chốt kỳ), `subsidy_mode` (`none | fixed | percent`), `subsidy_value`, `subsidy_daily_cap`, `status`.
- **`spree_pos_meal_accounts`**
  - Cột: `store_id`, `customer_profile_id`, `meal_sponsor_id` (null), `employee_code`, `group_label` (phòng ban, lớp), `daily_meal_limit`, `meal_windows` (jsonb, danh sách khung giờ được ăn), `pay_mode` (`wallet | sponsor | sponsor_subsidy`), `low_balance_threshold`, `status`.
  - Unique: (`store_id`, `employee_code`).
- **`spree_pos_stored_value_accounts`**
  - Cột: `store_id`, `customer_profile_id`, `kind` (`meal` ở phase này; phase 21 thêm `money | minutes`), `status`.
  - `MealAccount` có thêm `stored_value_account_id`.
- **`spree_pos_stored_value_entries`** (sổ chỉ thêm)
  - Cột: `stored_value_account_id`, `kind` (`top_up | spend | refund | adjust`), `amount` (có dấu), `minutes` (null, để phase 21 dùng), `received_funds_id`, `funds_allocation_id`, `workspace_id`, `actor_id`, `created_at`.
  - Số dư = tổng các dòng. Mọi lệnh ghi đều khóa hàng `StoredValueAccount` trước, giống cách `CreditAccount` khóa hàng.
  - Service dùng chung là `Spree::Pos::StoredValue` (`top_up`, `spend`, `refund`, `adjust`). Phase 21 dùng lại nó cho thẻ nạp tiền và thẻ nạp giờ.
- **`spree_pos_meal_swipes`**
  - Cột: `meal_account_id`, `input_method` (`code | search`, sau thêm `card`), `branch_id`, `business_date`, `meal_window`, `workspace_id`, `result` (`ok | duplicate | limit | revoked | unknown | insufficient`), `created_at`.
  - Dùng để chặn ghi suất trùng, đếm hạn mức và báo cáo.
- **Lõi và cấu hình:**
  - `PosPaymentMethod.kind`: thêm `meal_wallet` và `meal_sponsor`.
  - Approval action mới: `meal_wallet.refund`, `meal_wallet.adjust`, `meal_account.override_limit`.
  - Capabilities mới: `pos.meal_account.manage`.
- **Module:** đăng ký `fnb.meal_accounts` là `available`, thêm vào hồ sơ `cang_tin_tram_dung`.

## Server

1. **`MealAccounts::Resolve(store, input)`**: tìm tài khoản theo `employee_code` khớp tuyệt đối, hoặc trả danh sách gợi ý khi tìm theo tên. Lệnh chỉ đọc, có giới hạn tần suất theo thiết bị.
2. **`MealAccounts::Swipe(workspace, raw, key)`**:
   - kiểm tài khoản, trạng thái, khung giờ, hạn mức ngày và ghi suất trùng (khóa hàng tài khoản trong lúc kiểm);
   - ghi `MealSwipe`;
   - gắn tài khoản vào workspace (`pos_customer`);
   - trả `result` cùng số dư, số suất còn lại và phần trợ giá dự kiến.

   Vi phạm thì trả `Conflict`, kèm `reason` theo Q6.
3. **Tender `meal_wallet`**: ở bước prepare, kiểm số dư ≥ số tiền. Ở bước confirm, tạo các `FundsAllocation` từ các `ReceivedFunds` nạp ví còn `available`, cũ nhất trước, rồi ghi dòng `spend` vào `stored_value_entries`. Mọi việc chạy trong cùng transaction của lõi tender.
4. **Tender `meal_sponsor`**: tạo `CreditReservation` và `ReceivableEntry` (`debit`) trên `CreditAccount` của đơn vị chi trả. Lệnh tự duyệt khi còn trong hạn mức. Vượt hạn mức thì trả `Conflict reason: 'sponsor_limit'`.
5. **`MealAccounts::SplitPlan(workspace)`**: tính phần đơn vị trả và phần nhân viên trả theo `subsidy_mode` và trần ngày. Màn thanh toán đọc kết quả này để chuẩn bị sẵn hai tender. Khi complete, cả hai tender phải đủ.
6. **`MealWallets::TopUp(account, amount, tender, key)`**: chạy tender lõi không gắn workspace, ghi `ReceivedFunds` và dòng `top_up`, in phiếu nạp. Lệnh `Refund` và `Adjust` cần approval.
7. **`MealSponsors::Statement(sponsor, period)`**:
   - xuất bảng kê theo kỳ, gồm danh sách suất theo nhân viên và ngày, phần trợ giá và phần nhân viên tự trả;
   - định dạng CSV / XLSX qua `ExportRequest` hiện có;
   - thu nợ của đơn vị chi trả đi qua `Collection` hiện có.
8. **Hook số dư thấp**: sau dòng `spend` của tài khoản kind `meal`, nếu số dư dưới `low_balance_threshold` thì ghi `OutboxEntry` sự kiện `meal_wallet.low_balance`. Chưa gửi tin cho phụ huynh; phần đó làm khi có kênh Zalo / SMS.
9. **Nhập danh sách tài khoản** từ CSV: mã nhân viên, tên, phòng ban, đơn vị chi trả, hạn mức. Chưa cấp thẻ.
10. **API** dưới `/api/v3/admin/pos/`:
    - `meal_sponsors`;
    - `meal_accounts`, gồm `import`, `:id/top_ups`, `:id/refund`, `:id/adjust`;
    - `workspaces/:id/meal_swipes`;
    - `meal_sponsors/:id/statements`.

    Cập nhật `server/openapi/pos-staff.yaml`.

## Client web (`apps/pos`)

- **Màn bán căng tin:**
  - ô quét luôn giữ focus, kể cả sau khi chạm vào lưới món;
  - nhập mã thì hiện thông tin người ăn: tên, số dư, số suất còn và phần trợ giá;
  - âm báo theo `result`: `ok` một tiếng ngắn, `duplicate` hai tiếng, các lỗi khác một tiếng dài. Âm báo dùng file âm thanh có sẵn trong app, bật hoặc tắt theo máy;
  - nút thanh toán một chạm cho `meal_wallet` / `meal_sponsor` khi tài khoản đủ điều kiện.
- **Trang Tài khoản suất ăn:**
  - danh sách, tìm theo mã hoặc tên;
  - nhập CSV; khóa / mở tài khoản;
  - nạp tiền (mở bước tender); lịch sử ví;
  - hoàn và điều chỉnh qua luồng xin duyệt.
- **Trang Đơn vị chi trả:** hạn mức, kiểu trợ giá, xuất bảng kê kỳ, thu nợ (dẫn tới trang công nợ hiện có).
- **Báo cáo:** số suất theo bữa, theo quầy, theo đơn vị chi trả; số lần ghi suất bị từ chối theo lý do.

## Flutter (`apps/pos-staff`)

- Không có mode mới. Mode `kiosk` của phase 23 sẽ dùng `MealAccounts::Swipe` và tender `meal_wallet` qua cùng API; phase 23 ghi phần đó.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_create_spree_pos_meal_accounts.rb` (sponsors, accounts, cards, swipes) và `*_create_spree_pos_stored_value_accounts.rb` (accounts, entries) |
| Tạo | `server/app/models/spree/pos/meal_sponsor.rb`, `meal_account.rb`, `meal_card.rb`, `meal_swipe.rb`, `stored_value_account.rb`, `stored_value_entry.rb` |
| Tạo | `server/app/workflows/spree/pos/meal_accounts/swipe.rb`, `server/app/services/spree/pos/stored_value.rb` (top_up, spend, refund, adjust), `server/app/services/spree/pos/meal_cards/resolve.rb`, `server/app/services/spree/pos/meal_accounts/split_plan.rb`, `server/app/services/spree/pos/meal_sponsors/statement.rb` |
| Sửa | Workflow tender (thêm kind `meal_wallet`, `meal_sponsor`), `server/app/models/spree/pos/pos_payment_method.rb`, `approval.rb`, `capabilities.rb`, `server/config/initializers/pos_modules.rb`, `server/config/pos/business_profiles.yml`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/meal_accounts_controller.rb`, `meal_sponsors_controller.rb`, `meal_cards_controller.rb`, `workspaces/meal_swipes_controller.rb` |
| Tạo | `apps/pos/src/components/scan-input.tsx`, `apps/pos/src/components/meal-card-banner.tsx`, `apps/pos/src/pages/meal-accounts.tsx`, `apps/pos/src/pages/meal-sponsors.tsx`, `apps/pos/src/hooks/use-meal-accounts.ts`, `apps/pos/src/lib/scan-sounds.ts` |
| Sửa | `apps/pos/src/components/payment-panel.tsx`, `apps/pos/src/router.tsx`, `apps/pos/src/locales/*` |

## Các bước

1. Viết migration, model và service `StoredValue`, khóa hàng `StoredValueAccount` cho mọi lệnh ghi sổ.
2. Làm `Resolve` và `Swipe`: tra theo mã / tên, khung giờ, hạn mức, chặn trùng, giới hạn tần suất.
3. Làm tender `meal_wallet` (FIFO allocation) và nạp, hoàn, điều chỉnh ví.
4. Làm tender `meal_sponsor` dùng lại credit, tự duyệt trong hạn mức.
5. Làm `SplitPlan` trợ giá, và kiểm khi complete rằng đã đủ hai tender.
6. Làm bảng kê theo kỳ qua `ExportRequest`.
7. Làm nhập CSV tài khoản.
8. Làm hook số dư thấp vào `OutboxEntry`.
9. Làm API, OpenAPI, màn web (ô quét, âm báo, trang tài khoản, đơn vị chi trả, báo cáo).
10. Bật module, chạy spec, và chạy e2e nhập mã + Enter.

## Kiểm thử

- **Spec `Swipe`:**
  - tài khoản đã khóa bị từ chối; mã không tồn tại trả `unknown`;
  - ghi suất hai lần trong 60 giây bị từ chối với `meal_duplicate_swipe`;
  - quá số suất ngày bị từ chối;
  - ngoài khung giờ bị từ chối;
  - hai request đồng thời cho cùng tài khoản chỉ ghi được một lần `ok` (spec chạy song song như `workspace_race_spec`).
- **Spec ví:**
  - nạp tiền không ghi doanh thu;
  - `meal_wallet` allocate FIFO từ nhiều lần nạp;
  - không đủ số dư thì bị từ chối;
  - hoàn và điều chỉnh cần approval;
  - số dư bằng tổng `stored_value_entries`.
- **Spec đơn vị chi trả:** ghi nợ tự duyệt trong hạn mức, vượt hạn mức thì bị từ chối; bảng kê khớp với `ReceivableEntry`.
- **Spec trợ giá:** suất 35.000, trợ giá 25.000, trần 25.000 một ngày. Suất thứ hai trong ngày thì nhân viên trả toàn bộ. Hóa đơn điện tử là một hóa đơn.
- **Spec bảo mật:** có giới hạn tần suất của `Resolve`; tìm theo tên chỉ trả tài khoản của store hiện tại.
- **E2E web:** nhập mã nhân viên + Enter → thanh toán một chạm → in bill; quét trùng phát âm báo trùng.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Nhập mã nhân viên chậm hơn quẹt thẻ ở giờ cao điểm | Ô nhập giữ focus, gợi ý theo tên. Thẻ là bước sau, khi khách có nhu cầu. |
| Giờ cao điểm nhiều quầy cùng ghi suất, khóa hàng gây chậm | Chỉ khóa hàng tài khoản trong lúc kiểm và ghi. Đo thời gian ghi suất ở bài đo tải (mục tiêu < 300 ms trên server LAN). |
| Ví trả trước là nghĩa vụ phải trả với người dùng | Báo cáo tổng số dư ví theo store, hoàn số dư có approval, và có ghi chú pháp lý trong tài liệu triển khai. |
| Mất mạng ở trạm dừng | Server LAN (D5) giữ quầy chạy được. Hàng đợi offline phía client là phase 27; ghi suất không nằm trong hàng đợi đó vì cần kiểm hạn mức ở server. |

## Tiêu chí xong

- [ ] Nhận diện được người ăn bằng mã nhân viên hoặc tìm theo tên, qua một service `Resolve` duy nhất.
- [ ] Ghi suất kiểm hạn mức, khung giờ, ghi suất trùng ở server; âm báo phân biệt được ba kết quả.
- [ ] Nạp, trừ, hoàn và điều chỉnh ví đều đi qua lõi tiền; số dư khớp sổ.
- [ ] Đơn vị chi trả ghi nợ tự duyệt trong hạn mức; xuất bảng kê theo kỳ; thu nợ bằng luồng hiện có.
- [ ] Trợ giá chia đúng hai phần, hóa đơn vẫn là một.
- [ ] Đã có hook số dư thấp trong outbox.
- [ ] OpenAPI, spec và e2e đều xanh.

## Để sau: thẻ suất ăn

Chưa làm trong plan này (đã chốt 09/11/2026). Khi có khách cần, thêm bảng `spree_pos_meal_cards` (`meal_account_id`, `kind` `qr | rfid`, `token_digest` unique theo store, `last4`, `issued_at`, `revoked_at`) và một nhánh tra thẻ trong `MealAccounts::Resolve`. Giá trị thẻ chỉ lưu digest, giống `DisplayPairing`. Đầu đọc RFID kiểu bàn phím gõ vào ô nhập đã có, nên màn bán không phải sửa.
