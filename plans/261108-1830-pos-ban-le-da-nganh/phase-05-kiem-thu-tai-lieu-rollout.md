---
phase: 5
title: "Kiểm thử hồi quy, tài liệu, rollout"
status: completed
effort: "1,5 ngày"
dependsOn: [3, 4]
---

# Phase 5: Kiểm thử hồi quy, tài liệu, rollout

## Kiểm thử

1. **Hồi quy server:** chạy toàn bộ `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/`. Đặc biệt các spec `sale_lines_spec`, `traceability_spec`, `scale_labels_spec`, `settlement_spec`, `returns_refunds_spec` phải pass **hai lần**:
   - lần một với chi nhánh fixture bật đủ ba module;
   - lần hai với chi nhánh tắt cả ba module, nhưng SKU đã được cấu hình **trước khi** tắt.

   Lần hai chứng minh D5. Làm bằng shared context `with branch modules off` trong `spec/support`.
2. **Hồi quy client:** `pnpm --dir apps/pos test:e2e` đủ ba viewport, cộng các spec mới `branch-modules`, `onboarding`, `business-model`.
3. **Real API:**
   - Thêm vào `e2e/support/pos-live-fixture.rb` tùy chọn tạo store mới chưa onboard (`onboarding=1`). Chỉ chạy trên database cục bộ, gắn nhãn `POS Live <tag>`.
   - Phần dọn dẹp xóa store profile, chi nhánh, module của fixture theo đúng mẫu hiện có.
4. **Migration trên bản sao dữ liệu dev:**
   - Đếm chi nhánh trước và sau.
   - Mỗi chi nhánh có đủ ba dòng module.
   - Store đã có chi nhánh không thấy wizard.
5. **Hiệu năng:** `GET /pos/context` thêm `modules` chỉ tốn một query theo chi nhánh. Đo bằng `test:perf` để kiểm thời gian chuyển context không tăng đáng kể.

## Tài liệu

- `apps/pos/README.md`:
  - mục "Khái niệm chính" thêm **Ngành / mô hình kinh doanh**;
  - mục "Quản trị" thêm **Mô hình kinh doanh**;
  - mục "Cách sử dụng" thêm bước 0 **Thiết lập cửa hàng**;
  - ghi rõ "tắt chức năng không làm đổi cách bán SKU đã cấu hình".
- Báo cáo kiến trúc `plans/reports/261108-1800-pos-multi-industry-architecture.md` §8: D5 và D8 đã được ghi vào lúc lập plan. Khi xong, bổ sung những gì thực tế làm khác plan.
- `plans/261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md`: thêm một dòng tham chiếu tới plan này ở mục 2 (vẫn chỉ bán lẻ; không đổi ranh giới "không F&B").
- Ghi kết quả từng phase vào phần "Kết quả" của file phase, theo cách các plan trước đã làm.

## Rollout

- Không cần feature flag mới. Store cũ được backfill thành `khac` và đã có store profile, nên không thấy wizard và không đổi gì.
- Thứ tự deploy:
  1. Migration + server (client cũ bỏ qua `modules`, coi như bật hết).
  2. Client.
- Rollback client an toàn vì server vẫn tương thích ngược. Rollback server cần migration down: xóa hai bảng và hai cột, không có dữ liệu tiền bị ảnh hưởng.

## Success Criteria

- [x] Toàn bộ spec server pass ở cả hai chế độ module.
- [ ] `pnpm --dir apps/pos lint && pnpm --dir apps/pos typecheck && pnpm --dir apps/pos test && pnpm --dir apps/pos test:e2e` pass. (`typecheck` và `test` pass. `lint` fail vì CRLF, `test:e2e` còn 6 fail đã biết, cả hai không do plan này; xem "Kết quả".)
- [x] README và báo cáo kiến trúc đã cập nhật; mọi phase có phần "Kết quả".
- [x] Đã thử wizard với real API trên store mới ít nhất một lần, có ghi lại kết quả.

## Kết quả (09/11/2026)

