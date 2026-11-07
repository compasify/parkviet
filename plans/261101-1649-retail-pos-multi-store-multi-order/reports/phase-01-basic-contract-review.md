# Rà soát contract phase 1 — POS siêu thị cơ bản

Rà soát source và nhật ký tại checkpoint 04/11/2026; đây là kiểm tra tài liệu/source, **không phải chạy test mới hoặc đánh giá security toàn diện**. Công việc phase 5 đang thay đổi; route có trong source không chứng minh server đang chạy bản đó, UI đã nối, hoặc capability được phép vận hành.

## Phạm vi và trạng thái

- POS giao ngay tại quầy, cần mạng khi bắt đầu bán. Tồn không đủ hoặc không đọc được thì cảnh báo theo policy; đúng kho và đối soát sau. Recovery mất mạng giữa giao dịch không phải bán offline.
- Tiền mặt và chuyển khoản cá nhân do nhân viên xác nhận; QR và giao sau ngoài phạm vi cơ bản. Trả hàng, công nợ, hàng cân, serial/lô và tách gói không được tuyên bố đã hoạt động chỉ vì phase 1 đóng.
- Không có phê duyệt thu tiền thật/deploy; route handover không chứng minh handover hoạt động hay được mở.

## Contract, evidence và trách nhiệm còn lại

| Nhóm | Đã quan sát | Chưa chứng minh / chủ trì |
|---|---|---|
| Runtime và walk-in | [Nhật ký](./runtime-spike-results.md) ghi source Spree 6.0.2 tại các lần spike; walk-in marker server-owned và test từng phần. | Cần xác nhận source/mount/DB lại trước test mới; test cũ không chứng minh mọi extension hoặc runtime hiện tại. Phase 2–3/11. |
| Staff và isolation | Request test cũ ghi login/refresh, một số thử store chéo và từ chối core create với staff chỉ có POS; `server/app/controllers/spree/api/v3/admin/pos/base_controller.rb` yêu cầu staff và scope workspace/store. | Logout không chứng minh revoke JWT ngay; còn A01–A04, concurrent revoke và các direct endpoints chưa test. Phases 2–3/11; không cấp blanket core writes để bỏ qua wrapper. |
| Context/workspace/recovery | `server/config/routes.rb` có context, workspace, lease và command receipt; nhật ký có replay commit/mất response và tranh lease cho **draft**. `base_controller.rb` yêu cầu key và từ chối header/body khác nhau. | Không suy ra financial idempotency; W01–W05, restore/revoke và timeout live còn mở ở phase 4. Các DTO/envelope trong [ma trận](../specs/api-contract-and-test-matrix.md) vẫn là contract dự kiến ở những phần chưa đối chiếu. |
| Catalog, items, customer, discount | Source hiện có route catalog/customers/items/discount; items và discount controllers truyền revision/lease/editor/key vào workflows. Discount workflow source có lưu intent, recalc, approval/audit. | **Không khẳng định đã disabled:** các route tồn tại trong source; cần xác nhận runtime, permission, cấu hình và phạm vi exposure trước bất kỳ preview/enable. Core discount từng cho kết quả cũ sau recalc; test adjuster hẹp trong checkpoint phase 5 chưa chứng minh toàn bộ lifecycle, tax/approval/concurrency. Không sử dụng kết quả test hẹp làm proof an toàn. Phase 5 chịu trách nhiệm hoàn thiện và kiểm chứng. |
| Tiền và handover | Contract cho receipt được xác nhận khác `pending`; mất response phải lookup/replay đúng key. Route handover có trong source. | Server financial ledger/API replay và browser queue chưa được chứng minh; order pending có thể được đặt trong spike. Phase 6/8; không dùng draft command receipt làm proof tài chính. |
| Tồn | Spike thể hiện preferred location có thể fallback và over-allocation/reservation trong đường thử hẹp; policy bán tại quầy đã chốt. | Đúng kho, cảnh báo khi thiếu/không xác định, tác động một lần, tranh chấp online, đối soát và recovery chưa qualify. Phase 8/tracking stock; không tự sửa counter/backorder để né gate. |
| Các capability nâng cao | Các yêu cầu và scenario cũ được giữ trong ma trận. | Precision và traceability phase 5/8; credit phase 7; returns/refund phase 8; late-cash phase 6/9; I08 theo plan riêng. Chỉ được bật sau proof/ADR và quyền tương ứng. |

## Những điểm cần xử lý trước đóng phase 1

1. **UX:** [prototype](../assets/pos-wireframes.html) là dữ liệu giả, chưa được phê duyệt, không nối API. Prototype cũ còn hiển thị thẻ/kết hợp/công nợ là scope mở rộng, chưa thể hiện đầy đủ cảnh báo tồn không xác định và recovery online-first. Chỉ xin duyệt **bố cục cơ bản** hoặc cập nhật prototype trước khi duyệt hành vi; không coi nút mẫu là capability đã bật.
2. **Trạng thái tài liệu:** các bảng API mang tính contract/đề xuất, nhưng một số route đã có source; phân biệt rõ với chứng minh runtime/permission. Checkpoint phase 5 là lịch sử và có thể lạc hậu khi source thay đổi đồng thời.
3. **Trường hợp mất mạng sau nhận tiền:** đã xác định xử lý/đồng bộ lại khi có mạng, nhưng chưa xác định rõ người nào quyết định cho khách rời quầy khi đơn/tiền chưa được server xác nhận. Đây là quyết định vận hành cần chốt trước rollout, không tự ngầm suy diễn từ việc khách đang cầm hàng.

Không có test, migration, thay đổi dữ liệu hoặc thay đổi ứng dụng trong lượt rà soát này. Các bằng chứng lịch sử và acceptance chi tiết vẫn theo [phase 1](../phase-01-contracts-and-ux-validation.md), [handoff](./phase-01-04-handoff.md) và [runtime](./runtime-spike-results.md).
