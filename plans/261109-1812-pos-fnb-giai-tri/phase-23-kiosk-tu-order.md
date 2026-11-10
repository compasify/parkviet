---
phase: 23
title: "Kiosk tự order"
status: pending
effort: "5 ngày"
dependsOn: [5, 12]
---

# Phase 23: Kiosk tự order (S7)

## Overview

Một tablet hoặc màn đứng chạy app Flutter ở chế độ `kiosk`. Khách tự chọn món và modifier, trả bằng VietQR hoặc chọn "Trả tại quầy", rồi nhận số gọi in qua trạm in. Đây là ngoại lệ có kiểm soát của D7: kiosk được hoàn tất đơn **chỉ khi** webhook VietQR đã khớp; mọi trường hợp khác đều để thu ngân xử lý.

## Quyết định của phase

| # | Quyết định |
|---|---|
| Q1 | Mỗi kiosk là một `Device` mode `kiosk`, gắn **một quầy (`Register`) riêng** loại kiosk. Lõi hiện chỉ cho một ca mở mỗi quầy (`Shift#one_open_shift`) và ca phải có `owner` là nhân viên, nên kiosk không tự mở ca. Quản lý mở **ca kiosk** cho quầy kiosk (owner là quản lý), ca không có tiền mặt (`opening_float = 0`, không nhận tender tiền mặt). Kiosk từ chối nhận đơn khi quầy của nó không có ca mở và hiện "Tạm ngưng". |
| Q2 | Lệnh của kiosk chạy dưới **tài khoản dịch vụ của thiết bị**: mỗi kiosk có một `StaffMembership` hệ thống (cờ `service_account: true`), chỉ có các quyền: tạo workspace, thêm dòng menu, chuẩn bị và xác nhận tender VietQR có bằng chứng webhook, park. Không có quyền giảm giá, sửa giá, tiền mặt, hủy, trả hàng. `AuditEntry` ghi actor là tài khoản này kèm `device_id`. |
| Q3 | Xác nhận VietQR từ kiosk chỉ chấp nhận `evidence_kind = vietqr_webhook` (đã có trong `VietqrTender::EVIDENCE_KINDS`). `vietqr_manual` bị chặn cho tài khoản dịch vụ. Hết hạn QR mà chưa khớp thì hủy tender, giải phóng QR, và đơn chuyển sang "trả tại quầy". |
| Q4 | "Trả tại quầy": kiosk park workspace (`ChangeStatus` park) kèm số gọi và chuyển nó sang ca của quầy thu ngân khi thu ngân mở đơn (dùng `ShiftRebind` đã có cho draft chưa có tiền). Bếp **chưa nhận** món cho tới khi thu ngân thu tiền, trừ khi chi nhánh bật "báo bếp trước khi trả" (mặc định tắt). |
| Q5 | Khóa máy: Android dùng **lock task mode** (Device Owner qua QR provisioning, hoặc screen pinning nếu không có Device Owner); iOS dùng **Guided Access**, app hướng dẫn bật và kiểm tra `UIAccessibility.isGuidedAccessEnabled`, hiện cảnh báo cho quản lý nếu tắt. Thoát chế độ kiosk cần PIN quản lý. |
| Q6 | Module `fnb.kiosk` (research §5.2), phụ thuộc `fnb.menu`, `fnb.order_number`; feature `vietqr` phải bật để kiosk nhận trả QR. |

## Dữ liệu

- `spree_pos_registers`: thêm `kind` (`counter` | `kiosk`, mặc định `counter`).
- `spree_pos_staff_memberships`: thêm `service_account` (boolean, mặc định false) và `device_id` (optional). Tài khoản dịch vụ không đăng nhập bằng mật khẩu / PIN; chỉ dùng qua credential thiết bị.
- `spree_pos_workspaces`: dùng `order_source = 'kiosk'` (thêm vào `Workspace::ORDER_SOURCES`) để báo cáo theo nguồn đã có (`Reports::Sales#by_source`) tách được doanh thu kiosk.
- Cấu hình chi nhánh: `kiosk_idle_seconds` (mặc định 60), `kiosk_kitchen_before_payment` (mặc định false), `kiosk_qr_timeout_seconds` (mặc định 180).

## Server

- `Spree::Pos::Kiosks::Provision`: khi ghép thiết bị mode `kiosk` (phase 2), tạo tài khoản dịch vụ và gắn quầy kiosk; thu hồi thiết bị thì vô hiệu tài khoản.
- `Spree::Pos::Kiosks::Policy`: chặn mọi lệnh ngoài danh sách cho actor là tài khoản dịch vụ (kiểm trong `AccessPolicy`), kể cả khi capability bị gán nhầm.
- Luồng thanh toán QR: kiosk gọi `tenders/prepare` như thu ngân; kiosk nghe `workspace.updated` trên `BranchChannel` (hoặc poll 2 giây) để biết webhook đã khớp; khi `VietqrTender.summary` báo đã nhận, kiosk gọi `tenders/confirm` với evidence webhook, rồi `complete`. Sau complete: cấp số gọi (phase 10), tạo `PrintJob` loại `receipt` cho trạm in gắn quầy kiosk, gửi bếp như đơn trả trước (phase 9).
- Endpoint `GET api/v3/admin/pos/kiosk/state`: ca có mở không, thực đơn đang bán, cấu hình idle.
- Đơn kiosk park chưa trả quá 30 phút: job đánh dấu và hiện cho thu ngân "Đơn kiosk bỏ dở" để hủy.

