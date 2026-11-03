# Kiểm tra plan POS

## Context và kết quả

Cập nhật reconciliation ngày **03/11/2026**. Đây là kiểm tra **tài liệu kế hoạch**, không phải chứng nhận app hoạt động. Người dùng đã chọn **Áp dụng hết (Recommended)** cho correction review; việc duyệt này không cho phép code, eject, migrate, deploy hoặc giao dịch thật. Tất cả 11 phase vẫn `pending`.

- Bốn lens review đã trả kết quả. Security không báo High/Critical mới trong vòng review đó; các lens còn lại có 9 High observations, gộp một observation trùng thành **8 correction riêng biệt** bên dưới.
- Cả 8 correction đã được đưa vào canonical specs, phase work packages, API contracts và acceptance cases. Đây là disposition ở mức tài liệu, **chưa phải implementation fix đã pass runtime** hoặc vòng reviewer thứ hai chứng nhận app.
- CLI strict validation đã chạy sau correction: **0 errors, 0 warnings**, nhận đủ 11 phases. `ck plan status`: **0 completed / 0 in progress / 11 pending**.

## Workflow và phạm vi

- Scan ban đầu `plans/` chỉ có report VietQR, không có unfinished implementation plan khác cần dependency hai chiều. Report VietQR là tham khảo, không blocker đã duyệt.
- Scaffold bằng `ck plan create`; index và mọi generated phase stub đã đọc trước soạn. Không đổi phase status bằng tay.
- CLI active-plan helper từng cảnh báo `CK_SESSION_ID not set`; không khẳng định active metadata persist. Dùng đường dẫn plan cụ thể khi handoff.
- TaskCreate/TodoWrite không có trong catalog phiên; persistent phase checklists là source of truth, không giả đã hydrate session tasks.
- CodeGraph không được expose khi khảo sát; source observations có paths/line references và giới hạn tĩnh. Không chạy init/index hoặc dùng source tĩnh để claim runtime compatibility.
- Research UI/financial và bốn lens review là docs-only. Không sửa app code, upstream Spree, root package/config, `.gitignore` hoặc các thay đổi có sẵn của người dùng.
- `plans/` hiện bị `.gitignore` ignore; tài liệu vẫn lưu local, không tự force-add/commit/push. Nhật ký tại `docs/journal/261101-retail-pos-planning.md`.

## Validation interview và approval

1. Retail đầy đủ, không F&B.
2. Cash + transfer + external card + split + debt.
3. Nhiều branch, mỗi branch nhiều register; không hardcoded business quota.
4. Weighted/unit conversion + serial/IMEI + lot/expiry bắt buộc full release.
5. Mỗi register một drawer.
6. Credit policy do manager cấu hình.
7. Người dùng duyệt **áp dụng toàn bộ correction** sau review; các yêu cầu tiếp tục là hoàn thiện plan, không chuyển thành implementation authorization.

Ngưỡng/thiết bị cụ thể còn là configuration/design gates, không coi là đã được duyệt. Chưa có POS app, prototype HTML hoặc runtime spike tests trong phiên lập plan.

## Review disposition — đã áp dụng vào tài liệu

Evidence source tĩnh ở [architecture §13](../specs/product-and-architecture.md); contract và case IDs ở [API/test matrix](../specs/api-contract-and-test-matrix.md). Các reference tới bản draft bên dưới ghi nguyên nhân phát hiện, không mô tả trạng thái hiện tại còn lỗi.

| ID | Finding / evidence | Correction đã áp dụng | Owner và acceptance |
|---|---|---|---|
| FIN1 | Draft có unapplied excess/late receipt nhưng thiếu lối giải quyết liability độc lập goods return | Inbox + explicit allocation hoặc LiabilityPayout, beneficiary/permission/approval, durable reservation/unknown/confirmed + evidence; chưa allocated không fake Return/core Refund | Architecture §8, API và UX; phases 1/6/8/11; F19 |
| FIN2 | Chỉ cap theo child Payment/active allocation cho phép tiền đã refund sống lại sau reverse/reallocate collection | Parent ReceivedFunds buckets disjoint, shared lock/cap; child Refund và liability payout cùng consume parent; reverse chỉ phần unconsumed, giữ reserved/unknown | Architecture §8, API; phases 1/6/7/8/11; F20 + F19 |
| FIN3 | Draft late-cash correction mặc định current drawer dù tiền đã vào S2 opening/safe; double-count physical custody | Tách financial receipt/received-at/booked-at với physical movement; link S1 closed variance và custody/opening/transfer evidence; fixture S2 expected100k không thành200k | Architecture §10, UX/API; phases 1/6/9/11; F16 |
| INV1 | `orders/upsert_items.rb:10–12` kế thừa variant-keyed lookup/update ở `carts/upsert_items.rb:220–224,302–319`, không bảo toàn hai measured packages cùng variant khác cân/giá/lô | Immutable SaleLine ID/merge key, core line-ID-aware seam hoặc typed sublines mapping lossless; edit/remove/return độc lập; phase 1 proof/ADR blocker | Architecture §14, API/UX; phases 1/5/8/11; I08 |
| INV2 | `line_item.rb:258–266` round proportional return từng lần; cap tổng không tránh under-credit khi chia nhiều lượt | Cumulative entitlement và component/residual policy chung credit-note/refund/discount/tax; ordered reservations/cancel revalidation; 5×0.4 VND trả1+1+3 cấp đủ2 VND | Architecture §9, API/UX; phases 1/8/11; F21 |
| UX1 | Phase drafts chưa propagate đủ mandatory advanced-goods scope từ architecture | Qualification + unit/measured/serial-lot work packages, all-inventory-writer guards, input/traceability/bán-trả tests; tracked tender fail-closed trước capability, actual tiền tự về vẫn vào liability | Phases 1/5/6/8/11; I01–I08; không bỏ hàng cân/serial/lô khỏi full release |
| UX2 | Draft phase 6 có wording cash pilot sớm trái sandbox-only roadmap | Phase 6–7 chỉ sandbox; mọi pilot thật cần authorization riêng, qualified SKUs và applicable phase 11 refund/close/security/reconciliation gates | Plan, architecture, release roadmap, phases 6/11 |
| UX3 | Server revoke/generation không xóa QR đang render trên display mất kết nối | Bounded local freshness deadline + monotonic expiry, stale/cache không renew, hide khi offline/expired/resume rồi revalidate; cashier freshness/current-generation ACK, disconnect-before-clear/cancel/settlement/rebind tests | Architecture §11, UX/API, phases 10/11; W09 + F05; QR đã chụp vẫn có late-money recovery |

