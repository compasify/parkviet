---
phase: 4
title: "Wizard thiết lập và trang Mô hình kinh doanh"
status: completed
effort: "2,5 ngày"
dependsOn: [2, 3]
---

# Phase 4: Wizard thiết lập và trang Mô hình kinh doanh

## Overview

Phase này gồm hai màn hình:
- **Thiết lập cửa hàng**, hiện khi `context.onboarding.required` và người dùng có quyền thiết lập;
- **Cấu hình → chi nhánh → Mô hình kinh doanh**, để xem và đổi hồ sơ, bật / tắt từng module.

Cần duyệt **giá trị mặc định của 19 hồ sơ** (câu hỏi mở 1 ở `plan.md`) trước khi làm phase này.

## Thiết lập cửa hàng (`/setup`)

Điểm vào:
- `pos-shell.tsx`: khi `onboarding.required && onboarding.can_setup` thì chuyển sang `/setup` thay vì mở `ContextSetupDialog`.
- Không có quyền: giữ màn "Chưa có chi nhánh" hiện tại (`context-selector.tsx:107`), thêm câu "Nhờ quản trị cửa hàng thiết lập POS".

Các bước, mỗi bước một màn, có nút Quay lại, chưa gửi gì lên server cho đến bước 5:

1. **Bạn kinh doanh gì?**
   - Hai nhóm: **Bán buôn, bán lẻ** (13 thẻ) và **Ăn uống, giải trí** (6 thẻ, nhãn "Sắp hỗ trợ").
   - Mỗi thẻ có tên và một dòng mô tả lấy từ locale.
   - Bấm thẻ "Sắp hỗ trợ" thì hiện: "Chúng tôi sẽ báo khi hỗ trợ. Bạn có bán thêm hàng hóa không?" Trả lời có → chọn tiếp một hồ sơ bán lẻ (gợi ý `khac`, hoặc `cang_tin_tram_dung` → `tap_hoa_sieu_thi`). Hồ sơ F&B vào `interests`.
   - Thứ tự thẻ theo `order` của server.
2. **Có bán sỉ không?** Có / Không. Ghi chú: "Bảng giá sỉ sẽ có trong bản cập nhật sau."
3. **Chi nhánh đầu tiên**
   - Tên, mã (tự sinh từ tên, sửa được), múi giờ (mặc định theo store), kho bán (chọn từ `GET /pos/configuration/locations`).
   - Store chưa có kho nào: hiện hướng dẫn tạo kho trong Admin Dashboard, không cho đi tiếp.
   - Tên quầy đầu tiên: tùy chọn, mặc định "Quầy 1".
   - Ô "Cấp cho tôi toàn quyền tại chi nhánh này", tick sẵn.
4. **Xem trước**
   - Các chức năng được bật (module) kèm một câu giải thích mỗi chức năng.
   - Các mặc định của chi nhánh, sửa được tại chỗ.
   - Đơn vị mẫu sẽ thêm.
   - Danh sách "Ngành này thường dùng": các cờ rủi ro, ô chọn **để trống** (D6), mỗi cờ có một câu mô tả rủi ro lấy từ `branch-features.tsx`.
5. **Tạo**
   - `POST /pos/onboarding` với một idempotency key sinh một lần cho cả wizard (giữ trong state, không tạo key mới khi bấm lại).
   - Lỗi mạng hoặc timeout: hiện "Đang kiểm tra kết quả…" và gửi lại **cùng key**, theo đúng mẫu `submission-key.ts`.
   - Thành công: chọn chi nhánh / quầy mới làm context, chuyển về màn bán, mở hộp **Mở ca** như bình thường.

Yêu cầu chung:
- Đủ ba viewport (desktop / tablet / mobile).
- Điều hướng được bằng bàn phím; có `aria` cho nhóm thẻ (radio group).
- Không lưu wizard vào IndexedDB.

## Mô hình kinh doanh (`/settings/branches/$branchId/business-model`)

- Hiện hồ sơ hiện tại của chi nhánh, cùng danh sách module và trạng thái của từng module.
- **Đổi ngành:** chọn hồ sơ khác → gọi `profile/preview` → hiện diff:
  - module bật / tắt, kèm cảnh báo `in_use` nguyên văn ý D5;
  - từng default với ô chọn "Áp giá trị của ngành mới", mặc định **không tick**;
  - đơn vị mẫu sẽ thêm.

  Nhập lý do → `PUT profile` với `expected_profile_key`. Gặp 409 `profile_conflict` thì tải lại diff.
