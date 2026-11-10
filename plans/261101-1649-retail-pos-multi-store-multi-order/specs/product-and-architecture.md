# POS bán lẻ: phạm vi và kiến trúc

## 1. Trạng thái và quyết định đã xác nhận

- Ngày: 01/11/2026. **Plan-only**, chưa code app, chạy migration hay thay đổi hạ tầng.
- Người dùng chọn **POS bán lẻ đầy đủ**, không phải nhà hàng/bàn/bếp.
- Nhiều cửa hàng, mỗi cửa hàng nhiều quầy; không hardcode giới hạn số chi nhánh, quầy hoặc đơn đang phục vụ.
- Nhiều đơn đồng thời bằng tab trong app; khách A đang chờ chuyển khoản không chặn bán cho B.
- Có nút thêm khách hàng, giảm giá, chọn phương thức thanh toán ngay trên màn bán.
- Đã xác nhận: tiền mặt, chuyển khoản, thẻ qua máy ngoài, kết hợp nhiều phương thức, bán chịu/công nợ.
- Xác nhận bổ sung: **hàng cân/số lượng thập phân, quy đổi đơn vị, serial/IMEI, lô/hạn dùng đều trong phạm vi bắt buộc**. Mỗi quầy một két. Công nợ do quản lý cấu hình theo khách/quyền.
- POS làm trước; không phụ thuộc việc hoàn thành gem VietQR/SePay. Không thay đổi website checkout trong plan này.
- Các chính sách/thiết bị chưa được chọn bên dưới là **đề xuất cần duyệt**, không phải quyết định người dùng đã duyệt.
- Review: người dùng đã chọn **Áp dụng hết** cho các correction; disposition ở [verification report](../reports/planning-verification.md). Đây là duyệt sửa plan, không phê duyệt implementation/deploy.

## 2. Full functionality trong phạm vi bản phát hành

| Nhóm | Khả năng bắt buộc |
|---|---|
| Tổ chức | Chi nhánh, nhiều quầy, phân công thu ngân, cấu hình kho/tài khoản nhận/phương thức, khóa/ngừng quầy có lịch sử |
| Ca bán | Mở ca, tiền đầu ca, thu/chi, bàn giao, kiểm đếm cuối ca, chênh lệch và phê duyệt |
| Bán hàng | Search tên/SKU/barcode, ảnh hàng, variants, hàng cân, quy đổi đơn vị, serial/IMEI, lô/hạn dùng, tồn tại chi nhánh, ghi chú, giữ đơn, nhiều tab |
| Khách | Khách lẻ, tìm/thêm nhanh tên/điện thoại, gắn/đổi khách, lịch sử mua, công nợ theo quyền |
| Giá | Giá server, khuyến mãi/coupon, giảm dòng/toàn đơn theo %/VND, hạn mức và phê duyệt sửa giá |
| Thu tiền | Cash/change, bank manual, external-card attestation, split tender, chờ/xác nhận riêng từng khoản |
| Công nợ | Hạn mức, ngày hẹn, duyệt bán chịu, thu một phần/nhiều lần, phân bổ khoản thu, tuổi nợ, chứng từ |
| Hàng hóa | Giao tại quầy đúng kho, kiểm tra tồn, lịch sử đơn, hủy trước giao, trả một phần/toàn bộ, đổi hàng có thu/hoàn chênh lệch |
| Biên nhận | Bill 80mm/A4, in lại, bản sao, tìm theo mã bill; customer display chỉ đọc |
| Báo cáo | Doanh số, trả hàng, thực thu theo phương thức, nợ phát sinh/đã thu, sổ quỹ, chênh lệch ca; lọc chi nhánh/quầy/ca/thu ngân |
| Vận hành | Recovery sau reload/timeout, audit người thao tác/phê duyệt, phân quyền server, trạng thái mất kết nối |

Không gọi đây là bản phát hành đầy đủ khi mới có giỏ hàng và nút thanh toán. Các mốc nội bộ có thể nhỏ hơn; release đầy đủ phải qua phase 11 và toàn bộ acceptance matrix.

Hồ sơ ngành và module bán lẻ theo chi nhánh (wizard Thiết lập cửa hàng, trang Mô hình kinh doanh): [plan 261108-1830](../../261108-1830-pos-ban-le-da-nganh/plan.md). Vẫn chỉ bán lẻ; ngành ăn uống chỉ hiện "Sắp hỗ trợ", và ranh giới "không F&B" dưới đây không đổi.

### Ranh giới, không hứa thay mọi hệ thống bán lẻ

- Không thêm F&B, ERP/kế toán tổng hợp, loyalty engine mới, marketplace seller settlement, SaaS đa merchant, offline-finalize, acquiring/thẻ tích hợp trực tiếp trong đợt này.
  Ghi chú (10/11/2026): câu trên là ranh giới của đợt bán lẻ. Phạm vi F&B và giải trí nằm ở [ADR 0001](../../../docs/adr/0001-pos-fnb-scope.md).
