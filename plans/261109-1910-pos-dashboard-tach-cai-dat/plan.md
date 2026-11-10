---
title: "Tách cài đặt POS thành app riêng apps/pos-dashboard"
description: "Dựng app quản trị POS riêng trên @spree/dashboard-core và @spree/dashboard-ui, chuyển toàn bộ trang cài đặt khỏi apps/pos, tách logic thuần dùng chung vào packages/pos-shared, không sửa apps/dashboard."
status: done
priority: P2
effort: "~12 ngày công"
branch: "v2"
tags: [refactor, frontend]
blockedBy: []
blocks: []
created: "2026-11-09"
createdBy: "ak:plan"
source: skill
---

# Tách cài đặt POS thành app riêng `apps/pos-dashboard`

## Overview

POS sẽ còn mở rộng nhiều (xem [plan F&B](../261109-1812-pos-fnb-giai-tri/plan.md)), trong khi các trang cài đặt hiện nằm trong `apps/pos`. Chúng dùng CSS tự viết ([styles.css](../../apps/pos/src/styles.css)), CSS này gán style chung cho mọi `button`, `input`, `form`, nên giao diện không theo chuẩn admin. Ngoài ra, mỗi lần sửa cài đặt lại phải build và test lại màn bán hàng.

Plan này dựng một app quản trị riêng là `apps/pos-dashboard`, chạy ở port riêng và deploy riêng như `apps/pos`. App dùng lại khung của Spree qua npm: `@spree/dashboard-core` lo đăng nhập, phân quyền, `AppShell`, nav registry và `SettingsSidebar`, còn `@spree/dashboard-ui` cung cấp Button, Card, DataTable, Dialog, Field… Cách làm giống `apps/seller-dashboard`. Logic thuần dùng chung giữa hai app (dựng mẫu hóa đơn, tem cân, danh sách module và tính năng) được tách vào `packages/pos-shared`.

## Quyết định đã chốt (09/11/2026)

| # | Quyết định |
|---|---|
| D1 | **Không sửa `apps/dashboard`.** Nếu sau này muốn có link từ Spree dashboard thì làm ở một việc riêng. |
| D2 | **App riêng `apps/pos-dashboard`** chạy ở port riêng, cố định `5176` (`apps/pos` dùng `5175`). Gắn domain là việc của hạ tầng: code không chứa domain nào, chỉ đọc URL qua biến môi trường. |
| D8 | **Cắt hẳn.** Phase 7 xóa trang cũ trong `apps/pos` ngay khi trang mới đã qua e2e, không giữ song song. |
| D9 | **Trang thiết lập lần đầu (`/setup`) chuyển sang `apps/pos-dashboard`.** POS chỉ hiện thông báo kèm link khi cửa hàng chưa được thiết lập. |
| D3 | **Khung UI chỉ lấy từ npm:** `@spree/dashboard-core` và `@spree/dashboard-ui`, cùng phiên bản `6.0.3` với `apps/dashboard`. Không dùng `@spree/dashboard`, vì đó là shell của Spree dashboard. |
| D4 | **Menu POS nằm trên sidebar chính.** Mỗi mục có `if` riêng theo quyền. Các cài đặt ít dùng đặt dưới `/settings` của app, dùng `SettingsSidebar` và `settingsNav`, nên giao diện giống trang Settings của Spree. |
| D5 | **API và quyền phía server giữ nguyên.** Vẫn gọi `/api/v3/admin/pos/...` bằng `adminClient`. Quyền cấp cửa hàng là `read_pos_topology` / `write_pos_topology`. Quyền cấp chi nhánh là `pos.topology.manage`, và quản lý chi nhánh chỉ thấy Tính năng và Mô hình kinh doanh của chi nhánh mình. |
| D6 | **`packages/pos-shared` chỉ chứa TypeScript thuần**: không có React, không gọi API. Hai app tham chiếu qua `link:../../packages/pos-shared`. Hook gọi API được viết riêng ở mỗi app. |
| D7 | **Màn bán hàng, phần in và phần vận hành ở lại `apps/pos`**: ca, duyệt, công nợ, kho, báo cáo ca, hiệu chỉnh máy quét, chọn máy in, PIN màn khách. |

## Nguyên tắc bất biến

- Không đổi hành vi nghiệp vụ. Mỗi trang chuyển sang phải làm đúng những gì trang cũ làm, kể cả các trạng thái quyền (chỉ đọc, bị cấm, quản lý chi nhánh).
- Không thêm endpoint mới nếu endpoint cũ đã đủ. Nếu thiếu thì thêm vào API trước, theo `server/AGENTS.md`.
- Mọi chuỗi hiển thị đều qua i18next, có cả `vi` và `en`.
- Chỉ xóa trang cũ trong `apps/pos` ở phase cắt chuyển, sau khi trang mới đã chạy và qua e2e.

## Phases

| # | Phase | Phụ thuộc | Effort | Trạng thái |
|---|---|---|---|---|
| 1 | [Tách `packages/pos-shared`](phase-01-tach-pos-shared.md) | — | 1.5d | done |
| 2 | [Dựng khung `apps/pos-dashboard`](phase-02-khung-pos-dashboard.md) | — | 2d | done |
| 3 | [Hook API, ngữ cảnh POS và gate quyền](phase-03-hook-api-va-quyen.md) | 2 | 1.5d | done |
| 4 | [Chi nhánh, quầy, nhân viên, sản phẩm, tem cân](phase-04-trang-chi-nhanh.md) | 1, 3 | 2d | done |
| 5 | [Tính năng, mô hình kinh doanh, thiết lập lần đầu](phase-05-tinh-nang-mo-hinh.md) | 1, 3 | 1.5d | done |
| 6 | [Mẫu in hóa đơn: danh sách và trình sửa](phase-06-mau-in-hoa-don.md) | 1, 3 | 2d | done |
| 7 | [Cắt chuyển trong `apps/pos`](phase-07-cat-chuyen-pos.md) | 4, 5, 6 | 1d | done |
| 8 | [Deploy và tài liệu](phase-08-deploy-tai-lieu.md) | 7 | 0.5d | done |

