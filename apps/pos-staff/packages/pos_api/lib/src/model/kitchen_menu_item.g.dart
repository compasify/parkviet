// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_menu_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenMenuItem extends KitchenMenuItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? kitchenCategory;
  @override
  final bool soldOut;

  factory _$KitchenMenuItem([void Function(KitchenMenuItemBuilder)? updates]) =>
      (KitchenMenuItemBuilder()..update(updates))._build();

  _$KitchenMenuItem._(
      {required this.id,
      required this.name,
      this.kitchenCategory,
      required this.soldOut})
      : super._();
  @override
  KitchenMenuItem rebuild(void Function(KitchenMenuItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenMenuItemBuilder toBuilder() => KitchenMenuItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenMenuItem &&
        id == other.id &&
        name == other.name &&
        kitchenCategory == other.kitchenCategory &&
        soldOut == other.soldOut;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kitchenCategory.hashCode);
    _$hash = $jc(_$hash, soldOut.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenMenuItem')
          ..add('id', id)
          ..add('name', name)
          ..add('kitchenCategory', kitchenCategory)
          ..add('soldOut', soldOut))
        .toString();
  }
}

class KitchenMenuItemBuilder
    implements Builder<KitchenMenuItem, KitchenMenuItemBuilder> {
  _$KitchenMenuItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _kitchenCategory;
  String? get kitchenCategory => _$this._kitchenCategory;
  set kitchenCategory(String? kitchenCategory) =>
      _$this._kitchenCategory = kitchenCategory;

  bool? _soldOut;
  bool? get soldOut => _$this._soldOut;
  set soldOut(bool? soldOut) => _$this._soldOut = soldOut;

  KitchenMenuItemBuilder() {
    KitchenMenuItem._defaults(this);
  }

  KitchenMenuItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _kitchenCategory = $v.kitchenCategory;
      _soldOut = $v.soldOut;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenMenuItem other) {
    _$v = other as _$KitchenMenuItem;
  }

  @override
  void update(void Function(KitchenMenuItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenMenuItem build() => _build();

  _$KitchenMenuItem _build() {
    final _$result = _$v ??
        _$KitchenMenuItem._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KitchenMenuItem', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenMenuItem', 'name'),
          kitchenCategory: kitchenCategory,
          soldOut: BuiltValueNullFieldError.checkNotNull(
              soldOut, r'KitchenMenuItem', 'soldOut'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
