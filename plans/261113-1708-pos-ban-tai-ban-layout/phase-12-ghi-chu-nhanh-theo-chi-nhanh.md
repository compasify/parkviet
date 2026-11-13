---
phase: 12
title: "Ghi chú nhanh do chi nhánh đặt"
status: pending
effort: "0,5 ngày"
dependsOn: [4]
---

# Phase 12: Ghi chú nhanh do chi nhánh đặt

## Bối cảnh

Panel tùy chọn món (`modifier-panel.tsx`) hiện ghi chú nhanh lấy cứng từ locale `menuQuickNoteList`: "Ít cay", "Không hành", "Ít ngọt", "Mang ra sau". Danh sách này không hợp mọi quán (quán cà phê cần "Ít đá", "Không đường"), và "Mang ra sau" trùng ý với nút "Giữ món" theo course.

Chi nhánh đã có một thiết lập danh sách cùng kiểu: `course_labels`, lưu trên `spree_pos_branches`, sửa ở tab Sơ đồ bàn của pos-dashboard qua `table_settings_controller`. Ghi chú nhanh đi đúng đường đó.

## Yêu cầu

1. Cột `spree_pos_branches.quick_notes` (jsonb, mảng chuỗi, tối đa 12 mục, mỗi mục 1–40 ký tự). Null nghĩa là dùng danh sách mặc định của locale.
2. `branch.to_pos` trả `quick_notes`; `table_settings_controller` cho sửa; OpenAPI cập nhật.
3. pos-dashboard, tab Sơ đồ bàn: ô sửa danh sách ghi chú nhanh như chỗ sửa nhãn course (thêm, xóa, kéo thứ tự nếu nhãn course có).
4. POS: `modifier-panel.tsx` dùng `quick_notes` của chi nhánh, rỗng thì không hiện hàng ghi chú nhanh, null thì dùng locale. Bỏ "Mang ra sau" khỏi danh sách mặc định.

## File

- Tạo: migration `add_quick_notes_to_pos_branches` (`pnpm spree generate migration`, sao lưu DB dev trước khi migrate)
- Sửa: `server/app/models/spree/pos/branch.rb`, `table_settings_controller.rb`, `server/openapi/pos-staff.yaml`, `server/db/schema.rb`
- Spec: `server/spec/requests/spree/pos/table_settings_spec.rb`
- Sửa: `packages/pos-shared/src/types/pos-context.ts`, `apps/pos/src/components/table-service/modifier-panel.tsx`, locale POS
- Sửa: `apps/pos-dashboard/src/pages/branch-floor-plan.tsx`, `apps/pos-dashboard/src/lib/floor-plan.ts` (+ test), locale pos-dashboard

## Các bước

1. Spec: lưu danh sách hợp lệ, quá 12 mục, mục rỗng hoặc quá dài, null.
2. Migration, model, controller.
3. Ô sửa ở pos-dashboard; panel POS đọc danh sách.

## Kiểm tra

```bash
pnpm spree rspec spec/requests/spree/pos/table_settings_spec.rb
pnpm --dir apps/pos-dashboard typecheck && pnpm --dir apps/pos-dashboard exec vitest run src/lib/floor-plan.test.ts
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint
```

## Rủi ro và rollback

- Khi dump `schema.rb`, Rails làm hỏng điều kiện `where: "active = true"` của ràng buộc chống trùng đặt bàn; sửa tay trước khi commit.
- Rollback: revert và `pnpm spree rails db:rollback` một bước; cột nullable.
