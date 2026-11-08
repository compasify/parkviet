---
phase: 5
title: "Tùy biến nâng cao"
status: pending
effort: "3,5 ngày"
dependsOn: [3, 4]
---

# Phase 5: Tùy biến nâng cao

## Overview

Bổ sung các khả năng khác biệt thấy ở Shopify, Sapo, KiotViet, Lightspeed. Mỗi mục tách được thành PR riêng.

## Hạng mục

1. **Kéo thả khối** ở đầu và chân phiếu (pointer + bàn phím; giữ nút lên/xuống làm phương án dự phòng).
2. **Khối `qr`**:
   - `source: url` với `value` (chỉ http/https, ≤ 300 ký tự) và `caption`, ví dụ fanpage, Zalo OA, link đánh giá.
   - `source: store_social` dùng `url`/`facebook`/`instagram` của `Spree::Store`.
   - `source: vietqr_payment` chỉ cho `prebill`/`payment_ticket` chưa thanh toán, lấy payload từ luồng VietQR nếu plan VietQR đã có; nếu chưa thì ẩn khỏi danh sách khối.
   - Sinh QR ở client bằng một thư viện nhỏ, không gọi dịch vụ ngoài.
3. **Khối `barcode`** số chứng từ (Code 128) để quét tìm đơn ở màn trả hàng/đơn hàng.
4. **Khối `signatures`** cho A4/A5: các ô ký "Người mua", "Người bán", "Thu ngân" (chọn được), nhãn đổi được.
5. **Dòng hàng dạng bảng cho A4/A5**: cột STT, có kẻ bảng, cột tùy chọn rộng hơn.
6. **Logo đơn sắc** cho khổ nhiệt: CSS `filter: grayscale(1) contrast(…)`, tùy chọn trong khối logo.
7. **Tự in sau thanh toán** (`page.auto_print`) cho phiếu bán hàng: mở hộp thoại in ngay khi phiếu được phát hành. Đây là cài đặt theo máy (localStorage), mặc định tắt, vì in tự động phụ thuộc thiết bị. Bản in vẫn được ghi nhận như in tay.
8. **Số liên** (`page.copies` 1–3) cho phiếu bán hàng: một lần bấm in tạo bản gốc và các bản sao kế tiếp, mỗi liên được ghi nhận riêng và mang nhãn "BẢN SAO n", đúng quy tắc hiện tại. Gọi `prints` tuần tự với idempotency key riêng cho từng liên.
9. **Cảnh báo độ rộng**: ước tính ký tự/dòng theo khổ và cỡ chữ, gạch chân phần sẽ bị xuống dòng trong preview.

## Files (chính)

| Action | Path |
|---|---|
| modify | `server/app/services/spree/pos/receipt_template_schema.rb` (khối mới, schema vẫn 1, thêm loại khối) |
| create | `apps/pos/src/components/receipt-template/{qr-block,barcode-block,signature-block}.tsx` |
| modify | `apps/pos/src/lib/receipt-template/render.ts`, `components/print-sheet.tsx`, `styles/receipt.css` |
| modify | `apps/pos/src/components/receipt-print-panel.tsx` (auto print, liên) |
| modify | `apps/pos/package.json` (thư viện QR/Code128, chọn loại không có dependency nặng) |

## Success Criteria

- [ ] QR và mã vạch in rõ trên 58mm và 80mm (UAT trên máy in thật của cửa hàng pilot); quét được bằng máy quét hiện có.
- [ ] URL không phải http/https bị server từ chối (422).
- [ ] In 2 liên tạo 2 `ReceiptPrint` (gốc + BẢN SAO 1); thất bại giữa chừng không in liên chưa được ghi nhận.
- [ ] Tự in mặc định tắt; bật ở một máy không ảnh hưởng máy khác.
