---
phase: 22
title: "QR order tại bàn"
status: pending
effort: "7 ngày"
dependsOn: [16]
---

# Phase 22: QR order tại bàn (S6)

## Overview

Khách quét QR dán trên bàn hoặc trong phòng karaoke, xem thực đơn trên điện thoại (web, không cài app), chọn món kèm modifier, gửi đơn, gọi phục vụ và yêu cầu thanh toán. Đơn của khách là **đơn chờ**: chỉ khi phục vụ / thu ngân duyệt (hoặc chi nhánh bật chế độ gửi thẳng) thì các dòng mới nhập vào workspace của bàn và báo bếp. Khách không bao giờ ghi trực tiếp vào workspace, không thu tiền trên bề mặt này (D7).

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | **Vị trí: app Vite nhẹ `apps/table-order`**, build ra file tĩnh và được chính server Rails phục vụ dưới `/table/` (cùng origin với API). Không dùng storefront Next.js. Lý do: (1) server LAN tại quán (D5) không chạy thêm tiến trình Node; một thư mục tĩnh là đủ; (2) cùng origin nên không cần CORS và QR chỉ cần một URL; (3) storefront là site bán hàng online theo store, có giỏ hàng / checkout Spree, trái mô hình "đơn chờ gắn bàn"; (4) bundle nhỏ (React + i18n, không SSR) tải nhanh trên 3G. |
| Q2 | QR in trên bàn chứa **mã bàn cố định** (`table_code`, token ngẫu nhiên 128 bit, xoay được khi lộ). Mã bàn không cho đặt món; nó chỉ mở được **phiên khách** khi bàn đang mở (có workspace `dine_in` / `timed` đang chạy). Bàn trống thì trang hiện thực đơn chỉ xem và nút "Gọi phục vụ". |
| Q3 | Phiên khách (`GuestSession`) hết hạn khi workspace của bàn complete / cancel, hoặc sau 4 giờ. Mỗi lần bàn mở lại thì phiên cũ vô hiệu, nên ảnh chụp QR của khách trước không đặt món được cho khách sau. |
| Q4 | Hai chế độ theo chi nhánh: `staff_approval` (mặc định) và `direct_to_kitchen`. Chế độ thẳng bếp vẫn tạo đơn chờ, nhưng duyệt tự động bằng danh tính thiết bị hệ thống và có giới hạn giá trị / số món mỗi lần (vượt thì quay về chờ duyệt). |
| Q5 | Xác thực kiểu `DisplayViewsController`: controller riêng kế thừa `ActionController::API`, header `Authorization: Guest <token>` (không đặt token trong URL sau lần đổi đầu tiên), `no_store`, rate limit theo địa chỉ client cho lệnh mở phiên và theo phiên cho lệnh gửi đơn. Không bao giờ nhận JWT nhân viên hay API key. |
| Q6 | Module mới `fnb.qr_order` (đã có trong research §5.2), phụ thuộc `fnb.menu`, `fnb.tables`. Feature flag mới `qr_order` mặc định tắt. |

## Dữ liệu

- `spree_pos_table_codes`: `store_id`, `branch_id`, `resource_id` (unique khi active), `token_digest` (SHA-256), `status` (`active` | `revoked`), `rotated_at`. Token gốc chỉ hiện một lần khi in QR.
- `spree_pos_guest_sessions`: `table_code_id`, `workspace_id`, `token_digest`, `expires_at`, `client_fingerprint_digest`, `revoked_at`. Một bàn có nhiều phiên (nhiều điện thoại), tất cả gắn cùng workspace.
- `spree_pos_guest_orders`: `guest_session_id`, `workspace_id`, `status` (`pending` | `accepted` | `rejected` | `expired`), `items` jsonb (variant prefixed id, quantity, modifier option ids, note), `quoted_total`, `idempotency_key` (unique theo phiên), `decided_by_id`, `decided_at`, `reject_reason`.
- `spree_pos_guest_requests`: `guest_session_id`, `kind` (`call_staff` | `request_bill`), `status` (`open` | `done`), `handled_by_id`.
- Cấu hình chi nhánh: `qr_order_mode` (`staff_approval` | `direct_to_kitchen`), `qr_order_auto_limit` (số tiền tối đa duyệt tự động).

