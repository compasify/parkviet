// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_all_day_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenAllDayRow extends KitchenAllDayRow {
  @override
  final String key;
  @override
  final String name;
  @override
  final BuiltList<KitchenTicketItemModifier> modifiers;
  @override
  final String quantity;
  @override
  final DateTime oldestSentAt;
  @override
  final BuiltList<String> itemIds;

  factory _$KitchenAllDayRow(
          [void Function(KitchenAllDayRowBuilder)? updates]) =>
      (KitchenAllDayRowBuilder()..update(updates))._build();

  _$KitchenAllDayRow._(
      {required this.key,
      required this.name,
      required this.modifiers,
      required this.quantity,
      required this.oldestSentAt,
      required this.itemIds})
      : super._();
  @override
  KitchenAllDayRow rebuild(void Function(KitchenAllDayRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenAllDayRowBuilder toBuilder() =>
      KitchenAllDayRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenAllDayRow &&
        key == other.key &&
        name == other.name &&
        modifiers == other.modifiers &&
        quantity == other.quantity &&
        oldestSentAt == other.oldestSentAt &&
        itemIds == other.itemIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, oldestSentAt.hashCode);
    _$hash = $jc(_$hash, itemIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenAllDayRow')
          ..add('key', key)
          ..add('name', name)
          ..add('modifiers', modifiers)
          ..add('quantity', quantity)
          ..add('oldestSentAt', oldestSentAt)
          ..add('itemIds', itemIds))
        .toString();
  }
}

class KitchenAllDayRowBuilder
    implements Builder<KitchenAllDayRow, KitchenAllDayRowBuilder> {
  _$KitchenAllDayRow? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<KitchenTicketItemModifier>? _modifiers;
  ListBuilder<KitchenTicketItemModifier> get modifiers =>
      _$this._modifiers ??= ListBuilder<KitchenTicketItemModifier>();
  set modifiers(ListBuilder<KitchenTicketItemModifier>? modifiers) =>
      _$this._modifiers = modifiers;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  DateTime? _oldestSentAt;
  DateTime? get oldestSentAt => _$this._oldestSentAt;
  set oldestSentAt(DateTime? oldestSentAt) =>
      _$this._oldestSentAt = oldestSentAt;

  ListBuilder<String>? _itemIds;
  ListBuilder<String> get itemIds => _$this._itemIds ??= ListBuilder<String>();
  set itemIds(ListBuilder<String>? itemIds) => _$this._itemIds = itemIds;

  KitchenAllDayRowBuilder() {
    KitchenAllDayRow._defaults(this);
  }

  KitchenAllDayRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _name = $v.name;
      _modifiers = $v.modifiers.toBuilder();
      _quantity = $v.quantity;
      _oldestSentAt = $v.oldestSentAt;
      _itemIds = $v.itemIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenAllDayRow other) {
    _$v = other as _$KitchenAllDayRow;
  }

  @override
  void update(void Function(KitchenAllDayRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenAllDayRow build() => _build();

  _$KitchenAllDayRow _build() {
    _$KitchenAllDayRow _$result;
    try {
      _$result = _$v ??
          _$KitchenAllDayRow._(
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'KitchenAllDayRow', 'key'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'KitchenAllDayRow', 'name'),
            modifiers: modifiers.build(),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'KitchenAllDayRow', 'quantity'),
            oldestSentAt: BuiltValueNullFieldError.checkNotNull(
                oldestSentAt, r'KitchenAllDayRow', 'oldestSentAt'),
            itemIds: itemIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();

        _$failedField = 'itemIds';
        itemIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenAllDayRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
