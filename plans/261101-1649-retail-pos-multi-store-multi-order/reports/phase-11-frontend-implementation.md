# Phase 11 frontend: cờ tính năng, e2e toàn luồng, chaos, hàng truy xuất, a11y, đo UI

Trạng thái: đã triển khai, chưa commit. Không sửa `server/` (ngoài file tạm đã xóa trong `server/log/`), không đổi ô trạng thái plan.

## 1. Cờ tính năng (khớp hợp đồng backend cuối)

- `GET /pos/context` → `features` được chuẩn hóa (`src/lib/pos-features.ts`): không có `features` = không ẩn gì (server cũ); có `features` thì chỉ `true` mới bật (thiếu/sai kiểu = tắt).
- Điểm vào bị khóa kèm lý do tiếng Việt (`components/feature-off-note.tsx`, `aria-describedby`): nút **Ghi nợ** (credit); lập phiếu trả mới và nút trả hàng ở chi tiết đơn (returns); form yêu cầu hoàn tiền (refunds); **Đổi hàng** (exchanges); tồn đầu kỳ/đưa vào theo dõi (traceability — nhập/chuyển/kiểm kê vẫn mở, đúng bảng backend); kết nối/ghim/mã ghép/kết nối lại màn hình khách (customer_display — xóa/ngắt vẫn mở); **Thu/chi tiền mặt** (cash_moves); **Xuất CSV** (exports — tải file cũ vẫn mở).
- Đường phục hồi luôn mở: khoản thu cần chú ý, hóa đơn, phiếu trả đã lập (nhận/hủy), hoàn tiền đã yêu cầu (chi/hủy/ghi kết quả), đơn đổi đã mở, xác nhận yêu cầu thu chi, đóng ca, báo cáo.
- 409 `feature_disabled` (+ `details.feature`) → câu tiếng Việt riêng từng tính năng (`featureDisabledText` trong `describeFailure` và `describeShiftFailure`); mọi refusal đó làm mới context (`lib/app-session.ts`) nên điểm vào tự khóa ngay.
- Trang **Chức năng chi nhánh** (`/settings/branches/$branchId/features`): `GET /pos/feature_flags?branch_id=` (đọc `switches.{store, branch_override, effective}`, vẫn đọc dạng cũ), `PUT /pos/feature_flags/:feature` với lý do bắt buộc. Quản trị cửa hàng (`write_pos_topology`): bật/tắt cấp cửa hàng và **Bỏ tắt tại chi nhánh**. Quản lý chi nhánh (`pos.topology.manage`, vào từ menu, không cần quyền Cấu hình): chỉ **Tắt tại chi nhánh này**. Mỗi dòng hiện trạng thái cửa hàng, chi nhánh và lý do tắt (cửa hàng chưa bật / tắt tại chi nhánh), người đổi cuối, thời điểm, lý do.

## 2. Mục từ README review: tiền mặt khi không có ca

Server: tender/hoàn tất trên ca của đơn → 409 `shift_closed` (`Tenders::Guard.validate_open_shift!`); chi hoàn tiền mặt → 409 `shift_required` (`Refunds::ConfirmPayout.open_drawer!`); thu nợ (mọi hình thức) → 409 `shift_required` (`Collections::Receive`). UI nay chặn trước kèm lý do: khung thanh toán khi ca của đơn không mở/không phải của mình (Thanh toán, Ghi nợ, Hoàn tất bị khóa; `paymentNeedsOpenShift`), nút **Xác nhận chi** của hoàn tiền mặt, nút **Thu nợ**. `shift_closed` có câu tiếng Việt.

Thay đổi khác theo backend: replay mất phản hồi của lệnh tạo nháp bị 403 thì UI ngừng thử lại, làm mới danh sách nháp và giải thích (`DraftReplayRefused`); backend nay trả kết quả đã lưu nên đây chỉ còn là đường phòng hờ (vd. membership bị gỡ).

## 3. E2E (mock, 3 viewport) và chạy với API thật

Mock dùng chung `e2e/support/retail-api.ts`: server trong bộ nhớ, chung cho nhiều page/context, ghi mọi lệnh theo idempotency key (replay trả kết quả cũ), kiểm revision/lease, đếm hiệu ứng thật (tiền két, phiếu thu, xuất kho, hoàn kho, serial), tiêm lỗi theo họ lệnh (mất phản hồi sau khi commit, trễ, mất mạng, hết phiên), cờ tính năng theo cửa hàng/chi nhánh.

