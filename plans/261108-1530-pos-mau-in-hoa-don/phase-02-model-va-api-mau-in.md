---
phase: 2
title: "Model và API mẫu in"
status: pending
effort: "2,5 ngày"
dependsOn: [1]
---

# Phase 2: Model và API mẫu in

## Overview

Lưu mẫu theo cửa hàng, có phiên bản bất biến, validate schema ở server, và ghi mẫu/phiên bản/khổ giấy vào mỗi bản in để in lại đúng bản gốc (D2).

## Dữ liệu

`spree_pos_receipt_templates` — prefix `postpl`
- `store_id` (FK, not null), `name` (≤ 60), `document_type` (`sale|prebill|payment_ticket|return|refund|shift_closure`), `paper` (`58mm|80mm|a4|a5|a6`), `status` (`active|disabled`), `is_default` (bool), `current_version` (int), `created_by_id`, `updated_by_id`, timestamps.
- Unique partial index `(store_id, document_type) WHERE is_default AND status = 'active'`.
- Tối đa 5 mẫu `active` mỗi `(store, document_type)`.
- Mẫu bị tắt, không xóa (giống `LabelFormat`), vì bản in cũ còn tham chiếu.

`spree_pos_receipt_template_versions` — readonly sau khi tạo
- `receipt_template_id`, `version`, `config` (jsonb), `created_by_id`, `created_at`; unique `(receipt_template_id, version)`.

`spree_pos_receipt_prints` — thêm cột nullable `receipt_template_id`, `template_version`, `paper`. Bản in cũ để null.

Khổ giấy là thuộc tính của mẫu: muốn cùng nội dung trên A4 thì nhân bản mẫu và đổi khổ.

## Schema `config` (schema 1)

```jsonc
{
  "schema": 1,
  "page":   { "margin_mm": 3, "font": "sans|mono", "font_size": "s|m|l", "line_spacing": 1.0-1.6 },
  "header": [ /* khối, tối đa 8 */ ],
  "meta":   { "fields": ["time","cashier","register","branch","order_number","return_number","customer"], "labels": {} },
  "lines":  { "layout": "stacked|table", "columns": ["index","name","sku","unit","qty","price","discount","amount"],
              "show_trace": true, "show_conversion": true },
  "totals": { "fields": ["item_total","discount","tax","included_tax","total"], "labels": {} },
  "payments": { "fields": ["methods","handed","change","reference","paid_total","debt","due_on"], "labels": {} },
  "footer": [ /* khối, tối đa 8 */ ]
}
```

Khối phase 2–3: `logo {width_pct 20–100, align}`, `business {fields: name|branch|address|phone|email|url|facebook|instagram}`, `text {value ≤ 500, align, bold, size}`, `title {label ≤ 60}`, `divider {style: solid|dashed}`, `spacer {mm 1–10}`. Khối phase 5: `qr`, `barcode`, `signatures`.

Quy tắc validate (`Spree::Pos::ReceiptTemplateSchema`):
- Key, loại khối, field, cột, nhãn theo whitelist; nhãn ≤ 40 ký tự; mỗi field chỉ hợp lệ cho loại chứng từ có dữ liệu đó (ví dụ `shift_closure` không có `lines`).
- Biến trong text phải thuộc whitelist; biến lạ → lỗi 422 có `pointer` tới khối.
- Các phần bị khóa không có trong schema nên không tắt được; `total` luôn được thêm khi render dù thiếu trong `fields`.
- Payload `config` ≤ 16 KB.

## API (`/api/v3/admin/pos/receipt_templates`)

| Method | Path | Quyền | Ghi chú |
|---|---|---|---|
| GET | `/receipt_templates` | thành viên active của bất kỳ chi nhánh nào, hoặc `read_pos_topology` | Trả mẫu active + config phiên bản hiện tại; `?document_type=`, `?include_disabled=1` (chỉ admin) |
| GET | `/receipt_templates/:id?version=N` | như trên | Lấy đúng phiên bản (dùng cho in lại) |
| GET | `/receipt_templates/:id/versions` | `write_pos_topology` | Lịch sử: version, người sửa, thời gian |
| POST | `/receipt_templates` | `write_pos_topology` | Từ mẫu mặc định (`from_default: document_type`) hoặc `config` |
| PATCH | `/receipt_templates/:id` | `write_pos_topology` | Bắt buộc `expected_version`; lệch → 409 `template_version_conflict`; tạo version mới |
| POST | `/receipt_templates/:id/duplicate` | `write_pos_topology` | |
| POST | `/receipt_templates/:id/default` | `write_pos_topology` | Đặt mặc định cho loại chứng từ, trong transaction |
| POST | `/receipt_templates/:id/restore` | `write_pos_topology` | `{version}` → tạo version mới với config cũ |
| POST | `/receipt_templates/:id/disable` | `write_pos_topology` | Không tắt được mẫu mặc định cuối cùng của một loại |

