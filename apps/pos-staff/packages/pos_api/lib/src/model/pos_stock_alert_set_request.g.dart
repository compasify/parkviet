// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_stock_alert_set_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosStockAlertSetRequest extends PosStockAlertSetRequest {
  @override
  final String branchId;
  @override
  final String variantId;
  @override
  final int? minQuantity;

  factory _$PosStockAlertSetRequest(
          [void Function(PosStockAlertSetRequestBuilder)? updates]) =>
      (PosStockAlertSetRequestBuilder()..update(updates))._build();

  _$PosStockAlertSetRequest._(
      {required this.branchId, required this.variantId, this.minQuantity})
      : super._();
  @override
  PosStockAlertSetRequest rebuild(
          void Function(PosStockAlertSetRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosStockAlertSetRequestBuilder toBuilder() =>
      PosStockAlertSetRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosStockAlertSetRequest &&
        branchId == other.branchId &&
        variantId == other.variantId &&
        minQuantity == other.minQuantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, minQuantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosStockAlertSetRequest')
          ..add('branchId', branchId)
          ..add('variantId', variantId)
          ..add('minQuantity', minQuantity))
        .toString();
  }
}

class PosStockAlertSetRequestBuilder
    implements
        Builder<PosStockAlertSetRequest, PosStockAlertSetRequestBuilder> {
  _$PosStockAlertSetRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  int? _minQuantity;
  int? get minQuantity => _$this._minQuantity;
  set minQuantity(int? minQuantity) => _$this._minQuantity = minQuantity;

  PosStockAlertSetRequestBuilder() {
    PosStockAlertSetRequest._defaults(this);
  }

  PosStockAlertSetRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _variantId = $v.variantId;
      _minQuantity = $v.minQuantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosStockAlertSetRequest other) {
    _$v = other as _$PosStockAlertSetRequest;
  }

  @override
  void update(void Function(PosStockAlertSetRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosStockAlertSetRequest build() => _build();

  _$PosStockAlertSetRequest _build() {
    final _$result = _$v ??
        _$PosStockAlertSetRequest._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'PosStockAlertSetRequest', 'branchId'),
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'PosStockAlertSetRequest', 'variantId'),
          minQuantity: minQuantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
