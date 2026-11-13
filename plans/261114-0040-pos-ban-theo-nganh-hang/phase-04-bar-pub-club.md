---
phase: 4
title: "Tab quầy bar cho bar, pub và club"
status: pending
effort: "2 ngày"
dependsOn: []
---

# Phase 4: Tab quầy bar cho bar, pub và club

## Bối cảnh

Bar (`bar_pub_club`: `fnb.tables`, `fnb.postpay`, `fnb.service_charge`, `fnb.bottle_keep`, bề mặt `tab_list`) đang ở màn ba cột vì `sellingLayoutOf` loại `tab_list`. `TabList` (`tab-list.tsx`) đã có ô tìm giữ focus và "Mở tab" chỉ với tên khách; `close-tab-dialog.tsx` đóng tab. Bàn VIP và sofa nằm trên sơ đồ bàn, chuyển qua lại một chạm (trang ngành hứa).

Mockup màn 7. "Minimum spend" trong mockup bỏ vì trang ngành không hứa (quyết định N5 của plan).

## Yêu cầu

1. `sellingLayoutOf` trả `table_service` cho `tab_list`.
2. Khung `order` khi bề mặt là `tab_list`: cột trái hẹp (khoảng 240px) là danh sách tab mở, tìm theo tên không dấu, mỗi tab hiện tên, bàn/khu nếu có, giờ mở, tổng, "n chưa gửi"; tab gọi thanh toán nền xanh lá kèm chữ. Giữa là rail và lưới đồ uống; phải là phiếu. Chạm tab đổi phiếu ngay, không qua bảng.
3. Đầu cột tab: ô tìm (giữ focus như `TabList`), "+ Mở tab", nút chuyển sang khung `board` (sơ đồ bàn VIP) và quay lại.
4. Khung `board` cho bar là bảng bàn của plan trước; chạm bàn có khách mở tab của bàn đó trong khung `order` dạng tab.
5. Gửi bếp xong ở lại tab (bar không quay về bảng như nhà hàng): với `tab_list`, nút chính là "Gửi" và không có "Gửi & ở lại".
6. Ngày kinh doanh qua 0h: tab mở trước 0h vẫn hiện, không tách sang ngày mới (kiểm theo dữ liệu hiện có, không đổi luật).

## File

- Sửa: `packages/pos-shared/src/pos-modules.ts` + test
- Tạo: `apps/pos/src/components/table-service/tab-column.tsx` (dùng lại phần tìm và mở tab của `tab-list.tsx`)
- Sửa: `table-service-screen.tsx`, `ticket-footer.tsx`, `table-board.tsx`, `apps/pos/src/styles.css`, locale `vi`/`en`
- Sửa: `apps/pos/src/components/workspace-tabs.tsx` (gỡ nhánh `TabList` nếu không còn dùng)
- E2E: sửa `apps/pos/e2e/bar-tabs.spec.ts`
- Docs: mục bar trong `docs/pos/fnb-ban-va-tra-sau.md` hoặc trang riêng

## Các bước

1. Unit test `sellingLayoutOf` cho bar; cài đặt.
2. `TabColumn` và khung `order` dạng tab; nút chuyển sang sơ đồ VIP.
3. Hành vi gửi bếp ở lại tab.
4. E2E: mở tab bằng tên, gọi hai đồ, gửi, tìm tab khác bằng tên không dấu, chuyển sang sơ đồ VIP mở bàn, gọi thanh toán và đóng tab.

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/pos-modules.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/bar-tabs.spec.ts e2e/table-service-layout.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/bar-tabs.spec.ts --project tablet
```

## Rủi ro và rollback

- Màn 1366px có thêm cột tab 240px: lưới đồ uống còn khoảng 600px. Giảm số cột lưới, không thu nhỏ ô; trên tablet cột tab thu thành nút mở ngăn kéo.
- Rollback: revert commit; `sellingLayoutOf` loại `tab_list` như cũ.
