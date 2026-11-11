// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_report_menu_margin200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosReportMenuMargin200Response extends PosReportMenuMargin200Response {
  @override
  final BuiltList<MenuMarginRow> data;
  @override
  final JsonObject meta;

  factory _$PosReportMenuMargin200Response(
          [void Function(PosReportMenuMargin200ResponseBuilder)? updates]) =>
      (PosReportMenuMargin200ResponseBuilder()..update(updates))._build();

  _$PosReportMenuMargin200Response._({required this.data, required this.meta})
      : super._();
  @override
  PosReportMenuMargin200Response rebuild(
          void Function(PosReportMenuMargin200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosReportMenuMargin200ResponseBuilder toBuilder() =>
      PosReportMenuMargin200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosReportMenuMargin200Response &&
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
    return (newBuiltValueToStringHelper(r'PosReportMenuMargin200Response')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class PosReportMenuMargin200ResponseBuilder
    implements
        Builder<PosReportMenuMargin200Response,
            PosReportMenuMargin200ResponseBuilder> {
  _$PosReportMenuMargin200Response? _$v;

  ListBuilder<MenuMarginRow>? _data;
  ListBuilder<MenuMarginRow> get data =>
      _$this._data ??= ListBuilder<MenuMarginRow>();
  set data(ListBuilder<MenuMarginRow>? data) => _$this._data = data;

  JsonObject? _meta;
  JsonObject? get meta => _$this._meta;
  set meta(JsonObject? meta) => _$this._meta = meta;

  PosReportMenuMargin200ResponseBuilder() {
    PosReportMenuMargin200Response._defaults(this);
  }

  PosReportMenuMargin200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosReportMenuMargin200Response other) {
    _$v = other as _$PosReportMenuMargin200Response;
  }

  @override
  void update(void Function(PosReportMenuMargin200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosReportMenuMargin200Response build() => _build();

  _$PosReportMenuMargin200Response _build() {
    _$PosReportMenuMargin200Response _$result;
    try {
      _$result = _$v ??
          _$PosReportMenuMargin200Response._(
            data: data.build(),
            meta: BuiltValueNullFieldError.checkNotNull(
                meta, r'PosReportMenuMargin200Response', 'meta'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosReportMenuMargin200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
