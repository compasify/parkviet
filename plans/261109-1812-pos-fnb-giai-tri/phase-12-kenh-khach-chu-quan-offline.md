---
phase: 12
title: "Kênh khách, chủ quán, offline"
status: in-progress
effort: "23 ngày"
dependsOn: [3, 5, 8]
---

# Phase 12: Kênh khách, chủ quán, offline

## Overview

Bốn phần là các kênh mở rộng của đợt F5, ít đụng file của nhau: QR order, kiosk, app chủ quán, và hàng đợi offline của thu ngân.

| Phần | Nội dung | Effort |
|---|---|---|
| 12A | QR order tại bàn | 7 ngày |
| 12B | Kiosk tự order | 5 ngày |
| 12C | App chủ quán | 5 ngày |
| 12D | Hàng đợi offline cho thu ngân | 6 ngày |

## Cách làm

- Làm các phần theo thứ tự trên. Xong phần nào thì chạy test hẹp của phần đó rồi mới sang phần sau.
- Review và full suite chạy một lần khi xong cả plan, như mục "Cách chạy" của [plan.md](./plan.md).
- Mục kiểm thử trong từng phần liệt kê lệnh để chạy khi đang làm phần đó.

## Phần 12A: QR order tại bàn

### Overview

Khách quét QR dán trên bàn hoặc trong phòng karaoke, xem thực đơn trên điện thoại (web, không cài app), chọn món kèm modifier, gửi đơn, gọi phục vụ và yêu cầu thanh toán. Đơn của khách là **đơn chờ**: chỉ khi phục vụ / thu ngân duyệt (hoặc chi nhánh bật chế độ gửi thẳng) thì các dòng mới nhập vào workspace của bàn và báo bếp. Khách không bao giờ ghi trực tiếp vào workspace, không thu tiền trên bề mặt này (D7).

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | **Vị trí: app Vite nhẹ `apps/table-order`**, build ra file tĩnh và được chính server Rails phục vụ dưới `/table/` (cùng origin với API). Không dùng storefront Next.js. Lý do: (1) server LAN tại quán (D5) không chạy thêm tiến trình Node; một thư mục tĩnh là đủ; (2) cùng origin nên không cần CORS và QR chỉ cần một URL; (3) storefront là site bán hàng online theo store, có giỏ hàng / checkout Spree, trái mô hình "đơn chờ gắn bàn"; (4) bundle nhỏ (React + i18n, không SSR) tải nhanh trên 3G. |
| Q2 | QR in trên bàn chứa **mã bàn cố định** (`table_code`, token ngẫu nhiên 128 bit, xoay được khi lộ). Mã bàn không cho đặt món; nó chỉ mở được **phiên khách** khi bàn đang mở (có workspace `dine_in` / `timed` đang chạy). Bàn trống thì trang hiện thực đơn chỉ xem và nút "Gọi phục vụ". |
| Q3 | Phiên khách (`GuestSession`) hết hạn khi workspace của bàn complete / cancel, hoặc sau 4 giờ. Mỗi lần bàn mở lại thì phiên cũ vô hiệu, nên ảnh chụp QR của khách trước không đặt món được cho khách sau. |
| Q4 | Hai chế độ theo chi nhánh: `staff_approval` (mặc định) và `direct_to_kitchen`. Chế độ thẳng bếp vẫn tạo đơn chờ, nhưng duyệt tự động bằng danh tính thiết bị hệ thống và có giới hạn giá trị / số món mỗi lần (vượt thì quay về chờ duyệt). |
| Q5 | Xác thực kiểu `DisplayViewsController`: controller riêng kế thừa `ActionController::API`, header `Authorization: Guest <token>` (không đặt token trong URL sau lần đổi đầu tiên), `no_store`, rate limit theo địa chỉ client cho lệnh mở phiên và theo phiên cho lệnh gửi đơn. Không bao giờ nhận JWT nhân viên hay API key. |
| Q6 | Module mới `fnb.qr_order` (đã có trong research §5.2), phụ thuộc `fnb.menu`, `fnb.tables`. Feature flag mới `qr_order` mặc định tắt. |

### Dữ liệu

- `spree_pos_table_codes`: `store_id`, `branch_id`, `resource_id` (unique khi active), `token_digest` (SHA-256), `status` (`active` | `revoked`), `rotated_at`. Token gốc chỉ hiện một lần khi in QR.
- `spree_pos_guest_sessions`: `table_code_id`, `workspace_id`, `token_digest`, `expires_at`, `client_fingerprint_digest`, `revoked_at`. Một bàn có nhiều phiên (nhiều điện thoại), tất cả gắn cùng workspace.
- `spree_pos_guest_orders`: `guest_session_id`, `workspace_id`, `status` (`pending` | `accepted` | `rejected` | `expired`), `items` jsonb (variant prefixed id, quantity, modifier option ids, note), `quoted_total`, `idempotency_key` (unique theo phiên), `decided_by_id`, `decided_at`, `reject_reason`.
- `spree_pos_guest_requests`: `guest_session_id`, `kind` (`call_staff` | `request_bill`), `status` (`open` | `done`), `handled_by_id`.
- Cấu hình chi nhánh: `qr_order_mode` (`staff_approval` | `direct_to_kitchen`), `qr_order_auto_limit` (số tiền tối đa duyệt tự động).

### Server

- Namespace công khai `api/v3/pos_guest/`, controller `Spree::Pos::GuestViewsController`:
  - `POST session` (body: `table_code`) → phiên khách hoặc trạng thái "bàn chưa mở"; rate limit 10 / phút / địa chỉ.
  - `GET menu` → thực đơn của chi nhánh dùng lại serializer thực đơn của phần 6A, kèm trạng thái hết món; chỉ món có cờ "cho phép QR".
  - `GET order` → các dòng đã có trên bàn (chỉ tên, số lượng, trạng thái bếp, tạm tính; không lộ tên nhân viên, giảm giá thủ công).
  - `POST guest_orders` (Idempotency-Key bắt buộc) → đơn chờ. Server tính lại giá từ thực đơn; giá client gửi lên bị bỏ qua.
  - `POST requests` → gọi phục vụ / yêu cầu thanh toán; một yêu cầu mở mỗi loại mỗi phiên.
- Workflow `Spree::Pos::GuestOrders::Submit`, `Accept`, `Reject`. `Accept` chạy dưới danh tính nhân viên duyệt qua `CommandExecutor`, gọi đúng lệnh thêm dòng menu của phần 6A / 8B (thêm dòng không cần lease), rồi báo bếp theo phần chênh lệch (phần 8B). Nếu món đã hết giữa lúc khách gửi và lúc duyệt, `Accept` từ chối từng dòng đó và ghi lý do.
- Endpoint nhân viên `api/v3/admin/pos/guest_orders` (index theo chi nhánh, accept, reject) và `guest_requests` (index, done). Quyền mới `pos.guest_order.decide`.
- Realtime: phát `guest_order.created`, `guest_request.created` trên `BranchChannel` (sự kiện mới, cần thêm vào danh sách của phase 3). Thông báo phục vụ trên app Flutter và thu ngân.
- `AuditEntry`: `guest_order.accept`, `guest_order.reject`, `table_code.rotate`.
- Phục vụ file tĩnh: `public/table/` (build của `apps/table-order`) với fallback route `/table/*` về `index.html`.

### Client web `apps/table-order`

- Vite + React 19 + TypeScript, i18n vi / en (mặc định vi), không router nặng: 4 màn (Thực đơn, Món + modifier, Giỏ, Bàn của tôi).
- Đọc `table_code` từ URL lần đầu (`/table/t/<code>`), đổi lấy token phiên, lưu token trong `sessionStorage`, rồi `history.replaceState` xóa mã khỏi thanh địa chỉ.
- Bảng modifier dùng lại quy tắc min / max / bắt buộc của phần 6A (port logic thuần TS sang file chung `apps/table-order/src/lib/modifiers.ts`; không import từ `apps/pos` để giữ bundle nhỏ).
- Trạng thái đơn: "Đang chờ xác nhận", "Đã gửi bếp", "Bị từ chối: <lý do>". Poll 5 giây (khách không vào `BranchChannel`).
- Karaoke: QR trong phòng dùng cùng app; thực đơn ẩn món không thuộc phòng; nút "Yêu cầu thanh toán" ghi rõ tiền giờ tính đến lúc thanh toán.

### Client nhân viên

- `apps/pos`: khay "Đơn từ QR" trên màn bàn / bảng phòng, badge số đơn chờ, mở đơn xem từng dòng, Duyệt / Từ chối kèm lý do; trang cài đặt chi nhánh có chế độ QR, hạn mức tự duyệt, in lại / xoay QR từng bàn (in qua hàng đợi in, loại phiếu mới `table_qr`).
- Flutter chế độ `waiter`: danh sách đơn chờ và yêu cầu gọi phục vụ của khu mình phụ trách, duyệt ngay trên điện thoại.

### File

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

### Các bước

1. Migration + model + spec model (hết hạn phiên, unique bàn active, idempotency theo phiên).
2. `GuestViewsController` với xác thực `Guest`, rate limit, `no_store`; request spec cho từng lỗi (`table_closed`, `session_expired`, `item_sold_out`, `rate_limited`).
3. Workflow Submit / Accept / Reject; spec khẳng định giá tính lại ở server và `Accept` đi qua lệnh thêm dòng thường.
4. Endpoint nhân viên, quyền, audit, realtime; cập nhật OpenAPI.
5. Dựng `apps/table-order`, build vào `server/public/table/`, thêm script build vào CI.
6. Khay đơn chờ trên `apps/pos` và màn duyệt trên Flutter.
7. Mẫu in QR bàn qua hàng đợi in; xoay mã.

### Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/guest_views_spec.rb spec/workflows/spree/pos/guest_orders/`.
- Spec bảo mật: token khách không gọi được bất kỳ endpoint `admin/pos`; JWT nhân viên bị từ chối ở `pos_guest`; phiên của lần mở bàn trước bị từ chối.
- `apps/table-order`: vitest cho logic modifier và giỏ; Playwright: quét QR → gửi → thu ngân duyệt → dòng hiện trong workspace và KDS.
- `pnpm --dir apps/pos test:e2e` cho khay đơn chờ.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Khách ngoài quán dùng ảnh QR để đặt bừa | Phiên chỉ mở khi bàn đang có workspace; phiên chết khi bàn đóng; mặc định cần nhân viên duyệt. |
| Spam đơn | Rate limit theo phiên và theo địa chỉ; tối đa 3 đơn chờ mỗi phiên. |
| Chế độ thẳng bếp gửi món sai | Hạn mức tự duyệt; nhân viên vẫn hủy được theo luồng hủy món đã báo bếp (có `Approval`). |
| Server LAN không có tên miền công khai | QR trỏ địa chỉ LAN của server (phần 5B); khách phải vào Wi-Fi quán. Ghi rõ trên mẫu in QR. Với VPS dùng tên miền thật. |

