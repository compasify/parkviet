// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_report_rows.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformReportRows extends PlatformReportRows {
  @override
  final BuiltList<PlatformReportRow> data;
  @override
  final JsonObject meta;

  factory _$PlatformReportRows(
          [void Function(PlatformReportRowsBuilder)? updates]) =>
      (PlatformReportRowsBuilder()..update(updates))._build();

  _$PlatformReportRows._({required this.data, required this.meta}) : super._();
  @override
  PlatformReportRows rebuild(
          void Function(PlatformReportRowsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformReportRowsBuilder toBuilder() =>
      PlatformReportRowsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformReportRows &&
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
    return (newBuiltValueToStringHelper(r'PlatformReportRows')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class PlatformReportRowsBuilder
    implements Builder<PlatformReportRows, PlatformReportRowsBuilder> {
  _$PlatformReportRows? _$v;

  ListBuilder<PlatformReportRow>? _data;
  ListBuilder<PlatformReportRow> get data =>
      _$this._data ??= ListBuilder<PlatformReportRow>();
  set data(ListBuilder<PlatformReportRow>? data) => _$this._data = data;

  JsonObject? _meta;
  JsonObject? get meta => _$this._meta;
  set meta(JsonObject? meta) => _$this._meta = meta;

  PlatformReportRowsBuilder() {
    PlatformReportRows._defaults(this);
  }

  PlatformReportRowsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformReportRows other) {
    _$v = other as _$PlatformReportRows;
  }

  @override
  void update(void Function(PlatformReportRowsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformReportRows build() => _build();

  _$PlatformReportRows _build() {
    _$PlatformReportRows _$result;
    try {
      _$result = _$v ??
          _$PlatformReportRows._(
            data: data.build(),
            meta: BuiltValueNullFieldError.checkNotNull(
                meta, r'PlatformReportRows', 'meta'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformReportRows', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
