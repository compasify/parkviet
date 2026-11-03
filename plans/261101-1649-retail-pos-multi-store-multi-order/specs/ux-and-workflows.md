# UI/UX và luồng thao tác POS

## 1. Hướng thiết kế

POS desktop/tablet web, tiếng Việt mặc định; quen thuộc với KiotViet/Sapo/MISA nhưng không sao chép logo, tài sản hoặc giao diện pixel-perfect. Bố cục ưu tiên tốc độ thu ngân, không dùng layout landing/dashboard thống kê làm màn bán hàng.

Tham khảo design intelligence: accessible dense workspace, primary xanh, surface sáng, font có tiếng Việt (Be Vietnam Pro/Noto Sans/system fallback), tiền tabular numerals. Kết quả script gợi ý landing sự kiện không liên quan đã **loại bỏ**; chỉ giữ readability/contrast/touch guidance. UI primitives thống nhất với dashboard khi hợp lý; flat borders, ít hiệu ứng, không glassmorphism/gradient trang trí.

## 2. Layout desktop ≥1280px

```text
┌───────────────────────────────────────────────────────────────────────────────┐
│ ☰ Bán hàng │ Chi nhánh Hà Nội ▾ │ Quầy 02 │ Ca đang mở │ Kết nối │ Thu ngân ▾ │
├───────────────────────────────────────────────────────────────────────────────┤
│ Đơn 01 – Lan 320k │ Đơn 02 – Chờ CK ● │ Đơn 03 │ [+ Đơn mới] │ Danh sách ▾ │
├────────────────────────────────────────────────┬──────────────────────────────┤
│ [Quét mã / tìm tên, SKU, barcode      F3]       │ [Tìm khách hàng F4] [+ Thêm] │
│ Tất cả / nhóm hàng / sản phẩm thường bán       │ Khách lẻ / khách đã chọn    │
├────────────────────────────────────────────────┤                              │
│ STT  Sản phẩm       SL    Đơn giá   Thành tiền  │ Tiền hàng         500.000 ₫ │
│ 1    Áo – Đen/M   [- 2 +] 200.000    400.000   │ [Giảm giá F6]     -50.000 ₫ │
│ 2    Mũ           [- 1 +] 100.000    100.000   │ Thuế / phí         ...      │
│      giảm dòng / ghi chú / xóa có undo draft   │ TỔNG CẦN TRẢ      450.000 ₫ │
│                                               │                              │
│ [Grid ảnh sản phẩm bật/tắt]                    │ [Chọn thanh toán ▾]         │
│                                               │ Tiền mặt / CK / Thẻ / Kết hợp│
│                                               │ [Khách đưa]  [Ghi nợ]       │
│                                               │ Đã thu / Còn thiếu / Trả lại│
├────────────────────────────────────────────────┼──────────────────────────────┤
│ [Ghi chú] [Giữ đơn] [Mở đơn giữ] [Thao tác ▾]  │ [THANH TOÁN              F9] │
└────────────────────────────────────────────────┴──────────────────────────────┘
```

- Checkout panel khoảng 340–400px, product/line area co giãn; không giữ fixed width gây overflow ở màn nhỏ. Grid ảnh có toggle, không chiếm chỗ dòng hàng bắt buộc.
- Tổng tiền, nút khách hàng, giảm giá, phương thức và CTA không chôn trong menu ba chấm.
- Tab overflow dùng scroll strip có controls/list/search. Không hardcode chỉ 3/5 tab, không render toàn bộ line grids của hàng trăm draft.
- Mỗi tab có nhãn/mã, tên khách nếu có, amount, badge text `Đang soạn / Đang lưu / Đã lưu / Chờ chuyển khoản / Thu một phần / Cần xử lý`.
- Chỉ CTA hoàn tất là primary. `+ Đơn mới` luôn truy cập được cả khi tab khác chờ payment.

## 3. Tablet và điện thoại

- 1024px landscape: 2 vùng rút gọn, line table responsive, checkout panel 320px nếu còn đủ diện tích.
- 768px portrait: hàng hóa/giỏ theo pane, summary bar và checkout sheet; tab strip/overflow vẫn giữ. Payment sheet không ngăn chuyển sang đơn khác qua action `Để chờ, bán đơn khác`.
- 375px: sale flow đủ dùng với danh sách cards, sticky totals và payment sheet; quản trị/báo cáo bảng có card view hoặc scroll vùng bảng có nhãn, không tràn toàn trang.
- Touch targets ≥44px (ưu tiên 48px cho thao tác thường xuyên), contrast WCAG AA, label hiện, focus ring, keyboard và screen reader. Không chỉ dùng đỏ/xanh để diễn đạt tiền đã về.
- Header/context/summary không đè nội dung khi zoom 200%, bàn phím mềm hoặc orientation change.

## 4. Luồng nhiều đơn bắt buộc

