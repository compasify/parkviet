// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoices200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoices200Response extends PosEinvoices200Response {
  @override
  final BuiltList<Einvoice> data;
  @override
  final JsonObject meta;

  factory _$PosEinvoices200Response(
          [void Function(PosEinvoices200ResponseBuilder)? updates]) =>
      (PosEinvoices200ResponseBuilder()..update(updates))._build();

  _$PosEinvoices200Response._({required this.data, required this.meta})
      : super._();
  @override
  PosEinvoices200Response rebuild(
          void Function(PosEinvoices200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoices200ResponseBuilder toBuilder() =>
      PosEinvoices200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoices200Response &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoices200Response')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class PosEinvoices200ResponseBuilder
    implements
        Builder<PosEinvoices200Response, PosEinvoices200ResponseBuilder> {
  _$PosEinvoices200Response? _$v;

  ListBuilder<Einvoice>? _data;
  ListBuilder<Einvoice> get data => _$this._data ??= ListBuilder<Einvoice>();
  set data(ListBuilder<Einvoice>? data) => _$this._data = data;

  JsonObject? _meta;
  JsonObject? get meta => _$this._meta;
  set meta(JsonObject? meta) => _$this._meta = meta;

  PosEinvoices200ResponseBuilder() {
    PosEinvoices200Response._defaults(this);
  }

  PosEinvoices200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoices200Response other) {
    _$v = other as _$PosEinvoices200Response;
  }

  @override
  void update(void Function(PosEinvoices200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoices200Response build() => _build();

  _$PosEinvoices200Response _build() {
    _$PosEinvoices200Response _$result;
    try {
      _$result = _$v ??
          _$PosEinvoices200Response._(
            data: data.build(),
            meta: BuiltValueNullFieldError.checkNotNull(
                meta, r'PosEinvoices200Response', 'meta'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoices200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
