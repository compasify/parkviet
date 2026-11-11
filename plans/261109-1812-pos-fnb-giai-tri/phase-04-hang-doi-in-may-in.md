---
phase: 4
title: "Hàng đợi in và máy in"
status: in-progress
effort: "6 ngày"
dependsOn: [2, 3]
---

# Phase 4: Hàng đợi in và máy in

## Overview

F&B cần in ra máy in nhiệt theo trạm, mà không có hộp thoại trình duyệt, kể cả khi không có máy thu ngân nào đang mở (đơn từ app phục vụ, QR order, kiosk). Phase này thêm danh mục máy in, hàng đợi in ở server có trạng thái, và hai adapter trình duyệt: Epson ePOS-Print và Star WebPRNT. Máy in Sunmi và ESC/POS (LAN, Bluetooth) được in bởi app Flutter ở chế độ `print_station` (phase 5), theo D4.

Hiện trạng đã kiểm:
- `apps/pos/src/lib/print-adapter.ts` có `interface PrintAdapter { deliver(paper, options) }` và chỉ có `createBrowserPrintAdapter`.
- Kiểu `PrintDocument` (banners, header, meta, lines, totals, payments, payQr, notes, footer, disclaimer) nằm ở `apps/pos/src/lib/receipt-template/types.ts`. Bộ render template chạy **trên client**, trong `receipt-template/render.ts`.
- Server có `ReceiptTemplateSchema`, `ReceiptSnapshot` và `ReceiptPrint` (bản gốc / bản sao), nhưng chưa có hàng đợi.

## Quyết định của phase

1. **`PrintDocument` v1 là định dạng trung lập, có thêm phía server.**
   - Ruby `Spree::Pos::PrintDocuments` dựng đúng cấu trúc của kiểu TS hiện có, thêm trường `version: 1` và `kind`.
   - Biên lai và tạm tính đưa vào hàng đợi được dựng ở server từ `ReceiptSnapshot` cùng template hiện hành (`ReceiptPrint` chọn template / version / paper như đang làm).
   - Phiếu bếp, phiếu hủy, tem ly và phiếu kiểm đồ là tài liệu chỉ có ở server, bố cục cố định, dựng từ dữ liệu của phase 9 / 10.
   - **Chống lệch giữa hai bộ render:** dùng fixture vàng chung ở `server/spec/fixtures/print_documents/*.json`. Spec Ruby sinh ra đúng các file này, vitest đọc chúng để so với bộ render TS. Mở rộng `receipt-template/server-contract.test.ts` đang có.
2. **Máy in là bản ghi** `Printer`, thuộc chi nhánh.
   - `connection`: `escpos_lan`, `escpos_bluetooth`, `sunmi_builtin`, `epson_epos`, `star_webprnt`, `browser`.
   - Ba loại đầu bắt buộc gắn với một thiết bị `print_station` (`print_station_device_id`).
   - Hai loại `epson_epos` / `star_webprnt` có `address` (IP:port), và trình duyệt của thu ngân in thẳng vào đó.
   - Có `paper` (`58mm|80mm`) và `roles` (danh sách loại phiếu mặc định máy này nhận). Định tuyến theo trạm bếp thêm ở phase 9 qua `KitchenStation.printer_id`.
3. **Vòng đời `PrintJob`:**

   | Trạng thái | Ý nghĩa |
   |---|---|
   | `queued` | Đã tạo, chờ trạm in nhận |
   | `claimed` | Trạm in đã nhận, có lease 30 giây |
   | `printed` | Đã in xong |
   | `failed` | In lỗi, kèm lý do |
   | `canceled` | Đã hủy |

   - Trạm in nhận job bằng `FOR UPDATE SKIP LOCKED`, giống `DispatchOutboxJob`.
   - Lease hết hạn thì job về lại `queued`. Tối đa 5 lần thử, sau đó `failed` và phát `print_job.created` cho máy thu ngân để hiện cảnh báo.
   - Mỗi job có `idempotency_key` unique theo `(store_id, key)`, nên báo bếp lặp lại không in hai lần.
   - Job đi theo thứ tự `id` trong từng máy in.
