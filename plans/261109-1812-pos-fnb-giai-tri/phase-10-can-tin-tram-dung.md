---
phase: 10
title: "Căng tin và trạm dừng"
status: pending
effort: "11 ngày"
dependsOn: [8]
---

# Phase 10: Căng tin và trạm dừng

## Overview

Hai phần cùng phục vụ hồ sơ căng tin / trạm dừng và cùng ghi sổ theo người hoặc xe, chi trả qua lõi tiền.

| Phần | Nội dung | Effort |
|---|---|---|
| 10A | Căng tin: tài khoản suất ăn, ví, công nợ công ty | 7 ngày |
| 10B | Hoa hồng tài xế / phụ xe ở trạm dừng | 4 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 10A: Căng tin: tài khoản suất ăn, ví, công nợ công ty

### Overview

Phần này làm module **`fnb.meal_accounts`** cho căng tin công ty, trường và bệnh viện ([research §3.6](../reports/261109-1748-pos-fnb-giai-tri-research.md)). Phạm vi:

- tài khoản suất ăn gắn với người dùng và công ty;
- nhận diện người ăn bằng **mã nhân viên / học sinh** (gõ hoặc tìm theo tên); thẻ để sau;
- ví trả trước, nạp tiền qua lõi tender;
- hạn mức suất mỗi ngày, chặn ghi suất trùng;
- âm báo khác nhau cho hợp lệ, trùng suất và lỗi;
- công nợ trả sau theo công ty, dùng lại `credit` đang có, xuất bảng kê theo kỳ;
- trợ giá: công ty trả một phần, nhân viên trả phần còn lại;
- màn bán có ô nhập mã luôn sẵn sàng.

Phụ huynh nạp tiền và cảnh báo số dư thấp chỉ được chuẩn bị điểm nối (hook); kênh nạp tiền online để sau.

Câu hỏi mở 2 đã chốt ngày 09/11/2026: **chưa làm thẻ** (RFID hay QR), để phát triển sau. Phần này để sẵn điểm nối cho thẻ (mục "Để sau" ở cuối). Phần còn lại theo mặc định của plan:
- **có** trợ giá;
- trừ lương **chỉ xuất bảng kê**, không tích hợp hệ thống lương.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Tài khoản suất ăn (`MealAccount`) gắn với một `CustomerProfile`. Tài khoản có thể thuộc một **đơn vị chi trả** (`MealSponsor`, là công ty hoặc trường). Bản thân đơn vị chi trả là một `CustomerProfile` có `CreditAccount`, và công nợ của đơn vị đi qua `ReceivableEntry` như ghi nợ hiện có. |
| Q2 | **Chưa có thẻ.** Người ăn được nhận diện bằng `employee_code` (gõ vào ô nhập rồi Enter) hoặc tìm theo tên. Mọi lệnh nhận diện đi qua một service duy nhất `MealAccounts::Resolve(store, input)`, để sau này thêm thẻ chỉ cần thêm một cách tra trong service này, không sửa luồng bán. |
| Q3 | Ví trả trước là **tiền khách gửi giữ, không phải doanh thu**.<br>• **Nạp tiền:** đi qua lõi tender và tạo `ReceivedFunds` không gắn workspace, cùng mô hình với tiền cọc của [phần 9A](./phase-09-nha-hang-bar.md).<br>• **Trừ ví khi bán:** dùng tender kind mới `meal_wallet`, tạo `FundsAllocation` từ các lần nạp cũ nhất trước (FIFO).<br>• **Hoàn số dư khi nghỉ việc:** dùng `LiabilityPayout`, cần approval. |
| Q4 | Trả sau theo công ty dùng đường **ghi nợ sẵn có** (`credit`). Mỗi lần ghi suất không cần quản lý duyệt, vì hạn mức đã được duyệt trước trên `CreditAccount` của đơn vị chi trả. Lệnh dùng cơ chế tự duyệt như `quick_credit` nhưng giới hạn cho tender `meal_sponsor`, nên không cần bật `quick_credit` cho cả chi nhánh. |
| Q5 | Trợ giá chia **một đơn thành hai lần thanh toán**:<br>• phần đơn vị trả (`sponsor`) đi theo Q4;<br>• phần nhân viên trả đi bằng ví, tiền mặt hoặc QR.<br>Phần trợ giá có thể là số tiền cố định hoặc phần trăm theo suất, và có trần theo ngày. Hóa đơn điện tử vẫn là **một hóa đơn** cho cả đơn. |
| Q6 | Hạn mức tính theo `business_date`: số suất mỗi ngày, có thể giới hạn theo bữa (khung giờ). Cùng tài khoản được ghi suất lại trong vòng `duplicate_window_seconds` (mặc định 60 giây) thì bị từ chối với `reason: 'meal_duplicate_swipe'`. Server là bên quyết định; client chỉ phát âm báo theo `reason`. |
| Q7 | Màn bán của căng tin là `menu_grid` (phần 6A) có **ô nhập luôn giữ focus**. Chuỗi kết thúc bằng Enter: nếu khớp `employee_code` thì gắn tài khoản vào đơn, còn không thì coi như quét mã vạch sản phẩm theo `retail.units`. Khi có thẻ, đầu đọc kiểu bàn phím gõ vào đúng ô này. |

