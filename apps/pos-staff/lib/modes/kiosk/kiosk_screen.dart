import 'package:flutter/widgets.dart';

import '../../core/app_mode.dart';
import '../mode_scaffold.dart';

class KioskScreen extends StatelessWidget {
  const KioskScreen({super.key});

  @override
  Widget build(BuildContext context) => const ModePlaceholder(mode: AppMode.kiosk);
}
