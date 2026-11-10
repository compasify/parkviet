---
title: "Nen don hang F&B phase 1"
date: 2026-11-10
summary: "ADR, ngay kinh doanh, service mode, thue VAT va OpenAPI POS"
---

# Nen don hang F&B phase 1

Phase 1 đặt nền F&B vào lõi POS: ADR 0001, service_mode, business_date theo cutoff 04:00, sáu sale line kind, lịch thuế VAT vì Spree 6 không có starts_at/expires_at, và OpenAPI pos-staff.

Bằng chứng: rspec request POS 290 example (sửa 1 expectation sales_channel có sẵn), integration 108, workflow 156, spec mới của business day / kinds / thuế / service mode đều xanh. Vitest và typecheck của pos, pos-shared, pos-dashboard xanh. Dashboard đã mở form chi nhánh và từ chối giờ chốt 25:99.

Chưa xanh: Playwright apps/pos 19 test. Các lỗi nhìn thấy là nút nguồn đơn nhỏ hơn ngưỡng, thiếu .header ở login, hai nút Mở lại đơn, và timeout 30s. Không thuộc hành vi phase này. Ô tiêu chí e2e để mở.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
