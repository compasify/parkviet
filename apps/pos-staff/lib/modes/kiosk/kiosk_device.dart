import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// What a kiosk asks of the device it runs on: the screen stays on, and the
/// app stays in front (Android lock task, iOS Guided Access) until a
/// manager's PIN lets it go. The native side is `parkviet/kiosk`
/// (KioskLockChannel on Android, AppDelegate.swift on iOS).
abstract interface class KioskDevice {
  Future<void> keepAwake(bool on);

  /// True when the device now keeps the app in front.
  Future<bool> lock();

  Future<bool> unlock();

  Future<bool> isLocked();
}

class PlatformKioskDevice implements KioskDevice {
  const PlatformKioskDevice();

  static const _channel = MethodChannel('parkviet/kiosk');

  @override
  Future<void> keepAwake(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object {
      // A device without the plugin keeps its own screen timeout.
    }
  }

  @override
  Future<bool> lock() => _ask('start');

  @override
  Future<bool> unlock() => _ask('stop');

  @override
  Future<bool> isLocked() => _ask('isLocked');

  Future<bool> _ask(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
