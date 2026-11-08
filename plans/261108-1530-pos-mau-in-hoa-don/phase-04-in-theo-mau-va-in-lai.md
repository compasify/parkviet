---
phase: 4
title: "In theo mẫu ở quầy và in lại"
status: completed
effort: "2 ngày"
dependsOn: [2]
---

# Phase 4: In theo mẫu ở quầy và in lại

## Overview

Mọi nơi in dùng mẫu từ server. Lần in đầu dùng mẫu mặc định (hoặc mẫu máy này chọn gần nhất); in lại mặc định dùng đúng mẫu, phiên bản và khổ của bản gốc, cho phép đổi mẫu (D2).

## Implementation Steps

1. `use-receipt-templates.ts`: prefetch danh sách mẫu active khi vào `PosShell`, `staleTime` dài, refetch khi focus. Cache version theo `(id, version)` cho in lại. Lỗi mạng → dùng mẫu mặc định dựng sẵn và hiện cảnh báo nhỏ; không chặn in.
2. `ReceiptPrintPanel` (`components/receipt-print-panel.tsx`):
   - Thay `PaperPicker` bằng **chọn mẫu** (radio/segmented các mẫu active của loại chứng từ, mỗi mẫu hiện tên + khổ). Khổ giấy đi theo mẫu.
   - Chưa in: chọn sẵn mẫu máy này dùng gần nhất cho loại chứng từ (`localStorage` key `parkviet-pos:receipt-template:<document_type>`) nếu còn active, không thì mẫu mặc định.
   - Đã in: chọn sẵn `receipt.original_print` (mẫu + version + khổ), nhãn "Mẫu của bản gốc"; tải đúng version đó. Chọn mẫu khác → dùng version hiện tại của mẫu đó.
   - Gửi `receipt_template_id`, `template_version`, `paper` khi gọi `POST /pos/receipts/:id/prints`; render theo đúng giá trị server trả về trong `print`.
   - Bỏ key cũ `parkviet-pos:receipt-paper`.
3. `prebill-dialog.tsx` và `tender-evidence-dialog.tsx` (phiếu thanh toán): render bằng mẫu mặc định hiện tại của `prebill` / `payment_ticket`, có chọn mẫu nếu loại đó có > 1 mẫu active.
4. Logo: trước `adapter.deliver`, chờ mọi `<img>` trong print root `decode()` (timeout 1,5 s); lỗi thì bỏ logo và vẫn in.
5. `createBrowserPrintAdapter`: `pageRule` nhận margin từ `config.page`, giữ mặc định hiện tại khi thiếu.
6. Xóa wrapper `formatReceipt`/`formatPrebill`/`formatInvoiceTicket` của phase 1; cập nhật test sang `renderDocument`.

## Files

| Action | Path |
|---|---|
| modify | `apps/pos/src/components/receipt-print-panel.tsx`, `prebill-dialog.tsx`, `tender-evidence-dialog.tsx`, `pos-shell.tsx` |
| create | `apps/pos/src/components/template-picker.tsx` |
| modify | `apps/pos/src/lib/print-adapter.ts`, `invoice-ticket.ts` (+ tests) |
| modify | `apps/pos/e2e/receipts-display.spec.ts`, `split-tender.spec.ts`, `e2e/support/live.ts` |
| create | `apps/pos/e2e/receipt-reprint-template.spec.ts` |

## Success Criteria

- [x] e2e: in lần đầu bằng mẫu A (K80) → sửa mẫu A → in lại vẫn ra nội dung version cũ, khổ K80, banner "BẢN SAO 1".
- [x] e2e: in lại chọn mẫu B (A4) → `ReceiptPrint` ghi mẫu B; lần in lại sau mặc định vẫn là mẫu của bản gốc.
- [x] Mẫu bản gốc đã bị tắt vẫn in lại được.
- [x] API mẫu lỗi → vẫn in được bằng mẫu dựng sẵn, có cảnh báo.
- [x] Phiếu tạm tính và phiếu thanh toán theo mẫu mặc định hiện tại; nhãn tạm tính không mất.
- [ ] Live e2e (`live-api.spec.ts`) pass với server thật. (chưa chạy: cần fixture tổng hợp)

## Kết quả (08/11/2026)

- Phiếu bán, tạm tính và phiếu thanh toán in theo mẫu của cửa hàng; khổ giấy đi theo mẫu. Bỏ `PaperPicker` ở quầy và các key `parkviet-pos:receipt-paper`, `parkviet-pos:ticket-paper`.
- In lại chọn sẵn "Mẫu của bản gốc" (version và khổ của bản gốc); mẫu khác cùng loại dùng version hiện tại. Server không phải sửa.
- Tải mẫu quá 8 giây hoặc lỗi → in bằng mẫu dựng sẵn và hiện cảnh báo. Server từ chối mẫu (422 ở `/receipt_template_id` hoặc `/template_version`) → làm mới danh sách và in lại một lần bằng mẫu mặc định của server.
- Chờ logo tối đa 1,5 giây trước khi in; ảnh lỗi bị ẩn cho lần in đó.
- Đã xóa wrapper `formatReceipt`/`formatPrebill`/`formatInvoiceTicket`.
- **Lệch so với bước 5:** chưa áp dụng `page.margin_mm`. Mọi phiên bản đã lưu đều mang 3 mm, nên áp dụng sẽ đổi lề A4/A5/A6 (12/10/6 mm) và cắt mép phiếu nhiệt có độ rộng cố định khi lề ≥ 5 mm. Lề vẫn theo khổ giấy như cũ.

Vấn đề còn mở:
- Áp dụng lề mẫu cần: lề tùy chọn với mặc định theo khổ, và độ rộng phiếu tính theo lề.
- Khi in bằng mẫu dựng sẵn (dự phòng), server vẫn ghi nhận mẫu đã chọn; in lại sau đó dùng mẫu đó.
- In lại chưa chọn được mẫu của bản gốc ở version hiện tại.
- Máy từng chọn khổ 58mm nay nhận khổ của mẫu mặc định (80mm) nếu cửa hàng chưa tạo mẫu 58mm.
- Chưa chạy e2e với API thật (`live-api.spec.ts`, cần fixture tổng hợp).
