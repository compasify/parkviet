# Rà soát bảo mật POS (phase 11)

Ngày: 07/11/2026. Phạm vi: app `apps/pos` và API `/api/v3/admin/pos/*` trên Spree 6.0.2. Đây là rà soát theo bằng chứng trong repo và test đã chạy, không phải pentest độc lập. Bằng chứng backend: [báo cáo backend phase 11](./phase-11-backend-implementation.md); frontend: [báo cáo frontend phase 11](./phase-11-frontend-implementation.md).

## 1. Mô hình đe dọa

| Tài sản | Tác nhân | Mối đe dọa chính |
|---|---|---|
| Tiền (thu, hoàn, thu nợ, két) | Thu ngân, người ngoài quầy, lỗi mạng | Thu/hoàn hai lần do mất phản hồi; hoàn vượt quyền hưởng; đóng ca sai két |
| Tồn kho, serial, lô | Thu ngân, web/admin song song | Bán trùng serial, lệch tồn, trả hàng không đúng nguồn gốc |
| Công nợ, hạn mức | Thu ngân tự duyệt | Vượt hạn mức, dùng lại duyệt cũ |
| PII khách (SĐT, tên) | Nhân viên chi nhánh khác, màn hình khách, file xuất | Lộ dữ liệu ngoài phạm vi; CSV injection |
| Phiên nhân viên | XSS, CSRF, máy dùng chung | Lấy token, dùng cookie refresh từ origin lạ |
| Cấu hình/cờ tính năng | Quản lý chi nhánh | Bật tính năng rủi ro không duyệt, tắt làm mất tiền đang dở |

## 2. Checklist và bằng chứng hiện có

| Hạng mục | Trạng thái | Bằng chứng |
|---|---|---|
| A01 phiên: access token chỉ trong bộ nhớ, refresh cookie HttpOnly + SameSite, một lượt refresh | Đạt (test) | `session-coordinator.test.ts`; backend `security_spec.rb` (cookie HttpOnly/SameSite, không CORS origin lạ) |
| A01 hết phiên giữa ca: về màn đăng nhập, không mất đơn, không lặp tiền | Đạt (mock) | `e2e/full-retail.spec.ts` "reload, network flapping, an expired session and logout…" |
| A01 logout: access JWT cũ còn hiệu lực tới hết hạn (≤ 1 giờ) | Chấp nhận (quyết định phase 2) | phase-02 "Đóng phase" |
| A02 IDOR chi nhánh/store khác | Đạt (request spec) | backend `security_spec.rb` (workspace, funds, returns, refunds, receipts, exports, display…) |
| A03 gọi thẳng API core để bỏ qua POS | Đạt (request spec) | backend `security_spec.rb`: core order/payment/refund/stock writes của staff POS trả 403/404, ledger không đổi |
| A04 đổi chi nhánh/quầy khi request đang chạy | Đạt (mock) | `e2e/keyboard-context.spec.ts`, `context-defaults.spec.ts` |
| A05 duyệt dùng lại/thu hồi/hết hạn/tự duyệt | Đạt (request spec) | backend `security_spec.rb`, `topology_access_spec.rb` |
| A06 khóa chi nhánh/quầy/nhân viên còn ca | Đạt (spec + mock) | `topology_access_spec.rb`, `e2e/disable-session.spec.ts` |
| Idempotency mọi lệnh tiền/kho, mất phản hồi | Đạt (mock + API thật một phần) | `e2e/concurrency-chaos.spec.ts` (mỗi họ lệnh đúng 1 hiệu ứng, 1 key); live: mất phản hồi khi thêm hàng và thu tiền mặt được phục hồi bằng key |
| Kill-switch tính năng: tắt không xóa tiền/kho/audit, đường phục hồi mở | Đạt (spec + mock) | backend `feature_flags_spec.rb`; `e2e/feature-flags.spec.ts` |
| Thu tiền/hoàn tiền mặt/thu nợ khi không có ca mở của mình | Đạt (server chặn) | server: `shift_closed` (tender, hoàn tất), `shift_required` (chi hoàn tiền mặt, thu nợ). UI khóa thanh toán trên đơn thuộc ca không mở; với chi hoàn và thu nợ chỉ gợi ý (ca có thể ở quầy khác) và hiện câu từ chối của server: `feature-flags.spec.ts` test cuối |
| Màn hình khách: không JWT, không PII, ẩn khi mất kết nối | Đạt (mock) / chờ UAT | `e2e/receipts-display.spec.ts`; [UAT thiết bị](./device-uat.md) D1–D7 chưa chạy |
| CSV injection, file xuất hết hạn | Đạt (request spec) | backend `security_spec.rb` (escape ô bắt đầu bằng `=+-@`, 410) |
| Che SĐT với nhân viên không có quyền liên hệ | Đạt (request spec) | backend `security_spec.rb` |
| Log lệnh không chứa key/thanh toán/PII | Đạt (spec) | backend CommandExecutor log spec |
| CORS/SameSite trên hạ tầng thật (cùng hay khác domain) | **Mở** | Chưa chốt hạ tầng triển khai (phase 2) |
| Rate limit đăng nhập | Có (429 từ Spree) | Quan sát khi chạy e2e thật: đăng nhập dồn trả 429 |
| XSS: React escape, không `dangerouslySetInnerHTML` cho dữ liệu người dùng | Đạt (rà mã) | `grep dangerouslySetInnerHTML apps/pos/src` không có kết quả cho dữ liệu khách |

## 3. Việc còn mở (chặn phát hành đầy đủ)

1. Chốt hạ tầng (same-origin hay khác domain) rồi kiểm lại CORS, SameSite, CSP trên môi trường staging.
2. Pentest/rà soát độc lập trước khi bán tiền thật; hiện chỉ có tự rà soát.
3. Tài khoản/credential thử trên dev: fixture e2e thật tạo nhân viên `pos-live-*@example.test` có mật khẩu ngẫu nhiên, file credential nằm ngoài repo; cần vô hiệu sau đợt kiểm thử. Fixture cũ `POS Review e795bd452a` đã ghi nhận lộ mật khẩu trong snapshot (runtime-spike-results), cần vô hiệu.
4. Snapshot lỗi của Playwright có thể chứa giá trị ô nhập; `test-results/` đã gitignore, xóa sau khi chạy với tài khoản thật.
5. Cờ tính năng mặc định tắt: việc bật trên production cần quyết định vận hành có người ký (xem [release checklist](./release-checklist.md)).

Không phát hiện lỗ hổng mức critical/high mới trong phạm vi frontend. Lỗi đã sửa trong đợt này: UI cho bấm thu tiền trên đơn thuộc ca đã đóng (server vẫn chặn; nay UI khóa kèm lý do). Chi hoàn tiền mặt và thu nợ không bị khóa theo ca của quầy đang chọn vì server nhận mọi ca đang mở của nhân viên tại chi nhánh; UI gợi ý và hiện lý do khi server từ chối.
