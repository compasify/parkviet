# Bàn giao phase 1–4 và backlog quay lại

Checkpoint 04/11/2026. Tài liệu này tổng hợp kết quả đã ghi trong [nhật ký runtime](./runtime-spike-results.md); các mục kiểm thử là bằng chứng tại thời điểm chạy, **không phải** khẳng định code hoặc môi trường hiện tại vẫn giống hệt. Không xóa, reset hoặc seed dữ liệu để tiếp tục.

## Quyết định về tiến độ và an toàn

- Phase 1: **completed** 06/11/2026 theo checklist đã điều chỉnh. Phase 2: **completed** 06/11/2026, proof còn lại chuyển phase 11. Phase 3: **completed** 06/11/2026, W08 trên API thật chuyển phase 11. Phase 4: **completed** 06/11/2026, browser 20 view trên API thật và timeout reload chuyển phase 11. Phase 5 đã `in-progress` theo checkpoint của phase đó; có thể tiếp tục phát triển preview và kiểm thử trong phạm vi được phép, không cần giả vờ phase trước đã hoàn thành.
- Các dependency vẫn là **gate thực tế theo capability**: không bật bán hàng vận hành, thanh toán, giao hàng, ghi tồn hay bất kỳ chức năng nhạy cảm nào khi chưa có proof tương ứng và phê duyệt triển khai. Preview không phải cash pilot; không có giao dịch tiền thật được phê duyệt.
- Hàng cân/phân số, serial/lô và ghi nhận tồn đúng kho vẫn cần proof/ADR phù hợp trước khi bật. Tách các gói cùng variant khác giá/lô thuộc [plan riêng](../../261103-pos-goi-hang-truy-xuat/plan.md); không mô tả POS cơ bản như đã hỗ trợ.
- Không đưa credentials hoặc artifact nhạy cảm vào commit. Review account tổng hợp từng lộ credential đã được deactivate và đổi mật khẩu, file credential đã xóa; chưa có proof mọi access JWT cũ bị thu hồi tức thời. Test live về sau cần fixture/credential mới và scope phù hợp; giữ các record/draft tổng hợp cũ, không tự xóa.

## Phase 1 — contracts và runtime

**Phạm vi mới đã được duyệt:** chốt hợp đồng POS siêu thị cơ bản; proof chuyên sâu chuyển phase 2–9/11 hoặc plan tách gói, giữ nguyên gate capability. POS cần mạng để bắt đầu bán, giao ngay tại quầy; không đọc được tồn thì cảnh báo và đối soát sau, không phải quyền bắt đầu bán offline. Giao sau cho ngành ăn uống là nhu cầu tương lai. [Bảng trách nhiệm và checklist đóng phase 1](../phase-01-contracts-and-ux-validation.md). Phase 1 **completed 06/11/2026** sau khi người dùng duyệt wireframe; các proof chuyên sâu bên dưới vẫn là gate tại phase phụ trách, không chuyển thành pass.

**Đã có:** chạy runtime/Spree và test DB qua CLI, characterization workflow; scoped walk-in draft không email có marker server-owned; các spike auth/permission, pickup, discount, stock và payment. Test thành công của characterization cũng có thể ghi nhận hành vi không an toàn; không đồng nghĩa gate pass.

**Cần quay lại, ưu tiên trước capability liên quan:**

