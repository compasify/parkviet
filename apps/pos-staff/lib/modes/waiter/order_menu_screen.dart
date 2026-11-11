import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart';
import '../../l10n/app_localizations.dart';
import 'table_courses.dart';
import 'waiter_cart.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';

/// What adding the cart did: the order as it stands, and whether the
/// kitchen was told.
typedef AddOutcome = ({Workspace workspace, bool sent});

/// Ordering for one table: category tabs, search, dishes with their
/// picture, the options sheet, and the cart at the bottom with "Thêm vào
/// đơn" and "Thêm và báo bếp". The cart stays on the phone until one of
/// them works; a sold-out dish is dimmed and cannot go in it.
class OrderMenuScreen extends StatefulWidget {
  const OrderMenuScreen({super.key, required this.waiter, required this.workspaceId, required this.title});

  final WaiterContext waiter;
  final String workspaceId;
  final String title;

  @override
  State<OrderMenuScreen> createState() => _OrderMenuScreenState();
}

class _OrderMenuScreenState extends State<OrderMenuScreen> {
  final _cart = WaiterCart();
  final _search = TextEditingController();
  String? _categoryId;
  bool _busy = false;

  MenuCache get _menu => widget.waiter.menu;

  @override
  void initState() {
    super.initState();
    _cart.addListener(_changed);
    _search.addListener(_changed);
    if (_menu.menu.value == null) _menu.load();
  }

  @override
  void dispose() {
    _cart.dispose();
    _search.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  Future<void> _pick(Menu menu, MenuItem item) async {
    final l10n = AppLocalizations.of(context);
    if (item.soldOut) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.waiterSoldOut)));
      return;
    }
    if (item.variants.isEmpty) return;
    final groups = groupsOf(item, menu.modifierGroups);
    final choice = groups.isEmpty && item.variants.length == 1
        ? ModifierChoice(variant: item.variants.first, options: const [])
        : await showModifierSheet(context, item, menu.modifierGroups);
    if (choice != null) _cart.add(item, choice);
  }

  Future<void> _add({required bool send}) async {
    if (_cart.isEmpty || _busy) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      var workspace = await widget.waiter.api.append(widget.workspaceId, _cart.toAppendItems(), batchId: _cart.batchId);
      _cart.clear();
      if (send) workspace = await widget.waiter.api.sendToKitchen(widget.workspaceId);
      navigator.pop<AddOutcome>((workspace: workspace, sent: send));
    } on AppFailure catch (failure) {
      // The cart stays with its batch id: trying again adds it once.
      messenger.showSnackBar(SnackBar(content: Text(waiterFailureMessage(l10n, failure))));
      if (_cart.isEmpty) navigator.pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.waiterOrderFor(widget.title))),
      body: ValueListenableBuilder<Menu?>(
        valueListenable: _menu.menu,
        builder: (context, menu, _) {
          if (menu == null) {
            return ValueListenableBuilder<AppFailure?>(
              valueListenable: _menu.failure,
              builder: (context, failure, _) => Center(
                child: failure == null
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(waiterFailureMessage(l10n, failure)),
                          TextButton(onPressed: _menu.load, child: Text(l10n.retry)),
                        ],
                      ),
              ),
            );
          }
          return _body(menu);
        },
      ),
      bottomNavigationBar: _cart.isEmpty ? null : _CartBar(cart: _cart, busy: _busy, onAdd: _add),
    );
  }

  Widget _body(Menu menu) {
    final l10n = AppLocalizations.of(context);
    final categories = menu.categories.where((row) => row.active).toList()..sort((a, b) => a.position.compareTo(b.position));
    final query = _search.text.trim().toLowerCase();
    final items = menu.items
        .where((item) => item.active && item.variants.isNotEmpty)
        .where((item) => query.isNotEmpty || _categoryId == null || item.menuCategoryId == _categoryId)
        .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: TextField(
            key: const Key('menu-search'),
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.waiterSearch,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: const Key('category-all'),
                  label: Text(l10n.waiterAllCategories),
                  selected: _categoryId == null,
                  onSelected: (_) => setState(() => _categoryId = null),
                ),
              ),
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('category-${category.id}'),
                    label: Text(category.name),
                    selected: _categoryId == category.id,
                    onSelected: (_) => setState(() => _categoryId = category.id),
                  ),
                ),
            ],
          ),
        ),
        _PlacementBar(placement: _cart.placement, onChanged: _cart.setPlacement),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(l10n.waiterNoDishes))
              : GridView.builder(
                  key: const Key('menu-grid'),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _DishTile(
                    item: items[index],
                    imageUrl: widget.waiter.imageUrl(items[index].imageUrl),
                    onTap: () => _pick(menu, items[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

/// The course, seat and hold the next dishes go in the cart with.
class _PlacementBar extends StatelessWidget {
  const _PlacementBar({required this.placement, required this.onChanged});

  final TablePlacement placement;
  final ValueChanged<TablePlacement> onChanged;

  static const _seats = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        key: const Key('placement-bar'),
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        children: [
          for (final course in [null, ...tableCourses])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                key: Key('course-${course ?? 'none'}'),
                label: Text(course == null ? l10n.courseNone : courseLabel(l10n, course)),
                selected: placement.course == course,
                onSelected: (_) => onChanged(placement.copyWith(course: () => course)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              key: const Key('course-hold'),
              label: Text(l10n.courseHold),
              selected: placement.holds,
              onSelected: placement.course == null ? null : (hold) => onChanged(placement.copyWith(hold: hold)),
            ),
          ),
          DropdownButton<int?>(
            key: const Key('seat-picker'),
            value: placement.seat,
            hint: Text(l10n.seatLabel),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.seatShared)),
              for (var seat = 1; seat <= _seats; seat++)
                DropdownMenuItem<int?>(value: seat, child: Text(l10n.seatNumber(seat))),
            ],
            onChanged: (seat) => onChanged(placement.copyWith(seat: () => seat)),
          ),
        ],
      ),
    );
  }
}

