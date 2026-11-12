# ADR 0004: Hoa hồng tài xế là chi phí của trạm, chi tiền mặt qua phiếu chi két

Ngày: 2026-11-12
Trạng thái: đã chấp nhận

## Bối cảnh

Trạm dừng chân (module `fnb.vehicle_commission`, profile `cang_tin_tram_dung`)
trả hoa hồng cho tài xế / phụ xe đưa khách vào ăn. Hoa hồng tính theo lượt xe
(`VehicleVisit`): số tiền theo loại xe cộng số tiền mỗi khách nhân số khách, khi
đạt số khách và doanh thu tối thiểu (`CommissionRule`, quy tắc riêng của nhà xe
thắng quy tắc chung). Câu hỏi là hoa hồng nằm ở đâu trong sổ sách, và tiền ra
khỏi két bằng đường nào.

## Quyết định

1. **Hoa hồng là chi phí, không phải giảm giá.** Gắn đơn vào lượt xe
   (`Workspace.vehicle_visit_id`, chỉ trước khi đơn hoàn tất) không đổi giá đơn,
   tổng đơn hay hóa đơn điện tử. Doanh thu của lượt xe chỉ đọc từ các đơn đã hoàn
   tất.
2. **Chốt lượt giữ snapshot.** Lúc chốt (tay hoặc job tự chốt sau
   `vehicle_visit_window_minutes` của chi nhánh), quy tắc đang hiệu lực, số khách,
   doanh thu và kết quả được lưu vào `commission_snapshot`. Sửa quy tắc sau đó
   không đổi lượt đã chốt.
3. **Chi tiền mặt là `CashMovementRequest` cash_out** "Hoa hồng xe <biển số>"
   trên ca đang mở của người chi, chứng từ là mã lượt xe, và người thứ hai xác
   nhận như mọi phiếu chi két. Mỗi lượt chi một lần: khóa hàng lượt xe, unique
   index trên `cash_movement_request_id`, lệnh có idempotency key. Phiếu bị hủy
   thì lượt được chi lại. Chuyển khoản chỉ ghi mã giao dịch.
4. **Sửa sau khi chốt cần duyệt.** `adjust` luôn cần `Approval`
   `vehicle_visit.adjust` do người khác cấp trên revision của lượt xe, có ghi chú,
   và ghi `AuditEntry`. Hủy lượt chỉ khi chưa chi.
5. **Số điện thoại tài xế là dữ liệu cá nhân.** Chỉ người có
   `pos.vehicle_visit.manage` thấy đủ số; người khác thấy 4 số cuối. Báo cáo
   `vehicle_commissions` và file CSV không có số điện thoại hay tên tài xế.

## Hệ quả

- Tiền hoa hồng đã chi nằm trong dòng tiền ra của ca (phiếu chi két). Báo cáo
  đóng ca không tách riêng hoa hồng; báo cáo `vehicle_commissions` cộng theo
  ngày, nhà xe và biển số, phần đã chi chỉ tính khi phiếu chi đã xác nhận.
- Chưa có xác nhận của kế toán / thuế về khấu trừ thuế TNCN trên hoa hồng trả cho
  cá nhân và chứng từ chi cần có. POS không khấu trừ thuế; cần ký duyệt trước
  khi triển khai.