- Hóa đơn điện tử có giá trị pháp lý cần adapter/đối tác và quy trình riêng; **bill POS không phải hóa đơn điện tử**. UI có thể lưu yêu cầu xuất hóa đơn/thông tin khách cho bước tích hợp sau, không báo đã phát hành.
- Catalog, nhập hàng, stock transfers và cấu hình khuyến mãi đầy đủ tận dụng dashboard hiện có; POS có tồn kho tra cứu và thao tác bán/đổi trả, không viết lại back office.
- API core hiện dùng số lượng nguyên nhưng **hàng cân/quy đổi/serial/lô không được bỏ khỏi release đầy đủ**. Thiết kế representation ở mục 14 và integration qualification phase1 là blocking gate; không ép `1.25` vào integer API hoặc chỉ lưu traceability bằng metadata.
- Thẻ ở đây chỉ ghi nhận khoản thu đã được máy POS ngân hàng độc lập chấp thuận. Không đọc PAN/CVV, không SDK acquiring và không tự charge thẻ.
- Gift card/store credit nếu bật phải tái sử dụng workflow Spree; không gộp chúng với công nợ hoặc tiền mặt. Việc bật cần thêm test matrix, không giả định được chọn.

## 3. Hiện trạng và tái sử dụng

- Root là Spree starter; dashboard React/Vite ở `apps/dashboard`, storefront Next.js riêng. Chưa có `apps/pos` hay `pnpm-workspace.yaml` tại thời điểm khảo sát.
- Dashboard dùng React 19, Vite, TanStack Query/Router, i18next; kế thừa pattern nhưng không khởi tạo full admin shell trong cashier app.
- Source tham chiếu/lockfile: Spree 6.0.1/Rails 8.1.4. Source local không chứng minh container đang chạy đúng commit.
- Admin Orders API hỗ trợ draft, `channel_id`, `preferred_stock_location_id`, customer và items; số lượng nguyên; cho giá manual trên draft. Manual discounts có API riêng.
- Admin Orders Payments create chỉ tạo payment row; **không đồng nghĩa nhận tiền**. Default amount của API không nên dùng để tính phần còn lại trong split tender: wrapper POS luôn truyền decimal amount đã kiểm tra dưới lock.
- `Orders::Complete` có `payment_pending`; core coverage tính cả `pending/processing/completed`. **Gate POS phải chặt hơn core**: chỉ tiền đã xác nhận và tín dụng đã được duyệt mới cho bàn giao.
- Preferred stock location chỉ là ưu tiên và có thể fallback kho khác. POS bắt buộc enforce đúng location của branch, không trông chờ field ưu tiên.
- Spree Store là biên dữ liệu merchant; channel POS là nguồn bán, không phải chi nhánh hay quyền. Admin API không dùng `X-Spree-Channel` làm scope.
- PaymentSession thuộc Cart hoặc Order, có settlement lock và identity `external_id`; phù hợp cho từng tender receipt đã xác nhận. Cần kiểm chứng partial amounts/canceled attempts và source contract trước code tài chính.
- Stock: placement tăng allocation; handover/fulfillment mới giảm physical stock. Không viết code POS trừ kho lần hai.
- CodeGraph không được expose trong tool catalog phiên này; dùng docs local và đọc source đã biết, không chạy init hay sửa index.
- Không có unfinished `plans/**/plan.md` khác; report VietQR là nghiên cứu, không phải blocker hoặc plan đã duyệt.

## 4. Kiến trúc được đề xuất

```text
apps/pos (React + TypeScript + Vite)
  auth/session, context, query hooks, order-tab workspace, payment side panel
                         |
             Spree staff authentication (JWT memory + HttpOnly refresh cookie)
                         |
  /api/v3/admin/pos/* (NEW restricted, branch-scoped API in server/app)
  authorize -> membership/context -> revision/idempotency -> POS workflow
                         |
  Spree drafts, pricing, discount/tax, PaymentSession/Payment,
  complete order, inventory, fulfillment, returns/exchanges/refunds
                         |
  POS-owned branch/register/shift/workspace/tender/evidence/receivable/cashbook/audit
```

- Một Rails backend, không Node payment service riêng. Code app-specific ở `server/app`, không sửa `spree/` upstream hoặc tạo gem mới khi chưa có nhu cầu public.
- Namespace backend đề xuất `Spree::Pos`; UI route `/pos`; API namespace mới là **đề xuất**, phải khai báo request schema và kiểm chứng route/auth tại phase 1.
- App POS là dự án JS độc lập theo pattern các app hiện có; không chuyển toàn repo thành workspace chỉ để thêm POS. UI primitives có thể dùng `@spree/dashboard-ui` sau khi xác minh exports/CSS; fallback Radix/Base UI theo hệ hiện có, không kéo full dashboard router.
- TypeScript DTO/query keys có `store/branch/register/workspace` tương ứng; abort/clear query khi đổi context, không hiển thị cache từ merchant/chi nhánh trước.
- TanStack Query cho server state; state UI nhỏ cho active tab/dialog. IndexedDB chỉ giữ layout, IDs và unsent intentions có TTL/scoping; không là sổ đơn hay tiền. Không lưu JWT, secrets hoặc bank evidence vào browser persistence.
- Poll các workspace đang chờ + notification summary có phân trang, backoff; không mount poller cho mọi tab lịch sử. SSE có thể thay transport sau đo, không đổi authority.
- Online-first: xem cache có nhãn; mất mạng không xác nhận tiền, xuất bill finalized hay giao hàng. Hàng chờ đồng bộ phải hiển thị rõ.

## 5. Mô hình tổ chức và ownership

