// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoice200Response extends PosEinvoice200Response {
  @override
  final Einvoice data;

  factory _$PosEinvoice200Response(
          [void Function(PosEinvoice200ResponseBuilder)? updates]) =>
      (PosEinvoice200ResponseBuilder()..update(updates))._build();

  _$PosEinvoice200Response._({required this.data}) : super._();
  @override
  PosEinvoice200Response rebuild(
          void Function(PosEinvoice200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoice200ResponseBuilder toBuilder() =>
      PosEinvoice200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoice200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosEinvoice200Response')
          ..add('data', data))
        .toString();
  }
}

class PosEinvoice200ResponseBuilder
    implements Builder<PosEinvoice200Response, PosEinvoice200ResponseBuilder> {
  _$PosEinvoice200Response? _$v;

  EinvoiceBuilder? _data;
  EinvoiceBuilder get data => _$this._data ??= EinvoiceBuilder();
  set data(EinvoiceBuilder? data) => _$this._data = data;

  PosEinvoice200ResponseBuilder() {
    PosEinvoice200Response._defaults(this);
  }

  PosEinvoice200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoice200Response other) {
    _$v = other as _$PosEinvoice200Response;
  }

  @override
  void update(void Function(PosEinvoice200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoice200Response build() => _build();

  _$PosEinvoice200Response _build() {
    _$PosEinvoice200Response _$result;
    try {
      _$result = _$v ??
          _$PosEinvoice200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoice200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
