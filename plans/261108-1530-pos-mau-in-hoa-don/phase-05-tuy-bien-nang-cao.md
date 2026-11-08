---
phase: 5
title: "Tùy biến nâng cao"
status: completed
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

- [ ] QR và mã vạch in rõ trên 58mm và 80mm (UAT trên máy in thật của cửa hàng pilot); quét được bằng máy quét hiện có. (chưa kiểm được ở đây: cần máy in và máy quét thật)
- [x] URL không phải http/https bị server từ chối (422).
- [x] In 2 liên tạo 2 `ReceiptPrint` (gốc + BẢN SAO 1); thất bại giữa chừng không in liên chưa được ghi nhận.
- [x] Tự in mặc định tắt; bật ở một máy không ảnh hưởng máy khác.

## Kết quả (08/11/2026)

- Schema vẫn `schema: 1`, thêm khối `qr` (`source: url` với `value` http/https ≤ 300 ký tự, hoặc `source: store_social` với `field` `url`/`facebook`/`instagram`; `caption` ≤ 60), `barcode`, `signatures` (`parties` buyer/seller/cashier, `labels` ≤ 40), `logo.monochrome` và `page.copies` 1–3 chỉ cho `sale`. Link không phải http/https trả 422 `invalid_url`. Test client so khớp loại khối với `BLOCK_KEYS` của server.
- QR sinh ở client bằng `uqr` (0.1.3, không dependency). Code 128 (bộ B) tự viết ở `lib/receipt-template/code128.ts`; bảng mã đã đối chiếu với `python-barcode`. Mã vạch in số chứng từ (với phiếu bán là số đơn, tra được ở màn Trả hàng). Phiếu tạm tính và phiếu thanh toán không có số nên không có mã vạch.
- **Lệch:** không làm `source: vietqr_payment`. Luồng VietQR chỉ có `qr_url` là ảnh của `img.vietqr.io` (dịch vụ ngoài) và chỉ có khi đã tạo tender VietQR, không có payload EMV để sinh QR ở client; nguồn này bị ẩn và server từ chối.
- Trang của cửa hàng lưu dạng handle (`@parkviet`) hoặc tên miền được đổi thành link đầy đủ; cửa hàng chưa có trang đó thì khối ẩn.
- Ô chữ ký và bảng kẻ ô của dòng hàng (kiểu bảng) chỉ in trên A4/A5; editor chỉ cho thêm ô chữ ký khi khổ là A4/A5.
- Số liên: chỉ lần in đầu của phiếu bán tạo bản gốc và các bản sao, gọi `prints` tuần tự, mỗi liên một idempotency key và theo layout của bản gốc; tất cả in trong một hộp thoại in, mỗi liên một trang. Liên nào không ghi nhận được thì dừng, chỉ in các liên đã ghi nhận và báo lỗi. In lại vẫn là một bản sao mỗi lần.
- Tự in sau thanh toán: cài đặt theo máy (`parkviet-pos:auto-print:sale` trong localStorage), mặc định tắt, bật/tắt ngay trong hộp in phiếu bán. Chỉ tự in khi đơn chuyển sang hoàn tất lúc màn thanh toán đang mở và phiếu chưa in.
- Kéo thả khối bằng tay cầm (pointer, kể cả cảm ứng) và bàn phím (Enter/Space nhấc, mũi tên di chuyển, Enter đặt, Esc hủy); nút lên/xuống vẫn giữ.
- Preview trong editor gạch chân phần chữ vượt ước lượng ký tự/dòng của khổ nhiệt; bản in không có gạch chân. Cảnh báo độ rộng có thêm cho khối thông tin cửa hàng.
- `page.margin_mm` vẫn chưa áp dụng; ô lề trong editor ghi rõ chưa dùng khi in.
- Số liên dựa vào câu trả lời của server cho lần in đầu, không dựa vào phiếu đang cache; sau khi in, cache phiếu được cập nhật.
- Mã vạch thu hẹp vạch từ 0,33 xuống 0,25 mm cho vừa khổ; vẫn không vừa thì không in và editor cảnh báo.

Vấn đề còn mở:
- UAT in QR và mã vạch trên máy in nhiệt thật (58mm, 80mm) và quét bằng máy quét của cửa hàng pilot.
- QR thanh toán VietQR trên phiếu tạm tính cần server trả payload EMV (hoặc thông tin tài khoản đủ để dựng payload) cho đơn chưa có tender.
- Khi mẫu không tải được (dự phòng), số liên theo mẫu dựng sẵn (1 liên).
