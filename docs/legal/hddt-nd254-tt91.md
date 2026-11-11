# Hóa đơn điện tử cho POS theo NĐ 254/2026 và TT 91/2026

Ghi chú pháp lý phục vụ thiết kế tính năng xuất hóa đơn điện tử (HĐĐT) sau mỗi đơn hàng
hoàn tất. Đây là bản tóm tắt bằng lời của nhóm, không phải ý kiến tư vấn pháp lý. Tra cứu
ngày 11/11/2026.

**Độ tin cậy.** Không mở được toàn văn chính thức (thuvienphapluat.vn trả về 403, không tìm
thấy bản trên vanban.chinhphu.vn hoặc congbao.chinhphu.vn). Mọi điểm dưới đây dựa trên ít nhất
hai nguồn thứ cấp độc lập. Ưu tiên công văn 4831/CT-CS của Cục Thuế và các hãng kiểm toán
(KPMG, Forvis Mazars, Crowe), sau đó mới tới blog của nhà cung cấp hóa đơn (MISA, einvoice.vn,
Sapo). Điểm nào chỉ có một nguồn hoặc suy luận được đánh dấu **[CHƯA XÁC MINH]**. Trước khi
phát hành, cần đối chiếu số điều, khoản với toàn văn.

## 1. Tình trạng văn bản

| Văn bản | Tìm thấy | Ban hành | Hiệu lực | Ghi chú | Nguồn |
|---|---|---|---|---|---|
| NĐ 254/2026/NĐ-CP (hướng dẫn Luật Quản lý thuế 108/2025/QH15 về HĐĐT, chứng từ điện tử) | Có | 30/06/2026 | 01/07/2026, **đang hiệu lực** | 5 chương, 45 điều, 1 phụ lục. Thay thế NĐ 123/2020, NĐ 70/2025 và Điều 1 NĐ 41/2022 | [S1], [S2], [S3] |
| TT 91/2026/TT-BTC (hướng dẫn NĐ 254) | Có | 30/06/2026 | 01/07/2026, **đang hiệu lực** | Thay thế TT 32/2025/TT-BTC. Phụ lục I quy định ký hiệu, Phụ lục III chứa các mẫu (04/SS-HĐĐT, 01/TTGD, 01/BK-ĐCTT) | [S2], [S4], [S5] |
| Công văn 4831/CT-CS (Cục Thuế giới thiệu điểm mới) | Có | 15/07/2026 | Không áp dụng | Nguồn tóm tắt chính thức gần nhất | [S2] |
| NĐ 68/2026/NĐ-CP (thuế hộ, cá nhân kinh doanh) | Có | 05/03/2026 | Theo nguồn thứ cấp là 05/03/2026 **[CHƯA XÁC MINH]** | Khoản 5 Điều 8 quy định ngưỡng bắt buộc dùng HĐĐT | [S6], [S7] |
| NĐ 141/2026/NĐ-CP (sửa NĐ 68/2026 và NĐ 320/2025) | Có | 29/04/2026 | 01/01/2026, hồi tố theo Điều 3 | Đổi ngưỡng 500 triệu thành 1 tỷ ở nhiều điều | [S8], [S9] |
| NĐ 174/2025/NĐ-CP (giảm thuế GTGT xuống 8% theo NQ 204/2025/QH15) | Có | 30/06/2025 | 01/07/2025 đến 31/12/2026 | Chưa thấy văn bản gia hạn | [S10], [S11] |

**Kết luận về kế hoạch.** Nhận định "từ 01/07/2026, NĐ 254/2026 và TT 91/2026 thay thế bộ văn
bản cũ" là **đúng**. Cụm "NĐ 68/2026 sửa bởi NĐ 141/2026" cũng **đúng**, nhưng ngưỡng là
**trên** 1 tỷ đồng/năm, không phải "từ 1 tỷ trở lên" (xem mục 10). NĐ 123/2020, NĐ 70/2025 và
TT 32/2025 đã hết hiệu lực, nên không dùng làm căn cứ.

## 2. Hóa đơn khởi tạo từ máy tính tiền (MTT)

**Khái niệm (NĐ 254, Điều 3, khoản 3–4).** Đây là HĐĐT, có mã hoặc không có mã, được lập từ
hệ thống tính tiền. Dữ liệu được gửi tới cơ quan thuế (CQT) theo định dạng chuẩn. "Máy tính
tiền" có thể là một thiết bị hoặc giải pháp công nghệ thông tin có chức năng tính tiền và lưu
giao dịch. Phần mềm hóa đơn của nhà cung cấp cũng đáp ứng định nghĩa này [S12].