- **Bật / tắt từng module:** công tắc kèm lý do, giống `branch-features.tsx`. Bật module có phụ thuộc thì báo trước những module sẽ bật theo.
- **Hồ sơ chính của store** (chỉ người có `write_pos_topology`): đổi mặc định cho chi nhánh mới, bật/tắt "Có bán sỉ", danh sách ngành "Sắp hỗ trợ" đang quan tâm.
- Khi tạo chi nhánh mới trong `topology.tsx`: thêm ô chọn hồ sơ, mặc định là hồ sơ chính của store; các default sẽ được điền sẵn vào form.

## Files

| Action | Path |
|---|---|
| create | `apps/pos/src/pages/setup.tsx`, `apps/pos/src/components/setup/{profile-picker,setup-branch-step,setup-preview-step}.tsx` |
| create | `apps/pos/src/pages/settings/business-model.tsx`, `apps/pos/src/components/profile-diff.tsx` |
| create | `apps/pos/src/hooks/use-onboarding.ts`, `use-branch-modules.ts` |
| create | `apps/pos/src/lib/setup-wizard.ts`, `setup-wizard.test.ts` (state, sinh mã chi nhánh, payload) |
| modify | `apps/pos/src/router.tsx`, `apps/pos/src/components/pos-shell.tsx`, `context-selector.tsx`, `topology-editor.tsx`, `apps/pos/src/pages/settings/topology.tsx` |
| modify | `apps/pos/src/locales/vi.json`, `en.json`, `apps/pos/src/styles.css` (hoặc `styles/setup.css`) |
| create | `apps/pos/e2e/onboarding.spec.ts`, `apps/pos/e2e/business-model.spec.ts` |

## Success Criteria

- [x] Store mới (mock `onboarding.required`) với tài khoản quản trị → vào `/setup`. Chọn "Nhà thuốc", đi hết 5 bước → có chi nhánh, quầy, context đã chọn, màn bán mở hộp Mở ca.
- [x] Mất mạng ở bước 5 rồi bấm lại → gửi cùng key, không tạo chi nhánh thứ hai (e2e mock trả timeout lần đầu).
- [x] Chọn "Cafe, Trà sữa" → không tạo được chi nhánh F&B. Chọn tiếp hồ sơ bán lẻ thì `interests` có `cafe_tra_sua`.
- [x] Không có cờ rủi ro nào được bật nếu người dùng không tick.
- [x] Tài khoản không có quyền thiết lập → thấy câu nhắc, không thấy wizard.
- [x] Đổi hồ sơ một chi nhánh từ `khac` sang `thoi_trang`: diff báo tắt ba module, kèm cảnh báo SKU đang dùng. Không tick default nào → cấu hình chi nhánh không đổi. Lối vào cấu hình của ba module biến mất; màn bán không đổi (màn bán: xem "Khác với plan").
- [x] Axe không có lỗi nghiêm trọng ở `/setup` và trang Mô hình kinh doanh (theo `accessibility.spec.ts`; app không cài thư viện axe, xem "Khác với plan").

## Kết quả (09/11/2026)

Đã làm (chỉ client, không sửa server):
- `src/lib/setup-wizard.ts`: state, reducer và payload của wizard, không chạm React.
  - `initialSetup(timezone)`: múi giờ mặc định theo store (thiếu thì `Asia/Ho_Chi_Minh`), quầy "Quầy 1", ô cấp quyền tick sẵn, không cờ nào được tick.
  - `setupReducer`. Chọn thẻ bán lẻ thì lấy luôn mặc định của hồ sơ (`defaultsFromProfile`) và bỏ các cờ đã tick mà hồ sơ mới không gợi ý. Chọn thẻ "Sắp hỗ trợ" thì chưa đổi hồ sơ; trả lời "Có" thì ghi `interests` và chuyển sang hồ sơ gợi ý (`suggestedRetailProfile`: `cang_tin_tram_dung` → `tap_hoa_sieu_thi`, còn lại → `khac`); "Không" thì vẫn ghi `interests` (chỉ gửi khi tạo cửa hàng) và chặn bước 1 cho tới khi chọn thẻ bán lẻ.
  - `branchCodeFrom(name)`: bỏ dấu tiếng Việt (đ → d), ký tự khác thành `-`, tối đa 32 ký tự, không kết thúc bằng `-`. Ra đúng dạng `POST /branches` nhận. Mã đi theo tên cho tới khi người dùng tự sửa; xóa trống mã thì lại đi theo tên.
  - `stepProblems`: lý do chưa đi tiếp được của từng bước, trong đó có `no-locations`.
  - `editableDefaults`: hạn trả luôn có; chọn lô khi hồ sơ có `retail.traceability`; hai ngưỡng khi hồ sơ có đặt.
  - `onboardingPayload`: gửi mọi default đã hiện ở bước 4 đúng như người dùng sửa (field đã gửi, kể cả `null`, thắng default hồ sơ); tên quầy trống thì không gửi `register`; `features` chỉ gồm cờ đã tick **và** có trong `recommended_features`.
  - `onboardingSelection`: đọc chi nhánh và quầy mới từ kết quả 201.