```text
Spree Store (merchant / data boundary)
  POS Branch (chi nhánh vật lý, địa chỉ, timezone, receiving config)
    Register (quầy / logical drawer, không đồng nhất browser)
      Shift (một ca mở mỗi drawer, người chịu trách nhiệm)
    StockLocation mapping (một kho bán mặc định, chọn trong scope được cấp)
  StaffMembership (staff -> branch, granular capabilities)
  Workspace -> đúng một draft Order -> nhiều tender attempts
```

- Nhiều cửa hàng của cùng chuỗi là nhiều Branch trong cùng Store, không duplicate catalog/customer thành nhiều Store.
- Nếu thực sự nhiều merchant độc lập: biên Store/tenant được kiểm tra riêng; không biến yêu cầu nhiều cửa hàng thành mua Enterprise multi-tenant mặc định.
- Không hardcoded quota business. Dùng phân trang, virtual list, tìm kiếm/overflow và giới hạn kỹ thuật per-request. **Không hứa tải vô hạn**; profile tải là mục tiêu đo, không giới hạn thuê bao.
- Đã chọn **mỗi register/quầy một physical drawer**, một active shift chịu trách nhiệm; nhiều draft trong ca. Nhiều browser/máy không được tạo hai cash shifts bằng cách đổi client ID. Shared drawer giữa nhiều registers không nằm trong model đã chọn, không phải giới hạn số quầy.
- Thu ngân có thể quản lý nhiều workspace; mỗi workspace chỉ có một editor lease và revision. Mở cùng đơn ở máy khác là read-only hoặc takeover có audit/quyền, không silent last-write-wins.
- Workspace có typed associations tới branch/register/order; không chỉ dùng metadata khách có thể sửa. Snapshot source branch/register/cashier gắn lúc tạo và payment book context gắn lúc nhận tiền.
- Handoff khác quầy/ca chỉ khi không có receipt đã thu và không còn attempt chuyển khoản/thẻ unresolved. Khoản đã thu phải giữ nguyên order và được manager resolve/refund/complete trước, không chuyển lịch sử tiền sang ca mới. Future adapter auto có cancel không thật sự thu hồi bank QR.
- Đổi branch không âm thầm đổi location của drafts. Server chặn nếu active mutation; UI yêu cầu giữ ở context cũ/resolve, sau đó mới chuyển context.

## 6. Entity inventory — đề xuất, chốt ở phase 1

| Entity | Lý do có persistence riêng |
|---|---|
| Branch, Register, StaffMembership | Topology, access, cash drawer identity và cấu hình có lịch sử |
| Shift | Opening float, status, close barrier, count/approval, immutable closing snapshot |
| Workspace | Gắn draft Order, tab label/order, operational status, revision, editor lease, immutable branch origin |
| TenderAttempt | Amount/method, idempotency, pending evidence; liên kết settlement session và payment, không clone sổ tiền |
| ReceivedFunds, FundsAllocation, LiabilityPayout | Một sự thật tiền nhận dùng chung sale/collection; phân bổ, reversal và hoàn tiền chưa phân bổ có reservation/evidence và bảo toàn parent |
| ReceiptEvidence | Ai xác nhận, external reference/receiving account, timestamp/amount; dữ liệu nhạy cảm chỉ server |
| CommandReceipt | Durable key + payload digest + result/owner; replay cùng key khác payload bị từ chối |
| CreditAccount, ReceivableEntry, CollectionAllocation | Hạn mức, dư nợ theo khách/store; sổ tăng/giảm/bù trừ và phân bổ tiền vào nhiều đơn |
| CashMovement | Cash-only immutable entry, source receipt/refund/collection/payout, unique source association |
| AuditEntry, Approval | Dấu vết thay đổi nhạy cảm; approver distinct where policy yêu cầu; action/amount/revision-bound |
| SaleLine, UnitDefinition, UnitConversion, MeasuredLine | Immutable POS line identity; đơn vị bán/đơn vị tồn, hệ số exact/versioned, số đo và snapshot giá; ánh xạ core lossless |
| InventoryLot, SerialUnit, TraceAllocation | Nguồn nhập/lô/hạn dùng/serial, reservation/placement/handover/return provenance có constraint, không chỉ note |

Ưu tiên quan hệ/constraint và workflow hiện có. Không thêm entity riêng nếu chỉ lặp dữ liệu đã truy xuất bền vững được. Immutable events dùng reversal thay vì sửa/xóa. Foreign ownership luôn xác thực bằng store và branch ở server, kể cả incidental IDs.

## 7. Nhiều đơn, concurrency và recovery

1. `+ Đơn mới` tạo workspace + draft idempotently; UI giữ tab tạm đến khi server trả ID, không thêm hàng vào tab khác do response về muộn.
2. Mỗi edit gửi workspace ID, revision, command key; server lock/recheck lease/context; apply workflow rồi tăng revision.
3. Request stale trả `409` kèm revision/cách reload an toàn. Command retries giữ cùng key; không tự retry mutation bằng key mới.
4. Scanner có sequence per workspace; dùng commands tăng số lượng có idempotency, không concurrent absolute overwrites gây mất lần quét. Debounce search, **không debounce mất barcode events**.
5. Tab giữ search/scroll/panel theo workspace. Async callbacks bound ID, không dùng `activeTab` hiện tại làm đích.
6. Tender pending không khóa cả app: chỉ khóa dòng tiền/giá/khách/location của order đó. Chuyển sang tab khác vẫn làm việc.
7. Payment verified về cho tab nền tạo badge + toast ghi mã đơn; không chuyển active tab hay customer display bất ngờ.
8. Reload: server list current workspaces, restore active ID còn được phép; khôi phục status thật trước khi cho thu tiền. Logout purge cache/lease/UI với unsent warning; không xóa drafts server.
9. Close tab chỉ đóng view sau save/park; cancel order là command có quyền và kiểm tra tiền. Đơn có partial receipt không được xóa/hủy như nháp trống.
10. Lease timeout/takeover chặn stale editor; idempotent key receipt được đọc lại trước revision conflict để replay thành công của request đã commit.

