// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_alert.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StockAlert extends StockAlert {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String variantId;
  @override
  final String? name;
  @override
  final String? sku;
  @override
  final String? optionsText;
  @override
  final String baseUnit;
  @override
  final int minQuantity;
  @override
  final int onHand;
  @override
  final bool low;

  factory _$StockAlert([void Function(StockAlertBuilder)? updates]) =>
      (StockAlertBuilder()..update(updates))._build();

  _$StockAlert._(
      {required this.id,
      required this.branchId,
      required this.variantId,
      this.name,
      this.sku,
      this.optionsText,
      required this.baseUnit,
      required this.minQuantity,
      required this.onHand,
      required this.low})
      : super._();
  @override
  StockAlert rebuild(void Function(StockAlertBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StockAlertBuilder toBuilder() => StockAlertBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StockAlert &&
        id == other.id &&
        branchId == other.branchId &&
        variantId == other.variantId &&
        name == other.name &&
        sku == other.sku &&
        optionsText == other.optionsText &&
        baseUnit == other.baseUnit &&
        minQuantity == other.minQuantity &&
        onHand == other.onHand &&
        low == other.low;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sku.hashCode);
    _$hash = $jc(_$hash, optionsText.hashCode);
    _$hash = $jc(_$hash, baseUnit.hashCode);
    _$hash = $jc(_$hash, minQuantity.hashCode);
    _$hash = $jc(_$hash, onHand.hashCode);
    _$hash = $jc(_$hash, low.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StockAlert')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('sku', sku)
          ..add('optionsText', optionsText)
          ..add('baseUnit', baseUnit)
          ..add('minQuantity', minQuantity)
          ..add('onHand', onHand)
          ..add('low', low))
        .toString();
  }
}

class StockAlertBuilder implements Builder<StockAlert, StockAlertBuilder> {
  _$StockAlert? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

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

  String? _baseUnit;
  String? get baseUnit => _$this._baseUnit;
  set baseUnit(String? baseUnit) => _$this._baseUnit = baseUnit;

  int? _minQuantity;
  int? get minQuantity => _$this._minQuantity;
  set minQuantity(int? minQuantity) => _$this._minQuantity = minQuantity;

  int? _onHand;
  int? get onHand => _$this._onHand;
  set onHand(int? onHand) => _$this._onHand = onHand;

  bool? _low;
  bool? get low => _$this._low;
  set low(bool? low) => _$this._low = low;

  StockAlertBuilder() {
    StockAlert._defaults(this);
  }

  StockAlertBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _variantId = $v.variantId;
      _name = $v.name;
      _sku = $v.sku;
      _optionsText = $v.optionsText;
      _baseUnit = $v.baseUnit;
      _minQuantity = $v.minQuantity;
      _onHand = $v.onHand;
      _low = $v.low;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StockAlert other) {
    _$v = other as _$StockAlert;
  }

  @override
  void update(void Function(StockAlertBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StockAlert build() => _build();

  _$StockAlert _build() {
    final _$result = _$v ??
        _$StockAlert._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'StockAlert', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'StockAlert', 'branchId'),
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'StockAlert', 'variantId'),
          name: name,
          sku: sku,
          optionsText: optionsText,
          baseUnit: BuiltValueNullFieldError.checkNotNull(
              baseUnit, r'StockAlert', 'baseUnit'),
          minQuantity: BuiltValueNullFieldError.checkNotNull(
              minQuantity, r'StockAlert', 'minQuantity'),
          onHand: BuiltValueNullFieldError.checkNotNull(
              onHand, r'StockAlert', 'onHand'),
          low: BuiltValueNullFieldError.checkNotNull(low, r'StockAlert', 'low'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
