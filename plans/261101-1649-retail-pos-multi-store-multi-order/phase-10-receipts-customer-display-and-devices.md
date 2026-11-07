---
phase: 10
title: "Biên nhận, màn hình khách và thiết bị tại quầy"
status: completed
priority: P1
dependencies: [5, 6, 8, 9]
effort: "Ước tính 8–12 person-days"
---

# Phase 10: Biên nhận, màn hình khách và thiết bị tại quầy

## Overview

Làm bill 80mm/A4, read-only display theo generation và scanner/printer UAT; thiết bị không là authority thu tiền.
Chuẩn: [UX §6–9](./specs/ux-and-workflows.md), [kiến trúc §9,11](./specs/product-and-architecture.md), [API/tests](./specs/api-contract-and-test-matrix.md).

## Requirements

- Bill snapshot immutable, reprint có nhãn bản sao và tìm bill theo mã; bill POS không phải hóa đơn điện tử pháp lý.
- In rõ sale units/base-unit conversion, serial/IMEI hoặc lot/expiry theo policy traceability và quyền PII.
- Tổng/discount/tax/receipts/debt/refunds phân biệt; receipt chưa complete không được dán finalized success.
- Display explicit pin order/attempt; đổi tab cashier không thay QR khách đang quét.
- Display token read-only short-lived/revocable, bound session/attempt/generation, không staff JWT/cart token/PII/nợ.
- Display fail-closed: bounded local freshness TTL ẩn QR khi biết offline hoặc hết deadline/generation unresolved; cashier thấy freshness và phải có ACK generation hiện tại/clear trước show khách kế. Giá trị deadline phải được chốt/UAT trước enable display, token còn hạn không thay freshness proof.
- Browser print trước, model printer/scanner/display và native bridge nếu cần phải qua merchant approval/UAT.
- Bank manual/optional QR không báo đã nhận; VietQR tự động là adapter tương lai, không blocker POS.

## Architecture

- ReceiptSnapshot lấy core/ledger/traceability facts đã post, không phụ thuộc active tab hoặc recompute bằng JS.
- DisplaySession tách privileged API và public read-only route scoped token; generation tăng khi bind/clear/pin khách mới.
- Delayed response từ generation cũ bị bỏ; revoke/expiry ở server, BroadcastChannel không cấp quyền.
- Freshness lease dùng monotonic local deadline bounded đã duyệt, không reset bởi cached/delayed/out-of-order response; hết TTL/hide rồi revalidate+ACK generation mới show lại. Sleep/resume/visibility change phải hide trước khi revalidate; ACK bound session/generation/lease và cashier không coi expired ACK là proof khách đang thấy đúng QR.
- Old QR có thể còn chuyển được tiền thực: cảnh báo và late receipt exception phase 6, không áp tiền sang đơn khách sau.
- Printer adapter chỉ format/deliver snapshot; print failure/reprint không create Payment, stock move hoặc new sale.
- Scanner queue phase 5 thêm device terminator/keyboard calibration; measurement barcode dùng policy parser server-verified.
- Chưa chọn public provider/merchant; không hardcode SePay/payOS hoặc pretend có callback auto-bank.

## Related Code Files

Inventory từ repo root; source đề xuất app-specific, không fork dashboard/Spree.
- Create: `server/app/models/spree/pos/receipt_snapshot.rb`, `server/app/models/spree/pos/display_session.rb`, `server/db/migrate/TIMESTAMP_create_spree_pos_receipt_displays.rb`.
- Create: `server/app/services/spree/pos/receipt_builder.rb`, `server/app/workflows/spree/pos/displays/bind.rb`, `server/app/workflows/spree/pos/displays/revoke.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/receipts_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/display_sessions_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/display_sessions/acknowledgements_controller.rb` — scoped display ACK channel, không cấp staff/financial authority.
- Create: `server/app/controllers/spree/pos/display_views_controller.rb` — read-only token route riêng, không tái dùng admin session.
- Create: `apps/pos/src/pages/customer-display.tsx`, `apps/pos/src/pages/receipt.tsx`, `apps/pos/src/components/display-pin-control.tsx`.
- Create: `apps/pos/src/lib/print-adapter.ts`, `apps/pos/src/lib/display-generation.ts`, `apps/pos/src/hooks/use-display.ts`, `apps/pos/src/styles/receipt.css`.
- Create: `apps/pos/src/lib/measurement-barcode.test.ts`, `apps/pos/src/lib/display-generation.test.ts`, `apps/pos/e2e/receipts-display.spec.ts`.
- Create: `server/spec/requests/spree/pos/receipts_displays_spec.rb`, `apps/pos/docs/device-uat.md` — model/driver/paper/terminator evidence tương lai.
- Modify: routes/access/locales, receipt completion hooks và scanner/measurement barcode parser phase 5, financial facts phase 6–9.

