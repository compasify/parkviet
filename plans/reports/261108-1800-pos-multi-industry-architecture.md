# Kiến trúc POS đa ngành hàng — đề xuất

- **Ngày:** 08/11/2026 · **Trạng thái:** đề xuất kiến trúc, đã chốt hướng (mục 10), chưa code.
- **Phạm vi hiện tại:** chỉ mở rộng **bán lẻ đa ngành** (13 ngành). F&B và các nhóm khác chỉ là định hướng để lõi không chặn đường mở rộng. F&B sẽ có plan riêng, chủ yếu là **app** chứ không chỉ web.
- **Đầu vào:**
  - [Báo cáo ngành hàng thị trường](261108-1700-pos-nganh-hang-thi-truong-research.md).
  - Phạm vi hiện tại: [product-and-architecture.md](../261101-1649-retail-pos-multi-store-multi-order/specs/product-and-architecture.md). Bản này ghi "không thêm F&B"; nếu đề xuất được duyệt thì cần ADR để đổi phạm vi.
  - Code hiện có: `server/app/{models,workflows,services}/spree/pos`, `apps/pos/src`.
- **Mục tiêu:**
  - Ngay từ đầu có danh sách đủ **13 ngành bán lẻ** và **6 ngành ăn uống – giải trí** để chủ shop chọn.
  - Làm dần theo module.
  - Về sau mở thêm được làm đẹp / sức khỏe và lưu trú mà không phải viết lại lõi.

---

## 1. Trả lời ngắn

**Có, nên hỏi ngành ngay khi khởi tạo shop.** Nhưng ngành chỉ là **hồ sơ cấu hình sẵn (profile)**, không phải "loại phần mềm" khóa cứng.

| Câu hỏi | Đề xuất |
|---|---|
| Chọn lúc nào? | Ở bước "Thiết lập cửa hàng" lần đầu: chọn nhóm → chọn ngành → xem trước các module sẽ bật → tạo chi nhánh đầu tiên. |
| Chọn để làm gì? | Bật module, đặt cấu hình mặc định, chọn màn bán (quét mã / lưới menu / sơ đồ bàn), thuật ngữ ("Hóa đơn 3" hay "Bàn 5"), mẫu in, đơn vị mẫu. |
| Có khóa không? | Không. Ngành gắn **theo chi nhánh**: chuỗi có thể có chi nhánh cafe cạnh chi nhánh bán lẻ. Đổi ngành về sau chỉ bật/tắt module, không xóa dữ liệu. |
| Ngành chưa làm xong thì sao? | Vẫn hiện trong danh sách, kèm nhãn **"Sắp hỗ trợ"** hoặc **"Bản cơ bản"**. Lựa chọn được lưu lại, để khi module sẵn sàng thì gợi ý bật. |
| Code có `if industry == 'cafe'` không? | **Không bao giờ.** Code chỉ hỏi "chi nhánh này có bật module X không". Ngành chỉ là một gói module + mặc định. |

Lý do không tách **lõi / backend** theo ngành: client thì được tách (F&B sau này là app, xem §7), nhưng ParkViet có một backend và một lõi tiền / ca / sổ quỹ đã làm rất kỹ (ReceivedFunds, công nợ, đóng ca, trả hàng). Mỗi ngành mà nhân bản lõi này là rủi ro tài chính lớn nhất. Ngoài ra, ngành lai rất phổ biến: tiệm bánh có chỗ ngồi, karaoke bán bia, căng tin bán cả tạp hóa, cây xăng kèm cửa hàng tiện lợi.

---

## 2. Các ngành khác nhau ở đâu: 6 trục

Ngành nào cũng là tổ hợp của 6 trục dưới đây. **Mỗi lựa chọn trên một trục là một module**, không phải một nhánh code riêng.

