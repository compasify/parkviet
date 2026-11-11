import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  try {
    await forgetPreviousInstall(PlatformSecretStore(), await SharedPreferences.getInstance());
  } catch (error) {
    // Without the flag it runs again on the next launch; the app still starts.
    debugPrint('Could not clear storage from a previous install: $error');
  }
  runApp(const ProviderScope(child: ParkvietStaffApp()));
}
