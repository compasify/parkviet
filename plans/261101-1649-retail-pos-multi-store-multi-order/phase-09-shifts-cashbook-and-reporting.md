---
phase: 9
title: "Đóng ca, sổ quỹ và báo cáo đối soát"
status: completed
priority: P1
dependencies: [3, 6, 7, 8]
effort: "Ước tính 9–14 person-days"
---

# Phase 9: Đóng ca, sổ quỹ và báo cáo đối soát

## Overview

Mở rộng Shift đã có bằng close barrier/count/approval và projection từ ledger thật phase 6–8.
Một register tương ứng một physical drawer đã được xác nhận; không tạo ca riêng cho mỗi browser.
Chuẩn: [kiến trúc §10](./specs/product-and-architecture.md), [UX §7](./specs/ux-and-workflows.md), [API/tests F15–F17](./specs/api-contract-and-test-matrix.md).

## Requirements

- Thu/chi, safe drop, bàn giao, blind count đề xuất, expected/counted/variance riêng và threshold do manager cấu hình.
- Expected = opening float + unique physical inflows − unique physical outflows: cash sales net change/collections/unapplied cash/cash-in, trừ cash refunds/liability payouts/cash-out/safe drops; allocation/reversal không tạo cash movement.
- Không cộng bank/card/debt phát sinh vào drawer; change không trừ lần hai.
- Close lock/drain in-flight commands, unresolved receipt checklist và approval trước immutable closing snapshot.
- Late bank evidence giữ original attempt/sale nhưng book current reconciliation period, không rewrite closed shift.
- Late cash khác receipt mới: ghi financial fact/current-period reconciliation với actual received-at và custody evidence; không auto cộng tiền vào ca hiện tại nếu đã nằm trong opening float hoặc đã bàn giao/safe-drop.
- Sales/receipts/returns/debt/physical drawer phân biệt, timezone branch và ca qua nửa đêm đúng.
- Filters/exports scope server, async export lớn có permission/file TTL và CSV formula injection protection.

## Architecture

- CashMovement phase 6 là immutable source; projection không tạo ledger thứ hai hoặc tổng từ UI tabs/metadata.
- ShiftClosure snapshot source cutoff/checkpoint và approval; corrections bằng reversal/current-period entry có reason.
- Close barrier cùng protocol lock với cash settlement/collection/payout; không lock riêng chỉ trong close controller.
- Unknown external attempts phải resolve hoặc manager reconciliation hợp lệ, không handover receipt đã thu sang ca mới.
- Late cash attest không backdate/sửa closed snapshot; manager reconciliation link original closure/variance và current custody/opening/transfer. CashMovement chỉ khi có physical effect chưa ghi, không mặc định ở current drawer.
- Fixture: S1 actual cash100k/expected0/count100k/variance+100k; S2 opening100k → late financial receipt + classification overage S1, S2 expected vẫn100k. Tiền đã ở safe không cộng vào S2; physical transfer mới phải có matched custody/source links chống đếm lại opening hoặc safe movement.
- Report dimensions store/branch/register/shift/cashier + sales-at/received-at/booked-at/return-at riêng.
- Receivable report dùng ledger sau credit notes, không copy core `amount_due` thành dư nợ.

## Related Code Files

Inventory repo-root; create/modify dự kiến, không sửa upstream Spree.
- Create: `server/app/models/spree/pos/shift_closure.rb`, `server/app/models/spree/pos/export_request.rb`, `server/db/migrate/TIMESTAMP_create_spree_pos_shift_closures.rb`.
- Create: `server/app/models/spree/pos/cash_reconciliation.rb`, `server/app/workflows/spree/pos/shifts/reconcile_late_cash.rb`, `server/app/controllers/spree/api/v3/admin/pos/cash_reconciliations_controller.rb` — financial posting/variance classification/custody links; cùng closure migration.
- Create: `server/app/workflows/spree/pos/shifts/close.rb`, `server/app/workflows/spree/pos/shifts/post_cash_movement.rb`, `server/app/workflows/spree/pos/shifts/correct.rb`.
- Create: `server/app/services/spree/pos/cashbook_projection.rb`, `server/app/services/spree/pos/reports/sales.rb`, `server/app/services/spree/pos/reports/receipts.rb`.
- Create: `server/app/services/spree/pos/reports/receivables.rb`, `server/app/jobs/spree/pos/generate_export_job.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/shifts/closures_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/shifts/cash_movements_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/reports/sales_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/reports/cashbook_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/reports/receivables_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/exports_controller.rb`.
- Create: `apps/pos/src/pages/shifts.tsx`, `apps/pos/src/pages/reports.tsx`, `apps/pos/src/components/shift-close-dialog.tsx`, `apps/pos/src/hooks/use-reports.ts`.
- Create: `server/spec/workflows/spree/pos/shift_closure_spec.rb`, `server/spec/requests/spree/pos/reports_spec.rb`, `apps/pos/e2e/shift-reconciliation.spec.ts`.
- Modify: Shift/CashMovement và source posting workflows phase 3/6–8, routes/access/locales; report indexes theo query đo thực.

