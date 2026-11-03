---
phase: 10
title: "Biên nhận, màn hình khách và thiết bị tại quầy"
status: pending
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

- [ ] F13: reprint không payment/stock effects, snapshot giữ original sale/traceability sau cấu hình đổi.
- [ ] W01, W08: display pin A không đổi theo cashier tabs, keyboard/tablet/zoom và in tiếng Việt đúng.
- [ ] A01–A03: display token không admin authority/PII/debt, expiry/revoke/generation được server enforce.
- [ ] W09, F05: disconnect-before-clear/cancel/settlement/rebind/sleep tests ẩn QR stale trong bounded TTL; cashier thấy freshness và không show khách mới thiếu current-generation ACK; delay/cache không kéo dài deadline.
- [ ] F05: late QR receipt vào đúng original context/exception, không gán khách/đơn kế tiếp.
- [ ] W03, W06: scanner/measurement barcode đúng workspace, IME/focus và retry không duplicate intent.
- [ ] Device UAT ghi model/thông số/kết quả thật; optional VietQR adapter chưa chọn không chặn release manual-bank.

## Risk Assessment

- Browser print/driver khác nhau: merchant chọn model và test thật; không hứa silent printing/cash drawer driver chưa tích hợp.
- Token/QR stale khi offline: local fail-closed TTL + ACK/freshness mới chặn reuse display; QR đã chụp vẫn chuyển được tiền nên giữ late-receipt recovery.
- Bill bị hiểu là hóa đơn điện tử: nhãn rõ POS receipt; legal e-invoice cần adapter/quy trình riêng.

## Next Steps

Phase 11 gom evidence thiết bị và kiểm E2E full retail, gồm mandatory weighted/unit/serial/lot traceability.
