---
title: "Màn bán riêng cho phục vụ tại bàn"
description: "Tách màn bán của chi nhánh có bàn khỏi màn bán lẻ: bảng bàn làm màn đầu, màn gọi món hai vùng có phiếu bên phải, tùy chọn món thay chỗ lưới món, thanh toán toàn màn."
status: completed
priority: P1
effort: "~13 ngày công"
branch: "v2"
tags: [feature, frontend, backend, fnb, pos]
blockedBy: []
blocks: []
created: "2026-11-13"
createdBy: "ak:plan"
source: skill
---

# Màn bán riêng cho phục vụ tại bàn

## Overview

Màn bán `apps/pos` hiện dùng chung một bố cục ba cột (thực đơn | giỏ | thanh toán) cho bán lẻ và F&B. Chi nhánh có bàn chỉ thấy bảng bàn sau nút bật/tắt "Sơ đồ bàn", và cột thanh toán luôn chiếm chỗ. Plan này dựng một bố cục riêng cho phục vụ tại bàn theo mockup màn 1–4 và 10 quy tắc layout trong báo cáo research. Logic bán (lệnh workspace, gửi bếp, hủy món, chuyển gộp tách bàn, tạm tính, thanh toán) giữ nguyên và được dùng lại; chỉ bố cục là mới.

- Mockup: [mockup.html](../261113-1623-pos-fnb-layout-mockup/mockup.html), màn 1 Bảng bàn, 2 Gọi món tại bàn, 3 Tùy chọn món, 4 Thanh toán. Ảnh: [screens/](../261113-1623-pos-fnb-layout-mockup/screens).
- Research: [researcher-261113-1623-fnb-pos-layout-research.md](../reports/researcher-261113-1623-fnb-pos-layout-research.md), mục 4 "Mẫu layout nên áp dụng".
- Nền nghiệp vụ đã có: plan [POS F&B và giải trí](../261109-1812-pos-fnb-giai-tri/plan.md), hướng dẫn [Bán tại bàn và trả tiền sau](../../docs/pos/fnb-ban-va-tra-sau.md).

## Kết quả mong muốn

Thu ngân ở chi nhánh có bàn mở POS là thấy bảng bàn toàn màn. Chạm bàn thì vào màn gọi món với phiếu bên phải, gọi món, bấm "Gửi bếp (n)" rồi tự quay về bảng bàn. Khi khách trả tiền, "Thanh toán · tổng" mở màn thanh toán toàn màn có VietQR hiện sẵn; hoàn tất thì về bảng bàn. Chi nhánh bán lẻ không thấy gì thay đổi.

## Phạm vi

| Trong phạm vi | Ngoài phạm vi (plan sau) |
|---|---|
| Bảng bàn (lưới ô và sơ đồ), ô Mang về / Giao đi | Bảng phòng tính giờ karaoke, bida (`resource_board`) |
| Màn gọi món: rail danh mục, lưới món chữ, 3 mức mật độ | Tab quầy bar (`tab_list`) |
| Phiếu bàn: nhóm theo lượt / course / ghế, món mới ở trên, gửi bếp, giữ món, gửi & ở lại | Quầy nhanh cafe trả trước |
| Tùy chọn món dạng panel thay chỗ lưới món | Giao diện tối theo máy |
| Thanh toán toàn màn, VietQR hiện sẵn, chia và tách bill | App phục vụ, màn bếp (`apps/pos-staff`) |
| Lượt gửi bếp trên từng dòng món, ngưỡng "ngồi lâu" theo chi nhánh | Đổi luật nghiệp vụ hay API ghi đơn |

## Quyết định thiết kế

