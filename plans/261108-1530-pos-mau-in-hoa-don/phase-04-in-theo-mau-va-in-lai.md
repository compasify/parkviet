---
phase: 4
title: "In theo mẫu ở quầy và in lại"
status: pending
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

- [ ] e2e: in lần đầu bằng mẫu A (K80) → sửa mẫu A → in lại vẫn ra nội dung version cũ, khổ K80, banner "BẢN SAO 1".
- [ ] e2e: in lại chọn mẫu B (A4) → `ReceiptPrint` ghi mẫu B; lần in lại sau mặc định vẫn là mẫu của bản gốc.
- [ ] Mẫu bản gốc đã bị tắt vẫn in lại được.
- [ ] API mẫu lỗi → vẫn in được bằng mẫu dựng sẵn, có cảnh báo.
- [ ] Phiếu tạm tính và phiếu thanh toán theo mẫu mặc định hiện tại; nhãn tạm tính không mất.
- [ ] Live e2e (`live-api.spec.ts`) pass với server thật.
