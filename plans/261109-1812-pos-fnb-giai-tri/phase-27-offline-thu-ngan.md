---
phase: 27
title: "Hàng đợi offline cho thu ngân"
status: pending
effort: "6 ngày"
dependsOn: [12]
---

# Phase 27: Hàng đợi offline cho thu ngân (S1, đơn trả trước tại quầy)

## Overview

Khi thu ngân web (`apps/pos`) không kết nối được server (server LAN tắt / Wi-Fi rớt / VPS mất đường), thu ngân vẫn bán được **đơn trả trước tại quầy, thu tiền mặt**. Lệnh được xếp hàng trong IndexedDB và phát lại theo thứ tự khi có mạng. Đây là bậc 2 của research §6.6; bậc 1 (server LAN, D5) đã che phần lớn trường hợp mất internet. Luật nghiệp vụ vẫn chỉ chạy ở server (D6): khi offline client chỉ **ghi ý định**, server quyết định lúc phát lại.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Phạm vi offline: chỉ `service_mode = counter`, đơn mới, dòng `menu` / `ordinary` (không `measured`, `tracked`, `timed`), **chỉ tiền mặt**. VietQR, công nợ, giảm giá cần duyệt, trả hàng, đóng ca, bàn / trả sau đều bị khóa khi offline, nút hiện lý do. |
| Q2 | Mỗi đơn offline có `offline_id` (UUID v4 do client sinh) và mỗi lệnh có idempotency key suy ra từ `offline_id` + số thứ tự lệnh, nên phát lại nhiều lần vẫn chỉ tạo một workspace / một tender (dùng `CommandReceipt` hiện có). |
| Q3 | Phát lại bằng **một lệnh gộp** ở server `POST api/v3/admin/pos/offline_sales` (body: `offline_id`, register, shift, thời điểm client, dòng, tiền khách đưa) thay vì phát từng lệnh lẻ cần lease / revision. Server chạy tuần tự: tạo workspace → thêm dòng → tender tiền mặt → complete, tất cả qua các workflow hiện có trong một `CommandExecutor` với key `offline:<offline_id>`. |
| Q4 | Giá: server **tính lại** theo giá hiện tại. Nếu tổng khác tổng đã thu khi offline, đơn **không tự complete**: nó vào trạng thái `needs_review` (workspace park, tiền mặt đã thu ghi vào ghi chú bằng chứng) và hiện trên màn "Đơn offline cần xem lại". Món hết / ngừng bán cũng vào `needs_review`. Thu ngân chọn: chấp nhận giá đã thu (cần `Approval` `workspace.override_price` như hiện có) hoặc sửa đơn. |
| Q5 | Số hóa đơn: khi offline client in phiếu với **số tạm** `OFF-<mã quầy>-<số tăng dần cục bộ>` và dòng chữ "Phiếu tạm, chưa đồng bộ". Số đơn thật của Spree và số gọi do server cấp lúc phát lại. Hóa đơn điện tử (phase 7) chỉ phát hành sau khi phát lại thành công. |
| Q6 | Giờ bán: lưu `client_sold_at` để đối chiếu, nhưng `business_date` và `completed_at` theo server lúc phát lại cộng ghi chú `sold_offline_at`; báo cáo có cột "bán offline". Lệch giờ client lớn hơn 10 phút so với server lúc đồng bộ thì đánh dấu kiểm tra. |
| Q7 | Ca: chỉ bán offline khi ca đã mở trước lúc mất mạng (client có snapshot ca). Không mở / đóng ca offline. Tiền mặt offline cộng vào ca đó khi phát lại. |

## Dữ liệu

- Server: `spree_pos_offline_sales`: `store_id`, `branch_id`, `register_id`, `shift_id`, `offline_id` (unique theo store), `client_sold_at`, `payload` jsonb, `status` (`completed` \| `needs_review` \| `rejected`), `workspace_id`, `review_reason`, `resolved_by_id`, `resolved_at`.
- Client (IndexedDB qua `idb`): store `offline_sales` (`offline_id`, payload, `status`: `queued` \| `syncing` \| `synced` \| `needs_review` \| `failed`, `attempts`, `last_error`), store `catalog_snapshot` (thực đơn, giá, modifier, hết món tại lúc snapshot), store `context_snapshot` (chi nhánh, quầy, ca đang mở, mẫu in), counter số tạm theo quầy.

## Server

