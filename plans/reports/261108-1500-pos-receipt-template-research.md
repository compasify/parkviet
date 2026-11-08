# Mẫu in hóa đơn POS — research & đề xuất thiết kế

Ngày: 2026-11-08 · Phạm vi: menu **Cài đặt POS → Mẫu in** (không thuộc Spree Admin)

## 1. Hiện trạng trong code

| Thành phần | Vị trí | Ghi chú |
|---|---|---|
| Format phiếu đã ghi sổ / tạm tính | `apps/pos/src/lib/print-adapter.ts` (`formatReceipt`, `formatPrebill`) | Bố cục cứng: banner → header → meta → lines → totals → payments → notes → disclaimer |
| Phiếu thanh toán khổ nhiệt | `apps/pos/src/lib/invoice-ticket.ts` | Bộ format thứ hai, dạng bảng, footer cố định "cảm ơn" |
| Render | `components/receipt-sheet.tsx`, `invoice-ticket-sheet.tsx`, `styles/receipt.css` | HTML + `@page`, chỉ in qua trình duyệt |
| Cỡ giấy | `receipt-print-panel.tsx:20` | Lưu `localStorage` từng máy, mặc định 80mm |
| Snapshot | `server/app/models/spree/pos/receipt_snapshot.rb`, `services/spree/pos/receipt_builder.rb` | Bất biến; payload chỉ có `store.name`, `branch.name/code`, `register` |
| Dữ liệu doanh nghiệp | `Spree::Pos::Branch` | **Chưa có** địa chỉ, SĐT, MST, logo |
| Khuôn settings theo chi nhánh | `pages/settings/label-formats.tsx`, API `/pos/branches/:id/label_formats` | Có thể tái dùng khuôn này |

Disclaimer cố định: "Phiếu bán hàng POS — không phải hóa đơn điện tử".

## 2. Thị trường làm thế nào

| App | Cỡ giấy | Kiểu template | Điểm đáng học |
|---|---|---|---|
| KiotViet | K80, A4 | Rich-text + token (`/` để chèn biến) | Tối đa 5 mẫu/loại chứng từ, chọn A/B/C ngay màn bán hàng, chọn mẫu khi in lại, preview cạnh bên theo khổ giấy, in thử, đặt lại |
| Sapo | K57, K80, A5, A4 | Bật/tắt 80+ biến + editor trực quan (font, cỡ, màu) | Lịch sử phiên bản & khôi phục, QR thanh toán, tiền thừa/còn nợ |
| Haravan POS | 2 khổ gợi ý | HTML + Liquid | Linh hoạt nhưng người dùng phải "copy ra Notepad sửa" → khó dùng |
| MISA eShop | Theo khổ phổ biến | Lưới bảng + merge field | Nhiều loại phiếu (tạm tính, giao hàng, thu/chi, tem), field công nợ, trường HĐĐT (ký hiệu, số, mã CQT, mã tra cứu/QR) |
| Shopify POS | Nhiệt | Visual editor (block kéo thả) + block Liquid giới hạn; **đang bỏ editor code thuần** | Trường bắt buộc theo luật bị khóa theo quốc gia; QR/barcode mã đơn; override theo địa điểm |
| Square | Nhiệt | Form cài đặt | Cỡ chữ theo máy in, tự in theo printer profile, ngôn ngữ phiếu |
| Loyverse | Nhiệt | Toggle | Logo in riêng (đen trắng), header/footer ≤ 500 ký tự |
| Lightspeed X | Nhiệt / A4 | Form + toggle | Nhiều mẫu, **gán theo quầy**, locale theo mẫu, QR web/mạng xã hội kéo thả |
| Odoo / Toast | Nhiệt | Toggle header/footer | Tự in, QR cho khách tự yêu cầu hóa đơn |

Nguồn: kiotviet.vn/huong-dan-su-dung-kiotviet/retail-thiet-lap/quan-ly-mau-in, sapo.vn/cap-nhat-tinh-nang/nang-cap-cau-hinh-mau-in, help.haravan.com/docs/pos/settings, helpeshop.misa.vn/kb/thiet-lap-mau-in, help.shopify.com/en/manual/sell-in-person/shopify-pos/customize-pos/printed-receipts, squareup.com/help/us/en/article/5424, support.loyverse.com/en/articles/8622406, x-series-support.lightspeedhq.com/hc/en-us/articles/25534014632987, odoo.com/documentation/18.0/applications/sales/point_of_sale/receipts_invoices.html, doc.toasttab.com/doc/platformguide/adminReceiptSetup.html.
(Chưa tìm được tài liệu chính thức của iPOS, Suno, Nhanh, Pos365.)

