// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_summary200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceSummary200Response extends PosEinvoiceSummary200Response {
  @override
  final EinvoiceSummary data;

  factory _$PosEinvoiceSummary200Response(
          [void Function(PosEinvoiceSummary200ResponseBuilder)? updates]) =>
      (PosEinvoiceSummary200ResponseBuilder()..update(updates))._build();

  _$PosEinvoiceSummary200Response._({required this.data}) : super._();
  @override
  PosEinvoiceSummary200Response rebuild(
          void Function(PosEinvoiceSummary200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceSummary200ResponseBuilder toBuilder() =>
      PosEinvoiceSummary200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceSummary200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosEinvoiceSummary200Response')
          ..add('data', data))
        .toString();
  }
}

class PosEinvoiceSummary200ResponseBuilder
    implements
        Builder<PosEinvoiceSummary200Response,
            PosEinvoiceSummary200ResponseBuilder> {
  _$PosEinvoiceSummary200Response? _$v;

  EinvoiceSummaryBuilder? _data;
  EinvoiceSummaryBuilder get data => _$this._data ??= EinvoiceSummaryBuilder();
  set data(EinvoiceSummaryBuilder? data) => _$this._data = data;

  PosEinvoiceSummary200ResponseBuilder() {
    PosEinvoiceSummary200Response._defaults(this);
  }

  PosEinvoiceSummary200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceSummary200Response other) {
    _$v = other as _$PosEinvoiceSummary200Response;
  }

  @override
  void update(void Function(PosEinvoiceSummary200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceSummary200Response build() => _build();

  _$PosEinvoiceSummary200Response _build() {
    _$PosEinvoiceSummary200Response _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceSummary200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceSummary200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
