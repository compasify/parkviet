import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// The owner's fingerprint or face before a grant. A phone without either,
/// or without a screen lock, answers [ApproverCheck.unavailable], and the
/// screen falls back to asking for a plain confirmation: the person already
/// signed in with their PIN.
enum ApproverCheck { passed, failed, unavailable }

abstract interface class ApproverConfirmation {
  Future<ApproverCheck> confirm(String reason);
}

class LocalAuthConfirmation implements ApproverConfirmation {
  LocalAuthConfirmation([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<ApproverCheck> confirm(String reason) async {
    try {
      if (!await _auth.isDeviceSupported()) return ApproverCheck.unavailable;
      final passed = await _auth.authenticate(localizedReason: reason);
      return passed ? ApproverCheck.passed : ApproverCheck.failed;
    } on PlatformException {
      return ApproverCheck.unavailable;
    } on MissingPluginException {
      return ApproverCheck.unavailable;
    }
  }
}

final approverConfirmationProvider = Provider<ApproverConfirmation>(
  (ref) => LocalAuthConfirmation(),
);

/// This phone's token for background notifications, from Firebase Cloud
/// Messaging or Apple Push. A build without that native setup has none,
/// and the owner hears events only while the app is open.
typedef PushToken = ({String platform, String token});

abstract interface class PushTokenSource {
  Future<PushToken?> token();
}

class NoPushTokenSource implements PushTokenSource {
  const NoPushTokenSource();

  @override
  Future<PushToken?> token() async => null;
}

final pushTokenSourceProvider = Provider<PushTokenSource>(
  (ref) => const NoPushTokenSource(),
);
