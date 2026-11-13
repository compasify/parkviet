---
phase: 1
title: "Chọn bố cục và tách hook bán hàng"
status: pending
effort: "2,5 ngày"
dependsOn: []
---

# Phase 1: Chọn bố cục và tách hook bán hàng

## Bối cảnh

`apps/pos/src/components/workspace-tabs.tsx` (1853 dòng) vừa giữ trạng thái và lệnh bán (danh sách workspace, workspace đang chọn, serializer lệnh, lease, `command`, `run`, đồng bộ `?order=` với URL, placement course/ghế, các cờ module) vừa vẽ bố cục ba cột. Bố cục bàn mới cần đúng các trạng thái và lệnh đó. Phase này tách phần không phải giao diện ra một hook, rồi thêm điểm rẽ nhánh bố cục. Không đổi gì người dùng thấy.

## Yêu cầu

1. `packages/pos-shared/src/pos-modules.ts` có `sellingLayoutOf(context): 'table_service' | 'counter'`. Trả `table_service` khi `modules['fnb.tables'] === true` và `profile.display.surface` không phải `tab_list` hay `resource_board`; còn lại `counter`.
2. Hook `apps/pos/src/hooks/use-selling-workspace.ts` chứa toàn bộ trạng thái và lệnh hiện ở `WorkspaceTabs` mà không phải JSX: `workspaces`, `active`, `selectOrder`, `command`, `run`, `serializer`, `pendingCounts`, `busy`, `editable`, `canAppend`, `locked`, `lockReason`, `kitchenOn`, `postpay`, `placement`/`setPlacement`, `tableAddExtra`, `menu`, `soldOut`, đồng bộ URL `?order`, lease. `WorkspaceTabs` gọi hook này và chỉ còn phần vẽ.
3. Route `/` nhận thêm search `view?: 'board' | 'order' | 'pay'` (validate như `order`).
4. `pages/sale.tsx` rẽ nhánh: `table_service` vẽ `TableServiceScreen` (khung rỗng tạm, chỉ vẽ lại màn cũ trong phase này), `counter` vẽ `WorkspaceTabs` như cũ.

## File

- Sửa: `packages/pos-shared/src/pos-modules.ts`, `packages/pos-shared/src/pos-modules.test.ts`
- Tạo: `apps/pos/src/hooks/use-selling-workspace.ts`
- Sửa: `apps/pos/src/components/workspace-tabs.tsx`, `apps/pos/src/router.tsx`, `apps/pos/src/pages/sale.tsx`
- Tạo: `apps/pos/src/components/table-service/table-service-screen.tsx` (khung, giữ hành vi cũ)

## Các bước

1. Viết `sellingLayoutOf` và unit test bốn trường hợp: không có `fnb.tables`; có bàn với `floor_plan`; có bàn với `menu_grid`; có bàn với `tab_list` / `resource_board`.
2. Di chuyển từng khối state/effect/handler của `WorkspaceTabs` sang hook theo thứ tự xuất hiện, giữ nguyên tên và comment. Không đổi điều kiện, không gộp effect.
3. `WorkspaceTabs` lấy mọi thứ từ hook; chạy typecheck.
4. Thêm `view` vào `validateSearch` của `saleRoute`.
5. Rẽ nhánh ở `SalePage`. `TableServiceScreen` tạm thời vẽ `WorkspaceTabs` để phase 3–6 thay dần.

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/pos-modules.test.ts
pnpm --dir apps/pos typecheck
pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/lease.spec.ts e2e/lease-recovery.spec.ts e2e/layout-recovery.spec.ts e2e/tables.spec.ts e2e/table-kitchen-send.spec.ts e2e/full-retail.spec.ts --project desktop
```

Tất cả phải qua mà không sửa spec nào: phase này không được đổi hành vi.

## Rủi ro và rollback

- Effect phụ thuộc thứ tự (URL ↔ tab đang chọn, lease) dễ lệch khi tách. Giữ nguyên thứ tự khai báo trong hook.
- Rollback: revert commit của phase; không có thay đổi dữ liệu.
