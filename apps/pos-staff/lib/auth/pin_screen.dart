import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/errors.dart';
import '../core/failure_messages.dart';
import '../core/session.dart';
import '../l10n/app_localizations.dart';
import 'manager_access.dart';
import 'staff_picker_screen.dart';
import 'staff_session.dart';

/// One person's PIN, for signing in or for opening device management.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key, required this.membershipId, required this.name, required this.purpose});

  final String membershipId;
  final String name;
  final PinPurpose purpose;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final _pin = TextEditingController();
  bool _working = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final pin = _pin.text.trim();
    if (pin.isEmpty) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      if (widget.purpose == PinPurpose.signIn) {
        await ref.read(staffSessionControllerProvider.notifier).signIn(membershipId: widget.membershipId, pin: pin);
        return;
      }
      final session = ref.read(sessionProvider).value;
      if (session is! Paired) return;
      final allowed = await verifyManager(
        ref.read(apiClientProvider),
        branchId: session.me.branch.id,
        membershipId: widget.membershipId,
        pin: pin,
      );
      if (!mounted) return;
      if (!allowed) {
        setState(() => _error = l10n.managerDenied);
        return;
      }
      ref.read(managerAccessProvider.notifier).grant();
      context.go('/manage');
    } on Object catch (error) {
      if (mounted) setState(() => _error = failureMessage(l10n, failureFrom(error)));
    } finally {
      if (mounted) {
        _pin.clear();
        setState(() => _working = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pinTitle(widget.name))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                key: const Key('pin-input'),
                controller: _pin,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(labelText: l10n.pinLabel),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null)
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('pin-submit'),
                onPressed: _working ? null : _submit,
                child: Text(l10n.pinSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
