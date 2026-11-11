// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_stations200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterStations200Response extends PosPrinterStations200Response {
  @override
  final BuiltList<PosPrinterStations200ResponseDataInner> data;

  factory _$PosPrinterStations200Response(
          [void Function(PosPrinterStations200ResponseBuilder)? updates]) =>
      (PosPrinterStations200ResponseBuilder()..update(updates))._build();

  _$PosPrinterStations200Response._({required this.data}) : super._();
  @override
  PosPrinterStations200Response rebuild(
          void Function(PosPrinterStations200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterStations200ResponseBuilder toBuilder() =>
      PosPrinterStations200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterStations200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrinterStations200Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrinterStations200ResponseBuilder
    implements
        Builder<PosPrinterStations200Response,
            PosPrinterStations200ResponseBuilder> {
  _$PosPrinterStations200Response? _$v;

  ListBuilder<PosPrinterStations200ResponseDataInner>? _data;
  ListBuilder<PosPrinterStations200ResponseDataInner> get data =>
      _$this._data ??= ListBuilder<PosPrinterStations200ResponseDataInner>();
  set data(ListBuilder<PosPrinterStations200ResponseDataInner>? data) =>
      _$this._data = data;

  PosPrinterStations200ResponseBuilder() {
    PosPrinterStations200Response._defaults(this);
  }

  PosPrinterStations200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterStations200Response other) {
    _$v = other as _$PosPrinterStations200Response;
  }

  @override
  void update(void Function(PosPrinterStations200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterStations200Response build() => _build();

  _$PosPrinterStations200Response _build() {
    _$PosPrinterStations200Response _$result;
    try {
      _$result = _$v ??
          _$PosPrinterStations200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinterStations200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
