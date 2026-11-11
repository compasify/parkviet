// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_config_components_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuItemConfigComponentsInner extends MenuItemConfigComponentsInner {
  @override
  final String id;
  @override
  final String variantId;
  @override
  final String name;
  @override
  final int quantity;

  factory _$MenuItemConfigComponentsInner(
          [void Function(MenuItemConfigComponentsInnerBuilder)? updates]) =>
      (MenuItemConfigComponentsInnerBuilder()..update(updates))._build();

  _$MenuItemConfigComponentsInner._(
      {required this.id,
      required this.variantId,
      required this.name,
      required this.quantity})
      : super._();
  @override
  MenuItemConfigComponentsInner rebuild(
          void Function(MenuItemConfigComponentsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuItemConfigComponentsInnerBuilder toBuilder() =>
      MenuItemConfigComponentsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuItemConfigComponentsInner &&
        id == other.id &&
        variantId == other.variantId &&
        name == other.name &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuItemConfigComponentsInner')
          ..add('id', id)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('quantity', quantity))
        .toString();
  }
}

class MenuItemConfigComponentsInnerBuilder
    implements
        Builder<MenuItemConfigComponentsInner,
            MenuItemConfigComponentsInnerBuilder> {
  _$MenuItemConfigComponentsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  MenuItemConfigComponentsInnerBuilder() {
    MenuItemConfigComponentsInner._defaults(this);
  }

  MenuItemConfigComponentsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _variantId = $v.variantId;
      _name = $v.name;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuItemConfigComponentsInner other) {
    _$v = other as _$MenuItemConfigComponentsInner;
  }

  @override
  void update(void Function(MenuItemConfigComponentsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuItemConfigComponentsInner build() => _build();

  _$MenuItemConfigComponentsInner _build() {
    final _$result = _$v ??
        _$MenuItemConfigComponentsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MenuItemConfigComponentsInner', 'id'),
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'MenuItemConfigComponentsInner', 'variantId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MenuItemConfigComponentsInner', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'MenuItemConfigComponentsInner', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