### Tiêu chí xong

- [x] Khách quét QR bàn đang mở, gửi đơn, nhân viên duyệt trên web hoặc Flutter, món xuống KDS đúng trạm.
- [x] Bàn đóng thì mọi phiên khách của bàn đó bị từ chối.
- [x] Chế độ thẳng bếp hoạt động trong hạn mức, vượt hạn mức chuyển sang chờ duyệt.
- [x] Gọi phục vụ / yêu cầu thanh toán hiện realtime ở S1 và S2.
- [ ] Request spec, vitest, e2e xanh; OpenAPI cập nhật.

### Kết quả

Trạng thái: xong phần lớn. Tiêu chí cuối còn mở vì e2e của `apps/pos-dashboard` chưa chạy được trên máy này, và chưa có script build CI cho `apps/table-order` (xem "Còn mở").

**Đã làm**

- Server:
  - Migration `20261112110000`–`20261112110400`: bốn bảng `spree_pos_table_codes`, `spree_pos_guest_sessions`, `spree_pos_guest_orders`, `spree_pos_guest_requests`, và cấu hình QR trong `table_settings`: `qr_order_mode`, `qr_order_auto_limit`, `qr_order_auto_max_items`. Check constraint giữ trong `schema.rb`.
  - Model `TableCode`, `GuestSession`, `GuestOrder`, `GuestRequest`. Mỗi bàn chỉ có một mã active. Token chỉ lưu digest SHA-256. Phiên hết hạn sau 4 giờ, khi đơn bàn đóng, hoặc khi xoay mã. Idempotency key unique theo phiên. Tối đa 3 đơn chờ mỗi phiên.
  - API khách `Spree::Pos::GuestViewsController`:
    - xác thực `Authorization: Guest <token>`, header `no_store`;
    - rate limit: mở phiên 10/phút/địa chỉ, gửi đơn 5/phút/phiên, yêu cầu 10/phút/phiên;
    - không nhận JWT nhân viên hay API key;
    - đóng khi tắt module hoặc cờ;
    - thực đơn chỉ gồm món `qr_orderable`, kèm trạng thái hết món;
    - phần "Bàn của tôi" không lộ tên nhân viên hay giảm giá;
    - giá do server tính lại.
  - Workflow:
    - `GuestOrders::Submit`, `Accept`, `Reject`, `Guard`: `Accept` đi qua lệnh thêm dòng thường và `CommandExecutor` dưới danh tính người duyệt, báo bếp phần chênh lệch, bỏ dòng hết món giữa chừng, từ chối khi không còn dòng;
    - `GuestSessions::Open`, `GuestRequests::Create` / `Done`;
    - `TableCodes::Issue`: tạo / xoay mã, in tem qua hàng đợi in, loại phiếu mới `table_qr`.
  - Endpoint nhân viên `admin/pos/guest_orders` (index, accept, reject), `guest_requests` (index, done), `table_codes` (index, issue).
  - Quyền mới `pos.guest_order.decide`. Module `fnb.qr_order`, cờ `qr_order` (mặc định tắt).
  - Audit `guest_order.accept` / `reject` và `table_code.rotate`. Realtime `guest_order.created` / `updated`, `guest_request.created` / `updated`.
  - OpenAPI: sửa `server/openapi/pos-staff.yaml`, thêm `server/openapi/pos-guest.yaml`.
- `apps/table-order` (mới): Vite + React 19, i18n vi / en, 4 màn (Thực đơn, Món + modifier, Giỏ, Bàn của tôi).
  - Đọc mã từ `/table/t/<code>` rồi `replaceState` xóa khỏi thanh địa chỉ. Token trong `sessionStorage`. Mã bị quên ngay khi phiên đã đặt món, nên điện thoại rời bàn không âm thầm vào đơn của khách sau.
  - Poll 5 giây. Modifier min / max / bắt buộc port sang `src/lib/modifiers.ts`. Giỏ không gửi giá. Idempotency key giữ theo giỏ khi gửi lại.
  - Server Rails phục vụ dưới `/table/` (`TableOrderAppController`, `Referrer-Policy: no-referrer`). `server/Dockerfile` build app này cùng `apps/pos` và `apps/pos-dashboard`.
- `apps/pos`: khay "Đơn từ QR" trên màn bán, có badge số đơn chờ. Duyệt / Từ chối kèm lý do mẫu, đóng yêu cầu gọi phục vụ / thanh toán. Sự kiện realtime làm mới khay.
- `apps/pos-dashboard`: phần "Gọi món qua QR" trong tab Sơ đồ bàn: chế độ, hạn mức tiền, số món tối đa. Thẻ "Mã QR tại bàn": tạo / xoay mã, in tem, hiện QR và đường dẫn một lần. Cờ "Khách được gọi món này qua QR tại bàn" trong trang Thực đơn. Quyền mới trong nhóm bán hàng.
- `packages/pos-shared`: capability, feature `qr_order`, nhãn module `fnb.qr_order`.
- `apps/pos-staff` (Flutter, chế độ waiter): sinh lại `pos_api`. `GuestInbox` nghe sự kiện khách và rung khi có đơn / yêu cầu mới. Màn "Đơn từ QR" lọc khu mình / mọi khu, duyệt, từ chối kèm lý do, đóng yêu cầu. Nút có badge trên bảng bàn.
- Docs: mục "Khách gọi món qua QR trên bàn" trong [`docs/pos/fnb-ban-va-tra-sau.md`](../../docs/pos/fnb-ban-va-tra-sau.md). Đường `/table/` và yêu cầu Wi‑Fi quán trong [`docs/deploy/pos-lan-vps.md`](../../docs/deploy/pos-lan-vps.md).

**Lệnh và kết quả**

- `pnpm spree rspec` với spec model `guest_session`, `spec/workflows/spree/pos/guest_orders/` và `spec/requests/spree/pos/guest_views_spec.rb`, cùng các spec module / profile / onboarding / topology / devices / print_documents / authentication / feature_flags / realtime / web_apps / table_settings / menu: 180 examples, 0 failures. Chạy riêng `web_apps_spec.rb`: 7/0.
- `packages/pos-shared`: typecheck, lint ok; vitest 284 passed.
- `apps/pos-dashboard`: typecheck, lint ok; test 131 passed; build ok.
- `apps/pos`:
  - typecheck, lint ok; test 318 passed;
  - `pnpm --dir apps/pos exec playwright test e2e/guest-orders.spec.ts e2e/platform-orders.spec.ts --project desktop`: 2 passed;
  - e2e feature-flags, branch-modules, realtime, tables, karaoke (desktop): 16 passed.
- `apps/table-order`: typecheck, lint ok; vitest 14 passed; Playwright `--project mobile` 4 passed, `--project desktop` 4 passed; build ok (~95 KB gzip JS).
- `apps/pos-staff`: `tool/gen_api.sh` ok; `flutter analyze` không lỗi; `flutter test` 156 passed (gồm 4 test mới ở `test/modes/waiter/guest_orders_test.dart`).

**Lệch so với plan**

- Thẳng bếp duyệt tự động dưới danh tính chủ ca của workspace bàn, không dùng "thiết bị hệ thống" (chưa có danh tính đó). Audit ghi là tự động. Hạn mức gồm cả số món tối đa (`qr_order_auto_max_items`).
- Thêm sự kiện `.updated` cho đơn / yêu cầu khách, để các màn nhân viên bỏ đơn đã được người khác xử lý.
- Bàn chưa mở thì vẫn mở phiên "chỉ xem thực đơn". Trang có nút thử lại bằng mã đã lưu, thay vì bắt quét lại. Phiên gắn với đơn bàn mở sớm nhất.
- Cài đặt QR và in / xoay mã nằm trong `apps/pos-dashboard` (tab Sơ đồ bàn), không ở `apps/pos`, theo quy ước dự án: cài đặt chi nhánh không quay lại màn bán.
- SPA phục vụ từ thư mục do `TABLE_ORDER_DIST_PATH` chỉ (image đặt sẵn), không phải `server/public/table/`, giống `/pos` và `/pos-admin`.
- "In lại" là xoay mã: token gốc không được lưu, nên không in lại được tem cũ.
- Token mã bàn có trong access log của lần mở `/table/t/<code>` đầu tiên.
- Karaoke dùng cờ `qr_orderable` của món, không có thực đơn riêng theo phòng.
- `request_bill` chỉ báo nhân viên, không tạo PaymentRequest. Khách không trả tiền qua QR (D7).
- Code Flutter ở `lib/modes/waiter/guest_orders/` (theo cấu trúc hiện có), không phải `lib/features/waiter/guest_orders/`. Đã chạy `flutter gen-l10n` cho chuỗi mới.
- API khách chỉ mở khi cả module `fnb.qr_order` lẫn cờ `qr_order` đều bật.

**Còn mở**

- E2e `apps/pos-dashboard` (`administration.spec.ts` đổi số checkbox thành 37) chưa chạy được: cổng 5176 đang dùng cho dev server. Chờ CI.
- Chưa thêm script build `apps/table-order` vào workflow CI (`.github/` ngoài phạm vi sửa). Image Docker đã build app này.
- Playwright đầu-cuối trên API thật (quét QR → thu ngân duyệt → dòng hiện trong workspace và KDS) chưa có. Luồng này hiện chỉ được request spec `guest_views_spec.rb` phủ. E2e của `apps/table-order` và `apps/pos` dùng fixture.
- Bảng dự án trong `AGENTS.md` ở gốc chưa có dòng `apps/table-order` (không sửa file gốc). App có `apps/table-order/AGENTS.md` riêng.
- Thử trên điện thoại thật, máy in tem thật và pilot tại quán.
- Full suite rspec / e2e chạy trên CI.

## Phần 12B: Kiosk tự order

### Overview