| # | Quyết định |
|---|---|
| L1 | Bố cục mới bật khi chi nhánh chạy `fnb.tables` và bề mặt của hồ sơ ngành **không phải** `tab_list` hay `resource_board`. Bar và karaoke giữ màn hiện tại tới plan của chúng. Hàm quyết định nằm ở `packages/pos-shared` (`sellingLayoutOf`), code chỉ kiểm module và bề mặt, không kiểm tên ngành (giữ D9 của plan F&B). |
| L2 | Tách trạng thái và lệnh của `WorkspaceTabs` thành hook `useSellingWorkspace` dùng chung cho hai bố cục. Không viết lại lệnh, không sao chép logic. |
| L3 | Màn bán tại bàn có ba khung trong cùng route `/`: `board`, `order`, `pay`. Khung hiện tại ghi vào search `?order=…&view=pay` để tải lại trang mở đúng chỗ. |
| L4 | Phiếu nằm bên phải, rộng 400–420px (thói quen KiotViet, Square; nút thanh toán hợp tay phải). |
| L5 | Ô bàn chỉ dùng 5 màu nền: trống, đang phục vụ, có món chưa gửi (viền đứt cam), đã in tạm tính, gọi thanh toán. Chờ món lâu và ngồi quá ngưỡng là dải đỏ và chữ đỏ, không đổi nền. Đặt trước, lỗi in bếp, bàn gộp là biểu tượng góc. |
| L6 | Dòng món mang số lượt gửi bếp (`kitchen_send_sequence`) do server tính từ phiếu bếp đã có; không thêm bảng mới. |
| L7 | Gửi bếp xong mặc định về bảng bàn; "Gửi & ở lại" giữ người dùng ở màn gọi món. |
| L8 | Thanh toán dùng lại `PaymentPanel` trong khung toàn màn, không viết lại luồng tiền. |

## Nguyên tắc bất biến

1. Chi nhánh không bật `fnb.tables` giữ nguyên hành vi và DOM của màn bán hiện tại.
2. Mọi lệnh ghi vẫn đi qua `useWorkspaces` và `CommandExecutor` phía server với idempotency key như hiện nay.
3. Màu không bao giờ là tín hiệu duy nhất: mỗi trạng thái có chữ hoặc biểu tượng đi kèm (giữ quy ước của `tableStateKey`).
4. Chuỗi hiển thị mới có trong cả `vi` và `en`.
5. Chỉ chạy spec của file đã đổi; GitHub Actions chạy bộ đầy đủ.

## Phases

| # | Phase | Effort | Phụ thuộc | Trạng thái |
|---|---|---|---|---|
| 1 | [Chọn bố cục và tách hook bán hàng](./phase-01-chon-bo-cuc-va-tach-hook.md) | 2,5 ngày | – | xong |
| 2 | [Server: lượt gửi bếp trên dòng món, ngưỡng ngồi lâu](./phase-02-server-luot-gui-bep-nguong-ngoi-lau.md) | 1,5 ngày | – | xong |
| 3 | [Bảng bàn](./phase-03-bang-ban.md) | 2 ngày | 1, 2 | xong |
| 4 | [Màn gọi món: rail, lưới món, panel tùy chọn](./phase-04-man-goi-mon-thuc-don.md) | 2 ngày | 1 | xong |
| 5 | [Phiếu bàn](./phase-05-phieu-ban.md) | 2,5 ngày | 2, 4 | xong |
| 6 | [Thanh toán toàn màn](./phase-06-thanh-toan-toan-man.md) | 1,5 ngày | 5 | xong |
| 7 | [E2E, tài liệu và rà soát](./phase-07-e2e-tai-lieu-ra-soat.md) | 1 ngày | 3–6 | xong |

Phase 1 và 2 độc lập, chạy song song được. Phase 3 và 4 độc lập sau phase 1 (phase 3 cần thêm trường của phase 2).

## Tiêu chí nghiệm thu