## Whole-plan consistency sweep

- Đã đọc lại `plan.md` và **toàn bộ phase 01–11**, cùng bốn canonical specs; đối chiếu research log và decision deltas đã duyệt.
- Decision deltas chính kiểm tra: **8** correction trong bảng. Đồng bộ requirements/architecture/file ownership/steps/success criteria/risks và release gates, không chỉ sửa một phase.
- Dọn references cũ: current-drawer late cash, variant-only line identity, per-return-only rounding, thiếu liability resolution/parent consumption, display chỉ token expiry, pilot wording, acceptance ranges và review còn pending.
- Các clarification cùng scope: fractional **unit price** khác fractional total/receipt/payout VND; ví dụ kg/g tách canonical decimal string với dấu thập phân locale; PayoutEvidence có một phase tạo rồi các phase sau reuse; phase 1 được phép viết spikes sau authorization, proofs là gates của capability phụ thuộc.
- **Unresolved document contradictions: 0** trong sweep này. Không có nghĩa runtime/thiết bị/policy đã được chứng minh hoặc chốt.

## Kiểm tra cơ học

- `ck plan validate plans/261101-1649-retail-pos-multi-store-multi-order/plan.md --strict`: valid, **0 errors / 0 warnings / 11 phases**.
- `ck plan status plans/261101-1649-retail-pos-multi-store-multi-order/plan.md`: **11 pending**, 0% implementation.
- Link/frontmatter/dependency/acceptance/file-owner check cuối: **18 Markdown docs, 57 local links, 11 phase schemas/dependencies, 44 unique acceptance cases, 307 proposed Create paths có owner phase duy nhất; 0 errors**. Một Create/Reuse ambiguity của PayoutEvidence đã tách rõ owner phase 6, reuse phase 8. Check này xác nhận inventory tài liệu, không khẳng định các proposed code paths đã được tạo.
- `git check-ignore -v .../plan.md` xác nhận `.gitignore:8:plans`; không sửa ignore hoặc stage/commit. Git status không có thay đổi application/config mới do phần reconciliation này.
- 44 acceptance cases **A01–A06 / W01–W09 / F01–F21 / I01–I08** là yêu cầu kiểm thử, không phải 44 tests đã thực thi. CLI validation chỉ kiểm tài liệu, không chạy Spree hoặc app POS.

## Unresolved runtime/configuration gates

- Phase 1: runtime source/image/mount, SDK auth, walk-in/pickup, discounts persistence, partial PaymentSessions/credit placement và strict branch routing chưa spike.
- Exact quantity/base-unit price/schema/overflow, distinct measured-line mapping, cumulative entitlement và Return/Refund seam credit-sale chưa được chứng minh trên installed Spree; cần ADR/re-estimate nếu không đáp ứng.
- Parent-funds conservation/reallocation/liability payout và late-cash custody là contracts cần integration/concurrency tests thật; chưa là code chạy được.
- Traceability phải cover receiving/transfers/adjustments/web/admin/import/returns, không chỉ POS; opening balances/provenance cần đối soát trước enable.
- Chưa chốt precision/scale barcode profiles, printer/scanner/display models/freshness deadline, credit limit/due date/overdue và discount/refund/variance/return-window/cross-branch thresholds. Manager-configured credit và one-drawer/register đã xác nhận, giá trị cấu hình chưa chốt.

## Next steps

Bàn giao plan đã reconcile để người dùng review. Chỉ bắt đầu phase 1 sau authorization triển khai riêng; nếu cần eject phải xin phép trước. Không tự chạy cook, install, migrate, deploy, giao dịch thật hoặc coi approval correction là quyền triển khai.

**Handoff:** người dùng chọn **Dừng tại plan (Recommended)**; kết thúc ở tài liệu, không bắt đầu phase 1.