4. **In lại:** dùng `POST print_jobs/:id/reprint`.
   - Biên lai in lại tạo `ReceiptPrint` bản sao như hiện tại.
   - **Tạm tính** in lại cần `Approval` action `workspace.reprint_prebill`, đúng bất biến 4.
   - Phiếu bếp in lại đóng dấu "IN LẠI" và không tạo ticket mới.
5. **Adapter trình duyệt** (`apps/pos/src/lib/print-adapters/`):
   - `epson-epos.ts` dựng ePOS-Print XML và gửi bằng `fetch` tới `http(s)://<ip>/cgi-bin/epos/service.cgi`;
   - `star-webprnt.ts` dựng Star Markup và POST tới `/StarWebPRNT/SendMessage`.

   Cả hai map `PrintDocument` sang lệnh in (text, căn lề, đậm, cỡ chữ, QR, cắt giấy). Lỗi CORS / mixed content được báo bằng `PrintOutcome` dễ hiểu (phase 6 hướng dẫn cấu hình HTTPS trên máy in hoặc dùng HTTP trên LAN). Hộp thoại trình duyệt vẫn là đường dự phòng.
6. **Thu ngân chọn đường in theo máy in mặc định của quầy:**
   - `epson_epos` / `star_webprnt`: in thẳng từ trình duyệt;
   - ba loại gắn với trạm in: tạo `PrintJob`;
   - `browser`: dùng hộp thoại như hiện tại.

## Dữ liệu

| Bảng | Cột chính |
|---|---|
| `spree_pos_printers` | `store_id`, `branch_id`, `name`, `connection`, `address`, `bluetooth_id`, `paper`, `command_language` (`escpos|tspl`, mặc định `escpos`; `tspl` cho máy in tem ly), `roles text[]`, `print_station_device_id` FK `spree_pos_devices`, `register_id` (máy in mặc định của quầy, nullable), `status` (`active|disabled`), `settings jsonb` (codepage, độ rộng ký tự, có cắt giấy, có két) |
| `spree_pos_print_jobs` | `store_id`, `branch_id`, `printer_id`, `kind` (`receipt|prebill|kitchen_ticket|void_ticket|cup_label|checklist|table_qr|test`), `document jsonb` (PrintDocument v1), `source_type` / `source_id`, `status`, `attempts`, `claimed_by_device_id`, `claim_expires_at`, `printed_at`, `last_error`, `idempotency_key`, `created_by_id`, `copy_of_id` |

Index: `(printer_id, status, id)`, unique `(store_id, idempotency_key)`, `(source_type, source_id)`. Migration: `create_pos_printers`, `create_pos_print_jobs`. Thêm `ON DELETE` restrict: không xóa máy in đang có job `queued`.

## Server

- Model: `server/app/models/spree/pos/printer.rb`, `print_job.rb`.
- Bộ dựng tài liệu: `server/app/services/spree/pos/print_documents.rb` (dispatcher), `print_documents/receipt.rb` (từ snapshot + template), `print_documents/test_page.rb`. Các loại bếp / tem thêm ở phase 9 / 10, cùng thư mục.
- Workflow `server/app/workflows/spree/pos/print_jobs/`: `enqueue.rb`, `claim.rb`, `report.rb` (printed / failed), `reprint.rb`, `cancel.rb`.
- Job `server/app/jobs/spree/pos/release_print_claims_job.rb`, chạy mỗi phút: trả các lease đã hết hạn về `queued`.
- Controller:
  - `api/v3/admin/pos/printers_controller.rb` (CRUD, `test`), capability mới `pos.printer.manage`;
  - `api/v3/admin/pos/print_jobs_controller.rb` (`index` theo chi nhánh / trạng thái, `create` cho biên lai và tạm tính, `reprint`, `cancel`);
  - `server/app/controllers/spree/pos/device_api/print_jobs_controller.rb` (`POST claim`, `POST :id/report`), chỉ cho mode `print_station`.
