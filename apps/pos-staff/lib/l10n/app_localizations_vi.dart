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
  String get modeBridge => 'Cầu nối thiết bị';

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
}