Operational states của workspace (`editing/parked/awaiting_payment/partially_received/ready/completing/completed/attention/canceled`) là status riêng đề xuất. Không ghi chúng vào status/payment_status core. `attention` luôn có reason và recovery action.

## 8. Tiền và công nợ

- Currency launch: VND; mở rộng cấu trúc có currency, không hardcode nhân/chia 100. API canonical decimal strings, Ruby BigDecimal, UI decimal-safe math và `vi-VN`; tổng phải thu/thu thực/chi thực là nguyên VND theo policy. **Đơn giá base-unit và giá trị trung gian được fractional** nếu phase 1 chứng minh precision; không reject nhầm `0.4 VND/base-unit` hoặc làm tròn sớm.
- Giá/thuế/discount/tổng/amount còn phải thu do server tính. Discount limit + approval kiểm tra trên snapshot revision; không cho cashier gửi giá tùy ý vào Admin API.
- Gross cash handed = tiền khách đưa; cash applied = tiền ghi trả đơn; change = trả lại khách. Chỉ applied trở thành Spree Payment; CashMovement net drawer delta = handed - change. Không ghi tiền khách đưa thành overpayment.
- Một đơn 500.000đ trả cash applied 200.000đ + bank 200.000đ + debt approved 100.000đ: payments completed = 400.000đ, nợ = 100.000đ, **không phải paid**.
- Transfer chỉ pending khi mới chọn/hiển thị QR; staff có quyền kiểm tra tiền vào phía nhận rồi attest. External card chỉ completed sau attest receipt approval; lưu terminal reference, không dữ liệu thẻ nhạy cảm.
- Mỗi khoản actual receipt có một ReceivedFunds và unique receipt identity; mỗi allocation child có settlement identity/session/payment riêng. Sale thông thường có một child, collection có thể nhiều child; không tạo Payment cho phần chưa phân bổ. Confirm cùng lúc không thu hai lần. Khác receipt cùng reference đáng ngờ cần review, không tự bỏ qua tiền thật.
- Tổng tender đã nhận + in-flight commitments không vượt số còn phải thu đã lock. Bank transfer thực tế vượt cam kết vẫn phải ghi nguyên khoản tiền vào exception ledger; phần thừa là unapplied receipt/customer liability, không doanh số hoặc nợ âm. Trong collection nhiều đơn, parent receipt có nhiều allocation/payment child, tổng allocation không vượt parent receipt; không clone receipt tiền thật.
- Không giữ DB lock trong provider I/O. Durable intent trước external effect, durable receipt/result sau đó, transactional outbox/recovery sweep vá enqueue gap. Timeout là unknown cần tra operation cũ, không failed cho thu tiếp lần nữa. Processor fee/payout settlement không mở lại nợ khách.
- Tiền đã nhận nhưng placement fail là recovery, không rollback sự thật tiền, không thu lại. Khóa sửa snapshot; retry completion idempotently hoặc refund có evidence.
- Credit approval reserve exposure dưới customer account lock: open debt + committed exposure + pending approved credit không vượt configured limit. Customer change invalidates approval. Không dùng fake payment method 'debt' để làm paid.
- Credit default tắt đến khi manager cấu hình account/limit/due date policy. Manager action-bound approval, không shared admin PIN/reusable approval token.
- Collect nợ chỉ tạo Spree Payment/receipt một lần theo phương thức thực và allocation vào đúng order(s); không tạo doanh số bán mới. Multi-order collection có một received-funds record và child allocations, không copy nguyên amount sang mỗi đơn.
- Returns trên order còn nợ: credit note giảm nợ trước trong phạm vi returned value; phần vượt nợ mới là khoản hoàn tiền có cap theo actual paid/refundable. Tổng credit note + refund không vượt entitlement.
- Với credit-sale returns, `receivable balance` là dư nợ sau credit notes/allocations, không suy thẳng từ core `order.amount_due` hoặc gán lại `payment_status`. Phase 1 phải test seam Return/Refund khi phần trả hàng chưa từng được thu; design credit note không được tạo Refund cho tiền chưa nhận hoặc sửa lịch sử giá bán chỉ để số dư trông khớp. UI giải thích riêng giá trị đơn gốc, credit notes, actual receipts/refunds và dư nợ.
- Discount/khách/items không sửa sau nhận một phần tiền; muốn thay đổi phải đi workflow correction/return/đơn mới, không âm thầm recalc QR.

### ReceivedFunds conservation và xử lý tiền chưa phân bổ

