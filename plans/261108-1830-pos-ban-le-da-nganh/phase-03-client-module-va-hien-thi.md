---
phase: 3
title: "Client: context, ẩn hiện theo module, mặc định hiển thị"
status: completed
effort: "2 ngày"
dependsOn: [2]
---

# Phase 3: Client — context, ẩn hiện theo module, mặc định hiển thị

## Overview

POS client đọc `modules`, `profile`, `onboarding` từ context. Các lối vào cấu hình của module bị tắt sẽ ẩn đi; trang danh mục dùng view mặc định của hồ sơ. Phase này cũng đặt nền `src/modules/` để các module bán lẻ sau này cắm vào. Phase này không làm wizard; wizard ở phase 4.

## Kiểu dữ liệu và hook

- `apps/pos/src/lib/pos-modules.ts`, theo mẫu `pos-features.ts`:
  - `normalizeModules(value)` chỉ giữ các key là chuỗi và giá trị đúng `true`. Không biết key nào thì giữ nguyên key đó; không lọc theo danh sách cứng (D3).
  - `moduleEnabled(modules, key)`. Server cũ không gửi `modules` (`undefined`) → coi như **bật**, để không ẩn gì, giống `featureEnabled`. Server đã gửi object → chỉ `true` mới tính là bật (fail closed).
- `apps/pos/src/hooks/use-business-profiles.ts` gọi `GET /pos/business_profiles`, có cache dài, query key theo store.
- Mở rộng type context ở `pos-context.ts` / `use-pos-context.ts`: thêm `modules`, `profile`, `onboarding`. Thêm vào `pos-contract.test.ts`.
- Lỗi `409 module_disabled` hiện thông báo riêng ("Chi nhánh chưa bật chức năng …"), dùng chung cơ chế với `feature-off-note.tsx`.

## Registry client (nền cho các module sau)

`apps/pos/src/modules/registry.ts`:

```ts
export type PosModuleUi = {
  key: string;                              // trùng key server
  nav?: NavEntry[];                         // mục trong user menu
  branchSettings?: BranchSettingsEntry[];   // mục trong Cấu hình → chi nhánh
  skuEditor?: 'units' | 'measured' | 'traceability'; // vùng trên variant-unit-editor
};
export const moduleUis: PosModuleUi[] = [unitsUi, measuredUi, traceabilityUi];
```

- Ba module bán lẻ hiện có chỉ khai báo những lối vào **đã có** sẵn; không di chuyển trang. Code trang vẫn ở `pages/`, `components/`.
- `visibleNav(context)`, `visibleBranchSettings(context)` lọc theo `moduleEnabled` **và** theo quyền / cờ như hiện tại.

## Ẩn hiện theo module

| Module tắt ở chi nhánh | Ẩn | Vẫn giữ |
|---|---|---|
| `retail.traceability` | Mục menu **Truy xuất tồn kho**; tab Nhập hàng / Tồn đầu kỳ; lựa chọn "Theo dõi serial/lô" trong `variant-unit-editor`; trường **Chọn lô khi bán** trong cấu hình chi nhánh | Ô nhập serial / chọn lô trên màn bán cho SKU đã tracked; xem lô / serial đã bán (`sold-trace.tsx`); trả hàng |
| `retail.measured` | **Mẫu tem cân** (`label-formats.tsx`), trường mã tem trong editor SKU | Quét tem cân, dòng hàng cân trên đơn và trên phiếu |
| `retail.units` | Vùng đơn vị bán / tỷ lệ quy đổi trong editor SKU | Chọn đơn vị trên dòng đơn của SKU đã có quy đổi |

Quy tắc: **không ẩn bất cứ thứ gì trên màn bán, trên phiếu, hay ở luồng trả hàng.** Nếu lối vào trong menu bị ẩn nhưng người dùng mở thẳng URL, trang vẫn mở và hiện ghi chú "Chi nhánh chưa bật …"; server là bên chặn ghi.

## Mặc định hiển thị

