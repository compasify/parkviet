import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session.dart';
import '../l10n/app_localizations.dart';

/// First screen of an unpaired device: scan the manager's QR, or type the
/// server address and code.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider).value;
    final revoked = session is Unpaired && session.revoked;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text(l10n.welcomeTitle, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(l10n.welcomeBody),
              if (revoked) ...[
                const SizedBox(height: 12),
                Text(l10n.revokedNotice, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('welcome-scan'),
                onPressed: () => context.push('/pair/scan'),
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.welcomeScan),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('welcome-manual'),
                onPressed: () => context.push('/pair/manual'),
                icon: const Icon(Icons.keyboard),
                label: Text(l10n.welcomeManual),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