### Dữ liệu

- **`spree_pos_meal_sponsors`**
  - Cột: `store_id`, `customer_profile_id` (đơn vị chi trả), `credit_account_id`, `name`, `statement_day` (ngày chốt kỳ), `subsidy_mode` (`none | fixed | percent`), `subsidy_value`, `subsidy_daily_cap`, `status`.
- **`spree_pos_meal_accounts`**
  - Cột: `store_id`, `customer_profile_id`, `meal_sponsor_id` (null), `employee_code`, `group_label` (phòng ban, lớp), `daily_meal_limit`, `meal_windows` (jsonb, danh sách khung giờ được ăn), `pay_mode` (`wallet | sponsor | sponsor_subsidy`), `low_balance_threshold`, `status`.
  - Unique: (`store_id`, `employee_code`).
- **`spree_pos_stored_value_accounts`**
  - Cột: `store_id`, `customer_profile_id`, `kind` (`meal` ở phần này; phần 11B thêm `money | minutes`), `status`.
  - `MealAccount` có thêm `stored_value_account_id`.
- **`spree_pos_stored_value_entries`** (sổ chỉ thêm)
  - Cột: `stored_value_account_id`, `kind` (`top_up | spend | refund | adjust`), `amount` (có dấu), `minutes` (null, để phần 11B dùng), `received_funds_id`, `funds_allocation_id`, `workspace_id`, `actor_id`, `created_at`.
  - Số dư = tổng các dòng. Mọi lệnh ghi đều khóa hàng `StoredValueAccount` trước, giống cách `CreditAccount` khóa hàng.
  - Service dùng chung là `Spree::Pos::StoredValue` (`top_up`, `spend`, `refund`, `adjust`). Phần 11B dùng lại nó cho thẻ nạp tiền và thẻ nạp giờ.
- **`spree_pos_meal_swipes`**
  - Cột: `meal_account_id`, `input_method` (`code | search`, sau thêm `card`), `branch_id`, `business_date`, `meal_window`, `workspace_id`, `result` (`ok | duplicate | limit | revoked | unknown | insufficient`), `created_at`.
  - Dùng để chặn ghi suất trùng, đếm hạn mức và báo cáo.
- **Lõi và cấu hình:**
  - `PosPaymentMethod.kind`: thêm `meal_wallet` và `meal_sponsor`.
  - Approval action mới: `meal_wallet.refund`, `meal_wallet.adjust`, `meal_account.override_limit`.
  - Capabilities mới: `pos.meal_account.manage`.
- **Module:** đăng ký `fnb.meal_accounts` là `available`, thêm vào hồ sơ `cang_tin_tram_dung`.

### Server

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

### Client web (`apps/pos`)

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

### Flutter (`apps/pos-staff`)

- Không có mode mới. Mode `kiosk` của phần 12B sẽ dùng `MealAccounts::Swipe` và tender `meal_wallet` qua cùng API; phần 12B ghi phần đó.