### Ba cách tiếp cận

| Cách | Ưu | Nhược |
|---|---|---|
| Toggle/form (Square, Loyverse, Toast) | Không phá được layout, hợp khổ nhiệt & ESC/POS, dễ khóa trường bắt buộc | Ít tùy biến |
| **Block builder** (Shopify, Sapo mới, MISA) | Cân bằng: sắp xếp block, text tự do có biến, QR, vẫn validate được, chạy được trên mọi khổ | Tốn công làm hơn |
| HTML/Liquid/token tự do (Haravan, KiotViet) | Linh hoạt tối đa cho A4 | Dễ vỡ trên 58/80mm, người bán khó tự sửa, khó đảm bảo trường pháp lý, rủi ro XSS, không chuyển được sang ESC/POS |

Xu hướng: Shopify đang rời bỏ editor code thuần sang block builder → chọn **block builder**.

### Bối cảnh pháp lý (cần kiểm lại với văn bản gốc)
NĐ 70/2025 (sửa NĐ 123/2020, hiệu lực 01/06/2025): bán lẻ trực tiếp và hộ kinh doanh ≥ 1 tỷ/năm phải dùng **HĐĐT khởi tạo từ máy tính tiền**. Khi phiếu POS là HĐĐT thì phải có: tên, địa chỉ, MST người bán; hàng hóa, số lượng, đơn giá, thành tiền; thuế suất/tiền thuế; tổng; thời điểm; ký hiệu, số HĐ, mã CQT hoặc mã tra cứu/QR; hình thức thanh toán. Hiện POS ghi rõ "không phải HĐĐT" nên chưa bắt buộc, nhưng template phải chừa chỗ cho các trường này và **khóa** chúng khi bật HĐĐT.

## 3. Đề xuất thiết kế

### 3.1 Nguyên tắc
1. **Snapshot là dữ kiện, template là cách trình bày.** Template không bao giờ tính hay sửa số tiền; chỉ chọn hiển thị/ẩn, nhãn, thứ tự, trang trí.
2. **Một mô hình tài liệu, nhiều renderer.** Gộp `formatReceipt`, `formatPrebill`, `formatInvoiceTicket` thành một renderer theo template → HTML hôm nay, ESC/POS sau này. Vì vậy không dùng HTML tự do.
3. **Phần bị khóa** không tắt được: banner "BẢN SAO", disclaimer "không phải HĐĐT", tổng cộng, số chứng từ; khi bật HĐĐT thì khóa thêm các trường pháp lý.
4. **Biến chỉ theo whitelist** (`{store.name}`, `{order.number}`…), render text thuần → không XSS, không truy cập dữ liệu ngoài payload. Che SĐT/tên khách vẫn do server quyết định; template không mở khóa được.

### 3.2 Mô hình dữ liệu (server)
- `Spree::Pos::ReceiptTemplate`: `store`, `branch` (nil = toàn cửa hàng), `name`, `document_type` (`sale`, `prebill`, `payment_ticket`, `return`, `refund`, `shift_closure`), `paper` (`58mm|80mm|a4|a5|a6`), `status`, `is_default`, `version`, `config` (JSONB, validate theo schema), `updated_by`.
- `Spree::Pos::ReceiptTemplateVersion`: lưu `config` mỗi lần lưu → lịch sử & khôi phục.
- Gán mặc định: theo `document_type × paper` ở cấp cửa hàng, ghi đè theo chi nhánh, tùy chọn theo quầy (như Lightspeed).
- `ReceiptPrint` ghi thêm `template_id` + `template_version` để kiểm toán bản in.
- **Hồ sơ doanh nghiệp** (mới): tên pháp lý, MST, địa chỉ, SĐT, email, website, logo (ActiveStorage) ở cấp cửa hàng, ghi đè theo chi nhánh. Các trường danh tính pháp lý được **copy vào snapshot lúc phát hành** (dữ kiện); logo/QR/text trang trí lấy từ template lúc in.