- Dưới parent lock, các bucket **không chồng lấp** luôn thỏa `received_net = available_unapplied + allocated_unconsumed + payout_reserved_or_unknown + paid_out`. Tất cả không âm, cùng currency; `paid_out` gồm cả Refund của allocation child và LiabilityPayout trực tiếp. Cash `received_net` là handed − change; giữ handed/change làm evidence, không đếm lại change như refund.
- Allocation/refund/reversal/payout đều lock/recheck cùng parent ReceivedFunds và các child liên quan theo lock order dùng chung. Ledger giữ immutable face amount + transition/source links; bucket là projection, không xóa lịch sử Payment/Refund để cân sổ. Partial/failed settlement commitments cũng bị khóa, không đồng thời đem phân bổ/chi nơi khác.
- Refund reservation chuyển phần còn dùng được của allocation sang reserved; confirm chuyển sang paid_out. Liability payout làm tương tự từ available_unapplied. Unknown/timeout giữ reservation; chỉ release khi có evidence thao tác cũ không còn khả năng chi, không dựa timeout hoặc cancel UI.
- Reverse allocation chỉ giải phóng **phần chưa refund/chưa reserved/chưa unknown** về available_unapplied. Phần đã chi không bao giờ sống lại khi reverse child. Reverse toàn phần chạm consumed funds phải reject hoặc explicit partial reversal có preview/approval; điều chỉnh Payment/receivable bằng seam đã test, không fake external refund hay tạo receipt mới.
- Tiền chuyển thừa/trễ hoặc tiền nhận khi đơn đã hủy/đã thu cash phải có inbox, owner, evidence, original attempt/order context và số dư liability. Manager được **phân bổ có chủ đích** phần available sang đơn đủ điều kiện cùng merchant/currency với xác minh người trả/chủ hưởng, hoặc tạo LiabilityPayout hoàn tiền. Không auto-credit đơn kế tiếp, doanh số hoặc nợ âm.
- LiabilityPayout có durable intent → reserved → submitted/unknown → confirmed (hoặc failed-no-effect có evidence); request/confirm quyền riêng, action-bound approval và idempotency. Chỉ confirmed mới giảm liability vĩnh viễn/ghi cash out nếu thực chi; reservation đã giảm spendable ngay. Không yêu cầu goods return hoặc core Refund cho khoản chưa từng trở thành Payment. Phần đã allocated dùng core Refund seam, cùng parent cap để tránh hoàn ở cả hai đường.
- Acceptance bắt buộc: collection → allocate A → refund child A → reverse/reallocate B không hồi sinh phần đã hoàn; concurrent liability payout vs allocation/refund và late transfer sau cash/cancel đều bảo toàn parent.

## 9. Complete, giao hàng và refund

- Restricted `finalize` gate: confirmed completed receipts + approved credit allocation = amount phải xử lý; no unresolved external attempt; đúng branch location và policy hàng theo loại đơn; cash shift hợp lệ. Với hàng thực tế đã có tại quầy, thiếu tồn hệ thống chỉ cảnh báo, không chặn vì thiếu tồn; xem [quyết định và các proof còn thiếu](../reports/pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng). Không suy rộng sang giao sau hay tracked serial/lô.
- Chỉ gọi `Orders::Complete` sau gate. Trường hợp bán chịu dùng `payment_pending: true` có chủ đích, từ workflow đã duyệt; tuyệt đối không expose boolean này cho cashier client tùy ý.
- Order paid/partially_paid/none được core derive; receivable snapshot giải thích khoản chưa thu. Pending payment không thay credit approval.
- Khách lẻ có thể không email/address cá nhân: phase 1 phải chứng minh local pickup + walk-in trong installed workflows. Cấu hình/policy chỉ scoped POS; không tắt validation toàn website, không tạo email giả/địa chỉ nhà giả.
- POS không fallback sang kho chi nhánh khác khi hết hàng. Chặn hoặc tạo explicit transfer/delivery workflow riêng có quyền; launch mặc định chặn.
- Handover dùng fulfillment workflow có authorization paid-or-approved-credit; không `force` từ browser. Test reservation/allocated/physical counters và event exactly once trong retry.
- Trả hàng bám original fulfillment items/giá/discount/tax, kiểm returned quantity dưới lock; restock resellable vào receiving branch đúng quyền. Cross-branch return cần manager.
- Entitlement tính **lũy kế theo immutable sale-line snapshot**, dùng chung credit notes/refunds/discount/tax. Với line quantity `Q`, đã duyệt trả lũy kế `q`, target `E(q)` phân bổ từ số tiền gốc đã chốt; delta lần này = target mới − phần đã cấp/reserve. Full return bắt buộc `E(Q)` bằng toàn bộ giá trị gốc đủ điều kiện; residual VND không bị mất do round riêng từng lần. Component allocation phải khớp tổng và không âm; không cộng nhiều entitlement engines độc lập.
- Ví dụ 5 base units × 0.4 VND = 2 VND, trả `1 + 1 + 3` phải cấp tổng **2 VND** (lịch làm tròn từng lượt được chốt phase 1), không chỉ 1 VND. Lock quantity + entitlement + reservations để tránh cấp kép; nếu hủy reservation phải revalidate/reprice các entitlement phụ thuộc trước approval mới, không lặng lẽ đổi chứng từ đã post.
- Reservation có thứ tự dưới SaleLine lock; entitlement phụ thuộc không được post trước predecessor chưa resolve. Cancel chỉ rebuild/reapprove các dependent reservations chưa post; từ chối cancel nếu đòi thay chứng từ đã post, dùng explicit correction được duyệt. Quantity restock, returned entitlement và actual payout là ba facts riêng, không retry chi/nhập kho vì đang đợi predecessor.
- Hoàn cash: chứng từ payout tại active receiving shift, map core Refund đúng lúc thực chi. Bank/card: request và confirmation riêng; chưa có chứng từ hoàn thì không có refunded success giả. Không cung cấp dummy `credit` luôn true.
- Goods refund luôn consume parent ReceivedFunds qua allocation child; cap đồng thời return entitlement, Payment refundable và parent available-for-that-child, kể cả reserved/unknown. LiabilityPayout cho tiền chưa allocated ở §8 không giả lập trả hàng.
- Đổi hàng là linked return + replacement sale, stateful orchestration, bổ sung/hoàn chênh lệch; không netting làm mất hai vế chứng từ hoặc trả stock/tiền hai lần.

