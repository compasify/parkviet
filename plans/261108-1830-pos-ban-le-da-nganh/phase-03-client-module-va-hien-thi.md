---
phase: 3
title: "Client: context, ẩn hiện theo module, mặc định hiển thị"
status: pending
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

- [ ] Context không có `modules` (server cũ / mock cũ) → UI y như hiện tại. Toàn bộ e2e hiện có pass mà không phải sửa expectation.
- [ ] Chi nhánh tắt `retail.traceability`: không thấy menu Truy xuất tồn kho, không thấy tùy chọn tracked trong editor SKU. Vẫn bán được SKU tracked bằng serial (e2e mới `branch-modules.spec.ts`).
- [ ] Chi nhánh hồ sơ `nha_thuoc` mở danh mục ở dạng **Danh sách**; `thoi_trang` ở dạng **Thẻ**.
- [ ] `409 module_disabled` hiện thông báo dịch được, không phải lỗi chung chung.
- [ ] `pnpm --dir apps/pos lint`, `typecheck`, `test`, `test:e2e` pass.
