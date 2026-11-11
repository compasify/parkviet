import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'ParkViet Nhân viên'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghép máy với cửa hàng'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In vi, this message translates to:
  /// **'Mở Quản lý thiết bị trên trang quản trị, tạo mã ghép, rồi quét mã QR hoặc nhập địa chỉ server và mã.'**
  String get welcomeBody;

  /// No description provided for @welcomeScan.
  ///
  /// In vi, this message translates to:
  /// **'Quét QR ghép máy'**
  String get welcomeScan;

  /// No description provided for @welcomeManual.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ server và mã'**
  String get welcomeManual;

  /// No description provided for @revokedNotice.
  ///
  /// In vi, this message translates to:
  /// **'Máy này đã bị thu hồi hoặc gỡ ghép trên server. Hãy ghép lại.'**
  String get revokedNotice;

  /// No description provided for @scanTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quét QR ghép máy'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In vi, this message translates to:
  /// **'Đưa mã QR trên màn hình quản lý vào khung hình.'**
  String get scanHint;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được camera. Hãy cho phép dùng camera, hoặc quay lại và nhập mã bằng tay.'**
  String get scanCameraUnavailable;

  /// No description provided for @pairingWorking.
  ///
  /// In vi, this message translates to:
  /// **'Đang ghép máy…'**
  String get pairingWorking;

  /// No description provided for @manualTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ server'**
  String get manualTitle;

  /// No description provided for @manualServerLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ server'**
  String get manualServerLabel;

  /// No description provided for @manualServerHint.
  ///
  /// In vi, this message translates to:
  /// **'http://192.168.1.10 hoặc https://pos.quan-a.vn'**
  String get manualServerHint;

  /// No description provided for @manualCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã ghép'**
  String get manualCodeLabel;

  /// No description provided for @manualNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên máy'**
  String get manualNameLabel;

  /// No description provided for @manualSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Ghép máy'**
  String get manualSubmit;

  /// No description provided for @pairingNotPairingCode.
  ///
  /// In vi, this message translates to:
  /// **'Đây không phải mã QR ghép máy ParkViet.'**
  String get pairingNotPairingCode;

  /// No description provided for @pairingUnsupportedVersion.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR này thuộc phiên bản khác. Hãy cập nhật app.'**
  String get pairingUnsupportedVersion;

  /// No description provided for @pairingWrongKind.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR này không dùng để ghép thiết bị.'**
  String get pairingWrongKind;

  /// No description provided for @pairingInvalidUrl.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ server không hợp lệ. Cần bắt đầu bằng http:// hoặc https://.'**
  String get pairingInvalidUrl;

  /// No description provided for @pairingInsecureUrl.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ dùng http:// cho server trong mạng của quán (IP 192.168.x.x, 10.x.x.x, 172.16–31.x.x hoặc tên .local). Server trên internet phải dùng https://.'**
  String get pairingInsecureUrl;

  /// No description provided for @pairingMissingCode.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu mã ghép.'**
  String get pairingMissingCode;

  /// No description provided for @pairingCodeInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Mã ghép sai hoặc đã hết hạn. Hãy tạo mã mới.'**
  String get pairingCodeInvalid;

  /// No description provided for @failureTimeout.
  ///
  /// In vi, this message translates to:
  /// **'Server không trả lời kịp. Kiểm tra mạng rồi thử lại.'**
  String get failureTimeout;

  /// No description provided for @failureTls.
  ///
  /// In vi, this message translates to:
  /// **'Không tin được chứng chỉ bảo mật của server (HTTPS). Kiểm tra địa chỉ, hoặc nhờ người lắp đặt kiểm tra chứng chỉ.'**
  String get failureTls;

  /// No description provided for @failureCleartext.
  ///
  /// In vi, this message translates to:
  /// **'Máy này chặn kết nối không mã hóa (http://) tới địa chỉ đó.'**
  String get failureCleartext;

  /// No description provided for @failureUnreachable.
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được server. Kiểm tra địa chỉ và máy có cùng mạng với server không.'**
  String get failureUnreachable;

  /// No description provided for @failureUnauthorized.
  ///
  /// In vi, this message translates to:
  /// **'Server không nhận diện được máy hoặc phiên đăng nhập.'**
  String get failureUnauthorized;

  /// No description provided for @failureForbidden.
  ///
  /// In vi, this message translates to:
  /// **'Máy hoặc tài khoản này không có quyền làm việc đó.'**
  String get failureForbidden;

  /// No description provided for @failureNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy trên server.'**
  String get failureNotFound;

  /// No description provided for @failureRateLimited.
  ///
  /// In vi, this message translates to:
  /// **'Thử quá nhiều lần. Đợi một lát rồi thử lại.'**
  String get failureRateLimited;

  /// No description provided for @failureConflict.
  ///
  /// In vi, this message translates to:
  /// **'Server từ chối: {reason}'**
  String failureConflict(String reason);

  /// No description provided for @failureServer.
  ///
  /// In vi, this message translates to:
  /// **'Server gặp lỗi ({status}). Thử lại sau.'**
  String failureServer(int status);

  /// No description provided for @failureUnexpected.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi không mong đợi. Thử lại.'**
  String get failureUnexpected;

  /// No description provided for @pinIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'PIN không đúng.'**
  String get pinIncorrect;

  /// No description provided for @pinNotSet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt PIN. Đặt PIN trên trang quản trị trước.'**
  String get pinNotSet;

  /// No description provided for @pinLocked.
  ///
  /// In vi, this message translates to:
  /// **'Sai PIN quá nhiều lần. Khóa 15 phút trên máy này.'**
  String get pinLocked;

  /// No description provided for @pinRateLimited.
  ///
  /// In vi, this message translates to:
  /// **'Máy này nhập sai PIN quá nhiều. Đợi một lát.'**
  String get pinRateLimited;

  /// No description provided for @offlineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mất kết nối server'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In vi, this message translates to:
  /// **'Máy đã ghép với {serverUrl} nhưng chưa hỏi được server.'**
  String offlineBody(String serverUrl);

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @staffPickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tên của bạn'**
  String get staffPickerTitle;

  /// No description provided for @managerPickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý xác nhận'**
  String get managerPickerTitle;

  /// No description provided for @staffPickerEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chi nhánh chưa có nhân viên nào.'**
  String get staffPickerEmpty;

  /// No description provided for @pinTitle.
  ///
  /// In vi, this message translates to:
  /// **'PIN của {name}'**
  String pinTitle(String name);

  /// No description provided for @pinLabel.
  ///
  /// In vi, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @pinSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get pinSubmit;

  /// No description provided for @managerDenied.
  ///
  /// In vi, this message translates to:
  /// **'Người này không có quyền quản lý thiết bị.'**
  String get managerDenied;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @manageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin máy'**
  String get manageTitle;

  /// No description provided for @manageDeviceName.
  ///
  /// In vi, this message translates to:
  /// **'Tên máy'**
  String get manageDeviceName;

  /// No description provided for @manageMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ'**
  String get manageMode;

  /// No description provided for @manageBranch.
  ///
  /// In vi, this message translates to:
  /// **'Chi nhánh'**
  String get manageBranch;

  /// No description provided for @manageServer.
  ///
  /// In vi, this message translates to:
  /// **'Server'**
  String get manageServer;

  /// No description provided for @manageAppVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản app'**
  String get manageAppVersion;

  /// No description provided for @manageEditorId.
  ///
  /// In vi, this message translates to:
  /// **'Mã cài đặt'**
  String get manageEditorId;

  /// No description provided for @manageClockOffset.
  ///
  /// In vi, this message translates to:
  /// **'Lệch giờ với server (giây)'**
  String get manageClockOffset;

  /// No description provided for @manageRevokeHint.
  ///
  /// In vi, this message translates to:
  /// **'Gỡ ghép chỉ xóa ghép trên máy này. Để thu hồi hẳn, vào Quản lý thiết bị trên trang quản trị.'**
  String get manageRevokeHint;

  /// No description provided for @manageUnpair.
  ///
  /// In vi, this message translates to:
  /// **'Gỡ ghép'**
  String get manageUnpair;

  /// No description provided for @manageUnpairConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gỡ ghép máy này?'**
  String get manageUnpairConfirmTitle;

  /// No description provided for @manageUnpairConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Máy sẽ quên server và cần ghép lại bằng mã mới.'**
  String get manageUnpairConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @modeWaiter.
  ///
  /// In vi, this message translates to:
  /// **'Phục vụ'**
  String get modeWaiter;

  /// No description provided for @modeKds.
  ///
  /// In vi, this message translates to:
  /// **'Màn bếp'**
  String get modeKds;

  /// No description provided for @modeExpo.
  ///
  /// In vi, this message translates to:
  /// **'Chạy bàn'**
  String get modeExpo;

  /// No description provided for @modeKiosk.
  ///
  /// In vi, this message translates to:
  /// **'Kiosk'**
  String get modeKiosk;

  /// No description provided for @modePrintStation.
  ///
  /// In vi, this message translates to:
  /// **'Trạm in'**
  String get modePrintStation;

  /// No description provided for @modeOwner.
  ///
  /// In vi, this message translates to:
  /// **'Chủ quán'**
  String get modeOwner;

  /// No description provided for @modeBridge.
  ///
  /// In vi, this message translates to:
  /// **'Cầu nối thiết bị'**
  String get modeBridge;

  /// No description provided for @modePlaceholderBody.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ {mode} sẽ có trong bản cập nhật sau. Máy đã ghép và đang kết nối với server.'**
  String modePlaceholderBody(String mode);

  /// No description provided for @realtimeConnected.
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến'**
  String get realtimeConnected;

  /// No description provided for @realtimeConnecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối'**
  String get realtimeConnecting;

  /// No description provided for @realtimeDisconnected.
  ///
  /// In vi, this message translates to:
  /// **'Mất kết nối'**
  String get realtimeDisconnected;

  /// No description provided for @realtimeRejected.
  ///
  /// In vi, this message translates to:
  /// **'Bị từ chối'**
  String get realtimeRejected;

  /// No description provided for @realtimeIdle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa kết nối'**
  String get realtimeIdle;

  /// No description provided for @stationIosWarning.
  ///
  /// In vi, this message translates to:
  /// **'iPhone/iPad không chạy nền được: giữ app mở và màn hình sáng để in.'**
  String get stationIosWarning;

  /// No description provided for @stationServerError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gọi được server: {message}'**
  String stationServerError(String message);

  /// No description provided for @stationPrinters.
  ///
  /// In vi, this message translates to:
  /// **'Máy in'**
  String get stationPrinters;

  /// No description provided for @stationNoPrinters.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhận việc in nào. Máy in sẽ hiện ở đây sau phiếu đầu tiên, hoặc khi in thử từ trang quản trị.'**
  String get stationNoPrinters;

  /// No description provided for @stationTestPrint.
  ///
  /// In vi, this message translates to:
  /// **'In thử'**
  String get stationTestPrint;

  /// No description provided for @stationRecent.
  ///
  /// In vi, this message translates to:
  /// **'Việc in gần đây'**
  String get stationRecent;

  /// No description provided for @stationNoJobs.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có việc in.'**
  String get stationNoJobs;

  /// No description provided for @stationLocalTest.
  ///
  /// In vi, this message translates to:
  /// **'in thử tại máy'**
  String get stationLocalTest;

  /// No description provided for @stationPrinted.
  ///
  /// In vi, this message translates to:
  /// **'Đã in'**
  String get stationPrinted;

  /// No description provided for @stationFailed.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String stationFailed(String error);

  /// No description provided for @stationTestTitle.
  ///
  /// In vi, this message translates to:
  /// **'IN THỬ'**
  String get stationTestTitle;

  /// No description provided for @stationTestSample.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt: Phở bò tái, cà phê sữa đá, bánh mì.'**
  String get stationTestSample;

  /// No description provided for @stationTestDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi trang in thử.'**
  String get stationTestDone;

  /// No description provided for @stationForegroundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trạm in ParkViet'**
  String get stationForegroundTitle;

  /// No description provided for @stationForegroundText.
  ///
  /// In vi, this message translates to:
  /// **'Đang nhận việc in'**
  String get stationForegroundText;

  /// No description provided for @kdsTabPriority.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên'**
  String get kdsTabPriority;

  /// No description provided for @kdsTabByItem.
  ///
  /// In vi, this message translates to:
  /// **'Theo món'**
  String get kdsTabByItem;

  /// No description provided for @kdsTabByOrder.
  ///
  /// In vi, this message translates to:
  /// **'Theo bàn / số gọi'**
  String get kdsTabByOrder;

  /// No description provided for @kdsDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong (30 phút gần nhất)'**
  String get kdsDone;

  /// No description provided for @kdsNothingOpen.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món nào cần làm.'**
  String get kdsNothingOpen;

  /// No description provided for @kdsNothingDone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phiếu nào xong.'**
  String get kdsNothingDone;

  /// No description provided for @kdsStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get kdsStart;

  /// No description provided for @kdsReady.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get kdsReady;

  /// No description provided for @kdsServe.
  ///
  /// In vi, this message translates to:
  /// **'Đã ra món'**
  String get kdsServe;

  /// No description provided for @kdsRecall.
  ///
  /// In vi, this message translates to:
  /// **'Gọi lại'**
  String get kdsRecall;

  /// No description provided for @kdsBump.
  ///
  /// In vi, this message translates to:
  /// **'Xong cả phiếu'**
  String get kdsBump;

  /// No description provided for @kdsServeOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đã giao'**
  String get kdsServeOrder;

  /// No description provided for @kdsGuest.
  ///
  /// In vi, this message translates to:
  /// **'Khách: {name}'**
  String kdsGuest(String name);

  /// No description provided for @kdsPlatformGrabfood.
  ///
  /// In vi, this message translates to:
  /// **'GRABFOOD'**
  String get kdsPlatformGrabfood;

  /// No description provided for @kdsPlatformShopeefood.
  ///
  /// In vi, this message translates to:
  /// **'SHOPEEFOOD'**
  String get kdsPlatformShopeefood;

  /// No description provided for @kdsPickupCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã lấy: {code}'**
  String kdsPickupCode(String code);

  /// No description provided for @kdsTicketNumber.
  ///
  /// In vi, this message translates to:
  /// **'Phiếu #{number}'**
  String kdsTicketNumber(int number);

  /// No description provided for @kdsOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đơn {id}'**
  String kdsOrder(String id);

  /// No description provided for @kdsTickets.
  ///
  /// In vi, this message translates to:
  /// **'Phiếu {numbers}'**
  String kdsTickets(String numbers);

  /// No description provided for @kdsNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú: {note}'**
  String kdsNote(String note);

  /// No description provided for @kdsOffline.
  ///
  /// In vi, this message translates to:
  /// **'Mất kết nối · cập nhật lúc {time}'**
  String kdsOffline(String time);

  /// No description provided for @kdsOfflineNever.
  ///
  /// In vi, this message translates to:
  /// **'Mất kết nối · chưa tải được bếp'**
  String get kdsOfflineNever;

  /// No description provided for @kdsActionFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không đổi được món: {message}'**
  String kdsActionFailed(String message);

  /// No description provided for @kdsStationPick.
  ///
  /// In vi, this message translates to:
  /// **'Màn này hiện trạm nào?'**
  String get kdsStationPick;

  /// No description provided for @kdsAllStations.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả trạm'**
  String get kdsAllStations;

  /// No description provided for @kdsChangeStation.
  ///
  /// In vi, this message translates to:
  /// **'Đổi trạm'**
  String get kdsChangeStation;

  /// No description provided for @kdsNoStations.
  ///
  /// In vi, this message translates to:
  /// **'Chi nhánh chưa có trạm bếp. Thêm trạm trên trang quản trị, mục Bếp & bar.'**
  String get kdsNoStations;

  /// No description provided for @kdsSoldOut.
  ///
  /// In vi, this message translates to:
  /// **'Hết món'**
  String get kdsSoldOut;

  /// No description provided for @kdsSoldOutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hết món hôm nay'**
  String get kdsSoldOutTitle;

  /// No description provided for @kdsSoldOutWho.
  ///
  /// In vi, this message translates to:
  /// **'Ai báo hết món?'**
  String get kdsSoldOutWho;

  /// No description provided for @kdsPinFor.
  ///
  /// In vi, this message translates to:
  /// **'Mã PIN của {name}'**
  String kdsPinFor(String name);

  /// No description provided for @kdsConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get kdsConfirm;

  /// No description provided for @kdsStatusNew.
  ///
  /// In vi, this message translates to:
  /// **'Mới'**
  String get kdsStatusNew;

  /// No description provided for @kdsStatusPreparing.
  ///
  /// In vi, this message translates to:
  /// **'Đang làm'**
  String get kdsStatusPreparing;

  /// No description provided for @kdsStatusReady.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong'**
  String get kdsStatusReady;

  /// No description provided for @kdsStatusServed.
  ///
  /// In vi, this message translates to:
  /// **'Đã ra'**
  String get kdsStatusServed;

  /// No description provided for @kdsStatusVoided.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get kdsStatusVoided;

  /// No description provided for @kdsModeCounter.
  ///
  /// In vi, this message translates to:
  /// **'Tại quầy'**
  String get kdsModeCounter;

  /// No description provided for @kdsModeDineIn.
  ///
  /// In vi, this message translates to:
  /// **'Tại bàn'**
  String get kdsModeDineIn;

  /// No description provided for @kdsModeTakeaway.
  ///
  /// In vi, this message translates to:
  /// **'Mang đi'**
  String get kdsModeTakeaway;

  /// No description provided for @kdsModeDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Giao hàng'**
  String get kdsModeDelivery;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