### 3.3 Schema `config` (block builder)
```jsonc
{
  "page": { "margin_mm": 3, "font": "sans|mono", "font_size": "s|m|l", "line_spacing": 1.2,
            "copies": 1, "auto_print": false, "language": "vi" },
  "header": [
    { "type": "logo", "width_pct": 60, "align": "center", "mono": true },
    { "type": "business", "fields": ["legal_name","branch","address","phone","tax_id","website"] },
    { "type": "text", "value": "Mở cửa 7h–22h · Hotline {branch.phone}", "align": "center", "bold": false },
    { "type": "title", "label": "HÓA ĐƠN BÁN HÀNG" },
    { "type": "code", "kind": "barcode|qr", "source": "order.number" }
  ],
  "meta":   { "fields": ["time","cashier","register","order_number","customer"], "labels": {} },
  "lines":  { "layout": "stacked|table", "columns": ["index","name","sku","unit","qty","price","discount","amount"],
              "show_trace": true, "show_conversion": true, "show_line_note": false },
  "totals": { "fields": ["item_total","discount","tax","total"], "labels": { "total": "TỔNG THANH TOÁN" } },
  "payments": { "fields": ["methods","handed","change","debt","due_on"] },
  "footer": [
    { "type": "text", "value": "Đổi trả trong {branch.return_window_days} ngày kèm phiếu." },
    { "type": "qr", "source": "url", "value": "https://…", "caption": "Theo dõi chúng tôi" },
    { "type": "qr", "source": "vietqr_static" },
    { "type": "signatures", "roles": ["buyer","seller"] },   // khổ A4/A5
    { "type": "text", "value": "Cảm ơn quý khách!", "align": "center", "bold": true }
  ]
}
```
Block trong header/footer kéo thả được; meta/lines/totals/payments là section cố định thứ tự, chỉ bật/tắt cột/trường và đổi nhãn. Giới hạn độ dài text (≈500 ký tự/block) và số block.

### 3.4 Giao diện — Cài đặt POS → Mẫu in
- **Danh sách**: nhóm theo loại chứng từ; mỗi mẫu hiển thị khổ giấy, phạm vi (cửa hàng/chi nhánh), cờ mặc định. Hành động: tạo từ mẫu gợi ý, nhân bản, đặt mặc định, ngừng dùng.
- **Editor** 2 cột: trái là các accordion (Trang & giấy · Đầu phiếu · Thông tin chung · Dòng hàng · Tổng & thanh toán · Chân phiếu); phải là **preview trực tiếp** dùng lại `ReceiptSheet` với dữ liệu mẫu hoặc một phiếu thật gần nhất, đổi khổ giấy ngay trên preview.
- Bộ chọn biến (gõ `{` hoặc nút "Chèn thông tin"), cảnh báo khi text quá rộng cho 58mm.
- **In thử**, **Khôi phục mặc định**, **Lịch sử phiên bản**.
- Màn in (`ReceiptPrintPanel`): ngoài khổ giấy, thêm chọn mẫu (A/B/C); khổ/mẫu mặc định lấy từ server thay cho `localStorage`, máy vẫn nhớ lựa chọn gần nhất.
- Quyền: đọc theo quyền topology hiện có; sửa cần quyền ghi (có thể tách quyền `print_templates.manage`).

### 3.5 Lộ trình
| Giai đoạn | Nội dung |
|---|---|
| P1 — Nền tảng | Hồ sơ doanh nghiệp (địa chỉ, SĐT, MST, logo); model + API template; renderer hợp nhất; toggle trường/cột, text đầu/chân, nhãn; mặc định theo chi nhánh × khổ giấy; preview + in thử |
| P2 — Tùy biến sâu | Kéo thả block, biến trong text, QR/barcode, chữ ký A4, nhiều mẫu + chọn khi in/in lại, lịch sử phiên bản, số liên, tự in sau thanh toán |
| P3 — Mở rộng | Bảng A4 kiểu hóa đơn đầy đủ, renderer ESC/POS (in im lặng), trường HĐĐT máy tính tiền (khóa khi bật), phiếu bếp/giao hàng/thu chi nếu cần |

## 4. Câu hỏi cần chốt
1. Phạm vi mẫu: chỉ cấp cửa hàng, hay cửa hàng + ghi đè theo chi nhánh, hay tới từng quầy?
2. In lại: dùng mẫu **hiện tại** (như KiotViet, đề xuất) hay mẫu lúc in bản gốc?
3. Có kế hoạch tích hợp HĐĐT máy tính tiền không, và khi nào? (ảnh hưởng việc khóa trường)
4. Có cần mức "HTML tự do" cho A4 không? Đề xuất: không, ít nhất tới P3.
5. Logo và hồ sơ doanh nghiệp: lưu trong POS (model mới) hay lấy từ `Spree::Store` (sửa ở Admin)?