Một tablet hoặc màn đứng chạy app Flutter ở chế độ `kiosk`. Khách tự chọn món và modifier, trả bằng VietQR hoặc chọn "Trả tại quầy", rồi nhận số gọi in qua trạm in. Đây là ngoại lệ có kiểm soát của D7: kiosk được hoàn tất đơn **chỉ khi** webhook VietQR đã khớp; mọi trường hợp khác đều để thu ngân xử lý.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Mỗi kiosk là một `Device` mode `kiosk`, gắn **một quầy (`Register`) riêng** loại kiosk. Lõi hiện chỉ cho một ca mở mỗi quầy (`Shift#one_open_shift`) và ca phải có `owner` là nhân viên, nên kiosk không tự mở ca. Quản lý mở **ca kiosk** cho quầy kiosk (owner là quản lý), ca không có tiền mặt (`opening_float = 0`, không nhận tender tiền mặt). Kiosk từ chối nhận đơn khi quầy của nó không có ca mở và hiện "Tạm ngưng". |
| Q2 | Lệnh của kiosk chạy dưới **tài khoản dịch vụ của thiết bị**: mỗi kiosk có một `StaffMembership` hệ thống (cờ `service_account: true`), chỉ có các quyền: tạo workspace, thêm dòng menu, chuẩn bị và xác nhận tender VietQR có bằng chứng webhook, park. Không có quyền giảm giá, sửa giá, tiền mặt, hủy, trả hàng. `AuditEntry` ghi actor là tài khoản này kèm `device_id`. |
| Q3 | Xác nhận VietQR từ kiosk chỉ chấp nhận `evidence_kind = vietqr_webhook` (đã có trong `VietqrTender::EVIDENCE_KINDS`). `vietqr_manual` bị chặn cho tài khoản dịch vụ. Hết hạn QR mà chưa khớp thì hủy tender, giải phóng QR, và đơn chuyển sang "trả tại quầy". |
| Q4 | "Trả tại quầy": kiosk park workspace (`ChangeStatus` park) kèm số gọi và chuyển nó sang ca của quầy thu ngân khi thu ngân mở đơn (dùng `ShiftRebind` đã có cho draft chưa có tiền). Bếp **chưa nhận** món cho tới khi thu ngân thu tiền, trừ khi chi nhánh bật "báo bếp trước khi trả" (mặc định tắt). |
| Q5 | Khóa máy: Android dùng **lock task mode** (Device Owner qua QR provisioning, hoặc screen pinning nếu không có Device Owner); iOS dùng **Guided Access**, app hướng dẫn bật và kiểm tra `UIAccessibility.isGuidedAccessEnabled`, hiện cảnh báo cho quản lý nếu tắt. Thoát chế độ kiosk cần PIN quản lý. |
| Q6 | Module `fnb.kiosk` (research §5.2), phụ thuộc `fnb.menu`, `fnb.order_number`; feature `vietqr` phải bật để kiosk nhận trả QR. |

### Dữ liệu

- `spree_pos_registers`: thêm `kind` (`counter` | `kiosk`, mặc định `counter`).
- `spree_pos_staff_memberships`: thêm `service_account` (boolean, mặc định false) và `device_id` (optional). Tài khoản dịch vụ không đăng nhập bằng mật khẩu / PIN; chỉ dùng qua credential thiết bị.
- `spree_pos_workspaces`: dùng `order_source = 'kiosk'` (thêm vào `Workspace::ORDER_SOURCES`) để báo cáo theo nguồn đã có (`Reports::Sales#by_source`) tách được doanh thu kiosk.
- Cấu hình chi nhánh: `kiosk_idle_seconds` (mặc định 60), `kiosk_kitchen_before_payment` (mặc định false), `kiosk_qr_timeout_seconds` (mặc định 180).

### Server

- `Spree::Pos::Kiosks::Provision`: khi ghép thiết bị mode `kiosk` (phase 2), tạo tài khoản dịch vụ và gắn quầy kiosk; thu hồi thiết bị thì vô hiệu tài khoản.
- `Spree::Pos::Kiosks::Policy`: chặn mọi lệnh ngoài danh sách cho actor là tài khoản dịch vụ (kiểm trong `AccessPolicy`), kể cả khi capability bị gán nhầm.
- Luồng thanh toán QR: kiosk gọi `tenders/prepare` như thu ngân; kiosk nghe `workspace.updated` trên `BranchChannel` (hoặc poll 2 giây) để biết webhook đã khớp; khi `VietqrTender.summary` báo đã nhận, kiosk gọi `tenders/confirm` với evidence webhook, rồi `complete`. Sau complete: cấp số gọi (phần 7B), tạo `PrintJob` loại `receipt` cho trạm in gắn quầy kiosk, gửi bếp như đơn trả trước (phần 7A).
- Endpoint `GET api/v3/admin/pos/kiosk/state`: ca có mở không, thực đơn đang bán, cấu hình idle.
- Đơn kiosk park chưa trả quá 30 phút: job đánh dấu và hiện cho thu ngân "Đơn kiosk bỏ dở" để hủy.

### Flutter (`apps/pos-staff`, chế độ `kiosk`)

- Luồng màn: Chào → Danh mục / lưới món ảnh lớn → Modifier (dùng lại widget modifier của chế độ phục vụ) → Giỏ → Chọn cách trả (QR / Tại quầy) → QR đếm ngược → Thành công kèm số gọi lớn → tự quay về Chào.
- Idle reset: không chạm sau `kiosk_idle_seconds` thì hỏi "Bạn còn đó không?" 10 giây rồi xóa giỏ; workspace chưa có tender thì cancel.
- Trợ năng: chữ tối thiểu 20 sp, vùng chạm ≥ 64 dp, tương phản AA, hỗ trợ TalkBack / VoiceOver nhãn đầy đủ, chế độ "với tới thấp" dồn nút xuống nửa dưới màn, chuyển vi / en.
- Lock task: platform channel `parkviet/kiosk` (Kotlin: `startLockTask` / `stopLockTask`; Swift: kiểm Guided Access). Giữ màn hình sáng (`wakelock_plus`).
- Lỗi mạng: giữ giỏ, hiện "Đang kết nối lại", không cho thanh toán khi mất kết nối server.

### Client web `apps/pos`

- Cài đặt chi nhánh: quầy kiosk, mở / đóng ca kiosk, cấu hình idle / timeout / báo bếp trước.
- Màn đơn đang chờ: lọc "Từ kiosk", mở đơn kiosk park để thu tiền.

### File

| File | Hành động |
|---|---|
| `server/db/migrate/*_add_kind_to_spree_pos_registers.rb`, `*_add_service_account_to_staff_memberships.rb` | Tạo |
| `server/app/workflows/spree/pos/kiosks/provision.rb`, `server/app/services/spree/pos/kiosks/policy.rb` | Tạo |
| `server/app/services/spree/pos/access_policy.rb` | Sửa: chặn tài khoản dịch vụ ngoài danh sách |
| `server/app/workflows/spree/pos/tenders/confirm.rb` | Sửa: tài khoản dịch vụ chỉ được evidence `vietqr_webhook` |
| `server/app/models/spree/pos/workspace.rb` | Sửa: `ORDER_SOURCES` thêm `kiosk` |
| `server/app/controllers/spree/api/v3/admin/pos/kiosk_controller.rb` | Tạo |
| `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos-staff/lib/features/kiosk/`, `android/.../KioskChannel.kt`, `ios/Runner/KioskChannel.swift` | Tạo |
| `apps/pos/src/pages/settings/kiosk.tsx` | Tạo |

### Các bước

1. Migration, `Provision`, `Policy`, spec khẳng định tài khoản dịch vụ không giảm giá / tiền mặt / xác nhận tay được.
2. Sửa `Confirm` và spec: kiosk xác nhận được khi webhook đã khớp, bị từ chối với `vietqr_manual`.
3. Endpoint state, job đơn bỏ dở, nguồn đơn `kiosk` trong báo cáo.
4. Flutter chế độ kiosk, lock task, idle reset, trợ năng.
5. Cài đặt và lọc đơn kiosk trên `apps/pos`.
6. In số gọi qua trạm in gắn quầy kiosk.

### Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/kiosks/ spec/requests/spree/pos/kiosk_spec.rb spec/workflows/spree/pos/tenders/confirm_spec.rb`.
- Flutter: widget test luồng màn, idle reset; integration test với server test (QR giả lập webhook khớp).
- E2E web: đơn kiosk park → thu ngân mở, thu tiền mặt, complete, bếp nhận món.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Kiosk hoàn tất đơn khi tiền chưa về | Chỉ evidence webhook; spec chặn evidence tay. |
| Ca kiosk bị đóng giữa giờ | Kiosk hiện "Tạm ngưng" và không tạo đơn mới; đơn đang dở vẫn park được. |
| iOS không khóa máy được bằng code | Guided Access + kiểm tra trạng thái + cảnh báo quản lý; khuyến nghị Android cho kiosk. |
| Server LAN mất internet nên webhook không về | QR không khớp sau timeout, đơn chuyển "trả tại quầy". |

### Tiêu chí xong

- [x] Khách tự order, trả QR, nhận phiếu số gọi; thu ngân không phải chạm vào.
- [x] Trả tại quầy tạo đơn park, thu ngân thu tiền và hoàn tất bình thường.
- [x] Tài khoản dịch vụ kiosk bị chặn ở mọi lệnh ngoài danh sách.
- [ ] Android lock task và iOS Guided Access được kiểm và cảnh báo.
- [ ] Spec, test Flutter, e2e xanh.

### Kết quả

Trạng thái: xong phần code. Ba tiêu chí đầu đã được spec chứng minh. Tiêu chí khóa máy chưa tick vì code đã có nhưng chưa thử trên Android / iPad thật. Tiêu chí test chưa tick vì chưa có Flutter integration test với server, chưa chạy được e2e `apps/pos-dashboard`, và full suite chờ CI.

**Đã làm**