| Trục | Các lựa chọn | Đã có |
|---|---|---|
| **1. Đơn vị phục vụ** — cái gì giữ đơn đang mở | quầy / giỏ hàng · bàn ăn · tab theo khách (bar) · phòng / bàn chơi có đồng hồ · lịch hẹn (nhân viên × giờ) · phòng × đêm | quầy |
| **2. Vòng đời đơn** | trả ngay · trả trước rồi làm (cafe) · mở đơn, phục vụ dần, trả sau (nhà hàng, karaoke) · đặt trước / cọc · folio nhiều ngày | trả ngay |
| **3. Thực hiện** | giao tại quầy · gửi bếp / bar (phiếu bếp, KDS) · nhân viên làm dịch vụ · giao sau | giao tại quầy |
| **4. Tồn kho** | trừ thẳng variant · lô / serial · trừ theo công thức (định mức nguyên liệu) · không tồn (dịch vụ, giờ chơi) | thẳng, lô / serial |
| **5. Định giá** | đơn giá / cân / quy đổi · topping / tùy chọn · theo thời gian và khung giờ · theo đầu người · phí dịch vụ / phụ thu · bảng giá sỉ | đơn giá, cân, quy đổi |
| **6. Thuộc tính hàng** | biến thể size / màu · lô / HSD · serial / IMEI + bảo hành · đơn thuốc · kiểm tra tuổi | lô / HSD, serial |

**Điều bất biến:** dù đơn vị phục vụ là quầy, bàn hay phòng, cuối cùng vẫn là **Workspace → đúng một draft Order → tender → ReceivedFunds → complete**. Mọi ngành dùng chung một lõi tiền.

---

## 3. Kiến trúc: Lõi + Module + Hồ sơ ngành

```text
 Hồ sơ ngành (data, versioned)     tap_hoa · thoi_trang · nha_thuoc · ... · cafe · nha_hang · karaoke_bida
   = danh sách module + cấu hình mặc định + màn bán + thuật ngữ + mẫu in
                    │ áp vào chi nhánh
                    ▼
 Module (server + client, bật theo chi nhánh)
   Bán lẻ:  units · measured · traceability · warranty · deposits · wholesale · preorder_delivery · prescription
   F&B:     menu · kitchen · order_number · recipes · resources · tables · postpay · timed_billing · service_charge
   Sau này: appointments · packages · commissions · lodging
                    │ chỉ cắm vào qua các điểm mở rộng
                    ▼
 Lõi POS (không biết ngành)
   Branch · Register · Shift · Workspace(=1 draft Order) · SaleLine · Tender/ReceivedFunds/Allocation
   Credit · Returns/Refunds · Receipt template/snapshot · Approval · Audit · Capabilities · FeatureFlag · Reports
                    │
                    ▼
 Spree core: Order, LineItem, Price, Promotion, Fee, Stock, Fulfillment, Return
```

### 3.1 Lõi (giữ như hiện tại, chỉ thêm điểm mở rộng)

Lõi **không có** khái niệm bàn, bếp, phòng hay lịch hẹn. Ở lõi chỉ thêm:

1. `Workspace.service_mode`, kiểu chuỗi, mặc định `counter`. Giá trị phải thuộc danh sách các module đã đăng ký, ví dụ `table`, `tab`, `timed`. Dùng để chọn UI và bộ guard; không dùng cho logic tiền.
2. **Registry cho loại dòng hàng.** `SaleLine.kind` hiện suy ra từ `VariantUnit` (thường / cân / tracked). Đổi thành loại có handler đăng ký. Handler quy định:
   - cách tính giá;
   - merge key;
   - có sửa được không;
   - chính sách trả hàng;
   - tác động tồn kho.

   Các module thêm loại riêng: `menu_item` (có modifier), `timed` (giờ chơi), `cover` (buffet / vé vào cửa), `service` (dịch vụ có nhân viên).
3. **Hook pipeline cho workflow POS.** Workflow POS là class thuần chạy qua `CommandExecutor`, không phải `Spree::Workflow`, nên POS cần registry hook riêng. Các hook đề xuất:

   | Hook | Ví dụ dùng |
   |---|---|
   | `workspace.line.change.validate` | Cấm giảm món đã gửi bếp nếu không có lý do và quyền |
   | `workspace.complete.before` | `tracked_guard!` và pickup hiện đang viết cứng trong `Workspaces::Complete` sẽ chuyển thành hook của module bán lẻ |
   | `workspace.complete.after` | Trừ nguyên liệu theo công thức, đóng phiên bàn |
   | `workspace.cancel.after` | In phiếu hủy món |
   | `shift.close.blockers` | Bàn đang mở có tiền thì chặn đóng ca; bàn chưa có tiền thì được chuyển ca |
   | `receipt.data` | Thêm số bàn, số khách, nhân viên phục vụ, giờ vào / ra |
   | `workspace.serialize` | Ghép `extensions: { fnb: {...} }` vào `Workspace#to_pos` |
   | `reports.sources` | Báo cáo theo bàn, theo trạm bếp, báo cáo hủy món |