- `catalog-search.tsx`: `useState<'cards' | 'list'>('cards')` đổi thành giá trị khởi tạo `context.profile.display.catalog_view ?? 'cards'`. Người dùng đổi view thì vẫn giữ trong phiên như hiện tại.
- Tab đơn vẫn là "Hóa đơn N" cho mọi hồ sơ bán lẻ; chưa làm thuật ngữ theo hồ sơ (để cho F&B).

## Files

| Action | Path |
|---|---|
| create | `apps/pos/src/lib/pos-modules.ts`, `pos-modules.test.ts` |
| create | `apps/pos/src/modules/registry.ts`, `registry.test.ts` |
| create | `apps/pos/src/hooks/use-business-profiles.ts` |
| modify | `apps/pos/src/lib/pos-context.ts`, `apps/pos/src/hooks/use-pos-context.ts`, `apps/pos/src/lib/pos-contract.test.ts`, `apps/pos/src/lib/request-failure.ts` |
| modify | `apps/pos/src/components/user-menu.tsx`, `pos-shell.tsx`, `variant-unit-editor.tsx`, `catalog-search.tsx`, `feature-off-note.tsx` |
| modify | `apps/pos/src/pages/settings/topology.tsx`, `branch-settings.tsx`, `label-formats.tsx`, `inventory-traceability.tsx` |
| modify | `apps/pos/src/locales/vi.json`, `en.json` (nhãn module, 19 hồ sơ: `label`, `description`) |
| modify | `apps/pos/e2e/support/*` (mock context có `modules`, `profile`) |

## Success Criteria

- [x] Context không có `modules` (server cũ / mock cũ) → UI y như hiện tại. Toàn bộ e2e hiện có pass mà không phải sửa expectation.
- [x] Chi nhánh tắt `retail.traceability`: không thấy menu Truy xuất tồn kho, không thấy tùy chọn tracked trong editor SKU. Vẫn bán được SKU tracked bằng serial (e2e mới `branch-modules.spec.ts`).
- [x] Chi nhánh hồ sơ `nha_thuoc` mở danh mục ở dạng **Danh sách**; `thoi_trang` ở dạng **Thẻ**.
- [x] `409 module_disabled` hiện thông báo dịch được, không phải lỗi chung chung.
- [ ] `pnpm --dir apps/pos lint`, `typecheck`, `test`, `test:e2e` pass. `test` và `test:e2e` pass; `typecheck` và `lint` còn lỗi không do phase này (xem "Kiểm thử").

## Kết quả (09/11/2026)

Đã làm:
- `src/lib/pos-modules.ts` (theo mẫu `pos-features.ts`):
  - `normalizeModules(value)` giữ mọi key chuỗi khác rỗng có giá trị đúng `true`, kể cả key client chưa biết; không phải object thì trả `null`.
  - `moduleEnabled(modules, key)` / `contextModule(context, key)`: `null`/`undefined` (server cũ) → bật; đã có object → chỉ `true` mới bật (fail closed).
  - `normalizeModuleUsage`, `moduleInUse(context, key)` cho `module_usage`; thiếu hoặc sai dạng → không dùng.
  - `normalizeProfile`, `normalizeOnboarding`, `catalogViewOf(context)` (`profile.display.catalog_view ?? 'cards'`, giá trị lạ → `cards`).
  - `normalizeBusinessProfiles(value)` đọc `GET /business_profiles` (bỏ dòng không có key, sắp theo `order` rồi key), `profileLabelKey` / `profileDescriptionKey`.
  - `LABELLED_MODULES` chỉ để chọn câu dịch; bật/tắt luôn đọc từ server.
