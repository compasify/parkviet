// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_menu_variant.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskMenuVariant extends KioskMenuVariant {
  @override
  final String id;
  @override
  final String? name;
  @override
  final String price;
  @override
  final String? priceLabel;

  factory _$KioskMenuVariant(
          [void Function(KioskMenuVariantBuilder)? updates]) =>
      (KioskMenuVariantBuilder()..update(updates))._build();

  _$KioskMenuVariant._(
      {required this.id, this.name, required this.price, this.priceLabel})
      : super._();
  @override
  KioskMenuVariant rebuild(void Function(KioskMenuVariantBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskMenuVariantBuilder toBuilder() =>
      KioskMenuVariantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskMenuVariant &&
        id == other.id &&
        name == other.name &&
        price == other.price &&
        priceLabel == other.priceLabel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, priceLabel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskMenuVariant')
          ..add('id', id)
          ..add('name', name)
          ..add('price', price)
          ..add('priceLabel', priceLabel))
        .toString();
  }
}

class KioskMenuVariantBuilder
    implements Builder<KioskMenuVariant, KioskMenuVariantBuilder> {
  _$KioskMenuVariant? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  String? _priceLabel;
  String? get priceLabel => _$this._priceLabel;
  set priceLabel(String? priceLabel) => _$this._priceLabel = priceLabel;

  KioskMenuVariantBuilder() {
    KioskMenuVariant._defaults(this);
  }

  KioskMenuVariantBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _price = $v.price;
      _priceLabel = $v.priceLabel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskMenuVariant other) {
    _$v = other as _$KioskMenuVariant;
  }

  @override
  void update(void Function(KioskMenuVariantBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskMenuVariant build() => _build();

  _$KioskMenuVariant _build() {
    final _$result = _$v ??
        _$KioskMenuVariant._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KioskMenuVariant', 'id'),
          name: name,
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'KioskMenuVariant', 'price'),
          priceLabel: priceLabel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
