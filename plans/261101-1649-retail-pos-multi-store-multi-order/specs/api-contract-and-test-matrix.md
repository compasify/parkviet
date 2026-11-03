# API POS và ma trận kiểm thử

## 1. Contract status

Toàn bộ `/api/v3/admin/pos/*` bên dưới là **NEW đề xuất**, không phải endpoint sẵn có. Phase 1 chốt schema, HTTP semantics, permission subjects và Spree seams bằng integration spikes. Reuse admin authentication nhưng không grant blanket core writes. Server-only wrappers gọi core workflows, không browser tự chain các endpoint tài chính không có saga.

## 2. Nhóm API và quyền

| Resource đề xuất | Chức năng | Bất biến |
|---|---|---|
| `GET /pos/context` | Staff, permitted branches/registers, active shift, capabilities, currency/timezone | Chỉ scope được cấp, không xuất secret/internal full role data |
| `/pos/branches`, `/pos/registers`, `/pos/memberships` | Manager CRUD/config/disable; paginated | Same-store incidental IDs; không hard-delete lịch sử |
| `/pos/shifts`, `/shifts/:id/closure`, `/shifts/:id/cash_movements` | Mở/đóng ca và thu/chi | Unique active drawer, close barrier, immutable posted entries |
| `/pos/workspaces` | List/create/read/park/cancel draft wrapper | Typed context, belongs one Order, prefilled branch/channel from server |
| `/workspaces/:id/lease`, `/workspaces/:id/handover` | Claim/heartbeat/takeover/transfer | Lease generation, approval, preserve source context; no money/unresolved attempts on handover |
| `/workspaces/:id/items`, `/items/:sale_line_id`, `/customer`, `/discounts`, `/notes` | Domain mutations, serialized | Immutable SaleLine ID, explicit merge rules, revision/lease/key, no variant-keyed overwrite hoặc metadata price bypass |
| `GET /pos/catalog`, `/catalog/barcodes/:code`, `/customers` | Restricted POS search DTO | Branch assortment/stock, no cost price/other-branch PII; ambiguous barcode not guessed |
| `POST /pos/customers` | Quick create; idempotent | Duplicate warning policy, minimal required fields, no fake email |
| `/workspaces/:id/tender_attempts` | Prepare allocations/intents/status | Snapshot version, amount currency/remaining commitment ceiling, allowed branch method |
| `/tender_attempts/:id/confirmation` | Cash/manual bank/external-card evidence | Staff capability + evidence; atomic receipt allocation/Spree settlement; no `paid: true` |
| `/workspaces/:id/completion` | Guarded complete and recovery state | Confirmed coverage or approved credit; amount snapshot, no unresolved attempt, no raw payment_pending |
| `/pos/credit_accounts`, `/workspaces/:id/credit_approval` | Customer terms/exposure approval | Customer lock, action/revision-bound approval, audit |
| `/pos/receivables`, `/pos/collections`, `/collections/:id/allocations` | Debt list/receive/apply/reverse | One actual receipt, bounded child allocations, no new sale |
| `GET /pos/received_funds`, `GET /received_funds/:id`, `/received_funds/:id/allocations`, `/allocations/:id/reversals` | Inbox tiền thừa/trễ, allocate/reverse có chủ đích | Parent conservation lock; payer/beneficiary/merchant/currency checks; consumed/reserved/unknown không sống lại |
| `/received_funds/:id/liability_payouts`, `/liability_payouts/:id/confirmation`, `/liability_payouts/:id/resolution` | Request/confirm/reconcile hoàn tiền chưa allocated | Separate permission/approval, durable reservation, evidence; no fake return/core Refund; unknown không release bằng timeout |
| `/pos/cash_reconciliations` | Manager xử lý late-cash, variance và custody | Link original closure/current custody; không auto tạo physical movement hoặc sửa snapshot |
| `/pos/orders`, `/orders/:id/handover` | History, timeline, stock handover | Paid-or-credit gate, branch location strict; once-only stock effects |
| `/pos/returns`, `/pos/exchanges`, `/pos/refund_requests` | Return goods/credits/refund evidence | Cumulative SaleLine entitlement/residual + Payment/parent caps incl parallel reservations; no dummy credit |
| `/pos/receipts/:id`, `/pos/display_sessions`, `/display_sessions/:id/acknowledgement` | Snapshot bill và read-only display; generation ACK | No receipt financial writes; display no JWT/PII, local freshness lease + expiry/revoke/generation; ACK không cấp quyền tài chính |
| `/pos/reports/*`, `/pos/exports` | Financial read models/exports | Branch filters server-side, immutable facts, permission/file TTL |
| `/pos/units`, `/pos/unit_conversions`, `/pos/measured_lines` | Units/config và số đo draft | Exact decimal/unit DTO, canonical base units; proof price/tax/discount/return before implementation |
| `/pos/lots`, `/pos/serial_units`, `/workspaces/:id/trace_allocations` | Receive/lookup/reserve/allocate trace identities | Strict branch, FEFO, serial uniqueness, core stock aggregate conservation at every mutation entry |

