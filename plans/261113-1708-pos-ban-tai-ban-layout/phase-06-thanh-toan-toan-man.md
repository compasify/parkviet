---
phase: 6
title: "Thanh toán toàn màn"
status: pending
effort: "1,5 ngày"
dependsOn: [5]
---

# Phase 6: Thanh toán toàn màn

## Bối cảnh

Mockup màn 4; quy tắc 9 của research. `PaymentPanel` (967 dòng) đã có mọi phương thức, VietQR, nhiều lần thu, tiền thừa, ghi nợ, thẻ nạp, hóa đơn điện tử, quyền thu tiền và điều kiện ngăn kéo; hiện nó nằm trong cột thanh toán của màn cũ. Phần tách bill nằm ở `TableOrderBar` / `SplitOrderDialog`.

## Yêu cầu

1. Khung `pay` thay toàn bộ vùng dưới thanh trên. Trái 400px: phiếu rút gọn (món, số lượng, tiền), khuyến mại và phụ phí tách dòng, tổng. Phải: ba ô to "Cần thu · Còn lại · Tiền thừa".
2. VietQR hiện sẵn kèm số tiền còn lại khi chi nhánh có VietQR, trạng thái "Chờ chuyển khoản, tự khớp khi tiền về"; tiền mặt có mệnh giá gợi ý và bàn phím số; các phương thức khác ở hàng dưới. Logic vẫn là của `PaymentPanel`; phase này thêm prop bố cục (`layout="fullscreen"`, `defaultTender="vietqr"`) và CSS, không viết lại luồng tiền.
3. Đáy: Chia đều, Tách theo món, Tách theo ghế (gọi lệnh tách hiện có), In tạm tính, Xuất hóa đơn điện tử; nút chính "Hoàn tất · in hóa đơn".
4. "← Đơn" về khung `order`. Hoàn tất thành công thì về khung `board`.
5. Khung `pay` ghi vào URL (`?order=…&view=pay`); tải lại trang mở lại đúng màn thanh toán của đơn.
6. Đơn bàn khi đã có tiền thu một phần thì phiếu khóa sửa như hiện nay (`editLockedPayments`).

## File

- Tạo: `apps/pos/src/components/table-service/payment-screen.tsx`
- Sửa: `apps/pos/src/components/payment-panel.tsx` (prop bố cục, không đổi luồng), `apps/pos/src/styles.css`, locale
- Sửa: `apps/pos/src/components/table-service/table-service-screen.tsx`

## Các bước

1. Thêm prop bố cục vào `PaymentPanel` với giá trị mặc định giữ nguyên DOM cũ; chạy `split-tender.spec.ts` để chắc màn cũ không đổi.
2. Dựng `PaymentScreen` bọc `PaymentPanel` và phiếu rút gọn.
3. Nối nút tách bill vào lệnh `splitTable` / `splitBySeat` có sẵn.
4. Thêm kịch bản e2e: mở bàn → gửi bếp → thanh toán VietQR (mock webhook như spec hiện có) → về bảng bàn; tải lại khi đang ở khung `pay`.

## Kiểm tra

```bash
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/split-tender.spec.ts e2e/einvoice-buyer.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project desktop
```

## Rủi ro và rollback

- `PaymentPanel` có nhiều nhánh theo quyền và trạng thái ca; prop bố cục chỉ đổi CSS và thứ tự hiển thị, không đổi điều kiện.
- Rollback: revert commit; nút "Thanh toán" quay về mở cột thanh toán của phiếu cũ.
