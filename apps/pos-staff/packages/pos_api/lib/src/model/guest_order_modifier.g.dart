// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_modifier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestOrderModifier extends GuestOrderModifier {
  @override
  final String optionId;
  @override
  final String name;
  @override
  final int quantity;

  factory _$GuestOrderModifier(
          [void Function(GuestOrderModifierBuilder)? updates]) =>
      (GuestOrderModifierBuilder()..update(updates))._build();

  _$GuestOrderModifier._(
      {required this.optionId, required this.name, required this.quantity})
      : super._();
  @override
  GuestOrderModifier rebuild(
          void Function(GuestOrderModifierBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderModifierBuilder toBuilder() =>
      GuestOrderModifierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderModifier &&
        optionId == other.optionId &&
        name == other.name &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, optionId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestOrderModifier')
          ..add('optionId', optionId)
          ..add('name', name)
          ..add('quantity', quantity))
        .toString();
  }
}

class GuestOrderModifierBuilder
    implements Builder<GuestOrderModifier, GuestOrderModifierBuilder> {
  _$GuestOrderModifier? _$v;

  String? _optionId;
  String? get optionId => _$this._optionId;
  set optionId(String? optionId) => _$this._optionId = optionId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  GuestOrderModifierBuilder() {
    GuestOrderModifier._defaults(this);
  }

  GuestOrderModifierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _optionId = $v.optionId;
      _name = $v.name;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderModifier other) {
    _$v = other as _$GuestOrderModifier;
  }

  @override
  void update(void Function(GuestOrderModifierBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderModifier build() => _build();

  _$GuestOrderModifier _build() {
    final _$result = _$v ??
        _$GuestOrderModifier._(
          optionId: BuiltValueNullFieldError.checkNotNull(
              optionId, r'GuestOrderModifier', 'optionId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GuestOrderModifier', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'GuestOrderModifier', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
