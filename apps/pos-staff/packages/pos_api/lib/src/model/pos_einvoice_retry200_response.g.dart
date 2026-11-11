// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_retry200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceRetry200Response extends PosEinvoiceRetry200Response {
  @override
  final PosEinvoiceRetry200ResponseData data;

  factory _$PosEinvoiceRetry200Response(
          [void Function(PosEinvoiceRetry200ResponseBuilder)? updates]) =>
      (PosEinvoiceRetry200ResponseBuilder()..update(updates))._build();

  _$PosEinvoiceRetry200Response._({required this.data}) : super._();
  @override
  PosEinvoiceRetry200Response rebuild(
          void Function(PosEinvoiceRetry200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceRetry200ResponseBuilder toBuilder() =>
      PosEinvoiceRetry200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceRetry200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosEinvoiceRetry200Response')
          ..add('data', data))
        .toString();
  }
}

class PosEinvoiceRetry200ResponseBuilder
    implements
        Builder<PosEinvoiceRetry200Response,
            PosEinvoiceRetry200ResponseBuilder> {
  _$PosEinvoiceRetry200Response? _$v;

  PosEinvoiceRetry200ResponseDataBuilder? _data;
  PosEinvoiceRetry200ResponseDataBuilder get data =>
      _$this._data ??= PosEinvoiceRetry200ResponseDataBuilder();
  set data(PosEinvoiceRetry200ResponseDataBuilder? data) => _$this._data = data;

  PosEinvoiceRetry200ResponseBuilder() {
    PosEinvoiceRetry200Response._defaults(this);
  }

  PosEinvoiceRetry200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceRetry200Response other) {
    _$v = other as _$PosEinvoiceRetry200Response;
  }

  @override
  void update(void Function(PosEinvoiceRetry200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceRetry200Response build() => _build();

  _$PosEinvoiceRetry200Response _build() {
    _$PosEinvoiceRetry200Response _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceRetry200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceRetry200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
