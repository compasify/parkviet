---
phase: 4
title: "Nhiều đơn đồng thời và điều phối revision"
status: completed
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

- [ ] W01, W02: nhiều tab/overflow/reload giữ source context, không chuyển focus; payment end-to-end hoàn thiện phase 6. *(Backend đã phân trang 20 editing + 200 parked trên DB thật (`workspaces_spec.rb`); reload/overflow/lease mới chạy với API mock (`layout-recovery`, `context-defaults`, `lease*.spec.ts`). Mở 20 view trên trình duyệt với persistence thật chuyển phase 11; payment end-to-end thuộc phase 6.)*
- [x] W03, W04: queue/replay không mất intent, một lease generation, stale writes bị từ chối. *(`workspace_race_spec.rb`: hai connection PostgreSQL tranh lease chỉ một thắng, generation tăng đúng 1; cùng key tạo draft đồng thời chỉ ra một draft/receipt. `workspace_access_spec.rb`: sau takeover, ghi cũ trả 409 `lease_stale`. Scan/catalog end-to-end thuộc phase 5/6.)*
- [x] W05: close/park/cancel/logout khác nhau, unsaved cảnh báo, server draft không bị xóa ngoài ý muốn. *(`workspace_access_spec.rb`: park/reopen/cancel giữ order và audit, logout không xóa draft, cancel bị chặn khi còn tiền; e2e `context-defaults.spec.ts` giữ cảnh báo intent chưa rõ qua reload.)*
- [x] A02, A04: context/cache/callback không vượt store/branch; direct IDs vẫn authorize. *(`workspace_access_spec.rb`: membership bị gỡ thì list/detail/lease đều ẩn, receipt lookup 404 (`workspaces_spec.rb`); takeover chỉ thấy draft ở chi nhánh được cấp.)*
- [x] F04 nền tảng: replay sau commit trả cùng result trước revision conflict; financial test hoàn thiện phase 6. *(`workspace_access_spec.rb`: retry cùng key sau takeover vẫn trả kết quả đã commit; `workspace_commands_spec.rb`.)*

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

## Đóng phase 06/11/2026

Người dùng yêu cầu chuyển sang phase 4 theo cách đã làm ở phase 3: review code, sửa lỗi, bổ sung test rồi đóng.

**Lỗi đã sửa:**

- Sau khi bị takeover, mọi mutation của editor cũ trả 403 thay vì 409, vì `lease_holder_id` được kiểm ở bước authorize. Hệ quả: retry cùng key của lệnh đã commit (mất response) cũng bị 403, không lấy lại được kết quả. Nay lease chỉ được kiểm trong khóa mutation và trả 409 `lease_stale`; replay lệnh đã commit vẫn trả kết quả cũ. Áp cho mọi workflow workspace, tender, funds và heartbeat lease.
- Hủy draft không kiểm tiền: draft có tender `prepared`/`confirmed`/`unknown`, received funds hoặc allocation vẫn hủy được, làm tiền mất chỗ đối soát. Nay trả 409 `payments_recorded`; UI khóa nút hủy và giải thích lý do.
- Nhân viên bị gỡ hoặc vô hiệu membership vẫn xem được danh sách và chi tiết draft cũ (khách hàng, giỏ hàng) qua shift/lease của mình. Nay chỉ xem được khi còn membership bán hàng hoặc takeover tại chi nhánh đó.
- `CommandExecutor` coi mọi `RecordNotUnique` là trùng idempotency key, che lỗi thật của lệnh bằng thông báo sai. Nay chỉ xử lý như replay khi tìm thấy receipt cùng key, còn lại raise lỗi gốc.
- UI: 409 `lease_stale` từ mutation không chuyển trang sang chỉ xem, nên người dùng bấm tiếp vẫn bị từ chối. Nay trang bỏ quyền sửa và tải lại. Tab nền để lease hết hạn, khi quay lại bị báo mất quyền dù không ai nhận; nay heartbeat gặp `lease_stale` thì tự claim lại một lần và chỉ báo chỉ xem khi người khác đang giữ.
- Danh sách workspace tải branch/register/shift/order từng dòng (N+1); nay preload.

**Test mới:**

- `server/spec/requests/spree/pos/workspace_access_spec.rb` (5 examples): takeover → 409 `lease_stale` cho note/heartbeat/park, retry cùng key trả kết quả đã commit, quản lý park được và audit đúng actor; membership bị gỡ thì list/detail/lease đều ẩn; takeover chỉ thấy draft ở chi nhánh được cấp; hủy bị chặn khi tender còn tiền, được phép khi tender failed; park/reopen/cancel/logout giữ order.
- `server/spec/integration/spree/pos/workspace_race_spec.rb` (2 examples): hai connection PostgreSQL cùng claim một lease đã hết hạn thì chỉ một thắng, generation tăng đúng 1, một audit; cùng key tạo draft đồng thời chỉ ra một workspace, một receipt, một walk-in order. Chạy ngoài transaction và tự xóa dữ liệu; đã kiểm test DB về lại chỉ còn store mặc định.
- `workspace_commands_spec.rb`: unique violation của chính lệnh không bị đổi thành conflict idempotency.
- `apps/pos/e2e/lease-recovery.spec.ts` (3 test × 3 viewport): lease hết hạn mà không ai nhận thì tự claim lại; lease do người khác giữ thì sau lần ghi bị từ chối trang chuyển sang chỉ xem; draft có thanh toán thì nút hủy bị khóa.

**Kết quả 06/11/2026:** `pnpm spree rspec spec/requests/spree/pos spec/workflows/spree/pos spec/integration/spree/pos` 170 examples, 0 failures; sau khi chỉnh rubocop, chạy lại các spec mới: 11 examples, 0 failures. Rubocop sạch trên spec mới; offense còn lại trong các file app đã sửa là có từ trước. `apps/pos`: lint, typecheck, 43 unit pass; Playwright 102 passed / 6 skipped (live API opt-in).

**Còn lại (phase 11):** mở 20 view/overflow/reload trong trình duyệt trên API và persistence thật; điều tra timeout không ổn định khi reload/phục hồi phiên trên API thật (chưa tái hiện trong phiên này). Handover vẫn khóa theo gate phase 6/8.