- Server:
  - Migration `20261112120000_add_kiosk_self_ordering`:
    - `spree_pos_registers.kind` (`counter` | `kiosk`, check constraint);
    - `spree_pos_staff_memberships.service_account` và `device_id` (unique, check `service_account = (device_id IS NOT NULL)`);
    - cấu hình chi nhánh `kiosk_idle_seconds` (15–600, mặc định 60), `kiosk_qr_timeout_seconds` (60–900, mặc định 180), `kiosk_kitchen_before_payment` (mặc định false);
    - `Workspace::ORDER_SOURCES` thêm `kiosk`, nên `Reports::Sales#by_source` tách được doanh thu kiosk.
  - `Kiosks::Provision`:
    - ghép thiết bị mode `kiosk` chỉ với quầy loại kiosk, rồi tạo tài khoản dịch vụ (vai trò `pos-kiosk-service`);
    - thu hồi thiết bị thì tắt tài khoản;
    - tài khoản không đăng nhập bằng PIN và không hiện trong danh sách nhân viên;
    - thu ngân không mở ca trên quầy kiosk.
  - `Kiosks::Policy`, kiểm trong `AccessPolicy` và `CommandExecutor`:
    - capability bị cắt về danh sách kiosk dù membership có gì;
    - mọi lệnh ngoài danh sách bị từ chối.
  - Các chặn riêng cho tài khoản dịch vụ:
    - `Tenders::Prepare` chỉ nhận VietQR;
    - `Tenders::Confirm` chỉ nhận evidence `vietqr_webhook`, không nhận tip;
    - `Workspaces::Complete` không cho bán thiếu tiền (sponsor).
  - `Kiosks::Order`:
    - đặt đơn với giá do server tính, chặn món hết và ca đóng, chạy lại an toàn với cùng Idempotency-Key;
    - QR: chuẩn bị tender, theo dõi, và chỉ khi webhook đã khớp mới confirm + complete. Sau complete thì có số gọi, gửi bếp và in phiếu;
    - "Trả tại quầy" (khách chọn, hoặc QR hết hạn) trả QR lại, park đơn kèm số gọi và in phiếu số gọi + số tiền phải trả. Bếp chỉ nhận trước khi chi nhánh bật `kiosk_kitchen_before_payment`;
    - hủy đơn chưa trả khi idle.
  - `Kiosks::Handoff`:
    - thu ngân xem danh sách đơn kiosk đang chờ;
    - thu ngân lấy đơn về ca mình (rebind), rồi thu tiền và complete như thường; bếp nhận món lúc đó;
    - hủy đơn bỏ dở;
    - đơn bỏ dở mà ngân hàng đã trả thì được thanh toán khi thu ngân lấy về.
  - `Kiosks::Shifts`: quản lý mở / đóng ca kiosk, ca không tiền mặt, đóng với số đếm 0. `Kiosks::Settings` đọc / ghi cấu hình trong khoảng cho phép. `Kiosks::Printing` in trên máy in receipt của trạm in gắn quầy kiosk, sau commit; máy in hỏng không chặn bán.
  - API thiết bị `api/v3/pos_device/kiosk/*`:
    - `state`, `menu`, `orders`, `orders/{id}`, `finish`, `pay_at_counter`, `cancel`;
    - lệnh ghi bắt buộc `Idempotency-Key`;
    - rate limit 30 ghi / 120 đọc mỗi phút;
    - thiết bị khác mode bị từ chối, và token kiosk không dùng được trên API nhân viên.
  - API admin:
    - `admin/pos/kiosk_settings` (GET / PUT, chỉ quản lý);
    - `admin/pos/kiosks/{register_id}/shift` và `shift/close`;
    - `admin/pos/kiosk_orders` (index, take, cancel);
    - `registers` nhận `kind` khi tạo, và giữ `kind` của quầy đã dùng.
  - Module `fnb.kiosk` trong `config/initializers/pos_modules.rb`. Realtime `kiosk.updated`, `kiosk_order.waiting`. OpenAPI `server/openapi/pos-staff.yaml` có schema đặt tên cho mọi endpoint mới.
- `packages/pos-shared`: `KIOSK_ORDER_SOURCE`, `PosRegister.kind`, nhãn module `fnb.kiosk` vi / en.
- `apps/pos`:
  - khay "Đơn từ kiosk" trên màn bán, hiện khi module bật và người dùng có quyền thu: số gọi, số phút chờ, nút lấy đơn về ca để thu tiền, hủy đơn bỏ dở kèm lý do;
  - sự kiện realtime làm mới khay;
  - nguồn đơn `kiosk` cố định như đơn nền tảng.
- `apps/pos-dashboard`:
  - thẻ "Kiosk tự order" trong trang Quầy, khi module bật: idle, timeout QR, báo bếp trước khi trả, danh sách quầy kiosk với mở / đóng ca;
  - sơ đồ quầy có cột và ô chọn loại quầy (không đổi được khi sửa);
  - ghép thiết bị kiosk chỉ cho chọn quầy kiosk.
- `apps/pos-staff` (Flutter, chế độ kiosk):
  - sinh lại `pos_api` bằng `tool/gen_api.sh`;
  - `lib/modes/kiosk/`:
    - `KioskFlow` đi các bước Chào → Thực đơn → Giỏ → QR đếm ngược → Số gọi lớn → tự quay về sau 20 giây;
    - modifier dùng lại `ModifierSheet` của chế độ phục vụ qua adapter;
    - idle hỏi "Bạn còn đó không?" 10 giây rồi hủy đơn chưa trả và xóa giỏ;
    - poll QR 2 giây, QR hết hạn thì chuyển trả tại quầy;
    - mất mạng thì giữ giỏ, hiện "Đang kết nối lại" và gửi lại với cùng key;
    - ca đóng thì hiện "Tạm ngưng".
  - Trợ năng và ngôn ngữ: chữ phóng tối thiểu 1.45, vùng chạm 64 dp, nhãn Semantics, chế độ "với tới thấp", chuyển vi / en.
  - Khóa máy:
    - channel `parkviet/kiosk` (Android `KioskLockChannel.kt`: lock task / screen pinning; iOS `AppDelegate.swift`: kiểm Guided Access);
    - `wakelock_plus` giữ màn sáng;
    - cảnh báo khi máy chưa khóa;
    - giữ lâu vào tiêu đề để vào màn quản lý, có nút "Mở khóa màn hình kiosk" sau khi nhập PIN quản lý.
- Docs: mục "8. Kiosk tự order" trong [`docs/pos/fnb-ban-va-tra-sau.md`](../../docs/pos/fnb-ban-va-tra-sau.md).

**Lệnh và kết quả**

- `pnpm spree rspec spec/workflows/spree/pos/kiosks/`: 14 examples, 0 failures.
- `pnpm spree rspec spec/requests/spree/pos/kiosk_spec.rb`: 8 examples, 0 failures.
- Lần chạy chung 44 spec liên quan (devices, tenders confirm / prepare, workspaces complete, access policy, module policy, profiles, onboarding, topology, order sources, realtime, guest views, …): 404 examples, 1 failure. Lỗi là `order_sources_spec.rb` chưa có nguồn `kiosk`; đã sửa và chạy lại 7/0. Chạy lại spec topology: xanh.
- `packages/pos-shared`: typecheck, lint ok; vitest 284 passed.
- `apps/pos`: typecheck, lint ok; vitest 322 passed. `pnpm --dir apps/pos exec playwright test e2e/kiosk-orders.spec.ts --project desktop`: 1 passed.
- `apps/pos-dashboard`: typecheck, lint ok; vitest 134 passed; build ok.
- `apps/pos-staff`: `flutter analyze` không lỗi; `flutter test` 166 passed (gồm 10 test mới ở `test/modes/kiosk/kiosk_test.dart`).

**Lệch so với plan**

- Một migration thay cho hai.
- Ca kiosk do quản lý mở, nhưng owner là tài khoản dịch vụ của kiosk, không phải quản lý. Làm vậy để tender và complete của kiosk đi đúng ca của nó; audit vẫn ghi quản lý mở / đóng.
- API trạng thái nằm ở `api/v3/pos_device/kiosk/state` (xác thực bằng token thiết bị), không phải `admin/pos/kiosk/state`. Kiosk gọi endpoint riêng của mình thay vì `tenders/prepare` / `confirm` / `complete` trực tiếp. Bên trong vẫn đi qua các workflow đó dưới tài khoản dịch vụ.
- Kiosk poll 2 giây, không nghe `BranchChannel`.
- "Đơn bỏ dở" (quá 30 phút) được tính khi đọc danh sách, không dùng job đánh dấu.
- Cài đặt kiosk nằm trong `apps/pos-dashboard` (trang Quầy), không phải `apps/pos/src/pages/settings/kiosk.tsx`, theo quy ước dự án như phần 12A. Màn bán dùng khay "Đơn từ kiosk" thay cho bộ lọc.
- Code Flutter ở `lib/modes/kiosk/`, không phải `lib/features/kiosk/`. Kênh iOS nằm trong `AppDelegate.swift`, không có file `KioskChannel.swift` riêng.
- Thực đơn kiosk gồm mọi món đang bán, trừ món đổi bằng credit đồ uống; không có cờ "bán trên kiosk" riêng.
- Ảnh QR lấy từ `qr_url` của server.

**Còn mở**

- Thử trên Android thật (Device Owner / screen pinning), iPad bật Guided Access, máy in trạm thật, và pilot tại quán.
- Flutter integration test với server test (webhook giả lập khớp) chưa có. Luồng đầu-cuối hiện do request / workflow spec phủ, còn widget test dùng API giả.
- E2e `apps/pos-dashboard` chưa chạy được vì cổng 5176 đang dùng cho dev server. Chờ CI.
- Tài khoản dịch vụ là một user Spree, nên vẫn hiện trong danh sách user của Spree admin (đã ẩn khỏi danh sách nhân viên POS).
- Quầy kiosk vẫn hiện trong danh sách chọn quầy của thu ngân; mở ca ở đó bị server từ chối.
- Full suite rspec / e2e chạy trên CI.

## Phần 12C: App chủ quán

### Overview

Chủ hoặc quản lý mở app Flutter ở chế độ `owner` trên điện thoại của mình. App hiện doanh thu hôm nay theo thời gian thực, các bàn / phòng đang mở, hộp duyệt từ xa (hủy món đã báo bếp, sửa giờ chơi, in lại / hủy tạm tính, giảm giá), danh sách đặt bàn và cảnh báo. App không thu tiền và không sửa đơn (D7); nó chỉ đọc và cấp `Approval`.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Chế độ `owner` là thiết bị **cá nhân**: ghép bằng mã như các mode khác (phase 2), nhưng mỗi lần mở app cần đăng nhập nhân viên (PIN + sinh trắc học của máy qua `local_auth` sau lần đầu). Một thiết bị owner thấy mọi chi nhánh mà nhân viên đó có quyền, không bị gắn một chi nhánh. |
| Q2 | Duyệt từ xa dùng **yêu cầu duyệt** mới. Hiện `Approval` được tạo trực tiếp bởi người duyệt (`approver = current_user` trong `ApprovalsController#create`), tức người duyệt phải đứng ở máy. Phần này thêm `ApprovalRequest`: người cần duyệt gửi yêu cầu (hành động, subject, revision, số tiền, lý do); chủ bấm Đồng ý trên app → server tạo `Approval` với `approver` là chủ, `requester` là người gửi, đi qua đúng các kiểm tra hiện có (`approver_allowed?`, `approver_is_distinct`, TTL ≤ 1 giờ, gắn revision). Máy người gửi nhận sự kiện và tự dùng approval đó. |
| Q3 | Thông báo: khi app mở, nhận qua `BranchChannel` (sự kiện `approval.requested` đã có trong plan). Khi app ở nền: **push qua FCM / APNs chỉ khi server có internet**. Server không giữ khóa FCM / APNs trực tiếp nếu chạy LAN; nó gửi qua một **push relay tùy chọn** (dịch vụ nhỏ do ParkViet vận hành, nhận payload tối thiểu đã ký: loại sự kiện + id, không có tiền hay tên khách). Không có relay hoặc mất internet thì chỉ có thông báo khi mở app; UI ghi rõ điều này. |
| Q4 | Báo cáo dùng lại `Spree::Pos::Reports::Sales` / `Cashbook` / `Closures` hiện có qua endpoint báo cáo đã có; chỉ thêm một endpoint tổng hợp "hôm nay" nhẹ cho màn chính để không gọi 4 báo cáo mỗi lần mở app. |

