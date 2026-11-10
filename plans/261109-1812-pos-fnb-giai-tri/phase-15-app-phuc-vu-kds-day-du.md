---
phase: 15
title: "App phục vụ, KDS đầy đủ"
status: pending
effort: "9 ngày"
dependsOn: [5, 13, 14]
---

# Phase 15: App phục vụ (S2) và KDS đầy đủ (S3)

## Overview

Phase này làm chế độ `waiter` của app Flutter `apps/pos-staff`: phục vụ mở bàn, gọi món kèm modifier, báo bếp, nhận báo "món đã xong", gửi yêu cầu thanh toán, chuyển bàn và in phiếu kiểm đồ.

Song song, chế độ `kds` (đã có bản đầu ở phase 9) được nâng lên bản đầy đủ:
- nhiều trạm;
- định tuyến cơ bản đến trạm expo;
- gộp theo món (All-day);
- recall;
- báo hết món đồng bộ về S1 và S2;
- dữ liệu "chờ quá lâu" cho báo cáo.

Phase này **không thu tiền** trên app (plan.md D7). Mọi lệnh đi qua các endpoint của phase 13 và 14. App chỉ hiển thị dữ liệu và gửi lệnh có idempotency key.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Thông báo cho phục vụ chỉ đi qua realtime `BranchChannel` khi app đang mở. Ngoài ra có thông báo cục bộ (`flutter_local_notifications`) khi app chạy nền mà socket còn sống. **Không dùng FCM / APNs**, vì server LAN không ra internet được. Màn mở lại thì luôn refetch, nên không mất trạng thái. |
| Q2 | Phục vụ nhận "món xong" của **bàn mình đang phục vụ**: bàn có `added_by` là mình, hoặc bàn mình đã ghim. Cài đặt trên thiết bị có lựa chọn "nhận của mọi bàn trong khu". |
| Q3 | Trên S2, giỏ món là **bản nháp cục bộ** cho tới khi bấm "Thêm vào đơn". Lúc đó app gọi `append_items` (phase 14) với `append_batch_id` sinh trên máy, nên gửi lại khi mạng chập chờn không tạo dòng trùng. "Thêm và báo bếp" gọi liên tiếp `append_items` rồi `kitchen_sends`, mỗi lệnh một key. |
| Q4 | All-day là **phép gộp chỉ để hiển thị** trên KDS, theo `variant + modifiers` của các item `new` / `preparing` ở trạm. Không có bảng riêng. Bump trên All-day sẽ bump các item cũ nhất trước (FIFO). |
| Q5 | Trạm expo nhận bản sao "chỉ đọc" của mọi item thuộc ticket mà trạm prep đã bump `ready`. Bump ở expo chuyển item sang `served` và báo cho phục vụ. Course hold/fire, màn chạy bàn riêng và gọi món theo ghế để phase 18. |
| Q6 | Hết món: KDS hoặc thu ngân bấm "Hết món" thì tạo lệnh `Menu::MarkSoldOut` của phase 8 và phát `menu.sold_out`. S1 và S2 làm mờ món đó và chặn thêm vào giỏ (server vẫn là bên chặn). |
| Q7 | Ngưỡng màu timer theo trạm: `warn_after_seconds` (vàng), `late_after_seconds` (đỏ). Thời gian tính từ `fired_at` của server; thiết bị chỉ cộng độ lệch đồng hồ đo được khi kết nối. |
| Q8 | Phiếu kiểm đồ (`checklist`) liệt kê mọi món của đơn, kèm số lượng đã ra / chưa ra. In qua `PrintJob`, tới trạm in của khu hoặc máy in Bluetooth gắn với thiết bị phục vụ. |

## Dữ liệu

Migration `add_timing_thresholds_and_expo_to_pos_kitchen_stations`:
- `spree_pos_kitchen_stations`: `warn_after_seconds` (mặc định 600), `late_after_seconds` (mặc định 1200), `expo_station_id` (FK tự tham chiếu, nullable: trạm prep đẩy item `ready` về trạm expo này).

Migration `add_recall_and_timing_to_pos_kitchen_ticket_items`:
- `spree_pos_kitchen_ticket_items`: `recalled_at`, `recall_count`, `ready_at`, `served_at`, `prep_seconds` (tính khi `ready`), `late` (boolean, tính khi `ready`). Index `(station_id, status, fired_at)`.

Migration `create_spree_pos_device_table_pins`:
- `spree_pos_device_table_pins`: `device_id`, `resource_id`. Unique cặp. Dùng cho Q2.

## Server