4. **Quyền và cờ lấy từ registry.** `Capabilities` và `FeatureFlag::FEATURES` hiện là danh sách cố định. Đổi thành *lõi + phần module khai báo thêm*. Ngữ nghĩa giữ nguyên như `FeaturePolicy`: tắt chỉ chặn lệnh mới; việc đang dở vẫn xử lý được.
5. **Schema mẫu in mở rộng được.** `ReceiptTemplateSchema` cho module đăng ký thêm field / block, ví dụ phiếu bếp, tem ly, số bàn.

### 3.2 Module

Một module là một gói có khai báo, gồm hai nửa server và client.

```ruby
# config/initializers/pos_modules.rb  (server)
Spree::Pos::Modules.register(
  key: 'fnb.kitchen',
  depends_on: %w[fnb.menu],
  capabilities: %w[pos.kitchen.view pos.kitchen.void_sent],
  features: %w[kitchen_void],                       # kill-switch riêng nếu cần
  settings: 'Spree::Pos::Fnb::KitchenSettings',     # schema + mặc định, validate khi lưu
  line_kinds: {},
  hooks: {
    'workspace.line.change.validate' => 'Spree::Pos::Fnb::GuardSentLines',
    'workspace.serialize'            => 'Spree::Pos::Fnb::KitchenExtension',
    'receipt.data'                   => 'Spree::Pos::Fnb::KitchenReceiptData'
  }
)
```

```ts
// apps/pos/src/modules/fnb-kitchen/index.ts  (client)
export const kitchenModule: PosModule = {
  key: 'fnb.kitchen',
  dependsOn: ['fnb.menu'],
  routes: [{ path: '/kitchen', lazy: () => import('./pages/kitchen-display') }],
  saleSlots: { lineBadge: SentBadge, actionBar: SendToKitchenButton },
  settingsPages: [{ key: 'kitchen-stations', lazy: () => import('./settings/stations') }],
  locales: { vi: () => import('./locales/vi.json'), en: () => import('./locales/en.json') },
};
```

Quy tắc cho module:

- **Dữ liệu ở bảng riêng** `spree_pos_<module>_*`, có FK tới bảng lõi. Không thêm cột riêng của ngành vào bảng lõi; ngoại lệ duy nhất là `service_mode`.
- **Namespace Ruby** `Spree::Pos::<Module>::`, đặt trong các thư mục Rails chuẩn (`app/models/spree/pos/fnb/…`). Không cần autoload path riêng.
- **Client lazy-load theo module.** Shop chỉ bán lẻ không tải code F&B.
- **Không đụng tiền trực tiếp.** Module muốn thu tiền thì đi qua tender của lõi. Muốn thêm khoản (phí dịch vụ, giờ chơi) thì thành dòng hàng hoặc Spree `Fee`. Không tạo Payment riêng.
- **Bật / tắt:**
  - bật theo từng chi nhánh;
  - module có dữ liệu đang mở (bàn đang mở, phiếu bếp chưa xong) thì không tắt được, chỉ chặn lệnh mới;
  - chỉ gỡ được khi không còn dữ liệu sống.
- **Test:** mỗi module có bộ test riêng. Ngoài ra có bộ **contract test của lõi**, chạy hai lần: tắt hết module và bật hết module.

### 3.3 Hồ sơ ngành (profile)

Profile là **dữ liệu trong code** (có version), không phải bảng cho merchant sửa. Server là nguồn duy nhất và gửi danh sách profile xuống client qua endpoint context / onboarding.