Action-style path names ở bảng chỉ diễn tả capability. Khi implement dùng nested REST controllers/resources phù hợp Spree conventions (ví dụ POST singular `confirmation`/`completion`), khai báo request params; không thêm RPC/controller chứa hết nghiệp vụ.

## 3. Envelope và concurrency

- Theo envelope `{data, meta}` và error format installed API; prefixed IDs cho public entities, không raw integer IDs hoặc Ruby class names.
- Money canonical decimal strings, ví dụ `"250000"`; percentage và monetary values là hai loại input riêng. Total/receipt/payout VND là nguyên, exact base-unit price có thể `"0.4"` theo proof phase 1; không float hoặc early rounding. Currency/timezone do server context xác định.
- Item DTO có `sale_line_id`, `measurement_event_id` nếu có, sale/base quantity, unit/conversion version và core mapping server-owned. Edit/remove/return theo SaleLine ID; create có explicit merge intent, không variant-only replacement.
- ReceivedFunds DTO tách received_net/available_unapplied/allocated_unconsumed/payout_reserved_or_unknown/paid_out và child links; các bucket disjoint, tổng bằng received_net. Allocation/refund/liability-payout/reversal dùng chung parent lock/retention; receipt list không nhân bản parent amount theo số Payment con.
- Liability payout input gồm amount/currency, beneficiary/receiving method evidence, reason và approval; cash cần physical paying drawer/shift. Confirmation cần evidence + operation identity. Resolution chỉ release khi evidence failed-no-effect; unknown trả `202`/attention và giữ reservation. Allocation reversal chạm refunded/reserved funds phải domain conflict hoặc explicit bounded partial reversal; không im lặng trả full amount về available.
- Cash reconciliation input giữ actual received-at/booked-at, original shift/closure/variance và custody/opening/safe-drop/transfer evidence. Response phân biệt financial posting với physical movement; chỉ actual new drawer effect mới tạo CashMovement source-unique.
- Return preview/commit có original SaleLine, cumulative quantity/value/components, previous posted/reserved entitlement và delta/residual; server tính dưới lock, không tin refund amount do browser cộng riêng. Dependent reservation không post trước predecessor unresolved; cancel rebuild/reapprove unposted dependents hoặc reject nếu làm đổi posted facts. Display snapshot có session/generation/lease sequence và bounded freshness contract; cached/out-of-order responses không extend local deadline, ACK bound đúng generation/lease hiện tại.
- Sensitive mutation gửi `Idempotency-Key`, workspace `expected_revision`, lease generation và action-specific input. Server không nhận branch/approver evidence như assertion đáng tin chỉ vì client gửi.
- Replay same key/same digest trả kết quả cũ kể cả revision đã tăng. Same key/different digest trả conflict. Constraint scope gồm store/actor/command/resource phù hợp; retention đủ cho retry/financial audit, không TTL vài phút rồi thu lặp.
- `409` stale revision/lease/context: response có code và current revision, không raw private data; UI reload/resolve. `422` domain errors gắn field/action; `403/404` unauthorized scope theo policy; `202` in-progress/unknown khi chưa thể trả finalized result.
- Sau receipt verified response có status rõ: `receipt_confirmed`, `order_completion_pending`, `attention` hoặc finalized. Không trả success duy nhất làm client đoán order đã xong.
- Query keys: catalog `[store, branch, assortment, search]`; draft `[store, branch, workspace]`; cash `[store, branch, register, shift]`; report thêm filters/timezone. Context switch abort old requests và không áp response cũ vào tab mới.
- Notifications/status endpoint có cursor/checkpoint và chỉ permitted workspaces; no global list all orders. Payment poll backoff 2–3 giây đề xuất, độ trễ ngân hàng không cam kết.

## 4. Security và topology test matrix

| ID | Scenario | Gate |
|---|---|---|
| A01 | Login, refresh, rotation, expiry, revoke, logout, nhiều browser tabs refresh cùng lúc | No long-lived credential JS; unauthenticated mutations rejected |
| A02 | Cashier ở branch A đoán workspace/customer/stock/payment IDs branch B hoặc Store khác | Server denies; no leaked counts/PII |
| A03 | Cashier gọi trực tiếp core create/update/discount/capture/complete/refund APIs | Không bypass POS hạn mức/evidence/location/credit gate |
| A04 | Đổi branch/register khi requests đang chạy, cache còn data cũ | Không gửi/lộ dữ liệu sai context; source orders giữ nguyên |
| A05 | Manager approval được reuse sau đổi amount/customer/revision hoặc approver bị revoke | Reject; audit giữ action-bound authority |
| A06 | Disable branch/register/staff, active workspaces/shift còn tồn | Khóa new writes theo policy, recovery manager không mất lịch sử |

