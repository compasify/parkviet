// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ParkViet Staff';

  @override
  String get welcomeTitle => 'Pair with your store';

  @override
  String get welcomeBody =>
      'Open Devices in the dashboard, create a pairing code, then scan its QR or type the server address and code.';

  @override
  String get welcomeScan => 'Scan pairing QR';

  @override
  String get welcomeManual => 'Type server address and code';

  @override
  String get revokedNotice =>
      'The server revoked or removed this device. Pair it again.';

  @override
  String get scanTitle => 'Scan pairing QR';

  @override
  String get scanHint => 'Point the camera at the QR on the manager\'s screen.';

  @override
  String get scanCameraUnavailable =>
      'The camera did not open. Allow camera access, or go back and type the code.';

  @override
  String get pairingWorking => 'Pairing…';

  @override
  String get manualTitle => 'Type server address';

  @override
  String get manualServerLabel => 'Server address';

  @override
  String get manualServerHint =>
      'http://192.168.1.10 or https://pos.example.com';

  @override
  String get manualCodeLabel => 'Pairing code';

  @override
  String get manualNameLabel => 'Device name';

  @override
  String get manualSubmit => 'Pair';

  @override
  String get pairingNotPairingCode => 'This is not a ParkViet pairing QR.';

  @override
  String get pairingUnsupportedVersion =>
      'This QR is from another version. Update the app.';

  @override
  String get pairingWrongKind => 'This QR is not for pairing a device.';

  @override
  String get pairingInvalidUrl =>
      'The server address is not valid. It must start with http:// or https://.';

  @override
  String get pairingInsecureUrl =>
      'http:// is only for a server on the shop network (IP 192.168.x.x, 10.x.x.x, 172.16–31.x.x or a .local name). A server on the internet must use https://.';

  @override
  String get pairingMissingCode => 'The pairing code is missing.';

  @override
  String get pairingCodeInvalid =>
      'The pairing code is wrong or expired. Create a new one.';

  @override
  String get failureTimeout =>
      'The server did not answer in time. Check the network and try again.';

  @override
  String get failureTls =>
      'The server\'s security certificate (HTTPS) is not trusted. Check the address, or ask the installer to check the certificate.';

  @override
  String get failureCleartext =>
      'This device blocks unencrypted connections (http://) to that address.';

  @override
  String get failureUnreachable =>
      'Cannot reach the server. Check the address and that this device is on the server\'s network.';

  @override
  String get failureUnauthorized =>
      'The server does not recognise this device or sign-in.';

  @override
  String get failureForbidden => 'This device or account may not do that.';

  @override
  String get failureNotFound => 'Not found on the server.';

  @override
  String get failureRateLimited =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String failureConflict(String reason) {
    return 'The server refused: $reason';
  }

  @override
  String failureServer(int status) {
    return 'The server had an error ($status). Try again later.';
  }

  @override
  String get failureUnexpected => 'Something unexpected went wrong. Try again.';

  @override
  String get pinIncorrect => 'Wrong PIN.';

  @override
  String get pinNotSet => 'No PIN set. Set one in the dashboard first.';

  @override
  String get pinLocked =>
      'Too many wrong PINs. Locked for 15 minutes on this device.';

  @override
  String get pinRateLimited =>
      'Too many wrong PINs on this device. Wait a moment.';

  @override
  String get offlineTitle => 'Server unreachable';

  @override
  String offlineBody(String serverUrl) {
    return 'This device is paired with $serverUrl but could not reach it.';
  }

  @override
  String get retry => 'Try again';

  @override
  String get staffPickerTitle => 'Pick your name';

  @override
  String get managerPickerTitle => 'Manager confirmation';

  @override
  String get staffPickerEmpty => 'No staff at this branch yet.';

  @override
  String pinTitle(String name) {
    return '$name\'s PIN';
  }

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinSubmit => 'Sign in';

  @override
  String get managerDenied => 'This person may not manage devices.';

  @override
  String get signOut => 'Sign out';

  @override
  String get manageTitle => 'Device information';

  @override
  String get manageDeviceName => 'Device name';

  @override
  String get manageMode => 'Mode';

  @override
  String get manageBranch => 'Branch';

  @override
  String get manageServer => 'Server';

  @override
  String get manageAppVersion => 'App version';

  @override
  String get manageEditorId => 'Installation id';

  @override
  String get manageClockOffset => 'Clock offset from server (seconds)';

  @override
  String get manageRevokeHint =>
      'Unpairing only removes the pairing from this device. To revoke it for good, use Devices in the dashboard.';

  @override
  String get manageUnpair => 'Unpair';

  @override
  String get manageUnpairConfirmTitle => 'Unpair this device?';

  @override
  String get manageUnpairConfirmBody =>
      'The device forgets the server and needs a new code to pair again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get modeWaiter => 'Waiter';

  @override
  String get modeKds => 'Kitchen display';

  @override
  String get modeExpo => 'Runner';

  @override
  String get modeKiosk => 'Kiosk';

  @override
  String get modePrintStation => 'Print station';

  @override
  String get modeOwner => 'Owner';

  @override
  String get modeBridge => 'Device bridge';

  @override
  String modePlaceholderBody(String mode) {
    return 'The $mode mode comes in a later update. This device is paired and connected.';
  }

  @override
  String get realtimeConnected => 'Online';

  @override
  String get realtimeConnecting => 'Connecting';

  @override
  String get realtimeDisconnected => 'Disconnected';

  @override
  String get realtimeRejected => 'Refused';

  @override
  String get realtimeIdle => 'Not connected';

  @override
  String get stationIosWarning =>
      'iPhone and iPad cannot run in the background: keep the app open and the screen on to print.';

  @override
  String stationServerError(String message) {
    return 'Cannot reach the server: $message';
  }

  @override
  String get stationPrinters => 'Printers';

  @override
  String get stationNoPrinters =>
      'No print jobs yet. Printers show here after the first job, or after a test print from the dashboard.';

  @override
  String get stationTestPrint => 'Test print';

  @override
  String get stationRecent => 'Recent jobs';

  @override
  String get stationNoJobs => 'No print jobs yet.';

  @override
  String get stationLocalTest => 'local test';

  @override
  String get stationPrinted => 'Printed';

  @override
  String stationFailed(String error) {
    return 'Error: $error';
  }

  @override
  String get stationTestTitle => 'TEST PRINT';

  @override
  String get stationTestSample =>
      'Vietnamese: Phở bò tái, cà phê sữa đá, bánh mì.';

  @override
  String get stationTestDone => 'Test page sent.';

  @override
  String get stationForegroundTitle => 'ParkViet print station';

  @override
  String get stationForegroundText => 'Receiving print jobs';
}