- Workflow `Spree::Pos::OfflineSales::Ingest`: kiểm ca (thuộc quầy, đang mở hoặc đã đóng sau `client_sold_at`: nếu ca đã đóng thì `needs_review` để quản lý gán ca), kiểm quyền nhân viên có trong payload (đã đăng nhập trước khi offline), rồi chạy chuỗi workflow hiện có. Bất kỳ `Conflict` nào trong chuỗi → `needs_review` kèm `reason`, không raise ra client.
- `Resolve`: hoàn tất đơn `needs_review` theo lựa chọn của thu ngân (đi đúng lệnh hiện có với lease bình thường).
- Endpoint: `POST offline_sales` (idempotent), `GET offline_sales?status=needs_review`, `POST offline_sales/:id/resolve`, `POST offline_sales/:id/reject` (hủy đơn và ghi lý do; tiền mặt đã thu ghi thành chênh lệch ca, có audit).
- `GET api/v3/admin/pos/offline_snapshot?register_id=`: gói thực đơn + giá + mẫu in + ca hiện tại để client lưu, có `generated_at` và `etag`.

## Client web `apps/pos`

- **PWA shell:** thêm `vite-plugin-pwa` (Workbox), manifest, service worker precache bundle, font, ảnh món nhỏ. Hiện `apps/pos` chưa có manifest / service worker. Chỉ cache tài nguyên tĩnh; API không cache trong service worker (snapshot nằm trong IndexedDB).
- Phát hiện offline: ping `GET /up` (hoặc endpoint context) thất bại 2 lần liên tiếp, không chỉ dựa `navigator.onLine`. Thanh trạng thái đỏ "Mất kết nối server — chế độ bán offline" kèm số đơn chờ đồng bộ.
- Màn bán offline: dùng lưới món hiện có đọc từ `catalog_snapshot`, ẩn / khóa các tính năng ngoài Q1, hộp tiền mặt (nhận, tiền thối), in phiếu tạm qua adapter trình duyệt / ePOS / WebPRNT (trạm in Flutter cần server nên không dùng được khi server mất).
- Đồng bộ: khi server trở lại, `OfflineSyncWorker` gửi từng đơn theo thứ tự `client_sold_at`, tối đa 1 đơn cùng lúc, backoff khi lỗi mạng; kết quả `needs_review` chuyển sang màn "Đơn offline cần xem lại".
- `session-coordinator.ts`: không đăng xuất / làm mới token khi offline; token hết hạn trong lúc offline thì yêu cầu đăng nhập lại trước khi đồng bộ (đơn vẫn nằm trong IndexedDB).
- Snapshot làm mới mỗi 10 phút khi online và mỗi khi thực đơn đổi (sự kiện realtime phase 3).

## File

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

## Các bước

1. Server: model, `Ingest` với spec phát lại hai lần chỉ một đơn; giá lệch → `needs_review`; ca đã đóng → `needs_review`; món hết → `needs_review`.
2. `Resolve` / `Reject` + spec dùng `Approval` sửa giá hiện có.
3. Endpoint snapshot, cập nhật OpenAPI.
4. Client: PWA shell, kiểm tra app tải được khi tắt server.
5. Client: IndexedDB store, phát hiện offline, màn bán offline giới hạn, số tạm, in phiếu tạm.
6. Client: sync worker, màn xem lại, thanh trạng thái.
7. Báo cáo cột bán offline; tài liệu hướng dẫn thu ngân.

## Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/offline_sales/ spec/requests/spree/pos/offline_sales_spec.rb`.
- `pnpm --dir apps/pos test`: vitest cho store, sync worker (mock fetch), số tạm, lọc tính năng.
- Playwright: chặn mạng tới API (`page.route` abort) → bán 3 đơn tiền mặt → mở lại → 3 đơn complete, ca có đúng tiền; một đơn có giá đổi trong lúc offline vào màn xem lại.
- `pnpm --dir apps/pos lint`, `typecheck`, `build` (service worker sinh đúng).

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Hai máy bán offline trùng số tạm | Số tạm có mã quầy; số thật do server cấp. |
| Gian lận: bán offline rồi xóa IndexedDB | Đơn offline có audit khi đồng bộ; tiền mặt ca lệch lộ ra khi đóng ca; ghi rõ giới hạn trong tài liệu. |
| Giá / thuế khác lúc đồng bộ | Server tính lại, lệch thì `needs_review`, không tự complete. |
| Service worker giữ bản cũ sau khi deploy | Prompt "Có bản mới, tải lại" khi online; không tự reload giữa lúc bán. |
| Token hết hạn khi offline lâu | Giữ đơn, đòi đăng nhập lại trước đồng bộ. |

## Tiêu chí xong

- [ ] `apps/pos` mở được và bán đơn tiền mặt trả trước khi server không truy cập được.
- [ ] Khi server trở lại, đơn đồng bộ đúng thứ tự, không trùng, ca đúng tiền.
- [ ] Đơn lệch giá / hết món / ca đóng vào màn xem lại và được xử lý bằng luồng có duyệt.
- [ ] Mọi tính năng ngoài phạm vi offline bị khóa có lý do hiển thị.
- [ ] Server spec, vitest, Playwright, build xanh.