### File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_create_spree_pos_meal_accounts.rb` (sponsors, accounts, cards, swipes) và `*_create_spree_pos_stored_value_accounts.rb` (accounts, entries) |
| Tạo | `server/app/models/spree/pos/meal_sponsor.rb`, `meal_account.rb`, `meal_card.rb`, `meal_swipe.rb`, `stored_value_account.rb`, `stored_value_entry.rb` |
| Tạo | `server/app/workflows/spree/pos/meal_accounts/swipe.rb`, `server/app/services/spree/pos/stored_value.rb` (top_up, spend, refund, adjust), `server/app/services/spree/pos/meal_cards/resolve.rb`, `server/app/services/spree/pos/meal_accounts/split_plan.rb`, `server/app/services/spree/pos/meal_sponsors/statement.rb` |
| Sửa | Workflow tender (thêm kind `meal_wallet`, `meal_sponsor`), `server/app/models/spree/pos/pos_payment_method.rb`, `approval.rb`, `capabilities.rb`, `server/config/initializers/pos_modules.rb`, `server/config/pos/business_profiles.yml`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `server/app/controllers/spree/api/v3/admin/pos/meal_accounts_controller.rb`, `meal_sponsors_controller.rb`, `meal_cards_controller.rb`, `workspaces/meal_swipes_controller.rb` |
| Tạo | `apps/pos/src/components/scan-input.tsx`, `apps/pos/src/components/meal-card-banner.tsx`, `apps/pos/src/pages/meal-accounts.tsx`, `apps/pos/src/pages/meal-sponsors.tsx`, `apps/pos/src/hooks/use-meal-accounts.ts`, `apps/pos/src/lib/scan-sounds.ts` |
| Sửa | `apps/pos/src/components/payment-panel.tsx`, `apps/pos/src/router.tsx`, `apps/pos/src/locales/*` |

### Các bước

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

### Kiểm thử

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

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Nhập mã nhân viên chậm hơn quẹt thẻ ở giờ cao điểm | Ô nhập giữ focus, gợi ý theo tên. Thẻ là bước sau, khi khách có nhu cầu. |
| Giờ cao điểm nhiều quầy cùng ghi suất, khóa hàng gây chậm | Chỉ khóa hàng tài khoản trong lúc kiểm và ghi. Đo thời gian ghi suất ở bài đo tải (mục tiêu < 300 ms trên server LAN). |
| Ví trả trước là nghĩa vụ phải trả với người dùng | Báo cáo tổng số dư ví theo store, hoàn số dư có approval, và có ghi chú pháp lý trong tài liệu triển khai. |
| Mất mạng ở trạm dừng | Server LAN (D5) giữ quầy chạy được. Hàng đợi offline phía client là phần 12D; ghi suất không nằm trong hàng đợi đó vì cần kiểm hạn mức ở server. |

### Tiêu chí xong

- [x] Nhận diện được người ăn bằng mã nhân viên hoặc tìm theo tên, qua một service `Resolve` duy nhất.
- [x] Ghi suất kiểm hạn mức, khung giờ, ghi suất trùng ở server; âm báo phân biệt được ba kết quả.
- [x] Nạp, trừ, hoàn và điều chỉnh ví đều đi qua lõi tiền; số dư khớp sổ.
- [x] Đơn vị chi trả ghi nợ tự duyệt trong hạn mức; xuất bảng kê theo kỳ; thu nợ bằng luồng hiện có.
- [x] Trợ giá chia đúng hai phần, hóa đơn vẫn là một.
- [x] Đã có hook số dư thấp trong outbox.
- [ ] OpenAPI, spec và e2e đều xanh.

### Để sau: thẻ suất ăn

Chưa làm trong plan này (đã chốt 09/11/2026). Khi có khách cần, thêm bảng `spree_pos_meal_cards` (`meal_account_id`, `kind` `qr | rfid`, `token_digest` unique theo store, `last4`, `issued_at`, `revoked_at`) và một nhánh tra thẻ trong `MealAccounts::Resolve`. Giá trị thẻ chỉ lưu digest, giống `DisplayPairing`. Đầu đọc RFID kiểu bàn phím gõ vào ô nhập đã có, nên màn bán không phải sửa.

### Kết quả

Đã làm:

- **Dữ liệu.** Có ba migration:
  - `20261112050000_create_spree_pos_stored_value_accounts`: ví và sổ ví. Sổ ví có check theo loại dòng: `top_up` dương và có khoản nhận; `spend` âm và có allocation; `refund` âm và có payout; `adjust` khác 0. Allocation và payout là unique.
  - `…050100_create_spree_pos_meal_accounts`: đơn vị chi trả, tài khoản suất ăn và lượt ghi suất.
  - `…050200_allow_meal_reports_in_spree_pos_export_requests`.

  Cả ba đã chạy ở DB dev và test. `schema.rb` dựng lại từ HEAD cộng các bảng mới, vẫn đủ 210 check constraint. Model mới: `StoredValueAccount`, `StoredValueEntry`, `MealSponsor`, `MealAccount`, `MealSwipe`.