**Ai dùng (NĐ 254, Điều 6, khoản 1, điểm c và d)** [S2], [S12], [S13]:
- Điểm c áp dụng cho cơ sở bán trực tiếp cho người tiêu dùng: bán lẻ (trừ ô tô), ăn uống,
  nhà hàng, khách sạn, vận tải hành khách, **vui chơi giải trí**, dịch vụ cá nhân. Nhóm này
  dùng HĐĐT từ MTT. Cơ sở **đã đăng ký** HĐĐT có mã hoặc không mã thì **không bắt buộc**
  chuyển sang MTT. Vì vậy cafe, F&B, bán lẻ và giải trí có thể dùng MTT hoặc hóa đơn có mã.
- Điểm d áp dụng cho hộ và cá nhân kinh doanh có doanh thu năm trên 1 tỷ đồng, hoặc bán tài
  sản phải đăng ký quyền sở hữu. Nhóm này dùng hóa đơn có mã hoặc hóa đơn MTT có kết nối dữ
  liệu với CQT.

**Chữ ký số (NĐ 254, Điều 8, khoản 3).** Hóa đơn MTT có kết nối dữ liệu với CQT **không bắt
buộc** chữ ký số của người bán. Hóa đơn này cũng không cần chữ ký người mua [S14]. Đây là
khác biệt lớn nhất so với hóa đơn có mã.

**Nội dung bắt buộc (NĐ 254, Điều 10, khoản 4)** [S14], [S15]:
- Người bán: tên, địa chỉ, mã số thuế (MST).
- Hàng hóa, dịch vụ: tên, đơn giá, số lượng, thành tiền thanh toán.
- Nếu người bán nộp thuế theo phương pháp khấu trừ: giá chưa thuế, thuế suất GTGT, tiền thuế,
  tổng cộng có thuế.
- Thời điểm lập.
- Mã của CQT, hoặc dữ liệu điện tử để người mua tra cứu và kê khai.
- Người mua: chỉ ghi **khi người mua yêu cầu**. Có thể là MST, **số định danh cá nhân** hoặc
  số điện thoại, kèm tên và địa chỉ.
- Được phép bỏ trống: chữ ký số của người bán và người mua, thông tin người mua khi họ không
  yêu cầu.

Theo một bản dự thảo quyết định về định dạng XML, "hình thức thanh toán" là trường bắt buộc.
Các trường tùy chọn gồm họ tên người mua, mã ĐVQHNS, số hộ chiếu, tài khoản ngân hàng, mã
cửa hàng và tên cửa hàng [S12]. Đây là dự thảo **[CHƯA XÁC MINH bản chính thức]**.

**Mã của CQT trên hóa đơn MTT.** Mã gồm 23 ký tự theo dạng `M1-26-XXXXX-00000000001`
[S16]:
- `M1` hoặc `M2` là tiền tố. Theo hiểu biết của nhóm, M1 là hóa đơn GTGT, M2 là hóa đơn bán
  hàng **[CHƯA XÁC MINH]**.
- `26` là năm.
- `XXXXX` là 5 ký tự CQT cấp cho người nộp thuế.
- 11 chữ số cuối do phần mềm tự sinh.

Cấu trúc này đến từ QĐ 1450/QĐ-TCT (2021) và QĐ 1510/QĐ-TCT (2022), thuộc chế độ cũ.
**[CHƯA XÁC MINH còn nguyên dưới TT 91]**. Trên thực tế nhà cung cấp sinh mã và trả về, nên
POS chỉ lưu lại và không tự sinh.

## 3. Hóa đơn có mã của CQT (cấp mã theo từng hóa đơn)

**Nội dung bắt buộc (NĐ 254, Điều 10, khoản 1 và Phụ lục)** [S15], [S17]:
- Tên hóa đơn, ký hiệu mẫu số, ký hiệu hóa đơn, số hóa đơn.
- Tên, địa chỉ và MST người bán. Hộ kinh doanh có nhiều cửa hàng dùng chung một MST phải ghi
  tên, mã và địa chỉ của **từng cửa hàng** [S2].
