---
phase: 5
title: "Phiếu bàn"
status: pending
effort: "2,5 ngày"
dependsOn: [2, 4]
---

# Phase 5: Phiếu bàn

## Bối cảnh

Mockup màn 2 (nửa phải); quy tắc 4, 6, 7 của research. Hiện phiếu được ghép từ nhiều khối rời: `OrderLines`, `TableOrderBar` (chuyển, gộp, tách bàn, phí phục vụ, gọi thanh toán), `CourseSeatPicker`, `BuffetTierPicker`, `KitchenHistory` (nút báo bếp), `PrebillDialog`, `VoidItemDialog`, `DiscountForm`, `NoteForm`. Dòng món có `kitchen_status`, `course`, `course_status`, `seat`, `pending_kitchen_quantity` và từ phase 2 có `kitchen_send_sequence`.

## Yêu cầu

1. **Đầu phiếu:** nút "← Bàn" (về khung `board`), tên bàn (chạm mở chuyển / gộp bàn của `TableOrderBar`), chip số khách (chạm để sửa), thời gian ngồi, phục vụ, loại đơn; nút "⋯" chứa tách đơn, tách theo ghế, gộp đơn, giảm giá, ghi chú, khách hàng, phí phục vụ, hủy đơn. Các thao tác này gọi đúng lệnh mà `TableOrderBar` và các form hiện tại đang gọi.
2. **Nhóm dòng:** công tắc "Nhóm theo: Lượt gửi | Course | Ghế" (nhớ theo máy).
   - Lượt gửi: nhóm "MỚI · chưa gửi bếp · n món" luôn trên cùng, nền vàng nhạt, nhãn "Mới", sửa / xóa tự do; dưới đó các lượt mới nhất trước, tiêu đề "Lượt k · giờ · người gửi" lấy từ `kitchen_sends`, dòng đã gửi có biểu tượng khóa và trạng thái bếp (Đang làm n′ / Đã ra / Chờ gọi).
   - Course: tiêu đề course có biểu tượng chờ / đã gọi / xong và nút "Gọi món ra" cho course đang giữ (lệnh `fireCourse`).
   - Ghế: tiêu đề ghế kèm tổng tiền ghế; chạm tiêu đề chọn ghế đang nhập (đặt `placement.seat`).
   - Hàm nhóm là hàm thuần `groupTicketLines(workspace, mode)` trong `packages/pos-shared`, có unit test.
3. **Dòng chọn:** chạm dòng mở hàng thao tác: bước số lượng, ghi chú, ghế, giảm giá, xóa (dòng chưa gửi) hoặc hủy món có lý do (dòng đã gửi, qua `VoidItemDialog` và quyền `pos.kitchen.void`).
4. **Đáy phiếu:** dòng tóm tắt (số món, phí phục vụ, VAT, tạm tính); hàng phụ "In tạm tính" (`PrebillDialog`), "Giữ món" (đặt course đang nhập sang giữ), "Gửi & ở lại"; hai nút chính "Gửi bếp (n)" (n = tổng `pending_kitchen_quantity`, khóa khi 0, khi chi nhánh `kitchen_send_trigger === 'on_complete'` thì ẩn) và "Thanh toán · tổng" (sang khung `pay`).
5. Gửi bếp thành công: thông báo ngắn "Đã gửi n món" rồi về khung `board`. "Gửi & ở lại" giữ khung `order`.
6. Buffet: `BuffetTierPicker` vào menu "⋯" khi chi nhánh có buffet; không thiết kế lại.
7. Đơn mang về / giao đi dùng cùng phiếu, không có nhóm theo ghế và không có "← Bàn" mà là "← Bảng bàn".

## File

- Tạo: `apps/pos/src/components/table-service/ticket.tsx`, `ticket-header.tsx`, `ticket-lines.tsx`, `ticket-footer.tsx`, `ticket-more-menu.tsx`
- Sửa: `packages/pos-shared/src/tables.ts` hoặc file mới `packages/pos-shared/src/ticket-groups.ts` (+ test)
- Sửa: `apps/pos/src/components/table-service/table-service-screen.tsx`, `apps/pos/src/styles.css`, locale
- Dùng lại không đổi API: `TableOrderBar` (tách phần nút thành hàm dùng chung nếu cần), `VoidItemDialog`, `PrebillDialog`, `DiscountForm`, `NoteForm`, `CustomerPanel`, `BuffetTierPicker`

## Các bước

1. Unit test `groupTicketLines` cho ba chế độ: dòng chưa gửi, nhiều lượt, course giữ / đã gọi, ghế null vào "Chung cả bàn", dòng đã hủy.
2. Dựng phiếu từ dưới lên: footer (gửi bếp, thanh toán), danh sách dòng, header, menu "⋯".
3. Nối lệnh qua hook phase 1; không gọi `useWorkspaces` trực tiếp trong component.
4. Sửa e2e `table-kitchen-send.spec.ts` và `fnb-wave2.spec.ts` theo phiếu mới; thêm kịch bản "Gửi & ở lại".

## Kiểm tra

```bash
pnpm --dir packages/pos-shared exec vitest run src/ticket-groups.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/table-kitchen-send.spec.ts e2e/fnb-wave2.spec.ts e2e/guest-orders.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/table-kitchen-send.spec.ts --project tablet
```

## Rủi ro và rollback

- Nhiều máy cùng sửa một bàn: phiếu phải hiện lỗi `line_changed` / `line_sent` như `OrderLines` đang làm (`lib/table-kitchen.ts`) và tải lại đơn.
- Rollback: revert commit; khung `order` quay lại phiếu cũ của phase 4.
