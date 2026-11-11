// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_settings200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceSettings200Response extends PosEinvoiceSettings200Response {
  @override
  final EinvoiceSettings data;

  factory _$PosEinvoiceSettings200Response(
          [void Function(PosEinvoiceSettings200ResponseBuilder)? updates]) =>
      (PosEinvoiceSettings200ResponseBuilder()..update(updates))._build();

  _$PosEinvoiceSettings200Response._({required this.data}) : super._();
  @override
  PosEinvoiceSettings200Response rebuild(
          void Function(PosEinvoiceSettings200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceSettings200ResponseBuilder toBuilder() =>
      PosEinvoiceSettings200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceSettings200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosEinvoiceSettings200Response')
          ..add('data', data))
        .toString();
  }
}

class PosEinvoiceSettings200ResponseBuilder
    implements
        Builder<PosEinvoiceSettings200Response,
            PosEinvoiceSettings200ResponseBuilder> {
  _$PosEinvoiceSettings200Response? _$v;

  EinvoiceSettingsBuilder? _data;
  EinvoiceSettingsBuilder get data =>
      _$this._data ??= EinvoiceSettingsBuilder();
  set data(EinvoiceSettingsBuilder? data) => _$this._data = data;

  PosEinvoiceSettings200ResponseBuilder() {
    PosEinvoiceSettings200Response._defaults(this);
  }

  PosEinvoiceSettings200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceSettings200Response other) {
    _$v = other as _$PosEinvoiceSettings200Response;
  }

  @override
  void update(void Function(PosEinvoiceSettings200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceSettings200Response build() => _build();

  _$PosEinvoiceSettings200Response _build() {
    _$PosEinvoiceSettings200Response _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceSettings200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceSettings200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