- **Ví** (`StoredValue`, theo `docs/adr/0003-pos-vi-suat-an.md`):
  - `MealWallets::TopUp` nhận tiền mặt hoặc `bank_manual` thành một `ReceivedFunds` không có đơn, vào ca đang mở của người thu, và in phiếu nạp.
  - `MealWallets::Pay` (`workspaces/:id/meal_wallet`) allocate các khoản nạp vào đơn, khoản cũ trước. Mỗi phần là một core `Payment` đã hoàn tất cộng một `FundsAllocation`, kèm một dòng `spend`.
  - `MealWallets::Refund` hoàn bằng `LiabilityPayout`, người thứ hai xác nhận.
  - `MealWallets::Adjust` sửa số dư trong khoảng từ 0 tới phần còn của các khoản nạp. Hoàn và điều chỉnh tiêu thụ approval `meal_wallet.refund` / `meal_wallet.adjust`, gắn với tài khoản theo revision và số tiền.
  - Mọi lệnh khóa hàng ví trước, rồi mới khóa khoản nhận. Đảo allocation, hoặc payout thất bại / bị hủy, trả tiền lại vào ví bằng dòng `adjust`.
- **Nhận diện và ghi suất.** `MealAccounts::Resolve` là chỗ duy nhất nhận diện người ăn: mã nhân viên khớp đúng, hoặc tối đa 8 gợi ý theo tên, luôn trong store hiện tại. API `meal_accounts/resolve` giới hạn 120 lần một phút cho mỗi nhân viên (429 `meal_resolve_rate_limited`). `MealAccounts::Swipe` khóa hàng tài khoản rồi kiểm theo thứ tự:
  1. tài khoản bị khóa (`meal_account_locked`);
  2. trùng trong 60 giây (`meal_duplicate_swipe`);
  3. ngoài khung giờ (`meal_outside_window`, có khung qua nửa đêm);
  4. quá suất ngày hoặc quá suất của khung (`meal_daily_limit`).

  Vượt khung giờ hoặc hạn mức cần approval `meal_account.override_limit`. Mọi lần ghi, cả lần bị từ chối, đều để lại một dòng `meal_swipes`. Ghi được thì người ăn thành khách của đơn. Đơn bị hủy, hoặc đổi khách, thì suất được trả lại.
- **Đơn vị chi trả và trợ giá.**
  - `MealSponsors::Save` lưu đơn vị chi trả. Hạn mức và số ngày nợ đi qua `Credit::Configure`.
  - `MealAccounts::SplitPlan` chia phần đơn vị trả và phần người ăn trả:
    - theo `pay_mode`: `wallet`, `sponsor`, `sponsor_subsidy`;
    - trợ giá cố định hoặc theo phần trăm;
    - trần trợ giá mỗi ngày tính theo các đơn đã hoàn tất trong ngày của người ăn.
  - `complete` với `meal_sponsor: true` (`MealAccounts::ChargeSponsor`) ghi phần đơn vị chi trả thành `ReceivableEntry` debit:
    - trong cùng lệnh hoàn tất, dưới khóa tài khoản công nợ;
    - kèm một `CreditReservation` committed và một approval tự tiêu thụ, vì ràng buộc của debit cần chúng;
    - không cần quản lý duyệt từng suất.

    Vượt hạn mức báo `sponsor_limit`. Phần người ăn chưa trả đúng báo `meal_split_unpaid`. Vẫn chỉ có một đơn, nên vẫn một hóa đơn. Thu nợ đi qua luồng công nợ hiện có.
