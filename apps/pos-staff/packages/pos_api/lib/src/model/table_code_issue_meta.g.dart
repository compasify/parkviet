// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_code_issue_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableCodeIssueMeta extends TableCodeIssueMeta {
  @override
  final String? token;
  @override
  final String? url;
  @override
  final BuiltMap<String, JsonObject?>? printJob;

  factory _$TableCodeIssueMeta(
          [void Function(TableCodeIssueMetaBuilder)? updates]) =>
      (TableCodeIssueMetaBuilder()..update(updates))._build();

  _$TableCodeIssueMeta._({this.token, this.url, this.printJob}) : super._();
  @override
  TableCodeIssueMeta rebuild(
          void Function(TableCodeIssueMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableCodeIssueMetaBuilder toBuilder() =>
      TableCodeIssueMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableCodeIssueMeta &&
        token == other.token &&
        url == other.url &&
        printJob == other.printJob;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, printJob.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableCodeIssueMeta')
          ..add('token', token)
          ..add('url', url)
          ..add('printJob', printJob))
        .toString();
  }
}

class TableCodeIssueMetaBuilder
    implements Builder<TableCodeIssueMeta, TableCodeIssueMetaBuilder> {
  _$TableCodeIssueMeta? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  MapBuilder<String, JsonObject?>? _printJob;
  MapBuilder<String, JsonObject?> get printJob =>
      _$this._printJob ??= MapBuilder<String, JsonObject?>();
  set printJob(MapBuilder<String, JsonObject?>? printJob) =>
      _$this._printJob = printJob;

  TableCodeIssueMetaBuilder() {
    TableCodeIssueMeta._defaults(this);
  }

  TableCodeIssueMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _url = $v.url;
      _printJob = $v.printJob?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableCodeIssueMeta other) {
    _$v = other as _$TableCodeIssueMeta;
  }

  @override
  void update(void Function(TableCodeIssueMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableCodeIssueMeta build() => _build();

  _$TableCodeIssueMeta _build() {
    _$TableCodeIssueMeta _$result;
    try {
      _$result = _$v ??
          _$TableCodeIssueMeta._(
            token: token,
            url: url,
            printJob: _printJob?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'printJob';
        _printJob?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableCodeIssueMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
