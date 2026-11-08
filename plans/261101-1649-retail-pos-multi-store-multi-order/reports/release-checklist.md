# Checklist phát hành POS (go/no-go)

Ngày lập: 07/11/2026. Ma trận gốc: [API và test matrix](../specs/api-contract-and-test-matrix.md). Trạng thái:

- **Đạt** — có bằng chứng tự động (đường dẫn spec/test).
- **Cần API thật** — đạt trên mock/spec backend nhưng chưa chạy end-to-end trên API thật đủ.
- **Cần UAT** — cần thử trên thiết bị/quy trình thật tại cửa hàng.
- **Cần ký** — cần người có thẩm quyền quyết định/ký.

Kết luận (08/11/2026): **GO** theo quyết định của chủ dự án. Các mục "Cần UAT", "Cần API thật" và đo hiệu năng do người dùng tự thực hiện khi vận hành.

## A — bảo mật, quyền, ngữ cảnh

| ID | Trạng thái | Bằng chứng / việc còn lại |
|---|---|---|
| A01 phiên, refresh, logout, hết phiên | Đạt; Cần API thật (hạ tầng) | `session-coordinator.test.ts`; `e2e/full-retail.spec.ts` (hết phiên, logout); backend `security_spec.rb`. CORS/SameSite trên domain thật chưa kiểm |
| A02 IDOR chi nhánh/store | Đạt | backend `security_spec.rb` |
| A03 bỏ qua POS qua API core | Đạt | backend `security_spec.rb` |
| A04 đổi ngữ cảnh khi request chạy | Đạt | `e2e/keyboard-context.spec.ts`, `e2e/context-defaults.spec.ts` |
| A05 duyệt dùng lại/thu hồi | Đạt | backend `security_spec.rb`, `topology_access_spec.rb` |
| A06 khóa chi nhánh/quầy/nhân viên | Đạt | `topology_access_spec.rb`, `e2e/disable-session.spec.ts` |

## W — nhiều đơn, UX

| ID | Trạng thái | Bằng chứng / việc còn lại |
|---|---|---|
| W01 A chờ chuyển khoản, B tiền mặt, C quét | Đạt (mock); Cần API thật | `e2e/full-retail.spec.ts` test 1; backend `full_retail_spec.rb` |
| W02 20 tab, 200 nháp | Cần API thật | phân trang đã có; chưa đo 20 tab/200 nháp trên API thật |
| W03 100 lần quét, phản hồi đảo thứ tự | Đạt (mock) | `e2e/concurrency-chaos.spec.ts` (100 quét, đảo thứ tự); live: mất phản hồi khi quét được phục hồi bằng key |
| W04 hai trình duyệt, takeover | Đạt (mock + API thật) | `e2e/concurrency-chaos.spec.ts`, `e2e/live-api.spec.ts` |
| W05 đóng tab, tạm giữ, logout, crash | Đạt (mock) | `e2e/full-retail.spec.ts` (reload/logout), `layout-recovery.spec.ts` |
| W06 khách nhanh, quét trong ô nhập | Đạt (mock); Cần UAT (bộ gõ) | `e2e/catalog-scan.spec.ts`; [UAT thiết bị](./device-uat.md) S2–S3 |
| W07 giảm giá, làm tròn | Đạt (spec) | phase 5 specs |
| W08 desktop/tablet/phone, zoom 200%, bàn phím, screen reader | Đạt (kiểm có mục tiêu); Cần UAT | `e2e/accessibility.spec.ts`; chưa thử với screen reader thật (NVDA/VoiceOver) |
| W09 màn hình khách tươi/ACK | Đạt (mock); Cần UAT | `e2e/receipts-display.spec.ts`; UAT D1–D7 chưa chạy |

## F — tiền, nợ, kho