- `src/modules/registry.ts`: `PosModuleUi { key, nav?, branchSettings?, skuEditor? }`, `moduleUis = [unitsUi, measuredUi, traceabilityUi]`. Chỉ khai báo lối vào đã có, không dời trang:
  - `retail.units` → vùng `units` của editor SKU.
  - `retail.measured` → trang `label-formats`, vùng `measured` (mã tem).
  - `retail.traceability` → mục menu `inventory` (`keepWhileInUse`), trường `lot-selection` của chi nhánh, vùng `traceability`.
  - `visibleNav(scope)`, `navVisible(scope, id)`, `visibleBranchSettings(scope)`, `branchSettingVisible(scope, id)`, `branchSettingModule(id)`, `skuEditorAreas(modules)`. Lọc theo `moduleEnabled` **và** quyền như cũ (`canOpenInventory`, `administration.read`). `scope` có dạng context, nên truyền thẳng `context.data` được, hoặc `{ ...context.data, modules }` cho một chi nhánh khác.
- Hook:
  - `src/hooks/use-business-profiles.ts`: `useBusinessProfiles(storeId, enabled)`, key `['pos', 'business-profiles', generation, storeId]` (`businessProfilesKey`), `staleTime` / `gcTime` 1 giờ.
  - `src/hooks/use-branch-modules.ts` (không có trong plan): `useBranchModules(branchId)`. Chi nhánh đang chọn đọc `context.modules`; chi nhánh khác (trang cấu hình theo URL) gọi `GET /branches/:id/modules`, key `['pos', 'branch-modules', generation, branchId]`, `retry: false`. Đang tải, bị từ chối, hay server cũ → `null` → không ẩn gì.
- Context: `PosContext` thêm `modules`, `module_usage`, `profile`, `onboarding`; `normalizeContext()` ở `pos-context.ts` gom mọi bước đọc, `use-pos-context.ts` dùng nó.
- `409 module_disabled`: `moduleDisabledText(error, t)` ở `request-failure.ts`, gọi trong `describeFailure` ngay sau `featureDisabledText`. Vì vậy `describeTraceFailure`, `describeInventoryFailure`, editor SKU và editor mẫu tem đều hiện câu riêng: `posModules.<key>.disabled` với module đã biết, `moduleDisabled` với module lạ hoặc thiếu `details.module`. `FeatureOffNote` nhận thêm `module="<key>"` (câu `posModules.<key>.off`, dự phòng `moduleOff`, thuộc tính `data-module`).
- Ẩn hiện:
  - Menu **Truy xuất tồn kho** ẩn khi tắt `retail.traceability`, **trừ khi** `module_usage['retail.traceability']` là `true` (quyết định 4).
  - Trang `/inventory` luôn mở được. Tắt module → ghi chú module; ẩn nút **Khai báo tồn đầu kỳ** (`enroll` cần cả cờ `traceability` lẫn module); tab **Nhập hàng** chỉ ẩn khi vừa tắt module vừa không còn SKU tracked. Các tab khác giữ nguyên.
  - Editor SKU (`variant-unit-editor.tsx`): vùng đơn vị bán / tỷ lệ (`units`), ô **Theo dõi hàng** (`traceability`), ô **Mã hàng trên tem cân** (`measured`) ẩn theo module của chi nhánh, mỗi vùng ẩn có một ghi chú. Vùng SKU **đang dùng** thì vẫn hiện để đọc và thu hẹp: đã quy đổi; đang tracked (chỉ còn lựa chọn `none` và mode hiện tại); đã có mã tem.
  - **Mẫu tem cân**: ẩn link ở danh sách chi nhánh (`topology.tsx`) và ở thanh mục của chi nhánh (`branch-settings.tsx`; vẫn hiện khi đang đứng ở trang đó). Mở thẳng URL vẫn được: trang liệt kê mẫu, hiện ghi chú, ẩn **Thêm mẫu tem** / **Chỉnh sửa**, giữ **Ngừng**.
  - Trường **Chọn lô khi bán** trong editor chi nhánh (`topology-editor.tsx`, prop `hideLotSelection`) ẩn với chi nhánh đã có mà tắt traceability. Giá trị cũ vẫn được gửi lại nguyên vẹn. Chi nhánh mới vẫn thấy trường này.
  - Không đụng màn bán, phiếu, trả hàng, `sold-trace.tsx`.
