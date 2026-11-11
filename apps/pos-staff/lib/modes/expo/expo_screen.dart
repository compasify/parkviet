import 'package:flutter/widgets.dart';

import '../../core/app_mode.dart';
import '../kds/kds_screen.dart';

/// The pass: every station's tickets, to send plates out when all is ready.
class ExpoScreen extends StatelessWidget {
  const ExpoScreen({super.key});

  @override
  Widget build(BuildContext context) => const KdsScreen(mode: AppMode.expo);
}
