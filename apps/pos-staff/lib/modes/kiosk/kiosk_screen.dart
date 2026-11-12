import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';

import '../../auth/manager_hold_area.dart';
import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import 'kiosk_api.dart';
import 'kiosk_cart.dart';
import 'kiosk_device.dart';
import 'kiosk_flow.dart';

/// The smallest touch target and text on a kiosk: guests stand at arm's
/// length, some with poor sight.
const kioskTarget = 64.0;
const kioskMinTextScale = 1.45;

/// Self-ordering kiosk mode: the device works as the kiosk's service
/// account, without a PIN. The screen stays on and the app stays in front;
/// a manager leaves it by holding the welcome title and entering a PIN.
class KioskScreen extends ConsumerStatefulWidget {
  const KioskScreen({super.key});

  @override
  ConsumerState<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends ConsumerState<KioskScreen> {
  static const _device = PlatformKioskDevice();
  late final KioskFlow _flow = KioskFlow(
    api: ApiKioskApi(ref.read(apiClientProvider)),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_device.keepAwake(true));
    unawaited(_lock());
    unawaited(_flow.start());
  }

  bool _locked = true;

  /// Locks the app in front, and warns the manager when the device did not
  /// (no screen pinning, Guided Access off).
  Future<void> _lock() async {
    final locked = await _device.lock() || await _device.isLocked();
    if (mounted && locked != _locked) setState(() => _locked = locked);
  }

  @override
  void dispose() {
    unawaited(_device.keepAwake(false));
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KioskView(flow: _flow, locked: _locked);
}

/// What the guest sees, step by step, for one [KioskFlow].
class KioskView extends StatefulWidget {
  const KioskView({
    super.key,
    required this.flow,
    this.initialLocale,
    this.locked = true,
  });

  final KioskFlow flow;
  final Locale? initialLocale;

  /// False when the device does not keep the app in front; the welcome
  /// and paused screens then warn the manager.
  final bool locked;

  @override
  State<KioskView> createState() => _KioskViewState();
}

class _KioskViewState extends State<KioskView> {
  late Locale _locale = widget.initialLocale ?? const Locale('vi');
  bool _lowReach = false;

  KioskFlow get _flow => widget.flow;

