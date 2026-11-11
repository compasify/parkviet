import '../../core/errors.dart';
import '../../core/failure_messages.dart';
import '../../l10n/app_localizations.dart';

/// The refusals a waiter meets most, in words a person acts on; anything
/// else as the app says it elsewhere.
String waiterFailureMessage(AppLocalizations l10n, AppFailure failure) => switch (failure) {
      ConflictFailure(reason: 'line_changed') => l10n.waiterLineChanged,
      ConflictFailure(reason: 'snapshot_locked') => l10n.waiterSnapshotLocked,
      ConflictFailure(reason: 'lease_busy' || 'lease_stale') => l10n.waiterLeaseBusy,
      ConflictFailure(reason: 'workspace_closed') => l10n.waiterWorkspaceClosed,
      ConflictFailure(reason: 'menu_item_sold_out') => l10n.waiterSoldOut,
      ConflictFailure(reason: 'table_occupied') => l10n.waiterTableOccupied,
      ConflictFailure(reason: 'table_unavailable' || 'table_archived') => l10n.waiterTableUnavailable,
      ConflictFailure(reason: 'guest_count_invalid' || 'table_full') => l10n.waiterGuestCountInvalid,
      ConflictFailure(reason: 'modifier_min' || 'modifier_max' || 'modifier_unknown') => l10n.waiterModifierInvalid,
      ConflictFailure(reason: 'void_quantity_invalid') => l10n.waiterVoidQuantityInvalid,
      ConflictFailure(reason: 'void_reason_invalid' || 'void_note_required') => l10n.waiterVoidReasonInvalid,
      ConflictFailure(reason: 'payment_request_status_invalid') => l10n.waiterPaymentRequested,
      ForbiddenFailure() => l10n.waiterForbidden,
      _ => failureMessage(l10n, failure),
    };

/// A refusal after which the screen reads the order again.
bool needsRefetch(AppFailure failure) => switch (failure) {
      ConflictFailure(:final reason) => const {'line_changed', 'snapshot_locked', 'lease_stale', 'workspace_closed'}
          .contains(reason),
      _ => false,
    };