| Spec | Test (mỗi viewport) | Nội dung |
|---|---|---|
| `full-retail.spec.ts` | 3 + 1 live | W01 A chờ CK/B tiền mặt/C quét; ngày đầy đủ: ghi nợ 200k có duyệt, thu nợ 150k, trả 1 bao + hoàn tiền mặt + đổi hàng, nhận CK chờ, đếm mù két = 650k khớp hiệu ứng tiền; reload/mất mạng chập chờn/hết phiên/logout không mất đơn, không thu hai lần |
| `concurrency-chaos.spec.ts` | 5 + 1 live | hai browser cùng đơn (takeover, trang cũ bị từ chối, không lost update); mất phản hồi ở quét, chuẩn bị/xác nhận tiền, hoàn tất, giao hàng, thu nợ, lập phiếu trả, yêu cầu/chi hoàn tiền, đổi hàng, đếm két, đóng ca → mỗi họ đúng 1 hiệu ứng, 1 key; 100 lần quét nhanh đúng 100 dòng/lượt, revision tuần tự, 0 conflict; phản hồi đảo thứ tự giữa hai tab và đọc chậm không ghi đè bản mới |
| `advanced-goods.spec.ts` | 1 + 1 live | 2 tem cân cùng thịt = 2 dòng; 2 serial; 3 hộp lô FEFO L-01×2 + L-02×1; giao hàng; trả 200 g gói 1 + SN-2 + 1 hộp L-02 đúng nguồn gốc, hoàn kho từng dòng, SN-2 không trả lại được lần hai |
| `feature-flags.spec.ts` (mới) | 5 | khóa điểm vào + đường phục hồi; refusal khi vừa bị tắt; quản trị cửa hàng/quản lý chi nhánh; chặn thu tiền/chi hoàn/thu nợ khi không có ca |
| `accessibility.spec.ts` (mới) | 4 (desktop) | tên truy cập mọi control (bán hàng, hộp thanh toán, trang cờ); bàn phím: skip link → ô tìm, focus giữ trong hộp thoại, Escape trả focus; zoom 200% (640 px) và 375 px không cuộn ngang, CTA chạm được |

**API thật** (`POS_LIVE_REVIEW=1`, `POS_LIVE_FIXTURE`, fixture tổng hợp mới tạo bằng `e2e/support/pos-live-fixture.rb`): cả 3 journey **pass** trên dev ngày 07/11/2026, fixture `34f830628a`:
- chaos: thêm hàng và xác nhận tiền mặt bị mất phản hồi sau khi server commit → phục hồi bằng key, API cho 1 dòng, 1 attempt confirmed, `allocated` đúng (47,9 s);
- advanced-goods: cấu hình mẫu tem/đơn vị/serial/lô + tồn đầu kỳ qua API, bán tem 500 g + 2 serial + 3 hộp FEFO, giao hàng, trả một phần; API xác nhận lô `[L1×2, L2×1]` và `restocked_quantity` từng dòng (1,3 phút);
- full-retail: bán có tiền thừa, đơn trong lịch sử với `paid` đúng, trả 1 + hoàn tiền mặt, đếm mù và đóng ca khớp (1,5 phút).
Các lỗi gặp khi chạy thật đều do test/fixture (đăng nhập bị rate limit 429, API dev chậm, branch thiếu `return_window_days`, nháp đã thu tiền còn mở chặn đóng ca — server chặn đúng); đã sửa test/fixture. Một lần dev trả 500 "Migrations are pending" (đã báo coordinator, coordinator migrate lại).

## 4. Accessibility — lỗi thật đã sửa

Đóng hộp thanh toán bằng Escape/"Để chờ" làm mất focus về body vì nút mở ("Thanh toán") bị khóa khi đã có khoản chuẩn bị; nay focus chuyển sang **Tiếp tục thanh toán** (`payment-panel.tsx`). Không cài thư viện audit (không có `@axe-core/playwright`); chưa thử screen reader thật.

## 5. Đo UI (`tests/performance/pos-scenarios.ts`, `pnpm test:perf`)