- [x] Chi nhánh nhà hàng mở POS thấy bảng bàn toàn màn, không có thanh tab hóa đơn, cột giỏ hay cột thanh toán.
- [x] Ô bàn hiện tên, thời gian ngồi (to nhất), trạng thái bằng chữ, số khách, tạm tính; đúng 5 màu nền; ngồi quá ngưỡng chi nhánh thì có dải đỏ.
- [x] Chạm bàn trống hỏi số khách tại chỗ rồi mở màn gọi món; chạm bàn có khách vào thẳng màn gọi món.
- [x] Màn gọi món có rail danh mục, lưới món chữ có huy hiệu số lượng, món hết làm mờ; phiếu bên phải nhóm theo lượt gửi, món mới ở trên.
- [x] "Gửi bếp (n)" bị khóa khi n = 0, gửi xong về bảng bàn; "Gửi & ở lại" ở lại.
- [x] Món có tùy chọn mở panel thay chỗ lưới món, phiếu vẫn hiện; nút thêm khóa khi thiếu nhóm bắt buộc.
- [x] "Thanh toán · tổng" mở màn thanh toán toàn màn có VietQR hiện sẵn; hoàn tất về bảng bàn; tải lại trang giữ đúng khung.
- [x] Chi nhánh bán lẻ, bar `tab_list` và karaoke `resource_board` không đổi: e2e `full-retail`, `bar-tabs`, `karaoke` vẫn qua.
- [x] `pnpm typecheck`, `pnpm lint`, unit test và e2e của file đã đổi trong `apps/pos` đều qua; rspec của file server đã đổi qua.

## Rủi ro

- `WorkspaceTabs` dài 1853 dòng; tách hook (phase 1) có thể làm lệch hành vi tinh vi (lease, serializer lệnh, URL `?order`). Giảm rủi ro: tách thuần, không đổi logic, chạy e2e `lease`, `lease-recovery`, `tables`, `table-kitchen-send`, `layout-recovery` trước khi qua phase 3.
- Các e2e hiện có của chi nhánh có bàn (`tables`, `table-kitchen-send`, `fnb-wave2`, `guest-orders`, `reservations`) đang đi qua nút "Sơ đồ bàn" của màn cũ và sẽ phải sửa theo bố cục mới. Mỗi phase sửa spec chạm tới phần nó đổi.
- Quán ăn có bàn hiện mở thẳng lưới thực đơn; theo L1 sẽ mở bảng bàn. Đây là đổi hành vi có chủ đích, cần cập nhật tài liệu (phase 7).
- Màn 1366px: phiếu 410px + rail 116px còn khoảng 840px cho lưới món; nếu chật thì giảm số cột, không thu nhỏ ô.

## Câu hỏi còn mở

1. Quán ăn có bàn có chuyển sang mở bảng bàn như nhà hàng không (L1), hay giữ mở thẳng thực đơn?
2. Ngưỡng "ngồi lâu" mặc định 60 phút, cấu hình theo chi nhánh trong pos-dashboard (phase 2): giữ vậy hay cấu hình theo khu / loại bàn?
3. Có cần hỏi nhanh 2–3 thu ngân để xác nhận phiếu đặt bên phải trước khi làm phase 5 không?

Trả lời của chủ quán (13/11/2026): (1) đúng, quán ăn có bàn mở bảng bàn; (2) ăn uống ở Việt Nam không tính giờ, thời gian ngồi chỉ để tham khảo: cảnh báo ngồi lâu là tùy chọn mặc định tắt, bật lên thì gợi ý 180 phút; (3) không cần hỏi thu ngân, giữ phiếu bên phải.

## Việc còn lại sau plan

- Server chưa có hạn cho mã VietQR đang chờ: tắt tab hoặc mất mạng khi đang ở màn thanh toán để lại mã treo, khóa thêm món tới khi có người bấm "← Đơn".
- Ô "Mang về" / "Giao đi" tạo đơn nháp mới mỗi lần chạm, kể cả khi còn đơn trống.
- Ghi chú nhanh cố định trong locale; chip số khách chỉ xem (chưa có API sửa); chưa có biểu tượng lỗi in bếp và bàn gộp trên ô bàn.
- Rà soát mã: [code-reviewer-261113-1901-table-service-layout-review.md](../reports/code-reviewer-261113-1901-table-service-layout-review.md).
