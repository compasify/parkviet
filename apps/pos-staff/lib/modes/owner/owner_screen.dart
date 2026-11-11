import 'package:flutter/widgets.dart';

import '../../core/app_mode.dart';
import '../mode_scaffold.dart';

class OwnerScreen extends StatelessWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context) => const ModePlaceholder(mode: AppMode.owner);
}