## 10. Ca bán và báo cáo

- Opening float/close phải có unique register active-shift constraint, kiểm server; cashier có thể có nhiều tabs nhưng một drawer shift responsible owner.
- Cash expected = opening float + các physical inflows duy nhất − các physical outflows duy nhất: cash sales net change, collections/unapplied cash thực vào, cash-in; trừ refunds/liability payouts thực chi, cash-out/safe drops. **Không cộng bank/card/debt phát sinh**, không đếm một source hai lần; allocation/reversal không đổi tiền vật lý. Change không bị trừ hai lần.
- Close barrier lock shift và drain in-flight commands trước snapshot. Pending remote receipts phải resolve/cancel-safe hoặc manager handover/reconciliation; không sửa closed snapshot khi bằng chứng đến muộn.
- Late bank receipt: lưu original sale/attempt context và book vào current reconciliation period; không giả làm cash của ca cũ. Với **late cash attest**, tách thời điểm thực nhận, thời điểm book và custody hiện tại; không backdate/sửa closed snapshot và **không tự cộng CashMovement vào ca mới**.
- Ví dụ S1 thực nhận 100k chưa ghi, expected0/count100k/variance+100k; S2 đã opening100k: late attest ghi receipt tài chính một lần và current-period reconciliation phân loại overage S1, **S2 expected vẫn100k**, không200k. Nếu tiền đã safe-drop/bàn giao, link custody evidence thay vì cộng vào drawer S2. Chỉ có physical transfer/tiền mới thực vào S2 mới tạo net movement tương ứng; opening/transfer/source dedup để không đếm kép. Manager reconciliation có reason/approval và link S1 closure variance + current custody, không rewrite con số đã chốt.
- Blind count đề xuất; counted/expected/variance riêng, variance cần reason và phê duyệt theo ngưỡng cấu hình. Closed ca bất biến, correction/reversal có audit.
- Sales date, received-at, booked-at và return date tách riêng; báo cáo timezone chi nhánh, ca qua nửa đêm, filters allowlisted ở server. Thực thu không bằng doanh số và không bằng cash drawer.
- Report tài chính từ ledger/core facts, không đếm UI tabs hoặc tổng metadata. Export lớn có job + permission + file TTL; không gửi raw data toàn chuỗi cho cashier lọc client-side.

## 11. Quyền và bảo mật

- JWT staff access token ở memory + HttpOnly refresh cookie theo SDK hiện có; single-flight refresh giữa tab browser và xử lý revoke/logout. Không secret API key trong SPA.
- POS cashier chỉ được custom granular POS permissions; **không cấp blanket `write_orders/write_payments/write_refunds`**. Wrapper authorize custom domain, gọi workflow core bên server.
- Nếu core read endpoints cần scope quá rộng/serialize cost/internal info, expose POS DTO/scoped readers; không nới quyền chỉ để UI load được.
- Kiểm direct core endpoints trong negative tests: cashier không được bypass discount limit, confirm evidence, branch stock gate, refund/debt approval hoặc `payment_pending`.
- Approval validate approver role + branch + action + amount + revision + expiry, ghi audit; không reuse cấp quyền sau đổi giá/khách.
- Display bearer chỉ đọc, short-lived, revocable, bound attempt/session và display generation; không cart token/JWT, không PII/công nợ hay số dư.
- Display fail-closed bằng bounded **local freshness deadline** chốt/UAT ở phase 10, tách token expiry: cached/delayed response không renew lease, disconnect phát hiện được hoặc hết deadline phải ẩn QR. Resume/visibility change ẩn trước rồi revalidate; generation unresolved không show. Cashier thấy freshness và chỉ phục vụ khách kế sau ACK generation hiện tại/clear; thiếu ACK phải ngừng dùng display, không đoán đã clear. Server revoke không thể xóa QR đã chụp, late receipt vẫn vào exception.
- Mask PII, strict CORS/CSRF/origin handling, no sensitive log, CSV formula injection protection, no offline service worker cache auth/private JSON.

## 12. Chỉ tiêu, giả định và gates

