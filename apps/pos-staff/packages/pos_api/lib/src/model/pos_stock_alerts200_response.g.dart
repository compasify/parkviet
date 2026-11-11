// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_stock_alerts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosStockAlerts200Response extends PosStockAlerts200Response {
  @override
  final BuiltList<StockAlert> data;

  factory _$PosStockAlerts200Response(
          [void Function(PosStockAlerts200ResponseBuilder)? updates]) =>
      (PosStockAlerts200ResponseBuilder()..update(updates))._build();

  _$PosStockAlerts200Response._({required this.data}) : super._();
  @override
  PosStockAlerts200Response rebuild(
          void Function(PosStockAlerts200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosStockAlerts200ResponseBuilder toBuilder() =>
      PosStockAlerts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosStockAlerts200Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosStockAlerts200Response')
          ..add('data', data))
        .toString();
  }
}

class PosStockAlerts200ResponseBuilder
    implements
        Builder<PosStockAlerts200Response, PosStockAlerts200ResponseBuilder> {
  _$PosStockAlerts200Response? _$v;

  ListBuilder<StockAlert>? _data;
  ListBuilder<StockAlert> get data =>
      _$this._data ??= ListBuilder<StockAlert>();
  set data(ListBuilder<StockAlert>? data) => _$this._data = data;

  PosStockAlerts200ResponseBuilder() {
    PosStockAlerts200Response._defaults(this);
  }

  PosStockAlerts200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosStockAlerts200Response other) {
    _$v = other as _$PosStockAlerts200Response;
  }

  @override
  void update(void Function(PosStockAlerts200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosStockAlerts200Response build() => _build();

  _$PosStockAlerts200Response _build() {
    _$PosStockAlerts200Response _$result;
    try {
      _$result = _$v ??
          _$PosStockAlerts200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosStockAlerts200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
