import 'package:flutter/widgets.dart';

import '../../core/app_mode.dart';
import '../mode_scaffold.dart';

class BridgeScreen extends StatelessWidget {
  const BridgeScreen({super.key});

  @override
  Widget build(BuildContext context) => const ModePlaceholder(mode: AppMode.bridge);
}
