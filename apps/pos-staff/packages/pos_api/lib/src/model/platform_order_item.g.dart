// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderItem extends PlatformOrderItem {
  @override
  final String name;
  @override
  final String quantity;
  @override
  final BuiltList<String> modifiers;
  @override
  final String? note;

  factory _$PlatformOrderItem(
          [void Function(PlatformOrderItemBuilder)? updates]) =>
      (PlatformOrderItemBuilder()..update(updates))._build();

  _$PlatformOrderItem._(
      {required this.name,
      required this.quantity,
      required this.modifiers,
      this.note})
      : super._();
  @override
  PlatformOrderItem rebuild(void Function(PlatformOrderItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderItemBuilder toBuilder() =>
      PlatformOrderItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderItem &&
        name == other.name &&
        quantity == other.quantity &&
        modifiers == other.modifiers &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformOrderItem')
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('modifiers', modifiers)
          ..add('note', note))
        .toString();
  }
}

class PlatformOrderItemBuilder
    implements Builder<PlatformOrderItem, PlatformOrderItemBuilder> {
  _$PlatformOrderItem? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  ListBuilder<String>? _modifiers;
  ListBuilder<String> get modifiers =>
      _$this._modifiers ??= ListBuilder<String>();
  set modifiers(ListBuilder<String>? modifiers) =>
      _$this._modifiers = modifiers;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  PlatformOrderItemBuilder() {
    PlatformOrderItem._defaults(this);
  }

  PlatformOrderItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _quantity = $v.quantity;
      _modifiers = $v.modifiers.toBuilder();
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderItem other) {
    _$v = other as _$PlatformOrderItem;
  }

  @override
  void update(void Function(PlatformOrderItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderItem build() => _build();

  _$PlatformOrderItem _build() {
    _$PlatformOrderItem _$result;
    try {
      _$result = _$v ??
          _$PlatformOrderItem._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'PlatformOrderItem', 'name'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'PlatformOrderItem', 'quantity'),
            modifiers: modifiers.build(),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformOrderItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