Đo bằng `performance.mark/measure` trong trang, JSON ở `test-results/perf/pos-scenarios.json`. Lần chạy duy nhất: API mock, máy dev, 20 mẫu, chỉ phía trình duyệt — p50/p95 (ms): chuyển tab 13,3/27,9; tìm hàng 14,6/16,4; tạo nháp 20,2/36,1; xác nhận tiền mặt 51,9/97,8. Không phải năng lực hệ thống; chế độ `POS_PERF_LIVE=1` chưa chạy.

## 6. Tài liệu (thư mục này)

[security-review.md](./security-review.md), [operations-runbook.md](./operations-runbook.md), [release-checklist.md](./release-checklist.md) (kết luận NO-GO cho tiền thật), [traceability-uat.md](./traceability-uat.md), [capacity-baseline.md](./capacity-baseline.md). `apps/pos/README.md`: mục developer (live run, `test:perf`) và giới hạn về cờ tính năng.

## 7. File

Tạo: `src/lib/pos-features.ts`, `src/lib/pos-features.test.ts`, `src/components/feature-off-note.tsx`, `src/hooks/use-branch-features.ts`, `src/pages/settings/branch-features.tsx`, `e2e/support/retail-api.ts`, `e2e/support/live.ts`, `e2e/support/pos-live-fixture.rb`, `e2e/full-retail.spec.ts`, `e2e/concurrency-chaos.spec.ts`, `e2e/advanced-goods.spec.ts`, `e2e/feature-flags.spec.ts`, `e2e/accessibility.spec.ts`, `tests/performance/pos-scenarios.ts`, `tests/performance/playwright.config.ts`, 6 báo cáo trong `reports/`.

Sửa: `src/lib/{request-failure,shifts,pos-context,app-session,receivables}.ts`, `src/hooks/{use-pos-context,use-workspaces}.ts`, `src/components/{payment-panel,display-pin-control,refund-actions,workspace-tabs,pos-shell}.tsx`, `src/pages/{return-exchange,orders,shifts,reports,inventory-traceability,receivables}.tsx`, `src/pages/settings/{branch-settings,topology}.tsx`, `src/router.tsx`, `src/locales/{vi,en}.json`, `package.json` (`test:perf`), `README.md`; mock của `e2e/returns-exchanges.spec.ts` và `e2e/credit-collections.spec.ts` thêm `branch_id` vào shift (đúng context thật). `playwright.config.ts` không đổi.

## 8. Kết quả kiểm tra (07/11/2026, `POS_TEST_PORT=5177`)

- `biome check .` sạch; `tsc --noEmit` sạch; `vite build` ok.
- Vitest: 25 file, **166 test pass** (thêm 9 cho cờ tính năng/refusal).
- Playwright toàn bộ: **310 pass, 23 skip** (9 live của 3 spec mới, 6 live cũ, 8 a11y chỉ chạy desktop), 333 test, 2,6 phút. Các lượt trước có fail thoáng qua khi tôi sửa file giữa lượt chạy/tải cao; đã sửa race trong helper `openTab` và nới timeout test 100 lần quét; lượt cuối sạch.
- Live: 3/3 pass (mục 3).

## 9. Việc còn mở

1. UAT thiết bị và truy xuất trên hàng thật; screen reader thật; đo hiệu năng trên LAN staging (`POS_PERF_LIVE=1`) và tải nhiều quầy.
2. Hạ tầng (domain, CORS/SameSite/CSP) và pentest độc lập; sign-off chính sách và bật cờ production.
3. Dev: test live đã bật mặc định cấp **cửa hàng** cho `returns`, `refunds`, `traceability` (qua `PUT /pos/feature_flags`, có nhật ký) — ảnh hưởng mọi chi nhánh của store dev; quyết định giữ hay tắt lại. Ba fixture tổng hợp `POS Live 2672a14c4a`, `1e668b3b4f`, `34f830628a` (chi nhánh, quầy, 2 nhân viên `pos-live-*@example.test`, sản phẩm, đơn thử; hai fixture đầu còn ca mở và đơn dở) — nên vô hiệu nhân viên sau đợt thử. File credential nằm ngoài repo (scratchpad của phiên).
4. Đổi kiểu theo dõi serial/lô trong trang "Đơn vị và mã tem" chưa khóa trước theo cờ `traceability` (server từ chối, UI hiện câu tiếng Việt).
5. Khi đang mất mạng, nút **Kết thúc** của hộp thanh toán vẫn bấm được (lệnh không tới server, không ghi gì; khi có mạng bấm lại dùng đúng key). Có thể khóa sớm theo trạng thái mạng nếu muốn.