- Thông tin người mua (mục 6).
- Mỗi dòng hàng: tên hàng hóa, dịch vụ bằng **tiếng Việt**, đơn vị tính, số lượng, đơn giá,
  thành tiền chưa thuế, thuế suất.
- Tiền thuế GTGT theo từng mức thuế suất, tổng tiền thuế, tổng thanh toán **bằng số và bằng
  chữ**.
- Chữ ký số của người bán, thời điểm lập, thời điểm ký, mã của CQT.

**Được miễn (Phụ lục, mục 9)** [S15], [S18]:
- Điểm 9.1: không bắt buộc chữ ký số của người mua.
- Điểm 9.3: siêu thị, trung tâm thương mại, rạp chiếu phim và cây xăng bán cho cá nhân không
  cung cấp thông tin được bỏ trống thông tin người mua.
- Điểm 9.4: tem, vé, thẻ (mẫu số 5, ký tự G/H) được bỏ thông tin người mua và thuế suất. Có
  thể bỏ cả chữ ký người bán nếu đã có mã CQT. Liên quan tới vé giải trí.

**Đồng tiền (Phụ lục, mục 8.3).** Mặc định là đồng Việt Nam. Nếu giao dịch bằng ngoại tệ thì
ghi mã tiền tệ chuẩn và tỷ giá quy đổi [S15].

## 4. Ký hiệu mẫu số, ký hiệu hóa đơn, số hóa đơn (TT 91, Điều 4 và Phụ lục I)

Mẫu số và ký hiệu ghép thành một chuỗi 7 ký tự [S5], [S19], [S20]:

| Vị trí | Ý nghĩa |
|---|---|
| 1 (mẫu số) | 1 = GTGT, 2 = bán hàng, 5 = tem/vé/thẻ, 7 = hóa đơn thương mại điện tử, … |
| 2 | `C` = có mã CQT, `K` = không mã |
| 3–4 | Hai số cuối của năm lập, ví dụ `26` |
| 5 | Loại: `T` = đăng ký thông thường, `L` = CQT cấp theo từng lần phát sinh, **`M` = khởi tạo từ máy tính tiền**, `G`/`H` = tem, vé, thẻ, `X` = thương mại điện tử, … |
| 6–7 | Người bán tự đặt, dùng `YY` nếu không cần phân biệt |

Ví dụ cho POS:
- Doanh nghiệp khấu trừ: `1C26MAA` (MTT) hoặc `1C26TAA` (có mã).
- Hộ kinh doanh hoặc người nộp theo phương pháp trực tiếp: `2C26MAA`.

Các nguồn thống nhất chữ cái thứ 5 là `M` cho hóa đơn MTT. Ký tự đầu là `C`, theo ví dụ cũ
`C22MAA` và thực tế của các nhà cung cấp. Văn bản mới định nghĩa hóa đơn MTT là "có mã hoặc
không có mã", nên cần **xác nhận với nhà cung cấp** **[CHƯA XÁC MINH cho TT 91]**. Không được
hard-code. Mẫu số và ký hiệu phải là cấu hình, và hai số năm đổi vào 01/01.

**Số hóa đơn (Phụ lục NĐ 254, mục 2)** [S19]:
- Tối đa 8 chữ số, tăng dần trong cùng mẫu số và ký hiệu.
- Bắt đầu lại từ 1 vào ngày 01/01, hoặc từ ngày bắt đầu sử dụng.
- Nhiều chi nhánh dùng chung ký hiệu thì vẫn tăng dần theo thời điểm ký.
- Không còn thủ tục thông báo "từ số đến số".

Số do nhà cung cấp cấp. POS chỉ lưu lại.

## 5. Thời điểm lập (NĐ 254, Điều 9)

- **Khoản 1, bán hàng hóa.** Lập khi chuyển giao quyền sở hữu hoặc quyền sử dụng, đã thu tiền
  hay chưa không quan trọng [S21].
- **Khoản 2, dịch vụ.** Lập khi hoàn thành dịch vụ. Nếu thu tiền trước hoặc trong khi cung cấp
  thì lập khi thu tiền. Tiền đặt cọc bảo đảm theo Bộ luật Dân sự không phải lập hóa đơn
  [S2], [S21].
- **Khoản 3.** Giao hàng nhiều lần thì mỗi lần giao lập một hóa đơn [S21].
- **Khoản 4, các trường hợp đặc thù.** Gồm dịch vụ cần đối soát, bảo hiểm, taxi bán cho doanh
  nghiệp, và điểm r với bảng 01/TTGD cho một số dịch vụ tiêu dùng [S2]. **Không tìm thấy**
  ngoại lệ cho phép cafe, F&B hoặc bán lẻ gộp hóa đơn cuối ngày. Mỗi đơn là một hóa đơn.
