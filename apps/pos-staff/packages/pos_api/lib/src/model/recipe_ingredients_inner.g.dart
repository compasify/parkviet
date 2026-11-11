// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredients_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecipeIngredientsInner extends RecipeIngredientsInner {
  @override
  final String id;
  @override
  final String variantId;
  @override
  final String? name;
  @override
  final String? sku;
  @override
  final String? optionsText;
  @override
  final String quantity;
  @override
  final String unitCode;
  @override
  final int baseQuantity;
  @override
  final String baseUnit;
  @override
  final String? unitCost;
  @override
  final String? cost;

  factory _$RecipeIngredientsInner(
          [void Function(RecipeIngredientsInnerBuilder)? updates]) =>
      (RecipeIngredientsInnerBuilder()..update(updates))._build();

  _$RecipeIngredientsInner._(
      {required this.id,
      required this.variantId,
      this.name,
      this.sku,
      this.optionsText,
      required this.quantity,
      required this.unitCode,
      required this.baseQuantity,
      required this.baseUnit,
      this.unitCost,
      this.cost})
      : super._();
  @override
  RecipeIngredientsInner rebuild(
          void Function(RecipeIngredientsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeIngredientsInnerBuilder toBuilder() =>
      RecipeIngredientsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeIngredientsInner &&
        id == other.id &&
        variantId == other.variantId &&
        name == other.name &&
        sku == other.sku &&
        optionsText == other.optionsText &&
        quantity == other.quantity &&
        unitCode == other.unitCode &&
        baseQuantity == other.baseQuantity &&
        baseUnit == other.baseUnit &&
        unitCost == other.unitCost &&
        cost == other.cost;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sku.hashCode);
    _$hash = $jc(_$hash, optionsText.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unitCode.hashCode);
    _$hash = $jc(_$hash, baseQuantity.hashCode);
    _$hash = $jc(_$hash, baseUnit.hashCode);
    _$hash = $jc(_$hash, unitCost.hashCode);
    _$hash = $jc(_$hash, cost.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecipeIngredientsInner')
          ..add('id', id)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('sku', sku)
          ..add('optionsText', optionsText)
          ..add('quantity', quantity)
          ..add('unitCode', unitCode)
          ..add('baseQuantity', baseQuantity)
          ..add('baseUnit', baseUnit)
          ..add('unitCost', unitCost)
          ..add('cost', cost))
        .toString();
  }
}

class RecipeIngredientsInnerBuilder
    implements Builder<RecipeIngredientsInner, RecipeIngredientsInnerBuilder> {
  _$RecipeIngredientsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _sku;
  String? get sku => _$this._sku;
  set sku(String? sku) => _$this._sku = sku;

  String? _optionsText;
  String? get optionsText => _$this._optionsText;
  set optionsText(String? optionsText) => _$this._optionsText = optionsText;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _unitCode;
  String? get unitCode => _$this._unitCode;
  set unitCode(String? unitCode) => _$this._unitCode = unitCode;

  int? _baseQuantity;
  int? get baseQuantity => _$this._baseQuantity;
  set baseQuantity(int? baseQuantity) => _$this._baseQuantity = baseQuantity;

  String? _baseUnit;
  String? get baseUnit => _$this._baseUnit;
  set baseUnit(String? baseUnit) => _$this._baseUnit = baseUnit;

  String? _unitCost;
  String? get unitCost => _$this._unitCost;
  set unitCost(String? unitCost) => _$this._unitCost = unitCost;

  String? _cost;
  String? get cost => _$this._cost;
  set cost(String? cost) => _$this._cost = cost;

  RecipeIngredientsInnerBuilder() {
    RecipeIngredientsInner._defaults(this);
  }

  RecipeIngredientsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _variantId = $v.variantId;
      _name = $v.name;
      _sku = $v.sku;
      _optionsText = $v.optionsText;
      _quantity = $v.quantity;
      _unitCode = $v.unitCode;
      _baseQuantity = $v.baseQuantity;
      _baseUnit = $v.baseUnit;
      _unitCost = $v.unitCost;
      _cost = $v.cost;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecipeIngredientsInner other) {
    _$v = other as _$RecipeIngredientsInner;
  }

  @override
  void update(void Function(RecipeIngredientsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecipeIngredientsInner build() => _build();

  _$RecipeIngredientsInner _build() {
    final _$result = _$v ??
        _$RecipeIngredientsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RecipeIngredientsInner', 'id'),
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'RecipeIngredientsInner', 'variantId'),
          name: name,
          sku: sku,
          optionsText: optionsText,
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'RecipeIngredientsInner', 'quantity'),
          unitCode: BuiltValueNullFieldError.checkNotNull(
              unitCode, r'RecipeIngredientsInner', 'unitCode'),
          baseQuantity: BuiltValueNullFieldError.checkNotNull(
              baseQuantity, r'RecipeIngredientsInner', 'baseQuantity'),
          baseUnit: BuiltValueNullFieldError.checkNotNull(
              baseUnit, r'RecipeIngredientsInner', 'baseUnit'),
          unitCost: unitCost,
          cost: cost,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
