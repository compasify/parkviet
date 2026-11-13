---
title: "Màn bán theo ngành F&B còn lại"
description: "Đưa cafe, căng tin, karaoke-bida và bar sang bố cục hai vùng như màn bán tại bàn: quầy nhanh cho quán trả trước, bảng phòng tính giờ, tab quầy bar. Nhà hàng đã xong ở plan trước."
status: in-progress
priority: P1
effort: "~9 ngày công"
branch: "v2"
tags: [feature, frontend, fnb, pos]
blockedBy: []
blocks: []
created: "2026-11-14"
createdBy: "ak:plan"
source: skill
---

# Màn bán theo ngành F&B còn lại

## Overview

Plan [Màn bán riêng cho phục vụ tại bàn](../261113-1708-pos-ban-tai-ban-layout/plan.md) đã dựng bố cục hai vùng (rail danh mục + lưới món chữ | phiếu bên phải, thanh toán toàn màn) cho chi nhánh có `fnb.tables` với bề mặt `floor_plan` / `table_grid` / `menu_grid`. Plan này đưa bốn ngành còn lại sang cùng hệ bố cục theo mockup màn 5–8. Logic nghiệp vụ của từng ngành đã có và giữ nguyên; chỉ bố cục là mới.

- Mockup: [mockup.html](../261113-1623-pos-fnb-layout-mockup/mockup.html), màn 5 Bảng phòng tính giờ, 6 Gọi món trong phòng, 7 Tab quầy bar, 8 Quầy nhanh. Ảnh: [screens/](../261113-1623-pos-fnb-layout-mockup/screens).
- Research: [researcher-261113-1623-fnb-pos-layout-research.md](../reports/researcher-261113-1623-fnb-pos-layout-research.md), mục 4 (quy tắc 3–10) và câu hỏi mở 2.
- Tính năng từng ngành đối chiếu với trang ngành hàng trên parkviet.com (14/11/2026).

## Hiện trạng theo ngành

`sellingLayoutOf` (`packages/pos-shared/src/pos-modules.ts`) chọn bố cục từ module và bề mặt của hồ sơ ngành (`server/config/pos/business_profiles.yml`):

| Ngành | Module, bề mặt | Màn bán hiện nay | Việc cần làm |
|---|---|---|---|
| Nhà hàng | `fnb.tables`, `floor_plan` | Bố cục bàn mới | Không cần phase mới. Việc lẻ còn lại nằm ở phase 8–12 của plan trước. |
| Cafe & Trà sữa | `fnb.menu`, không bàn, `menu_grid` | Ba cột kiểu bán lẻ (`WorkspaceTabs`) | Phase 1: quầy nhanh |
| Căng tin & Trạm dừng | `fnb.menu`, `fnb.meal_accounts`, `fnb.vehicle_commission`, `menu_grid` | Ba cột kiểu bán lẻ | Phase 2: quầy nhanh có mã suất ăn và lượt xe |
| Karaoke & Bida | `fnb.tables`, `timed_billing`, `resource_board` | Ba cột, bảng phòng sau nút "Sơ đồ bàn" | Phase 3: bảng phòng tính giờ |
| Bar, Pub & Club | `fnb.tables`, `tab_list` | Ba cột, danh sách tab trong cột trái | Phase 4: tab quầy bar |

Quán ăn không bật bàn cũng là `fnb.menu` không có `fnb.tables`, nên cũng dùng quầy nhanh của phase 1.

## Quyết định thiết kế

| # | Quyết định |
|---|---|
| N1 | `sellingLayoutOf` trả thêm `quick_counter` khi có `fnb.menu` mà không có `fnb.tables`; bán lẻ (không `fnb.menu`) vẫn `counter`. `table_service` mở cho cả `resource_board` và `tab_list`. Vẫn chỉ kiểm module và bề mặt, không kiểm tên ngành. |
| N2 | Mọi bố cục mới dùng lại `useSellingWorkspace`, rail, lưới món, panel tùy chọn, phiếu và `PaymentPanel` của plan trước. Không chép logic. |
| N3 | Quầy nhanh mở thẳng màn gọi món, không có bảng bàn; thanh toán nằm ngay trong phiếu vì đơn trả trước đóng trong vài giây. |
| N4 | Bảng phòng và tab bar là biến thể của khung `board` / `order` của `TableServiceScreen`, không phải màn thứ tư. |
| N5 | Không thêm tính năng nghiệp vụ mới. "Minimum spend" của bar trong mockup bỏ vì trang ngành không hứa; giao diện tối theo máy vẫn ngoài phạm vi. |

