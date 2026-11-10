---
phase: 7
title: "Hóa đơn điện tử"
status: pending
effort: "7 ngày"
dependsOn: [1]
---

# Phase 7: Hóa đơn điện tử

## Overview

Mục tiêu: phát hành hóa đơn điện tử (HĐĐT) cho mọi đơn complete, gửi qua một nhà cung cấp, có hàng đợi chạy lại, và dùng chung cho cả bán lẻ lẫn F&B. Phase này cần làm vì:
- hộ kinh doanh doanh thu > 1 tỷ / năm bắt buộc dùng HĐĐT (NĐ 68/2026, sửa bởi NĐ 141/2026);
- F&B và giải trí thuộc nhóm dùng hóa đơn khởi tạo từ máy tính tiền;
- từ 01/07/2026, NĐ 254/2026 và TT 91/2026 thay bộ văn bản cũ (research §7).

**Nhà cung cấp do khách hàng chọn** (đã chốt 09/11/2026): mỗi cửa hàng chọn nhà cung cấp trong cài đặt, nên server phải có nhiều adapter. Phase này làm interface, hàng đợi, adapter `sandbox` (hành vi thật nhưng chỉ ghi trong DB) và **adapter VNPT**, vì khách thường dùng VNPT. Adapter của MISA, Viettel và các bên khác viết thêm theo cùng interface khi có khách cần, mỗi adapter một commit.

## Quyết định của phase

1. **Đọc văn bản gốc trước khi chốt trường dữ liệu.** Bước 1 của phase là đọc NĐ 254/2026/NĐ-CP và TT 91/2026/TT-BTC từ nguồn chính thức (Công báo / vbpl.vn, hoặc bản trên thuvienphapluat). Ghi vào `docs/legal/hddt-nd254-tt91.md`:
   - nội dung bắt buộc của HĐ khởi tạo từ máy tính tiền;
   - nội dung bắt buộc của HĐ có mã;
   - quy định thời điểm lập (gồm ngoại lệ 22h–6h ở Điều 9);
   - cách ghi khi người mua không lấy hóa đơn.

   Các tên trường dưới đây là bản nháp và sửa theo ghi chú đó.
2. **Hai loại hóa đơn**, cấu hình theo store (`StoreProfile.einvoice_type`):

   | Giá trị | Loại |
   |---|---|
   | `cash_register` | HĐ khởi tạo từ máy tính tiền |
   | `coded` | HĐ có mã từng lần |
   | `none` | Không phát hành, mặc định cho đơn vị dưới ngưỡng |

   Theo dõi doanh thu lũy kế trong năm và cảnh báo trên dashboard khi đạt 80% và 100% của mốc 1 tỷ. Phần cảnh báo này chỉ đọc báo cáo, không đổi hành vi bán.
3. **Phát hành sau complete, không chặn complete.**
   - `Workspaces::Complete` ghi một `OutboxEntry` `einvoice.issue` **trong cùng transaction**. Model này đã có, với cơ chế `record!` và `DispatchOutboxJob` claim bằng SKIP LOCKED.
   - Một handler mới gọi adapter. Lỗi thì chạy lại với backoff (1, 5, 15, 60 phút, rồi mỗi 6 giờ) cho đến khi thành công hoặc có người hủy.
   - Mất internet trên server LAN (phase 6) thì đơn vẫn complete, và hóa đơn được phát hành khi có mạng lại.
4. **Người mua:**
   - Mặc định là đơn không có thông tin người mua. Dòng chữ ghi trên hóa đơn ("Người mua không lấy hóa đơn" hoặc "Bán cho người tiêu dùng") chốt theo bước 1 và đặt trong cấu hình, không viết cứng.
   - Khi khách cần hóa đơn công ty, thu ngân nhập MST, tên, địa chỉ, email; hoặc khách **tự nhập qua QR trên bill**.
   - Server có `GET /pos_einvoice/:token` (trang web nhỏ, token ký, hết hạn theo cấu hình, mặc định đến cuối ngày kinh doanh), tra MST qua API của nhà cung cấp nếu có.
   - Khách gửi thông tin trước khi hóa đơn được phát hành thì hóa đơn mang thông tin đó. Nếu đã phát hành thì làm điều chỉnh / thay thế theo quy định ghi ở bước 1. Bản đầu cho quản lý làm thủ công, có audit.
5. **Dòng hóa đơn:**
   - Lấy từ snapshot đơn, kèm thuế suất **theo dòng** (phase 1, `TaxCategory`).
   - Dòng tính giờ (phase 17) có đơn vị "giờ", số lượng thập phân 2 chữ số.
   - Phí phục vụ (phase 13) là một dòng chịu thuế.
   - Tip không vào hóa đơn (phase 19).