  void _switchLanguage() {
    setState(
      () => _locale = _locale.languageCode == 'vi'
          ? const Locale('en')
          : const Locale('vi'),
    );
    _flow.touch();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final theme = base.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(kioskTarget, kioskTarget),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(kioskTarget, kioskTarget),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(kioskTarget, kioskTarget),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(kioskTarget, kioskTarget),
          iconSize: 32,
        ),
      ),
    );
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(minScaleFactor: kioskMinTextScale),
      ),
      child: Localizations.override(
        context: context,
        locale: _locale,
        child: Theme(
          data: theme,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _flow.touch(),
            child: ListenableBuilder(
              listenable: _flow,
              builder: (context, _) => Scaffold(
                body: SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(child: _body(context)),
                      if (_flow.reconnecting)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _ReconnectingBanner(),
                        ),
                      if (_flow.askingStillThere)
                        Positioned.fill(child: _StillThere(flow: _flow)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final toolbar = _Toolbar(
      lowReach: _lowReach,
      onLanguage: _switchLanguage,
      onLowReach: () {
        setState(() => _lowReach = !_lowReach);
        _flow.touch();
      },
    );
    final content = switch (_flow.step) {
      KioskStep.loading => const Center(child: CircularProgressIndicator()),
      KioskStep.paused => const _Paused(),
      KioskStep.welcome => _Welcome(flow: _flow),
      KioskStep.menu => _MenuStep(flow: _flow, locale: _locale),
      KioskStep.cart => _CartStep(flow: _flow),
      KioskStep.paying => _PayingStep(flow: _flow),
      KioskStep.done => _DoneStep(flow: _flow),
    };
    return Column(
      children: [
        toolbar,
        if (_flow.failure case final failure?) _FailureBanner(failure: failure),
        if (!widget.locked &&
            (_flow.step == KioskStep.welcome || _flow.step == KioskStep.paused))
          Container(
            key: const Key('kiosk-not-locked'),
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.all(12),
            child: Text(AppLocalizations.of(context).kioskNotLocked),
          ),
        // Low reach: the screen's content sits in its lower part, within reach
        // from a wheelchair or for a child.
        Expanded(
          child: _lowReach
              ? Column(
                  children: [
                    const Spacer(),
                    Expanded(flex: 2, child: content),
                  ],
                )
              : content,
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.lowReach,
    required this.onLanguage,
    required this.onLowReach,
  });

  final bool lowReach;
  final VoidCallback onLanguage;
  final VoidCallback onLowReach;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            key: const Key('kiosk-language'),
            onPressed: onLanguage,
            icon: const Icon(Icons.translate),
            label: Text(l10n.kioskLanguageSwitch),
          ),
          const Spacer(),
          Semantics(
            toggled: lowReach,
            child: TextButton.icon(
              key: const Key('kiosk-low-reach'),
              onPressed: onLowReach,
              icon: Icon(
                lowReach
                    ? Icons.vertical_align_top
                    : Icons.vertical_align_bottom,
              ),
              label: Text(l10n.kioskLowReach),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReconnectingBanner extends StatelessWidget {
  const _ReconnectingBanner();

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).kioskReconnecting,
              key: const Key('kiosk-reconnecting'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The kiosk's words for a refusal: what the guest can do about it.
String kioskFailureMessage(AppLocalizations l10n, AppFailure failure) =>
    switch (failure) {
      ConflictFailure(reason: 'item_sold_out' || 'item_unavailable') =>
        l10n.kioskFailureSoldOut,
      ConflictFailure(reason: 'kiosk_paused' || 'module_disabled') =>
        l10n.kioskFailurePaused,
      ConflictFailure(reason: 'vietqr_unavailable' || 'feature_disabled') =>
        l10n.kioskFailureQrUnavailable,
      _ => l10n.kioskFailureGeneric,
    };

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('kiosk-failure'),
        width: double.infinity,
        color: scheme.errorContainer,
        padding: const EdgeInsets.all(16),
        child: Text(
          kioskFailureMessage(AppLocalizations.of(context), failure),
          style: TextStyle(color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}

class _Paused extends StatelessWidget {
  const _Paused();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_outline, size: 96),
            const SizedBox(height: 24),
            ManagerHoldArea(
              child: Text(
                l10n.kioskPausedTitle,
                style: text.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.kioskPausedBody,
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.flow});

  final KioskFlow flow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return InkWell(
      key: const Key('kiosk-welcome'),
      onTap: flow.begin,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ManagerHoldArea(
                child: Text(
                  l10n.kioskWelcomeTitle,
                  style: text.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.kioskWelcomeHint,
                style: text.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                key: const Key('kiosk-start'),
                onPressed: flow.begin,
                icon: const Icon(Icons.touch_app),
                label: Text(l10n.kioskStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuStep extends StatelessWidget {
  const _MenuStep({required this.flow, required this.locale});

  final KioskFlow flow;
  final Locale locale;

  Future<void> _pick(BuildContext context, KioskMenuItem item) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final menu = flow.menu!;
    final groups = [
      for (final (index, group) in menu.modifierGroups.indexed)
        kioskModifierGroup(group, index),
    ];
    final menuItem = kioskMenuItem(item);
    final itemGroups = groupsOf(menuItem, groups);
    ModifierChoice? choice;
    if (itemGroups.isEmpty && item.variants.length == 1) {
      choice = ModifierChoice(
        variant: menuItem.variants.first,
        options: const [],
      );
    } else {
      final theme = Theme.of(context);
      final media = MediaQuery.of(context);
      choice = await showModalBottomSheet<ModifierChoice>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => MediaQuery(
          data: media,
          child: Localizations.override(
            context: sheetContext,
            locale: locale,
            child: Theme(
              data: theme,
              child: ModifierSheet(item: menuItem, groups: itemGroups),
            ),
          ),
        ),
      );
    }
    if (choice == null) return;
    if (!flow.add(KioskCartLine(item: item, choice: choice))) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.kioskCartFull)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menu = flow.menu;
    if (menu == null) return const Center(child: CircularProgressIndicator());
    final category = flow.selectedCategoryId;
    final items = [
      for (final item in menu.items)
        if (category == null || item.menuCategoryId == category) item,
    ]..sort((a, b) => a.position.compareTo(b.position));
    return Column(
      children: [
        if (menu.categories.isNotEmpty)
          SizedBox(
            height: kioskTarget + 16,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final row in menu.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('kiosk-category-${row.id}'),
                      label: Text(row.name),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      selected: row.id == category,
                      onSelected: (_) => flow.pickCategory(row.id),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _ItemTile(
              item: items[index],
              onTap: () => _pick(context, items[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('kiosk-cart'),
              onPressed: flow.cart.isEmpty ? null : flow.showCart,
              icon: const Icon(Icons.shopping_basket),
              label: Text(
                l10n.kioskCartButton(
                  flow.cart.count,
                  moneyLabel(flow.cart.total),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.onTap});

  final KioskMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final variant = item.variants.isEmpty ? null : item.variants.first;
    final price = variant == null
        ? ''
        : (variant.priceLabel ?? moneyLabel(money(variant.price)));
    final image = item.imageUrl;
    return Semantics(
      button: true,
      enabled: !item.soldOut,
      label: item.soldOut
          ? '${item.name}, $price, ${l10n.kioskSoldOut}'
          : '${item.name}, $price',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('kiosk-item-${item.id}'),
          onTap: item.soldOut || variant == null ? null : onTap,
          child: Opacity(
            opacity: item.soldOut ? 0.45 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: image == null
                      ? const ColoredBox(
                          color: Color(0x11000000),
                          child: Icon(Icons.restaurant, size: 48),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.restaurant, size: 48),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: text.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.soldOut ? l10n.kioskSoldOut : price,
                        style: text.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartStep extends StatelessWidget {
  const _CartStep({required this.flow});

  final KioskFlow flow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lines = flow.cart.lines;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.kioskCartTitle, style: text.headlineSmall),
        ),
        for (final (index, line) in lines.indexed) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              key: Key('kiosk-line-$index'),
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.title, style: text.titleMedium),
                      if (line.options.isNotEmpty)
                        Text(line.options, style: text.bodyMedium),
                      if (line.choice.note.isNotEmpty)
                        Text(line.choice.note, style: text.bodyMedium),
                      Text(moneyLabel(line.amount), style: text.bodyLarge),
                    ],
                  ),
                ),
                IconButton.outlined(
                  key: Key('kiosk-less-$index'),
                  tooltip: l10n.kioskLess(line.title),
                  onPressed: () => flow.setQuantity(index, line.quantity - 1),
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${line.quantity}', style: text.headlineSmall),
                ),
                IconButton.outlined(
                  key: Key('kiosk-more-$index'),
                  tooltip: l10n.kioskMore(line.title),
                  onPressed: line.quantity < kioskMaxQuantity
                      ? () => flow.setQuantity(index, line.quantity + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.kioskEstimate(moneyLabel(flow.cart.total)),
                style: text.headlineSmall,
              ),
              Text(l10n.kioskEstimateHint, style: text.bodyMedium),
              const SizedBox(height: 12),
              Text(l10n.kioskChoosePayment, style: text.titleMedium),
              const SizedBox(height: 8),
              if (flow.vietqrOffered) ...[
                FilledButton.icon(
                  key: const Key('kiosk-pay-qr'),
                  onPressed: flow.busy
                      ? null
                      : () => flow.checkout(KioskOrderInputPaymentEnum.vietqr),
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(l10n.kioskPayQr),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                key: const Key('kiosk-pay-counter'),
                onPressed: flow.busy
                    ? null
                    : () => flow.checkout(KioskOrderInputPaymentEnum.counter),
                icon: const Icon(Icons.point_of_sale),
                label: Text(l10n.kioskPayCounter),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('kiosk-back'),
                onPressed: flow.backToMenu,
                child: Text(l10n.kioskBackToMenu),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayingStep extends StatelessWidget {
  const _PayingStep({required this.flow});

  final KioskFlow flow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final order = flow.order!;
    final qr = order.payment?.qr;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.kioskQrTitle(moneyLabel(money(order.total))),
          key: const Key('kiosk-qr-title'),
          style: text.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (qr != null) ...[
          Center(
            child: Semantics(
              image: true,
              label: l10n.kioskQrImage,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  qr.qrUrl,
                  width: 280,
                  height: 280,
                  errorBuilder: (_, _, _) => const SizedBox.square(
                    dimension: 280,
                    child: Icon(Icons.qr_code_2, size: 120),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.kioskQrAccount(
              qr.bankName ?? '',
              qr.accountNumber,
              qr.accountName ?? '',
            ),
            style: text.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            l10n.kioskQrNote(qr.transferNote),
            key: const Key('kiosk-qr-note'),
            style: text.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        StreamBuilder<int>(
          stream: Stream.periodic(
            const Duration(seconds: 1),
            (_) => flow.qrSecondsLeft,
          ),
          initialData: flow.qrSecondsLeft,
          builder: (context, snapshot) => Semantics(
            liveRegion: true,
            child: Text(
              l10n.kioskQrLeft(snapshot.data ?? 0),
              key: const Key('kiosk-qr-left'),
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Text(
          l10n.kioskQrWaiting,
          style: text.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const Key('kiosk-qr-instead'),
          onPressed: flow.busy ? null : flow.payAtCounterInstead,
          icon: const Icon(Icons.point_of_sale),
          label: Text(l10n.kioskQrInstead),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('kiosk-start-over'),
          onPressed: flow.busy ? null : flow.abandon,
          child: Text(l10n.kioskStartOver),
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.flow});

  final KioskFlow flow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final order = flow.order;
    final paid = order?.status == KioskOrderStatusEnum.paid;
    final number = order?.callNumber;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.kioskDoneTitle, style: text.headlineMedium),
            const SizedBox(height: 16),
            if (number != null) ...[
              Text(l10n.kioskCallNumberLabel, style: text.titleLarge),
              Semantics(
                label: '${l10n.kioskCallNumberLabel} $number',
                excludeSemantics: true,
                child: Text(
                  '$number',
                  key: const Key('kiosk-call-number'),
                  style: text.displayLarge?.copyWith(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              paid ? l10n.kioskDonePaid : l10n.kioskDoneCounter,
              key: const Key('kiosk-done-message'),
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              key: const Key('kiosk-next'),
              onPressed: flow.next,
              child: Text(l10n.kioskNextGuest),
            ),
          ],
        ),
      ),
    );
  }
}

class _StillThere extends StatelessWidget {
  const _StillThere({required this.flow});

  final KioskFlow flow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          key: const Key('kiosk-still-there'),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.kioskStillThere, style: text.headlineMedium),
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.kioskStillThereBody(flow.stillThereLeft),
                    style: text.titleMedium,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('kiosk-still-here'),
                  onPressed: flow.stillHere,
                  child: Text(l10n.kioskStillHere),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: flow.abandon,
                  child: Text(l10n.kioskStartOver),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
