# Runbook vận hành POS

Tài liệu cho kỹ thuật và quản lý cửa hàng. Mọi lệnh API chạy qua Spree CLI ở thư mục gốc (`pnpm spree …`). Mọi triển khai, bật tính năng trên production hoặc thao tác dữ liệu thật cần người có thẩm quyền duyệt riêng; runbook này không thay cho phê duyệt đó.

## 1. Cờ tính năng và kill-switch

Tám tính năng có rủi ro: `credit`, `returns`, `refunds`, `exchanges`, `traceability`, `customer_display`, `cash_moves`, `exports`. Mặc định **tắt** (chưa có dòng cấu hình = tắt). Bán hàng tiền mặt/chuyển khoản, ca, hóa đơn không phụ thuộc cờ.

- Hiệu lực tại chi nhánh = mặc định cửa hàng **và** chi nhánh không tắt riêng. Chi nhánh chỉ có thể tắt, không thể bật khi cửa hàng đang tắt.
- Giao diện: Cài đặt → chi nhánh → **Chức năng chi nhánh**. Quản trị cửa hàng (`write_pos_topology`) bật/tắt cấp cửa hàng và **Bỏ tắt tại chi nhánh**; quản lý chi nhánh (`pos.topology.manage`) vào từ menu và chỉ có **Tắt tại chi nhánh này** (bật lại là quyết định cấp cửa hàng). Trạng thái hiện lý do tắt: "cửa hàng chưa bật" hay "tắt tại chi nhánh". Mỗi thay đổi bắt buộc nhập lý do, có nhật ký `feature_flag.change`.
- API: `GET /api/v3/admin/pos/feature_flags?branch_id=…` (trả `switches` theo tính năng: `store`, `branch_override`, `effective`); `PUT /api/v3/admin/pos/feature_flags/:feature` với `{ branch_id?, enabled, reason }`. Có `branch_id`: `false` tắt tại chi nhánh; `true`/`null` bỏ tắt (cần `write_pos_topology`).
- **Kill-switch khẩn cấp:** tắt cấp cửa hàng (một tính năng, mọi chi nhánh) hoặc tắt tại chi nhánh. Hiệu lực ngay với lệnh mới (409 `feature_disabled`, UI hiện lý do tiếng Việt và tự khóa nút). Không xóa tiền, phiếu, tồn hay nhật ký.
- Đường phục hồi luôn mở khi tắt (theo bảng của backend): xem/thu nợ hiện có; nhận, hủy, duyệt phiếu trả đã lập; xác nhận chi, hủy, ghi kết quả hoàn tiền đã yêu cầu; chi trả tiền chưa phân bổ; xóa/ngắt màn hình khách; xác nhận/hủy yêu cầu thu chi đã gửi; đóng ca, đối soát, báo cáo, tải file đã xuất; tra cứu và in hóa đơn.
- Không dùng cờ để "dọn" giao dịch: tắt rồi bật lại không làm mất hay lặp gì.

## 2. Job phục hồi (Solid Queue, `server/config/recurring.yml`)

| Job | Lịch | Việc |
|---|---|---|
| `Spree::Pos::RecoverSettlementJob` | 5 phút | Đơn đã thu đủ nhưng chưa đặt xong: đánh dấu `workspace.completion_pending`, không tự đặt đơn |
| `Spree::Pos::RecoverReturnOperationJob` | 5 phút | Ghi quyền hưởng của phiếu trả đang chờ phiếu trước |
| `Spree::Pos::DispatchOutboxJob` | 1 phút | Gửi sự kiện outbox |
| `Spree::Pos::ReleaseTraceReservationsJob` | 1 phút | Nhả serial/lô giữ quá hạn của nháp |
| `Spree::Pos::PurgeExpiredExportsJob` | mỗi giờ | Xóa file xuất hết hạn |

