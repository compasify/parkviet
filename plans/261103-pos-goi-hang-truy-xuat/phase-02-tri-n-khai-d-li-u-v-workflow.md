---
phase: 2
title: "Triển khai dữ liệu và workflow"
status: pending
effort: ""
---

# Phase 2: Triển khai dữ liệu và workflow

## Overview

Triển khai seam được duyệt với thay đổi BE nhỏ nhất, bảo toàn identity, giá và provenance trên toàn bộ vòng đời.

## Implementation Steps

1. Tạo dữ liệu và ràng buộc cần thiết; không sửa upstream Spree.
2. Thực hiện thêm/sửa/xóa độc lập và chuyển dữ liệu cart → order; xử lý đồng thời và retry.
3. Ánh xạ giao hàng/đổi trả/refund theo gói gốc, ghi residual tích lũy đúng; bảo vệ các writer khác.
4. Chỉ bật UI sau khi API và kiểm soát truy cập được test; dữ liệu cũ không có identity phải được xử lý minh bạch.

## Success Criteria

- [ ] Hai gói cùng variant khác giá/lô tồn tại độc lập qua edit/remove/checkout/return.
- [ ] Không mất tiền, không trùng phân bổ/refund hoặc làm sai stock khi retry/race.
