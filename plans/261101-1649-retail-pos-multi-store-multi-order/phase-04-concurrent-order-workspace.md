---
phase: 4
title: "Nhiều đơn đồng thời và điều phối revision"
status: in-progress
priority: P1
dependencies: [2, 3]
effort: "Ước tính 8–12 person-days"
---

# Phase 4: Nhiều đơn đồng thời và điều phối revision

## Overview

Xây workspace thật gắn draft Order, revision/lease và command receipt bền vững để nhiều đơn không ghi nhầm nhau.
Tham chiếu [kiến trúc §7](./specs/product-and-architecture.md), [UX §4](./specs/ux-and-workflows.md), [API/tests W01–W05](./specs/api-contract-and-test-matrix.md).

## Requirements

- `+ Đơn mới`, đọc/giữ/mở lại/đóng view/hủy có quyền; một workspace đúng một draft, source context bất biến.
- Không hardcode số tab; overflow/search, phân trang parked drafts và chỉ mount active line grid.
- Mỗi mutation gửi workspace ID, expected revision, lease generation và idempotency key.
- Một editor lease; máy khác read-only/takeover có quyền/audit, không silent last-write-wins.
- Reload/server recovery trước edit; persistence browser chỉ IDs/layout/unsent intentions có TTL/scope.
- Pending receipt về nền chỉ badge/toast mã đơn, không đổi active tab/focus/display.

## Architecture

- Workspace có FK store/branch/register/shift/order, operational status riêng, revision và lease expiry/generation.
- CommandReceipt có durable unique scoped key + digest/result; replay kiểm trước stale revision để trả lại commit cũ.
- Command executor authorize → lookup replay → lock/recheck context/lease/revision → workflow → revision/result atomic.
- Server là authority; BroadcastChannel chỉ lease hints/invalidation, không thay DB lock hay cập nhật tiền local.
- Query keys/callbacks bound immutable workspace ID; queue commands theo workspace, tab khác vẫn tương tác được.
- Handover khác quầy/ca cấm nếu receipt đã thu hoặc external attempt unresolved; kiểm server khi phase 6 thêm tender.
- Poll summary có cursor/backoff và active pending set; không mỗi parked tab một poller.

## Related Code Files

Inventory repo-root; migration timestamps do generator cấp sau approval triển khai.
- Create: `server/app/models/spree/pos/workspace.rb`, `server/app/models/spree/pos/command_receipt.rb`.
- Create: `server/db/migrate/TIMESTAMP_create_spree_pos_workspaces.rb` — FKs, revision/lease và durable command index.
- Create: `server/app/services/spree/pos/command_executor.rb`, `server/app/services/spree/pos/workspace_summary.rb`.
- Create: `server/app/workflows/spree/pos/workspaces/create.rb`, `server/app/workflows/spree/pos/workspaces/change_status.rb`.
- Create: `server/app/workflows/spree/pos/workspaces/claim_lease.rb`, `server/app/workflows/spree/pos/workspaces/handover.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/workspaces_controller.rb`, `server/app/controllers/spree/api/v3/admin/pos/workspaces/leases_controller.rb`.
- Create: `server/app/controllers/spree/api/v3/admin/pos/workspaces/handovers_controller.rb`.
- Create: `apps/pos/src/components/workspace-tabs.tsx`, `apps/pos/src/hooks/use-workspaces.ts`, `apps/pos/src/lib/command-queue.ts`.
- Create: `apps/pos/src/lib/workspace-channel.ts`, `apps/pos/src/lib/workspace-storage.ts`, `apps/pos/src/lib/command-queue.test.ts`.
- Create: `server/spec/workflows/spree/pos/workspace_commands_spec.rb`, `server/spec/requests/spree/pos/workspaces_spec.rb`, `apps/pos/e2e/workspaces.spec.ts`.
- Modify: server routes, POS sale/shell/query keys/locales và access policy của các phase trước.

## Implementation Steps

1. Viết tests-first create/replay cùng key, khác digest, commit rồi timeout, stale revision và takeover hai connections.
2. Tạo schema workspace/command receipt, unique order mapping và scoped key; retention financial-ready, không TTL vài phút.
3. Cài command executor và envelope conflict có code/current revision; không leak private draft khi unauthorized.
4. Cài create draft idempotent với branch/channel server-derived; park/cancel phân biệt close view, ghi audit.
5. Cài lease claim/heartbeat/takeover; stale editor hết hạn trả 409 dù UI còn cho edit.
6. Dựng tabs/overflow/parked list và per-tab search/scroll/panel; bind mọi callbacks theo workspace ID.
7. Cài queue và same-key retry/status lookup; request đảo thứ tự không áp vào tab mới, không global Enter confirm.
8. Cài reload từ server + cảnh báo unsent; logout purge local state/lease hints nhưng không xóa server drafts.
9. Cài handover chỉ draft chưa có tiền/unresolved attempt; tạm capability tắt nếu chưa có đủ checks từ phase 6.
10. Chạy multi-browser lease/refresh/reload và 20 live/200 parked scenarios; không dùng mocks để thay persistence gate.
11. Gate: `pnpm spree rspec spec/workflows/spree/pos/workspace_commands_spec.rb spec/requests/spree/pos/workspaces_spec.rb` và app unit/e2e.

## Success Criteria

- [ ] W01, W02: nhiều tab/overflow/reload giữ source context, không chuyển focus; payment end-to-end hoàn thiện phase 6.
- [ ] W03, W04: queue/replay không mất intent, một lease generation, stale writes bị từ chối.
- [ ] W05: close/park/cancel/logout khác nhau, unsaved cảnh báo, server draft không bị xóa ngoài ý muốn.
- [ ] A02, A04: context/cache/callback không vượt store/branch; direct IDs vẫn authorize.
- [ ] F04 nền tảng: replay sau commit trả cùng result trước revision conflict; financial test hoàn thiện phase 6.

## Risk Assessment

- Lease tách khỏi lock gây race: recheck generation trong transaction mutation; dùng DB time cho expiry.
- Browser persistence bị hiểu là ledger/offline: không lưu token/evidence, không offline-finalize.
- Infinite tabs gây tải: virtualized/active grid, pagination và profile đo; không bảo đảm capacity vô hạn.

## Next Steps

Phase 5 thêm catalog/customer/discount qua executor; phase 6 dùng lại chính durable receipt và khóa mutation này.

## Checkpoint 04/11/2026

- **In progress.** Workspace/draft, revision, editor lease, idempotency/receipt, park/reopen/cancel và phục hồi một phần layout đã triển khai. Có test API thật lost response/reload, stale editor/takeover và probe hai connection tranh lease.
- Backend đã kiểm 20 editing + 200 parked qua API/database thật; chưa chứng minh 20 view overflow/reload trong browser hoặc bảo toàn khách/lines/discount chưa được triển khai. Các phần W01/W03 về catalog/scan/payment thuộc phase sau.
- Cần hoàn tất W05, A02/A04, xử lý reload API thật timeout không ổn định, phục hồi tất cả view/permission bị thu hồi và tổng hợp bằng chứng criteria; xem [bàn giao phase 1–4](./reports/phase-01-04-handoff.md).
