import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps a print station working. The screen stays on; on Android a
/// foreground service with a notification keeps the app running when the
/// screen goes off anyway. iOS cannot run in the background, so the station
/// screen warns to keep the app open.
class StationKeepAwake {
  const StationKeepAwake();

  bool get runsInBackground => Platform.isAndroid;

  Future<void> start({required String title, required String text}) async {
    await WakelockPlus.enable();
    if (!Platform.isAndroid) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'print_station',
        channelName: title,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(showNotification: false),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    await FlutterForegroundTask.requestNotificationPermission();
    if (await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.startService(
      serviceTypes: [ForegroundServiceTypes.connectedDevice],
      notificationTitle: title,
      notificationText: text,
    );
  }

  Future<void> stop() async {
    await WakelockPlus.disable();
    if (Platform.isAndroid && await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}