## 5. Nhiều đơn và UX test matrix

| ID | Scenario | Gate |
|---|---|---|
| W01 | A chờ bank, B cash complete, C đang scan | A giữ nguyên, B thu/giao đúng, C focus không bị cướp |
| W02 | 20 live tabs, overflow, reload; 200 parked drafts paginated | Không mất khách/lines/discount/status; không load mọi grid |
| W03 | Scan 100 lần liên tiếp, mạng trả kết quả đảo thứ tự; network retry same scan | Đủ 100 intent, mỗi intent đúng một lần, đúng tab |
| W04 | Hai browsers/quầy mở cùng order; stale editor/takeover | Một editor generation; stale writes 409, không lost update |
| W05 | Close tab, park, cancel, logout, crash với unsent intents | Không xóa receipts/order; unsaved state có cảnh báo/cách phục hồi |
| W06 | Quick customer create trùng phone, lookup IME, scanner trong input | Không nhân đôi do retry, không scan vào nhầm đơn |
| W07 | %/VND discount, rounding, promotion stacking, draft recalc, line removed | Totals server, approval bounds, bill/return allocation đúng |
| W08 | Desktop/tablet/phone, zoom200%, keyboard-only, screen reader, reduced motion | Nút khách/giảm giá/payment truy cập được, no focus trap/lost CTA |
| W09 | Pin A, disconnect ngay trước clear/cancel/settlement/rebind C; response cũ tới trễ, display sleep/resume | Ẩn QR khi biết offline hoặc hết local deadline, stale response không renew; cashier thấy stale và không show khách kế thiếu current-generation ACK; screenshot QR vẫn phải late-receipt recovery |

## 6. Financial/stock blocking cases

| ID | Scenario | Gate |
|---|---|---|
| F01 | Sale250k/card100k/cash handed200k/change50k, confirm kép | Cash applied150k; one receipt150k; drawer delta150k |
| F02 | Cash200k+bank200k+credit100k trên sale500k | Actual payments400k; debt100k; core không paid; authorized handover |
| F03 | Cash thành công, bank chưa nhận, timeout/reload | Partial receipt bền vững, không auto-paid, không thu lại cash |
| F04 | Concurrent confirmations/replay/worker crash sau receipt trước placement | One receipt/payment; independent placement recovery, no second charge |
| F05 | Bank reference giống nhưng 2 real transfers; late QR sau đổi cash | Distinct money tracked; exception liability/review, không trả đơn kế tiếp |
| F06 | Hai terminals cố collect cùng balance; commitments pending/unknown | Serialized limit; unavoidable excess receipt thành exception, không biến mất |
| F07 | Store capture config đổi, pending session/session mới | Unconfirmed tender/debt không completed; split components không superseded mất |
| F08 | Hai credit approvals concurrent tại hai quầy, cùng customer limit | Exposure atomic không vượt; stale approval invalid |
| F09 | Credit sale1m collect300k rồi200k, collection allocate nhiều orders | Debt500k; không thêm sales/stock; sum allocations <= receipt |
| F10 | Sale1m paid300k debt700k, return400k hoặc toàn bộ | Return400k -> debt300k no refund; full -> debt0 refund entitlement300k |
| F11 | Cash/bank/card manual refunds, payout unknown, concurrent/storecredit refunds | Refund only after verified payout; cap incl reserved amounts, retry no second refund |
| F12 | Last unit POS/POS/web race; branch preferred fallback | Không bán từ chi nhánh khác; stock/backorder policy enforced |
| F13 | Complete retry, handover kép, collection, reprint, return receive retry | Một allocation và một physical depletion; collection/reprint không move stock; restock once |
| F14 | Return hư hỏng/cross-branch/partial exchange có chênh lệch | Only resellable received units restock receiving location; two linked financial legs |
| F15 | Close shift đua cash collection hoặc payout | Serialized cutoff, exact drawer, late entry không rewrite closed ca |
| F16 | Next-day cash collection/refund thực phát sinh; late bank; cash nhận ở S1 nhưng attest sau đóng ca, S2 opening đã gồm tiền hoặc tiền ở safe | Fresh cash effect vào paying/receiving shift; late attest reconcile S1 counted variance/custody không rewrite snapshot hoặc auto cộng S2; S1 overage100k/S2 opening100k vẫn expected100k; overnight dates riêng |
| F17 | Ledger correction, exports, provider fees/settlement | Immutable reversals; CSV-safe; net provider settlement không tạo nợ mới |
| F18 | Free order hoặc discount làm total0; negative/float/fractional total-receipt-payout VND | No zero fake payment; privilege/audit, invalid money inputs rejected; không reject exact fractional base-unit price đã qualify |
| F19 | Bank vượt cam kết hoặc late transfer sau cash/cancel; allocate exception hoặc liability payout, unknown/duplicate confirm, payout đua allocation | One ReceivedFunds; chỉ available được dùng, authenticated owner/beneficiary/approval; reserved/unknown bị giữ; no giả return/Refund cho tiền chưa allocated; actual cash payout once |
| F20 | Collection100k → allocation A100k → refund40k confirmed → reverse/reallocate B; thêm refund reserved/unknown và concurrency | Parent100k = available + allocated unconsumed + reserved/unknown + paid_out; B tối đa60k sau confirmed40k, không hồi sinh tiền refunded; nếu whole reversal không an toàn phải reject/partial có chủ đích; same operation retry không consume kép |
| F21 | 5 units × 0.4 VND = 2 VND, trả 1+1+3; thêm discount/tax, credit note+refund và concurrent/canceled reservations | Cumulative entitlement tổng2 VND, full return hết residual, components/tổng khớp; credit note+refund không vượt entitlement; cap alone không che under-credit |
| I01 | Sale DTO `"1.25" kg` → core1250g (UI1,25kg); conversion kg/g và thùng24/chai, giá fractional base-unit | Chính xác quantity/price/tax/discount/bill; reject nonrepresentable precision, no early round hoặc nhầm dấu thập phân locale |
| I02 | Weighted barcode price/weight/checksum/tare profile và manual correction | Đúng SKU/unit/net và reason, không parse nhầm barcode thường |
| I03 | Hai quầy reserve cùng serial; serial sold/wrong branch/duplicate scan | Một owner duy nhất, không charge khi thiếu serial; retry không bán lặp |
| I04 | FEFO nhiều lô/expiry/quarantine, stock loss, last unit concurrent | Không expired/quarantine, allocations khớp aggregate; no oversell |
| I05 | Return weighted partial/sai serial/sai lot/double return/exchange | Original provenance + exact quantities, restock eligible only once |
| I06 | Website/admin/import/receipt/transfer/adjustment bypass POS trace ledger | Guard trước mutation hoặc participate atomic; no hidden stock drift |
| I07 | Opening balances, unit version change khi còn tồn, recall search | Trace + aggregate reconcile; forbid unsafe conversion edit; recall permission scoped |
| I08 | Cùng variant, hai gói khác weight/price/unit/lot; reload/edit/remove từng line rồi fulfillment/partial return | Immutable SaleLine IDs, merge key rõ; core mapping lossless, giữ riêng giá/discount/tax/provenance/entitlement; không variant-upsert gộp hoặc overwrite gói khác |

