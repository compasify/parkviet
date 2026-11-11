// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_test200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterTest200Response extends PosPrinterTest200Response {
  @override
  final PosPrinterTest200ResponseData data;

  factory _$PosPrinterTest200Response(
          [void Function(PosPrinterTest200ResponseBuilder)? updates]) =>
      (PosPrinterTest200ResponseBuilder()..update(updates))._build();

  _$PosPrinterTest200Response._({required this.data}) : super._();
  @override
  PosPrinterTest200Response rebuild(
          void Function(PosPrinterTest200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterTest200ResponseBuilder toBuilder() =>
      PosPrinterTest200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterTest200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrinterTest200Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrinterTest200ResponseBuilder
    implements
        Builder<PosPrinterTest200Response, PosPrinterTest200ResponseBuilder> {
  _$PosPrinterTest200Response? _$v;

  PosPrinterTest200ResponseDataBuilder? _data;
  PosPrinterTest200ResponseDataBuilder get data =>
      _$this._data ??= PosPrinterTest200ResponseDataBuilder();
  set data(PosPrinterTest200ResponseDataBuilder? data) => _$this._data = data;

  PosPrinterTest200ResponseBuilder() {
    PosPrinterTest200Response._defaults(this);
  }

  PosPrinterTest200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterTest200Response other) {
    _$v = other as _$PosPrinterTest200Response;
  }

  @override
  void update(void Function(PosPrinterTest200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterTest200Response build() => _build();

  _$PosPrinterTest200Response _build() {
    _$PosPrinterTest200Response _$result;
    try {
      _$result = _$v ??
          _$PosPrinterTest200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinterTest200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
