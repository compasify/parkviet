---
phase: 1
title: "Đánh giá seam và định danh"
status: pending
effort: ""
---

# Phase 1: Đánh giá seam và định danh

## Overview

Chọn seam ít thay đổi backend nhất để biểu diễn từng gói độc lập và giữ mapping sang line/cart/order của phiên bản Spree thực chạy.

## Implementation Steps

1. Tái chạy spike same-variant, xác minh finder, workflow và khả năng mở rộng không fork.
2. Đánh giá line độc lập, subline có identity và giải pháp native; so sánh ảnh hưởng giá, tồn, API, migration và website.
3. Ghi ADR, đường nâng cấp dữ liệu và giới hạn SKU chưa hỗ trợ; xác định chính sách số thập phân/làm tròn và provenance.

## Success Criteria

- [ ] Có ADR được duyệt và mapping không mất identity qua cart → order → return.
- [ ] Không âm thầm gộp gói khác giá/lô hoặc bật tính năng khi chưa đủ dữ liệu.