- **Khoản 5, ban đêm.** Kế hoạch gọi là "ngoại lệ 22h–6h Điều 9". Quy định này **có tồn tại**
  nhưng **hẹp** [S2], [S22], [S23], [S24]:
  - Chỉ áp dụng khi người bán **không có phần mềm lập hóa đơn tự động** và giao dịch phát
    sinh trong giờ làm việc ban đêm theo Bộ luật Lao động (22h–6h, Điều 106 BLLĐ 2019).
  - Khi đó hạn lập chậm nhất là "ngày làm việc tiếp theo".
  - Có phần mềm tự động thì phải lập ngay. POS của mình là phần mềm tự động, nên **không được
    dựa vào ngoại lệ này** để hoãn xuất hóa đơn.
- **Sự cố (Điều 14).** Gặp sự kiện bất khả kháng thì lập và gửi trong vòng 3 ngày làm việc kể
  từ khi khắc phục xong [S2].

## 6. Thông tin người mua

- **Người mua là tổ chức hoặc hộ kinh doanh.** Ghi tên, địa chỉ, MST đúng theo đăng ký thuế
  (Điều 10, khoản 1, điểm d) [S2], [S18].
- **Người tiêu dùng cung cấp thông tin.** Họ tên, địa chỉ, **số định danh cá nhân** phải được
  ghi lên hóa đơn. Người nước ngoài ghi số hộ chiếu và quốc tịch thay cho số định danh
  (Phụ lục, điểm 4a) [S15], [S25].
- **Người tiêu dùng không cung cấp.** Ghi đúng cụm **"Bán cho người tiêu dùng"** (Phụ lục,
  điểm 4b) [S2], [S13], [S15]. Không dùng "người mua không lấy hóa đơn", vì cụm đó không có
  trong văn bản mới.
- **Hệ quả.** Hóa đơn không có thông tin người mua hoặc ghi "Bán cho người tiêu dùng" không
  được dùng để tính chi phí hay quyết toán thuế. Hóa đơn giá trị lớn mà ghi nhãn này bị xếp
  vào nhóm rủi ro cao [S2], [S18].
- **Hóa đơn MTT.** Thông tin người mua chỉ ghi khi người mua yêu cầu (Điều 10, khoản 4). Gồm
  MST, số định danh hoặc số điện thoại [S14].
- **Ngưỡng tiền.** **Không tìm thấy** ngưỡng giá trị bắt buộc ghi thông tin người mua. Thông
  tin bắt buộc khi người mua yêu cầu, hoặc khi người mua là doanh nghiệp cần hạch toán.

## 7. Xử lý sai sót

Căn cứ là TT 91, Điều 10, và công văn 4831 [S2], [S26], [S27]:
- **Sai tên hoặc địa chỉ, không sai MST, tiền, thuế suất, hàng hóa.** Không lập lại hóa đơn.
  Người bán thông báo cho người mua và gửi CQT **Mẫu 04/SS-HĐĐT** (Phụ lục III TT 91).
- **Hóa đơn MTT lập sai.** Lập **hóa đơn thay thế** (Điều 10, khoản 1, điểm c). Theo
  einvoice.vn, loại này không được chọn hóa đơn điều chỉnh [S14].
- **Hóa đơn có mã sai MST, tiền, thuế suất hoặc hàng hóa.** Lập điều chỉnh hoặc thay thế.
  Hóa đơn điều chỉnh ghi dòng "Điều chỉnh cho hóa đơn Mẫu số… ký hiệu… số…".
- **Nhiều hóa đơn sai cùng nội dung, cùng một người mua, trong cùng tháng.** Gộp thành một hóa
  đơn điều chỉnh kèm bảng kê 01/BK-ĐCTT.
- **Văn bản thỏa thuận.** Theo công văn 4831, không còn bắt buộc có văn bản thỏa thuận trước
  khi điều chỉnh hoặc thay thế [S2]. Theo lsvn, người mua là tổ chức thì vẫn cần văn bản, còn
  người mua cá nhân thì chỉ cần thông báo [S26]. Hai nguồn **mâu thuẫn**, cần đọc toàn văn
  **[CHƯA XÁC MINH]**.
