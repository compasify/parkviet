// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_orders200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKitchenOrders200Response extends PosKitchenOrders200Response {
  @override
  final CallBoard data;

  factory _$PosKitchenOrders200Response(
          [void Function(PosKitchenOrders200ResponseBuilder)? updates]) =>
      (PosKitchenOrders200ResponseBuilder()..update(updates))._build();

  _$PosKitchenOrders200Response._({required this.data}) : super._();
  @override
  PosKitchenOrders200Response rebuild(
          void Function(PosKitchenOrders200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenOrders200ResponseBuilder toBuilder() =>
      PosKitchenOrders200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenOrders200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKitchenOrders200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKitchenOrders200ResponseBuilder
    implements
        Builder<PosKitchenOrders200Response,
            PosKitchenOrders200ResponseBuilder> {
  _$PosKitchenOrders200Response? _$v;

  CallBoardBuilder? _data;
  CallBoardBuilder get data => _$this._data ??= CallBoardBuilder();
  set data(CallBoardBuilder? data) => _$this._data = data;

  PosKitchenOrders200ResponseBuilder() {
    PosKitchenOrders200Response._defaults(this);
  }

  PosKitchenOrders200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKitchenOrders200Response other) {
    _$v = other as _$PosKitchenOrders200Response;
  }

  @override
  void update(void Function(PosKitchenOrders200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenOrders200Response build() => _build();

  _$PosKitchenOrders200Response _build() {
    _$PosKitchenOrders200Response _$result;
    try {
      _$result = _$v ??
          _$PosKitchenOrders200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKitchenOrders200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
