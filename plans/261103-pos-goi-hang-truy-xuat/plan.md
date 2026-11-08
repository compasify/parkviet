---
title: "POS: tách từng gói và hàng truy xuất nâng cao"
description: "Plan riêng cho định danh, bán và trả từng gói cùng variant với giá hoặc lô khác nhau."
status: in-progress
priority: P1
branch: "v2"
tags: []
blockedBy: []
blocks: []
created: "2026-11-03T15:51:37.288Z"
createdBy: "ck:plan"
source: skill
---

# POS: tách từng gói và hàng truy xuất nâng cao

## Overview

Plan này xử lý riêng yêu cầu tách từng gói sau khi có POS chạy được trên hành vi chuẩn Spree, theo quyết định người dùng ngày 03/11/2026. Không chặn milestone POS cơ bản. Không ngụ ý các tính năng hàng cân, serial, lô hoặc hạn dùng khác đã được triển khai hay tự động chuyển ra khỏi scope.

Spike tại [runtime spike results](../261101-1649-retail-pos-multi-store-multi-order/reports/runtime-spike-results.md): core `Spree::Carts::AddItem` gộp cùng variant vào một line; giá và metadata lô lần thêm sau ghi đè lần trước (`spec/integration/spree/pos/sale_line_identity_contract_spec.rb`). POS không dùng đường đó.

## Trạng thái (08/11/2026)

Seam và dữ liệu đã được làm trong plan POS chính (phase 5 SaleLine, phase 8 trả hàng + truy xuất). Kiểm tra lại cho plan này:

- `Spree::Pos::SaleLine` map 1:1 với một core line item; POS không gọi variant-upsert. Chỉ gộp khi client gửi `merge: true` **và** merge key trùng (variant, giá, đơn vị, lô, hạn, serial). Hàng cân/serial không bao giờ gộp. ADR: [adr-saleline-seam.md](reports/adr-saleline-seam.md).
- Sửa/xóa/giảm giá/override giá theo `sale_line_id`; trả hàng và hoàn tiền giữ theo SaleLine (entitlement lũy kế, residual, chống cấp kép khi race/hủy).
- UI POS: form thêm hàng mặc định **không gộp** (có ô "gộp" tường minh), chọn lô khi chi nhánh cho phép, override giá từng dòng.
- Bổ sung 08/11: `spec/workflows/spree/pos/package_split_spec.rb` — hàng thường cùng mã, ba gói khác giá đi qua thanh toán → giao → trả một phần; trả gói rẻ được đúng 2 × 80 000, không ảnh hưởng gói còn lại; sửa/xóa một gói không đổi giá gói kia.

Bằng chứng: 8 file spec I08/F21 (`package_split`, `sale_lines`, `sale_guards`, `traceable_inventory`, `return_entitlement`, `fulfillment_returns`, `return_race`, `sale_line_identity_contract`) — **61 examples, 0 failures**.

Còn lại (phase 3, do người dùng): UAT với hàng mẫu tại cửa hàng và quyết định phát hành. Phạm vi: chỉ đơn bán qua POS (có SaleLine, migration `20261105100000`); đơn web/admin vẫn theo hành vi gộp variant của core Spree.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Đánh giá seam và định danh](./phase-01-nh-gi-seam-v-nh-danh.md) | Completed |
| 2 | [Triển khai dữ liệu và workflow](./phase-02-tri-n-khai-d-li-u-v-workflow.md) | Completed |
| 3 | [Kiểm thử đối soát và phát hành](./phase-03-ki-m-th-i-so-t-v-ph-t-h-nh.md) | In progress (chờ UAT) |

## Dependencies

Phụ thuộc POS cơ bản tại [plan chính](../261101-1649-retail-pos-multi-store-multi-order/plan.md); chỉ là dependency cho capability tách gói, không chặn POS cơ bản. Tách gói là gate riêng cho release tuyên bố hỗ trợ capability đó; an toàn tiền/tồn kho, bảo mật và phê duyệt pilot vẫn không được bỏ qua.
