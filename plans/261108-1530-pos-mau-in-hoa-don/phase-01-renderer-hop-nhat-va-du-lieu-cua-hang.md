---
phase: 1
title: "Renderer hợp nhất và dữ liệu cửa hàng"
status: completed
effort: "2 ngày"
dependsOn: []
---

# Phase 1: Renderer hợp nhất và dữ liệu cửa hàng

## Overview

Chưa có tùy biến. Mục tiêu là đưa mọi phiếu về một renderer chạy theo mẫu, với mẫu mặc định dựng sẵn cho ra **đúng** phiếu hiện tại, và đưa thông tin cửa hàng từ `Spree::Store` vào snapshot và context.

## Hiện trạng

- Ba bộ format: `formatReceipt`, `formatPrebill` (`apps/pos/src/lib/print-adapter.ts`) và `formatInvoiceTicket` (`apps/pos/src/lib/invoice-ticket.ts`).
- Hai component render: `components/receipt-sheet.tsx`, `components/invoice-ticket-sheet.tsx`.
- Payload snapshot chỉ có `store.name` (`server/app/services/spree/pos/receipt_builder.rb:88-95`).
- Context chỉ trả `store.{id,name,currency,locale,timezone}` (`server/app/controllers/spree/api/v3/admin/pos/context_controller.rb:32-38`).

## Implementation Steps

### Server
1. `ReceiptBuilder#base`: thêm vào `'store'` các trường `address`, `contact_phone`, `customer_support_email`, `url`, `facebook`, `instagram` (chỉ giá trị có mặt). Thêm `'branch' => { ..., 'return_window_days' => branch.return_window_days }`. Không đưa logo vào snapshot.
2. Context: thêm `store.profile` gồm các trường trên và `logo_url`. Xác minh tên attachment logo của `Spree::Store` trong Spree 6 (Admin API trả `logo_url`) và dùng URL công khai của nó.
3. Spec: `spec/services/spree/pos/receipt_builder_spec.rb` (hoặc spec hiện có của builder) kiểm tra các trường mới; `spec/requests/spree/pos/...context...` kiểm tra `store.profile`.

### Client
4. Tạo `apps/pos/src/lib/receipt-template/`:
   - `types.ts`: `DocumentType`, `TemplateConfig` (schema 1, xem phase 2), `PrintDocument` (danh sách section và block đã resolve, chỉ text/hình/mã).
   - `data.ts`: chuẩn hóa nguồn dữ liệu thành `TemplateData` — từ `ReceiptSnapshot`, từ `PosWorkspace` (prebill), từ workspace + attempts (payment_ticket); chuyển toàn bộ logic chọn dòng/tổng/thanh toán hiện có vào đây, giữ nguyên cách bỏ dòng 0đ.
   - `variables.ts`: whitelist biến và `interpolate(text, data)` (biến lạ để nguyên chuỗi, không lỗi).
   - `render.ts`: `renderDocument(config, data, { banner, testPrint })` → `PrintDocument`; áp dụng khóa (banner BẢN SAO, disclaimer, tiêu đề, số, tổng, nhãn tạm tính luôn có).
   - `defaults.ts`: mẫu mặc định cho 6 loại chứng từ, tái tạo output hiện tại (payment_ticket dạng bảng như `InvoiceTicketSheet`).
5. Tạo `components/print-sheet.tsx` render `PrintDocument` (dùng lại class CSS trong `styles/receipt.css`), và `PrintPortal`. Cho `ReceiptSheet`, `InvoiceTicketSheet` gọi qua lớp mới (hoặc thay hẳn), giữ `data-testid` và `data-paper`, `data-print-id` hiện có để e2e không đổi.
6. Giữ `formatReceipt`/`formatPrebill`/`formatInvoiceTicket` như wrapper mỏng gọi renderer với mẫu mặc định, để test hiện có (`print-adapter.test.ts`, `invoice-ticket.test.ts`) chạy nguyên trạng; xóa wrapper ở phase 4.
7. Header: hiển thị địa chỉ/SĐT cửa hàng khi có (mẫu mặc định bật), ẩn khi trống.

## Files

| Action | Path |
|---|---|
| modify | `server/app/services/spree/pos/receipt_builder.rb` |
| modify | `server/app/controllers/spree/api/v3/admin/pos/context_controller.rb` |
| create | `apps/pos/src/lib/receipt-template/{types,data,variables,render,defaults}.ts` + `*.test.ts` |
| create | `apps/pos/src/components/print-sheet.tsx` |
| modify | `apps/pos/src/components/receipt-sheet.tsx`, `invoice-ticket-sheet.tsx` |
| modify | `apps/pos/src/lib/print-adapter.ts`, `invoice-ticket.ts`, `pos-context.ts` (type store profile) |

## Success Criteria

- [x] Toàn bộ test hiện có pass không sửa kỳ vọng: `print-adapter.test.ts`, `invoice-ticket.test.ts`, e2e `receipts-display`, `split-tender`, `close-invoice-tab`.
- [x] Test mới: mỗi loại chứng từ render từ mẫu mặc định ra đúng thứ tự và nội dung như trước; không thể tắt các phần bị khóa dù config tắt chúng.
- [x] Snapshot mới có địa chỉ/SĐT cửa hàng; snapshot cũ vẫn render, khối trống bị ẩn.
- [x] Không có số tiền nào được tính ở client ngoài tiền thừa đang có sẵn.

## Kết quả (08/11/2026)

- Mọi chứng từ đi qua `renderDocument` (`apps/pos/src/lib/receipt-template/`); mẫu mặc định cho ra đúng phiếu cũ, ngoài dòng địa chỉ/SĐT cửa hàng và dòng cảm ơn của phiếu thanh toán (nay là khối chân phiếu).
- Ngoài các phần khóa trong plan, số tiền đã hoàn của phiếu hoàn tiền cũng luôn in. Khối hỏng (không phải object) bị bỏ qua; khối text ẩn từng dòng có biến đều rỗng.
- Context lấy `logo_url` bằng `cdn_image_url`; lỗi thiếu host mặc định chỉ trả `null` và báo qua `Rails.error`.
- Spec mới: `server/spec/requests/spree/pos/receipt_store_profile_spec.rb`. Thư mục `spec/models/spree/pos/` chưa tồn tại.
- Phase 2 cần chép `DEFAULT_TEMPLATES` và `TEMPLATE_VARIABLES` sang server.

Vấn đề còn mở:
- `return_supplement` vẫn không in số tiền (giữ nguyên hành vi cũ).
- Mẫu bán hàng tắt được `paid_total`, `debt`, `due_on`; phiếu bán nợ có thể không in số còn nợ. Cần quyết định có khóa các dòng này không.
- Tiêu đề chứng từ đổi được nhãn (vẫn luôn in, kèm số chứng từ).