Đã làm:
- Shared context `with branch modules off` trong `server/spec/support/pos_module_helpers.rb`, dựng trên helper của phase 2:
  - Khi bật, chi nhánh tạo trong spec nhận dòng module `enabled: false`.
  - Mọi request chạy với **mọi** dòng module tắt, trừ chính các lệnh thiết lập có `ModulePolicy.require!`: `PUT units/variant`, `POST`/`PATCH label_formats`, `POST inventory/opening_balances`. Lệnh thiết lập chạy với module bật rồi tắt lại ngay khi trả về, giống một quản lý bật module, cấu hình SKU rồi tắt trước khi có ai bán.
  - Vì vậy mọi việc sau khi cấu hình (bán, thu tiền, hoàn tất, giao hàng, trả hàng, hoàn tiền, nhận hàng, đọc), qua HTTP hay gọi workflow trực tiếp, đều chạy trên dòng module tắt. Các guard thiết lập vẫn chạy thật.
  - Hook `after` khẳng định cuối example không còn dòng module nào bật. Cuối lượt chạy in số request đã chạy với module tắt và số lệnh thiết lập.
- Năm spec `sale_lines`, `traceability`, `scale_labels`, `settlement`, `returns_refunds` có metadata `modules_off_rerun: true` (chỉ sửa dòng `RSpec.describe`). `pnpm spree rspec spec/requests/spree/pos/ --tag modules_off_rerun` vừa chọn năm file đó vừa bật shared context. `.rspec` nạp `rails_helper` trước khi filter dòng lệnh có hiệu lực, nên helper đọc tag trong `when_first_matching_example_defined`. `spree rspec` không chuyển biến môi trường vào container, nên không dùng env var.
- Hai example kiểm chính lệnh chặn thiết lập có `:module_setup` và bị loại khỏi lượt chạy tắt module: `scale_labels_spec` "keeps selling configured labels with the modules off and refuses new measured or unit setup" và `traceability_spec` "refuses new tracked setup with the module off and keeps selling and returning tracked stock". Lý do: hai example này tự tắt module rồi chờ 409 `module_disabled` từ lệnh thiết lập, mà lượt chạy này cố ý cho lệnh thiết lập qua. Ở lượt thường hai example vẫn chạy và pass.
- `PUT /store_profile` với `interests: []` (câu hỏi mở của phase 4): Rails giữ mảng rỗng, server xóa hết ngành quan tâm, có audit. `interests: null` cũng xóa hết, vì key có mặt và `Array(nil)` là `[]`; bỏ hẳn field thì giữ nguyên. Không cần sửa server; thêm example vào `branch_profiles_spec.rb`.
- Hiệu năng `GET /pos/context`: example mới trong `business_profiles_spec.rb` đếm query.
- Fixture API thật `apps/pos/e2e/support/pos-live-fixture.rb`:
  - Tùy chọn `onboarding=N` (1–3) không đụng store dev. Nó tạo N store mới `POS Live <tag> <n>` (code `pos-live-<tag>-<n>`), mỗi store một kho active, chưa có store profile hay chi nhánh, và một chủ `pos-live-owner-<tag>@example.test` có role cấu hình + bán trên mọi store đó, chưa có membership POS. JSON ghi vào `server/log/pos-live/` như fixture cũ.
  - `cleanup` thêm phần cho các store này (`POS Live %`, code `pos-live-%`, không bao giờ là store mặc định):
    - xóa feature flag, branch module, membership, quầy, hàng bán tại chi nhánh, chi nhánh, đơn vị và store profile của store;
    - gỡ grant của role trên store;
    - xóa mềm kho và store (`deleted_at`).

    Audit và command receipt được giữ làm lịch sử. Phần retire nhân viên `pos-live-*` giữ nguyên.
- e2e `real API` mới trong `e2e/onboarding.spec.ts`, cùng cơ chế opt-in với các nhóm `real API` cũ: `POS_LIVE_REVIEW=1` và `POS_LIVE_ONBOARDING_FIXTURE`, chỉ desktop. Helper mới trong `e2e/support/live.ts`: `requireLiveOnboarding`, `routeToStore`, `liveStoreApi`; `apiToken` tách ra `loginToken`.
- Tài liệu: README (khái niệm, quản trị, bước 0, giới hạn, developer), báo cáo kiến trúc §8.1, một dòng tham chiếu ở mục 2 của `product-and-architecture.md`.

