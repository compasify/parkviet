---
phase: 8
title: "Deploy và tài liệu"
status: pending
priority: P2
effort: "0.5d"
dependencies: [7]
---

# Phase 8: Deploy và tài liệu

## Goal
`apps/pos-dashboard` build và chạy ở port riêng, giống `apps/pos`. Tài liệu ghi đủ cách chạy, biến môi trường và những gì hạ tầng phải làm khi gắn domain. Code không chứa domain nào.

## Files to Create / Modify
- Modify: `apps/pos-dashboard/README.md` (build, port `5176`, các biến môi trường `VITE_SPREE_API_URL` và `VITE_BASE_PATH`, những việc hạ tầng cần làm)
- Modify: `apps/pos/README.md` (trang cài đặt đã chuyển sang pos-dashboard; thêm biến `VITE_POS_DASHBOARD_URL`)
- Modify: `AGENTS.md` ở gốc repo (thêm `apps/pos-dashboard/` và `packages/pos-shared/` vào bảng Project Structure)

## Tasks & Steps
1. Bản build chạy được theo cùng cách `apps/pos` đang chạy để deploy (port riêng). Gắn domain là việc của hạ tầng.
2. Ghi vào README những việc hạ tầng phải làm khi gắn domain:
   - Thêm origin đó vào Allowed Origins của cửa hàng. Nếu không, refresh và logout sẽ bị `StaffSessionOriginGuard` chặn (`server/config/initializers/staff_session_origin.rb`).
   - Đặt `VITE_POS_DASHBOARD_URL` cho bản build của POS.
3. Ghi vào README cách kiểm tra sau khi deploy.

## Verification
- Chạy bản build ở port `5176` trỏ vào API dev: đăng nhập được, reload không bị đăng xuất, đăng xuất được, link từ POS mở đúng trang.
- Kiểm tra các link trong tài liệu trỏ đúng file.

## Risk / Rollback
Chỉ đổi tài liệu. Nếu deploy lỗi thì POS vẫn bán bình thường; chỉ phần cài đặt tạm thời không vào được.
