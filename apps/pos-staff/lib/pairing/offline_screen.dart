import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/failure_messages.dart';
import '../core/session.dart';
import '../l10n/app_localizations.dart';

/// Paired, but the server did not answer who this device is.
class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider).value;
    if (session is! Offline) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.offlineBody(session.serverUrl), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(failureMessage(l10n, session.failure), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.read(sessionProvider.notifier).retry(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
