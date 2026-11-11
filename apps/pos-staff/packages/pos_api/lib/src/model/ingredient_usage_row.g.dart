// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_usage_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IngredientUsageRow extends IngredientUsageRow {
  @override
  final Date businessDate;
  @override
  final String ingredient;
  @override
  final String? ingredientSku;
  @override
  final String menuItem;
  @override
  final int quantity;
  @override
  final String unit;
  @override
  final String cost;
  @override
  final bool costMissing;

  factory _$IngredientUsageRow(
          [void Function(IngredientUsageRowBuilder)? updates]) =>
      (IngredientUsageRowBuilder()..update(updates))._build();

  _$IngredientUsageRow._(
      {required this.businessDate,
      required this.ingredient,
      this.ingredientSku,
      required this.menuItem,
      required this.quantity,
      required this.unit,
      required this.cost,
      required this.costMissing})
      : super._();
  @override
  IngredientUsageRow rebuild(
          void Function(IngredientUsageRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientUsageRowBuilder toBuilder() =>
      IngredientUsageRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientUsageRow &&
        businessDate == other.businessDate &&
        ingredient == other.ingredient &&
        ingredientSku == other.ingredientSku &&
        menuItem == other.menuItem &&
        quantity == other.quantity &&
        unit == other.unit &&
        cost == other.cost &&
        costMissing == other.costMissing;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, ingredient.hashCode);
    _$hash = $jc(_$hash, ingredientSku.hashCode);
    _$hash = $jc(_$hash, menuItem.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, cost.hashCode);
    _$hash = $jc(_$hash, costMissing.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IngredientUsageRow')
          ..add('businessDate', businessDate)
          ..add('ingredient', ingredient)
          ..add('ingredientSku', ingredientSku)
          ..add('menuItem', menuItem)
          ..add('quantity', quantity)
          ..add('unit', unit)
          ..add('cost', cost)
          ..add('costMissing', costMissing))
        .toString();
  }
}

class IngredientUsageRowBuilder
    implements Builder<IngredientUsageRow, IngredientUsageRowBuilder> {
  _$IngredientUsageRow? _$v;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  String? _ingredient;
  String? get ingredient => _$this._ingredient;
  set ingredient(String? ingredient) => _$this._ingredient = ingredient;

  String? _ingredientSku;
  String? get ingredientSku => _$this._ingredientSku;
  set ingredientSku(String? ingredientSku) =>
      _$this._ingredientSku = ingredientSku;

  String? _menuItem;
  String? get menuItem => _$this._menuItem;
  set menuItem(String? menuItem) => _$this._menuItem = menuItem;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _cost;
  String? get cost => _$this._cost;
  set cost(String? cost) => _$this._cost = cost;

  bool? _costMissing;
  bool? get costMissing => _$this._costMissing;
  set costMissing(bool? costMissing) => _$this._costMissing = costMissing;

  IngredientUsageRowBuilder() {
    IngredientUsageRow._defaults(this);
  }

  IngredientUsageRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _businessDate = $v.businessDate;
      _ingredient = $v.ingredient;
      _ingredientSku = $v.ingredientSku;
      _menuItem = $v.menuItem;
      _quantity = $v.quantity;
      _unit = $v.unit;
      _cost = $v.cost;
      _costMissing = $v.costMissing;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientUsageRow other) {
    _$v = other as _$IngredientUsageRow;
  }

  @override
  void update(void Function(IngredientUsageRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientUsageRow build() => _build();

  _$IngredientUsageRow _build() {
    final _$result = _$v ??
        _$IngredientUsageRow._(
          businessDate: BuiltValueNullFieldError.checkNotNull(
              businessDate, r'IngredientUsageRow', 'businessDate'),
          ingredient: BuiltValueNullFieldError.checkNotNull(
              ingredient, r'IngredientUsageRow', 'ingredient'),
          ingredientSku: ingredientSku,
          menuItem: BuiltValueNullFieldError.checkNotNull(
              menuItem, r'IngredientUsageRow', 'menuItem'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'IngredientUsageRow', 'quantity'),
          unit: BuiltValueNullFieldError.checkNotNull(
              unit, r'IngredientUsageRow', 'unit'),
          cost: BuiltValueNullFieldError.checkNotNull(
              cost, r'IngredientUsageRow', 'cost'),
          costMissing: BuiltValueNullFieldError.checkNotNull(
              costMissing, r'IngredientUsageRow', 'costMissing'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
