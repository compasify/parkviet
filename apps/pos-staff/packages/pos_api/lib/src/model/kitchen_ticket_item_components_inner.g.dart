// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_item_components_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenTicketItemComponentsInner
    extends KitchenTicketItemComponentsInner {
  @override
  final String name;
  @override
  final String quantity;

  factory _$KitchenTicketItemComponentsInner(
          [void Function(KitchenTicketItemComponentsInnerBuilder)? updates]) =>
      (KitchenTicketItemComponentsInnerBuilder()..update(updates))._build();

  _$KitchenTicketItemComponentsInner._(
      {required this.name, required this.quantity})
      : super._();
  @override
  KitchenTicketItemComponentsInner rebuild(
          void Function(KitchenTicketItemComponentsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketItemComponentsInnerBuilder toBuilder() =>
      KitchenTicketItemComponentsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicketItemComponentsInner &&
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
    return (newBuiltValueToStringHelper(r'KitchenTicketItemComponentsInner')
          ..add('name', name)
          ..add('quantity', quantity))
        .toString();
  }
}

class KitchenTicketItemComponentsInnerBuilder
    implements
        Builder<KitchenTicketItemComponentsInner,
            KitchenTicketItemComponentsInnerBuilder> {
  _$KitchenTicketItemComponentsInner? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  KitchenTicketItemComponentsInnerBuilder() {
    KitchenTicketItemComponentsInner._defaults(this);
  }

  KitchenTicketItemComponentsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenTicketItemComponentsInner other) {
    _$v = other as _$KitchenTicketItemComponentsInner;
  }

  @override
  void update(void Function(KitchenTicketItemComponentsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicketItemComponentsInner build() => _build();

  _$KitchenTicketItemComponentsInner _build() {
    final _$result = _$v ??
        _$KitchenTicketItemComponentsInner._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenTicketItemComponentsInner', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KitchenTicketItemComponentsInner', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