## 7. Test strategy và lệnh dự kiến

- RSpec app integration + FactoryBot/request/workflow/concurrency tests, real Spree boot. Không dùng stub toàn bộ lifecycle để claim compatibility.
- Vitest: command/revision mapping, query scopes, decimal input, lease/refresh coordinator, scanner queue, financial presentation, permission predicates.
- Playwright: cashier workflows thật, multi-browser contexts và display binding, network chaos, receipts print CSS snapshots, accessibility.
- Property/integration assertions: parent funds conservation xuyên refund/reversal/reallocation/liability payout; cumulative return entitlement + component sums; late-cash custody no-double-count; same-variant SaleLine lossless mapping. W09 dùng monotonic-clock/sleep/network fault tests, không chỉ token-expiry unit test.
- Test data là synthetic riêng DB test; không giao dịch ngân hàng thật cho automated suite. Device UAT/giao dịch nhỏ thực chỉ sau merchant approval.
- Root backend commands: `pnpm spree rails db:test:prepare`, `pnpm spree rspec spec/requests/spree/pos`, `pnpm spree rspec spec/workflows/spree/pos` (paths **planned**, chỉ chạy khi tạo).
- `apps/pos` dự kiến khai báo `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm build`, `pnpm test:e2e`. Root/dashboard không khởi động thêm stack đã chạy; POS dev command phải được docs phase2 chỉ rõ standalone app và CLI-supported integration nếu có.
- Gate phase1 kiểm available scripts/source/backend mounts trước khuyên lệnh setup. Không giả có `spree dev --app pos` hoặc typegen task chưa tồn tại.
- NFR benchmark profile/targets ở product spec; k6/Playwright chọn công cụ sau khi fixtures/môi trường rõ. Không claim tests đã pass khi mới tạo plan.

## Next steps

Mỗi phase phải map acceptance IDs liên quan, chỉ rõ create/modify paths và test gates. Phase11 release checklist không được thay thế test mỗi phase; financial features chỉ bật sau integration acceptance và operational sign-off.