- `catalog-search.tsx`: view ban đầu là `catalogViewOf(context.data)`, đọc qua `usePosSelection()` sẵn có. Người dùng bấm đổi thì giữ lựa chọn đó trong phiên (`chosenView`).
- Locale `vi.json` / `en.json`: `moduleOff`, `moduleDisabled`; `posModules.{retail_units, retail_measured, retail_traceability}.{label, description, off, disabled}`; `profiles.<key>.{label, description}` cho đủ 19 hồ sơ. Key module dùng `_` thay `.` vì i18next đọc dấu chấm là lồng cấp.
- e2e: `World` trong `e2e/support/retail-api.ts` có thêm `modules`, `moduleUsage`, `profile` (tùy chọn; thiếu thì context không có field đó, như server cũ). Spec mới `e2e/branch-modules.spec.ts` có 7 test:
  - traceability tắt: menu ẩn; bán SKU serial; mở `/inventory` bằng URL thấy ghi chú, không có tồn đầu kỳ, không có tab Nhập hàng;
  - traceability tắt nhưng store còn SKU tracked: menu và tab Nhập hàng còn, tồn đầu kỳ ẩn;
  - context không có `modules`: không ẩn gì;
  - `nha_thuoc` → Danh sách, `thoi_trang` → Thẻ, và lựa chọn của thu ngân được giữ;
  - cấu hình chi nhánh với measured và traceability tắt: link mẫu tem, trường chọn lô (PATCH gửi lại `lot_selection` cũ), ô tracked và mã tem trong editor SKU, 409 `module_disabled` ra câu tiếng Việt, trang mẫu tem mở bằng URL;
  - đối chứng: mọi module bật thì cấu hình như cũ.

Khác với plan:
- Theo quyết định 4 của `plan.md`: tắt traceability **không** ẩn tab Nhập hàng nếu store còn SKU tracked (`module_usage`). Tồn đầu kỳ thì luôn ẩn. Menu chỉ ẩn khi không còn SKU tracked.
- `pos-shell.tsx` không sửa: không có lối vào nào của module nằm ở đó (menu ở `user-menu.tsx`).
- Thêm `use-branch-modules.ts` và sửa `topology-editor.tsx` (không có trong bảng file). Trang cấu hình hiện chi nhánh theo URL, không phải chi nhánh trong context.
- `topology.tsx` gọi `GET /branches/:id/modules` cho **mỗi** chi nhánh trong danh sách (React Query gộp theo key, cache 30 s). Store có rất nhiều chi nhánh sẽ có nhiều request khi mở Cấu hình; nếu thành vấn đề thì phase 4 nên cho `GET /branches` trả kèm `modules`.
- Editor SKU vẫn hiện vùng mà SKU đang dùng dù module tắt, để còn đọc và thu hẹp được; server chỉ chặn thiết lập mới (D5).
- `useBusinessProfiles` chưa có chỗ nào dùng trong phase này; phase 4 dùng.

