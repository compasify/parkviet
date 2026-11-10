---
phase: 25
title: "Đơn từ nền tảng giao hàng (nhập tay)"
status: pending
effort: "3 ngày"
dependsOn: [9]
---

# Phase 25: Đơn từ nền tảng giao hàng (`fnb.delivery_platforms`), bản nhập tay

## Overview

Thu ngân nhập tay đơn GrabFood / ShopeeFood vào POS. Đơn có nguồn là nền tảng và đi thẳng xuống bếp với `service_mode = delivery`. Báo cáo cho thấy doanh thu, hoa hồng và tiền thực nhận theo nền tảng.

**Đã chốt 09/11/2026:** chưa có hợp đồng đối tác, và chi phí nối API ShopeeFood (khoảng 500 triệu) quá lớn ở giai đoạn này. Vì vậy phase này **chỉ làm nhập đơn tay**. Nối API (webhook, tự nhận đơn, đồng bộ thực đơn và hết món) làm sau, khi có hợp đồng; mục "Để sau" ở cuối file ghi điểm nối cho việc đó.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Đơn nền tảng **khách đã trả cho nền tảng**. Trong POS đơn vẫn đi đúng lõi: workspace → order → tender → complete. Tender là phương thức thanh toán mới `platform_receivable`, ghi khoản nền tảng nợ quán theo giá bán; khi nền tảng chuyển tiền thì đối soát. Không ghi tiền mặt, không đụng ngăn kéo. |
| Q2 | `Workspace::ORDER_SOURCES` thêm `grabfood` và `shopeefood`, nên báo cáo theo nguồn đơn hiện có tự tách được. Đơn có `service_mode = delivery`. Không dùng `Spree::Pos::Delivery` (người giao của quán), vì tài xế là của nền tảng. |
| Q3 | Nhập đơn tay gồm: nền tảng, mã đơn của nền tảng, mã lấy hàng, các món chọn từ thực đơn POS kèm modifier (phase 8), và giá theo nền tảng nếu khác giá quán. Giá ghi đè có lý do `platform_price` và có audit, không cần `Approval`. |
| Q4 | Mã đơn nền tảng là unique theo chi nhánh × nền tảng, để không nhập trùng một đơn hai lần. |
| Q5 | Hoa hồng tính theo `commission_rate` cấu hình cho từng chi nhánh × nền tảng. Thu ngân sửa được số thực tế khi đối soát. |

## Dữ liệu

- `spree_pos_platform_settings`:
  - cột `store_id`, `branch_id`, `platform` (`grabfood | shopeefood`), `commission_rate`, `status` (`active | disabled`);
  - unique `(branch_id, platform)`.
- `spree_pos_platform_orders`:
  - cột `branch_id`, `platform`, `platform_order_ref`, `pickup_code`, `workspace_id`, `status` (`accepted | ready | completed | canceled`), `gross_amount`, `commission_amount`, `net_amount`, `entered_by_id`, `settled_at`;
  - unique `(branch_id, platform, platform_order_ref)`.
- Module `fnb.delivery_platforms` đăng ký là `available`.

## Server

- `Spree::Pos::PlatformOrders::Enter` nhận đơn nhập tay:
  - tạo workspace trên quầy và ca đang mở của thu ngân, với `order_source` và `service_mode = delivery`;
  - thêm các dòng menu, ghi giá nền tảng;
  - báo bếp như đơn trả trước (phase 9);
  - in phiếu bếp có tên nền tảng và `pickup_code`, cấp số gọi (phase 10).

  Lệnh idempotent theo idempotency key và theo mã đơn.
- `MarkReady` chạy khi KDS bump xong toàn bộ đơn. `Complete` chạy khi tài xế lấy hàng: tender `platform_receivable` theo `gross_amount`, complete, rồi phát hành hóa đơn điện tử theo cấu hình (phase 7).
- `Cancel`: workspace chưa complete thì hủy. Món đã báo bếp thì đi qua luồng hủy món đã báo bếp (phase 14), với lý do "nền tảng hủy".
- `Settle`: thu ngân đánh dấu các đơn đã được nền tảng chuyển tiền, và nhập hoa hồng thực tế nếu khác.
- Công nợ nền tảng: bước 1 kiểm xem `ReceivableEntry` có ghi được đối tượng nợ không phải khách hàng không. Nếu không được, tạo một `CustomerProfile` đại diện cho từng nền tảng ở mỗi store và dùng sổ hiện có. Chọn cách nào thì ghi lại trong file này.
- Báo cáo `Spree::Pos::Reports::Platforms` theo nền tảng × ngày kinh doanh: số đơn, doanh thu gộp, hoa hồng, thực nhận, khoản chưa đối soát. Xuất CSV qua `export_file.rb` đã có.
- API dưới `api/v3/admin/pos/`: `platform_orders` (create, index, `:id/ready`, `:id/complete`, `:id/cancel`, `settle`) và `platform_settings`. Cập nhật `server/openapi/pos-staff.yaml`.

