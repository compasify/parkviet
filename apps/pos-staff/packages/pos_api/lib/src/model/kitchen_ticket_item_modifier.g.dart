// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_item_modifier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenTicketItemModifier extends KitchenTicketItemModifier {
  @override
  final String name;
  @override
  final String? groupName;
  @override
  final int quantity;

  factory _$KitchenTicketItemModifier(
          [void Function(KitchenTicketItemModifierBuilder)? updates]) =>
      (KitchenTicketItemModifierBuilder()..update(updates))._build();

  _$KitchenTicketItemModifier._(
      {required this.name, this.groupName, required this.quantity})
      : super._();
  @override
  KitchenTicketItemModifier rebuild(
          void Function(KitchenTicketItemModifierBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketItemModifierBuilder toBuilder() =>
      KitchenTicketItemModifierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicketItemModifier &&
        name == other.name &&
        groupName == other.groupName &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenTicketItemModifier')
          ..add('name', name)
          ..add('groupName', groupName)
          ..add('quantity', quantity))
        .toString();
  }
}

class KitchenTicketItemModifierBuilder
    implements
        Builder<KitchenTicketItemModifier, KitchenTicketItemModifierBuilder> {
  _$KitchenTicketItemModifier? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  KitchenTicketItemModifierBuilder() {
    KitchenTicketItemModifier._defaults(this);
  }

  KitchenTicketItemModifierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _groupName = $v.groupName;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenTicketItemModifier other) {
    _$v = other as _$KitchenTicketItemModifier;
  }

  @override
  void update(void Function(KitchenTicketItemModifierBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicketItemModifier build() => _build();

  _$KitchenTicketItemModifier _build() {
    final _$result = _$v ??
        _$KitchenTicketItemModifier._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenTicketItemModifier', 'name'),
          groupName: groupName,
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KitchenTicketItemModifier', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
