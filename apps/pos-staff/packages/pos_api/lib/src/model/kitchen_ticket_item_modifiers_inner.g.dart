// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_item_modifiers_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenTicketItemModifiersInner
    extends KitchenTicketItemModifiersInner {
  @override
  final String name;
  @override
  final String? groupName;
  @override
  final int quantity;

  factory _$KitchenTicketItemModifiersInner(
          [void Function(KitchenTicketItemModifiersInnerBuilder)? updates]) =>
      (KitchenTicketItemModifiersInnerBuilder()..update(updates))._build();

  _$KitchenTicketItemModifiersInner._(
      {required this.name, this.groupName, required this.quantity})
      : super._();
  @override
  KitchenTicketItemModifiersInner rebuild(
          void Function(KitchenTicketItemModifiersInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketItemModifiersInnerBuilder toBuilder() =>
      KitchenTicketItemModifiersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicketItemModifiersInner &&
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
    return (newBuiltValueToStringHelper(r'KitchenTicketItemModifiersInner')
          ..add('name', name)
          ..add('groupName', groupName)
          ..add('quantity', quantity))
        .toString();
  }
}

class KitchenTicketItemModifiersInnerBuilder
    implements
        Builder<KitchenTicketItemModifiersInner,
            KitchenTicketItemModifiersInnerBuilder> {
  _$KitchenTicketItemModifiersInner? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  KitchenTicketItemModifiersInnerBuilder() {
    KitchenTicketItemModifiersInner._defaults(this);
  }

  KitchenTicketItemModifiersInnerBuilder get _$this {
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
  void replace(KitchenTicketItemModifiersInner other) {
    _$v = other as _$KitchenTicketItemModifiersInner;
  }

  @override
  void update(void Function(KitchenTicketItemModifiersInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicketItemModifiersInner build() => _build();

  _$KitchenTicketItemModifiersInner _build() {
    final _$result = _$v ??
        _$KitchenTicketItemModifiersInner._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenTicketItemModifiersInner', 'name'),
          groupName: groupName,
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KitchenTicketItemModifiersInner', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