- Mọi ghi gọi `audit!('receipt_template.*', template, {...})`.
- `Spree::Pos::ReceiptTemplate.ensure_defaults!(store)` tạo mẫu mặc định khi đọc lần đầu, giống `UnitDefinition.ensure_defaults!`. Config mặc định nằm ở `server/config/pos/receipt_templates/*.json`, và client dùng bản sao làm fallback (phase 1 `defaults.ts`). Spec contract so sánh hai bản.
- Route trong `server/config/routes.rb`, cạnh `resources :label_formats`.

## In và in lại (`POST /pos/receipts/:id/prints`)

- Nhận thêm `receipt_template_id`, `template_version`, `paper` (tùy chọn).
- Server kiểm tra mẫu thuộc store, `document_type` khớp loại snapshot (`return_supplement` dùng mẫu `return`), và version tồn tại. Mẫu đã tắt chỉ được chấp nhận khi đúng là mẫu của bản in gốc.
- Bỏ trống: lấy mẫu của bản in gốc (copy 0); nếu bản gốc chưa có mẫu (dữ liệu cũ) hoặc chưa in, lấy mẫu mặc định hiện tại.
- `ReceiptPrint#to_pos` trả thêm `template_id`, `template_version`, `paper`. `ReceiptSnapshot#to_pos` trả thêm `original_print: { template_id, template_version, paper } | null`.
- Idempotency giữ như hiện tại (`CommandExecutor`); thêm các tham số mẫu vào payload băm idempotency.

## Files

| Action | Path |
|---|---|
| create | `server/db/migrate/*_create_spree_pos_receipt_templates.rb` (2 bảng + cột mới ở prints) |
| create | `server/app/models/spree/pos/receipt_template.rb`, `receipt_template_version.rb` |
| create | `server/app/services/spree/pos/receipt_template_schema.rb` |
| create | `server/config/pos/receipt_templates/{sale,prebill,payment_ticket,return,refund,shift_closure}.json` |
| create | `server/app/controllers/spree/api/v3/admin/pos/receipt_templates_controller.rb` |
| modify | `server/app/controllers/spree/api/v3/admin/pos/receipts_controller.rb` (`prints`) |
| modify | `server/app/models/spree/pos/receipt_print.rb`, `receipt_snapshot.rb` |
| modify | `server/config/routes.rb` |
| create | `server/spec/models/spree/pos/receipt_template_spec.rb`, `spec/services/spree/pos/receipt_template_schema_spec.rb`, `spec/requests/spree/pos/receipt_templates_spec.rb` |
| modify | `server/spec/requests/spree/pos/receipts_displays_spec.rb` (in theo mẫu, in lại) |

## Success Criteria

- [ ] `pnpm spree migrate` chạy sạch; `pnpm spree rspec spec/requests/spree/pos/receipt_templates_spec.rb spec/requests/spree/pos/receipts_displays_spec.rb` pass.
- [ ] Thu ngân không có `write_pos_topology` đọc được mẫu nhưng mọi lệnh ghi trả 403; store khác trả 404.
- [ ] Config sai (khối lạ, biến lạ, quá dài, field không hợp loại chứng từ) → 422 kèm vị trí lỗi.
- [ ] PATCH với `expected_version` cũ → 409; không mất chỉnh sửa của người khác.
- [ ] In lại không truyền mẫu → dùng mẫu + version + khổ của bản gốc, kể cả khi mẫu đã sửa hoặc đã tắt; truyền mẫu khác cùng loại → được ghi nhận; khác loại → 422.
- [ ] Mỗi thao tác ghi có audit entry.