```yaml
cafe_tra_sua:
  group: fnb
  label: "Cafe, Trà sữa"
  status: coming_soon        # available | basic | coming_soon (tự suy từ module required đã sẵn sàng chưa)
  required: [fnb.menu, fnb.kitchen, fnb.order_number]
  recommended: [fnb.recipes, vietqr, customer_display]
  optional: [resources, fnb.tables]
  surface: menu_grid         # counter | menu_grid | floor_plan | tab_list | resource_board
  terminology: { workspace: "Đơn", workspace_numbered: "Đơn {n}" }
  defaults:
    fnb.kitchen: { print_cup_label: true, auto_send_on_pay: true }
    fnb.order_number: { reset: daily }
  receipt_templates: [sale_80mm_fnb, cup_label_40x30, kitchen_ticket]
  sample_units: []
```

Lưu trữ:

```text
spree_pos_store_profiles   store_id (unique), profile_key, profile_version, wholesale (bool), chosen_by, chosen_at
spree_pos_branches         + profile_key (null = theo store)
spree_pos_branch_modules   branch_id, module_key, enabled, settings jsonb, settings_version,
                           changed_by, reason, timestamps · unique(branch_id, module_key) · audit mọi thay đổi
spree_pos_workspaces       + service_mode (default 'counter')
```

Áp profile vào chi nhánh là một workflow có audit, gồm hai bước:

1. Tính **diff module**: bật gì, tắt gì, module nào không tắt được vì đang có dữ liệu mở.
2. Người quản lý xác nhận, rồi mới ghi.

`branch_modules` khác `FeatureFlag`:

- `branch_modules` là bật **dương** theo chi nhánh (chi nhánh cafe có, chi nhánh bán lẻ không) và có settings riêng.
- `FeatureFlag` vẫn là kill-switch rủi ro: store bật, chi nhánh chỉ được tắt.
- Một lệnh chỉ chạy được khi **module bật ở chi nhánh VÀ cờ (nếu module có cờ) đang bật**.

---

## 4. Danh mục ngành lúc khởi tạo

Hiện đủ 19 ngành. Thêm câu hỏi riêng **"Có bán sỉ không?"**, vì "bán buôn" là chiều cắt ngang mọi ngành bán lẻ chứ không phải một ngành.

Ký hiệu module: ✓ = đã có · ◐ = có một phần · **mới** = chưa có.

### 4.1 Bán buôn, bán lẻ: màn bán `counter`, dùng được ngay ở bản cơ bản

| Ngành | Module bật sẵn | Module nên có (lộ trình bán lẻ) | Mặc định đáng chú ý |
|---|---|---|---|
| Tạp hóa & Siêu thị | units ✓, measured ✓, credit ✓, vietqr ✓ | traceability (HSD) ✓ tùy chọn | Ưu tiên quét mã, quy đổi lốc/thùng, ghi nợ khách quen |
| Thời trang | returns ✓, exchanges ✓ | variant_grid (UI chọn size × màu), in tem mã vạch | Dạng thẻ có ảnh, hạn đổi trả 7 ngày |
| Điện tử & Điện máy | traceability serial ✓, returns ✓ | **warranty** (bảo hành theo IMEI), **deposits** (cọc / trả góp) | Bắt buộc quét serial |
| Vật liệu xây dựng | units ✓ (bao, m, m², tấn), credit ✓ | **wholesale**, **deposits** (thanh toán theo tiến độ), **preorder_delivery** (giao công trình) | Số lượng thập phân, hạn mức nợ |
| Nông sản & Thực phẩm | measured ✓, traceability lô/HSD ✓ | — | Tem cân, cảnh báo cận date |
| Nhà thuốc | traceability lô/HSD FEFO ✓, units ✓ (viên/vỉ/hộp) | **prescription** (đơn thuốc, liên thông dược) | FEFO bắt buộc, chặn bán hàng hết hạn |
| Xe & Máy móc | traceability serial ✓ (số khung/máy) | **warranty** + phiếu sửa chữa, **deposits** | — |
| Mỹ phẩm | traceability lô/HSD ✓ | variant_grid, (loyalty dùng của Spree nếu có) | — |
| Nội thất & Gia dụng | — | **deposits**, **preorder_delivery** (giao + lắp) | — |
| Mẹ & Bé | traceability lô/HSD ✓ | variant_grid | — |
| Sách & Văn phòng phẩm | units ✓ (ram/hộp) | **wholesale** (bán cho trường/công ty) | Tìm theo tên/ISBN |
| Hoa & Quà tặng | — | **preorder_delivery** (đặt trước, hẹn ngày giao, lời chúc) | — |
| Khác | lõi | tự chọn module | — |