| ID | Trạng thái | Bằng chứng / việc còn lại |
|---|---|---|
| F01 tiền thừa, xác nhận kép | Đạt | `e2e/split-tender.spec.ts`; live: bán có tiền thừa, kiểm `allocated`/`change_due` qua API |
| F02 chia tiền + ghi nợ | Đạt | `e2e/full-retail.spec.ts` (300k tiền mặt + 200k ghi nợ); backend `full_retail_spec.rb` |
| F03, F04 mất phản hồi, crash trước đặt đơn | Đạt (mock + spec); live một phần | `e2e/concurrency-chaos.spec.ts`; backend `concurrency_faults_spec.rb`; live: xác nhận tiền mặt mất phản hồi → 1 khoản |
| F05, F19 tiền trễ/trùng tham chiếu, tiền chưa phân bổ | Đạt (spec) | phase 6/7 specs; Cần UAT với sao kê thật |
| F06, F08 thu nợ/duyệt đồng thời | Đạt (spec) | `credit_race_spec.rb` |
| F09 thu nợ phân bổ | Đạt | `e2e/full-retail.spec.ts`, `e2e/credit-collections.spec.ts` |
| F10 trả hàng đơn nợ (credit note trước) | Đạt (mock + spec) | `e2e/concurrency-chaos.spec.ts` (50k credit note + 50k hoàn); backend `full_retail_spec.rb` |
| F11 hoàn tiền, cap, retry | Đạt (mock + spec); Cần API thật | `e2e/returns-exchanges.spec.ts`, `concurrency-chaos.spec.ts`; live full-retail (kết quả xem báo cáo frontend) |
| F12, F12a, F12b tồn cuối, POS/web | Đạt (spec) | phase 8 specs; Cần UAT đối soát |
| F13 handover/receive lặp | Đạt | `e2e/concurrency-chaos.spec.ts` (handover 1 lần), backend race specs |
| F14 trả hư hỏng/khác chi nhánh/đổi | Đạt (spec + mock) | `returns-exchanges.spec.ts`, `full-retail.spec.ts` (đổi hàng) |
| F15, F16 đóng ca, tiền trễ | Đạt (spec + mock) | `shift-reconciliation.spec.ts`, `shift_close_race_spec.rb`; Cần UAT quy trình két |
| F17 sửa sổ, xuất CSV an toàn | Đạt (spec) | backend `security_spec.rb` (CSV) |
| F18 đơn 0 đồng, tiền lẻ | Đạt (spec) | phase 6 specs |
| F20 hoàn → đảo → phân bổ lại | Đạt (spec) | phase 7/8 specs |
| F21 0,4 VND × 5 trả 1+1+3 | Đạt (spec) | `return_entitlement_spec.rb` |
| Thu/chi tiền mặt khi ca không mở | Đạt | server chặn (`shift_closed`, `shift_required`); UI khóa thanh toán trên đơn thuộc ca không mở, gợi ý ở chi hoàn/thu nợ và hiện câu từ chối: `e2e/feature-flags.spec.ts` |

## I — hàng cân, quy đổi, serial, lô

| ID | Trạng thái | Bằng chứng / việc còn lại |
|---|---|---|
| I01 quy đổi, giá lẻ | Đạt (spec) | `unit_normalization_spec.rb` (sửa lỗi thùng 24) |
| I02 tem cân | Đạt (mock + API thật) | `e2e/scale-labels.spec.ts`, `e2e/advanced-goods.spec.ts` (live: tem cân 500 g) ; Cần UAT máy cân/in tem thật |
| I03 serial | Đạt (mock + API thật) | `e2e/advanced-goods.spec.ts`, `traceable_inventory_spec.rb` |
| I04 FEFO, hết hạn | Đạt (mock + API thật) | `e2e/advanced-goods.spec.ts` (live: L1×2 + L2×1) |
| I05 trả hàng cân/serial/lô một phần | Đạt (mock + API thật) | `e2e/advanced-goods.spec.ts` (200 g, 1 serial, 1 hộp lô L2; restock kiểm qua API) |
| I06 bypass qua admin/web | Đạt (spec) | `traceable_inventory_guards_spec.rb` |
| I07 tồn đầu kỳ, recall | Đạt (spec); Cần UAT tồn thật | `traceability_spec.rb`; đối soát tồn đầu với kho thật chưa làm |
| I08 cùng variant nhiều dòng | Đạt (mock + spec) | `e2e/advanced-goods.spec.ts` (2 tem cùng thịt = 2 dòng) |

## Vận hành và quyết định

| Hạng mục | Trạng thái |
|---|---|
| Cờ tính năng theo cửa hàng/chi nhánh, kill-switch không xóa tiền | Đạt (`feature_flags_spec.rb`, `e2e/feature-flags.spec.ts`, `e2e/feature-recovery.spec.ts`: mọi đường phục hồi chạy khi tắt hết cờ) |
| Runbook vận hành, phục hồi, sao lưu | Có ([runbook](./operations-runbook.md)); Cần ký |
| Đo hiệu năng | Cần đo trên LAN staging ([capacity baseline](./capacity-baseline.md)) |
| UAT thiết bị | Cần UAT ([device-uat](./device-uat.md)) |
| UAT truy xuất | Cần UAT ([traceability-uat](./traceability-uat.md)) |
| Chính sách ghi nợ, ngưỡng chênh lệch két, cấu hình một két/quầy | Cần ký (quản lý) |
| Bật từng tính năng trên production | Cần ký (theo chi nhánh pilot) |
| Vận hành tiền thật | Chủ dự án duyệt 08/11/2026; UAT do người dùng tự làm |
| Không còn lỗi critical/high | Đạt trong phạm vi rà soát ([security review](./security-review.md)); pentest độc lập chưa có |