1. Thu ngân scan hàng cho A, chọn khách, giảm giá; tab A `Đã lưu`.
2. Chọn chuyển khoản và tạo request 450.000đ. Tab A `Chờ chuyển khoản`; giữ nguyên snapshot.
3. Nhấn `+ Đơn mới`; scan bán B, thu cash, in bill và giao hàng.
4. A được authorized staff xác nhận nhận tiền hoặc adapter tương lai báo về. Badge/toast ghi `Đơn A đã nhận 450.000đ`; active tab B/C không đổi.
5. Mở lại A để kiểm tra/hoàn tất và bàn giao; nếu order auto-complete policy đã duyệt thì vẫn không auto-handover hàng.
6. Reload trình duyệt giữa bất kỳ bước nào: lấy lại server state, không mất khách/giảm giá/receipts, không tạo payment mới.

Đang có mutation: tab khác vẫn mở được; callback ghi kết quả vào đúng workspace ID. Confirm payment dialog phải luôn hiện mã đơn, khách, tổng và branch. Không dùng global Enter để vô tình thanh toán tab vừa chuyển.

## 5. Khách hàng và giảm giá

- Search customer theo phone/name; kết quả tối thiểu, không lộ địa chỉ/nợ cho người không quyền. `+ Thêm khách hàng`: tên, điện thoại, trường thêm tùy chọn, inline validation, lưu rồi gắn đúng tab.
- Không bắt buộc email cho walk-in; trùng phone cảnh báo và mở chọn, không tự merge hai người. Debt bắt buộc customer đã xác định và account approved.
- Discount dialog chọn `Dòng / Toàn đơn`, `% / ₫`, lý do, preview server. Hiển thị promotion riêng với manual; không âm thầm cộng hai mức giảm.
- Vượt giới hạn: yêu cầu manager approval bound đúng đơn/revision; không đề nghị đăng nhập admin trên cùng cashier session rồi để quên quyền.
- Sửa giá đơn vị là capability riêng; tổng trả về từ server. Sau partial receipt UI khóa sửa và giải thích workflow chỉnh sai/đổi trả.
- Hàng cân: input số lượng có đơn vị rõ `kg/g/lít/ml`, precision từ SKU, tare/net khi profile yêu cầu, đổi đơn vị có preview giá/tồn. Quy đổi thùng/lốc/chai không tạo tồn độc lập sai; bill hiển thị đơn vị khách mua và số lượng đúng.
- Hai gói cùng SKU khác cân/giá/unit/lô có dòng và ID riêng; sửa/xóa/giảm giá/đổi trả một gói không gộp hoặc ghi đè gói còn lại. Chỉ ordinary scans có merge key tương thích mới cộng số lượng theo intent; reload vẫn giữ identity/snapshot.
- Serial/IMEI: scan/chọn serial theo từng unit, hiển thị đủ/thiếu, branch và tình trạng; chặn trả tiền/giao nếu chưa đủ serial hoặc serial bị quầy khác reserve. Lot/expiry: FEFO gợi ý, hạn dùng hiện rõ, lý do đổi lô; expired/quarantined không bán được.

## 6. Payment panel

- Chọn method hiển thị label/icon và trạng thái; danh sách lấy server capabilities của branch/register, không hardcode provider classes.
- Cash: amount applied, tiền khách đưa, quick denomination buttons, change; validate insufficient, không mặc định exact receipt là đã nhận tiền trước confirm.
- Bank: receiving account, amount, reference, optional QR; `Đang chờ` khác `Đã xác nhận`. `Xác nhận đã nhận tiền` chỉ theo quyền, có evidence form; không nhận ảnh biên lai khách làm chứng cứ tự động.
- External card: `Thanh toán trên máy ngân hàng`, reference/approval, amount; cashier attest sau approved. Timeout không tự retry charge; nút ở đây không điều khiển máy ngân hàng.
- Kết hợp: nhiều allocation rows, thêm/xóa trước settlement; hiển thị `Đã xác nhận / Chờ xác nhận / Còn phải thu / Ghi nợ được duyệt`. Số tiền chờ không được cộng vào đã thu.
- Debt: không là tender đã thu. Hiện `Ghi nợ 100.000đ`, khách, limit available, due date, approver; confirm button ghi rõ `Hoàn tất & ghi nợ`.
- Partial receipts: có nút tiếp tục thu hoặc `Để chờ, bán đơn khác`; không `Hủy` làm mất ledger. Hoàn tác receipt đã settle là reversal/refund có quyền.
- Timeout: `Đang kiểm tra kết quả`, tra command state trước cho retry; không toast success optimistic.
- Tiền thừa/trễ: badge `Tiền chưa phân bổ – cần xử lý`, inbox hiển thị original order/attempt, received/available/reserved/paid-out riêng theo quyền. Manager chọn phân bổ đúng chủ hưởng hoặc hoàn khoản chưa phân bổ, có preview/evidence/approval; payout unknown hiện `Đang kiểm tra khoản hoàn`, không cho chi/phân bổ lại. Không tự gắn đơn kế tiếp hoặc yêu cầu tạo trả hàng giả.
- Discounted-to-zero order: không tạo payment zero giả; confirm theo quyền/reason, hoàn tất core payment-not-required và ghi audit.

## 7. Màn hình phụ