- Approval action mới: `workspace.reprint_prebill`. Thêm vào danh sách action của `server/app/models/spree/pos/approval.rb`.
- Sự kiện: `print_job.created`, phát tới chi nhánh khi enqueue và khi job chuyển `failed`.
- OpenAPI: thêm `Printer`, `PrintJob`, `PrintDocument` (schema đầy đủ, vì Flutter phải đọc nó), và các endpoint ở trên.

## Client web

- `apps/pos/src/lib/print-adapters/epson-epos.ts`, `star-webprnt.ts`, `index.ts` (chọn adapter theo `Printer.connection`). Giữ `print-adapter.ts` làm interface; adapter trình duyệt cũ không đổi.
- Trang `apps/pos/src/pages/settings/printers.tsx`:
  - danh sách máy in theo chi nhánh;
  - thêm / sửa máy in: chọn loại kết nối, trạm in, khổ giấy, vai trò, máy in mặc định của quầy;
  - nút "In thử".
- Trang hoặc ngăn kéo "Hàng đợi in": job lỗi, in lại, hủy. Hook `apps/pos/src/hooks/use-print-jobs.ts`, invalidate theo `print_job.created`.
- `payment-panel.tsx` và `pages/receipt.tsx`: in theo máy in mặc định của quầy, như quyết định 6.

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `server/db/migrate/*_create_pos_printers.rb`, `*_create_pos_print_jobs.rb` | create | Bảng |
| `server/app/models/spree/pos/printer.rb`, `print_job.rb`, `approval.rb` | create / modify | Model, action duyệt |
| `server/app/services/spree/pos/print_documents*.rb` | create | Dựng tài liệu |
| `server/app/workflows/spree/pos/print_jobs/*.rb` | create | Vòng đời job |
| `server/app/jobs/spree/pos/release_print_claims_job.rb` | create | Trả lease |
| `server/app/controllers/spree/api/v3/admin/pos/printers_controller.rb`, `print_jobs_controller.rb`, `spree/pos/device_api/print_jobs_controller.rb` | create | API |
| `server/spec/fixtures/print_documents/*.json` | create | Fixture vàng dùng chung |
| `apps/pos/src/lib/print-adapters/*.ts`, `pages/settings/printers.tsx`, `hooks/use-print-jobs.ts` | create | Adapter, UI |
| `apps/pos/src/lib/receipt-template/server-contract.test.ts` | modify | So fixture |
| `server/openapi/pos-staff.yaml` | modify | Schema in |

## Các bước

1. Đọc `receipt_print.rb`, `receipt_builder.rb`, `receipt-template/render.ts`, `types.ts`.
2. Chốt `PrintDocument` v1 bằng JSON Schema trong OpenAPI. Kiểu TS được kiểm theo schema này.
3. Viết bộ dựng Ruby cho biên lai và trang in thử, sinh fixture vàng, cho vitest so với bộ render TS.
4. Làm model, workflow và API máy in / job, kèm job trả lease.
5. Viết adapter ePOS và WebPRNT, có unit test cho XML / markup sinh ra từ fixture.
6. Làm UI máy in và hàng đợi in, rồi nối thu ngân với máy in mặc định.

## Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/print_jobs/ spec/requests/spree/pos/printers_spec.rb spec/requests/spree/pos/print_jobs_spec.rb spec/services/spree/pos/print_documents_spec.rb`
- Các ca phải có:
  - hai trạm in nhận job cùng lúc thì mỗi job chỉ một trạm nhận được;
  - lease hết hạn thì job được trả về;
  - job lỗi 5 lần chuyển `failed` và phát sự kiện;
  - enqueue lặp cùng key chỉ tạo một job;
  - in lại tạm tính khi không có approval trả 409 / 403.
