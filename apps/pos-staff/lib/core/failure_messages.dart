import '../l10n/app_localizations.dart';
import 'errors.dart';

/// A sentence a person can act on, for each failure.
String failureMessage(AppLocalizations l10n, AppFailure failure) => switch (failure) {
      TimeoutFailure() => l10n.failureTimeout,
      TlsFailure() => l10n.failureTls,
      CleartextFailure() => l10n.failureCleartext,
      UnreachableFailure() => l10n.failureUnreachable,
      UnauthorizedFailure(:final code) => switch (code) {
          'pin_incorrect' => l10n.pinIncorrect,
          'pin_not_set' => l10n.pinNotSet,
          _ => l10n.failureUnauthorized,
        },
      ForbiddenFailure() => l10n.failureForbidden,
      NotFoundFailure(:final code) => code == 'pairing_invalid' ? l10n.pairingCodeInvalid : l10n.failureNotFound,
      RateLimitedFailure(:final code) => switch (code) {
          'pin_locked' => l10n.pinLocked,
          'pin_rate_limited' => l10n.pinRateLimited,
          _ => l10n.failureRateLimited,
        },
      ConflictFailure(:final reason) => l10n.failureConflict(reason),
      ServerFailure(:final status) => l10n.failureServer(status),
      UnexpectedFailure() => l10n.failureUnexpected,
    };