Kiểm thử:
- `pnpm --dir apps/pos test`: 38 files, 284 tests pass (gồm `pos-modules.test.ts`, `registry.test.ts`, phần mới của `pos-contract.test.ts`).
- `pnpm --dir apps/pos typecheck`: pass trên working tree. Trên HEAD sạch (không có thay đổi đang dở của người khác) lỗi sẵn `TS2352` ở `src/lib/traceability.test.ts:27` (`vi as Record<string, string>` với `receiptTemplates` lồng cấp). Lỗi có từ trước phase này: HEAD `3cdcd65` chưa có patch phase 3 vẫn lỗi. Thay đổi chưa commit của người khác trong file đó (`as unknown as`) sửa lỗi này; phase 3 không stage file đó.
- `pnpm --dir apps/pos lint`: fail, 115 lỗi formatter, đều ở file phase 3 không sửa. Repo có `core.autocrlf=true` nên file checkout ra dạng CRLF, còn Biome đòi LF. Trên một bản chép đã đổi CRLF → LF chỉ còn 1 lỗi format ở `src/components/workspace-tabs.tsx` (thay đổi đang dở của người khác). `pnpm exec biome lint .` (chỉ rule) sạch. Mọi file phase 3 qua `biome check` trên working tree.
- `pnpm exec playwright test e2e/branch-modules.spec.ts` (= `test:e2e` cho một file, `POS_TEST_PORT=5181`): 21 passed (7 test × desktop/tablet/mobile).
- `pnpm exec playwright test` (toàn bộ `test:e2e`) trên working tree, gồm cả thay đổi đang dở của người khác: 403 passed, 9 failed, 23 skipped (nhóm `real API`). Chạy lại riêng các spec fail: 46 passed, 8 failed, 3 skipped. Fail ổn định: `layout-recovery.spec.ts:4` (3 viewport, nút "Mở lại đơn" ra hai lần) và `pages-polish.spec.ts:88` (3 viewport, trang login không còn `.header`). Fail lúc có lúc không: `pages-polish.spec.ts:124` (tablet), `full-retail.spec.ts:177` (desktop), `shift-reconciliation.spec.ts:542`, `ui-polish.spec.ts:5`.
- Cô lập: một git worktree tạm ở HEAD `3cdcd65`, chỉ áp patch đã stage của phase 3 (đã xóa sau khi chạy):
  - các spec fail ở trên + `branch-modules`: 75 passed, 0 failed;
  - `test:e2e` toàn bộ lần 1: 410 passed, 2 failed (`full-retail.spec.ts:177` desktop: timeout; `split-tender.spec.ts:455` mobile: assertion), 23 skipped. Hai test này chạy `--repeat-each=3` đều 3/3 pass trên HEAD sạch và trên HEAD + phase 3;
  - `test:e2e` toàn bộ lần 2: **412 passed, 0 failed**, 23 skipped.
  - Kết luận: fail trên working tree đến từ thay đổi đang dở (login, workspace tabs), không đến từ phase 3. Không sửa expectation của spec cũ nào.

Cho phase 4:
- Đọc hồ sơ: `useBusinessProfiles(context.data?.store.id ?? null)` → `{ version, modules, profiles }`; mỗi `profile` có `key, group, order, status ('available' | 'coming_soon'), modules, branch_defaults, display, recommended_features, sample_units`. Nhãn: `t(profileLabelKey(key))`, `t(profileDescriptionKey(key))`; nhãn module: `t(moduleLabelKey(key) ?? key)`; ghi chú module tắt: `<FeatureOffNote module={key} />`.
- Module: `contextModule(context.data, key)` cho chi nhánh đang chọn; `useBranchModules(branchId)` + `moduleEnabled(modules, key)` cho chi nhánh bất kỳ; `moduleInUse(context.data, 'retail.traceability')`; lối vào theo registry: `navVisible`, `branchSettingVisible`, `skuEditorAreas`.
- Onboarding: `context.data?.onboarding` (`{ required, can_setup }`, `null` trên server cũ); hồ sơ chi nhánh: `context.data?.profile`.
- Sau khi bật/tắt module, đổi hồ sơ hay onboarding, invalidate `['pos', 'context']` **và** `['pos', 'branch-modules']`. Lỗi 409 của các lệnh đó dùng `describeFailure`; `module_disabled` đã có câu riêng, các reason khác (`module_required_by`, `profile_conflict`, …) phase 4 tự thêm câu.
- Locale có sẵn: `moduleOff`, `moduleDisabled`, `posModules.<retail_units|retail_measured|retail_traceability>.<label|description|off|disabled>`, `profiles.<19 key>.<label|description>`.

Còn mở:
- `lint` / `typecheck` của app chỉ xanh khi thay đổi đang dở ở `workspace-tabs.tsx` và `traceability.test.ts` được format / commit, và khi file trong working tree là LF (hoặc Biome được cấu hình chấp nhận CRLF).
- Chưa thử với API thật (`real API`); mọi e2e mới chạy trên mock.