- `src/lib/pos-modules.ts`: `modulesEnabledWith` (các module sẽ bật kèm, theo `depends_on` đệ quy) và `modulesRequiring` (module đang bật cần module này).
- `src/hooks/use-onboarding.ts`:
  - `useOnboarding()`: `POST /pos/onboarding` với header `Idempotency-Key` theo `createSubmissionKey` (`submission-key.ts`). Key gắn với nội dung gửi: gửi lại cùng câu trả lời thì dùng cùng key. 4xx là từ chối dứt khoát. Lỗi mạng, timeout hoặc 5xx là "chưa rõ": giữ nguyên nội dung, `recheck()` gửi lại đúng body và key.
  - `useStoreProfile` / `saveStoreProfile` cho `GET`/`PUT /pos/store_profile`.
  - `refreshBusinessModel()` invalidate `['pos','context']`, `context-branches`, `context-registers`, `['pos','branch-modules']`, `branch-features`, `['pos','topology']`, `store-profile`.
- `src/hooks/use-branch-modules.ts`:
  - `useBranchModuleDetail(branchId)` (`GET /branches/:id/modules`, luôn hỏi server, cả với chi nhánh đang chọn, để có người đổi / lý do).
  - `setBranchModule`, `previewBranchProfile` (+ `normalizePreview`), `applyBranchProfile`.
- `/setup` (`src/pages/setup.tsx`, `components/setup/{profile-picker,setup-branch-step,setup-preview-step}.tsx`, `styles/setup.css`):
  - `pos-shell.tsx` chuyển sang `/setup` khi `onboarding.required && can_setup`, từ mọi trang; trong lúc đó không mở `ContextSetupDialog`. `/setup` không tính là màn bán.
  - Bước 1: một `radiogroup` (tên lấy theo tiêu đề bước) gồm hai `fieldset` "Bán buôn, bán lẻ" / "Ăn uống, giải trí". Thẻ là `input type=radio` thật (mũi tên chọn thẻ), sắp theo `order` của server. Tên radio chỉ là tên ngành; mô tả và nhãn "Sắp hỗ trợ" nằm trong `aria-describedby`. Câu hỏi "Bạn có bán thêm hàng hóa không?" là một `fieldset`.
  - Bước 2: Có / Không bán sỉ (mặc định "Không bán sỉ"), kèm ghi chú bảng giá sỉ.
  - Bước 3: tên, mã, múi giờ, kho (chỉ kho `active` từ `GET /pos/configuration/locations`; một kho thì tự chọn). Không có kho thì hiện hướng dẫn tạo kho trong Admin Dashboard, nút "Tải lại danh sách kho", và chặn bước. Có tên quầy (mặc định "Quầy 1", để trống là không tạo quầy) và ô "Cấp cho tôi toàn quyền tại chi nhánh này" tick sẵn.
  - Bước 4: module kèm một câu giải thích (`posModules.*.description`), default sửa tại chỗ, kiểu danh mục, đơn vị mẫu (`setup.unit.<code>`), và nhóm "Ngành này thường dùng". Mỗi cờ trong nhóm có ô chọn **để trống**, kèm câu rủi ro lấy từ `featureHint_<cờ>`: cùng câu mà `branch-features.tsx` hiện.
  - Bước 5: tóm tắt rồi "Tạo cửa hàng".
  - Lỗi "chưa rõ" hiện "Đang kiểm tra kết quả…" cùng nút "Kiểm tra lại"; trong lúc đó khóa "Quay lại" và "Tạo cửa hàng". Thành công thì `setSelection` sang chi nhánh / quầy mới, `refreshBusinessModel()`, về `/`; hộp Mở ca hiện như thường. 409 `already_onboarded` có câu riêng và tải lại context.
  - Mỗi lần đổi bước, focus về tiêu đề bước. Form `noValidate`: các thiếu sót hiện trong một `role=alert` và tự biến mất khi đã sửa. Không lưu gì vào trình duyệt.
