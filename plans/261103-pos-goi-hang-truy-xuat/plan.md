---
title: "POS: tách từng gói và hàng truy xuất nâng cao"
description: "Plan riêng cho định danh, bán và trả từng gói cùng variant với giá hoặc lô khác nhau."
status: pending
priority: P1
branch: "main"
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

Spike tại [runtime spike results](../261101-1649-retail-pos-multi-store-multi-order/reports/runtime-spike-results.md): cùng variant được gộp vào một line; giá và metadata lô lần thêm sau ghi đè lần trước. Vì vậy không được dùng POS cơ bản để bán các gói cùng variant cần phân biệt giá/lô, hoặc tuyên bố hỗ trợ traceability theo gói.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Đánh giá seam và định danh](./phase-01-nh-gi-seam-v-nh-danh.md) | Pending |
| 2 | [Triển khai dữ liệu và workflow](./phase-02-tri-n-khai-d-li-u-v-workflow.md) | Pending |
| 3 | [Kiểm thử đối soát và phát hành](./phase-03-ki-m-th-i-so-t-v-ph-t-h-nh.md) | Pending |

## Dependencies

Phụ thuộc POS cơ bản tại [plan chính](../261101-1649-retail-pos-multi-store-multi-order/plan.md); chỉ là dependency cho capability tách gói, không chặn POS cơ bản. Tách gói là gate riêng cho release tuyên bố hỗ trợ capability đó; an toàn tiền/tồn kho, bảo mật và phê duyệt pilot vẫn không được bỏ qua.