- **Báo cáo.** `meals` cho số suất theo ngày, khung giờ, quầy, đơn vị chi trả và kết quả; tóm tắt có số lần bị từ chối theo lý do. `meal_statement` (cần `meal_sponsor_id`) là bảng kê kỳ, khớp với các debit trong sổ công nợ. Cả hai xuất CSV qua `ExportRequest`.
- **Nhập CSV.** `meal_accounts/import` nhận đủ hoặc không nhận dòng nào. Khi từ chối, câu trả lời liệt kê lỗi theo dòng và cột. Giới hạn 5000 dòng, 2 MB.
- **Số dư thấp.** Khi trả bằng ví làm số dư xuống dưới ngưỡng, hệ thống ghi outbox `meal_wallet.low_balance`. Mỗi lần nạp ghi `meal_wallet.topped_up`.
- **Module, quyền, API.** Module `fnb.meal_accounts` đã đăng ký và bật trong hồ sơ `cang_tin_tram_dung`. Capability mới là `pos.meal_account.manage`; dashboard có 31 quyền. Approval mới gắn với `MealAccount`, xin qua `approvals` với `meal_account_id`. Có route `meal_accounts` (list, show, create, update, `entries`, `top_ups`, `refund`, `adjust`, `resolve`, `import`), `meal_sponsors` và `workspaces/:id/meal|meal_swipes|meal_wallet`. `pos-staff.yaml` có các schema tên riêng: `MealAccount`, `MealStatus`, `MealSplitPlan`, `MealResolve`, `MealSwipe*`, `MealWalletPay*`, `WorkspaceMeal*`. Client Dart đã sinh lại.
- **Web `apps/pos`.**
  - Ô quét trên màn bán, chỉ hiện khi bật module (`scan-input.tsx`):
    - luôn giữ focus;
    - Enter thì tra mã: khớp đúng là ghi suất, nhiều kết quả thì hiện danh sách chọn, không khớp mà giống mã vạch thì chuyển sang tra mã vạch hàng.
  - `scan-sounds.ts` có ba âm (ghi được, trùng, lỗi), bật / tắt theo máy.
  - `meal-banner.tsx` hiện tên, mã, nhóm, số dư, số suất còn, cảnh báo số dư thấp và phần chia, cùng nút thanh toán một chạm: trả phần người ăn bằng ví rồi hoàn tất, có `meal_sponsor` khi đơn vị chi trả có phần.
  - Bảng thanh toán thường cũng hoàn tất với `meal_sponsor` khi đơn có phần của đơn vị chi trả.
  - Trang `/meal-accounts`: tra cứu, lịch sử ví, nạp (in phiếu), hoàn và điều chỉnh có ô mã duyệt.
  - Chuỗi vi / en.
- **Dashboard.**
  - Trang Tài khoản suất ăn: danh sách và lọc, thêm / sửa có khung giờ, khóa / mở khóa, nhập CSV có lỗi theo dòng, lịch sử ví chỉ xem.
  - Trang Đơn vị chi trả: hạn mức, trợ giá, ngày chốt kỳ, xuất bảng kê theo kỳ, nút thu nợ dẫn tới trang công nợ.
  - Hai tab báo cáo `meals` và `meal_statement`.
  - Nhóm menu "Căng tin".
- **Tài liệu.** `docs/adr/0003-pos-vi-suat-an.md` ghi ví là tiền giữ hộ, đơn vị chi trả là công nợ, kèm ghi chú pháp lý về số dư ví.

Lệch so với kế hoạch:

- Không thêm tender kind `meal_wallet` / `meal_sponsor` và không sửa `pos_payment_method.rb`:
  - Trả bằng ví là lệnh riêng `meal_wallet`, làm như trừ cọc: tiền đã nhận lúc nạp nên không tạo tender mới.
  - Phần đơn vị chi trả là cờ `meal_sponsor` của `complete`, ghi nợ ngay khi hoàn tất.
  - Kiểm "đủ hai phần" là `meal_split_unpaid`.
- Không có bảng và lookup thẻ (`meal_cards`, `MealCards::Resolve`), theo mục "Để sau".
- Swipe không từ chối vì thiếu số dư (không có kết quả `insufficient`). Thu ngân thấy `wallet_covers` và cho người ăn trả phần thiếu bằng tender thường. Có thêm kết quả `window` cho ngoài khung giờ. Thời gian chặn trùng là hằng 60 giây.
- Bảng kê là báo cáo `meal_statement` qua luồng export sẵn có, theo chi nhánh. Không có route `meal_sponsors/:id/statements` hay service `MealSponsors::Statement` riêng.
- Đơn không lưu cột tài khoản suất ăn. Tài khoản của đơn suy ra từ lượt ghi suất còn tính, nên context POS và giới hạn query không đổi.
- Giới hạn tần suất của `Resolve` tính theo nhân viên đăng nhập, không theo thiết bị.
- Tài khoản mới (cả khi nhập CSV) cần số điện thoại hoặc email, vì hồ sơ khách bắt buộc có liên hệ.
- Tham số vượt hạn mức trên API là `override_limit`. Tên `override` trùng annotation của Dart nên client không biên dịch được.
- Trang Đơn vị chi trả nằm ở dashboard, không ở `apps/pos`: đây là màn quản trị.
- Constraint loại báo cáo của export trước đây thiếu `bar` (từ phần 9B); migration mới thêm cả `bar` và hai loại mới.
- Ghi nợ đơn vị chi trả chỉ cần module `fnb.meal_accounts`, không kiểm feature `credit` của chi nhánh. Hạn mức vẫn do người có `pos.credit.manage` đặt.

