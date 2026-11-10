---
title: Thiet bi ghep ma va PIN
date: 2026-11-10
summary: "Ghep thiet bi va PIN nam o dashboard, khong o app ban hang"
---

# Thiet bi ghep ma va PIN

Phase 2 thêm thiết bị ghép mã và PIN nhân viên. Trang quản lý nằm ở pos-dashboard (Cấu hình → Thiết bị), không thêm màn setting vào app bán hàng.

Mã 8 ký tự, QR chứa url và code, token chỉ lưu digest, thu hồi có hiệu lực ngay. PIN 4-6 số do nhân viên tự đặt; quản lý chỉ reset. Sai 5 lần thì khóa 15 phút trên đúng máy. Request thiết bị kèm session nhân viên đi qua quyền hiện có. Máy bếp không có session gọi workspaces thì 403.

Spec thiết bị 8 example xanh. Năm example request bị bẩn dữ liệu test rồi xanh lại sau khi nạp lại schema. e2e web chưa chạy lại.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
