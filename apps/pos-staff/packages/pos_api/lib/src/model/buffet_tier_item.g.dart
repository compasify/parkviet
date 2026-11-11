// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buffet_tier_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BuffetTierItem extends BuffetTierItem {
  @override
  final String id;
  @override
  final String productId;
  @override
  final String variantId;
  @override
  final String name;
  @override
  final int? maxPerRound;

  factory _$BuffetTierItem([void Function(BuffetTierItemBuilder)? updates]) =>
      (BuffetTierItemBuilder()..update(updates))._build();

  _$BuffetTierItem._(
      {required this.id,
      required this.productId,
      required this.variantId,
      required this.name,
      this.maxPerRound})
      : super._();
  @override
  BuffetTierItem rebuild(void Function(BuffetTierItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuffetTierItemBuilder toBuilder() => BuffetTierItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuffetTierItem &&
        id == other.id &&
        productId == other.productId &&
        variantId == other.variantId &&
        name == other.name &&
        maxPerRound == other.maxPerRound;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, maxPerRound.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuffetTierItem')
          ..add('id', id)
          ..add('productId', productId)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('maxPerRound', maxPerRound))
        .toString();
  }
}

class BuffetTierItemBuilder
    implements Builder<BuffetTierItem, BuffetTierItemBuilder> {
  _$BuffetTierItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _maxPerRound;
  int? get maxPerRound => _$this._maxPerRound;
  set maxPerRound(int? maxPerRound) => _$this._maxPerRound = maxPerRound;

  BuffetTierItemBuilder() {
    BuffetTierItem._defaults(this);
  }

  BuffetTierItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _productId = $v.productId;
      _variantId = $v.variantId;
      _name = $v.name;
      _maxPerRound = $v.maxPerRound;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuffetTierItem other) {
    _$v = other as _$BuffetTierItem;
  }

  @override
  void update(void Function(BuffetTierItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuffetTierItem build() => _build();

  _$BuffetTierItem _build() {
    final _$result = _$v ??
        _$BuffetTierItem._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BuffetTierItem', 'id'),
          productId: BuiltValueNullFieldError.checkNotNull(
              productId, r'BuffetTierItem', 'productId'),
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'BuffetTierItem', 'variantId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BuffetTierItem', 'name'),
          maxPerRound: maxPerRound,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