Lệnh và kết quả:

- `pnpm spree migrate` rồi `pnpm spree exec bin/rails db:test:prepare`: chạy được, schema còn đủ 210 check constraint.
- `pnpm spree rspec` các spec mới: `spec/workflows/spree/pos/meal_accounts/swipe_spec.rb` (7/0), `wallet_spec.rb` (6/0), `sponsor_spec.rb` (3/0), `spec/integration/spree/pos/meal_swipe_race_spec.rb` (1/0), `spec/requests/spree/pos/meal_accounts_spec.rb` (6/0). Chạy lại cả nhóm lần cuối: 23/0.
- Spec module và hồ sơ (branch_modules, branch_profiles, business_profiles request và service, onboarding, topology, module_policy): 72/0.
- Spec quanh phần lõi đã sửa (`Complete`, `AssignCustomer`, `ReverseAllocation`, `LiabilityPayouts::Resolve`, approvals, reports, capabilities): `credit_race`, `credit_receivables`, `quick_credit`, `returns_refunds`, `credit_returns`, `credit_sales`, `funds_conservation`, `refunds`, `reservations/deposits`, `printers`, `security`, `sale_guards`, `workspace_discounts`, `bottle_keeps`, `settlement_race`, `reports`: 140/0.
- Sau khi đổi `pos-staff.yaml`: `meal_accounts_spec`, `devices_spec`, `print_documents_spec`: 25/0.
- `packages/pos-shared`: `pnpm test` 280 qua, `pnpm typecheck` và `pnpm lint` sạch.
- `apps/pos`:
  - `pnpm lint` và `pnpm typecheck` sạch, `pnpm test` 300 qua.
  - `playwright test e2e/meal-accounts.spec.ts --project desktop`: 2/2. Spec kiểm nhập mã + Enter → thanh toán một chạm → in bill, và quét trùng phát âm báo trùng.
  - Chạy thêm `split-tender`, `full-retail`, `bar-tabs`, `user-menu`, `credit-collections`, `catalog-scan`, `fnb-menu`, `branch-modules`, `reservations`: 45 qua, 1 bỏ qua. `reservations` lỗi một lần khi chạy song song và qua khi chạy riêng.
- `apps/pos-dashboard`: `pnpm lint` và `pnpm typecheck` sạch, `pnpm test` 115 qua.
- `apps/pos-staff`: `tool/gen_api.sh` sinh lại client; `flutter analyze` không có lỗi; `flutter test` 137 qua.

Còn mở:

- Chưa chạy e2e dashboard (`administration.spec.ts` đếm 31 quyền), vì cổng 5176 đang dùng cho dashboard của developer. Tiêu chí "OpenAPI, spec và e2e đều xanh" vì vậy chưa tick.
- Chưa có báo cáo tổng số dư ví theo store (rủi ro "ví trả trước là nghĩa vụ phải trả"). Hiện chỉ xem được số dư từng tài khoản.
- Ghi chú pháp lý ở ADR 0003 cần kế toán và tư vấn pháp lý của khách xác nhận trước khi triển khai: ví đóng chỉ dùng trong căng tin, và cách xử lý số dư khi nghỉ việc.
- Chưa đo thời gian ghi suất ở bài đo tải (mục tiêu < 300 ms trên server LAN). Chưa thử đầu đọc mã vạch / RFID thật.
- Web chưa có luồng xin duyệt để vượt hạn mức hay khung giờ khi ghi suất; quầy chỉ báo lý do. API đã nhận `override_limit` và `approval_id`.
- Phiếu nạp ví in qua máy in LAN của quầy hoặc trình duyệt, chưa xếp vào hàng đợi in của trạm in. Nạp chuyển khoản trùng mã giao dịch chỉ báo trùng, chưa có bước xác nhận vẫn nhận.
- Chưa có thông báo thật khi số dư thấp; outbox mới ghi sự kiện để dùng sau.
- Toàn bộ thay đổi chưa commit; controller sẽ commit. Chưa chạy full rspec / e2e: để GitHub Actions chạy.

