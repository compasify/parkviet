import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'realtime.dart';
import 'realtime_provider.dart';

/// The connection state every mode shows in its bar.
class RealtimeStatusView extends ConsumerWidget {
  const RealtimeStatusView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(realtimeProvider);
    if (client == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<RealtimeStatus>(
      valueListenable: client.status,
      builder: (context, status, _) {
        final (label, color) = switch (status) {
          RealtimeStatus.connected => (l10n.realtimeConnected, Colors.green),
          RealtimeStatus.connecting => (l10n.realtimeConnecting, Colors.orange),
          RealtimeStatus.disconnected => (l10n.realtimeDisconnected, Colors.red),
          RealtimeStatus.rejected => (l10n.realtimeRejected, Colors.red),
          RealtimeStatus.idle => (l10n.realtimeIdle, Colors.grey),
        };
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Chip(
            avatar: Icon(Icons.circle, size: 12, color: color),
            label: Text(label),
          ),
        );
      },
    );
  }
}