## Implementation Steps

1. Viết trước reprint no-money/no-stock tests; display token scope/expiry/revoke/generation và PII exclusion request tests.
2. Viết W09 browser tests pin A/bán B và disconnect ngay trước clear/cancel/settlement/rebind C; biết offline hoặc hết local TTL ẩn QR, generation unresolved không show, stale response không renew; test sleep/resume và expired ACK.
3. Cài immutable receipt builder/snapshot, original/duplicate labels và traceability/sale unit formatting từ facts đã post.
4. Dựng 80mm/A4 print CSS, paid/part-paid/credit/refund copy chính xác; font tiếng Việt và tabular money.
5. Cài display session bind/revoke/expiry/public reader tối thiểu; tránh token/evidence xuất vào logs/cache/referrer.
6. Dựng display generation-safe/freshness TTL, cashier freshness indicator; ACK current generation trước show khách kế, clear không khẳng định QR ngân hàng vô hiệu.
7. Nối manual receiving-account/optional QR UI từ config đã duyệt; không tự xác nhận tiền sau scan/print.
8. Chạy scanner/measurement-label calibration với IME/focus/terminator; barcode input không được override giá server ngoài policy.
9. UAT máy in 80mm/A4, popup blocked/offline paper-out/reprint; lỗi in không rollback order hoặc thu lần hai.
10. Ghi adapter boundary auto-bank/native printing cho tương lai, không cài provider/driver ngoài scope được duyệt.
11. Gate: `pnpm spree rspec spec/requests/spree/pos/receipts_displays_spec.rb` + app unit/e2e print snapshots và device UAT có evidence.

## Success Criteria

- [x] F13: reprint không payment/stock effects, snapshot giữ original sale/traceability sau cấu hình đổi. *(`receipts_displays_spec.rb`: in/in lại chỉ tạo ReceiptPrint + audit, không Payment/kho/đơn; snapshot giữ nguyên sau đổi giá/cấu hình; có serial/lô/hạn dùng từ TraceAllocation đã bán.)*
- [x] W01, W08: display pin A không đổi theo cashier tabs, keyboard/tablet/zoom và in tiếng Việt đúng. *(E2E 3 viewport: ghim đơn A rồi bán B không đổi màn hình khách; in 80mm/A4 tiếng Việt, ngày dd/MM/yyyy, số thập phân dấu phẩy.)*
- [x] A01–A03: display token không admin authority/PII/debt, expiry/revoke/generation được server enforce. *(Token màn hình ngẫu nhiên 256 bit, lưu digest, chỉ qua header `Authorization: Display`, không dùng được cho Admin API và ngược lại; không PII/nợ/nhân viên; hết hạn, thu hồi, xoay khi gắn lại; ghép bằng mã 8 ký tự dùng một lần 10 phút.)*
- [x] W09, F05: disconnect-before-clear/cancel/settlement/rebind/sleep tests ẩn QR stale trong bounded TTL; cashier thấy freshness và không show khách mới thiếu current-generation ACK; delay/cache không kéo dài deadline. *(Hạn tươi theo `performance.now()`, phản hồi cũ/lệch thứ tự/trước khi ẩn không gia hạn; offline/ẩn tab/ngủ dậy ẩn ngay; ghim/xóa có compare-and-set generation; thu ngân không ghim khách kế khi chưa có ACK của generation hiện tại.)*
- [x] F05: late QR receipt vào đúng original context/exception, không gán khách/đơn kế tiếp. *(Xóa màn hình cảnh báo QR/tài khoản đã chụp vẫn chuyển được; tiền trễ đi luồng tiền ngoài luồng gắn đơn gốc, không gán đơn kế tiếp.)*
- [x] W03, W06: scanner/measurement barcode đúng workspace, IME/focus và retry không duplicate intent. *(Hiệu chỉnh máy quét theo quầy (Enter/Tab, khoảng cách phím), bỏ qua IME và ô nhập, chỉ vào đơn đang mở, intent ổn định khi thử lại; tem cân vẫn do server đọc.)*
- [ ] Device UAT ghi model/thông số/kết quả thật; optional VietQR adapter chưa chọn không chặn release manual-bank. *(Chưa đạt: mẫu UAT ở [device-uat.md](./reports/device-uat.md) chờ cửa hàng chọn máy và chạy thật; chuyển phase 11. Hạn tươi 15 giây cần đo trên thiết bị trước khi bật màn hình khách.)*