## Phần 10B: Hoa hồng tài xế / phụ xe ở trạm dừng

### Overview

Trạm dừng nghỉ thường trả hoa hồng cho tài xế hoặc phụ xe đưa khách vào ăn và mua hàng. Phần này ghi nhận **lượt xe**, gắn các đơn bán trong lượt đó vào xe, tính hoa hồng và chi tiền cho tài xế từ ngăn kéo qua luồng chi tiền đã có.

Cách tính đã chốt ngày 09/11/2026 là **cả hai**:
- **theo xe**: mỗi lượt xe một khoản cố định, có thể khác nhau theo loại xe (16, 29, 45 chỗ);
- **theo khách**: số khách × đơn giá.

Một quy tắc có thể dùng một trong hai cách hoặc cả hai cộng lại. Hoa hồng theo % doanh thu không có trong lựa chọn đã chốt. Nếu cần thì thêm loại quy tắc `revenue_percent` theo cùng mô hình, không phải đổi bảng.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Hoa hồng là **chi phí của quán**, không giảm doanh thu đơn và không đụng hóa đơn điện tử. Đơn của khách vẫn tính đủ giá. |
| Q2 | **Lượt xe** (`VehicleVisit`) do thu ngân hoặc nhân viên đón xe mở. Lượt gồm biển số, nhà xe, loại xe, tên và số điện thoại tài xế / phụ xe, số khách (nhập hoặc sửa được đến khi chốt), giờ đến. Lượt tự đóng sau `visit_window_minutes` (mặc định 60 phút) hoặc khi bấm "Xe đã đi". |
| Q3 | Đơn bán được gắn vào một lượt xe đang mở bằng nút chọn xe trên màn bán (`Workspace.vehicle_visit_id`). Gắn hay đổi lượt chỉ làm được trước khi complete. Số khách để tính hoa hồng là số nhập trên lượt, không suy ra từ số đơn. |
| Q4 | Quy tắc hoa hồng (`CommissionRule`) gắn với chi nhánh và có thể gắn riêng nhà xe. Mỗi quy tắc có: `per_vehicle_amount` theo loại xe, `per_guest_amount`, điều kiện tối thiểu (số khách hoặc doanh thu tối thiểu của lượt), và thời gian hiệu lực. Quy tắc riêng của nhà xe được ưu tiên hơn quy tắc chung của chi nhánh. |
| Q5 | Khi chốt lượt, server tính hoa hồng và lưu **snapshot** gồm quy tắc, số khách, doanh thu lượt và số tiền. Sửa quy tắc sau đó không làm đổi lượt đã chốt. |
| Q6 | Chi hoa hồng bằng tiền mặt đi qua `CashMovementRequest` kind `cash_out` có lý do "Hoa hồng xe <biển số>". Luồng duyệt có sẵn của request này được giữ nguyên. Một lượt chỉ chi được một lần (unique theo `vehicle_visit_id`). Chi bằng chuyển khoản thì chỉ ghi nhận "đã chi" kèm mã giao dịch, không đụng ngăn kéo. |
| Q7 | Sửa số khách hoặc số tiền **sau khi chốt** cần `Approval` action `vehicle_visit.adjust`, và có ghi `AuditEntry`. |

### Dữ liệu

| Bảng | Cột chính | Ràng buộc |
|---|---|---|
| `spree_pos_bus_operators` (nhà xe) | `store_id`, `name`, `phone`, `note`, `status` | unique `(store_id, name)` |
| `spree_pos_vehicle_visits` | `store_id`, `branch_id`, `bus_operator_id` (nullable), `plate`, `vehicle_type` (`seat_16|seat_29|seat_45|other`), `driver_name`, `driver_phone`, `guest_count`, `arrived_at`, `closed_at`, `status` (`open|closed|paid|voided`), `business_date`, `opened_by_id`, `commission_snapshot jsonb`, `commission_amount`, `paid_at`, `payout_method` (`cash|transfer`), `cash_movement_request_id`, `transfer_reference` | index `(branch_id, business_date)`, `(branch_id, plate, status)` |
| `spree_pos_commission_rules` | `store_id`, `branch_id`, `bus_operator_id` (nullable), `per_vehicle_amounts jsonb` (theo `vehicle_type`), `per_guest_amount`, `min_guests`, `min_revenue`, `starts_on`, `ends_on`, `status` | check ít nhất một trong hai khoản lớn hơn 0 |
| `spree_pos_workspaces` (sửa) | `vehicle_visit_id` (nullable, FK) | index |