### Dữ liệu

- `spree_pos_approval_requests`: `store_id`, `branch_id`, `requester_id`, `action` (một trong các action của `Approval`, cộng các action F&B của phần 8B / 11A), `subject_type`, `subject_id`, `revision`, `amount`, `currency`, `reason`, `status` (`pending` | `granted` | `declined` | `expired` | `canceled`), `approval_id` (khi granted), `decided_by_id`, `decided_at`, `expires_at` (mặc định 10 phút).
- `spree_pos_push_registrations`: `device_id`, `platform` (`fcm` | `apns`), `token_ciphertext` (Active Record encryption), `enabled`, `last_error`.
- Cấu hình store: `push_relay_url`, `push_relay_key` (mã hóa). Trống thì không gửi push.

### Server

- Workflow `Spree::Pos::ApprovalRequests::Submit`, `Grant`, `Decline`, `Cancel`. `Grant` gọi lại đúng logic tạo `Approval` của `ApprovalsController#create` (tách phần đó ra service `Spree::Pos::Approvals::Issue` để dùng chung; controller cũ gọi service mới, hành vi không đổi).
- Endpoint `api/v3/admin/pos/approval_requests` (create, index theo chi nhánh / trạng thái, grant, decline, cancel). Quyền: grant cần cùng quyền mà action đó yêu cầu khi tạo `Approval` hôm nay.
- `GET api/v3/admin/pos/owner/today?branch_id=`: doanh thu đã complete, số đơn, doanh thu theo nguồn (`by_source`), bàn / phòng đang mở và tạm tính, số ca đang mở, số đơn hủy / món hủy trong ngày kinh doanh (`business_date`, D8).
- `GET api/v3/admin/pos/owner/open_units`: workspace đang mở theo resource, thời gian ngồi, tạm tính, trạng thái bếp chậm.
- Đặt bàn: đọc `api/v3/admin/pos/reservations` của phần 9A (chỉ đọc + xác nhận / hủy đặt bàn).
- Cảnh báo (`Spree::Pos::OwnerAlerts`): món chờ quá ngưỡng, ca chênh lệch tiền khi đóng ca, nhiều món hủy trong 1 giờ, doanh thu lũy kế năm gần mốc 1 tỷ (research §7), máy in / trạm in lỗi (`PrintJob` failed), hóa đơn điện tử lỗi (phần 6C). Mỗi cảnh báo phát `owner_alert.created` (sự kiện mới).
- Push: subscriber trên `OutboxEntry` / sự kiện realtime → `Spree::Pos::Push::RelayClient` gửi job nền (Solid Queue), retry có giới hạn, ghi `last_error`.

### Flutter (`apps/pos-staff`, chế độ `owner`)

- Tab: **Hôm nay** (doanh thu, số đơn, theo nguồn, biểu đồ theo giờ), **Đang mở** (lưới bàn / phòng với đồng hồ và tạm tính, chạm xem dòng), **Duyệt** (badge số yêu cầu; mỗi thẻ hiện ai xin, hành động, món / số tiền / giờ cũ → giờ mới, lý do; Đồng ý cần xác nhận sinh trắc học), **Đặt bàn**, **Cảnh báo**.
- Chọn chi nhánh ở thanh trên; nhớ lựa chọn cuối.
- Realtime khi mở app; kéo xuống để làm mới; khi nhận push thì mở đúng thẻ duyệt.
- Đăng ký push token khi người dùng cho phép; nút tắt push.

### Client web `apps/pos`

- Ở mọi chỗ hiện cần `Approval` (giảm giá, sửa giá, hủy món đã báo bếp, sửa giờ, in lại tạm tính): thêm lựa chọn **"Gửi chủ duyệt"** cạnh luồng quản lý nhập PIN tại chỗ. Gửi xong hiện "Đang chờ duyệt", nghe sự kiện và tự tiếp tục khi được duyệt, hoặc báo bị từ chối.
- Cài đặt store: URL / khóa push relay, trạng thái kết nối.

### File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_approval_requests.rb`, `*_create_spree_pos_push_registrations.rb` | Tạo |
| `server/app/models/spree/pos/approval_request.rb`, `push_registration.rb` | Tạo |
| `server/app/services/spree/pos/approvals/issue.rb` | Tạo, tách từ `approvals_controller.rb` |
| `server/app/controllers/spree/api/v3/admin/pos/approvals_controller.rb` | Sửa: gọi `Approvals::Issue` |
| `server/app/workflows/spree/pos/approval_requests/*.rb` | Tạo |
| `server/app/controllers/spree/api/v3/admin/pos/approval_requests_controller.rb`, `owner_controller.rb`, `push_registrations_controller.rb` | Tạo |
| `server/app/services/spree/pos/owner_alerts.rb`, `push/relay_client.rb`, `server/app/jobs/spree/pos/push_delivery_job.rb` | Tạo |
| `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos-staff/lib/features/owner/` | Tạo |
| `apps/pos/src/components/remote-approval-button.tsx`, `hooks/use-approval-requests.ts` | Tạo |

### Các bước

1. Tách `Approvals::Issue`; chạy lại toàn bộ spec approval hiện có để chứng minh không đổi hành vi.
2. `ApprovalRequest` + workflow + spec (hết hạn, revision đổi làm yêu cầu vô hiệu, người gửi không tự duyệt).
3. Endpoint owner today / open_units dùng lại `Reports::*`; spec so khớp số liệu với báo cáo sales cùng khoảng.
4. Cảnh báo và push relay client (job nền, không chặn lệnh nghiệp vụ).
5. Flutter chế độ owner, sinh trắc học, push.
6. Nút "Gửi chủ duyệt" trên `apps/pos` ở các điểm cần duyệt.

### Kiểm thử

- `pnpm spree rspec spec/requests/spree/pos/approvals_spec.rb spec/requests/spree/pos/approval_requests_spec.rb spec/requests/spree/pos/owner_spec.rb spec/workflows/spree/pos/approval_requests/`.
- Spec bảo mật: nhân viên không có quyền duyệt không grant được; yêu cầu của chi nhánh A không hiện cho người chỉ có quyền chi nhánh B.
- Flutter: widget test thẻ duyệt, test realtime với mock channel.
- E2E: thu ngân xin giảm giá → chủ duyệt trên app (giả lập qua API) → thu ngân tiếp tục.

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Duyệt nhầm từ xa | Thẻ duyệt hiện đủ thông tin trước / sau; xác nhận sinh trắc học; `Approval` vẫn gắn revision nên đơn đã đổi thì approval vô hiệu. |
| Push lộ dữ liệu ra ngoài | Payload relay chỉ có loại sự kiện + id; app tự gọi server lấy chi tiết. |
| Server LAN không có internet nên không push | Ghi rõ trên UI và tài liệu; vẫn có realtime khi app mở và cùng mạng / có đường vào server. |
| Chủ ở ngoài quán không vào được server LAN | Phần 5B cung cấp tunnel; không có tunnel thì app owner chỉ dùng khi ở quán. |

### Tiêu chí xong

- [x] Màn Hôm nay khớp số liệu với báo cáo bán hàng cùng ngày kinh doanh.
- [x] Yêu cầu duyệt từ thu ngân / phục vụ đến app chủ realtime, được duyệt / từ chối, máy gửi tự tiếp tục.
- [ ] Push hoạt động khi có relay và internet; tắt êm khi không có.
- [x] Spec approval cũ vẫn xanh sau khi tách service.

### Kết quả

**Đã làm**

