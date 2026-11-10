---
phase: 1
title: "Tách packages/pos-shared"
status: done
priority: P2
effort: "1.5d"
dependencies: []
---

# Phase 1: Tách `packages/pos-shared`

## Goal
Chuyển phần logic thuần mà cả màn bán hàng lẫn trang cài đặt cùng dùng vào một package source. `apps/pos` dùng package đó và không đổi hành vi.

## Bối cảnh
Đã kiểm tra các import (09/11):
- `lib/receipt-template/*`: `types.ts`, `defaults.ts` và `code128.ts` không phụ thuộc gì. `render.ts`, `validate.ts` và `variables.ts` chỉ dùng file trong cùng thư mục. Riêng `data.ts`, `sample-data.ts` và `selection.ts` có import `../money`, `../pay-later`, `../pos-context` và `../print-adapter`.
- `lib/pos-modules.ts`, `lib/pos-features.ts` và `lib/pos-capabilities.ts` không phụ thuộc gì.
- `lib/label-format.ts` chỉ dùng `./money`.
- `lib/setup-wizard.ts` dùng `pos-features` và `pos-modules`.
- `modules/registry.ts` dùng `pos-modules` và `traceability`.
- `print-adapter.ts` có phần gọi trình duyệt để in, nên **ở lại** `apps/pos`. Chỉ các type mà `receipt-template` cần mới được chuyển đi.

## Files to Create / Modify
- Create: `packages/pos-shared/package.json` (`"name": "@parkviet/pos-shared"`, `"type": "module"`, `exports` trỏ thẳng vào `src/*.ts`, không có bước build)
- Create: `packages/pos-shared/tsconfig.json`, `vitest.config.ts`, `biome.json` (copy cấu hình từ `apps/pos`)
- Create: `packages/pos-shared/src/receipt-template/*` (chuyển từ `apps/pos/src/lib/receipt-template/*`, kèm test)
- Create: `packages/pos-shared/src/{money,label-format,pos-modules,pos-features,pos-capabilities,setup-wizard,module-registry,traceability,pay-later}.ts`. Chỉ chuyển phần thuần; chỗ nào lẫn với UI hay session thì tách hàm ra.
- Create: `packages/pos-shared/src/types/pos-context.ts`. Chỉ chứa các type (`PosBranch`, `PosMembership`, `PosContext`…) mà phần dùng chung cần.
- Modify: `apps/pos/package.json` (thêm `"@parkviet/pos-shared": "link:../../packages/pos-shared"`)
- Modify: các file trong `apps/pos/src` import từ đường dẫn cũ, đổi sang `@parkviet/pos-shared/...`
- Delete: các file gốc đã chuyển trong `apps/pos/src/lib`, `apps/pos/src/modules/registry.ts`

## Tasks & Steps
1. Lập danh sách export mà `apps/pos` dùng từ mỗi file sẽ chuyển (`grep -rn "from '.*receipt-template"` và các file còn lại).
2. Tạo package, chuyển file và test bằng `git mv` để giữ lịch sử.
3. Gỡ phụ thuộc ngược: `data.ts`, `sample-data.ts` và `selection.ts` chỉ được import type từ `types/pos-context.ts` và từ `print-adapter` (phần type). Test dùng `i18n` thì nhận bộ dịch qua tham số hoặc tự nạp locale riêng của test.
4. `server-contract.test.ts` và `validate.test.ts` đang đọc file bằng `node:fs` theo đường dẫn tương đối. Sửa đường dẫn để vẫn trỏ đúng vào `server/`.
5. Đổi import trong `apps/pos`, chạy `pnpm install` trong `apps/pos`.

## Verification
- `cd packages/pos-shared && pnpm install && pnpm test && pnpm exec tsc --noEmit`
- `cd apps/pos && pnpm typecheck && pnpm lint && pnpm test && pnpm build`
- `grep -rn "lib/receipt-template\|modules/registry" apps/pos/src` không còn kết quả nào.
- In thử một hóa đơn trong POS ở dev: bố cục giống trước khi tách.

## Risk / Rollback
Chỉ đổi chỗ đặt file và đường dẫn import. Có lỗi thì revert commit của phase.