- Không có quyền: ô "Chưa có chi nhánh." của `context-selector.tsx` thêm "Nhờ quản trị cửa hàng thiết lập POS." khi `onboarding.required && !can_setup`. Mở thẳng `/setup` chỉ thấy câu đó, không có wizard.
- `/settings/branches/$branchId/business-model` (`pages/settings/business-model.tsx`, `components/profile-diff.tsx`):
  - Hồ sơ hiện tại.
  - Đổi ngành (chỉ `write_pos_topology`): chọn hồ sơ `available` → `profile/preview` → diff:
    - module sẽ bật / tắt, với số đang dùng (`in_use`) đọc thành câu;
    - ghi chú D5: "Việc bán SKU đã cấu hình không đổi; chỉ ẩn màn cấu hình.";
    - ô "Bật / tắt chức năng theo ngành mới" (`apply_modules`);
    - mỗi default một ô "Áp giá trị của ngành mới", **không tick**;
    - đơn vị mẫu sẽ thêm, và cờ ngành thường dùng (chỉ nhắc, có link sang Chức năng chi nhánh).

    Có lý do bắt buộc rồi mới gửi `PUT profile`, với `expected_profile_key` = `from` của preview. Gặp 409 `profile_conflict` thì báo, tải lại context và gọi preview lại; lý do được giữ, các ô default trở về không tick.
  - Chức năng của chi nhánh, theo kiểu `branch-features.tsx`: trạng thái, lần đổi cuối, nút "Bật/Tắt <tên>" với form lý do. Trước khi bật thì báo những module sẽ bật kèm; khi đã bật thì báo "kèm …" theo `also_enabled`. Nút tắt bị khóa, kèm câu giải thích, khi module khác đang bật cần nó; 409 `module_required_by` vẫn có câu riêng.
  - Hồ sơ chính của store (chỉ `write_pos_topology`): ngành mặc định (chỉ hồ sơ `available`), "Có bán sỉ", các ngành "Sắp hỗ trợ" đang quan tâm, lý do bắt buộc.
  - Sau mỗi thay đổi gọi `refreshBusinessModel()`, nên context và dữ liệu module theo chi nhánh cùng được làm mới.
  - Quản lý chi nhánh (`pos.topology.manage` tại chi nhánh đang chọn, không có quyền đọc quản trị) mở được trang cho chi nhánh của mình, chỉ thấy phần module.
- Lối vào: link "Mô hình kinh doanh" ở mỗi dòng chi nhánh (`topology.tsx`, aria-label "Mô hình kinh doanh của chi nhánh <tên>") và ở thanh mục chi nhánh (`branch-settings.tsx`, section `model`).
- Tạo chi nhánh (`topology-editor.tsx`): ô "Ngành của chi nhánh" chỉ có khi tạo mới, đã có catalogue và người dùng có quyền ghi. Mặc định là hồ sơ chính của store (chưa đọc được thì `khac`); khi form chưa bị sửa, ô này đi theo dữ liệu tải về sau. Đổi ngành sẽ điền lại hạn trả, chọn lô và hai ngưỡng theo hồ sơ (trống nếu hồ sơ không đặt). `profile_key` chỉ gửi khi tạo.
- `PosBranch` thêm `profile_key?`, `profile_version?`, `variance_threshold?`.
- Locale: thêm hai object `setup.*` (83 key, có `setup.unit.<mã>` cho đơn vị mặc định và đơn vị mẫu) và `businessModel.*` (vi 67 key; en tách `_one`/`_other` cho câu đếm). Cả hai nằm ngay sau `profiles`.

