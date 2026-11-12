// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kiosk_orders200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKioskOrders200Response extends PosKioskOrders200Response {
  @override
  final BuiltList<KioskHandoffOrder> data;

  factory _$PosKioskOrders200Response(
          [void Function(PosKioskOrders200ResponseBuilder)? updates]) =>
      (PosKioskOrders200ResponseBuilder()..update(updates))._build();

  _$PosKioskOrders200Response._({required this.data}) : super._();
  @override
  PosKioskOrders200Response rebuild(
          void Function(PosKioskOrders200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKioskOrders200ResponseBuilder toBuilder() =>
      PosKioskOrders200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKioskOrders200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKioskOrders200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKioskOrders200ResponseBuilder
    implements
        Builder<PosKioskOrders200Response, PosKioskOrders200ResponseBuilder> {
  _$PosKioskOrders200Response? _$v;

  ListBuilder<KioskHandoffOrder>? _data;
  ListBuilder<KioskHandoffOrder> get data =>
      _$this._data ??= ListBuilder<KioskHandoffOrder>();
  set data(ListBuilder<KioskHandoffOrder>? data) => _$this._data = data;

  PosKioskOrders200ResponseBuilder() {
    PosKioskOrders200Response._defaults(this);
  }

  PosKioskOrders200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKioskOrders200Response other) {
    _$v = other as _$PosKioskOrders200Response;
  }

  @override
  void update(void Function(PosKioskOrders200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKioskOrders200Response build() => _build();

  _$PosKioskOrders200Response _build() {
    _$PosKioskOrders200Response _$result;
    try {
      _$result = _$v ??
          _$PosKioskOrders200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKioskOrders200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