- `Kitchen::Bump` mở rộng: chuyển `new → preparing → ready → served`, cho phép bump theo item, theo ticket hoặc theo All-day (Q4). Mỗi bước ghi giờ server và phát `kitchen_ticket.updated`.
- `Kitchen::Recall`: đưa item `ready` / `served` (trong N phút cuối, mặc định 30) về `preparing`, tăng `recall_count`, audit.
- `Kitchen::Board.for(station)`: dữ liệu cho KDS với ba tab: Ưu tiên (theo `fired_at`, ticket trễ lên đầu), Theo món (All-day), Theo bàn. Có lọc theo `service_mode`. Một truy vấn gộp.
- `Kitchen::ReadyFeed.for(device)`: item vừa `ready` / `served` của các bàn theo Q2, dùng cho thông báo của S2.
- `Reports::KitchenTiming`: thời gian chế biến trung bình và p90 theo trạm / món / giờ, số item trễ. Dữ liệu này dùng cho báo cáo ở phase 24.
- `Tables::Pin` / `Unpin` cho thiết bị phục vụ.
- Endpoint mới dưới `/api/v3/admin/pos/`: `kitchen/stations/:id/board`, `kitchen/items/:id/bump|recall`, `kitchen/stations/:id/all_day/bump`, `devices/current/ready_feed`, `devices/current/table_pins`, `workspaces/:id/checklist` (tạo `PrintJob` loại `checklist`). Cập nhật OpenAPI rồi sinh lại client Dart.
- Quyền:
  - thiết bị `kds` / `expo` gọi bump / recall bằng danh tính máy (phase 2), không cần nhân viên đăng nhập;
  - thiết bị `waiter` cần nhân viên đăng nhập bằng PIN có `pos.table.serve`.

## App Flutter (`apps/pos-staff`)

Chế độ `waiter`:
- **Danh sách bàn**: lưới ô lấy từ `resource_board` (phase 13), có lọc theo khu và theo trạng thái (Trống / Có khách / Chờ món / Yêu cầu thanh toán / Của tôi). Ô hiện số khách, phút ngồi, số món chờ.
- **Mở bàn**: nhập số khách bằng bàn phím số lớn. Bàn có hai đơn thì chọn đơn A / B.
- **Gọi món**: tab danh mục, tìm kiếm, ô món có ảnh nếu có. Chạm vào món mở bảng modifier (min/max, bắt buộc, giá cộng; dùng lại định nghĩa của phase 8) với ô ghi chú. Giỏ ở đáy màn có "Thêm vào đơn" và "Thêm và báo bếp".
- **Đơn của bàn**: dòng đã báo bếp có trạng thái từng món (mới / đang làm / xong / đã ra). Giảm món đã báo bếp mở hộp hủy món có lý do; nếu thiếu quyền thì hiện "Chờ quản lý duyệt" kèm mã yêu cầu `Approval`.
- **Hành động**: Báo bếp, Yêu cầu thanh toán, Chuyển bàn, Gộp bàn, In phiếu kiểm đồ, In tạm tính (lần đầu; in lại cần duyệt).
- **Thông báo**: băng "Bàn 5: Phở bò ×2 đã xong" kèm rung và âm. Chạm vào để mở bàn.
- Xung đột 409 `line_changed` / `snapshot_locked` hiện thông báo dễ hiểu rồi refetch.

Chế độ `kds` (bản đầy đủ):
- Chọn trạm khi ghép thiết bị; một thiết bị xem được nhiều trạm.
- Ba tab Ưu tiên / Theo món / Theo bàn. Ticket hiện số bàn hoặc số gọi, `service_mode`, giờ gửi, timer vàng / đỏ, modifier in đậm, ghi chú, và dòng hủy gạch ngang màu đỏ.
- Bump bằng chạm theo item hoặc cả ticket; giữ lâu để Recall. Có màn "Đã xong gần đây" để recall.
- Nút "Hết món" trên item.
- Màn hình luôn sáng (`wakelock_plus`), chữ lớn, hỗ trợ màn ngang 10–15 inch.

Chế độ `expo` cơ bản: danh sách item `ready` theo bàn; bump sang `served`.

Cấu trúc code: `lib/features/waiter/`, `lib/features/kds/`, `lib/features/expo/`, dùng chung `lib/core/api` (client sinh từ OpenAPI), `lib/core/realtime` và `lib/core/menu` (bảng modifier dùng chung).

## Client web (`apps/pos`)

- Thu ngân thấy yêu cầu thanh toán (phase 13) và trạng thái món theo dòng giống S2.
- Món hết hàng bị làm mờ trên `menu_grid` và `catalog-search.tsx` khi nhận `menu.sold_out`.

