---
phase: 4
title: "Wizard thiết lập và trang Mô hình kinh doanh"
status: pending
effort: "2,5 ngày"
dependsOn: [2, 3]
---

# Phase 4: Wizard thiết lập và trang Mô hình kinh doanh

## Overview

Phase này gồm hai màn hình:
- **Thiết lập cửa hàng**, hiện khi `context.onboarding.required` và người dùng có quyền thiết lập;
- **Cấu hình → chi nhánh → Mô hình kinh doanh**, để xem và đổi hồ sơ, bật / tắt từng module.

Cần duyệt **giá trị mặc định của 19 hồ sơ** (câu hỏi mở 1 ở `plan.md`) trước khi làm phase này.

## Thiết lập cửa hàng (`/setup`)

Điểm vào:
- `pos-shell.tsx`: khi `onboarding.required && onboarding.can_setup` thì chuyển sang `/setup` thay vì mở `ContextSetupDialog`.
- Không có quyền: giữ màn "Chưa có chi nhánh" hiện tại (`context-selector.tsx:107`), thêm câu "Nhờ quản trị cửa hàng thiết lập POS".

Các bước, mỗi bước một màn, có nút Quay lại, chưa gửi gì lên server cho đến bước 5:

1. **Bạn kinh doanh gì?**
   - Hai nhóm: **Bán buôn, bán lẻ** (13 thẻ) và **Ăn uống, giải trí** (6 thẻ, nhãn "Sắp hỗ trợ").
   - Mỗi thẻ có tên và một dòng mô tả lấy từ locale.
   - Bấm thẻ "Sắp hỗ trợ" thì hiện: "Chúng tôi sẽ báo khi hỗ trợ. Bạn có bán thêm hàng hóa không?" Trả lời có → chọn tiếp một hồ sơ bán lẻ (gợi ý `khac`, hoặc `cang_tin_tram_dung` → `tap_hoa_sieu_thi`). Hồ sơ F&B vào `interests`.
   - Thứ tự thẻ theo `order` của server.
2. **Có bán sỉ không?** Có / Không. Ghi chú: "Bảng giá sỉ sẽ có trong bản cập nhật sau."
3. **Chi nhánh đầu tiên**
   - Tên, mã (tự sinh từ tên, sửa được), múi giờ (mặc định theo store), kho bán (chọn từ `GET /pos/configuration/locations`).
   - Store chưa có kho nào: hiện hướng dẫn tạo kho trong Admin Dashboard, không cho đi tiếp.
   - Tên quầy đầu tiên: tùy chọn, mặc định "Quầy 1".
   - Ô "Cấp cho tôi toàn quyền tại chi nhánh này", tick sẵn.
4. **Xem trước**
   - Các chức năng được bật (module) kèm một câu giải thích mỗi chức năng.
   - Các mặc định của chi nhánh, sửa được tại chỗ.
   - Đơn vị mẫu sẽ thêm.
   - Danh sách "Ngành này thường dùng": các cờ rủi ro, ô chọn **để trống** (D6), mỗi cờ có một câu mô tả rủi ro lấy từ `branch-features.tsx`.
5. **Tạo**
   - `POST /pos/onboarding` với một idempotency key sinh một lần cho cả wizard (giữ trong state, không tạo key mới khi bấm lại).
   - Lỗi mạng hoặc timeout: hiện "Đang kiểm tra kết quả…" và gửi lại **cùng key**, theo đúng mẫu `submission-key.ts`.
   - Thành công: chọn chi nhánh / quầy mới làm context, chuyển về màn bán, mở hộp **Mở ca** như bình thường.

Yêu cầu chung:
- Đủ ba viewport (desktop / tablet / mobile).
- Điều hướng được bằng bàn phím; có `aria` cho nhóm thẻ (radio group).
- Không lưu wizard vào IndexedDB.

## Mô hình kinh doanh (`/settings/branches/$branchId/business-model`)

- Hiện hồ sơ hiện tại của chi nhánh, cùng danh sách module và trạng thái của từng module.
- **Đổi ngành:** chọn hồ sơ khác → gọi `profile/preview` → hiện diff:
  - module bật / tắt, kèm cảnh báo `in_use` nguyên văn ý D5;
  - từng default với ô chọn "Áp giá trị của ngành mới", mặc định **không tick**;
  - đơn vị mẫu sẽ thêm.

  Nhập lý do → `PUT profile` với `expected_profile_key`. Gặp 409 `profile_conflict` thì tải lại diff.
- **Bật / tắt từng module:** công tắc kèm lý do, giống `branch-features.tsx`. Bật module có phụ thuộc thì báo trước những module sẽ bật theo.
- **Hồ sơ chính của store** (chỉ người có `write_pos_topology`): đổi mặc định cho chi nhánh mới, bật/tắt "Có bán sỉ", danh sách ngành "Sắp hỗ trợ" đang quan tâm.
- Khi tạo chi nhánh mới trong `topology.tsx`: thêm ô chọn hồ sơ, mặc định là hồ sơ chính của store; các default sẽ được điền sẵn vào form.

## Files

| Action | Path |
|---|---|
| create | `apps/pos/src/pages/setup.tsx`, `apps/pos/src/components/setup/{profile-picker,setup-branch-step,setup-preview-step}.tsx` |
| create | `apps/pos/src/pages/settings/business-model.tsx`, `apps/pos/src/components/profile-diff.tsx` |
| create | `apps/pos/src/hooks/use-onboarding.ts`, `use-branch-modules.ts` |
| create | `apps/pos/src/lib/setup-wizard.ts`, `setup-wizard.test.ts` (state, sinh mã chi nhánh, payload) |
| modify | `apps/pos/src/router.tsx`, `apps/pos/src/components/pos-shell.tsx`, `context-selector.tsx`, `topology-editor.tsx`, `apps/pos/src/pages/settings/topology.tsx` |
| modify | `apps/pos/src/locales/vi.json`, `en.json`, `apps/pos/src/styles.css` (hoặc `styles/setup.css`) |
| create | `apps/pos/e2e/onboarding.spec.ts`, `apps/pos/e2e/business-model.spec.ts` |

## Success Criteria

- [ ] Store mới (mock `onboarding.required`) với tài khoản quản trị → vào `/setup`. Chọn "Nhà thuốc", đi hết 5 bước → có chi nhánh, quầy, context đã chọn, màn bán mở hộp Mở ca.
- [ ] Mất mạng ở bước 5 rồi bấm lại → gửi cùng key, không tạo chi nhánh thứ hai (e2e mock trả timeout lần đầu).
- [ ] Chọn "Cafe, Trà sữa" → không tạo được chi nhánh F&B. Chọn tiếp hồ sơ bán lẻ thì `interests` có `cafe_tra_sua`.
- [ ] Không có cờ rủi ro nào được bật nếu người dùng không tick.
- [ ] Tài khoản không có quyền thiết lập → thấy câu nhắc, không thấy wizard.
- [ ] Đổi hồ sơ một chi nhánh từ `khac` sang `thoi_trang`: diff báo tắt ba module, kèm cảnh báo SKU đang dùng. Không tick default nào → cấu hình chi nhánh không đổi. Lối vào cấu hình của ba module biến mất; màn bán không đổi.
- [ ] Axe không có lỗi nghiêm trọng ở `/setup` và trang Mô hình kinh doanh (theo `accessibility.spec.ts`).
