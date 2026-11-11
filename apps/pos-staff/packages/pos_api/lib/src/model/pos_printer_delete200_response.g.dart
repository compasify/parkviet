// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_delete200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterDelete200Response extends PosPrinterDelete200Response {
  @override
  final PosPrinterDelete200ResponseData data;

  factory _$PosPrinterDelete200Response(
          [void Function(PosPrinterDelete200ResponseBuilder)? updates]) =>
      (PosPrinterDelete200ResponseBuilder()..update(updates))._build();

  _$PosPrinterDelete200Response._({required this.data}) : super._();
  @override
  PosPrinterDelete200Response rebuild(
          void Function(PosPrinterDelete200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterDelete200ResponseBuilder toBuilder() =>
      PosPrinterDelete200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterDelete200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrinterDelete200Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrinterDelete200ResponseBuilder
    implements
        Builder<PosPrinterDelete200Response,
            PosPrinterDelete200ResponseBuilder> {
  _$PosPrinterDelete200Response? _$v;

  PosPrinterDelete200ResponseDataBuilder? _data;
  PosPrinterDelete200ResponseDataBuilder get data =>
      _$this._data ??= PosPrinterDelete200ResponseDataBuilder();
  set data(PosPrinterDelete200ResponseDataBuilder? data) => _$this._data = data;

  PosPrinterDelete200ResponseBuilder() {
    PosPrinterDelete200Response._defaults(this);
  }

  PosPrinterDelete200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterDelete200Response other) {
    _$v = other as _$PosPrinterDelete200Response;
  }

  @override
  void update(void Function(PosPrinterDelete200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterDelete200Response build() => _build();

  _$PosPrinterDelete200Response _build() {
    _$PosPrinterDelete200Response _$result;
    try {
      _$result = _$v ??
          _$PosPrinterDelete200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinterDelete200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
