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

  /// No description provided for @kdsDoneHint.
  ///
  /// In vi, this message translates to:
  /// **'Giữ một món để gọi lại món đã xong hoặc đã ra.'**
  String get kdsDoneHint;

  /// No description provided for @kdsRecalled.
  ///
  /// In vi, this message translates to:
  /// **'Gọi lại {count} lần'**
  String kdsRecalled(int count);

  /// No description provided for @kdsAllDayOne.
  ///
  /// In vi, this message translates to:
  /// **'Xong 1'**
  String get kdsAllDayOne;

  /// No description provided for @kdsAllDayAll.
  ///
  /// In vi, this message translates to:
  /// **'Xong hết ({count})'**
  String kdsAllDayAll(int count);

  /// No description provided for @kdsServiceModeAll.
  ///
  /// In vi, this message translates to:
  /// **'Mọi kiểu phục vụ'**
  String get kdsServiceModeAll;

  /// No description provided for @kdsServiceModeFilter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo kiểu phục vụ'**
  String get kdsServiceModeFilter;

  /// No description provided for @kdsStationExpo.
  ///
  /// In vi, this message translates to:
  /// **'Trạm ra món (expo)'**
  String get kdsStationExpo;

  /// No description provided for @kdsStationPickHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một hoặc nhiều trạm. Lựa chọn được giữ trên máy này.'**
  String get kdsStationPickHint;

  /// No description provided for @kdsStationShow.
  ///
  /// In vi, this message translates to:
  /// **'Hiện {count} trạm'**
  String kdsStationShow(int count);

  /// No description provided for @expoNothingReady.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món nào chờ ra.'**
  String get expoNothingReady;

  /// No description provided for @expoServeAll.
  ///
  /// In vi, this message translates to:
  /// **'Ra cả đơn'**
  String get expoServeAll;

  /// No description provided for @modifierVariant.
  ///
  /// In vi, this message translates to:
  /// **'Cỡ / loại'**
  String get modifierVariant;

  /// No description provided for @modifierNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú cho bếp'**
  String get modifierNote;

  /// No description provided for @modifierAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm · {amount}'**
  String modifierAdd(String amount);

  /// No description provided for @modifierPickExactly.
  ///
  /// In vi, this message translates to:
  /// **'Chọn {count}'**
  String modifierPickExactly(int count);

  /// No description provided for @modifierPickBetween.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ {min} đến {max}'**
  String modifierPickBetween(int min, int max);

  /// No description provided for @modifierPickUpTo.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tối đa {max}'**
  String modifierPickUpTo(int max);

  /// No description provided for @voidReasonChangedMind.
  ///
  /// In vi, this message translates to:
  /// **'Khách đổi ý'**
  String get voidReasonChangedMind;

  /// No description provided for @voidReasonSoldOut.
  ///
  /// In vi, this message translates to:
  /// **'Hết món'**
  String get voidReasonSoldOut;

  /// No description provided for @voidReasonMistake.
  ///
  /// In vi, this message translates to:
  /// **'Nhập nhầm'**
  String get voidReasonMistake;

  /// No description provided for @voidReasonSpoiled.
  ///
  /// In vi, this message translates to:
  /// **'Làm hỏng'**
  String get voidReasonSpoiled;

  /// No description provided for @voidReasonOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác (ghi lý do)'**
  String get voidReasonOther;

  /// No description provided for @waiterAllAreas.
  ///
  /// In vi, this message translates to:
  /// **'Mọi khu'**
  String get waiterAllAreas;

  /// No description provided for @waiterFilterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get waiterFilterAll;

  /// No description provided for @waiterFilterFree.
  ///
  /// In vi, this message translates to:
  /// **'Trống'**
  String get waiterFilterFree;

  /// No description provided for @waiterFilterSeated.
  ///
  /// In vi, this message translates to:
  /// **'Có khách'**
  String get waiterFilterSeated;

  /// No description provided for @waiterFilterWaiting.
  ///
  /// In vi, this message translates to:
  /// **'Chờ món'**
  String get waiterFilterWaiting;

  /// No description provided for @waiterFilterPayment.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu thanh toán'**
  String get waiterFilterPayment;

  /// No description provided for @waiterFilterMine.
  ///
  /// In vi, this message translates to:
  /// **'Của tôi'**
  String get waiterFilterMine;

  /// No description provided for @waiterNoTables.
  ///
  /// In vi, this message translates to:
  /// **'Không có bàn nào.'**
  String get waiterNoTables;

  /// No description provided for @waiterStateFree.
  ///
  /// In vi, this message translates to:
  /// **'Trống'**
  String get waiterStateFree;

  /// No description provided for @waiterStateSeated.
  ///
  /// In vi, this message translates to:
  /// **'Có khách'**
  String get waiterStateSeated;

  /// No description provided for @waiterStateOrdered.
  ///
  /// In vi, this message translates to:
  /// **'Đang phục vụ'**
  String get waiterStateOrdered;

  /// No description provided for @waiterStateWaitingLong.
  ///
  /// In vi, this message translates to:
  /// **'Chờ lâu'**
  String get waiterStateWaitingLong;

  /// No description provided for @waiterStatePayment.
  ///
  /// In vi, this message translates to:
  /// **'Gọi thanh toán'**
  String get waiterStatePayment;

  /// No description provided for @waiterStatePrebilled.
  ///
  /// In vi, this message translates to:
  /// **'Đã in tạm tính'**
  String get waiterStatePrebilled;

  /// No description provided for @waiterStateCleaning.
  ///
  /// In vi, this message translates to:
  /// **'Đang dọn'**
  String get waiterStateCleaning;

  /// No description provided for @waiterStateOut.
  ///
  /// In vi, this message translates to:
  /// **'Ngưng phục vụ'**
  String get waiterStateOut;

  /// No description provided for @waiterGuests.
  ///
  /// In vi, this message translates to:
  /// **'{count} khách'**
  String waiterGuests(int count);

  /// No description provided for @waiterSeatedMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String waiterSeatedMinutes(int minutes);

  /// No description provided for @waiterPendingItems.
  ///
  /// In vi, this message translates to:
  /// **'{count} món chờ'**
  String waiterPendingItems(int count);

  /// No description provided for @waiterPaymentRequested.
  ///
  /// In vi, this message translates to:
  /// **'Đã gọi thanh toán'**
  String get waiterPaymentRequested;

  /// No description provided for @waiterOrders.
  ///
  /// In vi, this message translates to:
  /// **'{count} đơn'**
  String waiterOrders(int count);

  /// No description provided for @waiterPickOrder.
  ///
  /// In vi, this message translates to:
  /// **'{table}: chọn đơn'**
  String waiterPickOrder(String table);

  /// No description provided for @waiterOrderLetter.
  ///
  /// In vi, this message translates to:
  /// **'Đơn {letter}'**
  String waiterOrderLetter(String letter);

  /// No description provided for @waiterSecondOrder.
  ///
  /// In vi, this message translates to:
  /// **'Mở thêm đơn trên bàn này'**
  String get waiterSecondOrder;

  /// No description provided for @waiterPin.
  ///
  /// In vi, this message translates to:
  /// **'Ghim bàn (nhận báo món xong)'**
  String get waiterPin;

  /// No description provided for @waiterUnpin.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ghim bàn'**
  String get waiterUnpin;

  /// No description provided for @waiterFollowTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận báo món xong'**
  String get waiterFollowTitle;

  /// No description provided for @waiterFollowHint.
  ///
  /// In vi, this message translates to:
  /// **'Mặc định: bàn bạn gọi món và bàn đã ghim.'**
  String get waiterFollowHint;

  /// No description provided for @waiterFollowMine.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ bàn của tôi'**
  String get waiterFollowMine;

  /// No description provided for @waiterFollowArea.
  ///
  /// In vi, this message translates to:
  /// **'Mọi bàn trong khu {area}'**
  String waiterFollowArea(String area);

  /// No description provided for @waiterReadyCount.
  ///
  /// In vi, this message translates to:
  /// **'Có {count} món đã xong, chạm để mở bàn'**
  String waiterReadyCount(int count);

  /// No description provided for @waiterReadyNotice.
  ///
  /// In vi, this message translates to:
  /// **'{table}: {name} ×{quantity} đã xong'**
  String waiterReadyNotice(String table, String name, String quantity);

  /// No description provided for @waiterClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get waiterClose;

  /// No description provided for @waiterGuestsFor.
  ///
  /// In vi, this message translates to:
  /// **'Số khách · {table}'**
  String waiterGuestsFor(String table);

  /// No description provided for @waiterCapacity.
  ///
  /// In vi, this message translates to:
  /// **'Bàn {count} chỗ'**
  String waiterCapacity(int count);

  /// No description provided for @waiterOpenTable.
  ///
  /// In vi, this message translates to:
  /// **'Mở bàn'**
  String get waiterOpenTable;

  /// No description provided for @waiterOrderFor.
  ///
  /// In vi, this message translates to:
  /// **'Gọi món · {table}'**
  String waiterOrderFor(String table);

  /// No description provided for @waiterSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm món'**
  String get waiterSearch;

  /// No description provided for @waiterAllCategories.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get waiterAllCategories;

  /// No description provided for @waiterNoDishes.
  ///
  /// In vi, this message translates to:
  /// **'Không có món nào.'**
  String get waiterNoDishes;

  /// No description provided for @waiterSoldOutLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hết món'**
  String get waiterSoldOutLabel;

  /// No description provided for @waiterCart.
  ///
  /// In vi, this message translates to:
  /// **'{count} món · {amount}'**
  String waiterCart(int count, String amount);

  /// No description provided for @waiterAddToOrder.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào đơn'**
  String get waiterAddToOrder;

  /// No description provided for @waiterAddAndSend.
  ///
  /// In vi, this message translates to:
  /// **'Thêm và báo bếp'**
  String get waiterAddAndSend;

  /// No description provided for @waiterAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào đơn.'**
  String get waiterAdded;

  /// No description provided for @waiterAddedAndSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm và báo bếp.'**
  String get waiterAddedAndSent;

  /// No description provided for @waiterSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã báo bếp.'**
  String get waiterSent;

  /// No description provided for @waiterOrderDishes.
  ///
  /// In vi, this message translates to:
  /// **'Gọi món'**
  String get waiterOrderDishes;

  /// No description provided for @waiterSend.
  ///
  /// In vi, this message translates to:
  /// **'Báo bếp'**
  String get waiterSend;

  /// No description provided for @waiterSendCount.
  ///
  /// In vi, this message translates to:
  /// **'Báo bếp ({count})'**
  String waiterSendCount(int count);

  /// No description provided for @waiterSubtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính {amount}'**
  String waiterSubtotal(String amount);

  /// No description provided for @waiterEmptyOrder.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món nào. Bấm \"Gọi món\".'**
  String get waiterEmptyOrder;

  /// No description provided for @waiterLineUnsent.
  ///
  /// In vi, this message translates to:
  /// **'{count} chưa báo bếp'**
  String waiterLineUnsent(String count);

  /// No description provided for @waiterLineNew.
  ///
  /// In vi, this message translates to:
  /// **'{count} mới'**
  String waiterLineNew(String count);

  /// No description provided for @waiterLinePreparing.
  ///
  /// In vi, this message translates to:
  /// **'{count} đang làm'**
  String waiterLinePreparing(String count);

  /// No description provided for @waiterLineReady.
  ///
  /// In vi, this message translates to:
  /// **'{count} xong'**
  String waiterLineReady(String count);

  /// No description provided for @waiterLineServed.
  ///
  /// In vi, this message translates to:
  /// **'{count} đã ra'**
  String waiterLineServed(String count);

  /// No description provided for @waiterVoidSent.
  ///
  /// In vi, this message translates to:
  /// **'Hủy món đã báo bếp'**
  String get waiterVoidSent;

  /// No description provided for @waiterRemoveUnsent.
  ///
  /// In vi, this message translates to:
  /// **'Xóa món chưa báo bếp'**
  String get waiterRemoveUnsent;

  /// No description provided for @waiterVoided.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy món.'**
  String get waiterVoided;

  /// No description provided for @waiterVoidTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hủy {name}'**
  String waiterVoidTitle(String name);

  /// No description provided for @waiterVoidSentCount.
  ///
  /// In vi, this message translates to:
  /// **'Bếp đã nhận {count}.'**
  String waiterVoidSentCount(int count);

  /// No description provided for @waiterVoidNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get waiterVoidNote;

  /// No description provided for @waiterVoidNoteRequired.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (bắt buộc)'**
  String get waiterVoidNoteRequired;

  /// No description provided for @waiterVoidConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Hủy món'**
  String get waiterVoidConfirm;

  /// No description provided for @waiterWaitingApproval.
  ///
  /// In vi, this message translates to:
  /// **'Chờ quản lý duyệt. Quản lý cấp mã duyệt cho đơn này, mã sẽ tự điền khi có, hoặc nhập mã bên dưới.'**
  String get waiterWaitingApproval;

  /// No description provided for @waiterApprovalCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã duyệt'**
  String get waiterApprovalCode;

  /// No description provided for @waiterRequestPayment.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu thanh toán'**
  String get waiterRequestPayment;

  /// No description provided for @waiterPaymentRequestSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã báo thu ngân.'**
  String get waiterPaymentRequestSent;

  /// No description provided for @waiterMove.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển bàn'**
  String get waiterMove;

  /// No description provided for @waiterMerge.
  ///
  /// In vi, this message translates to:
  /// **'Gộp bàn'**
  String get waiterMerge;

  /// No description provided for @waiterMoveTo.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang bàn trống'**
  String get waiterMoveTo;

  /// No description provided for @waiterMergeInto.
  ///
  /// In vi, this message translates to:
  /// **'Gộp vào đơn của bàn'**
  String get waiterMergeInto;

  /// No description provided for @waiterMoved.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển bàn.'**
  String get waiterMoved;

  /// No description provided for @waiterMerged.
  ///
  /// In vi, this message translates to:
  /// **'Đã gộp bàn.'**
  String get waiterMerged;

  /// No description provided for @waiterChecklist.
  ///
  /// In vi, this message translates to:
  /// **'In phiếu kiểm đồ'**
  String get waiterChecklist;

  /// No description provided for @waiterPrebill.
  ///
  /// In vi, this message translates to:
  /// **'In tạm tính'**
  String get waiterPrebill;

  /// No description provided for @waiterPrintQueued.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi in tới {printer}.'**
  String waiterPrintQueued(String printer);

  /// No description provided for @waiterPrinted.
  ///
  /// In vi, this message translates to:
  /// **'Đã in trên {printer}.'**
  String waiterPrinted(String printer);

  /// No description provided for @waiterPrintFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không in được: {error}'**
  String waiterPrintFailed(String error);

  /// No description provided for @waiterNoPrinter.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có máy in cho phiếu này'**
  String get waiterNoPrinter;

  /// No description provided for @waiterLineChanged.
  ///
  /// In vi, this message translates to:
  /// **'Món này vừa được người khác sửa. Đã tải lại đơn.'**
  String get waiterLineChanged;

  /// No description provided for @waiterSnapshotLocked.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đang chờ thanh toán nên không đổi được. Đã tải lại đơn.'**
  String get waiterSnapshotLocked;

  /// No description provided for @waiterLeaseBusy.
  ///
  /// In vi, this message translates to:
  /// **'Máy khác đang sửa đơn này. Thử lại sau ít phút.'**
  String get waiterLeaseBusy;

  /// No description provided for @waiterWorkspaceClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đã đóng.'**
  String get waiterWorkspaceClosed;

  /// No description provided for @waiterSoldOut.
  ///
  /// In vi, this message translates to:
  /// **'Món này đã hết.'**
  String get waiterSoldOut;

  /// No description provided for @waiterTableOccupied.
  ///
  /// In vi, this message translates to:
  /// **'Bàn đã có khách.'**
  String get waiterTableOccupied;

  /// No description provided for @waiterTableUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Bàn không phục vụ lúc này.'**
  String get waiterTableUnavailable;

  /// No description provided for @waiterGuestCountInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số khách không hợp lệ cho bàn này.'**
  String get waiterGuestCountInvalid;

  /// No description provided for @waiterModifierInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Lựa chọn của món không hợp lệ. Mở lại món để chọn.'**
  String get waiterModifierInvalid;

  /// No description provided for @waiterVoidQuantityInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng hủy không hợp lệ.'**
  String get waiterVoidQuantityInvalid;

  /// No description provided for @waiterVoidReasonInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Chọn lý do hủy, hoặc ghi lý do khi chọn \"Khác\".'**
  String get waiterVoidReasonInvalid;

  /// No description provided for @waiterForbidden.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền làm việc này trên máy phục vụ.'**
  String get waiterForbidden;

  /// No description provided for @checklistTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị đã ghép'**
  String get checklistTitle;

  /// No description provided for @checklistIntro.
  ///
  /// In vi, this message translates to:
  /// **'Máy đã ghép vào {branch}. Kiểm tra các mục dưới đây trước khi dùng.'**
  String checklistIntro(String branch);

  /// No description provided for @checklistStation.
  ///
  /// In vi, this message translates to:
  /// **'Trạm bếp'**
  String get checklistStation;

  /// No description provided for @checklistStationOk.
  ///
  /// In vi, this message translates to:
  /// **'Đã chọn: {name}'**
  String checklistStationOk(String name);

  /// No description provided for @checklistStationMissing.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn trạm. Chọn trạm trên màn bếp sau khi bắt đầu.'**
  String get checklistStationMissing;

  /// No description provided for @checklistPrinter.
  ///
  /// In vi, this message translates to:
  /// **'Máy in của trạm'**
  String get checklistPrinter;

  /// No description provided for @checklistPrinterOk.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận: {name}'**
  String checklistPrinterOk(String name);

  /// No description provided for @checklistPrinterMissing.
  ///
  /// In vi, this message translates to:
  /// **'Trạm chưa có máy in; phiếu chỉ hiện trên màn hình. Gán máy in ở trang chi nhánh, tab Bếp & bar.'**
  String get checklistPrinterMissing;

  /// No description provided for @checklistStaff.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên có PIN'**
  String get checklistStaff;

  /// No description provided for @checklistStaffOk.
  ///
  /// In vi, this message translates to:
  /// **'{count} người đăng nhập được bằng PIN'**
  String checklistStaffOk(int count);

  /// No description provided for @checklistStaffMissing.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ai có PIN. Quản lý đặt PIN cho nhân viên trên trang quản trị.'**
  String get checklistStaffMissing;

  /// No description provided for @checklistNothing.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ này không cần chuẩn bị thêm.'**
  String get checklistNothing;

  /// No description provided for @checklistStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu dùng'**
  String get checklistStart;

  /// No description provided for @courseNone.
  ///
  /// In vi, this message translates to:
  /// **'Không chia lượt'**
  String get courseNone;

  /// No description provided for @courseStarter.
  ///
  /// In vi, this message translates to:
  /// **'Khai vị'**
  String get courseStarter;

  /// No description provided for @courseMain.
  ///
  /// In vi, this message translates to:
  /// **'Món chính'**
  String get courseMain;

  /// No description provided for @courseDessert.
  ///
  /// In vi, this message translates to:
  /// **'Tráng miệng'**
  String get courseDessert;

  /// No description provided for @courseNumber.
  ///
  /// In vi, this message translates to:
  /// **'Lượt {number}'**
  String courseNumber(int number);

  /// No description provided for @courseHold.
  ///
  /// In vi, this message translates to:
  /// **'Giữ lại, chờ gọi'**
  String get courseHold;

  /// No description provided for @courseHeldTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ, chờ gọi món'**
  String get courseHeldTitle;

  /// No description provided for @courseFire.
  ///
  /// In vi, this message translates to:
  /// **'Gọi {course} ({count} món)'**
  String courseFire(String course, int count);

  /// No description provided for @courseFired.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi bếp: {course}'**
  String courseFired(String course);

  /// No description provided for @seatLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghế'**
  String get seatLabel;

  /// No description provided for @seatShared.
  ///
  /// In vi, this message translates to:
  /// **'Dùng chung'**
  String get seatShared;

  /// No description provided for @seatNumber.
  ///
  /// In vi, this message translates to:
  /// **'Ghế {seat}'**
  String seatNumber(int seat);

  /// No description provided for @expoHeldTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chờ gọi món'**
  String get expoHeldTitle;

  /// No description provided for @expoReadyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong, cần mang ra'**
  String get expoReadyTitle;

  /// No description provided for @expoAllAreas.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả khu'**
  String get expoAllAreas;

  /// No description provided for @expoArea.
  ///
  /// In vi, this message translates to:
  /// **'Khu {number}'**
  String expoArea(int number);

  /// No description provided for @ownerReservationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt bàn hôm nay'**
  String get ownerReservationsTitle;

  /// No description provided for @ownerNoReservations.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay chưa có lượt đặt bàn.'**
  String get ownerNoReservations;

  /// No description provided for @ownerDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Cọc {amount} · {status}'**
  String ownerDeposit(String amount, String status);

  /// No description provided for @ownerRefund.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn cọc'**
  String get ownerRefund;

  /// No description provided for @ownerForfeit.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cọc'**
  String get ownerForfeit;

  /// No description provided for @ownerConfirmRefund.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn {amount} cho {name}?'**
  String ownerConfirmRefund(String amount, String name);

  /// No description provided for @ownerConfirmForfeit.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cọc {amount} của {name}? Khoản cọc thành một hóa đơn phí giữ chỗ có thuế.'**
  String ownerConfirmForfeit(String amount, String name);

  /// No description provided for @ownerConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get ownerConfirm;

  /// No description provided for @ownerKeep.
  ///
  /// In vi, this message translates to:
  /// **'Thôi'**
  String get ownerKeep;

  /// No description provided for @ownerRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn cọc.'**
  String get ownerRefunded;

  /// No description provided for @ownerForfeited.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi nhận giữ cọc.'**
  String get ownerForfeited;

  /// No description provided for @reservationBooked.
  ///
  /// In vi, this message translates to:
  /// **'Đã đặt'**
  String get reservationBooked;

  /// No description provided for @reservationSeated.
  ///
  /// In vi, this message translates to:
  /// **'Đã vào bàn'**
  String get reservationSeated;

  /// No description provided for @reservationCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong'**
  String get reservationCompleted;

  /// No description provided for @reservationNoShow.
  ///
  /// In vi, this message translates to:
  /// **'Không đến'**
  String get reservationNoShow;

  /// No description provided for @reservationCanceled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get reservationCanceled;

  /// No description provided for @depositHeld.
  ///
  /// In vi, this message translates to:
  /// **'đang giữ'**
  String get depositHeld;

  /// No description provided for @depositApplied.
  ///
  /// In vi, this message translates to:
  /// **'đã trừ vào hóa đơn'**
  String get depositApplied;

  /// No description provided for @depositRefunded.
  ///
  /// In vi, this message translates to:
  /// **'đã hoàn'**
  String get depositRefunded;

  /// No description provided for @depositForfeited.
  ///
  /// In vi, this message translates to:
  /// **'đã giữ cọc'**
  String get depositForfeited;

  /// No description provided for @waiterTabsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tab đang mở'**
  String get waiterTabsTitle;

  /// No description provided for @waiterTabOpen.
  ///
  /// In vi, this message translates to:
  /// **'Mở tab'**
  String get waiterTabOpen;

  /// No description provided for @waiterTabSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tên khách, bàn hoặc số tab'**
  String get waiterTabSearch;

  /// No description provided for @waiterTabsNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tab nào đang mở.'**
  String get waiterTabsNone;

  /// No description provided for @waiterTabsNoMatch.
  ///
  /// In vi, this message translates to:
  /// **'Không có tab nào khớp.'**
  String get waiterTabsNoMatch;

  /// No description provided for @waiterTabOpenedAt.
  ///
  /// In vi, this message translates to:
  /// **'Mở lúc {time}'**
  String waiterTabOpenedAt(String time);

  /// No description provided for @waiterTabName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hoặc mô tả khách'**
  String get waiterTabName;

  /// No description provided for @waiterTabNameTaken.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tab đang mở với tên này.'**
  String get waiterTabNameTaken;

  /// No description provided for @waiterTabNameInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên tab (tối đa 60 ký tự).'**
  String get waiterTabNameInvalid;

  /// No description provided for @waiterBottleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Rót rượu gửi'**
  String get waiterBottleTitle;

  /// No description provided for @waiterBottleCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã chai'**
  String get waiterBottleCode;

  /// No description provided for @waiterBottleNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không thấy chai gửi với mã này.'**
  String get waiterBottleNotFound;

  /// No description provided for @waiterBottleLevel.
  ///
  /// In vi, this message translates to:
  /// **'Còn {level}%'**
  String waiterBottleLevel(int level);

  /// No description provided for @waiterBottleNewLevel.
  ///
  /// In vi, this message translates to:
  /// **'Mức còn sau khi rót: {level}%'**
  String waiterBottleNewLevel(int level);

  /// No description provided for @waiterBottleMl.
  ///
  /// In vi, this message translates to:
  /// **'Số ml đã rót (không bắt buộc)'**
  String get waiterBottleMl;

  /// No description provided for @waiterBottlePour.
  ///
  /// In vi, this message translates to:
  /// **'Rót'**
  String get waiterBottlePour;

  /// No description provided for @waiterBottlePoured.
  ///
  /// In vi, this message translates to:
  /// **'Đã rót, chai còn {level}%.'**
  String waiterBottlePoured(int level);

  /// No description provided for @waiterBottleClosed.
  ///
  /// In vi, this message translates to:
  /// **'Phiếu gửi này đã kết thúc.'**
  String get waiterBottleClosed;

  /// No description provided for @waiterBottleLevelRaised.
  ///
  /// In vi, this message translates to:
  /// **'Rót không làm mức tăng; quản lý sửa mức nếu nhập sai.'**
  String get waiterBottleLevelRaised;

  /// No description provided for @waiterRoomsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phòng'**
  String get waiterRoomsTitle;

  /// No description provided for @waiterRoomsNone.
  ///
  /// In vi, this message translates to:
  /// **'Chi nhánh chưa có phòng hay bàn chơi.'**
  String get waiterRoomsNone;

  /// No description provided for @waiterStatePlaying.
  ///
  /// In vi, this message translates to:
  /// **'Đang tính giờ'**
  String get waiterStatePlaying;

  /// No description provided for @waiterStateEndingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp hết giờ'**
  String get waiterStateEndingSoon;

  /// No description provided for @waiterClockStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu tính giờ'**
  String get waiterClockStart;

  /// No description provided for @waiterClockStop.
  ///
  /// In vi, this message translates to:
  /// **'Dừng giờ'**
  String get waiterClockStop;

  /// No description provided for @waiterClockStopConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Dừng giờ {room}? Tiền giờ được chốt theo giờ máy chủ.'**
  String waiterClockStopConfirm(String room);

  /// No description provided for @waiterClockMove.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển phòng'**
  String get waiterClockMove;

  /// No description provided for @waiterClockMoveTo.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển {room} sang'**
  String waiterClockMoveTo(String room);

  /// No description provided for @waiterClockMoveNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có phòng trống để chuyển.'**
  String get waiterClockMoveNone;

  /// No description provided for @waiterClockOpenOrder.
  ///
  /// In vi, this message translates to:
  /// **'Mở đơn của phòng'**
  String get waiterClockOpenOrder;

  /// No description provided for @waiterClockQuote.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính {amount}'**
  String waiterClockQuote(String amount);

  /// No description provided for @waiterClockStopped.
  ///
  /// In vi, this message translates to:
  /// **'Đã dừng giờ, tiền giờ {amount}.'**
  String waiterClockStopped(String amount);

  /// No description provided for @waiterClockRunning.
  ///
  /// In vi, this message translates to:
  /// **'Phòng này đang tính giờ.'**
  String get waiterClockRunning;

  /// No description provided for @waiterClockNoRatePlan.
  ///
  /// In vi, this message translates to:
  /// **'Phòng này chưa có bảng giá giờ. Báo quản lý thêm bảng giá.'**
  String get waiterClockNoRatePlan;

  /// No description provided for @waiterClockPickOrder.
  ///
  /// In vi, this message translates to:
  /// **'Phòng có nhiều đơn mở; chọn đơn cần tính giờ.'**
  String get waiterClockPickOrder;

  /// No description provided for @waiterClockAlreadyStopped.
  ///
  /// In vi, this message translates to:
  /// **'Giờ của phòng này đã dừng.'**
  String get waiterClockAlreadyStopped;

  /// No description provided for @waiterClockPause.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng giờ'**
  String get waiterClockPause;

  /// No description provided for @waiterClockResume.
  ///
  /// In vi, this message translates to:
  /// **'Tính giờ tiếp'**
  String get waiterClockResume;

  /// No description provided for @waiterClockPaused.
  ///
  /// In vi, this message translates to:
  /// **'Đang tạm dừng'**
  String get waiterClockPaused;

  /// No description provided for @waiterClockAlreadyPaused.
  ///
  /// In vi, this message translates to:
  /// **'Giờ của phòng này đang tạm dừng.'**
  String get waiterClockAlreadyPaused;

  /// No description provided for @waiterClockNotPaused.
  ///
  /// In vi, this message translates to:
  /// **'Giờ của phòng này không tạm dừng.'**
  String get waiterClockNotPaused;

  /// No description provided for @waiterClockLongPause.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng quá lâu: cần quản lý duyệt tại quầy để tính giờ tiếp.'**
  String get waiterClockLongPause;

  /// No description provided for @waiterClockPackageLeft.
  ///
  /// In vi, this message translates to:
  /// **'Gói còn {minutes} phút'**
  String waiterClockPackageLeft(int minutes);

  /// No description provided for @waiterServeRoom.
  ///
  /// In vi, this message translates to:
  /// **'Tôi phục vụ phòng này'**
  String get waiterServeRoom;

  /// No description provided for @waiterServingRoom.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận phục vụ {room}.'**
  String waiterServingRoom(String room);

  /// No description provided for @waiterAttendantBusy.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang phục vụ một phòng khác.'**
  String get waiterAttendantBusy;

  /// No description provided for @waiterAlertEndingSoon.
  ///
  /// In vi, this message translates to:
  /// **'{room} còn 10 phút'**
  String waiterAlertEndingSoon(String room);

  /// No description provided for @waiterAlertEndedPackage.
  ///
  /// In vi, this message translates to:
  /// **'{room} đã hết gói giờ'**
  String waiterAlertEndedPackage(String room);

  /// No description provided for @waiterAlertPauseTooLong.
  ///
  /// In vi, this message translates to:
  /// **'{room} tạm dừng quá lâu'**
  String waiterAlertPauseTooLong(String room);

  /// No description provided for @waiterGuestTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đơn từ QR'**
  String get waiterGuestTitle;

  /// No description provided for @waiterGuestAllAreas.
  ///
  /// In vi, this message translates to:
  /// **'Mọi khu'**
  String get waiterGuestAllAreas;

  /// No description provided for @waiterGuestMyArea.
  ///
  /// In vi, this message translates to:
  /// **'Khu tôi theo dõi'**
  String get waiterGuestMyArea;

  /// No description provided for @waiterGuestEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không có đơn hay yêu cầu nào của khách đang chờ.'**
  String get waiterGuestEmpty;

  /// No description provided for @waiterGuestWaiting.
  ///
  /// In vi, this message translates to:
  /// **'{count} đang chờ'**
  String waiterGuestWaiting(int count);

  /// No description provided for @waiterGuestAccept.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get waiterGuestAccept;

  /// No description provided for @waiterGuestReject.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get waiterGuestReject;

  /// No description provided for @waiterGuestRejectTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lý do từ chối'**
  String get waiterGuestRejectTitle;

  /// No description provided for @waiterGuestRejectHint.
  ///
  /// In vi, this message translates to:
  /// **'Khách đọc được lý do này trên điện thoại.'**
  String get waiterGuestRejectHint;

  /// No description provided for @waiterGuestRejectSoldOut.
  ///
  /// In vi, this message translates to:
  /// **'Món đã hết'**
  String get waiterGuestRejectSoldOut;

  /// No description provided for @waiterGuestRejectKitchenClosed.
  ///
  /// In vi, this message translates to:
  /// **'Bếp đã đóng'**
  String get waiterGuestRejectKitchenClosed;

  /// No description provided for @waiterGuestRejectAskStaff.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng gọi nhân viên'**
  String get waiterGuestRejectAskStaff;

  /// No description provided for @waiterGuestAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào đơn {table} và báo bếp.'**
  String waiterGuestAccepted(String table);

  /// No description provided for @waiterGuestRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã từ chối đơn của {table}.'**
  String waiterGuestRejected(String table);

  /// No description provided for @waiterGuestCallStaff.
  ///
  /// In vi, this message translates to:
  /// **'{table} gọi phục vụ'**
  String waiterGuestCallStaff(String table);

  /// No description provided for @waiterGuestRequestBill.
  ///
  /// In vi, this message translates to:
  /// **'{table} yêu cầu thanh toán'**
  String waiterGuestRequestBill(String table);

  /// No description provided for @waiterGuestDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xử lý'**
  String get waiterGuestDone;

  /// No description provided for @waiterGuestNoDecide.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có quyền duyệt đơn khách gọi qua QR.'**
  String get waiterGuestNoDecide;

  /// No description provided for @waiterGuestArrived.
  ///
  /// In vi, this message translates to:
  /// **'Khách vừa gọi món hoặc gọi phục vụ qua QR'**
  String get waiterGuestArrived;

  /// No description provided for @kioskWelcomeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào! Chạm để gọi món'**
  String get kioskWelcomeTitle;

  /// No description provided for @kioskWelcomeHint.
  ///
  /// In vi, this message translates to:
  /// **'Tự chọn món, trả bằng QR chuyển khoản hoặc trả tại quầy.'**
  String get kioskWelcomeHint;

  /// No description provided for @kioskStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu gọi món'**
  String get kioskStart;

  /// No description provided for @kioskPausedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiosk đang tạm dừng'**
  String get kioskPausedTitle;

  /// No description provided for @kioskPausedBody.
  ///
  /// In vi, this message translates to:
  /// **'Xin mời bạn gọi món tại quầy thu ngân.'**
  String get kioskPausedBody;

  /// No description provided for @kioskReconnecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối lại máy chủ…'**
  String get kioskReconnecting;

  /// No description provided for @kioskSoldOut.
  ///
  /// In vi, this message translates to:
  /// **'Hết món'**
  String get kioskSoldOut;

  /// No description provided for @kioskAllItems.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả món'**
  String get kioskAllItems;

  /// No description provided for @kioskCartButton.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng · {count} món · {amount}'**
  String kioskCartButton(int count, String amount);

  /// No description provided for @kioskCartTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng của bạn'**
  String get kioskCartTitle;

  /// No description provided for @kioskBackToMenu.
  ///
  /// In vi, this message translates to:
  /// **'Gọi thêm món'**
  String get kioskBackToMenu;

  /// No description provided for @kioskEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính {amount}'**
  String kioskEstimate(String amount);

  /// No description provided for @kioskEstimateHint.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền chính xác hiện ngay khi bạn đặt đơn.'**
  String get kioskEstimateHint;

  /// No description provided for @kioskChoosePayment.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn trả thế nào?'**
  String get kioskChoosePayment;

  /// No description provided for @kioskPayQr.
  ///
  /// In vi, this message translates to:
  /// **'Trả bằng QR chuyển khoản'**
  String get kioskPayQr;

  /// No description provided for @kioskPayCounter.
  ///
  /// In vi, this message translates to:
  /// **'Trả tại quầy'**
  String get kioskPayCounter;

  /// No description provided for @kioskLess.
  ///
  /// In vi, this message translates to:
  /// **'Bớt {name}'**
  String kioskLess(String name);

  /// No description provided for @kioskMore.
  ///
  /// In vi, this message translates to:
  /// **'Thêm {name}'**
  String kioskMore(String name);

  /// No description provided for @kioskCartFull.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng đã đủ món; hãy đặt đơn này trước.'**
  String get kioskCartFull;

  /// No description provided for @kioskQrTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã để trả {amount}'**
  String kioskQrTitle(String amount);

  /// No description provided for @kioskQrImage.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR chuyển khoản'**
  String get kioskQrImage;

  /// No description provided for @kioskQrAccount.
  ///
  /// In vi, this message translates to:
  /// **'{bank} · {account} · {name}'**
  String kioskQrAccount(String bank, String account, String name);

  /// No description provided for @kioskQrNote.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung chuyển khoản: {note}'**
  String kioskQrNote(String note);

  /// No description provided for @kioskQrLeft.
  ///
  /// In vi, this message translates to:
  /// **'Mã còn hiệu lực {seconds} giây'**
  String kioskQrLeft(int seconds);

  /// No description provided for @kioskQrWaiting.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ ngân hàng báo đã nhận tiền…'**
  String get kioskQrWaiting;

  /// No description provided for @kioskQrInstead.
  ///
  /// In vi, this message translates to:
  /// **'Trả tại quầy thay vì QR'**
  String get kioskQrInstead;

  /// No description provided for @kioskDoneTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn!'**
  String get kioskDoneTitle;

  /// No description provided for @kioskCallNumberLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số gọi món của bạn'**
  String get kioskCallNumberLabel;

  /// No description provided for @kioskDonePaid.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận tiền. Quán đang làm món; nghe gọi số này để nhận.'**
  String get kioskDonePaid;

  /// No description provided for @kioskDoneCounter.
  ///
  /// In vi, this message translates to:
  /// **'Mời bạn ra quầy thu ngân và đọc số này để trả tiền.'**
  String get kioskDoneCounter;

  /// No description provided for @kioskNextGuest.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get kioskNextGuest;

  /// No description provided for @kioskStillThere.
  ///
  /// In vi, this message translates to:
  /// **'Bạn còn đó không?'**
  String get kioskStillThere;

  /// No description provided for @kioskStillThereBody.
  ///
  /// In vi, this message translates to:
  /// **'Đơn sẽ được hủy sau {seconds} giây.'**
  String kioskStillThereBody(int seconds);

  /// No description provided for @kioskStillHere.
  ///
  /// In vi, this message translates to:
  /// **'Tôi vẫn ở đây'**
  String get kioskStillHere;

  /// No description provided for @kioskStartOver.
  ///
  /// In vi, this message translates to:
  /// **'Hủy và làm lại'**
  String get kioskStartOver;

  /// No description provided for @kioskLanguageSwitch.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get kioskLanguageSwitch;

  /// No description provided for @kioskNotLocked.
  ///
  /// In vi, this message translates to:
  /// **'Màn hình chưa được khóa vào ứng dụng. Quản lý: bật ghim màn hình (Android) hoặc Guided Access (iOS).'**
  String get kioskNotLocked;

  /// No description provided for @kioskLowReach.
  ///
  /// In vi, this message translates to:
  /// **'Đưa nút xuống thấp'**
  String get kioskLowReach;

  /// No description provided for @kioskFailureSoldOut.
  ///
  /// In vi, this message translates to:
  /// **'Có món vừa hết. Vui lòng bỏ món đó khỏi giỏ.'**
  String get kioskFailureSoldOut;

  /// No description provided for @kioskFailurePaused.
  ///
  /// In vi, this message translates to:
  /// **'Kiosk vừa tạm dừng. Xin mời gọi món tại quầy.'**
  String get kioskFailurePaused;

  /// No description provided for @kioskFailureQrUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Hiện chưa trả được bằng QR. Bạn có thể trả tại quầy.'**
  String get kioskFailureQrUnavailable;

  /// No description provided for @kioskFailureGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt được đơn. Vui lòng thử lại hoặc gọi nhân viên.'**
  String get kioskFailureGeneric;

  /// No description provided for @manageKioskUnlock.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa màn hình kiosk'**
  String get manageKioskUnlock;

  /// No description provided for @manageKioskUnlockHint.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép thoát ứng dụng để bảo trì. Kiosk tự khóa lại khi mở lại chế độ kiosk.'**
  String get manageKioskUnlockHint;

  /// No description provided for @manageKioskUnlocked.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khóa màn hình kiosk.'**
  String get manageKioskUnlocked;

  /// No description provided for @manageKioskUnlockFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị không mở khóa được; tắt chế độ ghim màn hình hoặc Guided Access trong cài đặt máy.'**
  String get manageKioskUnlockFailed;

  /// No description provided for @waiterAskOwner.
  ///
  /// In vi, this message translates to:
  /// **'Gửi chủ duyệt'**
  String get waiterAskOwner;

  /// No description provided for @waiterAskedOwner.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi chủ duyệt, đang chờ trả lời.'**
  String get waiterAskedOwner;

  /// No description provided for @waiterOwnerDeclined.
  ///
  /// In vi, this message translates to:
  /// **'Chủ quán đã từ chối.'**
  String get waiterOwnerDeclined;

  /// No description provided for @waiterOwnerDeclinedReason.
  ///
  /// In vi, this message translates to:
  /// **'Chủ quán đã từ chối: {reason}'**
  String waiterOwnerDeclinedReason(String reason);

  /// No description provided for @waiterOwnerExpired.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đã hết hạn hoặc đơn đã đổi; gửi lại nếu cần.'**
  String get waiterOwnerExpired;

  /// No description provided for @ownerTabToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get ownerTabToday;

  /// No description provided for @ownerTabOpen.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở'**
  String get ownerTabOpen;

  /// No description provided for @ownerTabApprovals.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get ownerTabApprovals;

  /// No description provided for @ownerTabReservations.
  ///
  /// In vi, this message translates to:
  /// **'Đặt bàn'**
  String get ownerTabReservations;

  /// No description provided for @ownerTabAlerts.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get ownerTabAlerts;

  /// No description provided for @ownerNoBranches.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa được giao chi nhánh nào để xem hoặc duyệt.'**
  String get ownerNoBranches;

  /// No description provided for @ownerNoReports.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền xem báo cáo ở chi nhánh này.'**
  String get ownerNoReports;

  /// No description provided for @ownerNoApprove.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền duyệt ở chi nhánh này.'**
  String get ownerNoApprove;

  /// No description provided for @ownerNoPending.
  ///
  /// In vi, this message translates to:
  /// **'Không có yêu cầu nào đang chờ.'**
  String get ownerNoPending;

  /// No description provided for @ownerNoAlerts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cảnh báo trong 24 giờ qua.'**
  String get ownerNoAlerts;

  /// No description provided for @ownerNoOpen.
  ///
  /// In vi, this message translates to:
  /// **'Không có đơn nào đang mở.'**
  String get ownerNoOpen;

  /// No description provided for @ownerSales.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu'**
  String get ownerSales;

  /// No description provided for @ownerNetSales.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu thuần'**
  String get ownerNetSales;

  /// No description provided for @ownerOrders.
  ///
  /// In vi, this message translates to:
  /// **'Số đơn'**
  String get ownerOrders;

  /// No description provided for @ownerOpenOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đang mở'**
  String get ownerOpenOrders;

  /// No description provided for @ownerOpenShifts.
  ///
  /// In vi, this message translates to:
  /// **'Ca đang mở'**
  String get ownerOpenShifts;

  /// No description provided for @ownerCanceled.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hủy'**
  String get ownerCanceled;

  /// No description provided for @ownerVoided.
  ///
  /// In vi, this message translates to:
  /// **'{count} món hủy'**
  String ownerVoided(int count);

  /// No description provided for @ownerBySource.
  ///
  /// In vi, this message translates to:
  /// **'Theo kênh'**
  String get ownerBySource;

  /// No description provided for @ownerSourceOrders.
  ///
  /// In vi, this message translates to:
  /// **'{count} đơn'**
  String ownerSourceOrders(int count);

  /// No description provided for @ownerByHour.
  ///
  /// In vi, this message translates to:
  /// **'Theo giờ'**
  String get ownerByHour;

  /// No description provided for @ownerSourceCounter.
  ///
  /// In vi, this message translates to:
  /// **'Tại quầy'**
  String get ownerSourceCounter;

  /// No description provided for @ownerSourceKiosk.
  ///
  /// In vi, this message translates to:
  /// **'Kiosk'**
  String get ownerSourceKiosk;

  /// No description provided for @ownerSourceOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get ownerSourceOther;

  /// No description provided for @ownerTakeaway.
  ///
  /// In vi, this message translates to:
  /// **'Mang đi'**
  String get ownerTakeaway;

  /// No description provided for @ownerMinutesOpen.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String ownerMinutesOpen(int minutes);

  /// No description provided for @ownerKitchenLate.
  ///
  /// In vi, this message translates to:
  /// **'{count} món trễ bếp'**
  String ownerKitchenLate(int count);

  /// No description provided for @ownerKitchenWaiting.
  ///
  /// In vi, this message translates to:
  /// **'{count} món chờ bếp'**
  String ownerKitchenWaiting(int count);

  /// No description provided for @ownerRequestedBy.
  ///
  /// In vi, this message translates to:
  /// **'{name} xin duyệt'**
  String ownerRequestedBy(String name);

  /// No description provided for @ownerRequestReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do: {reason}'**
  String ownerRequestReason(String reason);

  /// No description provided for @ownerRequestExpires.
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn lúc {time}'**
  String ownerRequestExpires(String time);

  /// No description provided for @ownerGrant.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý'**
  String get ownerGrant;

  /// No description provided for @ownerDecline.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get ownerDecline;

  /// No description provided for @ownerGrantBiometricReason.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận để duyệt yêu cầu'**
  String get ownerGrantBiometricReason;

  /// No description provided for @ownerGrantNotConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác nhận được vân tay hoặc khuôn mặt.'**
  String get ownerGrantNotConfirmed;

  /// No description provided for @ownerGrantConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt: {action}?'**
  String ownerGrantConfirm(String action);

  /// No description provided for @ownerDeclineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối yêu cầu'**
  String get ownerDeclineTitle;

  /// No description provided for @ownerDeclineReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (không bắt buộc)'**
  String get ownerDeclineReason;

  /// No description provided for @ownerGranted.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt; máy gửi sẽ tự tiếp tục.'**
  String get ownerGranted;

  /// No description provided for @ownerDeclined.
  ///
  /// In vi, this message translates to:
  /// **'Đã từ chối.'**
  String get ownerDeclined;

  /// No description provided for @ownerRequestExpired.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đã hết hạn hoặc đơn đã đổi.'**
  String get ownerRequestExpired;

  /// No description provided for @ownerRequestCanceled.
  ///
  /// In vi, this message translates to:
  /// **'Người gửi đã hủy yêu cầu.'**
  String get ownerRequestCanceled;

  /// No description provided for @ownerSelfApproval.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không thể tự duyệt yêu cầu của mình.'**
  String get ownerSelfApproval;

  /// No description provided for @ownerAlreadyDecided.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu này đã được trả lời.'**
  String get ownerAlreadyDecided;

  /// No description provided for @ownerActionDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá đơn'**
  String get ownerActionDiscount;

  /// No description provided for @ownerActionLineDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá món'**
  String get ownerActionLineDiscount;

  /// No description provided for @ownerActionOverridePrice.
  ///
  /// In vi, this message translates to:
  /// **'Đổi giá món'**
  String get ownerActionOverridePrice;

  /// No description provided for @ownerActionPrebill.
  ///
  /// In vi, this message translates to:
  /// **'In lại hoặc hủy phiếu tạm tính'**
  String get ownerActionPrebill;

  /// No description provided for @ownerActionVoid.
  ///
  /// In vi, this message translates to:
  /// **'Hủy món đã gửi bếp'**
  String get ownerActionVoid;

  /// No description provided for @ownerActionPlatformCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đơn app giao hàng'**
  String get ownerActionPlatformCancel;

  /// No description provided for @ownerActionBuffet.
  ///
  /// In vi, this message translates to:
  /// **'Đổi lượt buffet'**
  String get ownerActionBuffet;

  /// No description provided for @ownerActionMinimumSpend.
  ///
  /// In vi, this message translates to:
  /// **'Miễn chi tiêu tối thiểu'**
  String get ownerActionMinimumSpend;

  /// No description provided for @ownerActionTimedEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa giờ tính tiền'**
  String get ownerActionTimedEdit;

  /// No description provided for @ownerActionLongPause.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng giờ lâu'**
  String get ownerActionLongPause;

  /// No description provided for @ownerActionDepositRefund.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn cọc đặt bàn'**
  String get ownerActionDepositRefund;

  /// No description provided for @ownerActionDepositForfeit.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cọc đặt bàn'**
  String get ownerActionDepositForfeit;

  /// No description provided for @ownerActionBottleKeep.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh chai gửi'**
  String get ownerActionBottleKeep;

  /// No description provided for @ownerActionMealWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví suất ăn'**
  String get ownerActionMealWallet;

  /// No description provided for @ownerActionCommission.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh hoa hồng xe'**
  String get ownerActionCommission;

  /// No description provided for @ownerActionStoredValue.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ trả trước'**
  String get ownerActionStoredValue;

  /// No description provided for @ownerAlertKitchenLate.
  ///
  /// In vi, this message translates to:
  /// **'Món chờ bếp {minutes} phút'**
  String ownerAlertKitchenLate(String minutes);

  /// No description provided for @ownerAlertShiftVariance.
  ///
  /// In vi, this message translates to:
  /// **'Chênh lệch két khi đóng ca: {amount}'**
  String ownerAlertShiftVariance(String amount);

  /// No description provided for @ownerAlertVoidBurst.
  ///
  /// In vi, this message translates to:
  /// **'{count} món bị hủy trong một giờ'**
  String ownerAlertVoidBurst(String count);

  /// No description provided for @ownerAlertRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu năm đạt {percent}% ngưỡng 1 tỷ'**
  String ownerAlertRevenue(String percent);

  /// No description provided for @ownerAlertPrintFailed.
  ///
  /// In vi, this message translates to:
  /// **'Một lệnh in bị lỗi'**
  String get ownerAlertPrintFailed;

  /// No description provided for @ownerAlertEinvoiceFailed.
  ///
  /// In vi, this message translates to:
  /// **'Một hóa đơn điện tử bị lỗi'**
  String get ownerAlertEinvoiceFailed;

  /// No description provided for @ownerPushTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo nền'**
  String get ownerPushTitle;

  /// No description provided for @ownerPushToggle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận thông báo khi app đóng'**
  String get ownerPushToggle;

  /// No description provided for @ownerPushNoToken.
  ///
  /// In vi, this message translates to:
  /// **'Bản cài này chưa có thông báo nền; bạn chỉ nhận sự kiện khi app đang mở.'**
  String get ownerPushNoToken;

  /// No description provided for @ownerPushNoRelay.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng chưa cài dịch vụ chuyển tiếp thông báo; bạn chỉ nhận sự kiện khi app đang mở.'**
  String get ownerPushNoRelay;

  /// No description provided for @ownerPushReady.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo chỉ mang loại sự kiện, không kèm số tiền hay tên khách.'**
  String get ownerPushReady;

  /// No description provided for @ownerPushLastError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi gần nhất: {error}'**
  String ownerPushLastError(String error);
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
