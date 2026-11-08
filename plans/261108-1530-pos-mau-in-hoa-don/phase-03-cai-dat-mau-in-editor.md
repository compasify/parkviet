---
phase: 3
title: "Cài đặt POS → Mẫu in (editor)"
status: pending
effort: "3 ngày"
dependsOn: [2]
---

# Phase 3: Cài đặt POS → Mẫu in (editor)

## Overview

Màn hình quản lý và chỉnh mẫu trong POS. Màn có quyền đọc theo `administration.read`, chỉnh theo `administration.write` (đã có trong context, `context_controller.rb:23-26`).

## Routes và điều hướng

- `/settings/receipt-templates`: danh sách.
- `/settings/receipt-templates/$templateId`: editor.
- Thêm link "Mẫu in" trong trang Cài đặt (`pages/settings/topology.tsx`), cấp cửa hàng, không nằm trong `BranchSettingsFrame` vì mẫu không theo chi nhánh (D1).
- Đăng ký route trong `apps/pos/src/router.tsx`.

## Danh sách mẫu

- Nhóm theo loại chứng từ (Phiếu bán hàng, Tạm tính, Phiếu thanh toán, Trả hàng, Hoàn tiền, Chốt ca).
- Mỗi dòng: tên, khổ giấy, nhãn "Mặc định", thời gian và người sửa cuối.
- Hành động: Sửa, Nhân bản, Đặt mặc định, Ngừng dùng. "Tạo mẫu" mở dialog chọn loại chứng từ, khổ giấy, tên, và tạo từ mẫu gợi ý.
- Người chỉ có quyền đọc thấy danh sách và preview, không có nút ghi.

## Editor

Bố cục 2 cột (≥ 1024px), 1 cột với preview dạng tab trên màn hẹp.

Cột trái là các accordion:
1. **Trang & giấy**: tên mẫu, khổ giấy (dùng `PaperPicker`), lề, font (sans/mono), cỡ chữ S/M/L, giãn dòng.
2. **Đầu phiếu**: danh sách khối (logo, thông tin cửa hàng, text, tiêu đề, đường kẻ, khoảng trống). Thêm, xóa, lên/xuống bằng nút (kéo thả ở phase 5).
3. **Thông tin chung**: checkbox field meta + đổi nhãn.
4. **Dòng hàng**: kiểu xếp chồng hoặc bảng, checkbox cột, hiện serial/lô/HSD, hiện quy đổi đơn vị.
5. **Tổng & thanh toán**: checkbox field + đổi nhãn. Dòng "Tổng cộng" hiện nhưng bị khóa, có tooltip giải thích.
6. **Chân phiếu**: như đầu phiếu. Disclaimer "không phải HĐĐT" hiện ở cuối, bị khóa.

Ô text có nút **Chèn thông tin** (và gõ `{` để gợi ý) liệt kê biến kèm giá trị mẫu: `{store.name}`, `{store.address}`, `{store.phone}`, `{store.email}`, `{store.url}`, `{branch.name}`, `{branch.code}`, `{branch.return_window_days}`, `{register.name}`, `{cashier}`, `{document.number}`, `{document.time}`, `{customer.name}`.

Cột phải là **preview trực tiếp** dùng `PrintSheet` của phase 1:
- Nguồn dữ liệu: "Dữ liệu mẫu" (fixture theo loại chứng từ, dùng thông tin cửa hàng thật từ context) hoặc "Phiếu gần nhất" (gọi `GET /pos/receipts?source_type=…` ở chi nhánh đang chọn, lấy bản đầu).
- Chọn chi nhánh/quầy để xem biến đổi theo (D1).
- Cảnh báo khi dòng text vượt số ký tự ước tính của khổ 58/80mm.

Thanh hành động:
- **Lưu**: PATCH với `expected_version`. Khi gặp 409 thì báo "Mẫu vừa được người khác sửa", cho tải lại hoặc ghi đè bằng cách lưu lại trên version mới.
- **In thử**: in preview với banner "IN THỬ — KHÔNG CÓ GIÁ TRỊ" qua `createBrowserPrintAdapter`; không ghi nhận bản in.
- **Khôi phục mặc định**: nạp config mặc định vào form (chưa lưu).
- **Lịch sử**: drawer liệt kê version; xem preview từng version; "Khôi phục" gọi `restore`.
- Chặn rời trang khi có thay đổi chưa lưu.

## Validation phía client

Mirror các giới hạn server (độ dài, số khối, biến hợp lệ) để báo lỗi ngay; lỗi 422 từ server map về đúng khối theo `pointer`.

## Files

| Action | Path |
|---|---|
| create | `apps/pos/src/pages/settings/receipt-templates.tsx`, `receipt-template-editor.tsx` |
| create | `apps/pos/src/components/receipt-template/{block-list,block-editor,field-toggles,variable-picker,template-preview,version-drawer}.tsx` |
| create | `apps/pos/src/hooks/use-receipt-templates.ts` (react-query, key `['pos','receipt-templates']`) |
| create | `apps/pos/src/lib/receipt-template/{sample-data,validate}.ts` + tests |
| modify | `apps/pos/src/router.tsx`, `apps/pos/src/pages/settings/topology.tsx` |
| modify | `apps/pos/src/locales/vi.json`, `en.json` |
| modify | `apps/pos/src/styles.css` (layout editor) |
| create | `apps/pos/e2e/receipt-templates.spec.ts` (API mock theo kiểu `branch-assortment.spec.ts`) |

## Success Criteria

- [ ] e2e: tạo mẫu từ gợi ý → đổi text chân phiếu có biến → preview cập nhật ngay → lưu → tải lại thấy đúng; đặt mặc định; nhân bản; ngừng dùng; khôi phục version cũ.
- [ ] e2e: người dùng chỉ đọc không thấy nút ghi; 409 hiện thông báo xung đột; 422 đánh dấu đúng khối.
- [ ] Không tắt được các phần bị khóa trên UI.
- [ ] In thử không tạo `ReceiptPrint`.
- [ ] Đủ i18n vi/en; điều khiển dùng được bằng bàn phím (accordion, checkbox, nút lên/xuống).
