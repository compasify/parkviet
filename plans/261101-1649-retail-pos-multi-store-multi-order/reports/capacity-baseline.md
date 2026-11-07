# Capacity baseline POS (mẫu)

**Chưa đo.** Không có con số nào trong tài liệu này là năng lực đã chứng minh. Hồ sơ tải đề xuất bên dưới là giả định cần kiểm, không phải hạn mức hay SLA. POS không có hạn mức cứng số chi nhánh, quầy hay tab.

## 1. Mục tiêu đề xuất (theo plan, đo trên LAN staging)

| Tương tác | Mục tiêu | Cách đo |
|---|---|---|
| Chuyển tab đơn | < 100 ms | `apps/pos/tests/performance/pos-scenarios.ts` (`tab_switch`) |
| Tìm hàng | p95 < 500 ms | `catalog_search` |
| Tạo đơn nháp | p95 < 700 ms | `draft_create` |
| Xác nhận thu tiền mặt tại quầy | p95 < 2 s | `cash_confirmation` |

Chạy: `pnpm test:perf` (API mock, chỉ đo phía trình duyệt) hoặc `POS_PERF_LIVE=1 POS_LIVE_REVIEW=1 POS_LIVE_FIXTURE=… pnpm test:perf` (API thật). Kết quả JSON: `test-results/perf/pos-scenarios.json` (p50/p95/max, mẫu thô, môi trường).

## 2. Hồ sơ tải đề xuất (chưa đo)

| Thông số | Giá trị đề xuất |
|---|---|
| Chi nhánh | 50 |
| Quầy mỗi chi nhánh | 10 |
| Đơn mở mỗi quầy | 20 |
| Variant trong catalog | 100.000 |
| Thu ngân hoạt động đồng thời | 100 |
| Nhịp quét | (điền: số lần quét/phút/quầy giờ cao điểm) |
| Tỷ lệ chuyển khoản / tiền mặt / ghi nợ | (điền) |

Công cụ tạo tải (k6, Playwright nhiều worker…) chọn sau khi có môi trường staging và dữ liệu mẫu; repo chưa cài công cụ tải.

## 3. Phần cứng và môi trường (điền khi đo)

| Mục | Giá trị |
|---|---|
| Máy chủ API (CPU, RAM, số worker Puma) | |
| PostgreSQL (phiên bản 18, CPU, RAM, đĩa, pool) | |
| Mạng quầy – máy chủ (LAN/WAN, độ trễ) | |
| Máy quầy (CPU, RAM, trình duyệt) | |
| Phiên bản POS (commit) / API | |

## 4. Dữ liệu (điền khi đo)

| Mục | Giá trị |
|---|---|
| Số variant, số mã vạch | |
| Số đơn lịch sử, số khách | |
| Số serial/lô đang theo dõi | |

## 5. Kết quả (điền khi đo)

| Kịch bản | Tải | Mẫu | p50 | p95 | max | Lỗi | Đạt mục tiêu? |
|---|---|---|---|---|---|---|---|
| tab_switch | | | | | | | |
| catalog_search | | | | | | | |
| draft_create | | | | | | | |
| cash_confirmation | | | | | | | |

Số đo tham khảo duy nhất hiện có là chạy harness trên máy dev với API mock (xem báo cáo frontend phase 11); chỉ phản ánh phía trình duyệt, không dùng để kết luận năng lực.

## 6. Khoảng trống và quyết định

| Mục | Ghi chú |
|---|---|
| Kịch bản chưa đạt | |
| Phạm vi được phê duyệt dù chưa đạt | |
| Người duyệt / ngày | |
