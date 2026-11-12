import 'package:pos_api/pos_api.dart';

/// The device modes, as the server names them, and how the app treats each.
enum AppMode {
  waiter('waiter', staffSignIn: true),
  kds('kds'),
  expo('expo'),
  kiosk('kiosk'),
  printStation('print-station'),
  owner('owner', staffSignIn: true);

  const AppMode(this.path, {this.staffSignIn = false});

  /// The route segment under `/mode/`.
  final String path;

  /// A person picks their name and enters a PIN before using the device.
  /// Every other mode works as the device itself.
  final bool staffSignIn;

  static AppMode of(DeviceModeEnum mode) => switch (mode) {
        DeviceModeEnum.waiter => waiter,
        DeviceModeEnum.kds => kds,
        DeviceModeEnum.expo => expo,
        DeviceModeEnum.kiosk => kiosk,
        DeviceModeEnum.printStation => printStation,
        DeviceModeEnum.owner => owner,
        _ => throw ArgumentError.value(mode, 'mode'),
      };

  static AppMode? fromPath(String path) {
    for (final mode in values) {
      if (mode.path == path) return mode;
    }
    return null;
  }
}