## Implementation Steps

1. Viết trước F15 race close-vs-cash-sale/collection/payout bằng independent connections và cutoff assertions.
2. Viết fixtures F16/F17: overnight shift, next-day collection/refund thực phát sinh, late bank, reversal và provider fee khác customer debt. Late cash S1 đã vào S2 opening hoặc safe/drop/bàn giao không được cộng thêm S2; test fresh cash thực nhận S2 vẫn + đúng một lần.
3. Tạo closure snapshot/cutoff và report indexes; không update posted money facts khi refresh projection.
4. Tích hợp barrier vào mọi cash write path, drain in-flight; close retry trả cùng immutable result.
5. Cài manual cash-in/out/safe-drop với reason/capability/evidence, không coi đó là sales hoặc customer Payment.
6. Cài count/variance/approval và reconciliation checklist; blocked close trả actions tới đúng workspace/attempt.
7. Cài cashbook/sales/receipts/returns/debt projections, timezone/date semantics và server allowlisted filters.
8. Cài late evidence/current-period financial corrections + manager custody reconciliation, giữ source context/received-at/booked-at. Link/count variance S1 bằng adjustment có audit, không rewrite snapshot hoặc tự tạo physical inflow S2; cash effect mới mới post source-unique movement.
9. Dựng close wizard, cashbook và reports hiển thị riêng doanh số/thực thu/nợ/két; variance có giải thích.
10. Cài export job/permission/file TTL/sanitized CSV; download vẫn reauthorize và không lộ toàn chuỗi cho cashier.
11. Gate: `pnpm spree rspec spec/workflows/spree/pos/shift_closure_spec.rb spec/requests/spree/pos/reports_spec.rb` + app e2e.

## Success Criteria

- [x] F15: serialized cutoff đúng khi close đua receipt/collection/payout; một physical drawer một active shift. *(`ShiftBarrier` khóa ca trong mọi đường ghi tiền mặt; race hai connection: đóng ca đua tiền mặt bán hàng, thu nợ, chi liability, hoàn tiền mặt, tiền ngoài luồng, nộp/rút két, late-cash và hoàn tất bán chịu — `shift_close_race_spec.rb`.)*
- [x] F16: late bank/fresh current cash/overnight giữ source sale; late S1 cash reconcile variance/custody không rewrite snapshot hoặc double-count S2 opening/safe; fixture100k không thành200k. *(Fixture S1 thừa 100k / S2 đầu ca 100k giữ expected 100k theo cả hai thứ tự đối soát; chỉ `new_physical_inflow` tạo cash movement; tiền giữ ngoài két không đi ra từ két; ca qua nửa đêm hiện ở cả hai ngày theo múi giờ chi nhánh.)*
- [x] F17: reversal immutable, reports/CSV-safe exports reconcile được tới source facts; fees không tạo nợ mới. *(Closure, cash movement, reconciliation chỉ đọc; sửa bằng bút toán mới có audit; CSV escape công thức, BOM UTF-8, link tải ký một phút, TTL 24h.)*
- [x] F01, F09–F11, F19, F20: cash change/collection/refund/liability payout reconcile once, reversal không physical inflow; bank/card/debt không vào drawer. *(Expected = đầu ca + cash movement: thu ròng (đã trừ tiền thối), thu nợ, chi/hoàn âm; bank/thẻ/nợ và phân bổ/đảo phân bổ không tạo movement — `shift_closure_spec.rb`.)*
- [x] A02, A05, A06: report scope/variance approval/recovery có quyền; closed ca không bị cashier sửa. *(Thu ngân chỉ thấy ca của mình, không thấy tổng tiền mặt ca đang mở trước khi đếm; chênh lệch vượt ngưỡng cần duyệt người khác; rút tiền/nộp két cần người thứ hai xác nhận; quản lý có quyền recover đóng được ca vắng chủ.)*
- [x] W08: close checklist/variance/report filters dùng được tablet/keyboard, không chỉ màu phân loại. *(E2E mock 3 viewport cho đóng ca, nộp/rút két, late-cash, báo cáo; trạng thái chênh lệch hiện bằng chữ Thừa/Thiếu/Khớp. Kiểm trên API thật chuyển phase 11.)*