Theo dõi: `GET /api/v3/admin/pos/operations/metrics?branch_id=…` (tender chưa giải quyết, outbox chậm/lỗi, việc cần chú ý, chênh lệch két, lock wait). Ngưỡng "cũ": 900 giây. Nếu outbox `failed` tăng hoặc `oldest_unresolved_age_seconds` vượt ngưỡng: xem `pnpm spree logs` (dòng `pos command`, không chứa key/số tiền/PII), xem `/jobs`.

## 3. Xử lý "Cần chú ý"

1. Thu ngân thấy cảnh báo "Có khoản thu chưa rõ kết quả": bấm **Kiểm tra lại khoản thu chưa rõ**. Không tạo khoản thu mới cho cùng tiền.
2. Trang **Khoản thu cần chú ý**: mỗi khoản có trạng thái máy chủ; khoản không xác minh được thì đối soát thủ công với sao kê/két, ghi kết quả bằng chức năng giải quyết (cần `pos.payment.resolve`).
3. Đơn `completion_pending`: mở đơn, bấm hoàn tất lại (cùng key, đặt đơn đúng một lần).
4. Không bao giờ xóa bản ghi tiền hoặc gửi lại lệnh với key mới để "thử lại".

## 4. Tiền đến trễ, tiền thừa

- Chuyển khoản đến sau khi đơn đã trả bằng cách khác: khoản vào **Tiền chưa phân bổ** của đơn gốc. Phân bổ cho đơn đúng người trả, hoặc chi trả lại (liability payout) có chứng từ và duyệt. Không gán cho khách sau.
- Tiền mặt nhận ở ca S1 nhưng ghi sau khi S1 đã đóng: dùng **Đối soát tiền mặt trễ** (trang Ca & két), chọn đúng ca gốc và nơi giữ tiền (két ca sau hay két sắt). Không cộng tay vào tiền đầu ca S2.

## 5. Màn hình khách lỗi

- Mất mạng/ngủ: màn hình tự ẩn thông tin trong khoảng tươi (mặc định 15 giây). Thu ngân thấy "chưa xác nhận" và không ghim được đơn mới.
- Màn hình treo: bấm **Màn hình khách không phản hồi** để thu hồi; ghép lại bằng mã kết nối. Khi cần dừng hẳn: tắt `customer_display` (vẫn xóa/ngắt được).
- Khách đã chụp thông tin chuyển khoản: tiền đến muộn xử lý như mục 4.

## 6. Máy in lỗi

- Chỉ in qua hộp thoại trình duyệt. In lỗi/hủy không đổi đơn hay tiền. Bản gốc mất thì in lại ra "BẢN SAO – lần N" từ trang Hóa đơn.
- Hết giấy giữa chừng: thay giấy, in lại từ Hóa đơn. Không thu tiền lần hai.

## 7. Sao lưu trước migration

- Trước mọi `pnpm spree migrate` trên dữ liệu có giá trị: sao lưu bằng công cụ **cùng phiên bản PostgreSQL với server (18)**. `pnpm spree exec` chạy trong container web, nơi chỉ có `pg_dump` 17, không dump được server 18. Dùng `pg_dump` của chính container postgres 18 (hoặc công cụ backup của nhà cung cấp DB trên môi trường thật), có người phụ trách xác nhận cách truy cập.
- Kiểm tra file dump khôi phục được (restore thử vào database tạm) trước khi migrate.
- Ghi lại phiên bản migration trước/sau (`pnpm spree migrate:status`).
- Không chạy `pnpm spree db:reset` hay `eject` khi chưa được developer đồng ý.

## 8. Rollback

- Ứng dụng: triển khai lại bản trước; dữ liệu tiền/kho không bị xóa. Tắt cờ tính năng mới trước khi rollback để chặn lệnh mới.
- Migration: chỉ rollback khi đã có bản sao lưu đã thử khôi phục; ưu tiên migration sửa tiếp (forward fix) với bảng chứa tiền.

## 9. Liên hệ hỗ trợ

Điền trước khi pilot: người trực kỹ thuật, người trực vận hành, kênh liên lạc, giờ hỗ trợ. (Chưa có.)