Khác với plan:
- Idempotency: một key cho một **nội dung** gửi (đúng mẫu `submission-key.ts`), không phải một key cố định cho cả wizard. Khi kết quả chưa rõ, nội dung bị khóa (không quay lại được), nên mọi lần gửi lại đều cùng key. Chỉ sau một từ chối dứt khoát (4xx, lệnh đã rollback) người dùng mới sửa được câu trả lời và nhận key mới. Nhờ vậy không gặp 409 "key dùng lại với payload khác". Nếu lần đầu thật ra đã ghi mà lần sau gửi nội dung khác, server trả `already_onboarded`, wizard báo và tải lại context, không tạo chi nhánh thứ hai.
- Thử lại: SDK (`@spree/admin-sdk`) tự thử lại lỗi mạng hai lần với cùng `Idempotency-Key` (`retryOnNetworkError`, `maxRetries: 2`). Khi cả ba lần đều mất, wizard hiện "Đang kiểm tra kết quả…" và để người dùng bấm "Kiểm tra lại". Không tự gửi lại theo hẹn giờ, giống `CommandCheck` của trang tồn kho.
- Cờ đã tick ở wizard được server bật làm **mặc định cấp cửa hàng** (`Onboarding::Setup` gọi `FeaturePolicy.set!` không kèm chi nhánh). Câu trong wizard nói rõ "bật ngay cho cả cửa hàng".
- `apply_modules` là ô chọn **tick sẵn**, chỉ hiện khi diff có module đổi. Plan chỉ bắt các default để trống (D7); module không phải cờ rủi ro (D5), và tiêu chí `khac` → `thoi_trang` cần lối vào biến mất khi không tick gì.
- Axe: app không cài axe-core (`accessibility.spec.ts` cũng ghi vậy), nên dùng cùng các kiểm tra có mục tiêu của spec đó: mọi control đang hiện đều có tên, không cuộn ngang. Chạy ở cả năm bước của wizard và trang Mô hình kinh doanh (có diff mở), trên ba viewport, kèm một test chỉ dùng bàn phím.
- "Màn bán không đổi" sau khi đổi ngành: `business-model.spec.ts` dùng tài khoản quản trị không có chi nhánh bán, nên không lặp lại phần bán. Việc bán SKU tracked khi module tắt đã có ở `branch-modules.spec.ts` (phase 3); phase này không đụng màn bán.
- File không có trong bảng: `e2e/support/business-profiles.ts` (catalogue 19 hồ sơ theo bảng phase 1, dùng chung cho hai spec mới). Không sửa `styles.css`: style mới nằm trong `styles/setup.css`, do `setup.tsx` và `business-model.tsx` import.

Kiểm thử (thư mục `apps/pos`):
- `pnpm test`: 39 files, 310 tests pass. `setup-wizard.test.ts` có 26 test: state, mã chi nhánh, payload, phụ thuộc module, và key locale vi/en khớp nhau.
- `pnpm typecheck`: pass trên working tree.
- `pnpm lint` (`biome check .`): fail, 115 lỗi `format`, tất cả ở file có CRLF trong working tree (`core.autocrlf=true`), giống phase 3. `pnpm exec biome lint .` (chỉ rule): sạch. Mọi file của phase này qua `biome check`; `src/router.tsx` (working copy CRLF) qua `biome check` khi đổi sang LF.
- `POS_TEST_PORT=5181 pnpm exec playwright test e2e/onboarding.spec.ts e2e/business-model.spec.ts`: 33 passed (11 test × desktop/tablet/mobile). Thêm `--project=tablet --repeat-each=2`: 22 passed.
  - `onboarding.spec.ts`: Nhà thuốc đi hết 5 bước → body đúng, `features: []`, context mới, hộp Mở ca; mất cả ba câu trả lời → "Đang kiểm tra kết quả…", "Kiểm tra lại" → 4 POST cùng một key và cùng body, 1 chi nhánh; Cafe → "Không" bị chặn, Căng tin → "Có" → `tap_hoa_sieu_thi`, `interests: ['cafe_tra_sua','cang_tin_tram_dung']`, chỉ gửi `credit` vì đã tick; không có kho; không có quyền; bàn phím.
  - `business-model.spec.ts`: `khac` → `thoi_trang`; 409 `profile_conflict` tải lại diff; bật/tắt module có phụ thuộc; hồ sơ chính của store và form tạo chi nhánh; quản lý chi nhánh.
