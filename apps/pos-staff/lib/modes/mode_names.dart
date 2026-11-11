import '../core/app_mode.dart';
import '../l10n/app_localizations.dart';

String modeName(AppLocalizations l10n, AppMode mode) => switch (mode) {
      AppMode.waiter => l10n.modeWaiter,
      AppMode.kds => l10n.modeKds,
      AppMode.expo => l10n.modeExpo,
      AppMode.kiosk => l10n.modeKiosk,
      AppMode.printStation => l10n.modePrintStation,
      AppMode.owner => l10n.modeOwner,
      AppMode.bridge => l10n.modeBridge,
    };