- Server: tách `Spree::Pos::Approvals::Issue` (`server/app/services/spree/pos/approvals/issue.rb`); `ApprovalsController#create` gọi service, hành vi và thông báo lỗi giữ nguyên. Migration `20261112130000_add_owner_app.rb` tạo `spree_pos_approval_requests`, `spree_pos_push_registrations`, `spree_pos_push_relay_settings`, `spree_pos_owner_alerts` (thêm 6 check constraint, schema.rb chỉ giữ phần mới). Workflow `ApprovalRequests::Submit` / `Grant` / `Decline` / `Cancel`: gửi kiểm như duyệt tại quầy (`Issue.check!`), hỏi lại cùng việc trả về yêu cầu đang chờ, revision mới hủy yêu cầu cũ, quá 10 phút hoặc subject đổi thì `expired`, người gửi không tự duyệt (`approver_is_requester`), grant/decline idempotent, có audit; grant phát `approval.requested` (máy gửi tự dùng mã) và `approval_request.updated`. Endpoint `approval_requests`, `owner/branches|today|open_units|alerts`, `push_registration`, `push_relay_settings` (+ `check`). `owner/today` lấy đúng summary của báo cáo `sales` cộng `by_hour` (thêm vào `Reports::Sales`). Cảnh báo `OwnerAlerts` do job `pos_owner_alerts_scan` chạy mỗi phút, mỗi việc báo một lần (khóa dedupe), phát `owner_alert.created`. Push: `Push.notify` chỉ xếp `PushDeliveryJob` khi store có relay, payload chỉ `platform`, `token`, `event`, `id`, ký HMAC-SHA256, thử lại tối đa 5 lần, ghi `last_error`. Kênh realtime cho thiết bị owner nghe chi nhánh khác nơi người đăng nhập có quyền duyệt hoặc xem báo cáo. Lỗi `approval_required` của đơn, đặt bàn và ví suất ăn giờ có `action`, revision và số tiền cần xin.
- Flutter `apps/pos-staff` mode owner (`lib/modes/owner/`): chọn chi nhánh (nhớ trên máy), tab Hôm nay / Đang mở / Duyệt (badge, Đồng ý qua `local_auth`, máy không có sinh trắc thì hỏi xác nhận, Từ chối kèm lý do) / Đặt bàn / Cảnh báo, kéo để làm mới, realtime theo chi nhánh đang xem, bảng thông báo nền (bật/tắt, trạng thái relay). Hộp hủy món của máy phục vụ có **Gửi chủ duyệt**, tự hủy món khi được duyệt, báo từ chối / hết hạn, rút yêu cầu khi đóng hộp. Nguồn push token nằm sau interface `PushTokenSource` (mặc định không có).
- `apps/pos`: `RemoteApprovalButton` + `use-approval-requests` ở hủy món đã báo bếp, giảm giá đơn, giảm giá món, đổi giá, sửa giờ, tạm dừng lâu, in lại tạm tính, hoàn/giữ cọc, ví suất ăn (hoàn, điều chỉnh), chai gửi, sửa hoa hồng xe; realtime làm mới yêu cầu đang chờ.
- `apps/pos-dashboard`: thẻ **Thông báo cho app chủ quán** ở trang Thông tin server (địa chỉ HTTPS, khóa chỉ ghi, kiểm tra kết nối, lỗi / lần gửi gần nhất, gỡ).
- Tài liệu: `docs/pos/fnb-ban-va-tra-sau.md` §9, `docs/deploy/pos-lan-vps.md` §7.
- Bổ sung sau lần đầu:
  - **Đang mở → chạm xem dòng**: `GET api/v3/admin/pos/owner/open_units/:workspace_id?branch_id=` (`OwnerDashboard.open_unit`), cần `pos.report.read` ở chi nhánh, chỉ đơn đang mở của đúng chi nhánh (khác thì 404). Trả nhãn bàn, nguồn, số khách, phút mở, tổng và từng dòng: tên, số lượng, đơn vị, tiền sau giảm giá, trạng thái bếp (`none` / `unsent` / `waiting` / `ready` / `served`); không có thông tin khách. App: chạm ô mở bảng dòng (chỉ đọc), đơn đã đóng thì báo "Đơn này không còn mở."
  - **Đặt bàn → xác nhận / hủy**: phần 9A không có trạng thái "đã xác nhận", nên thêm cột `confirmed_at` (migration `20261112140000_add_reservation_confirmation.rb`) và workflow `Reservations::Confirm` (`POST reservations/:id/confirm`): chỉ lượt `booked`, quyền như `Cancel` (`Guard.manage!`: `pos.reservation.manage` hoặc quản trị store), không đổi revision nên approval cọc đang xin vẫn đúng, xác nhận lại không ghi gì thêm, có audit `reservation.confirm`. Hủy dùng lại `Reservations::Cancel` (`canceled`); hai lệnh này không cần approval nên app không xin. `OwnerBranch.can_manage_reservations` quyết định app có hiện nút **Xác nhận** / **Hủy đặt bàn** (hủy hỏi lại trước); lượt đã xác nhận ghi "Đã xác nhận với khách".
  - OpenAPI: `posOwnerOpenUnitShow` (`OwnerOpenOrder`, `OwnerOpenOrderLine`, `OwnerOpenOrderResult`), `posReservationConfirm`, `Reservation.confirmed_at`, `OwnerBranch.can_manage_reservations`; client Dart sinh lại.

**Lệnh và kết quả**

- `pnpm spree rspec spec/requests/spree/pos/approval_requests_spec.rb` — 7 examples, 0 failures; `spec/requests/spree/pos/owner_spec.rb` — 8, 0.
- Spec các luồng approval cũ (workspace_discounts, sale_guards, security, topology_access, topology, bottle_keeps, meal_accounts, vehicle_visits, print_jobs, realtime, timed_operations, timed_sessions, credit_receivables, prebills, platform_orders, table_kitchen, returns_refunds, integration fnb_wave2_scenario, credit_race, workflows stored_value_cards, fnb/bar_billing, kitchen/, meal_accounts/, platform_orders/, reservations/, timed/, vehicle_visits/) — 307 examples, 0 failures.
- `pnpm spree rspec spec/workflows/spree/pos/approval_requests/ spec/requests/spree/pos/owner_spec.rb spec/requests/spree/pos/approval_requests_spec.rb spec/requests/spree/pos/devices_spec.rb spec/services/spree/pos/print_documents_spec.rb spec/requests/spree/pos/authentication_spec.rb` — 47, 0.
- `pnpm spree rspec spec/requests/spree/pos/meal_accounts_spec.rb spec/requests/spree/pos/reservations_spec.rb spec/workflows/spree/pos/meal_accounts/ spec/workflows/spree/pos/reservations/ spec/workflows/spree/pos/approval_requests/ spec/requests/spree/pos/approval_requests_spec.rb` — 42, 0.
- `apps/pos-staff`: `flutter analyze` — không lỗi; `flutter test` — 174 passed (8 mới trong `test/modes/owner/owner_home_test.dart`).
- `apps/pos`: `tsc --noEmit`, `biome check .` sạch; `vitest run` — 328 passed; `playwright test e2e/remote-approval.spec.ts --project desktop` — 1 passed; các e2e liên quan (table-kitchen-send, karaoke, meal-accounts, vehicle-visits, reservations, bar-tabs, print-queue, realtime, tables) — 28 passed, 1 skipped (real API).
- `apps/pos-dashboard`: `pnpm typecheck`, `pnpm lint` sạch; `pnpm test` — 136 passed.
- Phần bổ sung: `pnpm spree rspec spec/requests/spree/pos/owner_spec.rb spec/requests/spree/pos/reservations_spec.rb spec/workflows/spree/pos/reservations/ spec/requests/spree/pos/devices_spec.rb spec/services/spree/pos/print_documents_spec.rb` — 40 examples, 0 failures; rubocop các file server đã sửa sạch; `apps/pos-staff`: `flutter analyze` không lỗi, `flutter test` — 177 passed (mới: xem dòng đơn đang mở trong `owner_home_test.dart`, xác nhận / hủy đặt bàn trong `table_service_test.dart`).

**Lệch so với plan**

- Thêm bảng `spree_pos_owner_alerts` để mỗi cảnh báo báo một lần và app đọc lại được; cảnh báo do job quét mỗi phút, không móc vào lệnh nghiệp vụ.
- Cấu hình relay là bảng `spree_pos_push_relay_settings` thay cho cột của store; token cột `token` (mã hóa Active Record) thay cho `token_ciphertext`; `push_registrations` có thêm `staff_id` để lọc theo quyền chi nhánh.
- Sự kiện yêu cầu là `approval_request.created` / `.updated`; `approval.requested` vẫn nghĩa là "đã cấp mã" để máy đang chờ tự tiếp tục.
- Cài đặt relay nằm ở `apps/pos-dashboard` (trang Thông tin server), không ở `apps/pos`, theo ranh giới các phần trước.
- Màn bán không có nút "gửi" trước khi bị từ chối ở những chỗ số tiền do server tính (giảm giá, đổi giá, ví suất ăn): thu ngân bấm lệnh, server trả `approval_required` kèm số tiền, rồi mới hiện **Gửi chủ duyệt**.
- "Xác nhận đặt bàn" là dấu thời gian `confirmed_at` trên lượt `booked`, không phải trạng thái mới; `apps/pos` chưa hiện hay bấm xác nhận (chỉ app chủ).

**Còn mở**

- Push thật: cấu hình native Firebase Cloud Messaging / APNs (google-services, entitlement, tài khoản Firebase/Apple) và `PushTokenSource` thật; dịch vụ relay do ParkViet vận hành chưa có. Mở thẳng tab Duyệt từ thông báo mới có hook (`OwnerScreen.initialTab`). Tiêu chí push để trống.
- Chưa thử trên máy thật (vân tay / Face ID, nhiều chi nhánh qua tunnel) và chưa pilot.
- E2E `apps/pos-dashboard` (thêm ca relay vào `e2e/system-status.spec.ts`) chưa chạy: cổng 5176 đang dùng cho máy phát triển. `pnpm build` của dashboard không chạy để không ghi đè `dist/` sẵn có.
- Không có luồng duyệt tiền tip hiện có để nối vào yêu cầu duyệt từ xa.
- Full suite chạy trên GitHub Actions.

## Phần 12D: Hàng đợi offline cho thu ngân

### Overview

Khi thu ngân web (`apps/pos`) không kết nối được server (server LAN tắt / Wi-Fi rớt / VPS mất đường), thu ngân vẫn bán được **đơn trả trước tại quầy, thu tiền mặt**. Lệnh được xếp hàng trong IndexedDB và phát lại theo thứ tự khi có mạng. Đây là bậc 2 của research §6.6; bậc 1 (server LAN, D5) đã che phần lớn trường hợp mất internet. Luật nghiệp vụ vẫn chỉ chạy ở server (D6): khi offline client chỉ **ghi ý định**, server quyết định lúc phát lại.

### Quyết định

| # | Quyết định |
|---|---|
| Q1 | Phạm vi offline: chỉ `service_mode = counter`, đơn mới, dòng `menu` / `ordinary` (không `measured`, `tracked`, `timed`), **chỉ tiền mặt**. VietQR, công nợ, giảm giá cần duyệt, trả hàng, đóng ca, bàn / trả sau đều bị khóa khi offline, nút hiện lý do. |
| Q2 | Mỗi đơn offline có `offline_id` (UUID v4 do client sinh) và mỗi lệnh có idempotency key suy ra từ `offline_id` + số thứ tự lệnh, nên phát lại nhiều lần vẫn chỉ tạo một workspace / một tender (dùng `CommandReceipt` hiện có). |
| Q3 | Phát lại bằng **một lệnh gộp** ở server `POST api/v3/admin/pos/offline_sales` (body: `offline_id`, register, shift, thời điểm client, dòng, tiền khách đưa) thay vì phát từng lệnh lẻ cần lease / revision. Server chạy tuần tự: tạo workspace → thêm dòng → tender tiền mặt → complete, tất cả qua các workflow hiện có trong một `CommandExecutor` với key `offline:<offline_id>`. |
| Q4 | Giá: server **tính lại** theo giá hiện tại. Nếu tổng khác tổng đã thu khi offline, đơn **không tự complete**: nó vào trạng thái `needs_review` (workspace park, tiền mặt đã thu ghi vào ghi chú bằng chứng) và hiện trên màn "Đơn offline cần xem lại". Món hết / ngừng bán cũng vào `needs_review`. Thu ngân chọn: chấp nhận giá đã thu (cần `Approval` `workspace.override_price` như hiện có) hoặc sửa đơn. |
| Q5 | Số hóa đơn: khi offline client in phiếu với **số tạm** `OFF-<mã quầy>-<số tăng dần cục bộ>` và dòng chữ "Phiếu tạm, chưa đồng bộ". Số đơn thật của Spree và số gọi do server cấp lúc phát lại. Hóa đơn điện tử (phần 6C) chỉ phát hành sau khi phát lại thành công. |
| Q6 | Giờ bán: lưu `client_sold_at` để đối chiếu, nhưng `business_date` và `completed_at` theo server lúc phát lại cộng ghi chú `sold_offline_at`; báo cáo có cột "bán offline". Lệch giờ client lớn hơn 10 phút so với server lúc đồng bộ thì đánh dấu kiểm tra. |
| Q7 | Ca: chỉ bán offline khi ca đã mở trước lúc mất mạng (client có snapshot ca). Không mở / đóng ca offline. Tiền mặt offline cộng vào ca đó khi phát lại. |

