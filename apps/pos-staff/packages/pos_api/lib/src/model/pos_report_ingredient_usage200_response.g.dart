// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_report_ingredient_usage200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosReportIngredientUsage200Response
    extends PosReportIngredientUsage200Response {
  @override
  final BuiltList<IngredientUsageRow> data;
  @override
  final JsonObject meta;

  factory _$PosReportIngredientUsage200Response(
          [void Function(PosReportIngredientUsage200ResponseBuilder)?
              updates]) =>
      (PosReportIngredientUsage200ResponseBuilder()..update(updates))._build();

  _$PosReportIngredientUsage200Response._(
      {required this.data, required this.meta})
      : super._();
  @override
  PosReportIngredientUsage200Response rebuild(
          void Function(PosReportIngredientUsage200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosReportIngredientUsage200ResponseBuilder toBuilder() =>
      PosReportIngredientUsage200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosReportIngredientUsage200Response &&
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
    return (newBuiltValueToStringHelper(r'PosReportIngredientUsage200Response')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class PosReportIngredientUsage200ResponseBuilder
    implements
        Builder<PosReportIngredientUsage200Response,
            PosReportIngredientUsage200ResponseBuilder> {
  _$PosReportIngredientUsage200Response? _$v;

  ListBuilder<IngredientUsageRow>? _data;
  ListBuilder<IngredientUsageRow> get data =>
      _$this._data ??= ListBuilder<IngredientUsageRow>();
  set data(ListBuilder<IngredientUsageRow>? data) => _$this._data = data;

  JsonObject? _meta;
  JsonObject? get meta => _$this._meta;
  set meta(JsonObject? meta) => _$this._meta = meta;

  PosReportIngredientUsage200ResponseBuilder() {
    PosReportIngredientUsage200Response._defaults(this);
  }

  PosReportIngredientUsage200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosReportIngredientUsage200Response other) {
    _$v = other as _$PosReportIngredientUsage200Response;
  }

  @override
  void update(
      void Function(PosReportIngredientUsage200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosReportIngredientUsage200Response build() => _build();

  _$PosReportIngredientUsage200Response _build() {
    _$PosReportIngredientUsage200Response _$result;
    try {
      _$result = _$v ??
          _$PosReportIngredientUsage200Response._(
            data: data.build(),
            meta: BuiltValueNullFieldError.checkNotNull(
                meta, r'PosReportIngredientUsage200Response', 'meta'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'PosReportIngredientUsage200Response',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