- **Hủy hóa đơn.** Thủ tục **hủy hóa đơn do sai sót không còn** từ 01/07/2026. Chỉ còn điều
  chỉnh hoặc thay thế [S27]. Chưa rõ trường hợp hóa đơn đã có mã nhưng chưa gửi người mua còn
  cách hủy bằng 04/SS như chế độ cũ hay không **[CHƯA XÁC MINH]**.
- **Người mua đòi thông tin công ty sau khi hóa đơn đã lập** (thường là hóa đơn ghi "Bán cho
  người tiêu dùng" hoặc hóa đơn MTT). Không tìm thấy quy định riêng. Cách xử lý hợp lý nhất là
  coi đây là sai sót thông tin người mua có liên quan tới MST, rồi **lập hóa đơn thay thế** có
  thông tin người mua. Với hóa đơn MTT, thay thế là cách duy nhất được nêu. Không sửa trực tiếp
  hóa đơn gốc **[CHƯA XÁC MINH, hỏi nhà cung cấp và CQT]**.

## 8. Chuyển dữ liệu tới CQT

- **Hóa đơn MTT (NĐ 254, Điều 15, khoản 3).** Gửi dữ liệu **trong ngày**, chậm nhất **cuối
  ngày** [S2], [S14]. Nhà cung cấp thường gửi ngay khi lập.
- **Hóa đơn có mã.** CQT cấp mã trước khi hóa đơn được gửi cho người mua, nên quá trình là
  đồng bộ.
- **Hóa đơn không mã và bảng 01/TTGD (Điều 16).** Gửi theo hạn nộp tờ khai GTGT [S2].
- **Hệ thống gặp sự cố.** Chứng từ điện tử được gửi trong vòng 3 ngày làm việc sau khi khắc
  phục (Điều 27). Hóa đơn gặp bất khả kháng cũng có hạn 3 ngày làm việc (Điều 14) [S2]. Mất
  mạng thông thường có thuộc "bất khả kháng" hay không thì **chưa xác minh**. Nên coi hạn cứng
  là cuối ngày đối với MTT.

## 9. Thuế suất, phí phục vụ, tiền boa, chiết khấu

- **Thuế suất ghi theo từng dòng hàng.** Tiền thuế được cộng theo từng mức thuế suất (Phụ lục,
  mục 5) [S15]. Các mức theo Luật thuế GTGT là 0%, 5%, 10%, cộng các trường hợp không chịu
  thuế hoặc không kê khai.
- **Mức 8%.** Hàng hóa, dịch vụ đang chịu 10% được giảm xuống 8% từ 01/07/2025 **đến hết
  31/12/2026**, trừ các nhóm trong Phụ lục I và II của NĐ 174/2025 [S10], [S11]. Đồ ăn uống
  không nằm trong danh sách loại trừ. Nước ngọt có đường trên 5g/100ml thì không được giảm.
  **Phải kiểm tra lại việc gia hạn trước 01/01/2027.** Thuế suất phải là dữ liệu theo từng mặt
  hàng và có ngày hiệu lực, không hard-code 8%.
- **Phí phục vụ.** Đây là khoản thu thêm, tính vào doanh thu chịu thuế và ghi thành dòng riêng
  có thuế suất. Đây là hiểu biết theo Luật thuế GTGT về giá tính thuế, phiên này chưa đọc
  nguyên văn **[CHƯA XÁC MINH]**.
- **Tiền boa.** Không tìm thấy quy định trong NĐ 254 hay TT 91 **[CHƯA XÁC MINH]**. Nên hỏi
  kế toán của khách hàng trước khi đưa vào hóa đơn.
- **Chiết khấu thương mại và khuyến mại.** Phải thể hiện trên hóa đơn [S15].

## 10. Ngưỡng bắt buộc dùng HĐĐT của hộ và cá nhân kinh doanh

Theo NĐ 68/2026, Điều 8, khoản 5, đã sửa bởi NĐ 141/2026, Điều 1, khoản 2 [S8], [S9]:
- Doanh thu năm **trên 01 tỷ đồng**: phải dùng HĐĐT có mã của CQT. NĐ 254, Điều 6, khoản 1,
  điểm d còn cho phép dùng hóa đơn MTT có kết nối dữ liệu [S12], [S13].
- Doanh thu từ 1 tỷ trở xuống: được dùng nếu có nhu cầu và đáp ứng điều kiện.
- NĐ 141/2026 có hiệu lực từ 01/01/2026.

Hai điểm **chưa xác minh**:
- Có nguồn ghi ngưỡng gốc của NĐ 68 là "từ 1 tỷ trở lên" [S6]. Bản đã sửa ghi "trên 01 tỷ".
- Ngày bắt đầu áp dụng nghĩa vụ hóa đơn (theo năm doanh thu nào) cần đọc thêm toàn văn NĐ 68.

## 11. Ảnh hưởng tới thiết kế POS

**Lưu cho mỗi hóa đơn.** Mỗi bản ghi là ảnh chụp tại thời điểm lập, không tham chiếu dữ liệu
đang thay đổi:
- Người bán:
  - `seller_name`, `seller_tax_code`, `seller_address`.
  - Với hộ có nhiều cửa hàng thêm `outlet_code` và `outlet_name`, lấy theo **branch** chứ
    không theo store.
- Ký hiệu, số và thời điểm:
  - `template_code`: mẫu số, 1 chữ số.
  - `symbol`: 6 ký tự, ví dụ `C26MAA`.
  - `number`: tối đa 8 chữ số.
  - `issued_at`: thời điểm lập.
  - `signed_at`: hóa đơn có mã có thời điểm ký riêng.
  - `cqt_code`: mã CQT.
  - `lookup_code` và `lookup_url`: tra cứu.
  - `sent_to_cqt_at`.
- Người mua: `tax_code`, `name`, `address`, `personal_id` (số định danh cá nhân), `phone`,
  `passport_no`, `nationality`, `email`, `buyer_note`.
- Thanh toán: `payment_method`, `currency`, `exchange_rate`.
- Tổng: tổng chưa thuế, tiền thuế theo từng mức, tổng thuế, chiết khấu, tổng thanh toán và
  số tiền bằng chữ. Số tiền bằng chữ có thể để nhà cung cấp sinh.

**Lưu cho mỗi dòng hàng.**
- `name` bằng tiếng Việt, `unit`, `quantity`, `unit_price`, `discount`, `amount_before_tax`.
- `tax_rate`: gồm 0, 5, 8, 10, `KCT` (không chịu thuế), `KKKNT` (không kê khai, không nộp
  thuế).
- `tax_amount`, `amount`.
- Loại dòng: hàng hóa, phí phục vụ, chiết khấu, khuyến mại.

**Nhãn người tiêu dùng.**
- `consumer_label` để cấu hình được, mặc định **"Bán cho người tiêu dùng"**.
- Chỉ dùng khi không có thông tin người mua.
- Với hóa đơn MTT có thể để trống phần người mua. Hành vi cụ thể phụ thuộc định dạng của nhà
  cung cấp.

**Thời điểm và hàng đợi.**
- Lập ngay khi đơn hoàn tất, một đơn một hóa đơn. Không gộp cuối ngày, không dựa vào ngoại lệ
  ban đêm.
- Khi nhà cung cấp hoặc CQT gặp sự cố: đưa vào hàng đợi `pending` và thử lại tự động.
  - Với MTT, cảnh báo khi gần cuối ngày mà hóa đơn vẫn chưa được gửi.
  - Ghi nhận thời điểm khắc phục sự cố để tính hạn 3 ngày làm việc.
- `issued_at` là thời điểm hoàn tất đơn, không phải thời điểm thử lại thành công.
  **[CHƯA XÁC MINH]**: chỉ làm được nếu nhà cung cấp cho phép truyền thời điểm lập.

**Bổ sung thông tin người mua sau khi đã xuất.** Tạo hóa đơn **thay thế** mới có liên kết tới
hóa đơn gốc. Không ghi đè buyer của hóa đơn đã phát hành.

**Mâu thuẫn với bản nháp hiện tại.**
1. `order_id unique` sai. Một đơn có thể có hóa đơn gốc cộng hóa đơn thay thế hoặc điều chỉnh.
   Cần thêm:
   - `original_einvoice_id`.
   - `relation`, nhận giá trị `replaces` hoặc `adjusts`.
   - Ràng buộc chỉ một hóa đơn "hiện hành" cho mỗi đơn.
2. `status` có `canceled`, nhưng không còn thủ tục hủy hóa đơn đã phát hành. Chỉ dùng
   `canceled` cho bản chưa phát hành, hoặc đổi tên. Cần thêm `replaced`. `adjusted` là trạng
   thái của hóa đơn gốc.
3. `buyer` thiếu `personal_id`, `phone`, `passport_no`, `nationality`. Văn bản bắt buộc ghi số
   định danh nếu người mua cung cấp. Với hóa đơn MTT, số điện thoại là một trong các lựa chọn.
4. Settings thiếu `seller_tax_code`. `seller_name` và `seller_address` cần ghi đè được theo
   branch.
5. `template_code` và `symbol` cần tách đúng: mẫu số 1 ký tự và ký hiệu 6 ký tự. Năm trong ký
   hiệu đổi hằng năm, nên tính theo năm hoặc cho cấu hình theo năm.
6. `lookup_code` cần tách khỏi `cqt_code`. Bản nháp còn thiếu `payment_method`, `currency`,
   `exchange_rate`, `signed_at`, `sent_to_cqt_at`.
7. `invoice_type` (`cash_register` | `coded`) giữ nguyên được. Cả hai loại thường dùng ký tự
   đầu `C`, khác nhau ở chữ cái thứ 5 (`M` và `T`). Hóa đơn MTT không cần chữ ký số.

## Nguồn

Toàn văn NĐ 254 và TT 91 chưa mở được, nên các nguồn dưới đây đều là thứ cấp. Cần đối chiếu
lại.

- [S1] thuvienphapluat: Đã có NĐ 254/2026 — https://thuvienphapluat.vn/ma-so-thue/phap-luat-thue/da-co-nghi-dinh-2542026ndcp-huong-dan-hoa-don-chung-tu-dien-tu-227590.html
- [S2] luatvietnam: Công văn 4831/CT-CS về điểm mới NĐ 254 và TT 91 — https://luatvietnam.vn/thue/cong-van-4831-ct-cs-2026-cua-cuc-thue-ve-noi-dung-moi-tai-nghi-dinh-254-2026-nd-cp-va-thong-tu-91-2026-tt-btc-440460-d6.html
- [S3] KPMG Việt Nam — https://kpmg.com/vn/en/insights/2026/07/decree-254-and-circular-91-on-electronic-invoices.html
- [S4] Forvis Mazars — https://www.forvismazars.com/vn/vi/n-ph-m-s-ki-n/c-p-nh-t-v-vi-t-nam/b-n-tin-thong-bao-chuyen-mon/b-n-tin-v-thu-va-phap-ly/ngh-d-nh-254-va-thong-t-91
- [S5] thuvienphapluat: Đã có TT 91/2026 — https://thuvienphapluat.vn/ma-so-thue/phap-luat-thue/da-co-thong-tu-912026ttbtc-huong-dan-ve-hoa-don-dien-tu-chung-tu-dien-tu-227794.html
- [S6] thuvienphapluat: Hộ kinh doanh từ 1 tỷ phải dùng HĐĐT — https://thuvienphapluat.vn/hoi-dap-phap-luat/ho-kinh-doanh-co-doanh-thu-1-ty-dong-tro-len-phai-ap-dung-hoa-don-dien-tu-dung-khong-138082541.html
- [S7] Thời báo Tài chính Việt Nam — https://thoibaotaichinhvietnam.vn/chinh-thuc-quy-dinh-ho-kinh-doanh-co-doanh-thu-1-ty-dong-tro-len-phai-ap-dung-hoa-don-dien-tu-193181.html
- [S8] hethongphapluat: NĐ 141/2026 — https://hethongphapluat.com/nghi-dinh-141-2026-nd-cp-21f4c295caca62acf3b33cedda2abb2d.html
- [S9] Tạp chí Công Thương: ngưỡng 1 tỷ áp dụng từ 01/01/2026 — https://tapchicongthuong.vn/chinh-thuc--nang-nguong-chiu-thue-voi-ho-kinh-doanh-len-1-ty-dong-nam--ap-dung-tu-1-1-2026-514336.htm
- [S10] einvoice.vn: toàn văn NĐ 174/2025 — https://einvoice.vn/tin-tuc/toan-van-nghi-dinh-174-2025-nd-cp-quy-dinh-muc-giam-pham-vi-va-doi-tuong-ap-dung-thue-gtgt-theo-nghi-quyet-204-2025-qh15
- [S11] thuvienphapluat: mặt hàng giảm thuế 8% đến hết 2026 — https://thuvienphapluat.vn/ma-so-thue/phap-luat-thue/chi-tiet-mat-hang-giam-thue-gtgt-tu-10-xuong-8-den-het-nam-2026-892633-222484.html
- [S12] MISA helpact: câu hỏi về hóa đơn MTT theo NĐ 254 — https://helpact.misa.vn/?p=87015
- [S13] ketoananpha: quy định NĐ 254 — https://ketoananpha.vn/quy-dinh-hoa-don-va-chung-tu-dien-tu-2026.html
- [S14] einvoice.vn: hóa đơn MTT có cần chữ ký số — https://einvoice.vn/tin-tuc/hddt-khoi-tao-tu-may-tinh-tien-co-can-chu-ky-so
- [S15] einvoice.vn: nội dung hóa đơn theo NĐ 254 — https://einvoice.vn/tin-tuc/noi-dung-hoa-don-dien-tu
- [S16] luatvietnam: hóa đơn MTT có mã hay không — https://luatvietnam.vn/thue-phi-le-phi/hoa-don-khoi-tao-tu-may-tinh-tien-la-hoa-don-co-ma-hay-khong-565-95293-article.html
- [S17] Crowe Việt Nam — https://www.crowe.com/vn/vi-vn/news/e-invoices-and-electronic-documents-from-1-july-2026
- [S18] Thời báo Tài chính Việt Nam: lập hóa đơn cho bán lẻ và thương mại điện tử — https://thoibaotaichinhvietnam.vn/go-vuong-mac-ve-lap-hoa-don-dien-tu-cho-thi-truong-ban-le-va-thuong-mai-dien-tu-200649.html
- [S19] misaeshop: ký hiệu hóa đơn MTT — https://www.misaeshop.vn/30747/ky-hieu-hoa-don-khoi-tao-tu-may-tinh-tien/
- [S20] luatvietnam: giải mã ký hiệu theo TT 91 — https://luatvietnam.vn/thue-phi-le-phi/giai-ma-ky-hieu-mau-va-ky-hieu-hoa-don-dien-tu-565-110328-article.html
- [S21] misaeshop: thời điểm xuất hóa đơn theo NĐ 254 — https://www.misaeshop.vn/?p=45259
- [S22] thue.man.net.vn: khung giờ xuất hóa đơn — https://thue.man.net.vn/khung-gio-xuat-hoa-don-hop-le/
- [S23] RSM: bản tin thời điểm xuất hóa đơn (PDF, không đọc được nội dung, chỉ đọc được tiêu đề) — https://www.rsm.global/vietnam/
- [S24] Công văn 6325/CT-QLNT ngày 26/08/2026 (chỉ đọc được đoạn trích) — https://thuviennhadat.vn/vbpl/cong-van-6325-ct-qlnt-2026-lap-hoa-don-722393.html
- [S25] ketoanleanh: khi nào ghi số định danh — https://ketoanleanh.edu.vn/kinh-nghiem-ke-toan/khi-nao-bat-buoc-ghi-so-dinh-danh-ca-nhan-tren-hoa-don.html
- [S26] lsvn: hóa đơn MTT lập sai xử lý thế nào — https://lsvn.vn/hoa-don-dien-tu-tu-may-tinh-tien-lap-sai-thi-xu-ly-the-nao-a176099.html
- [S27] MISA AMIS: bãi bỏ thủ tục hủy hóa đơn theo NĐ 254 — https://amis.misa.vn/80258/phuong-phap-huy-hoa-don-dien-tu/

## Câu hỏi còn mở

1. Toàn văn chính thức của NĐ 254 và TT 91 (Công báo hoặc chinhphu.vn): xác nhận số điều,
   khoản đã dẫn, nhất là Điều 9 khoản 5, Điều 10 khoản 4 và Phụ lục điểm 4 và 9.
2. Ký tự đầu của ký hiệu hóa đơn MTT là `C` hay `K` dưới TT 91, và cấu trúc mã CQT của hóa
   đơn MTT còn giữ dạng `M1-YY-XXXXX-…` hay không. Hỏi nhà cung cấp.
3. Người mua yêu cầu thông tin công ty sau khi đã có hóa đơn MTT hoặc hóa đơn ghi "Bán cho
   người tiêu dùng": dùng thay thế hay thông báo 04/SS.
4. Thuế suất 8% có được gia hạn sau 31/12/2026 hay không.
5. Cách hạch toán tiền boa và phí phục vụ trên hóa đơn. Hỏi kế toán.
