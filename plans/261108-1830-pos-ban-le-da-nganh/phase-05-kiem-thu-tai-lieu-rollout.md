---
phase: 5
title: "Kiểm thử hồi quy, tài liệu, rollout"
status: pending
effort: "1,5 ngày"
dependsOn: [3, 4]
---

# Phase 5: Kiểm thử hồi quy, tài liệu, rollout

## Kiểm thử

1. **Hồi quy server:** chạy toàn bộ `pnpm spree rspec spec/requests/spree/pos/ spec/models/spree/pos/ spec/services/spree/pos/`. Đặc biệt các spec `sale_lines_spec`, `traceability_spec`, `scale_labels_spec`, `settlement_spec`, `returns_refunds_spec` phải pass **hai lần**:
   - lần một với chi nhánh fixture bật đủ ba module;
   - lần hai với chi nhánh tắt cả ba module, nhưng SKU đã được cấu hình **trước khi** tắt.

   Lần hai chứng minh D5. Làm bằng shared context `with branch modules off` trong `spec/support`.
2. **Hồi quy client:** `pnpm --dir apps/pos test:e2e` đủ ba viewport, cộng các spec mới `branch-modules`, `onboarding`, `business-model`.
3. **Real API:**
   - Thêm vào `e2e/support/pos-live-fixture.rb` tùy chọn tạo store mới chưa onboard (`onboarding=1`). Chỉ chạy trên database cục bộ, gắn nhãn `POS Live <tag>`.
   - Phần dọn dẹp xóa store profile, chi nhánh, module của fixture theo đúng mẫu hiện có.
4. **Migration trên bản sao dữ liệu dev:**
   - Đếm chi nhánh trước và sau.
   - Mỗi chi nhánh có đủ ba dòng module.
   - Store đã có chi nhánh không thấy wizard.
5. **Hiệu năng:** `GET /pos/context` thêm `modules` chỉ tốn một query theo chi nhánh. Đo bằng `test:perf` để kiểm thời gian chuyển context không tăng đáng kể.

## Tài liệu

- `apps/pos/README.md`:
  - mục "Khái niệm chính" thêm **Ngành / mô hình kinh doanh**;
  - mục "Quản trị" thêm **Mô hình kinh doanh**;
  - mục "Cách sử dụng" thêm bước 0 **Thiết lập cửa hàng**;
  - ghi rõ "tắt chức năng không làm đổi cách bán SKU đã cấu hình".
- Báo cáo kiến trúc `plans/reports/261108-1800-pos-multi-industry-architecture.md` §8: D5 và D8 đã được ghi vào lúc lập plan. Khi xong, bổ sung những gì thực tế làm khác plan.
- `plans/261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md`: thêm một dòng tham chiếu tới plan này ở mục 2 (vẫn chỉ bán lẻ; không đổi ranh giới "không F&B").
- Ghi kết quả từng phase vào phần "Kết quả" của file phase, theo cách các plan trước đã làm.

## Rollout

- Không cần feature flag mới. Store cũ được backfill thành `khac` và đã có store profile, nên không thấy wizard và không đổi gì.
- Thứ tự deploy:
  1. Migration + server (client cũ bỏ qua `modules`, coi như bật hết).
  2. Client.
- Rollback client an toàn vì server vẫn tương thích ngược. Rollback server cần migration down: xóa hai bảng và hai cột, không có dữ liệu tiền bị ảnh hưởng.

## Success Criteria

- [ ] Toàn bộ spec server pass ở cả hai chế độ module.
- [ ] `pnpm --dir apps/pos lint && pnpm --dir apps/pos typecheck && pnpm --dir apps/pos test && pnpm --dir apps/pos test:e2e` pass.
- [ ] README và báo cáo kiến trúc đã cập nhật; mọi phase có phần "Kết quả".
- [ ] Đã thử wizard với real API trên store mới ít nhất một lần, có ghi lại kết quả.