6. **Địa điểm:** mỗi chi nhánh có thể in tên và địa chỉ riêng (`Branch` / `StoreProfile`), cùng **ký hiệu mẫu số / ký hiệu hóa đơn** riêng. Nhà cung cấp cấp ký hiệu, cấu hình ở mức chi nhánh.
7. **Interface adapter** `Spree::Pos::Einvoice::Provider` gồm:
   - `issue(invoice) → { provider_ref, number, symbol, lookup_code, issued_at }`;
   - `status(invoice)`;
   - `cancel(invoice, reason)`;
   - `lookup_tax_code(mst)` (tùy chọn).

   Adapter được đăng ký qua registry `Spree::Pos::Einvoice.providers`, giống cách Spree đăng ký payment method. Thông tin đăng nhập nhà cung cấp lưu mã hóa bằng Active Record encryption (đã cấu hình khóa trong env).

## Dữ liệu

| Bảng | Cột chính |
|---|---|
| `spree_pos_einvoices` | `store_id`, `branch_id`, `order_id` unique, `workspace_id`, `invoice_type`, `provider`, `status` (`pending|issuing|issued|failed|canceled|adjusted`), `buyer jsonb` (mst, name, address, email, buyer_note), `lines_snapshot jsonb`, `totals_snapshot jsonb`, `provider_ref`, `number`, `symbol`, `lookup_code`, `issued_at`, `attempts`, `next_attempt_at`, `last_error`, `buyer_token_digest`, `buyer_token_expires_at` |
| `spree_pos_einvoice_settings` | `store_id`, `branch_id` (nullable = mặc định store), `provider`, `credentials` (encrypted), `template_code`, `symbol`, `seller_name`, `seller_address`, `consumer_label`, `status` |
| `spree_pos_store_profiles` | thêm `einvoice_type` (`none|cash_register|coded`, mặc định `none`) |

Migration: `create_pos_einvoices`, `create_pos_einvoice_settings`, `add_einvoice_type_to_pos_store_profiles`. Index: `(store_id, status, next_attempt_at)`.

## Server

- `server/app/services/spree/pos/einvoice.rb` (registry), `einvoice/provider.rb` (interface), `einvoice/sandbox_provider.rb`, `einvoice/vnpt_provider.rb` (adapter VNPT, dùng web service hóa đơn của VNPT theo tài liệu tích hợp họ cấp cho đối tác), `einvoice/builder.rb` (snapshot dòng + thuế từ order và `Workspace#to_pos`).
- `server/app/workflows/spree/pos/einvoices/`:
  - `enqueue.rb`, gọi trong `workspaces/complete.rb`;
  - `issue.rb` (idempotent theo `order_id`: đã `issued` thì bỏ qua);
  - `update_buyer.rb`;
  - `cancel.rb`;
  - `retry.rb`.
- `DispatchOutboxJob` hiện chỉ đánh dấu processed. Thêm bảng định tuyến `event_type → handler` và handler `einvoice.issue`. Không đổi hành vi của các event_type đang có.
- Controller:
  - `api/v3/admin/pos/einvoices_controller.rb` (`index` có lọc "chưa có hóa đơn" / "lỗi", `show`, `update_buyer`, `retry`, `cancel`), capability mới `pos.einvoice.manage`;
  - `api/v3/admin/pos/einvoice_settings_controller.rb`;
  - `server/app/controllers/spree/pos/einvoice_buyer_controller.rb`: trang công khai cho khách tự nhập MST, có rate limit.
- Mẫu in: biến `einvoice.lookup_code`, `einvoice.lookup_url`, `einvoice.buyer_qr` trong `config/pos/receipt_template_variables.json`. QR tự nhập MST in trên bill khi store bật `einvoice_type`.
- Báo cáo: "Đơn chưa có hóa đơn" theo `business_date` / chi nhánh trong `reports_controller.rb`. Thêm "Doanh thu lũy kế năm" để cảnh báo mốc 1 tỷ.
- Audit: `einvoice.issued`, `einvoice.failed`, `einvoice.buyer_updated`, `einvoice.canceled`.
- OpenAPI: `Einvoice`, `EinvoiceSettings`.

## Client web

- `apps/pos/src/pages/settings/einvoice.tsx`: chọn loại hóa đơn, nhà cung cấp, thông tin đăng nhập (chỉ ghi, không hiện lại), ký hiệu theo chi nhánh, nút "Phát hành thử" (sandbox).
- `payment-panel.tsx`: ô "Khách lấy hóa đơn" (MST, tên, địa chỉ, email) trước khi kết thúc.
- `pages/orders.tsx` / `pages/receipt.tsx`: trạng thái hóa đơn của đơn, thêm thông tin người mua, phát hành lại.
- `apps/pos/src/pages/einvoices.tsx`: danh sách lỗi / chưa có hóa đơn, chạy lại hàng loạt.
- Trang khách tự nhập MST: HTML do server render, không thuộc `apps/pos`, để chạy được trên điện thoại khách mà không cần cài gì.

## File

