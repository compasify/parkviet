---
phase: 7
title: "E2E, tài liệu và rà soát"
status: completed
effort: "1 ngày"
dependsOn: [3, 4, 5, 6]
---

# Phase 7: E2E, tài liệu và rà soát

## Bối cảnh

Các phase trước đã sửa spec chạm tới phần của mình. Phase này viết một spec xuyên suốt cho bố cục bàn, kiểm chi nhánh không có bàn vẫn y như cũ, cập nhật tài liệu cho chủ quán và rà soát mã.

## Yêu cầu

1. `apps/pos/e2e/table-service-layout.spec.ts` (API mock như các spec hiện có) phủ: bảng bàn là màn đầu; lọc "Cần xử lý"; mở bàn trống với số khách; gọi món không tùy chọn và có tùy chọn (nút khóa khi thiếu nhóm bắt buộc); "Gửi bếp (n)" về bảng bàn; "Gửi & ở lại"; nhóm theo course và "Gọi món ra"; thanh toán toàn màn và về bảng bàn; tải lại trang ở khung `order` và `pay`.
2. Chạy lại các spec của bố cục cũ để chắc không đổi: `full-retail`, `bar-tabs`, `karaoke`, `fnb-call-number`.
3. Kiểm khả năng truy cập của bố cục mới trong `accessibility.spec.ts` (thêm trang bàn vào danh sách quét nếu spec có danh sách).
4. Cập nhật `docs/pos/fnb-ban-va-tra-sau.md` mục 2: màn bán của chi nhánh có bàn mở trên bảng bàn; màu ô; ngưỡng ngồi lâu đặt ở tab Sơ đồ bàn; luồng gửi bếp và thanh toán mới. Bỏ câu "Quán ăn có bàn vẫn mở thẳng lưới thực đơn" nếu câu hỏi mở 1 được trả lời là chuyển sang bảng bàn.
5. Rà soát mã bằng skill code review cho toàn bộ thay đổi của plan trước khi commit cuối.

## File

- Tạo: `apps/pos/e2e/table-service-layout.spec.ts`
- Sửa: `apps/pos/e2e/accessibility.spec.ts` (nếu cần), `docs/pos/fnb-ban-va-tra-sau.md`

## Kiểm tra

```bash
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project desktop
pnpm --dir apps/pos exec playwright test e2e/table-service-layout.spec.ts --project tablet
pnpm --dir apps/pos exec playwright test e2e/full-retail.spec.ts e2e/bar-tabs.spec.ts e2e/karaoke.spec.ts e2e/fnb-call-number.spec.ts e2e/accessibility.spec.ts --project desktop
pnpm --dir apps/pos typecheck && pnpm --dir apps/pos lint && pnpm --dir apps/pos test
```

Không chạy bộ e2e hoặc rspec đầy đủ ở máy; GitHub Actions chạy khi push.

## Rủi ro và rollback

- Spec mới dùng cổng Playwright cố định; nếu cổng bận thì chờ phiên khác chạy xong, không đổi cổng.
- Rollback: tài liệu và spec revert cùng commit của phase.
