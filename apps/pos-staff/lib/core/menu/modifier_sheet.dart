import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../l10n/app_localizations.dart';

/// The most of one option the server takes when its group allows
/// quantities.
const maxOptionQuantity = 10;

/// The most characters of a line note.
const maxNoteLength = 200;

num money(String? value) => num.tryParse(value ?? '') ?? 0;

/// "50.000đ".
String moneyLabel(num value) {
  final digits = value.round().abs().toString();
  final grouped = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '${value < 0 ? '-' : ''}$groupedđ';
}

/// What a person picked for one dish: its variant, options with their
/// quantities, a note and how many.
@immutable
class ModifierChoice {
  const ModifierChoice({
    required this.variant,
    required this.options,
    this.note = '',
    this.quantity = 1,
  });

  final MenuItemAllOfVariants variant;

  /// The option and how many of it, in the order they were offered.
  final List<(ModifierGroupOptionsInner, int)> options;
  final String note;
  final int quantity;

  /// The price of one, options included.
  num get unitPrice => options.fold<num>(money(variant.price), (sum, row) => sum + money(row.$1.priceDelta) * row.$2);
}

/// The groups an item offers, in their order, with only active options.
List<ModifierGroup> groupsOf(MenuItem item, Iterable<ModifierGroup> all) {
  final byId = {for (final group in all) group.id: group};
  return [
    for (final id in item.modifierGroupIds)
      if (byId[id] case final group?) group,
  ]..sort((a, b) => a.position.compareTo(b.position));
}

/// The fewest picks a group takes: a required group takes at least one.
int minimumOf(ModifierGroup group) => group.required_ && group.minSelect < 1 ? 1 : group.minSelect;

/// How many a group counts: units when it allows quantities, else options.
int countOf(ModifierGroup group, Map<String, int> picks) => group.options
    .where((option) => (picks[option.id] ?? 0) > 0)
    .fold(0, (sum, option) => sum + (group.allowQuantity ? picks[option.id]! : 1));

/// The groups whose picks are outside their minimum and maximum, the same
/// rules the server applies (`modifier_min`, `modifier_max`).
List<ModifierGroup> invalidGroups(List<ModifierGroup> groups, Map<String, int> picks) => [
      for (final group in groups)
        if (countOf(group, picks) < minimumOf(group) || countOf(group, picks) > group.maxSelect) group,
    ];

/// The default picks of an item's groups.
Map<String, int> defaultPicks(List<ModifierGroup> groups) => {
      for (final group in groups)
        for (final option in group.options)
          if (option.active && option.defaultSelected) option.id: 1,
    };

/// Opens the options of [item] over the screen. Null when it is closed
/// without adding.
Future<ModifierChoice?> showModifierSheet(BuildContext context, MenuItem item, Iterable<ModifierGroup> groups) =>
    showModalBottomSheet<ModifierChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ModifierSheet(item: item, groups: groupsOf(item, groups)),
    );

/// The variants, option groups (with their minimum, maximum and price),
/// a note and the quantity of one dish. "Thêm" stays off until every
/// group is valid.
class ModifierSheet extends StatefulWidget {
  const ModifierSheet({super.key, required this.item, required this.groups});

  final MenuItem item;
  final List<ModifierGroup> groups;

  @override
  State<ModifierSheet> createState() => _ModifierSheetState();
}

class _ModifierSheetState extends State<ModifierSheet> {
  late MenuItemAllOfVariants _variant = widget.item.variants.first;
  late final Map<String, int> _picks = defaultPicks(widget.groups);
  final _note = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _toggle(ModifierGroup group, ModifierGroupOptionsInner option, int quantity) {
    setState(() {
      if (group.maxSelect == 1 && !group.allowQuantity && quantity > 0) {
        for (final other in group.options) {
          _picks.remove(other.id);
        }
      }
      if (quantity <= 0) {
        _picks.remove(option.id);
      } else {
        _picks[option.id] = quantity.clamp(1, group.allowQuantity ? maxOptionQuantity : 1);
      }
    });
  }

  ModifierChoice get _choice => ModifierChoice(
        variant: _variant,
        options: [
          for (final group in widget.groups)
            for (final option in group.options)
              if ((_picks[option.id] ?? 0) > 0) (option, _picks[option.id]!),
        ],
        note: _note.text.trim(),
        quantity: _quantity,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final invalid = invalidGroups(widget.groups, _picks).map((group) => group.id).toSet();
    final choice = _choice;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(widget.item.name, style: theme.textTheme.titleLarge),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (widget.item.variants.length > 1) ...[
                  Text(l10n.modifierVariant, style: theme.textTheme.titleMedium),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final variant in widget.item.variants)
                        ChoiceChip(
                          key: Key('variant-${variant.id}'),
                          label: Text('${variant.name ?? widget.item.name} · ${moneyLabel(money(variant.price))}'),
                          selected: variant.id == _variant.id,
                          onSelected: (_) => setState(() => _variant = variant),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                for (final group in widget.groups) ...[
                  Text(
                    group.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: invalid.contains(group.id) ? theme.colorScheme.error : null,
                    ),
                  ),
                  Text(
                    _rule(l10n, group),
                    key: Key('modifier-rule-${group.id}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: invalid.contains(group.id) ? theme.colorScheme.error : null,
                    ),
                  ),
                  for (final option in group.options.where((row) => row.active))
                    _OptionRow(
                      group: group,
                      option: option,
                      quantity: _picks[option.id] ?? 0,
                      onChanged: (quantity) => _toggle(group, option, quantity),
                    ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  key: const Key('modifier-note'),
                  controller: _note,
                  maxLength: maxNoteLength,
                  decoration: InputDecoration(labelText: l10n.modifierNote, border: const OutlineInputBorder()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton.outlined(
                  key: const Key('modifier-less'),
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('$_quantity', key: const Key('modifier-quantity'), style: theme.textTheme.headlineSmall),
                ),
                IconButton.outlined(
                  key: const Key('modifier-more'),
                  onPressed: _quantity < 99 ? () => setState(() => _quantity++) : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      key: const Key('modifier-add'),
                      onPressed: invalid.isEmpty ? () => Navigator.of(context).pop(choice) : null,
                      child: Text(l10n.modifierAdd(moneyLabel(choice.unitPrice * _quantity))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rule(AppLocalizations l10n, ModifierGroup group) {
    final min = minimumOf(group);
    if (min == group.maxSelect) return l10n.modifierPickExactly(min);
    if (min > 0) return l10n.modifierPickBetween(min, group.maxSelect);
    return l10n.modifierPickUpTo(group.maxSelect);
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.group, required this.option, required this.quantity, required this.onChanged});

  final ModifierGroup group;
  final ModifierGroupOptionsInner option;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final delta = money(option.priceDelta);
    final price = delta == 0 ? null : Text('${delta > 0 ? '+' : ''}${moneyLabel(delta)}');
    if (!group.allowQuantity) {
      return CheckboxListTile(
        key: Key('option-${option.id}'),
        contentPadding: EdgeInsets.zero,
        value: quantity > 0,
        title: Text(option.name),
        secondary: price,
        onChanged: (on) => onChanged(on == true ? 1 : 0),
      );
    }
    return ListTile(
      key: Key('option-${option.id}'),
      contentPadding: EdgeInsets.zero,
      title: Text(option.name),
      subtitle: price,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('option-less-${option.id}'),
            onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$quantity'),
          IconButton(
            key: Key('option-more-${option.id}'),
            onPressed: quantity < maxOptionQuantity ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