Kết quả với API thật (stack dev, đã eject; fixture `c0429e4adb`, sau hai lượt chạy hỏng do assertion sai shape):
- Store 1, Nhà thuốc, giữ tick "Cấp cho tôi toàn quyền", tick "Trả hàng":
  - `GET /pos/configuration/locations` 200 cho tài khoản thiết lập; kho duy nhất được tự chọn.
  - `POST /pos/onboarding` 201: một chi nhánh `nha_thuoc`, "Quầy 1", membership có `pos.shift.open`, `modules = { units: true, measured: false, traceability: true }`.
  - POS về `/` với chi nhánh và quầy mới đã chọn, hiện ô "Tiền đầu ca", không mở hộp chọn nơi bán.
  - Gửi lại đúng key và body → 201, body giống hệt lần đầu, vẫn một chi nhánh.
  - Lần thiết lập thứ hai (key khác) → 409 `already_onboarded`, vẫn một chi nhánh.
  - Cờ đã tick thành mặc định cấp cửa hàng: `switches.returns = { store: true, branch_override: null }`, `features.returns = true`; `refunds` vẫn tắt.
  - `context.onboarding = { required: false, can_setup: true }`.
- Store 2, Thời trang, **bỏ** tick "Cấp cho tôi toàn quyền":
  - 201 với `membership: null`, mọi module và cờ tắt.
  - POS vẫn về `/` và chọn chi nhánh + quầy mới, vì quản trị store thấy mọi chi nhánh. `capabilities` chỉ còn `pos.topology.read`, `pos.topology.manage`.
  - Màn bán báo "Cần có ca đang mở và thuộc tài khoản của bạn để tạo đơn.", không có ô mở ca, "Đơn nháp mới" bị khóa; không lỗi, không quay lại `/setup`.
  - Mở lại `/setup` không còn wizard.
- Dọn: `cleanup` chạy sau mỗi lượt (ba fixture). Lần đầu fail vì `Spree::Role` không xóa được khi còn grant; transaction rollback, đã sửa script (gỡ grant trước) rồi chạy lại. Kiểm sau cùng:
  - 0 store `POS Live` chưa xóa (6 store đã xóa mềm);
  - 0 store profile, chi nhánh, module, quầy, membership, cờ hay đơn vị còn lại trong các store đó; 0 grant; 0 kho chưa xóa;
  - store dev giữ nguyên: profile `khac`, 8 chi nhánh, 24 dòng module.

  File credential JSON đã xóa.

Khác với plan:
- D5 được chứng minh bằng cách bật/tắt dòng module **theo từng request**, không phải tắt một lần sau khi cấu hình. Lý do: năm spec cấu hình SKU qua HTTP xen kẽ với việc bán, trong cùng một example. Cách này chặt hơn: mọi request không phải lệnh thiết lập đều chạy với module tắt. Đã thử thêm tạm `ModulePolicy.require!` vào `Tenders::Guard.tracked_guard!`: lượt chạy tắt module fail 22/48, lượt thường chỉ fail 1 example (đã gỡ ngay).
- Lượt chạy tắt module chỉ gồm năm spec được nêu, không phải toàn bộ spec server.
- Client POS không gửi `X-Spree-Store-Id`, nên API luôn trả store mặc định (đã onboard). Test API thật thêm header này cho mọi request Admin API của trang (trừ `/auth/*`). Đây là giới hạn thật: POS chỉ phục vụ được store mặc định; đã ghi vào README và báo cáo kiến trúc.
- "Migration trên bản sao dữ liệu dev": không chạy lại migration. Đã kiểm chỉ đọc trên DB dev (đã migrate từ phase 1, 2): 8 chi nhánh (7 active), đều `khac`, mỗi chi nhánh đúng 3 dòng module bật (`backfill`), `onboarding.required = false` cho store dev.
- `test:perf` không có kịch bản chuyển context. Đã chạy bản mock và đo phía server bằng đếm query thay cho đo thời gian chuyển context với API thật.