### Dữ liệu

- Server: `spree_pos_offline_sales`: `store_id`, `branch_id`, `register_id`, `shift_id`, `offline_id` (unique theo store), `client_sold_at`, `payload` jsonb, `status` (`completed` \| `needs_review` \| `rejected`), `workspace_id`, `review_reason`, `resolved_by_id`, `resolved_at`.
- Client (IndexedDB qua `idb`): store `offline_sales` (`offline_id`, payload, `status`: `queued` \| `syncing` \| `synced` \| `needs_review` \| `failed`, `attempts`, `last_error`), store `catalog_snapshot` (thực đơn, giá, modifier, hết món tại lúc snapshot), store `context_snapshot` (chi nhánh, quầy, ca đang mở, mẫu in), counter số tạm theo quầy.

### Server

- Workflow `Spree::Pos::OfflineSales::Ingest`: kiểm ca (thuộc quầy, đang mở hoặc đã đóng sau `client_sold_at`: nếu ca đã đóng thì `needs_review` để quản lý gán ca), kiểm quyền nhân viên có trong payload (đã đăng nhập trước khi offline), rồi chạy chuỗi workflow hiện có. Bất kỳ `Conflict` nào trong chuỗi → `needs_review` kèm `reason`, không raise ra client.
- `Resolve`: hoàn tất đơn `needs_review` theo lựa chọn của thu ngân (đi đúng lệnh hiện có với lease bình thường).
- Endpoint: `POST offline_sales` (idempotent), `GET offline_sales?status=needs_review`, `POST offline_sales/:id/resolve`, `POST offline_sales/:id/reject` (hủy đơn và ghi lý do; tiền mặt đã thu ghi thành chênh lệch ca, có audit).
- `GET api/v3/admin/pos/offline_snapshot?register_id=`: gói thực đơn + giá + mẫu in + ca hiện tại để client lưu, có `generated_at` và `etag`.

### Client web `apps/pos`

- **PWA shell:** thêm `vite-plugin-pwa` (Workbox), manifest, service worker precache bundle, font, ảnh món nhỏ. Hiện `apps/pos` chưa có manifest / service worker. Chỉ cache tài nguyên tĩnh; API không cache trong service worker (snapshot nằm trong IndexedDB).
- Phát hiện offline: ping `GET /up` (hoặc endpoint context) thất bại 2 lần liên tiếp, không chỉ dựa `navigator.onLine`. Thanh trạng thái đỏ "Mất kết nối server — chế độ bán offline" kèm số đơn chờ đồng bộ.
- Màn bán offline: dùng lưới món hiện có đọc từ `catalog_snapshot`, ẩn / khóa các tính năng ngoài Q1, hộp tiền mặt (nhận, tiền thối), in phiếu tạm qua adapter trình duyệt / ePOS / WebPRNT (trạm in Flutter cần server nên không dùng được khi server mất).
- Đồng bộ: khi server trở lại, `OfflineSyncWorker` gửi từng đơn theo thứ tự `client_sold_at`, tối đa 1 đơn cùng lúc, backoff khi lỗi mạng; kết quả `needs_review` chuyển sang màn "Đơn offline cần xem lại".
- `session-coordinator.ts`: không đăng xuất / làm mới token khi offline; token hết hạn trong lúc offline thì yêu cầu đăng nhập lại trước khi đồng bộ (đơn vẫn nằm trong IndexedDB).
- Snapshot làm mới mỗi 10 phút khi online và mỗi khi thực đơn đổi (sự kiện realtime phase 3).

### File

| File | Hành động |
|---|---|
| `server/db/migrate/*_create_spree_pos_offline_sales.rb` | Tạo |
| `server/app/models/spree/pos/offline_sale.rb` | Tạo |
| `server/app/workflows/spree/pos/offline_sales/ingest.rb`, `resolve.rb`, `reject.rb` | Tạo |
| `server/app/controllers/spree/api/v3/admin/pos/offline_sales_controller.rb`, `offline_snapshots_controller.rb` | Tạo |
| `server/app/services/spree/pos/reports/sales.rb` | Sửa: cột "bán offline" |
| `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos/vite.config.ts`, `apps/pos/package.json` | Sửa: `vite-plugin-pwa`, `idb` |
| `apps/pos/src/lib/offline/store.ts`, `sync-worker.ts`, `connectivity.ts`, `provisional-number.ts` | Tạo |
| `apps/pos/src/components/offline-banner.tsx`, `pages/offline-review.tsx` | Tạo |
| `apps/pos/src/lib/session-coordinator.ts` | Sửa: hành vi khi offline |

### Các bước

1. Server: model, `Ingest` với spec phát lại hai lần chỉ một đơn; giá lệch → `needs_review`; ca đã đóng → `needs_review`; món hết → `needs_review`.
2. `Resolve` / `Reject` + spec dùng `Approval` sửa giá hiện có.
3. Endpoint snapshot, cập nhật OpenAPI.
4. Client: PWA shell, kiểm tra app tải được khi tắt server.
5. Client: IndexedDB store, phát hiện offline, màn bán offline giới hạn, số tạm, in phiếu tạm.
6. Client: sync worker, màn xem lại, thanh trạng thái.
7. Báo cáo cột bán offline; tài liệu hướng dẫn thu ngân.

### Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/offline_sales/ spec/requests/spree/pos/offline_sales_spec.rb`.
- `pnpm --dir apps/pos test`: vitest cho store, sync worker (mock fetch), số tạm, lọc tính năng.
- Playwright: chặn mạng tới API (`page.route` abort) → bán 3 đơn tiền mặt → mở lại → 3 đơn complete, ca có đúng tiền; một đơn có giá đổi trong lúc offline vào màn xem lại.
- `pnpm --dir apps/pos lint`, `typecheck`, `build` (service worker sinh đúng).

### Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Hai máy bán offline trùng số tạm | Số tạm có mã quầy; số thật do server cấp. |
| Gian lận: bán offline rồi xóa IndexedDB | Đơn offline có audit khi đồng bộ; tiền mặt ca lệch lộ ra khi đóng ca; ghi rõ giới hạn trong tài liệu. |
| Giá / thuế khác lúc đồng bộ | Server tính lại, lệch thì `needs_review`, không tự complete. |
| Service worker giữ bản cũ sau khi deploy | Prompt "Có bản mới, tải lại" khi online; không tự reload giữa lúc bán. |
| Token hết hạn khi offline lâu | Giữ đơn, đòi đăng nhập lại trước đồng bộ. |

### Tiêu chí xong

- [ ] `apps/pos` mở được và bán đơn tiền mặt trả trước khi server không truy cập được.
- [x] Khi server trở lại, đơn đồng bộ đúng thứ tự, không trùng, ca đúng tiền.
- [x] Đơn lệch giá / hết món / ca đóng vào màn xem lại và được xử lý bằng luồng có duyệt.
- [x] Mọi tính năng ngoài phạm vi offline bị khóa có lý do hiển thị.
- [x] Server spec, vitest, Playwright, build xanh.

### Kết quả

**Đã làm**

- **Server.**
  - Migration `20261112150000_create_spree_pos_offline_sales.rb` tạo bảng `spree_pos_offline_sales`:
    - `offline_id` unique theo store, số tạm, `client_sold_at`, độ lệch đồng hồ và cờ `clock_check`;
    - `payload` (chỉ các dòng), tiền đã thu và tiền khách đưa;
    - `status`, `workspace_id` (unique), lý do và chi tiết xem lại;
    - người, lúc và cách xử lý.
  - Bảng có 6 check constraint mới, nâng tổng từ 252 lên 258. `schema.rb` chỉ giữ phần mới.
  - Model `Spree::Pos::OfflineSale` (`posoffline_`). Module `Spree::Pos::OfflineSales` gom quy tắc chung: khóa `offline:<offline_id>`, kiểm dòng theo luật đơn QR, món còn bán, dựng đơn nháp, trả tiền mặt rồi complete.
  - `OfflineSales::Ingest` chạy trong một `CommandExecutor` với key `offline:<offline_id>`; các lệnh con có key suy ra từ đó. Trình tự: `Workspaces::Create.draft!` → `ManageLineItem.add` (`merge: false`) → `Tenders::Prepare` / `Confirm` tiền mặt (`cash_count`) → `Workspaces::Complete`.
    - Server tính lại giá. Tổng khác tiền đã thu thì đơn được park, ghi chú tiền đã thu, lý do `price_changed`.
    - Ca đã đóng, giờ bán lệch ca, món ngừng bán hoặc hết món cũng vào `needs_review`, không tạo đơn.
    - `Conflict` trong chuỗi thành `sale_refused`, không raise ra client.
    - Phát lại cùng key trả đúng kết quả cũ. Bếp và tem ly không in lại khi phát lại.
  - `OfflineSales::Resolve`: chỉ thu ngân đã thu tiền xử lý được đơn, bằng một trong ba cách:
    - `accept_collected`: một `Approval` `workspace.override_price` bằng tổng đã thu, rồi `OverridePrice.apply!` từng dòng lệch;
    - `current_price`: thu theo giá hiện tại;
    - `edited`: bán dòng khác.

    Đơn chưa có order thì order mới vào ca đang mở của thu ngân.
  - `OfflineSales::Reject`: người có `pos.approval.grant` từ chối, kèm lý do. Đơn park bị hủy và có audit. Tiền mặt thành chênh lệch ca.
  - Endpoint:
    - `GET offline_snapshot?register_id=` có ETag / 304 và `no-store`;
    - `POST offline_sales`, idempotent;
    - `GET offline_sales?branch_id=&status=`: cashier chỉ thấy đơn của mình;
    - `POST offline_sales/:id/resolve`, `POST offline_sales/:id/reject`.
  - `Workspaces::OverridePrice.apply!` tách từ `call`. Báo cáo bán hàng thêm cột `sold_offline_at` và hai dòng tổng `offline_orders`, `offline_total`.
  - OpenAPI có 5 operation và 8 schema mới. Client Dart đã sinh lại.
