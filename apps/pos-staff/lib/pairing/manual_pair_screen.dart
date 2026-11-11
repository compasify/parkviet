import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/session.dart';
import '../l10n/app_localizations.dart';
import 'pairing_errors.dart';

/// Pairs with a typed server address and the code from the manager's screen.
class ManualPairScreen extends ConsumerStatefulWidget {
  const ManualPairScreen({super.key});

  @override
  ConsumerState<ManualPairScreen> createState() => _ManualPairScreenState();
}

class _ManualPairScreenState extends ConsumerState<ManualPairScreen> {
  final _server = TextEditingController();
  final _code = TextEditingController();
  final _name = TextEditingController();
  bool _working = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(deviceDescriptorProvider.future).then((descriptor) {
      if (mounted && _name.text.isEmpty) _name.text = descriptor.model;
    }).ignore();
  }

  @override
  void dispose() {
    _server.dispose();
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).pair(serverUrl: _server.text, code: _code.text, name: _name.text);
    } on Object catch (error) {
      if (mounted) setState(() => _error = pairingErrorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              TextField(
                key: const Key('manual-server'),
                controller: _server,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.manualServerLabel, hintText: l10n.manualServerHint),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('manual-code'),
                controller: _code,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l10n.manualCodeLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('manual-name'),
                controller: _name,
                maxLength: 80,
                decoration: InputDecoration(labelText: l10n.manualNameLabel),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('manual-submit'),
                onPressed: _working ? null : _submit,
                child: _working ? Text(l10n.pairingWorking) : Text(l10n.manualSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