Nhận xét: các ngành bán lẻ **chọn được ngay hôm nay** với trạng thái `available` hoặc `basic`. Các module còn thiếu đều là bổ sung, không chặn việc bán. Riêng `preorder_delivery` đụng vào bất biến hiện tại "giao ngay tại quầy, không giao sau", nên là module lớn, cần thiết kế riêng.

### 4.2 Ăn uống, giải trí: ngoài phạm vi hiện tại, chỉ hiện "Sắp hỗ trợ" ở onboarding

Bảng dưới là định hướng cho plan F&B sau này, không phải việc của đợt này. Lúc onboarding, shop chọn được ngành F&B để lưu lại nhu cầu, nhưng chưa tạo chi nhánh F&B được.

| Ngành | Màn bán | Module bắt buộc | Tùy chọn |
|---|---|---|---|
| Cafe, Trà sữa | `menu_grid` | menu (size / đường / đá / topping), kitchen (phiếu pha chế), order_number (gọi số, tem ly) | recipes, tables (nếu có chỗ ngồi, trả sau) |
| Căng tin & Trạm dừng nghỉ | `menu_grid` + quét mã | menu, kitchen, order_number; **dùng chung** units / measured của bán lẻ cho hàng đóng gói | recipes |
| Quán ăn | `menu_grid` hoặc `floor_plan` | menu, kitchen | tables + postpay (quán có bàn, trả sau), recipes |
| Nhà hàng | `floor_plan` | menu, kitchen (nhiều trạm, KDS), resources, tables, postpay, service_charge | recipes, đặt bàn, gọi món QR (sau) |
| Bar, Pub & Club | `tab_list` / `floor_plan` | menu, kitchen (trạm bar), postpay (tab theo khách), service_charge (vé vào cửa / phụ thu) | tables |
| Karaoke, Bida | `resource_board` | resources, **timed_billing** (giờ chơi, giá theo khung giờ), menu, postpay | kitchen, deposits (cọc phòng) |

---

## 5. Các module F&B: ánh xạ vào lõi và Spree (định hướng, cho plan F&B sau)

Mục này chỉ để kiểm tra các điểm mở rộng ở mục 3 có đủ cho F&B hay không. Không code trong đợt này.

| Module | Thực thể mới | Cách cắm vào lõi / Spree |
|---|---|---|
| `fnb.menu` | `ModifierGroup` (min/max, bắt buộc), `Modifier` (giá cộng thêm, variant nguyên liệu tùy chọn), `ProductModifierGroup`, `Combo` | Món là Spree Product, phần lớn `track_inventory: false`. Thêm SaleLine kind `menu_item` với snapshot modifier; server tính giá dòng = giá gốc + Σ modifier, qua seam giá thủ công trên draft giống `override_price`, client không gửi giá. Merge key gồm bộ modifier và ghi chú, nên hai ly khác topping là hai dòng (SaleLine đã hỗ trợ). |
| `fnb.kitchen` | `KitchenStation`, `ProductStationRoute`, `KitchenTicket` (mỗi lần "gửi bếp" là một bản bất biến), `KitchenTicketItem` (sale_line, số lượng, trạng thái sent → preparing → ready → served / voided) | Gọi thêm món tạo ticket mới. Giảm hoặc xóa món đã gửi cần lý do, quyền `pos.kitchen.void_sent`, audit và phiếu hủy (hook `line.change.validate`). Có hai chế độ: in phiếu theo trạm hoặc màn KDS. |
| `fnb.order_number` | Bộ đếm theo chi nhánh × ngày | Số gọi in trên bill và tem ly; màn khách hiện số đang gọi (tái dùng customer display). |
| `fnb.recipes` | `Recipe` (variant, version), `RecipeComponent` (variant nguyên liệu, base_quantity theo `UnitDefinition` g / ml) | Hook `complete.after` ghi stock movement nguyên liệu tại kho chi nhánh **qua workflow tồn của Spree**, idempotent theo order + sale line. Spree vẫn là bên duy nhất ghi số tồn tổng. Trả món thường không nhập lại kho. |
| `resources` (dùng chung) | `ResourceArea`, `Resource` (loại: table / room / billiard / chair / bed…, sức chứa), `ResourceSession` (resource, workspace, opened_at, closed_at, guests) | Mỗi resource chỉ có một session đang mở (unique partial index). **Đây là móng để sau này mở spa và khách sạn.** |
| `fnb.tables` | — (dùng `resources`) | Sơ đồ bàn mở ra workspace `service_mode=table`. Lệnh chuyển bàn, gộp bàn, tách bill (chuyển sale line sang workspace mới), số khách. Chỉ cho tách / gộp **trước khi có tiền**, đúng quy tắc khóa snapshot hiện có. |
| `fnb.postpay` | Chính sách chuyển ca | Đơn mở dài, qua nhiều ca. Workspace chưa có tiền được rebind sang ca mới (`ShiftRebind` đã có). Có tiền một phần thì chặn đóng ca (hook `shift.close.blockers`). Bar tab = workspace `service_mode=tab` gắn khách thay vì bàn. |
| `timed_billing` | `RatePlan` (khung giờ, ngày thường / cuối tuần, làm tròn phút, tối thiểu), `Meter` (start / pause / stop gắn ResourceSession) | SaleLine kind `timed`. Giá do server tính lại từ meter đến khi chốt; khi bắt đầu thu tiền thì đóng băng (khóa snapshot). |
| `service_charge` | Cấu hình % hoặc số tiền, vé vào cửa | Dùng Spree `Fee` (kind `surcharge`). Vé vào cửa / buffet là SaleLine kind `cover`. Tip là chính sách chưa chốt (doanh thu hay khoản phải trả nhân viên). |

