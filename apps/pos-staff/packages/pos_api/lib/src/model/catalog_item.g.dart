// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CatalogItem extends CatalogItem {
  @override
  final String productId;
  @override
  final String price;
  @override
  final num stockOnHand;

  factory _$CatalogItem([void Function(CatalogItemBuilder)? updates]) =>
      (CatalogItemBuilder()..update(updates))._build();

  _$CatalogItem._(
      {required this.productId, required this.price, required this.stockOnHand})
      : super._();
  @override
  CatalogItem rebuild(void Function(CatalogItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CatalogItemBuilder toBuilder() => CatalogItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CatalogItem &&
        productId == other.productId &&
        price == other.price &&
        stockOnHand == other.stockOnHand;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, stockOnHand.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CatalogItem')
          ..add('productId', productId)
          ..add('price', price)
          ..add('stockOnHand', stockOnHand))
        .toString();
  }
}

class CatalogItemBuilder implements Builder<CatalogItem, CatalogItemBuilder> {
  _$CatalogItem? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  num? _stockOnHand;
  num? get stockOnHand => _$this._stockOnHand;
  set stockOnHand(num? stockOnHand) => _$this._stockOnHand = stockOnHand;

  CatalogItemBuilder() {
    CatalogItem._defaults(this);
  }

  CatalogItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _price = $v.price;
      _stockOnHand = $v.stockOnHand;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CatalogItem other) {
    _$v = other as _$CatalogItem;
  }

  @override
  void update(void Function(CatalogItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CatalogItem build() => _build();

  _$CatalogItem _build() {
    final _$result = _$v ??
        _$CatalogItem._(
          productId: BuiltValueNullFieldError.checkNotNull(
              productId, r'CatalogItem', 'productId'),
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'CatalogItem', 'price'),
          stockOnHand: BuiltValueNullFieldError.checkNotNull(
              stockOnHand, r'CatalogItem', 'stockOnHand'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
