import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/errors.dart';
import '../core/failure_messages.dart';
import '../core/realtime_status_view.dart';
import '../l10n/app_localizations.dart';
import 'manager_hold_area.dart';
import 'staff_session.dart';

enum PinPurpose { signIn, manage }

/// The names at the branch. Picking one asks for that person's PIN.
class StaffPickerScreen extends ConsumerWidget {
  const StaffPickerScreen({super.key, required this.purpose});

  final PinPurpose purpose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staff = ref.watch(branchStaffProvider);
    final title = Text(purpose == PinPurpose.manage ? l10n.managerPickerTitle : l10n.staffPickerTitle);
    return Scaffold(
      appBar: AppBar(
        title: purpose == PinPurpose.signIn ? ManagerHoldArea(child: title) : title,
        actions: const [RealtimeStatusView()],
      ),
      body: staff.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(failureMessage(l10n, failureFrom(error))),
              TextButton(onPressed: () => ref.invalidate(branchStaffProvider), child: Text(l10n.retry)),
            ],
          ),
        ),
        data: (members) => members.isEmpty
            ? Center(child: Text(l10n.staffPickerEmpty))
            : ListView(
                children: [
                  for (final member in members)
                    ListTile(
                      key: Key('staff-${member.id}'),
                      leading: const Icon(Icons.person),
                      title: Text(member.name),
                      subtitle: member.pinSet ? null : Text(l10n.pinNotSet),
                      enabled: member.pinSet,
                      onTap: () => context.push(
                        purpose == PinPurpose.manage ? '/manage/pin/${member.id}' : '/staff/pin/${member.id}',
                        extra: member.name,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