Migration: `create_pos_bus_operators_and_vehicle_visits`, `create_pos_commission_rules`, `add_vehicle_visit_to_pos_workspaces`.

Số điện thoại tài xế là dữ liệu cá nhân: chỉ hiện cho người có quyền `pos.vehicle_visit.manage`, và không có trong file xuất trừ khi người xuất có quyền đó.

### Server

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

### Client web (`apps/pos`)

- Thanh "Xe đang ở trạm" trên màn bán: danh sách lượt đang mở (biển số, nhà xe, số khách, thời gian còn lại). Có nút "Xe mới" và nút gắn đơn đang mở vào một xe.
- Màn "Lượt xe": lọc theo ngày và trạng thái, chốt lượt, xem tính toán, chi tiền (mở luồng chi tiền ngăn kéo có sẵn), sửa có duyệt.
- Cài đặt: nhà xe, quy tắc hoa hồng (bảng theo loại xe + đơn giá theo khách).
- Báo cáo hoa hồng xe ở trang Báo cáo.

### File

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

### Các bước

1. Viết migration và model, kèm spec validation và quyền xem số điện thoại.
2. Viết `Calculator`, có spec cho theo xe, theo khách, cả hai, điều kiện tối thiểu, và quy tắc riêng của nhà xe được ưu tiên.
3. Viết các workflow `open`, `attach_workspace`, `close`, `void`, kèm job tự đóng.
4. Viết `pay` qua `CashMovementRequest`, đảm bảo idempotent và chỉ chi một lần cho mỗi lượt; viết `adjust` có `Approval`.
5. Làm báo cáo và xuất CSV.
6. Làm API, OpenAPI và UI web, rồi bật module trong hồ sơ trạm dừng.

### Kiểm thử

- `pnpm spree rspec spec/models/spree/pos/vehicle_visit_spec.rb spec/services/spree/pos/vehicle_commission/ spec/workflows/spree/pos/vehicle_visits/ spec/requests/spree/pos/vehicle_visits_spec.rb`
- Spec chính:
  - hoa hồng không làm đổi tổng đơn hay hóa đơn điện tử;
  - chi hai lần cho một lượt chỉ tạo một `CashMovementRequest`;
  - sửa quy tắc sau khi chốt không đổi snapshot;
  - sửa sau chốt mà không có `Approval` bị từ chối;
  - gắn đơn đã complete bị từ chối.
- E2E web: xe mới → gắn 3 đơn → complete → chốt lượt → chi tiền mặt → tiền mong đợi trong ngăn kéo giảm đúng số hoa hồng.
- Chạy lại `pnpm --dir apps/pos lint`, `typecheck`, `test`.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Khai khống số khách để lấy hoa hồng | Sửa sau chốt phải có duyệt; báo cáo tỷ lệ hoa hồng / doanh thu theo nhà xe để phát hiện bất thường; có điều kiện doanh thu tối thiểu. |
| Thu ngân quên gắn đơn vào xe | Thanh "Xe đang ở trạm" luôn hiện khi có lượt mở; doanh thu lượt chỉ dùng cho điều kiện tối thiểu và báo cáo, không quyết định số tiền khi quy tắc chỉ tính theo xe / khách. |
| Chi tiền mặt làm lệch ngăn kéo | Đi qua `CashMovementRequest` và đối soát ca có sẵn; không có đường chi tiền riêng. |
| Lộ số điện thoại tài xế | Ẩn theo quyền, và lọc khỏi file xuất. |

### Tiêu chí xong

- [ ] Mở, gắn đơn, chốt, chi và sửa lượt xe chạy đúng quyền và duyệt.
- [ ] Tính đúng hoa hồng theo xe, theo khách và cả hai; snapshot không đổi khi sửa quy tắc.
- [ ] Chi tiền mặt đi qua luồng chi tiền ngăn kéo; mỗi lượt chỉ chi một lần.
- [ ] Báo cáo theo nhà xe và biển số xuất được CSV.
- [ ] Spec và e2e xanh; OpenAPI đã cập nhật.

## Tiêu chí xong của plan

- [ ] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
