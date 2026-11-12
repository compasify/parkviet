// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_code_issue_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableCodeIssueResult extends TableCodeIssueResult {
  @override
  final TableCode data;
  @override
  final TableCodeIssueMeta meta;

  factory _$TableCodeIssueResult(
          [void Function(TableCodeIssueResultBuilder)? updates]) =>
      (TableCodeIssueResultBuilder()..update(updates))._build();

  _$TableCodeIssueResult._({required this.data, required this.meta})
      : super._();
  @override
  TableCodeIssueResult rebuild(
          void Function(TableCodeIssueResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableCodeIssueResultBuilder toBuilder() =>
      TableCodeIssueResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableCodeIssueResult &&
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
    return (newBuiltValueToStringHelper(r'TableCodeIssueResult')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class TableCodeIssueResultBuilder
    implements Builder<TableCodeIssueResult, TableCodeIssueResultBuilder> {
  _$TableCodeIssueResult? _$v;

  TableCodeBuilder? _data;
  TableCodeBuilder get data => _$this._data ??= TableCodeBuilder();
  set data(TableCodeBuilder? data) => _$this._data = data;

  TableCodeIssueMetaBuilder? _meta;
  TableCodeIssueMetaBuilder get meta =>
      _$this._meta ??= TableCodeIssueMetaBuilder();
  set meta(TableCodeIssueMetaBuilder? meta) => _$this._meta = meta;

  TableCodeIssueResultBuilder() {
    TableCodeIssueResult._defaults(this);
  }

  TableCodeIssueResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableCodeIssueResult other) {
    _$v = other as _$TableCodeIssueResult;
  }

  @override
  void update(void Function(TableCodeIssueResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableCodeIssueResult build() => _build();

  _$TableCodeIssueResult _build() {
    _$TableCodeIssueResult _$result;
    try {
      _$result = _$v ??
          _$TableCodeIssueResult._(
            data: data.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableCodeIssueResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
