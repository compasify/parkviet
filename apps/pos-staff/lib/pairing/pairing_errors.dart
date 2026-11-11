import '../core/errors.dart';
import '../core/failure_messages.dart';
import '../l10n/app_localizations.dart';
import 'pairing_payload.dart';

/// What went wrong while pairing, from a QR problem or a server failure.
String pairingErrorMessage(AppLocalizations l10n, Object error) => switch (error) {
      PairingPayloadError(:final problem) => switch (problem) {
          PairingPayloadProblem.notPairingCode => l10n.pairingNotPairingCode,
          PairingPayloadProblem.unsupportedVersion => l10n.pairingUnsupportedVersion,
          PairingPayloadProblem.wrongKind => l10n.pairingWrongKind,
          PairingPayloadProblem.invalidUrl => l10n.pairingInvalidUrl,
          PairingPayloadProblem.insecureUrl => l10n.pairingInsecureUrl,
          PairingPayloadProblem.missingCode => l10n.pairingMissingCode,
        },
      AppFailure() => failureMessage(l10n, error),
      _ => l10n.failureUnexpected,
    };