- Orders: tìm bill, thời gian/chi nhánh/quầy/thu ngân/status, receipt/tenders/timeline, reprint, return.
- Returns/exchange: chọn original invoice và lines còn được trả, reason, condition/restock, preview debt-credit/refund; phần chênh lệch có chứng từ rõ.
- Preview trả nhiều lần hiển thị số lượng/giá trị lũy kế, entitlement đã dùng/reserved và phần được cấp lần này; dùng cùng residual policy cho credit note/refund/tax/discount, full return không mất VND do round từng lần. Sửa allocation đã hoàn tiền phải báo phần không thể giải phóng, không hứa trả full receipt vào available balance.
- Trả hàng cân giữ precision/conversion snapshot; serial/lô phải đối chiếu giao dịch gốc, cảnh báo sai serial/hạn dùng và cho quarantine thay vì mặc định nhập lại bán được.
- Customer debt: số dư/overdue, danh sách receivables, thu nợ và allocation preview; không có sales mới.
- Shifts: mở ca/float, cash in/out, count blind, close checklist, variance và approval. Pending orders có link quay lại hoặc handover hợp lệ.
- Late cash: manager wizard hỏi tiền thực nhận ca nào và hiện ở drawer/opening float/safe/bàn giao nào; phân biệt xác nhận receipt tài chính với tiền mới vào két. Link original closed variance và chứng từ custody; không mặc định cộng tiền vào ca mới hoặc sửa số count đã chốt.
- Reports: today/shift/branch và filters; tách `Doanh số`, `Thực thu`, `Tiền mặt trong két`, `Công nợ`; export theo quyền.
- Settings: manager cấu hình branches/registers/membership/payment methods/receipt; catalog và procurement sâu link dashboard đúng context.
- Customer display: explicit pin một order/attempt; cashier đổi tab không tự đổi QR khách đang dùng. Bind generation/clear trước gắn khách tiếp theo, cashier thấy freshness và phải có ACK generation hiện tại; thiếu ACK thì ngừng dùng display cho khách kế, không đoán đã clear. Display ẩn QR khi biết offline/hết local freshness deadline hoặc generation unresolved; resume hide trước revalidate, cached/delayed response không kéo dài lease. Cảnh báo QR đã chụp vẫn có thể chuyển tiền và đi late-receipt recovery.

## 8. Keyboard/scanner và trạng thái

- Proposed map: F3 tìm hàng, F4 khách, F6 giảm giá, F8 khách đưa, F9 mở payment/confirm sau review, Esc chỉ đóng popup. Hiển thị shortcut help; mới/chuyển đơn chọn shortcut sau test browser/OS, không chiếm Ctrl+T/W/L/R.
- Không giữ scanner listener global khi focus phone/name/bank reference hoặc IME đang compose. Hỗ trợ barcode terminator theo thiết bị; duplicate physical scans có intent khác, network replay cùng scan không tăng lần hai.
- Loading có placeholder, saving/saved/error có text và retry đúng command; 401/session expired khóa thao tác, giữ draft server và hướng dẫn login.
- Giữ scroll/focus/search từng tab; toast không cướp focus. Modal focus trap/return focus, live region thông báo kết quả payment đúng mã đơn.

## 9. Nguồn tham khảo UI chính thức

Đọc từ public help docs qua researcher ngày 01/11/2026; là bằng chứng về pattern, không phải screenshot review hoặc cam kết parity từng phiên bản:

1. Sapo nhiều đơn/+ và điều hướng: https://help.sapo.vn/them-don-hang-moi-tai-quay
2. KiotViet tìm hàng/scan/grid: https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/retail-ban-hang/ban-hang/
3. Sapo thêm hàng: https://help.sapo.vn/them-san-pham-vao-don-hang-ban-tai-quay
4. KiotViet thêm khách nhanh: https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/retail-lam-quen-voi-kiotviet/buoc-3-ban-hang/
5. Sapo giảm giá/đổi trả/cuối ngày: https://help.sapo.vn/he-thong-phim-chuc-nang-trong-giao-dien-ban-tai-quay-pos
6. KiotViet split tender: https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/retail-thanh-toan/thanh-toan/
7. Sapo payment picker: https://help.sapo.vn/thanh-toan-don-hang-ban-tai-quay-pos
8. MISA công nợ (bán buôn): https://eshop.misa.vn/help/vi/kb/lap_hoa_don_ban_buon
9. MISA chọn chi nhánh web: https://eshop.misa.vn/help/vi/kb/ban-hang-tren-trinh-duyet-web
10. Sapo context: https://help.sapo.vn/cau-hinh-va-thao-tac-tren-man-hinh-ban-tai-quay
11. Sapo ca bán: https://help.sapo.vn/quan-ly-ca-ban-hang
12. Shortcuts khác nhau giữa docs: https://help.sapo.vn/su-dung-phim-tat-va-shortcut và https://help.sapo.vn/huong-dan-su-dung-phim-tat-shortcut

## Next steps

Phase 1 phải tạo wireframe/prototype cho desktop/tablet, 3 đơn song song và split+debt, lấy duyệt layout trước sản xuất UI. Các spec trên là đề xuất, chưa phải ảnh giao diện đã dựng hoặc usability test đã chạy.