## Server

- Namespace công khai `api/v3/pos_guest/`, controller `Spree::Pos::GuestViewsController`:
  - `POST session` (body: `table_code`) → phiên khách hoặc trạng thái "bàn chưa mở"; rate limit 10 / phút / địa chỉ.
  - `GET menu` → thực đơn của chi nhánh dùng lại serializer thực đơn của phase 8, kèm trạng thái hết món; chỉ món có cờ "cho phép QR".
  - `GET order` → các dòng đã có trên bàn (chỉ tên, số lượng, trạng thái bếp, tạm tính; không lộ tên nhân viên, giảm giá thủ công).
  - `POST guest_orders` (Idempotency-Key bắt buộc) → đơn chờ. Server tính lại giá từ thực đơn; giá client gửi lên bị bỏ qua.
  - `POST requests` → gọi phục vụ / yêu cầu thanh toán; một yêu cầu mở mỗi loại mỗi phiên.
- Workflow `Spree::Pos::GuestOrders::Submit`, `Accept`, `Reject`. `Accept` chạy dưới danh tính nhân viên duyệt qua `CommandExecutor`, gọi đúng lệnh thêm dòng menu của phase 8 / 14 (thêm dòng không cần lease), rồi báo bếp theo phần chênh lệch (phase 14). Nếu món đã hết giữa lúc khách gửi và lúc duyệt, `Accept` từ chối từng dòng đó và ghi lý do.
- Endpoint nhân viên `api/v3/admin/pos/guest_orders` (index theo chi nhánh, accept, reject) và `guest_requests` (index, done). Quyền mới `pos.guest_order.decide`.
- Realtime: phát `guest_order.created`, `guest_request.created` trên `BranchChannel` (sự kiện mới, cần thêm vào danh sách của phase 3). Thông báo phục vụ trên app Flutter và thu ngân.
- `AuditEntry`: `guest_order.accept`, `guest_order.reject`, `table_code.rotate`.
- Phục vụ file tĩnh: `public/table/` (build của `apps/table-order`) với fallback route `/table/*` về `index.html`.

## Client web `apps/table-order`

- Vite + React 19 + TypeScript, i18n vi / en (mặc định vi), không router nặng: 4 màn (Thực đơn, Món + modifier, Giỏ, Bàn của tôi).
- Đọc `table_code` từ URL lần đầu (`/table/t/<code>`), đổi lấy token phiên, lưu token trong `sessionStorage`, rồi `history.replaceState` xóa mã khỏi thanh địa chỉ.
- Bảng modifier dùng lại quy tắc min / max / bắt buộc của phase 8 (port logic thuần TS sang file chung `apps/table-order/src/lib/modifiers.ts`; không import từ `apps/pos` để giữ bundle nhỏ).
- Trạng thái đơn: "Đang chờ xác nhận", "Đã gửi bếp", "Bị từ chối: <lý do>". Poll 5 giây (khách không vào `BranchChannel`).
- Karaoke: QR trong phòng dùng cùng app; thực đơn ẩn món không thuộc phòng; nút "Yêu cầu thanh toán" ghi rõ tiền giờ tính đến lúc thanh toán.

## Client nhân viên

- `apps/pos`: khay "Đơn từ QR" trên màn bàn / bảng phòng, badge số đơn chờ, mở đơn xem từng dòng, Duyệt / Từ chối kèm lý do; trang cài đặt chi nhánh có chế độ QR, hạn mức tự duyệt, in lại / xoay QR từng bàn (in qua hàng đợi in, loại phiếu mới `table_qr`).
- Flutter chế độ `waiter`: danh sách đơn chờ và yêu cầu gọi phục vụ của khu mình phụ trách, duyệt ngay trên điện thoại.