## Flutter (`apps/pos-staff`, chế độ `kiosk`)

- Luồng màn: Chào → Danh mục / lưới món ảnh lớn → Modifier (dùng lại widget modifier của chế độ phục vụ) → Giỏ → Chọn cách trả (QR / Tại quầy) → QR đếm ngược → Thành công kèm số gọi lớn → tự quay về Chào.
- Idle reset: không chạm sau `kiosk_idle_seconds` thì hỏi "Bạn còn đó không?" 10 giây rồi xóa giỏ; workspace chưa có tender thì cancel.
- Trợ năng: chữ tối thiểu 20 sp, vùng chạm ≥ 64 dp, tương phản AA, hỗ trợ TalkBack / VoiceOver nhãn đầy đủ, chế độ "với tới thấp" dồn nút xuống nửa dưới màn, chuyển vi / en.
- Lock task: platform channel `parkviet/kiosk` (Kotlin: `startLockTask` / `stopLockTask`; Swift: kiểm Guided Access). Giữ màn hình sáng (`wakelock_plus`).
- Lỗi mạng: giữ giỏ, hiện "Đang kết nối lại", không cho thanh toán khi mất kết nối server.

## Client web `apps/pos`

- Cài đặt chi nhánh: quầy kiosk, mở / đóng ca kiosk, cấu hình idle / timeout / báo bếp trước.
- Màn đơn đang chờ: lọc "Từ kiosk", mở đơn kiosk park để thu tiền.

## File

| File | Hành động |
|---|---|
| `server/db/migrate/*_add_kind_to_spree_pos_registers.rb`, `*_add_service_account_to_staff_memberships.rb` | Tạo |
| `server/app/workflows/spree/pos/kiosks/provision.rb`, `server/app/services/spree/pos/kiosks/policy.rb` | Tạo |
| `server/app/services/spree/pos/access_policy.rb` | Sửa: chặn tài khoản dịch vụ ngoài danh sách |
| `server/app/workflows/spree/pos/tenders/confirm.rb` | Sửa: tài khoản dịch vụ chỉ được evidence `vietqr_webhook` |
| `server/app/models/spree/pos/workspace.rb` | Sửa: `ORDER_SOURCES` thêm `kiosk` |
| `server/app/controllers/spree/api/v3/admin/pos/kiosk_controller.rb` | Tạo |
| `server/openapi/pos-staff.yaml` | Sửa |
| `apps/pos-staff/lib/features/kiosk/`, `android/.../KioskChannel.kt`, `ios/Runner/KioskChannel.swift` | Tạo |
| `apps/pos/src/pages/settings/kiosk.tsx` | Tạo |

## Các bước

1. Migration, `Provision`, `Policy`, spec khẳng định tài khoản dịch vụ không giảm giá / tiền mặt / xác nhận tay được.
2. Sửa `Confirm` và spec: kiosk xác nhận được khi webhook đã khớp, bị từ chối với `vietqr_manual`.
3. Endpoint state, job đơn bỏ dở, nguồn đơn `kiosk` trong báo cáo.
4. Flutter chế độ kiosk, lock task, idle reset, trợ năng.
5. Cài đặt và lọc đơn kiosk trên `apps/pos`.
6. In số gọi qua trạm in gắn quầy kiosk.

## Kiểm thử

- `pnpm spree rspec spec/workflows/spree/pos/kiosks/ spec/requests/spree/pos/kiosk_spec.rb spec/workflows/spree/pos/tenders/confirm_spec.rb`.
- Flutter: widget test luồng màn, idle reset; integration test với server test (QR giả lập webhook khớp).
- E2E web: đơn kiosk park → thu ngân mở, thu tiền mặt, complete, bếp nhận món.

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Kiosk hoàn tất đơn khi tiền chưa về | Chỉ evidence webhook; spec chặn evidence tay. |
| Ca kiosk bị đóng giữa giờ | Kiosk hiện "Tạm ngưng" và không tạo đơn mới; đơn đang dở vẫn park được. |
| iOS không khóa máy được bằng code | Guided Access + kiểm tra trạng thái + cảnh báo quản lý; khuyến nghị Android cho kiosk. |
| Server LAN mất internet nên webhook không về | QR không khớp sau timeout, đơn chuyển "trả tại quầy". |

## Tiêu chí xong

- [ ] Khách tự order, trả QR, nhận phiếu số gọi; thu ngân không phải chạm vào.
- [ ] Trả tại quầy tạo đơn park, thu ngân thu tiền và hoàn tất bình thường.
- [ ] Tài khoản dịch vụ kiosk bị chặn ở mọi lệnh ngoài danh sách.
- [ ] Android lock task và iOS Guided Access được kiểm và cảnh báo.
- [ ] Spec, test Flutter, e2e xanh.
