import 'package:flutter/widgets.dart';

import '../../core/app_mode.dart';
import '../mode_scaffold.dart';

class WaiterScreen extends StatelessWidget {
  const WaiterScreen({super.key});

  @override
  Widget build(BuildContext context) => const ModePlaceholder(mode: AppMode.waiter);
}