## Client web `apps/pos`

- Nút "Đơn Grab / Shopee" trên màn bán, mở form nhập đơn: chọn nền tảng, mã đơn, mã lấy hàng, chọn món từ lưới thực đơn.
- Khay "Đơn nền tảng": đơn đang làm và đơn đã sẵn sàng, bấm "Tài xế đã lấy" để complete.
- Trang đối soát: lọc đơn chưa đối soát theo nền tảng và kỳ, đánh dấu đã nhận tiền.
- Cài đặt: bật nền tảng cho chi nhánh, tỷ lệ hoa hồng.
- Báo cáo nền tảng nằm ở trang Báo cáo.
- KDS (Flutter) hiện nhãn nền tảng và `pickup_code` trên ticket.

## File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_platform_orders.rb` (settings và orders) | Tạo |
| `server/app/models/spree/pos/platform_setting.rb`, `platform_order.rb` | Tạo |
| `server/app/workflows/spree/pos/platform_orders/enter.rb`, `mark_ready.rb`, `complete.rb`, `cancel.rb`, `settle.rb` | Tạo |
| `server/app/controllers/spree/api/v3/admin/pos/platform_orders_controller.rb`, `platform_settings_controller.rb` | Tạo |
| `server/app/services/spree/pos/reports/platforms.rb` | Tạo |
| `server/app/models/spree/pos/workspace.rb` | Sửa: `ORDER_SOURCES` thêm `grabfood`, `shopeefood` |
| `server/app/models/spree/pos/pos_payment_method.rb` | Sửa: thêm loại `platform_receivable` |
| `server/config/initializers/pos_modules.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos/src/components/platform-order-form.tsx`, `platform-order-tray.tsx`, `pages/platform-settlement.tsx`, `pages/settings/delivery-platforms.tsx`, `hooks/use-platform-orders.ts` | Tạo |

## Các bước

1. Kiểm khả năng ghi công nợ cho đối tượng không phải khách hàng của `ReceivableEntry`, rồi chốt cách ghi công nợ nền tảng.
2. Viết migration, model và tender `platform_receivable`.
3. Viết `Enter`, `MarkReady`, `Complete`, `Cancel`, `Settle`. Spec phải đi hết lõi: có tender, có `ReceivedFunds`, không đụng ngăn kéo.
4. Làm báo cáo nền tảng và xuất CSV.
5. Làm API và OpenAPI, rồi UI: form nhập, khay, đối soát, cài đặt, báo cáo; thêm nhãn nền tảng trên KDS.

## Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/platform_orders/ spec/requests/spree/pos/platform_orders_spec.rb spec/services/spree/pos/reports/platforms_spec.rb`.
- Spec: cùng mã đơn nhập hai lần chỉ tạo một đơn; giá nền tảng có audit; hủy đơn đã báo bếp đi qua luồng hủy món; đối soát chỉ đổi trạng thái công nợ, không đổi doanh thu.
- E2E web: nhập đơn tay → KDS bump → tài xế lấy → complete → báo cáo nền tảng có dòng → đối soát.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Thu ngân nhập sai giá hoặc sai món | Giá nền tảng hiện cạnh giá quán khi nhập; có audit; mã đơn unique. |
| Hoa hồng thực tế khác tỷ lệ cấu hình | Sửa được khi đối soát; báo cáo tách số ước tính và số thực tế. |
| Nhập tay chậm giờ cao điểm | Form dùng chung lưới thực đơn và modifier của màn bán. Nối API là bước sau. |

## Tiêu chí xong

- [ ] Đơn nhập tay đi hết luồng nhập → bếp → sẵn sàng → hoàn tất → đối soát.
- [ ] Không nhập trùng được cùng mã đơn nền tảng.
- [ ] Báo cáo theo nền tảng có doanh thu gộp, hoa hồng, thực nhận và khoản chưa đối soát.
- [ ] Spec và e2e xanh; OpenAPI đã cập nhật.

## Để sau: nối API nền tảng

Làm khi có hợp đồng đối tác và chấp nhận được chi phí. Phần cần thêm:
- interface `Spree::Pos::DeliveryPlatforms::Adapter` (`verify_webhook`, `parse_order`, `accept`, `reject`, `mark_ready`, `sync_availability`);
- webhook công khai `POST api/v3/pos_platforms/:platform/webhook`, cần địa chỉ công khai: VPS hoặc tunnel của phase 6;
- tự nhận đơn và ánh xạ món nền tảng sang thực đơn POS;
- đồng bộ hết món qua `menu.sold_out`.

Workflow `Enter` của phase này là điểm vào chung: đơn từ webhook sẽ gọi cùng workflow đó, nên phần nhập tay không phải sửa.