Phase 1 và phase 2 chạy song song được, vì không đụng file của nhau. Phase 4, 5 và 6 cũng song song được sau khi xong phase 1 và 3.

## Tiêu chí hoàn thành

1. `apps/pos-dashboard` đăng nhập được bằng tài khoản admin. Sidebar chính có menu POS với đủ các mục ở D4, và mục nào cũng ẩn hoặc hiện đúng theo quyền.
2. Mọi trang trong `apps/pos/src/pages/settings/*` và `/setup` đều có bản tương đương trong `apps/pos-dashboard`, dựng hoàn toàn bằng component của `@spree/dashboard-ui`, không có CSS tự viết cho layout, nút hay bảng.
3. Quản lý chi nhánh có `pos.topology.manage` nhưng không có quyền cấp cửa hàng chỉ thấy Tính năng và Mô hình kinh doanh của chi nhánh mình. Tài khoản không có quyền POS thì không thấy menu nào và mở URL trực tiếp sẽ ra trang 403.
4. `apps/pos` không còn route `/settings*` hay `/setup`. Các link cũ mở sang `apps/pos-dashboard` qua biến môi trường `VITE_POS_DASHBOARD_URL`.
5. Bản in thật trong POS và bản xem trước trong trình sửa mẫu dùng cùng một bộ dựng trong `packages/pos-shared`.
6. Cả ba nơi đều xanh: `pnpm typecheck && pnpm lint && pnpm test && pnpm build` trong `apps/pos`, trong `apps/pos-dashboard`, và `pnpm test` trong `packages/pos-shared`. E2e của các trang cài đặt đã chuyển sang `apps/pos-dashboard` và chạy xanh.
7. `git diff --stat` không có file nào thuộc `apps/dashboard/`.

## Rủi ro

| Rủi ro | Cách xử lý |
|---|---|
| API nội bộ của `dashboard-core` (`setApiClient`, `AppShell`, nav registry) đổi khi nâng Spree | Khóa cùng phiên bản với `apps/dashboard`. Khi nâng thì đọc diff của `apps/seller-dashboard`, vì đó là app dùng cùng khung. |
| Tailwind không quét class của `dashboard-core` vì không có vite plugin của Spree | Phase 2 thêm `@source` cho `dashboard-core` và kiểm tra bằng build. |
| Đăng nhập riêng theo origin, refresh bị `StaffSessionOriginGuard` chặn | Khi hạ tầng gắn domain, thêm origin đó vào Allowed Origins (phase 8). Dev dùng proxy `/api` nên cùng origin. |
| Trình sửa mẫu in lớn (956 dòng) và phụ thuộc nhiều component POS | Tách riêng thành phase 6, và giữ nguyên cách dựng xem trước từ `pos-shared`. |

## Review 10/11/2026

Đã sửa sau review:
- `normalizeContext` và `ORDER_SOURCES` chuyển vào `pos-shared`.
- Chỉ chuyển sang `/setup` khi có `can_setup`.
- Trang Tem cân vẫn vào được khi module tắt.
- Trang 403 qua i18n.
- Phiếu in và bản xem trước dùng chung `renderSheetHtml` trong `pos-shared`.
- `pos-shared` có locale riêng.
- Locale của pos-dashboard bỏ khoảng 1.400 key thừa.
- Đăng nhập lại quay về đúng trang, bản nháp mẫu in được giữ khi mất phiên.

Phase 7: `paper-picker.tsx` cũng bị xóa, vì `template-picker.tsx` chỉ dùng class CSS `.paper-picker*` (vẫn giữ). Link quản trị trong POS mở tab mới để không ảnh hưởng lease của hóa đơn đang mở.

E2E POS có 4 test fail từ trước khi refactor, đã kiểm tra trên `0b38ba1`: `inventory-traceability:711`, `layout-recovery:4`, `pages-polish:88`, `ui-polish:5`.

Phase 8: bản build chạy bằng `pnpm preview` ở cổng 5176 (proxy `/api` như dev); e2e desktop chạy trên bản build: 43 qua, 2 bỏ qua (cần API thật). Deep link trả 200, `/api` qua proxy tới API dev. Chưa thử đăng nhập bằng tài khoản thật.

## Câu hỏi còn mở

Không còn. Các câu đã hỏi được ghi ở D2, D8 và D9.

## Validation Log

### Verification Results (09/11/2026)
- Claims checked: 22. Verified: 20. Fixed: 2. Unverified: 1.
- Fixed: `apps/pos/.env.example` chưa tồn tại, nên phase 7 đổi từ sửa sang tạo mới. `paper-picker.tsx` vẫn được `template-picker.tsx` của màn bán hàng dùng, nên phase 7 giữ lại.
- Unverified: `@spree/admin-sdk` có hàm gửi request tùy ý để gọi endpoint POS hay không. Phase 3 xác nhận việc này trước tiên.
