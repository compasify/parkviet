import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/manager_hold_area.dart';
import '../auth/staff_session.dart';
import '../core/app_mode.dart';
import '../core/realtime_status_view.dart';
import '../l10n/app_localizations.dart';
import 'mode_names.dart';

/// The frame every mode shares: its name (hold it for management), the
/// realtime state and, for a signed-in person, sign-out.
class ModeScaffold extends ConsumerWidget {
  const ModeScaffold({super.key, required this.mode, required this.body, this.actions = const [], this.bottom});

  final AppMode mode;
  final Widget body;

  /// The mode's own buttons, before the realtime state.
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staff = ref.watch(staffSessionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: ManagerHoldArea(
          child: Text(staff?.name == null ? modeName(l10n, mode) : '${modeName(l10n, mode)} · ${staff!.name}'),
        ),
        bottom: bottom,
        actions: [
          ...actions,
          const RealtimeStatusView(),
          if (staff != null)
            IconButton(
              key: const Key('staff-sign-out'),
              tooltip: l10n.signOut,
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(staffSessionControllerProvider.notifier).signOut(),
            ),
        ],
      ),
      body: body,
    );
  }
}

/// A mode a later release builds. It is paired and connected already.
class ModePlaceholder extends StatelessWidget {
  const ModePlaceholder({super.key, required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModeScaffold(
      mode: mode,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.modePlaceholderBody(modeName(l10n, mode)), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