| Đường dẫn | Loại | Nội dung |
|---|---|---|
| `docs/legal/hddt-nd254-tt91.md` | create | Ghi chú văn bản gốc |
| `server/db/migrate/*` (3 file) | create | Như bảng Dữ liệu |
| `server/app/models/spree/pos/einvoice.rb`, `einvoice_setting.rb`, `store_profile.rb` | create / modify | Model |
| `server/app/services/spree/pos/einvoice*.rb` | create | Registry, adapter, builder |
| `server/app/workflows/spree/pos/einvoices/*.rb`, `workspaces/complete.rb` | create / modify | Phát hành |
| `server/app/jobs/spree/pos/dispatch_outbox_job.rb` | modify | Định tuyến handler |
| `server/app/controllers/spree/api/v3/admin/pos/einvoices_controller.rb`, `einvoice_settings_controller.rb`, `spree/pos/einvoice_buyer_controller.rb` | create | API, trang khách |
| `server/config/pos/receipt_template_variables.json` | modify | Biến hóa đơn |
| `apps/pos/src/pages/settings/einvoice.tsx`, `pages/einvoices.tsx`, `components/payment-panel.tsx` | create / modify | UI |
| `server/openapi/pos-staff.yaml` | modify | Schema |

## Các bước

1. Đọc NĐ 254/2026 và TT 91/2026 từ nguồn chính thức, viết `docs/legal/hddt-nd254-tt91.md`, rồi sửa danh sách trường của phase.
2. Viết migration, model và cấu hình.
3. Viết builder dòng và thuế, có spec cho đơn 8% + 10%, đơn có phí phục vụ, và dòng giờ (khi phase 17 chưa có thì dùng fixture).
4. Viết adapter sandbox và interface.
5. Gắn `enqueue` vào `complete.rb` và handler outbox. Spec: complete khi adapter lỗi vẫn thành công, hóa đơn ở trạng thái `failed` và được chạy lại.
6. Làm trang khách tự nhập MST và QR trên bill.
7. Làm UI cấu hình, danh sách lỗi, ô người mua ở thanh toán.
8. Làm báo cáo đơn chưa có hóa đơn và doanh thu lũy kế năm.
9. Viết adapter VNPT trong một commit riêng: lấy tài liệu tích hợp và tài khoản thử của VNPT, map trường từ builder, xử lý mã lỗi và chạy lại, rồi thử phát hành, tra cứu và hủy trên môi trường thử của VNPT. Spec của adapter dùng response mẫu ghi lại từ môi trường thử, không gọi mạng.
10. Ghi trong `docs/` cách thêm adapter cho nhà cung cấp khác (interface, đăng ký vào registry, spec mẫu).

## Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/einvoices/ spec/services/spree/pos/einvoice/ spec/requests/spree/pos/einvoices_spec.rb spec/requests/spree/pos/einvoice_buyer_spec.rb`
- Các ca phải có:
  - phát hành lặp lại vẫn chỉ ra một hóa đơn;
  - hai worker cùng claim thì chỉ một worker gọi adapter;
  - token tự nhập MST hết hạn hoặc sai thì bị từ chối;
  - store `none` thì không tạo outbox;
  - thông tin đăng nhập không xuất hiện trong response hay log.
- Hồi quy đường tiền: `pnpm spree rspec spec/workflows/spree/pos/workspaces/complete_spec.rb spec/integration/spree/pos/`.
- `pnpm --dir apps/pos test test:e2e`: thanh toán có nhập MST, đơn hiện trạng thái "Đã phát hành" với adapter sandbox.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Hiểu sai nội dung bắt buộc vì mới đọc qua nguồn thứ cấp | Bước 1 đọc văn bản gốc. Tên trường và nhãn là cấu hình. Nhờ kế toán của khách đầu tiên duyệt mẫu. |
| Phát hành trùng khi chạy lại | Unique `order_id` và trạng thái `issuing` có khóa. Adapter gửi mã tham chiếu idempotent (`order.prefixed_id`) nếu nhà cung cấp hỗ trợ. |
| Treo hàng đợi khi mất internet kéo dài | Backoff có trần. Báo cáo "chưa có hóa đơn" và cảnh báo trên trang trạng thái hệ thống (phase 6). |
| Lộ thông tin đăng nhập nhà cung cấp | Mã hóa cột; API chỉ ghi, không đọc lại; lọc khỏi log. |

## Tiêu chí xong

- [ ] Có ghi chú văn bản gốc NĐ 254 / TT 91; trường hóa đơn khớp ghi chú đó.
- [ ] Store chọn được loại hóa đơn; đơn complete tạo hóa đơn qua hàng đợi, không chặn complete.
- [ ] Hóa đơn có thuế suất theo dòng; phí phục vụ và dòng giờ được hỗ trợ trong builder.
- [ ] Khách tự nhập MST qua QR trên bill; thu ngân nhập được tại quầy.
- [ ] Có danh sách hóa đơn lỗi / chưa có, chạy lại được; có cảnh báo mốc 1 tỷ.
- [ ] Adapter sandbox chạy đầy đủ.
- [ ] Adapter VNPT phát hành, tra cứu và hủy được trên môi trường thử của VNPT.
- [ ] Mỗi cửa hàng chọn được nhà cung cấp trong cài đặt; nhà cung cấp chưa có adapter không hiện trong danh sách.
- [ ] Spec POS và e2e web xanh.
