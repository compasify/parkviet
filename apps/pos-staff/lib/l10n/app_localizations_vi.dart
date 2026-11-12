// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'ParkViet Nhân viên';

  @override
  String get welcomeTitle => 'Ghép máy với cửa hàng';

  @override
  String get welcomeBody =>
      'Mở Quản lý thiết bị trên trang quản trị, tạo mã ghép, rồi quét mã QR hoặc nhập địa chỉ server và mã.';

  @override
  String get welcomeScan => 'Quét QR ghép máy';

  @override
  String get welcomeManual => 'Nhập địa chỉ server và mã';

  @override
  String get revokedNotice =>
      'Máy này đã bị thu hồi hoặc gỡ ghép trên server. Hãy ghép lại.';

  @override
  String get scanTitle => 'Quét QR ghép máy';

  @override
  String get scanHint => 'Đưa mã QR trên màn hình quản lý vào khung hình.';

  @override
  String get scanCameraUnavailable =>
      'Không mở được camera. Hãy cho phép dùng camera, hoặc quay lại và nhập mã bằng tay.';

  @override
  String get pairingWorking => 'Đang ghép máy…';

  @override
  String get manualTitle => 'Nhập địa chỉ server';

  @override
  String get manualServerLabel => 'Địa chỉ server';

  @override
  String get manualServerHint =>
      'http://192.168.1.10 hoặc https://pos.quan-a.vn';

  @override
  String get manualCodeLabel => 'Mã ghép';

  @override
  String get manualNameLabel => 'Tên máy';

  @override
  String get manualSubmit => 'Ghép máy';

  @override
  String get pairingNotPairingCode => 'Đây không phải mã QR ghép máy ParkViet.';

  @override
  String get pairingUnsupportedVersion =>
      'Mã QR này thuộc phiên bản khác. Hãy cập nhật app.';

  @override
  String get pairingWrongKind => 'Mã QR này không dùng để ghép thiết bị.';

  @override
  String get pairingInvalidUrl =>
      'Địa chỉ server không hợp lệ. Cần bắt đầu bằng http:// hoặc https://.';

  @override
  String get pairingInsecureUrl =>
      'Chỉ dùng http:// cho server trong mạng của quán (IP 192.168.x.x, 10.x.x.x, 172.16–31.x.x hoặc tên .local). Server trên internet phải dùng https://.';

  @override
  String get pairingMissingCode => 'Thiếu mã ghép.';

  @override
  String get pairingCodeInvalid =>
      'Mã ghép sai hoặc đã hết hạn. Hãy tạo mã mới.';

  @override
  String get failureTimeout =>
      'Server không trả lời kịp. Kiểm tra mạng rồi thử lại.';

  @override
  String get failureTls =>
      'Không tin được chứng chỉ bảo mật của server (HTTPS). Kiểm tra địa chỉ, hoặc nhờ người lắp đặt kiểm tra chứng chỉ.';

  @override
  String get failureCleartext =>
      'Máy này chặn kết nối không mã hóa (http://) tới địa chỉ đó.';

  @override
  String get failureUnreachable =>
      'Không kết nối được server. Kiểm tra địa chỉ và máy có cùng mạng với server không.';

  @override
  String get failureUnauthorized =>
      'Server không nhận diện được máy hoặc phiên đăng nhập.';

  @override
  String get failureForbidden =>
      'Máy hoặc tài khoản này không có quyền làm việc đó.';

  @override
  String get failureNotFound => 'Không tìm thấy trên server.';

  @override
  String get failureRateLimited =>
      'Thử quá nhiều lần. Đợi một lát rồi thử lại.';

  @override
  String failureConflict(String reason) {
    return 'Server từ chối: $reason';
  }

  @override
  String failureServer(int status) {
    return 'Server gặp lỗi ($status). Thử lại sau.';
  }

  @override
  String get failureUnexpected => 'Có lỗi không mong đợi. Thử lại.';

  @override
  String get pinIncorrect => 'PIN không đúng.';

  @override
  String get pinNotSet => 'Chưa đặt PIN. Đặt PIN trên trang quản trị trước.';

  @override
  String get pinLocked => 'Sai PIN quá nhiều lần. Khóa 15 phút trên máy này.';

  @override
  String get pinRateLimited => 'Máy này nhập sai PIN quá nhiều. Đợi một lát.';

  @override
  String get offlineTitle => 'Mất kết nối server';

  @override
  String offlineBody(String serverUrl) {
    return 'Máy đã ghép với $serverUrl nhưng chưa hỏi được server.';
  }

  @override
  String get retry => 'Thử lại';

  @override
  String get staffPickerTitle => 'Chọn tên của bạn';

  @override
  String get managerPickerTitle => 'Quản lý xác nhận';

  @override
  String get staffPickerEmpty => 'Chi nhánh chưa có nhân viên nào.';

  @override
  String pinTitle(String name) {
    return 'PIN của $name';
  }

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinSubmit => 'Đăng nhập';

  @override
  String get managerDenied => 'Người này không có quyền quản lý thiết bị.';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get manageTitle => 'Thông tin máy';

  @override
  String get manageDeviceName => 'Tên máy';

  @override
  String get manageMode => 'Chế độ';

  @override
  String get manageBranch => 'Chi nhánh';

  @override
  String get manageServer => 'Server';

  @override
  String get manageAppVersion => 'Phiên bản app';

  @override
  String get manageEditorId => 'Mã cài đặt';

  @override
  String get manageClockOffset => 'Lệch giờ với server (giây)';

  @override
  String get manageRevokeHint =>
      'Gỡ ghép chỉ xóa ghép trên máy này. Để thu hồi hẳn, vào Quản lý thiết bị trên trang quản trị.';

  @override
  String get manageUnpair => 'Gỡ ghép';

  @override
  String get manageUnpairConfirmTitle => 'Gỡ ghép máy này?';

  @override
  String get manageUnpairConfirmBody =>
      'Máy sẽ quên server và cần ghép lại bằng mã mới.';

  @override
  String get cancel => 'Hủy';

  @override
  String get modeWaiter => 'Phục vụ';

  @override
  String get modeKds => 'Màn bếp';

  @override
  String get modeExpo => 'Chạy bàn';

  @override
  String get modeKiosk => 'Kiosk';

  @override
  String get modePrintStation => 'Trạm in';

  @override
  String get modeOwner => 'Chủ quán';

  @override
  String modePlaceholderBody(String mode) {
    return 'Chế độ $mode sẽ có trong bản cập nhật sau. Máy đã ghép và đang kết nối với server.';
  }

  @override
  String get realtimeConnected => 'Trực tuyến';

  @override
  String get realtimeConnecting => 'Đang kết nối';

  @override
  String get realtimeDisconnected => 'Mất kết nối';

  @override
  String get realtimeRejected => 'Bị từ chối';

  @override
  String get realtimeIdle => 'Chưa kết nối';

  @override
  String get stationIosWarning =>
      'iPhone/iPad không chạy nền được: giữ app mở và màn hình sáng để in.';

  @override
  String stationServerError(String message) {
    return 'Chưa gọi được server: $message';
  }

  @override
  String get stationPrinters => 'Máy in';

  @override
  String get stationNoPrinters =>
      'Chưa nhận việc in nào. Máy in sẽ hiện ở đây sau phiếu đầu tiên, hoặc khi in thử từ trang quản trị.';

  @override
  String get stationTestPrint => 'In thử';

  @override
  String get stationRecent => 'Việc in gần đây';

  @override
  String get stationNoJobs => 'Chưa có việc in.';

  @override
  String get stationLocalTest => 'in thử tại máy';

  @override
  String get stationPrinted => 'Đã in';

  @override
  String stationFailed(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get stationTestTitle => 'IN THỬ';

  @override
  String get stationTestSample =>
      'Tiếng Việt: Phở bò tái, cà phê sữa đá, bánh mì.';

  @override
  String get stationTestDone => 'Đã gửi trang in thử.';

  @override
  String get stationForegroundTitle => 'Trạm in ParkViet';

  @override
  String get stationForegroundText => 'Đang nhận việc in';

  @override
  String get kdsTabPriority => 'Ưu tiên';

  @override
  String get kdsTabByItem => 'Theo món';

  @override
  String get kdsTabByOrder => 'Theo bàn / số gọi';

  @override
  String get kdsDone => 'Đã xong (30 phút gần nhất)';

  @override
  String get kdsNothingOpen => 'Chưa có món nào cần làm.';

  @override
  String get kdsNothingDone => 'Chưa có phiếu nào xong.';

  @override
  String get kdsStart => 'Bắt đầu';

  @override
  String get kdsReady => 'Xong';

  @override
  String get kdsServe => 'Đã ra món';

  @override
  String get kdsRecall => 'Gọi lại';

  @override
  String get kdsBump => 'Xong cả phiếu';

  @override
  String get kdsServeOrder => 'Đã giao';

  @override
  String kdsGuest(String name) {
    return 'Khách: $name';
  }

  @override
  String get kdsPlatformGrabfood => 'GRABFOOD';

  @override
  String get kdsPlatformShopeefood => 'SHOPEEFOOD';

  @override
  String kdsPickupCode(String code) {
    return 'Mã lấy: $code';
  }

  @override
  String kdsTicketNumber(int number) {
    return 'Phiếu #$number';
  }

  @override
  String kdsOrder(String id) {
    return 'Đơn $id';
  }

  @override
  String kdsTickets(String numbers) {
    return 'Phiếu $numbers';
  }

  @override
  String kdsNote(String note) {
    return 'Ghi chú: $note';
  }

  @override
  String kdsOffline(String time) {
    return 'Mất kết nối · cập nhật lúc $time';
  }

  @override
  String get kdsOfflineNever => 'Mất kết nối · chưa tải được bếp';

  @override
  String kdsActionFailed(String message) {
    return 'Không đổi được món: $message';
  }

  @override
  String get kdsStationPick => 'Màn này hiện trạm nào?';

  @override
  String get kdsAllStations => 'Tất cả trạm';

  @override
  String get kdsChangeStation => 'Đổi trạm';

  @override
  String get kdsNoStations =>
      'Chi nhánh chưa có trạm bếp. Thêm trạm trên trang quản trị, mục Bếp & bar.';

  @override
  String get kdsSoldOut => 'Hết món';

  @override
  String get kdsSoldOutTitle => 'Hết món hôm nay';

  @override
  String get kdsSoldOutWho => 'Ai báo hết món?';

  @override
  String kdsPinFor(String name) {
    return 'Mã PIN của $name';
  }

  @override
  String get kdsConfirm => 'Xác nhận';

  @override
  String get kdsStatusNew => 'Mới';

  @override
  String get kdsStatusPreparing => 'Đang làm';

  @override
  String get kdsStatusReady => 'Đã xong';

  @override
  String get kdsStatusServed => 'Đã ra';

  @override
  String get kdsStatusVoided => 'Đã hủy';

  @override
  String get kdsModeCounter => 'Tại quầy';

  @override
  String get kdsModeDineIn => 'Tại bàn';

  @override
  String get kdsModeTakeaway => 'Mang đi';

  @override
  String get kdsModeDelivery => 'Giao hàng';

  @override
  String get kdsDoneHint => 'Giữ một món để gọi lại món đã xong hoặc đã ra.';

  @override
  String kdsRecalled(int count) {
    return 'Gọi lại $count lần';
  }

  @override
  String get kdsAllDayOne => 'Xong 1';

  @override
  String kdsAllDayAll(int count) {
    return 'Xong hết ($count)';
  }

  @override
  String get kdsServiceModeAll => 'Mọi kiểu phục vụ';

  @override
  String get kdsServiceModeFilter => 'Lọc theo kiểu phục vụ';

  @override
  String get kdsStationExpo => 'Trạm ra món (expo)';

  @override
  String get kdsStationPickHint =>
      'Chọn một hoặc nhiều trạm. Lựa chọn được giữ trên máy này.';

  @override
  String kdsStationShow(int count) {
    return 'Hiện $count trạm';
  }

  @override
  String get expoNothingReady => 'Chưa có món nào chờ ra.';

  @override
  String get expoServeAll => 'Ra cả đơn';

  @override
  String get modifierVariant => 'Cỡ / loại';

  @override
  String get modifierNote => 'Ghi chú cho bếp';

  @override
  String modifierAdd(String amount) {
    return 'Thêm · $amount';
  }

  @override
  String modifierPickExactly(int count) {
    return 'Chọn $count';
  }

  @override
  String modifierPickBetween(int min, int max) {
    return 'Chọn từ $min đến $max';
  }

  @override
  String modifierPickUpTo(int max) {
    return 'Chọn tối đa $max';
  }

  @override
  String get voidReasonChangedMind => 'Khách đổi ý';

  @override
  String get voidReasonSoldOut => 'Hết món';

  @override
  String get voidReasonMistake => 'Nhập nhầm';

  @override
  String get voidReasonSpoiled => 'Làm hỏng';

  @override
  String get voidReasonOther => 'Khác (ghi lý do)';

  @override
  String get waiterAllAreas => 'Mọi khu';

  @override
  String get waiterFilterAll => 'Tất cả';

  @override
  String get waiterFilterFree => 'Trống';

  @override
  String get waiterFilterSeated => 'Có khách';

  @override
  String get waiterFilterWaiting => 'Chờ món';

  @override
  String get waiterFilterPayment => 'Yêu cầu thanh toán';

  @override
  String get waiterFilterMine => 'Của tôi';

  @override
  String get waiterNoTables => 'Không có bàn nào.';

  @override
  String get waiterStateFree => 'Trống';

  @override
  String get waiterStateSeated => 'Có khách';

  @override
  String get waiterStateOrdered => 'Đang phục vụ';

  @override
  String get waiterStateWaitingLong => 'Chờ lâu';

  @override
  String get waiterStatePayment => 'Gọi thanh toán';

  @override
  String get waiterStatePrebilled => 'Đã in tạm tính';

  @override
  String get waiterStateCleaning => 'Đang dọn';

  @override
  String get waiterStateOut => 'Ngưng phục vụ';

  @override
  String waiterGuests(int count) {
    return '$count khách';
  }

  @override
  String waiterSeatedMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String waiterPendingItems(int count) {
    return '$count món chờ';
  }

  @override
  String get waiterPaymentRequested => 'Đã gọi thanh toán';

  @override
  String waiterOrders(int count) {
    return '$count đơn';
  }

  @override
  String waiterPickOrder(String table) {
    return '$table: chọn đơn';
  }

  @override
  String waiterOrderLetter(String letter) {
    return 'Đơn $letter';
  }

  @override
  String get waiterSecondOrder => 'Mở thêm đơn trên bàn này';

  @override
  String get waiterPin => 'Ghim bàn (nhận báo món xong)';

  @override
  String get waiterUnpin => 'Bỏ ghim bàn';

  @override
  String get waiterFollowTitle => 'Nhận báo món xong';

  @override
  String get waiterFollowHint => 'Mặc định: bàn bạn gọi món và bàn đã ghim.';

  @override
  String get waiterFollowMine => 'Chỉ bàn của tôi';

  @override
  String waiterFollowArea(String area) {
    return 'Mọi bàn trong khu $area';
  }

  @override
  String waiterReadyCount(int count) {
    return 'Có $count món đã xong, chạm để mở bàn';
  }

  @override
  String waiterReadyNotice(String table, String name, String quantity) {
    return '$table: $name ×$quantity đã xong';
  }

  @override
  String get waiterClose => 'Đóng';

  @override
  String waiterGuestsFor(String table) {
    return 'Số khách · $table';
  }

  @override
  String waiterCapacity(int count) {
    return 'Bàn $count chỗ';
  }

  @override
  String get waiterOpenTable => 'Mở bàn';

  @override
  String waiterOrderFor(String table) {
    return 'Gọi món · $table';
  }

  @override
  String get waiterSearch => 'Tìm món';

  @override
  String get waiterAllCategories => 'Tất cả';

  @override
  String get waiterNoDishes => 'Không có món nào.';

  @override
  String get waiterSoldOutLabel => 'Hết món';

  @override
  String waiterCart(int count, String amount) {
    return '$count món · $amount';
  }

  @override
  String get waiterAddToOrder => 'Thêm vào đơn';

  @override
  String get waiterAddAndSend => 'Thêm và báo bếp';

  @override
  String get waiterAdded => 'Đã thêm vào đơn.';

  @override
  String get waiterAddedAndSent => 'Đã thêm và báo bếp.';

  @override
  String get waiterSent => 'Đã báo bếp.';

  @override
  String get waiterOrderDishes => 'Gọi món';

  @override
  String get waiterSend => 'Báo bếp';

  @override
  String waiterSendCount(int count) {
    return 'Báo bếp ($count)';
  }

  @override
  String waiterSubtotal(String amount) {
    return 'Tạm tính $amount';
  }

  @override
  String get waiterEmptyOrder => 'Chưa có món nào. Bấm \"Gọi món\".';

  @override
  String waiterLineUnsent(String count) {
    return '$count chưa báo bếp';
  }

  @override
  String waiterLineNew(String count) {
    return '$count mới';
  }

  @override
  String waiterLinePreparing(String count) {
    return '$count đang làm';
  }

  @override
  String waiterLineReady(String count) {
    return '$count xong';
  }

  @override
  String waiterLineServed(String count) {
    return '$count đã ra';
  }

  @override
  String get waiterVoidSent => 'Hủy món đã báo bếp';

  @override
  String get waiterRemoveUnsent => 'Xóa món chưa báo bếp';

  @override
  String get waiterVoided => 'Đã hủy món.';

  @override
  String waiterVoidTitle(String name) {
    return 'Hủy $name';
  }

  @override
  String waiterVoidSentCount(int count) {
    return 'Bếp đã nhận $count.';
  }

  @override
  String get waiterVoidNote => 'Ghi chú';

  @override
  String get waiterVoidNoteRequired => 'Lý do (bắt buộc)';

  @override
  String get waiterVoidConfirm => 'Hủy món';

  @override
  String get waiterWaitingApproval =>
      'Chờ quản lý duyệt. Quản lý cấp mã duyệt cho đơn này, mã sẽ tự điền khi có, hoặc nhập mã bên dưới.';

  @override
  String get waiterApprovalCode => 'Mã duyệt';

  @override
  String get waiterRequestPayment => 'Yêu cầu thanh toán';

  @override
  String get waiterPaymentRequestSent => 'Đã báo thu ngân.';

  @override
  String get waiterMove => 'Chuyển bàn';

  @override
  String get waiterMerge => 'Gộp bàn';

  @override
  String get waiterMoveTo => 'Chuyển sang bàn trống';

  @override
  String get waiterMergeInto => 'Gộp vào đơn của bàn';

  @override
  String get waiterMoved => 'Đã chuyển bàn.';

  @override
  String get waiterMerged => 'Đã gộp bàn.';

  @override
  String get waiterChecklist => 'In phiếu kiểm đồ';

  @override
  String get waiterPrebill => 'In tạm tính';

  @override
  String waiterPrintQueued(String printer) {
    return 'Đã gửi in tới $printer.';
  }

  @override
  String waiterPrinted(String printer) {
    return 'Đã in trên $printer.';
  }

  @override
  String waiterPrintFailed(String error) {
    return 'Không in được: $error';
  }

  @override
  String get waiterNoPrinter => 'Chưa có máy in cho phiếu này';

  @override
  String get waiterLineChanged =>
      'Món này vừa được người khác sửa. Đã tải lại đơn.';

  @override
  String get waiterSnapshotLocked =>
      'Đơn đang chờ thanh toán nên không đổi được. Đã tải lại đơn.';

  @override
  String get waiterLeaseBusy =>
      'Máy khác đang sửa đơn này. Thử lại sau ít phút.';

  @override
  String get waiterWorkspaceClosed => 'Đơn đã đóng.';

  @override
  String get waiterSoldOut => 'Món này đã hết.';

  @override
  String get waiterTableOccupied => 'Bàn đã có khách.';

  @override
  String get waiterTableUnavailable => 'Bàn không phục vụ lúc này.';

  @override
  String get waiterGuestCountInvalid => 'Số khách không hợp lệ cho bàn này.';

  @override
  String get waiterModifierInvalid =>
      'Lựa chọn của món không hợp lệ. Mở lại món để chọn.';

  @override
  String get waiterVoidQuantityInvalid => 'Số lượng hủy không hợp lệ.';

  @override
  String get waiterVoidReasonInvalid =>
      'Chọn lý do hủy, hoặc ghi lý do khi chọn \"Khác\".';

  @override
  String get waiterForbidden =>
      'Bạn không có quyền làm việc này trên máy phục vụ.';

  @override
  String get checklistTitle => 'Thiết bị đã ghép';

  @override
  String checklistIntro(String branch) {
    return 'Máy đã ghép vào $branch. Kiểm tra các mục dưới đây trước khi dùng.';
  }

  @override
  String get checklistStation => 'Trạm bếp';

  @override
  String checklistStationOk(String name) {
    return 'Đã chọn: $name';
  }

  @override
  String get checklistStationMissing =>
      'Chưa chọn trạm. Chọn trạm trên màn bếp sau khi bắt đầu.';

  @override
  String get checklistPrinter => 'Máy in của trạm';

  @override
  String checklistPrinterOk(String name) {
    return 'Đã nhận: $name';
  }

  @override
  String get checklistPrinterMissing =>
      'Trạm chưa có máy in; phiếu chỉ hiện trên màn hình. Gán máy in ở trang chi nhánh, tab Bếp & bar.';

  @override
  String get checklistStaff => 'Nhân viên có PIN';

  @override
  String checklistStaffOk(int count) {
    return '$count người đăng nhập được bằng PIN';
  }

  @override
  String get checklistStaffMissing =>
      'Chưa ai có PIN. Quản lý đặt PIN cho nhân viên trên trang quản trị.';

  @override
  String get checklistNothing => 'Chế độ này không cần chuẩn bị thêm.';

  @override
  String get checklistStart => 'Bắt đầu dùng';

  @override
  String get courseNone => 'Không chia lượt';

  @override
  String get courseStarter => 'Khai vị';

  @override
  String get courseMain => 'Món chính';

  @override
  String get courseDessert => 'Tráng miệng';

  @override
  String courseNumber(int number) {
    return 'Lượt $number';
  }

  @override
  String get courseHold => 'Giữ lại, chờ gọi';

  @override
  String get courseHeldTitle => 'Đang giữ, chờ gọi món';

  @override
  String courseFire(String course, int count) {
    return 'Gọi $course ($count món)';
  }

  @override
  String courseFired(String course) {
    return 'Đã gửi bếp: $course';
  }

  @override
  String get seatLabel => 'Ghế';

  @override
  String get seatShared => 'Dùng chung';

  @override
  String seatNumber(int seat) {
    return 'Ghế $seat';
  }

  @override
  String get expoHeldTitle => 'Chờ gọi món';

  @override
  String get expoReadyTitle => 'Đã xong, cần mang ra';

  @override
  String get expoAllAreas => 'Tất cả khu';

  @override
  String expoArea(int number) {
    return 'Khu $number';
  }

  @override
  String get ownerReservationsTitle => 'Đặt bàn hôm nay';

  @override
  String get ownerNoReservations => 'Hôm nay chưa có lượt đặt bàn.';

  @override
  String ownerDeposit(String amount, String status) {
    return 'Cọc $amount · $status';
  }

  @override
  String get ownerRefund => 'Hoàn cọc';

  @override
  String get ownerForfeit => 'Giữ cọc';

  @override
  String ownerConfirmRefund(String amount, String name) {
    return 'Hoàn $amount cho $name?';
  }

  @override
  String ownerConfirmForfeit(String amount, String name) {
    return 'Giữ cọc $amount của $name? Khoản cọc thành một hóa đơn phí giữ chỗ có thuế.';
  }

  @override
  String get ownerConfirm => 'Xác nhận';

  @override
  String get ownerKeep => 'Thôi';

  @override
  String get ownerRefunded => 'Đã hoàn cọc.';

  @override
  String get ownerForfeited => 'Đã ghi nhận giữ cọc.';

  @override
  String get reservationBooked => 'Đã đặt';

  @override
  String get reservationSeated => 'Đã vào bàn';

  @override
  String get reservationCompleted => 'Đã xong';

  @override
  String get reservationNoShow => 'Không đến';

  @override
  String get reservationCanceled => 'Đã hủy';

  @override
  String get depositHeld => 'đang giữ';

  @override
  String get depositApplied => 'đã trừ vào hóa đơn';

  @override
  String get depositRefunded => 'đã hoàn';

  @override
  String get depositForfeited => 'đã giữ cọc';

  @override
  String get waiterTabsTitle => 'Tab đang mở';

  @override
  String get waiterTabOpen => 'Mở tab';

  @override
  String get waiterTabSearch => 'Tên khách, bàn hoặc số tab';

  @override
  String get waiterTabsNone => 'Chưa có tab nào đang mở.';

  @override
  String get waiterTabsNoMatch => 'Không có tab nào khớp.';

  @override
  String waiterTabOpenedAt(String time) {
    return 'Mở lúc $time';
  }

  @override
  String get waiterTabName => 'Tên hoặc mô tả khách';

  @override
  String get waiterTabNameTaken => 'Đã có tab đang mở với tên này.';

  @override
  String get waiterTabNameInvalid => 'Nhập tên tab (tối đa 60 ký tự).';

  @override
  String get waiterBottleTitle => 'Rót rượu gửi';

  @override
  String get waiterBottleCode => 'Mã chai';

  @override
  String get waiterBottleNotFound => 'Không thấy chai gửi với mã này.';

  @override
  String waiterBottleLevel(int level) {
    return 'Còn $level%';
  }

  @override
  String waiterBottleNewLevel(int level) {
    return 'Mức còn sau khi rót: $level%';
  }

  @override
  String get waiterBottleMl => 'Số ml đã rót (không bắt buộc)';

  @override
  String get waiterBottlePour => 'Rót';

  @override
  String waiterBottlePoured(int level) {
    return 'Đã rót, chai còn $level%.';
  }

  @override
  String get waiterBottleClosed => 'Phiếu gửi này đã kết thúc.';

  @override
  String get waiterBottleLevelRaised =>
      'Rót không làm mức tăng; quản lý sửa mức nếu nhập sai.';

  @override
  String get waiterRoomsTitle => 'Phòng';

  @override
  String get waiterRoomsNone => 'Chi nhánh chưa có phòng hay bàn chơi.';

  @override
  String get waiterStatePlaying => 'Đang tính giờ';

  @override
  String get waiterStateEndingSoon => 'Sắp hết giờ';

  @override
  String get waiterClockStart => 'Bắt đầu tính giờ';

  @override
  String get waiterClockStop => 'Dừng giờ';

  @override
  String waiterClockStopConfirm(String room) {
    return 'Dừng giờ $room? Tiền giờ được chốt theo giờ máy chủ.';
  }

  @override
  String get waiterClockMove => 'Chuyển phòng';

  @override
  String waiterClockMoveTo(String room) {
    return 'Chuyển $room sang';
  }

  @override
  String get waiterClockMoveNone => 'Không có phòng trống để chuyển.';

  @override
  String get waiterClockOpenOrder => 'Mở đơn của phòng';

  @override
  String waiterClockQuote(String amount) {
    return 'Tạm tính $amount';
  }

  @override
  String waiterClockStopped(String amount) {
    return 'Đã dừng giờ, tiền giờ $amount.';
  }

  @override
  String get waiterClockRunning => 'Phòng này đang tính giờ.';

  @override
  String get waiterClockNoRatePlan =>
      'Phòng này chưa có bảng giá giờ. Báo quản lý thêm bảng giá.';

  @override
  String get waiterClockPickOrder =>
      'Phòng có nhiều đơn mở; chọn đơn cần tính giờ.';

  @override
  String get waiterClockAlreadyStopped => 'Giờ của phòng này đã dừng.';

  @override
  String get waiterClockPause => 'Tạm dừng giờ';

  @override
  String get waiterClockResume => 'Tính giờ tiếp';

  @override
  String get waiterClockPaused => 'Đang tạm dừng';

  @override
  String get waiterClockAlreadyPaused => 'Giờ của phòng này đang tạm dừng.';

  @override
  String get waiterClockNotPaused => 'Giờ của phòng này không tạm dừng.';

  @override
  String get waiterClockLongPause =>
      'Tạm dừng quá lâu: cần quản lý duyệt tại quầy để tính giờ tiếp.';

  @override
  String waiterClockPackageLeft(int minutes) {
    return 'Gói còn $minutes phút';
  }

  @override
  String get waiterServeRoom => 'Tôi phục vụ phòng này';

  @override
  String waiterServingRoom(String room) {
    return 'Đã nhận phục vụ $room.';
  }

  @override
  String get waiterAttendantBusy => 'Bạn đang phục vụ một phòng khác.';

  @override
  String waiterAlertEndingSoon(String room) {
    return '$room còn 10 phút';
  }

  @override
  String waiterAlertEndedPackage(String room) {
    return '$room đã hết gói giờ';
  }

  @override
  String waiterAlertPauseTooLong(String room) {
    return '$room tạm dừng quá lâu';
  }

  @override
  String get waiterGuestTitle => 'Đơn từ QR';

  @override
  String get waiterGuestAllAreas => 'Mọi khu';

  @override
  String get waiterGuestMyArea => 'Khu tôi theo dõi';

  @override
  String get waiterGuestEmpty =>
      'Không có đơn hay yêu cầu nào của khách đang chờ.';

  @override
  String waiterGuestWaiting(int count) {
    return '$count đang chờ';
  }

  @override
  String get waiterGuestAccept => 'Duyệt';

  @override
  String get waiterGuestReject => 'Từ chối';

  @override
  String get waiterGuestRejectTitle => 'Lý do từ chối';

  @override
  String get waiterGuestRejectHint =>
      'Khách đọc được lý do này trên điện thoại.';

  @override
  String get waiterGuestRejectSoldOut => 'Món đã hết';

  @override
  String get waiterGuestRejectKitchenClosed => 'Bếp đã đóng';

  @override
  String get waiterGuestRejectAskStaff => 'Vui lòng gọi nhân viên';

  @override
  String waiterGuestAccepted(String table) {
    return 'Đã thêm vào đơn $table và báo bếp.';
  }

  @override
  String waiterGuestRejected(String table) {
    return 'Đã từ chối đơn của $table.';
  }

  @override
  String waiterGuestCallStaff(String table) {
    return '$table gọi phục vụ';
  }

  @override
  String waiterGuestRequestBill(String table) {
    return '$table yêu cầu thanh toán';
  }

  @override
  String get waiterGuestDone => 'Đã xử lý';

  @override
  String get waiterGuestNoDecide =>
      'Bạn chưa có quyền duyệt đơn khách gọi qua QR.';

  @override
  String get waiterGuestArrived => 'Khách vừa gọi món hoặc gọi phục vụ qua QR';

  @override
  String get kioskWelcomeTitle => 'Xin chào! Chạm để gọi món';

  @override
  String get kioskWelcomeHint =>
      'Tự chọn món, trả bằng QR chuyển khoản hoặc trả tại quầy.';

  @override
  String get kioskStart => 'Bắt đầu gọi món';

  @override
  String get kioskPausedTitle => 'Kiosk đang tạm dừng';

  @override
  String get kioskPausedBody => 'Xin mời bạn gọi món tại quầy thu ngân.';

  @override
  String get kioskReconnecting => 'Đang kết nối lại máy chủ…';

  @override
  String get kioskSoldOut => 'Hết món';

  @override
  String get kioskAllItems => 'Tất cả món';

  @override
  String kioskCartButton(int count, String amount) {
    return 'Giỏ hàng · $count món · $amount';
  }

  @override
  String get kioskCartTitle => 'Giỏ hàng của bạn';

  @override
  String get kioskBackToMenu => 'Gọi thêm món';

  @override
  String kioskEstimate(String amount) {
    return 'Tạm tính $amount';
  }

  @override
  String get kioskEstimateHint =>
      'Số tiền chính xác hiện ngay khi bạn đặt đơn.';

  @override
  String get kioskChoosePayment => 'Bạn muốn trả thế nào?';

  @override
  String get kioskPayQr => 'Trả bằng QR chuyển khoản';

  @override
  String get kioskPayCounter => 'Trả tại quầy';

  @override
  String kioskLess(String name) {
    return 'Bớt $name';
  }

  @override
  String kioskMore(String name) {
    return 'Thêm $name';
  }

  @override
  String get kioskCartFull => 'Giỏ hàng đã đủ món; hãy đặt đơn này trước.';

  @override
  String kioskQrTitle(String amount) {
    return 'Quét mã để trả $amount';
  }

  @override
  String get kioskQrImage => 'Mã QR chuyển khoản';

  @override
  String kioskQrAccount(String bank, String account, String name) {
    return '$bank · $account · $name';
  }

  @override
  String kioskQrNote(String note) {
    return 'Nội dung chuyển khoản: $note';
  }

  @override
  String kioskQrLeft(int seconds) {
    return 'Mã còn hiệu lực $seconds giây';
  }

  @override
  String get kioskQrWaiting => 'Đang chờ ngân hàng báo đã nhận tiền…';

  @override
  String get kioskQrInstead => 'Trả tại quầy thay vì QR';

  @override
  String get kioskDoneTitle => 'Cảm ơn bạn!';

  @override
  String get kioskCallNumberLabel => 'Số gọi món của bạn';

  @override
  String get kioskDonePaid =>
      'Đã nhận tiền. Quán đang làm món; nghe gọi số này để nhận.';

  @override
  String get kioskDoneCounter =>
      'Mời bạn ra quầy thu ngân và đọc số này để trả tiền.';

  @override
  String get kioskNextGuest => 'Xong';

  @override
  String get kioskStillThere => 'Bạn còn đó không?';

  @override
  String kioskStillThereBody(int seconds) {
    return 'Đơn sẽ được hủy sau $seconds giây.';
  }

  @override
  String get kioskStillHere => 'Tôi vẫn ở đây';

  @override
  String get kioskStartOver => 'Hủy và làm lại';

  @override
  String get kioskLanguageSwitch => 'English';

  @override
  String get kioskNotLocked =>
      'Màn hình chưa được khóa vào ứng dụng. Quản lý: bật ghim màn hình (Android) hoặc Guided Access (iOS).';

  @override
  String get kioskLowReach => 'Đưa nút xuống thấp';

  @override
  String get kioskFailureSoldOut =>
      'Có món vừa hết. Vui lòng bỏ món đó khỏi giỏ.';

  @override
  String get kioskFailurePaused =>
      'Kiosk vừa tạm dừng. Xin mời gọi món tại quầy.';

  @override
  String get kioskFailureQrUnavailable =>
      'Hiện chưa trả được bằng QR. Bạn có thể trả tại quầy.';

  @override
  String get kioskFailureGeneric =>
      'Chưa đặt được đơn. Vui lòng thử lại hoặc gọi nhân viên.';

  @override
  String get manageKioskUnlock => 'Mở khóa màn hình kiosk';

  @override
  String get manageKioskUnlockHint =>
      'Cho phép thoát ứng dụng để bảo trì. Kiosk tự khóa lại khi mở lại chế độ kiosk.';

  @override
  String get manageKioskUnlocked => 'Đã mở khóa màn hình kiosk.';

  @override
  String get manageKioskUnlockFailed =>
      'Thiết bị không mở khóa được; tắt chế độ ghim màn hình hoặc Guided Access trong cài đặt máy.';

  @override
  String get waiterAskOwner => 'Gửi chủ duyệt';

  @override
  String get waiterAskedOwner => 'Đã gửi chủ duyệt, đang chờ trả lời.';

  @override
  String get waiterOwnerDeclined => 'Chủ quán đã từ chối.';

  @override
  String waiterOwnerDeclinedReason(String reason) {
    return 'Chủ quán đã từ chối: $reason';
  }

  @override
  String get waiterOwnerExpired =>
      'Yêu cầu đã hết hạn hoặc đơn đã đổi; gửi lại nếu cần.';

  @override
  String get ownerTabToday => 'Hôm nay';

  @override
  String get ownerTabOpen => 'Đang mở';

  @override
  String get ownerTabApprovals => 'Duyệt';

  @override
  String get ownerTabReservations => 'Đặt bàn';

  @override
  String get ownerTabAlerts => 'Cảnh báo';

  @override
  String get ownerNoBranches =>
      'Bạn chưa được giao chi nhánh nào để xem hoặc duyệt.';

  @override
  String get ownerNoReports =>
      'Bạn không có quyền xem báo cáo ở chi nhánh này.';

  @override
  String get ownerNoApprove => 'Bạn không có quyền duyệt ở chi nhánh này.';

  @override
  String get ownerNoPending => 'Không có yêu cầu nào đang chờ.';

  @override
  String get ownerNoAlerts => 'Chưa có cảnh báo trong 24 giờ qua.';

  @override
  String get ownerNoOpen => 'Không có đơn nào đang mở.';

  @override
  String get ownerSales => 'Doanh thu';

  @override
  String get ownerNetSales => 'Doanh thu thuần';

  @override
  String get ownerOrders => 'Số đơn';

  @override
  String get ownerOpenOrders => 'Đơn đang mở';

  @override
  String get ownerOpenShifts => 'Ca đang mở';

  @override
  String get ownerCanceled => 'Đơn hủy';

  @override
  String ownerVoided(int count) {
    return '$count món hủy';
  }

  @override
  String get ownerBySource => 'Theo kênh';

  @override
  String ownerSourceOrders(int count) {
    return '$count đơn';
  }

  @override
  String get ownerByHour => 'Theo giờ';

  @override
  String get ownerSourceCounter => 'Tại quầy';

  @override
  String get ownerSourceKiosk => 'Kiosk';

  @override
  String get ownerSourceOther => 'Khác';

  @override
  String get ownerTakeaway => 'Mang đi';

  @override
  String ownerMinutesOpen(int minutes) {
    return '$minutes phút';
  }

  @override
  String ownerKitchenLate(int count) {
    return '$count món trễ bếp';
  }

  @override
  String ownerKitchenWaiting(int count) {
    return '$count món chờ bếp';
  }

  @override
  String ownerRequestedBy(String name) {
    return '$name xin duyệt';
  }

  @override
  String ownerRequestReason(String reason) {
    return 'Lý do: $reason';
  }

  @override
  String ownerRequestExpires(String time) {
    return 'Hết hạn lúc $time';
  }

  @override
  String get ownerGrant => 'Đồng ý';

  @override
  String get ownerDecline => 'Từ chối';

  @override
  String get ownerGrantBiometricReason => 'Xác nhận để duyệt yêu cầu';

  @override
  String get ownerGrantNotConfirmed =>
      'Chưa xác nhận được vân tay hoặc khuôn mặt.';

  @override
  String ownerGrantConfirm(String action) {
    return 'Duyệt: $action?';
  }

  @override
  String get ownerDeclineTitle => 'Từ chối yêu cầu';

  @override
  String get ownerDeclineReason => 'Lý do (không bắt buộc)';

  @override
  String get ownerGranted => 'Đã duyệt; máy gửi sẽ tự tiếp tục.';

  @override
  String get ownerDeclined => 'Đã từ chối.';

  @override
  String get ownerRequestExpired => 'Yêu cầu đã hết hạn hoặc đơn đã đổi.';

  @override
  String get ownerRequestCanceled => 'Người gửi đã hủy yêu cầu.';

  @override
  String get ownerSelfApproval => 'Bạn không thể tự duyệt yêu cầu của mình.';

  @override
  String get ownerAlreadyDecided => 'Yêu cầu này đã được trả lời.';

  @override
  String get ownerActionDiscount => 'Giảm giá đơn';

  @override
  String get ownerActionLineDiscount => 'Giảm giá món';

  @override
  String get ownerActionOverridePrice => 'Đổi giá món';

  @override
  String get ownerActionPrebill => 'In lại hoặc hủy phiếu tạm tính';

  @override
  String get ownerActionVoid => 'Hủy món đã gửi bếp';

  @override
  String get ownerActionPlatformCancel => 'Hủy đơn app giao hàng';

  @override
  String get ownerActionBuffet => 'Đổi lượt buffet';

  @override
  String get ownerActionMinimumSpend => 'Miễn chi tiêu tối thiểu';

  @override
  String get ownerActionTimedEdit => 'Sửa giờ tính tiền';

  @override
  String get ownerActionLongPause => 'Tạm dừng giờ lâu';

  @override
  String get ownerActionDepositRefund => 'Hoàn cọc đặt bàn';

  @override
  String get ownerActionDepositForfeit => 'Giữ cọc đặt bàn';

  @override
  String get ownerActionBottleKeep => 'Điều chỉnh chai gửi';

  @override
  String get ownerActionMealWallet => 'Ví suất ăn';

  @override
  String get ownerActionCommission => 'Điều chỉnh hoa hồng xe';

  @override
  String get ownerActionStoredValue => 'Thẻ trả trước';

  @override
  String ownerAlertKitchenLate(String minutes) {
    return 'Món chờ bếp $minutes phút';
  }

  @override
  String ownerAlertShiftVariance(String amount) {
    return 'Chênh lệch két khi đóng ca: $amount';
  }

  @override
  String ownerAlertVoidBurst(String count) {
    return '$count món bị hủy trong một giờ';
  }

  @override
  String ownerAlertRevenue(String percent) {
    return 'Doanh thu năm đạt $percent% ngưỡng 1 tỷ';
  }

  @override
  String get ownerAlertPrintFailed => 'Một lệnh in bị lỗi';

  @override
  String get ownerAlertEinvoiceFailed => 'Một hóa đơn điện tử bị lỗi';

  @override
  String get ownerPushTitle => 'Thông báo nền';

  @override
  String get ownerPushToggle => 'Nhận thông báo khi app đóng';

  @override
  String get ownerPushNoToken =>
      'Bản cài này chưa có thông báo nền; bạn chỉ nhận sự kiện khi app đang mở.';

  @override
  String get ownerPushNoRelay =>
      'Cửa hàng chưa cài dịch vụ chuyển tiếp thông báo; bạn chỉ nhận sự kiện khi app đang mở.';

  @override
  String get ownerPushReady =>
      'Thông báo chỉ mang loại sự kiện, không kèm số tiền hay tên khách.';

  @override
  String ownerPushLastError(String error) {
    return 'Lỗi gần nhất: $error';
  }
}
