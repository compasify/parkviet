import 'package:flutter/widgets.dart';

import '../../core/app_mode.dart';
import '../mode_scaffold.dart';

class ExpoScreen extends StatelessWidget {
  const ExpoScreen({super.key});

  @override
  Widget build(BuildContext context) => const ModePlaceholder(mode: AppMode.expo);
}