Kiểm thử:
- `pnpm spree rspec spec/requests/spree/pos/ --tag modules_off_rerun`: 48 examples, 0 failures; 392 request chạy với mọi module tắt, 37 lệnh thiết lập chạy với module bật. Trước khi gắn `:module_setup`: 50 examples, 2 failures (đúng hai example ở trên).
- `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/ spec/migrations/`: 286 examples, 0 failures (seed 33001, trước khi thêm example đếm query); chạy lại sau cùng: 287 examples, 0 failures (seed 22018).
- `pnpm spree rspec spec/workflows/spree/pos/`: 154 examples, 0 failures.
- `pnpm spree rspec spec/integration/spree/pos/`: 88 examples, 0 failures.
- `pnpm spree rspec spec/requests/spree/pos/business_profiles_spec.rb` (có example đếm query): 8 examples, 0 failures. `branch_profiles_spec.rb`: 6 examples, 0 failures. Rubocop sạch trên các file spec đã sửa.
- Số query của `GET /pos/context` (có chi nhánh, có store profile): 1 chi nhánh = 33 query; 6 chi nhánh có đủ module và 3 SKU tracked = 38 query.
  - `modules`, `module_usage` và store profile mỗi thứ đúng 1 query ở cả hai trường hợp.
  - 5 query thêm là `spree_stock_locations` của từng chi nhánh trong danh sách (`Branch#to_pos`, có từ commit `5b9369d`, trước plan này; danh sách tối đa 100).
- `POS_LIVE_REVIEW=1 POS_LIVE_ONBOARDING_FIXTURE=… POS_TEST_PORT=5177 pnpm exec playwright test e2e/onboarding.spec.ts -g "real API" --project=desktop`: 2 passed (35,5 s).
- `pnpm exec playwright test e2e/onboarding.spec.ts` (mock): 18 passed, 6 skipped (nhóm `real API`).
- `pnpm --dir apps/pos test`: 39 files, 310 tests pass. `typecheck`: pass. `tsc` riêng cho `e2e/onboarding.spec.ts`, `e2e/support/live.ts` (e2e không nằm trong `tsconfig`): sạch.
- `pnpm --dir apps/pos lint`: fail, 115 lỗi format do CRLF (`core.autocrlf=true`), giống phase 3, 4. `biome lint .` (chỉ rule): sạch. Biome bỏ qua `e2e/`.
- `pnpm exec playwright test` (toàn bộ, working tree có thay đổi dở của người khác): 439 passed, 6 failed, 29 skipped (23 cũ + 6 `real API` mới). Sáu fail đều đã biết từ phase 3: `layout-recovery.spec.ts:4` × 3 ("Mở lại đơn" ra hai lần) và `pages-polish.spec.ts:88` × 3 (CSS trang đăng nhập). Không có fail mới, nên không dựng worktree cô lập.
- `pnpm --dir apps/pos test:perf` (mock, chỉ phía trình duyệt): tab p95 55 ms, tìm hàng p95 17 ms, tạo nháp p95 39 ms, xác nhận tiền mặt p95 146 ms. Bản live bỏ qua.

Còn mở:
- `lint` chỉ xanh khi file trong working tree là LF (hoặc Biome chấp nhận CRLF). Hai fail e2e ở trên thuộc thay đổi đang dở về đăng nhập / tab đơn.
- Chưa có race spec hai phiên onboarding đồng thời (ghi từ phase 2). Đã có khóa dòng store và unique `store_profiles.store_id`.
- Chưa đo thời gian chuyển context với API thật.
- Client chọn store: nếu một máy chủ phục vụ nhiều cửa hàng, POS cần gửi `X-Spree-Store-Id`.
- Trang Cấu hình gọi `GET /branches/:id/modules` cho từng chi nhánh (ghi từ phase 3).
