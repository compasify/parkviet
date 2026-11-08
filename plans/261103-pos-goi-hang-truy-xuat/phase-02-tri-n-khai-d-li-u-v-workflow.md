---
phase: 2
title: "Triển khai dữ liệu và workflow"
status: completed
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

- [x] Hai gói cùng variant khác giá/lô tồn tại độc lập qua edit/remove/checkout/return. *(`package_split_spec.rb` khác giá; `traceable_inventory_spec.rb` khác lô/cân; `sale_lines_spec.rb` draft.)*
- [x] Không mất tiền, không trùng phân bổ/refund hoặc làm sai stock khi retry/race. *(`return_entitlement_spec.rb`, `return_race_spec.rb`, `fulfillment_returns_spec.rb` retry complete/handover/receive.)*