---

## 6. Mở rộng sau này: làm đẹp, sức khỏe, lưu trú

Phần này đã có móng; khi làm chỉ cần thêm module, không sửa lõi.

| Nhóm | Module | Dựa trên |
|---|---|---|
| Spa, salon, nail, gym | `appointments` (lịch, nhân viên × resource × khung giờ, chống trùng), `packages` (liệu trình / gói tập trả trước), `commissions` (hoa hồng theo dòng) | `resources` (ghế, giường, phòng); `packages` là khoản nợ phải trả khách, có thể tái dùng store credit / gift card của Spree; SaleLine kind `service` gắn nhân viên |
| Phòng khám | `appointments` + hồ sơ bệnh nhân + kê đơn | Nên là sản phẩm riêng, POS chỉ thu tiền |
| Khách sạn, homestay | `lodging` (folio nhiều đêm, giá phòng × đêm, OTA, CCCD) | `resources` (phòng) + workspace folio. **Khuyến nghị làm app PMS riêng dùng chung lõi tiền**, không nhét vào màn bán POS |

---

## 7. Chuẩn bị cho nhiều loại client (app F&B sau này)

F&B sau này chủ yếu là **app** (máy phục vụ cầm tay, tablet bếp, máy quầy), không chỉ là web. Hướng chốt là: **một backend, một lõi tiền, nhiều client**. Tách client là được, tách lõi theo ngành thì không. Ngay đợt bán lẻ này cần giữ mấy nguyên tắc để app sau không phải chép lại logic:

1. **Luật nghiệp vụ chỉ nằm ở server.** Hiện đã đúng: giá, giảm giá, khóa snapshot, đủ tiền, đóng ca đều do server quyết. Phép tính ở client, như chia phương thức thanh toán (`payment-split.ts`) hay tiền thừa, chỉ để hiển thị; server luôn kiểm lại.
2. **Danh mục ngành, module, quyền, cờ, schema settings và thuật ngữ đều do server trả về qua API.** Client không giữ hằng số; hiện `pos-features.ts` và `pos-capabilities.ts` vẫn đang là hằng số, cần đổi. Client gặp module chưa biết thì chỉ ẩn phần UI đó; server vẫn chặn lệnh.
3. **Dữ liệu mở rộng trong DTO** đặt dưới `extensions.<module_key>`, có `schema_version`, và được ghi vào OpenAPI của POS. App và web đọc cùng một hợp đồng.
4. **In qua adapter.** `PrintAdapter` (`apps/pos/src/lib/print-adapter.ts:100`) đã là interface; bản đầu tiên là adapter trình duyệt. Nội dung phiếu đã chốt là snapshot ở server. App sau này chỉ cần thêm adapter ESC/POS qua Bluetooth/LAN. In bếp **chưa làm, chưa chọn công nghệ**; đợt này chỉ cần không phá vỡ ranh giới "dữ liệu in từ server, cách in do client".
5. **Đăng nhập trên app khác web.** Hiện dùng JWT trong memory cộng refresh cookie HttpOnly, gắn với origin, hợp với web. App native cần refresh token trong secure storage và định danh thiết bị gắn với quầy. Ghi lại để plan F&B kiểm chứng; đợt này không đổi.
6. **Realtime.** Hiện POS poll. Nhiều thiết bị cùng một bàn hoặc bếp có thể cần push (SSE / WebSocket). Để plan F&B quyết định; đợt này không đổi.