- Kiến trúc không quota cứng; benchmark đề xuất: 50 branches × 10 registers, 20 live workspaces/register, catalog 100.000 variants, 100 concurrent active cashiers. Đây là **profile kiểm thử ban đầu**, cần đo/chốt, không claim SLA/capacity đã đạt.
- Mục tiêu LAN staging: thao tác tap/tab phản hồi <100ms ở UI, search p95 <500ms, draft mutation p95 <700ms, confirm local receipt + status p95 <2s không gồm bank/printer. Phải ghi hardware/data/load và kết quả thực trước cam kết.
- Gate phase 1: runtime source/mount, draft discounts persistence, split PaymentSession, unpaid/credit placement, pickup/walk-in, strict branch routing, permission bypass và refund evidence đều phải có spike tests. Nếu seam không đáp ứng, ADR + cập nhật plan trước code các phase tài chính.
- Backend mọi lệnh qua `pnpm spree ...` từ root; chỉ eject khi developer duyệt vì có thể đổi DB. Không tự eject/reset hoặc chạy Rails/Docker trực tiếp.
- Các policy chưa chốt: độ chính xác cân/đơn vị và thiết bị; hạn mức/duedate/overdue rule; ngưỡng discount/refund/variance; return window/cross-branch; model máy in và display. Manager-configured credit và mỗi quầy một két đã được người dùng chọn; ngưỡng cụ thể vẫn cần cấu hình trước vận hành.

## 13. Nguồn local và phạm vi kiểm chứng

Đã đọc tĩnh, chưa gọi live transaction API hoặc chạy integration tests:

- `apps/dashboard/package.json`, `src/main.tsx`, `AGENTS.md`; root `package.json`, `server/AGENTS.md`, `config/routes.rb`, `config/initializers/spree.rb`, `docker-compose.yml`.
- `spree/spree/api/app/controllers/spree/api/v3/admin/orders_controller.rb:18–74,92–145`: draft input, price, preferred location, completion.
- `.../admin/orders/payments_controller.rb:23–59`: create row/amount, không xác nhận nhận tiền.
- `.../admin/orders/discounts_controller.rb:14–55`: %/flat và allocation qua service.
- `spree/spree/core/app/services/spree/orders/update.rb:19–38`: fulfillment rebuild và totals recalculation; discount persistence phải test.
- `spree/spree/core/app/workflows/spree/orders/complete.rb:23–61,135–153,283–285`: payment coverage và inventory allocation.
- `spree/spree/core/app/models/spree/payment_session.rb:143–159`: owner lock/idempotent settlement.
- `spree/spree/core/app/models/spree/line_item.rb:11,56–68,225–229`: integer quantity, DB integer max, rounding line amount sau price × quantity.
- `spree/spree/core/app/workflows/spree/carts/upsert_items.rb:91–107,123–137,198–209` và `orders/upsert_items.rb:10–25`: coercion `.to_i`, exact BigDecimal manual unit price và inherited draft pipeline; không được gửi fractional quantity trực tiếp. Exact base-unit pricing vẫn phải test end-to-end.
- `spree/spree/core/app/workflows/spree/carts/upsert_items.rb:220–224,302–319`, kế thừa qua `orders/upsert_items.rb:10–12`: variant-keyed lookup/update có thể gộp các dòng cùng variant; không phải line-ID-aware POS contract.
- `spree/spree/core/app/models/spree/line_item.rb:258–266`: proportional return amount round từng lần; cap tổng không tự bảo đảm hoàn đủ residual khi chia nhiều lần trả. Cumulative entitlement cần spike riêng.
- `node_modules/@spree/docs/dist/developer/core-concepts/{stores,channels,inventory,orders,discounts,order-totals,staff-roles,returns-exchanges-claims}.md`.
- `node_modules/@spree/docs/dist/developer/sdk/admin/authentication.md`.
- [Report VietQR trước đó](../../reports/261101-1628-vietqr-payments-and-pos-research.md): tham khảo boundary payment, không kế thừa toàn bộ scope website/SePay.

## Next steps

Đọc cùng `ux-and-workflows.md`, `api-contract-and-test-matrix.md` và phase files. Duyệt plan/policy rồi mới triển khai. Không cần duyệt provider ngân hàng để bắt đầu shell/multi-order POS; trước thu tiền thật phải qua financial gates.

## 14. Hàng cân, quy đổi, serial và lô — bổ sung phạm vi đã duyệt

### Representation và gate tương thích core

- Đề xuất ưu tiên **integer canonical stock base units**: ví dụ UI Việt `1,25 kg = 1.250 g`, DTO sale quantity `"1.25" kg` → core quantity `"1250" g`; 1 thùng = 24 chai. UI dùng exact decimal + unit labels; core quan sát integer base quantity. Mọi kênh/cấu hình phải hiểu cùng đơn vị, không một nơi hiểu 1250 là g nơi khác hiểu là kg.
- Đơn vị/hệ số conversion versioned và immutable khi đã có stock/order; không đổi base unit tùy ý khi tồn/receipts còn sống. Cho phép conversion hữu tỷ exact theo precision đã chọn; reject giá trị không biểu diễn được, không truncate số đo.
- Đơn giá theo kg/thùng phải chuyển exact về base price; test core price column scale, request money normalization, promotion/volume tiers, tax/discount allocation, stock counters, fulfillment items, return/refund precision và overflow DB trước chọn giải pháp. Core `LineItem` khai báo integer quantity, amount round sau `price * quantity`; đây chưa chứng minh toàn bộ pipeline giữ fractional unit-price.
- Không giả định giá base unit luôn nguyên VND hoặc có thể làm tròn sớm. Nếu lượng/giá không representable với installed Spree, phase1 phải chọn ADR thay thế được duyệt (host-supported workflow/representation hoặc compatibility change được duyệt riêng), cập nhật consumers/test matrix rồi mới code. **Không đánh dấu full release khi chưa giải quyết gate này**; không có quyền tự sửa fork/schema core trong phiên planning.
- Mã vạch cân embedded weight/price cần profile theo cửa hàng/thiết bị, checksum, unit và tare/net; nhập tay có reason. Không đoán mọi EAN-13 là weighted code. Camera/USB-scale drivers cần adapter đã UAT, manual numeric input vẫn đầy đủ chức năng bán cân.

