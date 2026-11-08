---
phase: 6
title: "Hóa đơn điện tử khởi tạo từ máy tính tiền"
status: deferred
effort: "Chưa ước lượng"
dependsOn: [4]
---

# Phase 6: Hóa đơn điện tử khởi tạo từ máy tính tiền (deferred)

## Overview

Tách riêng theo D3: chưa làm vì sản phẩm chưa nhắm cửa hàng doanh thu ≥ 1 tỷ/năm. Khi mở phase này nên tạo một plan riêng, vì phần lớn công việc là tích hợp nhà cung cấp HĐĐT, không phải mẫu in.

## Bối cảnh (cần đối chiếu văn bản gốc trước khi làm)

NĐ 70/2025/NĐ-CP sửa NĐ 123/2020 (hiệu lực 01/06/2025): bán lẻ trực tiếp cho người tiêu dùng và hộ kinh doanh doanh thu ≥ 1 tỷ/năm dùng HĐĐT khởi tạo từ máy tính tiền, kết nối cơ quan thuế. Phiếu in khi đó cần: tên, địa chỉ, MST người bán; tên hàng, số lượng, đơn giá, thành tiền; thuế suất và tiền thuế (nếu khai thuế GTGT); tổng; thời điểm lập; ký hiệu, số hóa đơn, mã của cơ quan thuế hoặc mã tra cứu/QR; hình thức thanh toán; MST/CCCD người mua nếu người mua yêu cầu.

## Phạm vi dự kiến

1. **Nguồn MST và tên pháp lý**: `Spree::Store` không có; quyết định lúc đó giữa metadata của store, một extension, hoặc cấu hình của nhà cung cấp HĐĐT.
2. **Tích hợp nhà cung cấp** (MISA meInvoice, Viettel, VNPT, BKAV…): phát hành, nhận mã CQT, xử lý lỗi/gửi lại, hủy/điều chỉnh khi trả hàng. Làm theo provider pattern (xem skill `spree-providers`), cấu hình bật theo cửa hàng.
3. **Dữ liệu trên snapshot**: thêm `einvoice { series, number, authority_code, lookup_code, lookup_url }` vào snapshot hoặc một bản ghi liên kết. Snapshot vẫn bất biến; HĐĐT phát hành trễ thì in phiếu bổ sung, giống `return_supplement`.
4. **Mẫu in**: khi cửa hàng bật HĐĐT, các trường pháp lý thành khối **khóa bật** trên mẫu `sale`, giống cách Shopify khóa theo quốc gia. Thêm khối "QR tra cứu / yêu cầu xuất hóa đơn". Disclaimer "không phải hóa đơn điện tử" chỉ hiện khi phiếu chưa có mã HĐĐT.
5. **Thuế suất từng dòng** nếu nhà cung cấp/quy định yêu cầu: đọc từ `Spree::TaxLine`, không tính ở client.

## Điều kiện mở phase

- Có cửa hàng mục tiêu thuộc diện bắt buộc.
- Chọn được nhà cung cấp HĐĐT và có tài khoản sandbox.
- Đã đọc và chốt danh sách trường bắt buộc theo văn bản hiện hành (NĐ, Thông tư hướng dẫn).
