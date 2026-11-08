---
phase: 3
title: "Kiểm thử đối soát và phát hành"
status: in-progress
effort: ""
---

# Phase 3: Kiểm thử đối soát và phát hành

## Overview

Kiểm chứng end-to-end, đối soát và phát hành có kiểm soát capability tách gói.

## Implementation Steps

1. Kiểm tra số lượng, giá, thuế, giảm giá, residual trả nhiều lần và các ca đồng thời.
2. Kiểm tra provenance, POS/web/admin/import/transfer, phân quyền và phục hồi sau lỗi.
3. Chạy UAT với hàng mẫu, đánh giá migration/rollback không xóa financial facts và xin phê duyệt phát hành.

## Success Criteria

- [x] Acceptance I08/F21 tương ứng và regression tài chính/tồn kho pass với bằng chứng. *(08/11/2026: 8 file spec, 61 examples, 0 failures.)*
- [ ] Có đối soát, runbook và quyết định release riêng trước khi bật. *(Chờ UAT hàng mẫu tại cửa hàng và quyết định của người dùng.)*