## Nguyên tắc bất biến

1. Chi nhánh bán lẻ giữ nguyên hành vi và DOM của màn bán hiện tại.
2. Mọi lệnh ghi vẫn đi qua `useWorkspaces` và `CommandExecutor` với idempotency key.
3. Màu không bao giờ là tín hiệu duy nhất.
4. Chuỗi hiển thị mới có trong cả `vi` và `en`.
5. Chỉ chạy spec của file đã đổi; GitHub Actions chạy bộ đầy đủ.

## Phases

| # | Phase | Effort | Phụ thuộc | Trạng thái |
|---|---|---|---|---|
| 1 | [Quầy nhanh cho cafe và trà sữa](./phase-01-quay-nhanh-cafe.md) | 2,5 ngày | – | xong |
| 2 | [Căng tin và trạm dừng trên quầy nhanh](./phase-02-cang-tin-tram-dung.md) | 1,5 ngày | 1 | chưa làm |
| 3 | [Bảng phòng tính giờ cho karaoke và bida](./phase-03-karaoke-bida.md) | 3 ngày | – | chưa làm |
| 4 | [Tab quầy bar cho bar, pub và club](./phase-04-bar-pub-club.md) | 2 ngày | – | chưa làm |

Phase 1, 3, 4 độc lập về bố cục nhưng cùng sửa `sellingLayoutOf`, `table-service-screen.tsx` và locale POS, nên làm lần lượt 1 → 2 → 3 → 4. Mỗi phase tự cập nhật e2e và tài liệu ngành của mình.

## Tiêu chí nghiệm thu

- [ ] Cafe mở POS thấy ngay màn gọi món có số gọi to ở đầu phiếu, chọn loại đơn một chạm, ô món có ảnh, thanh toán trong phiếu; xong đơn thì phiếu trống cho đơn kế.
- [ ] Căng tin gõ mã suất ăn ngay trên màn bán, nghe âm báo hợp lệ/trùng/lỗi; trạm dừng mở và gắn lượt xe từ màn bán.
- [ ] Karaoke mở POS thấy bảng phòng toàn màn với đồng hồ lớn, cam khi còn ≤10 phút, đỏ khi hết giờ, xám khi tạm dừng; thanh toán khi đồng hồ chạy hỏi "Dừng giờ và thanh toán?".
- [ ] Bar mở POS thấy danh sách tab bên trái, thực đơn giữa, phiếu phải; chuyển sang sơ đồ bàn VIP một chạm.
- [ ] Bán lẻ không đổi: e2e `full-retail` qua. E2E `fnb-call-number`, `meal-accounts`, `vehicle-visits`, `karaoke`, `bar-tabs` qua sau khi sửa theo bố cục mới.
- [ ] `pnpm typecheck`, `pnpm lint`, unit test và e2e của file đã đổi trong `apps/pos` đều qua.

## Rủi ro

- `WorkspaceTabs` vẫn là màn của bán lẻ; nhiều công cụ ngành (ô mã suất ăn, `VehicleVisitBar`, `TabList`, `TimedPanel`) đang gắn vào nó. Mỗi phase dời công cụ của ngành mình sang bố cục mới và xóa nhánh ngành đó khỏi `WorkspaceTabs` khi không còn ai dùng.
- Quầy nhanh đổi màn của mọi quán `fnb.menu` không bàn cùng lúc. Có thể cần cờ theo máy để quay về màn cũ trong vài tuần đầu (câu hỏi mở 2).

## Câu hỏi còn mở

1. Quầy nhanh có cần hàng chờ pha ("Đang làm / Mời nhận") ngay trên màn thu ngân, hay chỉ trên màn khách như hiện nay?
2. Có giữ đường quay về màn ba cột cũ cho quán `fnb.menu` (cài đặt theo máy) trong thời gian chuyển đổi không?
3. Karaoke: thao tác Bắt đầu/Dừng, Gọi món, Thanh toán đặt ngay trên ô phòng như mockup, hay chạm ô mới hiện?