- `pnpm --dir apps/pos test`: adapter ePOS / WebPRNT và hợp đồng fixture.
- Thử tay với một máy Epson TM-m30 hoặc Star mC-Print trong LAN. Nếu không có máy thì ghi rõ chưa thử.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Hai bộ render (TS và Ruby) lệch nhau | Fixture vàng dùng chung, CI chạy cả hai phía. Tài liệu chỉ có ở server thì không có bản TS. |
| Trình duyệt chặn gọi HTTP tới máy in từ trang HTTPS | Phase 6 chọn HTTP trên LAN, hoặc bật HTTPS trên máy in. Nếu không được thì chuyển máy in đó sang trạm in. |
| Hàng đợi tắc vì một job hỏng | Mỗi máy in một thứ tự; job `failed` không chặn job sau; UI cho hủy. |

## Tiêu chí xong

- [x] Có danh mục máy in theo chi nhánh với 6 loại kết nối; có in thử (e2e trang máy in chưa chạy).
- [x] `PrintJob` đi đủ vòng đời, trạm in nhận job atomic, lease tự trả.
- [x] `PrintDocument` v1 có schema; fixture Ruby / TS khớp nhau.
- [ ] Thu ngân in thẳng ra Epson ePOS / Star WebPRNT trong LAN, hoặc đẩy job cho trạm in (đường đẩy job đã có; in thẳng chưa thử với máy thật).
- [x] In lại tạm tính cần duyệt (trên đường hàng đợi; đường trình duyệt và máy LAN do phase 13 ghi nhận).
- [ ] Spec POS và test web xanh (spec và unit xanh; chưa chạy full suite và e2e dashboard).

## Kết quả

Code đã xong, đã qua review và đã commit. Phase giữ `in-progress` vì còn hai mục chưa kiểm bên dưới.

**Kiểm thử:** full rspec 858 example, 0 failure; unit `packages/pos-shared` 247, `apps/pos` 245, `apps/pos-dashboard` 85 đều xanh; full e2e `apps/pos` 366 pass, 26 skip, 1 fail. Test fail là `full-retail.spec.ts:176` trên mobile, chạy riêng thì pass và cũng từng fail khi tải cao trên HEAD sạch.

**Chưa kiểm:** `apps/pos-dashboard/e2e/branch-printers.spec.ts` chưa từng chạy vì cổng 5176 đang bị một dev server giữ; chưa thử máy Epson TM-m30 hay Star mC-Print thật, lệnh in mới được kiểm dưới dạng chuỗi.

**Khác với kế hoạch ban đầu:**
- Cấu hình máy in và in thử nằm ở `apps/pos-dashboard`; hàng đợi và đường in của thu ngân ở `apps/pos`; bộ dựng lệnh Epson / Star ở `packages/pos-shared/src/print-commands/` vì cả hai app cùng dùng.
- `Approval` không có danh sách action; `workspace.reprint_prebill` được khớp khi consume.
- Giới hạn tạm tính tính theo digest nội dung hóa đơn, không theo `revision`, vì đỗ đơn rồi mở lại cũng tăng `revision`. Đổi serial / lô không tính là đổi nội dung.
- Thêm `POST receipts/:id/prints/:print_id/void` (chỉ cho bản in thẳng ra máy), `GET printers/stations`, `GET print_jobs/prebills`.
- Job in lỗi được thử lại sau 10, 30, 60 và 120 giây.
- `POST /pos/approvals` nhận thêm `write_pos_orders`, nên quản lý chi nhánh có capability duyệt cấp được duyệt mà không cần quyền cấu hình cửa hàng. Việc cấp vẫn do capability tại chi nhánh quyết định.

**Hành vi cần biết:** giao job là at-least-once. Nếu giấy đã in, báo cáo bị mất và lease hết hạn rồi job bị nhận lại thì sẽ in hai lần; không tránh được khi máy in không xác nhận.

**Còn lại:**
- Phase 13: ghi nhận tạm tính in qua trình duyệt / máy LAN, và `workspace.cancel_prebill`.
- Máy in có trạm đã bị thu hồi vẫn `active`; lệnh in bị từ chối với thông báo rõ và có cảnh báo job kẹt.
