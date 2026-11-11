import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import '../../core/menu/modifier_sheet.dart';
import 'table_courses.dart';

/// One dish in the cart, before it is added to the order.
@immutable
class CartLine {
  const CartLine({required this.key, required this.item, required this.choice, this.placement = const TablePlacement()});

  /// Tells two cart lines apart on the screen.
  final String key;
  final MenuItem item;
  final ModifierChoice choice;

  /// The course, seat and hold the dish was put in the cart with.
  final TablePlacement placement;

  int get quantity => choice.quantity;
  num get total => choice.unitPrice * choice.quantity;

  /// The options as the order shows them: "Ít đá, Trân châu x2".
  String get optionsLabel =>
      choice.options.map((row) => row.$2 > 1 ? '${row.$1.name} x${row.$2}' : row.$1.name).join(', ');

  CartLine withQuantity(int quantity) => CartLine(
        key: key,
        item: item,
        choice: ModifierChoice(variant: choice.variant, options: choice.options, note: choice.note, quantity: quantity),
        placement: placement,
      );

  AppendItem toAppendItem() => AppendItem((b) {
        b
          ..variantId = choice.variant.id
          ..quantity = choice.quantity;
        placement.apply(b);
        if (choice.note.isNotEmpty) b.note = choice.note;
        if (choice.options.isNotEmpty) {
          b.modifiers.replace([
            for (final (option, quantity) in choice.options)
              ModifierPick((pick) => pick
                ..optionId = option.id
                ..quantity = quantity),
          ]);
        }
      });
}

/// The waiter's draft of what a table orders, kept on the phone until
/// "Thêm vào đơn". The batch id goes with every attempt to add it, so a
/// retry after a dropped connection does not add the dishes twice. It is
/// renewed when the cart changes, and once the dishes are on the order.
class WaiterCart extends ChangeNotifier {
  WaiterCart({Uuid uuid = const Uuid()}) : _uuid = uuid, batchId = uuid.v4();

  final Uuid _uuid;
  final _lines = <CartLine>[];
  int _next = 0;

  String batchId;

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get count => _lines.fold(0, (sum, line) => sum + line.quantity);
  num get total => _lines.fold<num>(0, (sum, line) => sum + line.total);

  /// Where the next dishes go; a dish keeps the placement it was added with.
  TablePlacement placement = const TablePlacement();

  void setPlacement(TablePlacement next) {
    placement = next;
    notifyListeners();
  }

  void add(MenuItem item, ModifierChoice choice) {
    _lines.add(CartLine(key: 'c${_next++}', item: item, choice: choice, placement: placement));
    _changed();
  }

  /// Zero or less takes the line out.
  void setQuantity(String key, int quantity) {
    final index = _lines.indexWhere((line) => line.key == key);
    if (index < 0) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].withQuantity(quantity.clamp(1, 99));
    }
    _changed();
  }

  void _changed() {
    batchId = _uuid.v4();
    notifyListeners();
  }

  List<AppendItem> toAppendItems() => [for (final line in _lines) line.toAppendItem()];

  /// After the dishes are on the order: an empty cart and a new batch.
  void clear() {
    _lines.clear();
    _changed();
  }
}