## File

| Hành động | File |
|---|---|
| Tạo | `server/db/migrate/*_add_timing_thresholds_and_expo_to_pos_kitchen_stations.rb`, `*_add_recall_and_timing_to_pos_kitchen_ticket_items.rb`, `*_create_spree_pos_device_table_pins.rb` |
| Tạo / sửa | `server/app/workflows/spree/pos/kitchen/{bump,recall}.rb`, `server/app/services/spree/pos/kitchen/{board,ready_feed}.rb`, `server/app/services/spree/pos/reports/kitchen_timing.rb`, `server/app/workflows/spree/pos/tables/{pin,unpin}.rb` |
| Sửa | `server/app/controllers/spree/api/v3/admin/pos/kitchen_*_controller.rb`, `server/config/routes.rb`, `server/openapi/pos-staff.yaml` |
| Tạo | `apps/pos-staff/lib/features/waiter/**`, `apps/pos-staff/lib/features/kds/**` (mở rộng phase 9), `apps/pos-staff/lib/features/expo/**`, `apps/pos-staff/lib/core/menu/modifier_sheet.dart`, `apps/pos-staff/lib/l10n/app_{vi,en}.arb` |
| Tạo | `apps/pos-staff/test/features/waiter/**`, `apps/pos-staff/test/features/kds/**`, `apps/pos-staff/integration_test/waiter_flow_test.dart` |
| Sửa | `apps/pos/src/components/{catalog-search,order-lines}.tsx`, `apps/pos/src/hooks/use-realtime.ts` (của phase 3) |

## Các bước

1. Server: ngưỡng trạm, recall, timing, All-day bump, ready feed, ghim bàn; spec cho từng lệnh.
2. Sinh lại client Dart từ OpenAPI; CI kiểm client đã commit khớp file.
3. Waiter: danh sách bàn → mở bàn → gọi món với modifier → thêm vào đơn → báo bếp.
4. Waiter: thông báo món xong, yêu cầu thanh toán, chuyển / gộp bàn, phiếu kiểm đồ, hủy món có duyệt.
5. KDS đầy đủ: ba tab, nhiều trạm, recall, hết món, timer.
6. Expo cơ bản.
7. Web: hiển thị trạng thái món và hết món.
8. Thử trên thiết bị thật: Sunmi (Android) làm KDS, điện thoại Android và iPhone làm S2, cùng server LAN của phase 6.

## Kiểm thử

- Server: `pnpm spree rspec spec/workflows/spree/pos/kitchen/ spec/services/spree/pos/kitchen/ spec/requests/spree/pos/kitchen_board_spec.rb spec/requests/spree/pos/ready_feed_spec.rb`.
- Flutter (trong `apps/pos-staff`): `flutter analyze`, `flutter test`, `flutter test integration_test/waiter_flow_test.dart` (chạy với server test có seed bàn và thực đơn).
- Spec bắt buộc:
  - bump All-day bump đúng item cũ nhất;
  - recall quá cửa sổ 30 phút bị từ chối;
  - thiết bị `kds` không gọi được `append_items`;
  - phục vụ không có `pos.table.serve` bị 403.
- Đo: từ lúc S2 bấm "Thêm và báo bếp" tới lúc ticket hiện trên KDS ≤ 2 giây trong LAN (dùng log thời gian server và thiết bị).

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| iOS ngắt socket khi app chạy nền nên phục vụ không nhận báo món xong | Q1: refetch khi mở lại app. Băng "Có n món xong" lấy từ `ready_feed`. Ghi rõ giới hạn trong tài liệu phase 16. |
| Bảng KDS chậm khi trạm đông ticket | `Board` một truy vấn có index `(station_id, status, fired_at)`; chỉ đẩy sự kiện mỏng, KDS refetch theo trạm. |
| Lệch đồng hồ thiết bị làm timer sai | Timer tính từ giờ server cộng độ lệch đo khi kết nối (Q7). |

## Tiêu chí xong

- [ ] Phục vụ trên Android và iOS mở bàn, gọi món có modifier, báo bếp, và nhận báo món xong trong LAN.
- [ ] KDS nhiều trạm có ba tab, timer vàng / đỏ, recall, và hết món đồng bộ về S1 / S2.
- [ ] Expo cơ bản chuyển món sang "đã ra" và báo cho phục vụ.
- [ ] Phiếu kiểm đồ in qua trạm in hoặc máy in Bluetooth.
- [ ] App không có màn hay lệnh thu tiền nào.
