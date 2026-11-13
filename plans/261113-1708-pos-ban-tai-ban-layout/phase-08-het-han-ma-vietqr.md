---
phase: 8
title: "Server tự hủy mã VietQR quá hạn"
status: pending
effort: "1 ngày"
dependsOn: [6]
---

# Phase 8: Server tự hủy mã VietQR quá hạn

## Bối cảnh

Màn thanh toán toàn màn tạo mã VietQR ngay khi mở (`Tenders::Prepare` → `VietqrTender.open!`). Mã chỉ được hủy khi màn thanh toán đóng trên máy (`Tenders::Cancel`). Nếu tắt tab, mất mạng hay máy treo, lượt thanh toán ở lại trạng thái `prepared`, và đơn bị khóa thêm món (`Workspace` khóa snapshot khi có tender `SNAPSHOT_LOCKING_TENDERS`) tới khi có người mở lại đơn và bấm "← Đơn".

Đã kiểm:

- `SpreeVietqr::PaymentAllocation` có `expires_at` (`AllocatePaymentAccount#expires_at`: giờ hiện QR + `payment_timeout_minutes`).
- Job `SpreeVietqr::ExpireAllocationsJob` của gem có sẵn nhưng **không** có trong `server/config/recurring.yml`. Kể cả khi chạy, job chỉ nhả allocation; `TenderAttempt` của POS vẫn `prepared`.
- Không có job nào của POS dọn lượt thanh toán VietQR treo.

## Yêu cầu

1. Job lặp `Spree::Pos::Tenders::ExpireVietqrJob` (mỗi phút, khai trong `recurring.yml`) tìm `TenderAttempt` `prepared`, phương thức `vietqr`, có allocation `expires_at` + 5 phút ân hạn < bây giờ.
2. Với mỗi lượt: khóa workspace, kiểm lại trong khóa. Nếu tiền đã về (allocation `confirmed` hoặc payment `completed`) thì **không** hủy, để thu ngân xác nhận như hiện nay. Còn lại thì hủy như `Tenders::Cancel`: `VietqrTender.cancel!`, `status: 'canceled'`, tăng `revision`, ghi `AuditEntry` `tender.expire` (actor hệ thống), phát realtime để máy đang mở đơn tải lại.
3. Phần hủy dùng chung với `Tenders::Cancel` (tách hàm, không chép logic). Job không đi qua lease hay `CommandExecutor` vì không có người sửa; ghi rõ lý do trong comment.
4. POS: khi đơn đổi revision vì lượt thanh toán bị hủy, màn thanh toán đang mở (nếu còn) hiện "Mã QR đã hết hạn" và nút "Tạo mã mới", không tự tạo lại.

## File

- Tạo: `server/app/jobs/spree/pos/tenders/expire_vietqr_job.rb`, spec `server/spec/jobs/spree/pos/tenders/expire_vietqr_job_spec.rb`
- Sửa: `server/app/workflows/spree/pos/tenders/cancel.rb` (tách phần hủy), `server/app/services/spree/pos/vietqr_tender.rb`, `server/config/recurring.yml`
- Sửa: `apps/pos/src/components/payment-panel.tsx` (trạng thái hết hạn), locale `vi`/`en`

## Các bước

1. Spec trước: lượt quá hạn bị hủy và đơn mở khóa; lượt chưa quá hạn giữ nguyên; lượt đã nhận tiền giữ nguyên; lượt tiền mặt không bị đụng.
2. Tách hàm hủy, viết job, khai lịch.
3. Trạng thái hết hạn ở `PaymentPanel`; unit test nếu panel có test.

## Kiểm tra

```bash
pnpm spree rspec spec/jobs/spree/pos/tenders/expire_vietqr_job_spec.rb spec/integration/spree/pos/vietqr_tender_spec.rb
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project desktop
```

## Rủi ro và rollback

- Khách chuyển khoản trễ sau khi mã bị hủy: tiền về mà không khớp allocation. Khoảng ân hạn 5 phút giảm rủi ro; giao dịch lạc đã được gem đưa vào danh sách chờ đối soát như hiện nay.
- `payment-panel.tsx`, `prepare.rb` và `confirm.rb` đang có thay đổi chưa commit của phiên khác: chỉ stage hunk của phase này.
- Rollback: gỡ dòng trong `recurring.yml` là tắt job; revert commit.
