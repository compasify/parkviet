// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_all_of_variants.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuItemAllOfVariants extends MenuItemAllOfVariants {
  @override
  final String id;
  @override
  final String? name;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  final String price;
  @override
  final String? listPrice;
  @override
  final String? scheduleId;

  factory _$MenuItemAllOfVariants(
          [void Function(MenuItemAllOfVariantsBuilder)? updates]) =>
      (MenuItemAllOfVariantsBuilder()..update(updates))._build();

  _$MenuItemAllOfVariants._(
      {required this.id,
      this.name,
      this.sku,
      this.barcode,
      required this.price,
      this.listPrice,
      this.scheduleId})
      : super._();
  @override
  MenuItemAllOfVariants rebuild(
          void Function(MenuItemAllOfVariantsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuItemAllOfVariantsBuilder toBuilder() =>
      MenuItemAllOfVariantsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuItemAllOfVariants &&
        id == other.id &&
        name == other.name &&
        sku == other.sku &&
        barcode == other.barcode &&
        price == other.price &&
        listPrice == other.listPrice &&
        scheduleId == other.scheduleId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sku.hashCode);
    _$hash = $jc(_$hash, barcode.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, listPrice.hashCode);
    _$hash = $jc(_$hash, scheduleId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuItemAllOfVariants')
          ..add('id', id)
          ..add('name', name)
          ..add('sku', sku)
          ..add('barcode', barcode)
          ..add('price', price)
          ..add('listPrice', listPrice)
          ..add('scheduleId', scheduleId))
        .toString();
  }
}

class MenuItemAllOfVariantsBuilder
    implements Builder<MenuItemAllOfVariants, MenuItemAllOfVariantsBuilder> {
  _$MenuItemAllOfVariants? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _sku;
  String? get sku => _$this._sku;
  set sku(String? sku) => _$this._sku = sku;

  String? _barcode;
  String? get barcode => _$this._barcode;
  set barcode(String? barcode) => _$this._barcode = barcode;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  String? _listPrice;
  String? get listPrice => _$this._listPrice;
  set listPrice(String? listPrice) => _$this._listPrice = listPrice;

  String? _scheduleId;
  String? get scheduleId => _$this._scheduleId;
  set scheduleId(String? scheduleId) => _$this._scheduleId = scheduleId;

  MenuItemAllOfVariantsBuilder() {
    MenuItemAllOfVariants._defaults(this);
  }

  MenuItemAllOfVariantsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _sku = $v.sku;
      _barcode = $v.barcode;
      _price = $v.price;
      _listPrice = $v.listPrice;
      _scheduleId = $v.scheduleId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuItemAllOfVariants other) {
    _$v = other as _$MenuItemAllOfVariants;
  }

  @override
  void update(void Function(MenuItemAllOfVariantsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuItemAllOfVariants build() => _build();

  _$MenuItemAllOfVariants _build() {
    final _$result = _$v ??
        _$MenuItemAllOfVariants._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MenuItemAllOfVariants', 'id'),
          name: name,
          sku: sku,
          barcode: barcode,
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'MenuItemAllOfVariants', 'price'),
          listPrice: listPrice,
          scheduleId: scheduleId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