---

## 8. Giai đoạn 0: nền mở rộng cho bán lẻ đa ngành (phạm vi hiện tại)

Giai đoạn này không đổi hành vi của shop đang chạy. Chỉ làm những gì 13 ngành bán lẻ cần ngay; phần chỉ phục vụ F&B thì chưa làm (YAGNI).

| # | Việc | Ghi chú |
|---|---|---|
| 1 | **Registry module + hồ sơ ngành** ở server; bảng `store_profiles`, `branch_modules` | Backfill: chi nhánh hiện có → profile `khac`, bật các module đang dùng (units, measured, traceability…). Feature flag giữ nguyên. |
| 2 | **13 profile bán lẻ** + 6 profile F&B ở trạng thái `coming_soon` | Mỗi profile có module bật sẵn, mặc định chi nhánh (hạn trả hàng, cách chọn lô, FEFO bắt buộc…), đơn vị mẫu, kiểu hiển thị danh mục (thẻ có ảnh / danh sách / ưu tiên quét). |
| 3 | **Wizard thiết lập** khi store chưa có chi nhánh POS: chọn nhóm → ngành → "có bán sỉ?" → xem trước → tạo chi nhánh / kho / quầy | Dùng lại workflow topology hiện có. Ngành F&B chỉ lưu lại nhu cầu, chưa tạo chi nhánh được. |
| 4 | **Cấu hình → Chi nhánh → Mô hình kinh doanh** | Đổi profile: hiện diff module, chặn tắt module đang có dữ liệu mở, có audit. |
| 5 | ~~Hook pipeline~~ **Hoãn** tới module đầu tiên cần đến (dự kiến `warranty`) | Khi đọc code: `tracked_guard!` chạy ở 4 đường tiền (`tenders/prepare`, `tenders/confirm`, `funds/allocate`, `workspaces/complete`). Nó là bất biến theo dữ liệu SKU, nên **không được** biến thành hook tắt theo module. Giai đoạn 0 không có module nào dùng hook, nên không đáng đụng vào đường tiền. |
| 6 | **Quyền và cờ lấy từ registry**, client nhận danh sách từ server | Theo §7.2. |
| 7 | **Client `src/modules/` + registry**; màn bán hiện tại là surface `counter` | Thuật ngữ và kiểu hiển thị danh mục lấy từ profile. |

**Module không chặn việc bán.** Tắt module chỉ ẩn màn cấu hình và từ chối lệnh thiết lập mới; bán, trả hàng và các guard theo dữ liệu SKU luôn chạy. Plan chi tiết: [261108-1830-pos-ban-le-da-nganh](../261108-1830-pos-ban-le-da-nganh/plan.md).

**Chưa làm trong giai đoạn 0, để plan F&B:** registry SaleLine kind, `Workspace.service_mode`, slot `extensions` trên màn bán, module `resources`. Mục 3.1 vẫn giữ để thiết kế không chặn chúng.

---

## 9. Lộ trình

### 9.1 Phạm vi hiện tại: bán lẻ

