import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// What this device says about itself when pairing.
class DeviceDescriptor {
  const DeviceDescriptor({required this.platform, required this.model, required this.appVersion});

  /// `android` or `ios`, the server's platform names.
  final String platform;
  final String model;
  final String appVersion;

  static Future<DeviceDescriptor> load() async {
    final package = await PackageInfo.fromPlatform();
    final version = '${package.version}+${package.buildNumber}';
    final info = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return DeviceDescriptor(platform: 'ios', model: ios.name, appVersion: version);
    }
    final android = await info.androidInfo;
    final model = [android.manufacturer, android.model].where((part) => part.isNotEmpty).join(' ');
    return DeviceDescriptor(platform: 'android', model: model, appVersion: version);
  }
}
