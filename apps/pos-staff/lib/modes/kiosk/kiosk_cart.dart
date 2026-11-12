import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/menu/modifier_sheet.dart';
import 'kiosk_api.dart';

/// The most of one dish a guest puts in the basket, and the most lines;
/// the server refuses more.
const kioskMaxQuantity = 20;
const kioskMaxLines = 20;

/// The kiosk menu in the shapes the shared option sheet reads. The kiosk's
/// menu leaves out what a guest has no business seeing (SKU, tax, kitchen
/// routing), so those fields stay empty here.
MenuItem kioskMenuItem(KioskMenuItem item) => MenuItem(
  (b) => b
    ..id = item.id
    ..productId = ''
    ..name = item.name
    ..kind = item.kind == KioskMenuItemKindEnum.combo
        ? MenuItemConfigKindEnum.combo
        : MenuItemConfigKindEnum.single
    ..menuCategoryId = item.menuCategoryId
    ..cupLabel = false
    ..showComponentsOnKds = false
    ..position = item.position
    ..active = true
    ..modifierGroupIds.replace(item.modifierGroupIds)
    ..imageUrl = item.imageUrl
    ..soldOut = item.soldOut
    ..variants.replace([
      for (final variant in item.variants)
        MenuItemAllOfVariants(
          (v) => v
            ..id = variant.id
            ..name = variant.name
            ..price = variant.price
            ..priceLabel = variant.priceLabel,
        ),
    ]),
);

ModifierGroup kioskModifierGroup(KioskModifierGroup group, int position) =>
    ModifierGroup(
      (b) => b
        ..id = group.id
        ..name = group.name
        ..minSelect = group.minSelect
        ..maxSelect = group.maxSelect
        ..allowQuantity = group.allowQuantity
        ..position = position
        ..required_ = group.required_
        ..options.replace([
          for (final (index, option) in group.options.indexed)
            ModifierGroupOptionsInner(
              (o) => o
                ..id = option.id
                ..name = option.name
                ..priceDelta = option.priceDelta
                ..defaultSelected = option.defaultSelected
                ..position = index
                ..active = true,
            ),
        ]),
    );

/// One line of the basket: the dish, what the guest picked, and its price
/// as the menu shows it now. The server prices the order again; the total
/// the guest pays is the one it answers.
@immutable
class KioskCartLine {
  const KioskCartLine({required this.item, required this.choice});

  final KioskMenuItem item;
  final ModifierChoice choice;

  int get quantity => choice.quantity;

  num get amount => choice.unitPrice * choice.quantity;

  String get title {
    final size = choice.variant.name;
    return size == null || size.isEmpty || item.variants.length < 2
        ? item.name
        : '${item.name} ($size)';
  }

  /// "Trân châu, Ít đá ×2".
  String get options => [
    for (final (option, count) in choice.options)
      count > 1 ? '${option.name} ×$count' : option.name,
  ].join(', ');

  /// The same dish, size, options and note.
  bool sameChoice(KioskCartLine other) =>
      choice.variant.id == other.choice.variant.id &&
      choice.note.trim() == other.choice.note.trim() &&
      listEquals(
        [for (final (option, count) in choice.options) '${option.id}:$count'],
        [
          for (final (option, count) in other.choice.options)
            '${option.id}:$count',
        ],
      );

  KioskCartLine withQuantity(int quantity) => KioskCartLine(
    item: item,
    choice: ModifierChoice(
      variant: choice.variant,
      options: choice.options,
      note: choice.note,
      quantity: quantity,
    ),
  );

  KioskItemInput get input => KioskItemInput(
    variantId: choice.variant.id,
    quantity: choice.quantity,
    options: [for (final (option, count) in choice.options) (option.id, count)],
    note: choice.note.trim().isEmpty ? null : choice.note.trim(),
  );
}

/// The guest's basket.
class KioskCart extends ChangeNotifier {
  final List<KioskCartLine> _lines = [];

  List<KioskCartLine> get lines => List.unmodifiable(_lines);

  bool get isEmpty => _lines.isEmpty;

  int get count => _lines.fold(0, (sum, line) => sum + line.quantity);

  num get total => _lines.fold<num>(0, (sum, line) => sum + line.amount);

  /// Adds a dish, to the same line when the guest picked the same again;
  /// false when the basket is full.
  bool add(KioskCartLine line) {
    final same = _lines.indexWhere((row) => row.sameChoice(line));
    if (same >= 0) {
      _lines[same] = _lines[same].withQuantity(
        (_lines[same].quantity + line.quantity).clamp(1, kioskMaxQuantity),
      );
      notifyListeners();
      return true;
    }
    if (_lines.length >= kioskMaxLines) return false;
    _lines.add(line.withQuantity(line.quantity.clamp(1, kioskMaxQuantity)));
    notifyListeners();
    return true;
  }

  /// Changes how many of a line; at zero the line goes.
  void setQuantity(int index, int quantity) {
    if (index < 0 || index >= _lines.length) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].withQuantity(
        quantity.clamp(1, kioskMaxQuantity),
      );
    }
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  List<KioskItemInput> get inputs => [for (final line in _lines) line.input];
}
