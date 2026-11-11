// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printers200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinters200Response extends PosPrinters200Response {
  @override
  final BuiltList<Printer> data;

  factory _$PosPrinters200Response(
          [void Function(PosPrinters200ResponseBuilder)? updates]) =>
      (PosPrinters200ResponseBuilder()..update(updates))._build();

  _$PosPrinters200Response._({required this.data}) : super._();
  @override
  PosPrinters200Response rebuild(
          void Function(PosPrinters200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinters200ResponseBuilder toBuilder() =>
      PosPrinters200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinters200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrinters200Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrinters200ResponseBuilder
    implements Builder<PosPrinters200Response, PosPrinters200ResponseBuilder> {
  _$PosPrinters200Response? _$v;

  ListBuilder<Printer>? _data;
  ListBuilder<Printer> get data => _$this._data ??= ListBuilder<Printer>();
  set data(ListBuilder<Printer>? data) => _$this._data = data;

  PosPrinters200ResponseBuilder() {
    PosPrinters200Response._defaults(this);
  }

  PosPrinters200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinters200Response other) {
    _$v = other as _$PosPrinters200Response;
  }

  @override
  void update(void Function(PosPrinters200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinters200Response build() => _build();

  _$PosPrinters200Response _build() {
    _$PosPrinters200Response _$result;
    try {
      _$result = _$v ??
          _$PosPrinters200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinters200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