- Các spec gần phần đã sửa (`context`, `context-defaults`, `keyboard-context`, `administration`, `feature-flags`, `feature-recovery`, `branch-modules`, `branch-assortment`, `accessibility`, `user-menu`, `scale-labels`, `auth`): 130 passed, 8 skipped (accessibility chỉ chạy desktop).
- `pnpm exec playwright test` (toàn bộ) trên working tree, gồm cả thay đổi đang dở của người khác: 436 passed, 9 failed, 23 skipped (`real API`).
  - Fail đã biết: `layout-recovery:4` ×3, `pages-polish:88` ×3, `full-retail:177` (tablet).
  - Thêm `branch-assortment:138` (desktop, phân trang chưa đổi kịp) và `split-tender:405` (mobile); chạy lại riêng `--repeat-each=3` trên ba viewport: 18 passed.
- Cô lập: git worktree tạm ở HEAD `22021d4`, chỉ áp patch đã stage của phase 4, `node_modules` qua junction. Đã gỡ junction rồi xóa worktree.
  - `vitest`: 39 files, 309 tests pass.
  - `tsc`: chỉ còn `TS2352` ở `src/lib/traceability.test.ts:27`, lỗi có từ trước (đã ghi ở phase 3).
  - `playwright test` toàn bộ: 444 passed, 1 failed (`feature-recovery:215` mobile: strict mode, chữ "Đã khai báo tồn đầu kỳ" khớp hai đoạn ở trang tồn kho; phase này không sửa trang đó), 23 skipped. Chạy lại `feature-recovery.spec.ts --repeat-each=3`: 27 passed.

Cho phase 5:
- Chưa chạy với API thật. Cần thử trên một store **chưa** thiết lập (không store profile, không chi nhánh active; DB dev hiện đã thiết lập):
  - `POST /onboarding` với `Idempotency-Key`; replay sau khi mất câu trả lời;
  - 409 `already_onboarded` từ máy thứ hai;
  - `GET /pos/configuration/locations` với tài khoản chỉ có `write_pos_topology`;
  - context của chi nhánh mới khi bỏ tick "Cấp cho tôi toàn quyền": tài khoản không có membership tại đó, `pos-selection` sẽ quay lại lựa chọn cũ nếu server trả 403;
  - các cờ đã tick thành mặc định cấp cửa hàng.
- `PUT /store_profile` với `interests: []` (bỏ hết ngành quan tâm): kiểm tra Rails nhận mảng rỗng chứ không phải `nil` (deep munge). Phía server, `Array(nil)` cũng là `[]`.
- Quản lý chi nhánh không có quyền đọc quản trị: trang Mô hình kinh doanh lấy chi nhánh từ `context.branches`, `profile_key` lấy từ đó (hoặc `context.profile`).
- README / tài liệu người dùng cho Thiết lập cửa hàng và Mô hình kinh doanh chưa viết (phase 5).
- Ghi nhận khi dò lỗi: sau một cú click, popover chọn chi nhánh ở header (đang đóng) vẫn có hộp layout rộng 650px. Ở trang này đó không phải nguyên nhân cuộn ngang (lỗi thật là radio nhận style `input` toàn cục, đã sửa trong `setup.css`), nên không sửa `styles.css`.

Locale (stage từng hunk):
- `vi.json` và `en.json` có thay đổi đang dở của người khác (4 hunk mỗi file). Chỉ stage một hunk của phase 4 (thêm `setup` + `businessModel` sau `profiles`).
- Cách làm: lấy hunk đó từ `git diff -U0`, sửa header thành `-N,0 +N+1,M` (vì các hunk trước không được áp), rồi `git apply --cached --unidiff-zero` từ file patch ngoài repo.
- Lần đầu chưa sửa header thì git đặt khối lệch 10 dòng; đã `git reset` riêng hai file đó rồi làm lại.
- Đã kiểm tra:
  - index có khối nằm giữa `profiles` và `featureName_credit`;
  - `git show :apps/pos/src/locales/{vi,en}.json` parse được JSON;
  - không có key của người khác (`loginShowcase`, `workspacePhase_*`) trong index;
  - `git diff -U0` (phần chưa stage) còn đúng 4 hunk của người khác: 477, 1000/1001, 1019/1020 và hunk cuối file.
