// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_modifier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskOrderModifier extends KioskOrderModifier {
  @override
  final String name;
  @override
  final int quantity;

  factory _$KioskOrderModifier(
          [void Function(KioskOrderModifierBuilder)? updates]) =>
      (KioskOrderModifierBuilder()..update(updates))._build();

  _$KioskOrderModifier._({required this.name, required this.quantity})
      : super._();
  @override
  KioskOrderModifier rebuild(
          void Function(KioskOrderModifierBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderModifierBuilder toBuilder() =>
      KioskOrderModifierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderModifier &&
        name == other.name &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrderModifier')
          ..add('name', name)
          ..add('quantity', quantity))
        .toString();
  }
}

class KioskOrderModifierBuilder
    implements Builder<KioskOrderModifier, KioskOrderModifierBuilder> {
  _$KioskOrderModifier? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  KioskOrderModifierBuilder() {
    KioskOrderModifier._defaults(this);
  }

  KioskOrderModifierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderModifier other) {
    _$v = other as _$KioskOrderModifier;
  }

  @override
  void update(void Function(KioskOrderModifierBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderModifier build() => _build();

  _$KioskOrderModifier _build() {
    final _$result = _$v ??
        _$KioskOrderModifier._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KioskOrderModifier', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KioskOrderModifier', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