## Risk Assessment

- Browser print/driver khác nhau: merchant chọn model và test thật; không hứa silent printing/cash drawer driver chưa tích hợp.
- Token/QR stale khi offline: local fail-closed TTL + ACK/freshness mới chặn reuse display; QR đã chụp vẫn chuyển được tiền nên giữ late-receipt recovery.
- Bill bị hiểu là hóa đơn điện tử: nhãn rõ POS receipt; legal e-invoice cần adapter/quy trình riêng.

## Next Steps

Phase 11 gom evidence thiết bị và kiểm E2E full retail, gồm mandatory weighted/unit/serial/lot traceability.

## Review 07/11/2026

Hai review độc lập; lỗi tìm thấy đã sửa và có test:

- Backend: thu ngân đọc/in được phiếu đóng ca, phiếu trả, phiếu hoàn của người khác; lệnh ghim bị trễ có thể hiện đơn khách trước cho khách sau; lỗi dựng biên nhận làm hỏng cả giao dịch bán/trả/hoàn/đóng ca. Nay phân quyền theo loại phiếu, ghim/xóa so generation, biên nhận phát hành trong savepoint và phát hành muộn nếu lỗi; phiếu trả có phiếu bổ sung khi giảm nợ/hoàn được ghi sau.
- Frontend: bản in gốc đầu tiên ra trang trắng mà vẫn tính là đã in; CSS in biên nhận làm trắng mọi bản in khác; Chromium bỏ khổ 80mm. Nay chỉ in khi bản in đã có trong DOM, CSS chỉ áp khi đang in biên nhận, khổ `80mm 297mm`. Sửa thêm: request màn hình treo làm dừng poll, gắn lại không chuyển token sang cửa sổ đang mở, chỉ báo "đã xác nhận" từ dữ liệu cũ, ghép thiết bị phải gõ token dài, máy quét Tab không dùng được ở ô tìm kiếm.

## Đóng phase 07/11/2026

**Kết quả:** backend POS 396 examples, 0 failures (suite chạy riêng hai lần liên tiếp, số dòng bảng không đổi) (gồm `receipts_displays_spec.rb` 19 examples). `apps/pos`: lint, typecheck sạch, 157 unit; Playwright 264 passed / 6 skipped (live API opt-in). Chi tiết: [báo cáo triển khai](./reports/phase-10-implementation.md).

**Migration:** `20261107170000`, `20261107170001` chỉ áp database test. Development vẫn chờ sao lưu.

**Ghi chú:** chỉ in qua trình duyệt, chưa có driver máy in/ngăn kéo tiền. Bản gốc mất khi in lỗi/hủy là chấp nhận; lần in sau là "BẢN SAO". Màn hình khách chỉ hiện mô tả tài khoản nhận của phương thức chuyển khoản, chưa có QR/VietQR (adapter tương lai). ACK màn hình đặt ở controller công khai vì màn hình không có phiên nhân viên.

**Chuyển phase sau:** UAT thiết bị thật (máy in, máy quét, màn hình khách, đo thời gian ẩn), kiểm trên API thật (phase 11). Vẫn sandbox-only.
