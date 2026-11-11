// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_sample200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceSample200Response extends PosEinvoiceSample200Response {
  @override
  final EinvoiceSample data;

  factory _$PosEinvoiceSample200Response(
          [void Function(PosEinvoiceSample200ResponseBuilder)? updates]) =>
      (PosEinvoiceSample200ResponseBuilder()..update(updates))._build();

  _$PosEinvoiceSample200Response._({required this.data}) : super._();
  @override
  PosEinvoiceSample200Response rebuild(
          void Function(PosEinvoiceSample200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceSample200ResponseBuilder toBuilder() =>
      PosEinvoiceSample200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceSample200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosEinvoiceSample200Response')
          ..add('data', data))
        .toString();
  }
}

class PosEinvoiceSample200ResponseBuilder
    implements
        Builder<PosEinvoiceSample200Response,
            PosEinvoiceSample200ResponseBuilder> {
  _$PosEinvoiceSample200Response? _$v;

  EinvoiceSampleBuilder? _data;
  EinvoiceSampleBuilder get data => _$this._data ??= EinvoiceSampleBuilder();
  set data(EinvoiceSampleBuilder? data) => _$this._data = data;

  PosEinvoiceSample200ResponseBuilder() {
    PosEinvoiceSample200Response._defaults(this);
  }

  PosEinvoiceSample200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceSample200Response other) {
    _$v = other as _$PosEinvoiceSample200Response;
  }

  @override
  void update(void Function(PosEinvoiceSample200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceSample200Response build() => _build();

  _$PosEinvoiceSample200Response _build() {
    _$PosEinvoiceSample200Response _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceSample200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceSample200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