## File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_table_codes.rb`, `*_guest_sessions.rb`, `*_guest_orders.rb`, `*_guest_requests.rb` | Tạo |
| `server/app/models/spree/pos/table_code.rb`, `guest_session.rb`, `guest_order.rb`, `guest_request.rb` | Tạo |
| `server/app/controllers/spree/pos/guest_views_controller.rb` | Tạo |
| `server/app/controllers/spree/api/v3/admin/pos/guest_orders_controller.rb`, `guest_requests_controller.rb`, `table_codes_controller.rb` | Tạo |
| `server/app/workflows/spree/pos/guest_orders/submit.rb`, `accept.rb`, `reject.rb` | Tạo |
| `server/config/routes.rb` | Sửa: route `pos_guest` cạnh `pos_display`, route tĩnh `/table` |
| `server/config/initializers/pos_modules.rb`, `server/app/models/spree/pos/feature_flag.rb`, `capabilities.rb` | Sửa |
| `server/openapi/pos-staff.yaml` | Sửa: endpoint nhân viên; thêm `server/openapi/pos-guest.yaml` cho API khách |
| `apps/table-order/` | Tạo app mới |
| `apps/pos/src/components/guest-order-tray.tsx`, `hooks/use-guest-orders.ts` | Tạo |
| `apps/pos-staff/lib/features/waiter/guest_orders/` | Tạo |

## Các bước

1. Migration + model + spec model (hết hạn phiên, unique bàn active, idempotency theo phiên).
2. `GuestViewsController` với xác thực `Guest`, rate limit, `no_store`; request spec cho từng lỗi (`table_closed`, `session_expired`, `item_sold_out`, `rate_limited`).
3. Workflow Submit / Accept / Reject; spec khẳng định giá tính lại ở server và `Accept` đi qua lệnh thêm dòng thường.
4. Endpoint nhân viên, quyền, audit, realtime; cập nhật OpenAPI.
5. Dựng `apps/table-order`, build vào `server/public/table/`, thêm script build vào CI.
6. Khay đơn chờ trên `apps/pos` và màn duyệt trên Flutter.
7. Mẫu in QR bàn qua hàng đợi in; xoay mã.

## Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/guest_views_spec.rb spec/workflows/spree/pos/guest_orders/`.
- Spec bảo mật: token khách không gọi được bất kỳ endpoint `admin/pos`; JWT nhân viên bị từ chối ở `pos_guest`; phiên của lần mở bàn trước bị từ chối.
- `apps/table-order`: vitest cho logic modifier và giỏ; Playwright: quét QR → gửi → thu ngân duyệt → dòng hiện trong workspace và KDS.
- `pnpm --dir apps/pos test:e2e` cho khay đơn chờ.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Khách ngoài quán dùng ảnh QR để đặt bừa | Phiên chỉ mở khi bàn đang có workspace; phiên chết khi bàn đóng; mặc định cần nhân viên duyệt. |
| Spam đơn | Rate limit theo phiên và theo địa chỉ; tối đa 3 đơn chờ mỗi phiên. |
| Chế độ thẳng bếp gửi món sai | Hạn mức tự duyệt; nhân viên vẫn hủy được theo luồng hủy món đã báo bếp (có `Approval`). |
| Server LAN không có tên miền công khai | QR trỏ địa chỉ LAN của server (phase 6); khách phải vào Wi-Fi quán. Ghi rõ trên mẫu in QR. Với VPS dùng tên miền thật. |

## Tiêu chí xong

- [ ] Khách quét QR bàn đang mở, gửi đơn, nhân viên duyệt trên web hoặc Flutter, món xuống KDS đúng trạm.
- [ ] Bàn đóng thì mọi phiên khách của bàn đó bị từ chối.
- [ ] Chế độ thẳng bếp hoạt động trong hạn mức, vượt hạn mức chuyển sang chờ duyệt.
- [ ] Gọi phục vụ / yêu cầu thanh toán hiện realtime ở S1 và S2.
- [ ] Request spec, vitest, e2e xanh; OpenAPI cập nhật.