### Immutable sale-line identity và merge rules

- Mỗi POS SaleLine có immutable public ID scoped workspace/order, không lấy variant ID hoặc row index làm identity. MeasuredLine lưu measurement-event ID, gross/tare/net, sale quantity/unit, conversion version, exact base quantity, price/discount/tax snapshot và trace links; chỉnh nháp giữ line ID nhưng tăng revision, sau settlement dùng correction/return thay ghi đè.
- Hai gói cùng variant nhưng khác số cân/nhãn giá, unit/conversion, negotiated price/discount, lot/serial hoặc provenance phải giữ dòng riêng. Ordinary untracked scans chỉ merge khi **toàn bộ merge key đã duyệt** trùng và intent cho phép; không mặc định merge measured scans vì cùng SKU. Serial/lot chia dòng hay sub-allocation phải mapping lossless.
- Phase 1 chọn seam **core line-ID-aware write** hoặc **typed measured sublines → core lines** có mapping lossless đã test. Variant-keyed core upsert hiện tại không đủ; không chỉ thêm metadata và hy vọng không bị gộp. Nếu sublines cần aggregate, phải giữ đúng tổng exact quantity/value/discount/tax, fulfillment và return entitlement theo từng SaleLine; không weighted-average làm mất giá gốc. Không chứng minh được thì ADR/block phase 5/6/8.
- DTO, edit/remove, discount targets, scanner commands, bills, handover và partial returns dùng SaleLine ID; core line/fulfillment IDs là server mapping. Tests reload/edit/remove/return riêng từng gói cùng variant không đổi gói còn lại hoặc aggregate stock sai.

### Lot/serial stock conservation

- SerialUnit là unique identity trong merchant/product domain đã chốt, trạng thái available/reserved/sold/returned/quarantined và current location; một serial chỉ xuất một lần, không bán vượt unit count.
- Lot có lot code, received/source, expiry, available/reserved/allocated quantities theo location/base unit. TraceAllocation gắn line/fulfillment/tender-independent business operation, reserve/consume/release under lock. Tổng eligible lot units phải khớp phần tracked StockLevel, cộng quarantine/non-sellable có đối chiếu rõ.
- FEFO theo expiry + receipt tie-breaker, chặn expired/quarantined và cảnh báo near-expiry; manager chọn lô khác được ghi audit, không cho bán expired chỉ vì bypass UI.
- Thu tiền không là lúc duy nhất allocate serial/lô: reserve trong prepare stock và chuyển sang allocated/shipped theo core lifecycle. Timeout/release đúng owner; không giữ serial/lô vô hạn vì hàng trăm parked tabs.
- **Spree vẫn là writer số lượng aggregate**; traceability ledger đồng bộ atomic với core workflow tại seam đã test, không tự giảm aggregate ngoài workflow. Receiving, transfers, adjustments, cancellations, sale/website/admin/import và returns của tracked SKUs đều phải tham gia. Async subscriber sau commit không đủ làm guard trước oversell.
- Phase1 phải inventory các mutation entry points và chứng minh enforce/bypass tests. Nếu consumer chưa hỗ trợ traceability, capability reject tracked-SKU mutation rõ ràng (không âm thầm drift). Enable theo SKU/location sau đối soát opening balance và migration/import trace identities; regression normal website SKUs không đổi.
- Return phải đối chiếu original serial/lot/base quantity, chặn serial khác hoặc double return, expiry/condition -> quarantine nếu không resellable. Replacement sale giữ traceability mới và không reuse sold serial.
- Recall/search theo serial/lot -> receipt/customer/chi nhánh theo quyền, không expose toàn chuỗi cho cashier. Báo cáo tồn/expiry có unit labels, conversion snapshot để không hiển thị 1250kg thay 1,25kg khi stock base là1250g.

### Release scope và dependency

- Phase1 qualify architecture; phase5 định nghĩa đơn vị/cấu hình SKU, measured-sale UI và draft snapshot; phase8 đưa inbound/stock allocation/traceability + returns vào hoạt động thật. Phase6 money guard phải từ chối bán tracked SKU trước khi stock capability phase8 đạt, không thu tiền rồi mới phát hiện thiếu serial.
- Guard chặn prepare/allocate sale settlement, không từ chối ghi nhận unsolicited/late actual money; khoản đã tự về vẫn vào ReceivedFunds/unapplied liability/attention, không đủ quyền complete hoặc handover.
- Release đầy đủ bao gồm mọi loại hàng người dùng đã chọn; phase 6–7 **sandbox-only**. Cash pilot riêng nếu được duyệt chỉ dùng qualified ordinary SKUs dưới feature flags, áp ngay security/refund/close/reconciliation gates phase 11 và human deployment authorization; **không được gọi là hoàn tất yêu cầu**.