class _DishTile extends StatelessWidget {
  const _DishTile({required this.item, required this.imageUrl, required this.onTap});

  final MenuItem item;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prices = item.variants.map((variant) => money(variant.price)).toList()..sort();
    return Opacity(
      opacity: item.soldOut ? 0.4 : 1,
      child: Card(
        key: Key('dish-${item.id}'),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: imageUrl == null
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant, size: 40),
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.restaurant, size: 40),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    Text(
                      item.soldOut ? l10n.waiterSoldOutLabel : moneyLabel(prices.first),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: item.soldOut ? theme.colorScheme.error : null,
                        fontWeight: item.soldOut ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cart: how many and how much, its lines to change, and the two ways
/// to put it on the order.
class _CartBar extends StatelessWidget {
  const _CartBar({required this.cart, required this.busy, required this.onAdd});

  final WaiterCart cart;
  final bool busy;
  final Future<void> Function({required bool send}) onAdd;

  Future<void> _lines(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => ListenableBuilder(
          listenable: cart,
          builder: (sheet, _) => ListView(
            shrinkWrap: true,
            children: [
              for (final line in cart.lines)
                ListTile(
                  key: Key('cart-${line.key}'),
                  title: Text(line.item.name),
                  subtitle: Text([
                    if (line.optionsLabel.isNotEmpty) '+ ${line.optionsLabel}',
                    if (line.placement.seat != null) AppLocalizations.of(sheet).seatNumber(line.placement.seat!),
                    if (line.placement.course != null)
                      [
                        courseLabel(AppLocalizations.of(sheet), line.placement.course!),
                        if (line.placement.holds) AppLocalizations.of(sheet).courseHold,
                      ].join(' · '),
                    if (line.choice.note.isNotEmpty) line.choice.note,
                    moneyLabel(line.total),
                  ].join('\n')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('cart-less-${line.key}'),
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => cart.setQuantity(line.key, line.quantity - 1),
                      ),
                      Text('${line.quantity}', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        key: Key('cart-more-${line.key}'),
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => cart.setQuantity(line.key, line.quantity + 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            TextButton(
              key: const Key('cart-open'),
              onPressed: () => _lines(context),
              child: Text(l10n.waiterCart(cart.count, moneyLabel(cart.total))),
            ),
            const Spacer(),
            OutlinedButton(
              key: const Key('cart-add'),
              onPressed: busy ? null : () => onAdd(send: false),
              child: Text(l10n.waiterAddToOrder),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('cart-add-send'),
              onPressed: busy ? null : () => onAdd(send: true),
              child: Text(l10n.waiterAddAndSend),
            ),
          ],
        ),
      ),
    );
  }
}