## Risk Assessment

- Close chỉ khóa Shift nhưng settlement không tham gia: bắt buộc shared barrier protocol và race regression cho mọi writer.
- Double-count change/refund hoặc nhầm sales với receipt: reconcile fixtures và source links, không UI-calculated ledger.
- Late cash attest bị coi receipt mới ca S2: bắt buộc custody/closure-variance/opening links và manager classification; chưa đủ evidence thì attention, không bịa CashMovement.
- Policy threshold chưa duyệt: manager configure trước bật automatic approval; không ngầm cho chênh lệch vô hạn.

## Next Steps

Phase 10 hiển thị/in snapshot theo financial facts này; phase 11 duyệt operational reconciliation trước full retail.

## Review 07/11/2026

Hai review độc lập xác nhận barrier phủ đủ 7 đường ghi cash movement với thứ tự khóa nhất quán; các lỗi tìm thấy đã sửa và có test:

- Chi liability hoặc hoàn tiền mặt từ tiền đang giữ ngoài két (`held`) trừ vào két, tạo thừa giả khi đóng ca. Nay bị từ chối `held_custody`; chi từ nơi giữ thì ghi xuất custody, không đụng két.
- Cùng một khoản tiền trễ được giải thích hai lần (qua closure và qua phiếu giữ tiền) làm S2 expected thành 200k. Nay phiếu giữ tiền tự gắn closure còn thừa, `in_opening_float` không vượt tiền đầu ca, người đóng ca và người duyệt chênh lệch không được tự đối soát.
- Đếm két bị coi là còn hiệu lực theo giờ máy chủ. Nay so theo id cash movement cuối lúc đếm.
- Rút tiền và nộp két chỉ một người tự khai. Nay cần chứng từ và người thứ hai xác nhận mới ghi movement.
- Tải export không kiểm lại phạm vi đọc, dựng cả file trong bộ nhớ và nhét vào JSON. Nay kiểm lại quyền, phân trang theo khóa, ghi Tempfile, link ký một phút.
- Frontend: mất phản hồi khi rút tiền có thể ghi hai lần (key đổi khi sửa lý do) và kết quả đếm/duyệt không tra lại được (thiếu `branch_id` trong receipt). Nay intent ổn định theo dialog/revision, receipt có `branch_id`, hiện "Đang kiểm tra kết quả". Sửa thêm: wizard late-cash không gửi số tiền, link checklist không mở đúng đơn/phiếu, sổ quỹ không hiện tóm tắt theo ca, export hết hạn vẫn cho tải, đổi tab báo cáo hiện dữ liệu cũ.
- Đơn nháp chưa nhận tiền của ca đã đóng được chuyển sang ca mới khi thu ngân mở lại (có audit); đơn đã nhận tiền vẫn chặn đóng ca.

## Đóng phase 07/11/2026

**Kết quả:** backend POS 345 examples, 0 failures (thêm `shift_closure_spec.rb`, `reports_spec.rb`, `shift_close_spec.rb`, `spec/integration/spree/pos/shift_close_race_spec.rb`). `apps/pos`: lint, typecheck sạch, 111 unit; Playwright 219 passed / 6 skipped (live API opt-in). Chi tiết: [báo cáo triển khai](./reports/phase-09-implementation.md).

**Migration:** `20261107143000_create_spree_pos_shift_closures`, `20261107150000_add_pos_cash_movement_requests` chỉ áp database test. Development vẫn chờ sao lưu.

**Ghi chú thiết kế:** đếm và đóng là hai lệnh riêng (`Shifts::Count`, `Shifts::Close`); không có `shifts/correct.rb` vì mọi sửa chữa là bút toán mới. Một controller báo cáo allowlist phục vụ năm loại báo cáo. Đếm mù là bắt buộc trong UI và báo cáo nhưng thu ngân vẫn đếm lại được (mỗi lần đếm có audit).

**Chuyển phase sau:** in phiếu đóng ca và hiển thị khách (phase 10); kiểm trên API thật, tải lớn và quy trình vận hành két (phase 11). Vẫn sandbox-only.