1. **Tồn kho/fulfillment:** đã chốt nghiệp vụ: bán trực tiếp khi hàng thực tế ở quầy thì thiếu tồn chỉ cảnh báo, không chặn thanh toán; tracking stock xử lý xung đột online. Không tự áp cho giao sau. Fixture staff draft dựng sẵn đã cho thấy hai order allocation một đơn vị; service spike cart/order reserve cùng một đơn vị — bằng chứng giới hạn, không phải proof giải pháp. Còn phải qualify đúng kho, cảnh báo/dấu vết, stock effects một lần, tranh chấp POS/online và recovery; xem [quyết định](./pos-contract-decisions.md#tồn-kho-và-pickup--gate-đóng). Chưa bật bán thật.
2. **Tiền:** đã chốt phạm vi tiền mặt/chuyển khoản cá nhân nhân viên xác nhận; QR để sau, cần local recovery qua browser khi mất mạng giữa giao dịch và đối soát server khi có mạng. Chi tiết [hợp đồng tiền](./pos-contract-decisions.md#tiền--gate-đóng). Core có thể place order với test payment `pending`, không phải evidence tiền đã nhận; financial ledger, recovery sync/replay, settlement, unknown/refund/late cash và bảo toàn nguồn tiền chưa qualify. Không mở payment/handover dựa trên status order hoặc `payment_covered?`; việc khách rời quầy khi đơn/tiền chưa được server xác nhận chưa được quyết định rõ.
3. **Advanced goods/returns:** base-unit, precision, thuế/discount/rounding, serial/lot/expiry, provenance và cumulative returns chưa có proof đầy đủ. Core variant upsert từng gộp và ghi đè giá/metadata các gói; tham chiếu plan tách gói riêng trước capability đó.
4. **Authorization và UX:** hoàn tất test direct endpoint/bypass, concurrent revoke và duyệt UX/keyboard/responsive thực; các phép thử lẻ không thay được A01–A03/W01/W07/W08 toàn bộ.

## Phase 2 — shell và staff auth

**Completed 06/11/2026.** Chấp nhận access JWT sống tới hết hạn sau logout; hạ tầng triển khai chưa chốt. Backlog dưới đây là gate phase 11, xem [mục đóng phase](../phase-02-app-shell-and-staff-authentication.md#đóng-phase-06112026).

**Đã có:** app POS độc lập, login/refresh/logout, access token trong memory, context và i18n, shell theo wireframe, test unit/mocked browser và một số browser/API thật. Logout xóa state cục bộ; intent chưa rõ được cảnh báo và có receipt lookup.

**Cần quay lại:** A01 refresh rotation/logout/revoke giữa nhiều browser/tab thật và hành vi tab ngủ, CORS/origin/CSRF theo deployment; A02/A04 kiểm late callbacks/cache sau đổi store/logout; W08 keyboard, screen reader, zoom 200% và thiết bị thực; build trên môi trường triển khai tương lai. Logout thông thường chưa chứng minh thu hồi tức thời JWT cũ; deactivate staff đã được thử ở một số endpoint, không suy rộng cho toàn API.

## Phase 3 — topology, quyền và ca

**Completed 06/11/2026.** A02–A06 và F15 đã có test (gồm race hai connection PostgreSQL). Backlog dưới đây đã đóng, trừ W08 trên API/thiết bị thật và bypass core API toàn diện, chuyển phase 11. Xem [mục đóng phase](../phase-03-branches-registers-and-access-control.md#đóng-phase-06112026).

**Đã có:** branch/register/membership, access policy, context, shift tối thiểu, audit/approval primitives, selector search/phân trang; disable/recovery được test server và browser mock. Approval bind subject/action/amount/revision nhưng chưa là proof tích hợp discount.

**Cần quay lại:**

- A02/A03/A04: mở rộng guessed IDs, direct core bypass, store/branch isolation, revoke và context changes với request đang chạy; không lấy UI làm ranh giới quyền.
- A05/A06: kiểm đủ approval expiry/revocation/audit và recovery không mất lịch sử trong workflow tích hợp.
- F15: chứng minh hai connection đồng thời mở cùng drawer chỉ tạo một ca, opening float đúng và audit đầy đủ trước khi thu cash. Shift tối thiểu chưa phải close/cashbook phase 9.
- W08: selector/forms/ca bằng keyboard/tablet và API thật. Branch/location mapping không chứng minh strict stock routing.

## Phase 4 — workspace, lease và recovery

**Completed 06/11/2026.** W03–W05, A02/A04 và nền tảng F04 đã có test (gồm race hai connection PostgreSQL cho lease và tạo draft). Backlog dưới đây đã đóng, trừ mở 20 view trên trình duyệt với persistence thật và timeout reload trên API thật, chuyển phase 11. Xem [mục đóng phase](../phase-04-concurrent-order-workspace.md#đóng-phase-06112026).

**Đã có:** draft/workspace scoped, revision, lease gắn editor, takeover có quyền, command receipt/replay, park/reopen/cancel, pagination, layout/active selection một phần, cảnh báo intent và tra receipt. API thật từng chứng minh stale editor bị từ chối, takeover rõ ràng, commit mất response rồi reload/retry cùng key; probe PostgreSQL dùng hai connection cùng chờ row lock rồi chỉ một claim thành công.

**Đính chính W02:** test backend trên database/API thật đã tạo và phân trang **20 editing + 200 parked**, xác nhận 220 ID/order và summary không có `line_items` ([nhật ký, checkpoint phase 4 bước 10](./runtime-spike-results.md)). Việc còn thiếu là test **browser** mở/overflow/reload 20 view trên persistence thật, khôi phục mọi view và xác nhận khách/lines/discount khi các khả năng này tồn tại; không nói toàn bộ scenario W02 đã pass hay chưa từng có test 20/200.

**Cần quay lại:**

- W01/W03: không thể chứng minh end-to-end bank/cash/scan/100 physical intents khi catalog, line items và payment chưa hoàn thiện; tích hợp lại ở phase 5/6, bảo đảm không cướp focus, không mất/nhân đôi intent.
- W02/W05: close view, reopen, park, cancel và logout không xóa nhầm draft; test thực mọi view, pagination dịch chuyển, quyền bị thu hồi và context đổi/response đến muộn. Hiện mới có chứng cứ từng phần, gồm mock browser.
- A02/A04: kiểm scope/direct ID và stale cache/callback đầy đủ, đặc biệt sau revoke và đổi store/branch. F04 hiện chỉ có nền tảng receipt của command draft; financial replay phải kiểm riêng ở phase 6.
- Điều tra API thật đôi lúc timeout khi reload/tải danh sách hoặc phục hồi phiên: thu thập request/response, trạng thái auth và thời gian; không coi tăng timeout hay một lần pass là root cause.
- Handover vẫn bị khóa cho tới khi có kiểm tra receipt/external attempt phù hợp; tổng hợp lại từng acceptance phase 4 trước khi đánh dấu completed.

## Evidence và chạy lại

| Evidence đã ghi | Kết quả và giới hạn |
|---|---|
| Backend POS request/workflow/integration | 79 examples, 0 failures, seed `20060` ở checkpoint trước; không đại diện những sửa đổi sau đó. |
| Gate backend phase 4 | 13 examples, 0 failures, seed `46901`. |
| Frontend | 29 unit tests, build và lint pass tại checkpoint; Playwright mặc định 18 pass/6 skip, test chủ yếu mock. |
| Browser + API development thật | Hai test desktop pass ở lượt cuối trước revoke fixture; có lượt timeout không ổn định. Test 401 anonymous hiện mock refresh, không thay auth live. |
| Race PostgreSQL | Probe development opt-in xác nhận hai backend PID cùng bị block và chỉ một lease claim thành công; không phải bằng chứng race mọi workflow. |

Trước chạy lại: đọc `AGENTS.md`, xác nhận nguồn/mount/DB và migrations hiện tại; chỉ dùng `pnpm spree ...` cho Rails/database, không reset/seed, không dừng process POS của người dùng. Bộ test dùng transactional fixtures và guard chống chiến lược DatabaseCleaner phá hủy, nhưng guard không bảo vệ mọi SQL hoặc test nhiều connection tự quản lý. Chi tiết lịch sử database, thử nghiệm và sai sót nằm trong [nhật ký runtime](./runtime-spike-results.md).

Các thay đổi hiện có còn chưa commit; phase 5 và các file khác có thể đang được người dùng hoặc phiên khác chỉnh. Kiểm tra trạng thái thực tế trước mọi sửa đổi, không revert/overwrite công việc đó.