| Thứ tự | Module | Ngành hưởng lợi | Ghi chú |
|---|---|---|---|
| 0 | Nền mở rộng (§8) | Cả 13 ngành | — |
| 1 | `wholesale`: bảng giá theo nhóm khách, dùng price list của Spree | VLXD, sách / VPP, tạp hóa, mọi shop "có bán sỉ" | Ít rủi ro, dùng pricing của Spree |
| 2 | `variant_grid`: chọn size × màu nhanh, in tem mã vạch | Thời trang, mỹ phẩm, mẹ & bé | Chủ yếu là UI |
| 3 | `warranty`: phiếu bảo hành theo serial / IMEI, tra bảo hành, phiếu sửa chữa | Điện máy, xe & máy móc | Dựa trên SerialUnit đã có |
| 4 | `deposits` + `preorder_delivery`: đặt cọc, thanh toán nhiều đợt, đặt trước, giao sau | Nội thất, VLXD, hoa & quà, điện máy | **Phá vỡ bất biến "giao ngay tại quầy"**, nên cần ADR và thiết kế riêng (tiền cọc, giữ hàng, hủy cọc) |
| 5 | `prescription`: đơn thuốc, liên thông dược quốc gia | Nhà thuốc | Có yếu tố pháp lý; cần khảo sát quy định trước |

### 9.2 Ngoài phạm vi hiện tại: chỉ định hướng, mỗi mục có plan riêng

| Nhóm | Hướng |
|---|---|
| F&B (app) | Trả trước tại quầy → có bàn / trả sau → tính giờ (karaoke, bida). Ánh xạ module xem §5. |
| Làm đẹp, sức khỏe | appointments, packages, commissions (§6) |
| Lưu trú | App PMS riêng, dùng chung lõi tiền |

---

## 10. Rủi ro

### 10.1 Của đợt bán lẻ

1. **Tách guard của `Workspaces::Complete` thành hook** là sửa trên đường tiền. Phải giữ đúng thứ tự kiểm tra và chạy lại toàn bộ test request / e2e `full-retail` trước và sau khi tách.
2. **Backfill chi nhánh cũ.** Profile `khac` phải bật đúng các module mà chi nhánh đang dùng, không được làm tắt tính năng đang chạy. Cần test migration trên dữ liệu có traceability, cân và công nợ.
3. **Điểm vào của wizard.** Cần xác minh luồng tạo store / chi nhánh hiện tại (Spree admin hay trang topology của POS) để wizard không tạo thêm một đường tạo chi nhánh thứ hai.
4. **Profile chỉ là mặc định.** Đổi profile không được ghi đè cấu hình mà quản lý đã chỉnh tay (ví dụ hạn trả hàng). Chỉ áp mặc định cho giá trị còn trống, hoặc hiện diff để quản lý chọn.
5. `deposits` / `preorder_delivery` và `prescription` (xem §9.1) cần ADR hoặc khảo sát riêng, không gộp vào giai đoạn 0.

### 10.2 Ghi chú để dành cho plan F&B (chưa xử lý)

- In bếp / KDS trên app, nhiều máy in theo trạm.
- Chuyển dòng giữa các order khi tách / gộp bàn (seam upsert gộp theo variant).
- Trừ nguyên liệu theo công thức qua kho Spree, idempotent.
- Đơn mở qua đêm, qua ca; nhiều phục vụ sửa cùng một bàn.
- Offline cho bếp; đăng nhập và định danh thiết bị trên app; push realtime.
- Chính sách: tip, phí dịch vụ trước / sau thuế, làm tròn giờ chơi, hủy món đã nấu.
- Đổi phạm vi trong `product-and-architecture.md:6,36` ("không F&B") khi bắt đầu plan F&B.

---

## 11. Quyết định đã chốt (08/11/2026)

1. Ngành là **profile theo chi nhánh**, chọn ở onboarding, không khóa. Danh sách hiện đủ 19 ngành; ngành chưa hỗ trợ có nhãn "Sắp hỗ trợ".
2. **Một backend, một lõi tiền / ca / sổ quỹ cho mọi ngành.** Client được phép tách: web cho bán lẻ, app cho F&B. Module không tự tạo Payment.
3. **Phạm vi hiện tại chỉ là bán lẻ đa ngành:** giai đoạn 0 (§8) rồi các module bán lẻ (§9.1).
4. **F&B có plan riêng sau**, chủ yếu dạng app. Lõi chỉ cần giữ các nguyên tắc ở §3.1 và §7 để không chặn đường.
5. **In bếp chưa hỗ trợ và chưa chọn công nghệ.** Giữ ranh giới `PrintAdapter` để mở rộng sau.
6. Lưu trú, nếu làm, là app riêng.