- **`apps/pos`.**
  - `lib/offline-store.ts`: IndexedDB `parkviet-pos-offline` gồm hai phần.
    - `meta` giữ snapshot của quầy và bộ đếm số tạm theo quầy và ngày. Bộ đếm đọc và ghi trong một transaction.
    - `sales` giữ hàng đợi. Không lưu token hay email.
  - `lib/offline-sales.ts`:
    - luật offline: snapshot quá 12 giờ hoặc ca chưa mở thì không bán;
    - giới hạn hàng đợi 200 đơn hoặc 24 giờ;
    - giới hạn dòng 20 / 20 / 50;
    - số tạm `OFF-<mã quầy>-<yyMMdd>-<nnn>`;
    - tính tiền theo đơn vị phần trăm đồng.
  - `lib/offline-sync.ts`: gửi lần lượt theo `client_sold_at`, mỗi lần một đơn, mỗi đơn một key. Có khóa `navigator.locks` giữa các tab. Xử lý kết quả:
    - lỗi mạng, 5xx, 429 hoặc lệnh đang chạy: dừng, lần sau gửi lại;
    - 401: dừng, chờ đăng nhập;
    - 4xx khác: đánh dấu `failed`, giữ trên máy và chỉ gửi lại khi thu ngân bấm;
    - server đã nhận đơn (hoàn tất hoặc chờ xem lại): xóa khỏi máy.
  - `lib/connectivity.ts`: request không có phản hồi thì hỏi server. Hai lần không trả lời là offline. Khi offline thì hỏi lại mỗi 15 giây. Có kèm sự kiện `online` / `offline` của trình duyệt.
  - `session-coordinator.ts`: `resume()` không đăng xuất khi không có phản hồi. Đăng xuất chủ động thì xóa snapshot; đơn đã xếp hàng vẫn giữ.
  - Màn `/offline` (`pages/offline-sale.tsx`, nằm ngoài shell đăng nhập):
    - lưới món hiện có (`MenuGrid` thêm `menuData`) và `ModifierSheet`;
    - giỏ có nút −/+, ô khách đưa, tiền thừa, nút **Thu tiền mặt**;
    - phiếu tạm in qua adapter trình duyệt ("PHIẾU TẠM – CHƯA ĐỒNG BỘ", số tạm, tiền khách đưa và tiền thừa);
    - danh sách các việc không làm được khi offline;
    - không bán khi snapshot hỏng, quá cũ, ca đóng, hàng đợi đầy hoặc trình duyệt không lưu được dữ liệu.
  - `OfflineBanner` trong shell:
    - làm mới snapshot mỗi 10 phút, khi ca đổi và khi có mạng lại;
    - hiện link **Bán offline (chỉ tiền mặt)** khi mất mạng;
    - hiện số đơn chờ đồng bộ (nút **Gửi ngay**) và số đơn bị từ chối (nút **Gửi lại**);
    - hiện link **N đơn offline cần xem lại**.

    Màn đăng nhập cũng hiện link bán offline khi có snapshot dùng được.
  - Màn `/offline-review` (`pages/offline-review.tsx`):
    - **Giữ giá đã thu**, với mã duyệt hoặc **Gửi chủ duyệt**;
    - **Thu theo giá hiện tại**, có ô tổng tiền mặt đã thu;
    - **Từ chối đơn**, chỉ cho người có quyền duyệt.
  - PWA: plugin nhỏ trong `vite.config.ts` sinh `sw.js` cho bản build. Service worker precache file của bản build, lấy trang từ mạng trước rồi mới lấy `index.html` đã lưu, và không chặn `/api` hay `/cable`. Mỗi bản build có cache riêng.

    `lib/service-worker.ts` chỉ đăng ký ở bản production. `AppUpdatePrompt` hiện "Có bản mới của POS. Tải lại" và không tự reload.
- **`apps/pos-dashboard`**: cột báo cáo `sold_offline_at` (giờ) và hai dòng tổng, có bản vi và en.
- **Tài liệu**: `docs/pos/fnb-ban-va-tra-sau.md` §10 "Bán offline khi mất mạng" (phạm vi, giới hạn, đồng bộ, xem lại, chống gian lận, service worker). Mục dữ liệu thử chuyển thành §11.

**Lệnh và kết quả**

- `pnpm spree rspec spec/workflows/spree/pos/offline_sales/` — 14 examples, 0 failures.
- `pnpm spree rspec spec/requests/spree/pos/offline_sales_spec.rb` — 5, 0.
- Spec của các file server đã sửa, chạy chung — 101 examples, 0 failures:
  - `reports_spec`, `sale_guards_spec`, `sale_lines_spec`;
  - `workspaces/complete_spec`, `workspaces/manage_line_item_spec`, `cup_labels/issue_spec`;
  - `owner_spec`, `order_sources_spec`, `devices_spec`, `print_documents_spec`.
- `kiosks/kiosk_policy_spec`, `scale_labels_spec`, `package_split_spec`, `approval_requests_spec`, `authentication_spec` — 34, 0.
- Rubocop: đã autocorrect các file server mới. Còn `Metrics/ParameterLists` giống các workflow sẵn có.
- `apps/pos`:
  - `pnpm lint` và `pnpm typecheck` sạch.
  - `pnpm test` — 346 passed. Mới: `offline-sales.test.ts` 8, `offline-sync.test.ts` 5, `connectivity.test.ts` 4, `session-coordinator.test.ts` +1.
  - `playwright test e2e/offline-sales.spec.ts --project desktop --project tablet --project mobile` — 6 passed. Kịch bản:
    - mất mạng → bán 3 đơn tiền mặt → có mạng;
    - phản hồi đầu bị mất và được gửi lại cùng key;
    - 2 đơn hoàn tất; đơn có giá đổi vào màn xem lại rồi được thu theo giá hiện tại;
    - tiền ca bằng 98.000;
    - không có snapshot thì không có lối vào.
  - E2e liên quan: `fnb-menu`, `full-retail`, `auth`, `feature-recovery`, `lease-recovery`, `concurrency-chaos`, `fnb-wave1` — 25 passed, 2 skipped (real API). `accessibility`, `pages-polish`, `ui-polish`, `realtime` — 8 passed, 1 skipped.
  - `vite build` ra thư mục tạm: có `sw.js`, precache `index.html` cùng JS và CSS. Thư mục tạm đã xóa, `dist/` sẵn có không bị đụng.
- `apps/pos-staff`:
  - `tool/gen_api.sh` sinh lại client;
  - `flutter analyze` không lỗi;
  - `flutter test` — 177 passed.
- `apps/pos-dashboard`: `pnpm lint` và `pnpm typecheck` sạch; `pnpm test` — 136 passed.

**Lệch so với plan**

- Không thêm `idb` hay `vite-plugin-pwa`. `pnpm add` báo `ERR_PNPM_UNEXPECTED_STORE`: `node_modules` được cài bằng store v11, còn pnpm 10.33.4 của máy đòi store v10. Thay vào đó:
  - IndexedDB viết trực tiếp, theo mẫu `financial-recovery.ts`;
  - service worker do plugin 40 dòng trong `vite.config.ts` sinh ra;
  - chưa có web manifest và icon cài app.
- File nằm ở `src/lib/offline-*.ts` và `src/lib/connectivity.ts`, `service-worker.ts` (theo cách đặt file phẳng của `src/lib`), không trong thư mục `lib/offline/`.
- Hàng đợi trên máy chỉ có `pending` / `failed`. Server đã nhận đơn thì máy xóa đơn; trạng thái `completed` / `needs_review` đọc từ server.
- Snapshot và ngữ cảnh gộp thành một bản ghi của quầy gần nhất, không tách `catalog_snapshot` / `context_snapshot`.
- Ca đã đóng hoặc món ngừng bán thì không tạo workspace lúc phát lại. Order được tạo khi thu ngân xử lý, trên ca đang mở của họ. Plan ghi "quản lý gán ca".
- Màn offline nằm ngoài shell đăng nhập, để mở được sau khi tải lại lúc mất mạng.
  - Không đồng bộ từ màn offline, vì không biết chắc ai đang đăng nhập. Máy chỉ đồng bộ ở màn bán, theo nhân viên của context.
- Máy hỏi server bằng `GET offline_snapshot` không kèm token, thay cho `/up`. Server trả 401 nghĩa là vẫn tới được. Dev server Vite chỉ proxy `/api` và `/cable`.
- Client không gửi `If-None-Match`, vì SDK không nhận header riêng. Server vẫn trả 304 khi có header.
- Không có sự kiện realtime mới: màn xem lại hỏi lại mỗi 2 phút. Snapshot không làm mới theo sự kiện thực đơn, chỉ theo lịch 10 phút, khi đổi ca và khi có mạng lại.
- Màn xem lại chưa có giao diện cho `edited` (server đã có). Phiếu tạm in qua hộp thoại trình duyệt, chưa in thẳng ePOS / WebPRNT.
- Từ chối do người có quyền duyệt làm. Tiền mặt của đơn bị từ chối hiện là tiền thừa khi đếm két và xử lý qua đối soát tiền muộn.

**Còn mở**

- Tiêu chí đầu chưa tick: phần "bán khi server không truy cập được" đã qua e2e trên trang đang mở. Còn phần "mở app khi server tắt" thì chưa thử bản build có service worker do Rails / Caddy phục vụ. Cũng chưa kiểm header `Cache-Control: no-cache` của `sw.js`.
- Web manifest và icon cài app. Giao diện `edited`. Làm mới snapshot theo sự kiện thực đơn. In thẳng ePOS / WebPRNT khi offline.
- Dashboard chưa có trang theo dõi đơn offline. E2e báo cáo của `apps/pos-dashboard` chưa chạy, vì cổng 5176 đang dùng cho dev server.
- Kế toán / thuế cần duyệt việc hóa đơn điện tử máy tính tiền chỉ phát hành sau khi đồng bộ, và phiếu tạm khi offline.
- Chi nhánh có thuế bổ sung theo giá thì mọi đơn offline sẽ vào màn xem lại: máy chỉ ước giá theo thực đơn, không tính thuế.
- Thử trên máy thật, mất Wi-Fi thật với server LAN, và pilot tại quán.
- Full suite rspec / e2e chạy trên CI.

## Tiêu chí xong của plan

- [x] Mọi tiêu chí trong các phần đã đạt, hoặc được ghi rõ là còn mở kèm lý do.
- [ ] Đã review toàn bộ diff của plan và xử lý các phát hiện.
- [ ] Full suite của các phía bị đổi đã chạy và kết quả được ghi vào mục Kết quả.
