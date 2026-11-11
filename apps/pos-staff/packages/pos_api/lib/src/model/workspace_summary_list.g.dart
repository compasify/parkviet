// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_summary_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceSummaryList extends WorkspaceSummaryList {
  @override
  final BuiltList<WorkspaceSummary> data;
  @override
  final WorkspacePageMeta? meta;

  factory _$WorkspaceSummaryList(
          [void Function(WorkspaceSummaryListBuilder)? updates]) =>
      (WorkspaceSummaryListBuilder()..update(updates))._build();

  _$WorkspaceSummaryList._({required this.data, this.meta}) : super._();
  @override
  WorkspaceSummaryList rebuild(
          void Function(WorkspaceSummaryListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceSummaryListBuilder toBuilder() =>
      WorkspaceSummaryListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceSummaryList &&
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
    return (newBuiltValueToStringHelper(r'WorkspaceSummaryList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class WorkspaceSummaryListBuilder
    implements Builder<WorkspaceSummaryList, WorkspaceSummaryListBuilder> {
  _$WorkspaceSummaryList? _$v;

  ListBuilder<WorkspaceSummary>? _data;
  ListBuilder<WorkspaceSummary> get data =>
      _$this._data ??= ListBuilder<WorkspaceSummary>();
  set data(ListBuilder<WorkspaceSummary>? data) => _$this._data = data;

  WorkspacePageMetaBuilder? _meta;
  WorkspacePageMetaBuilder get meta =>
      _$this._meta ??= WorkspacePageMetaBuilder();
  set meta(WorkspacePageMetaBuilder? meta) => _$this._meta = meta;

  WorkspaceSummaryListBuilder() {
    WorkspaceSummaryList._defaults(this);
  }

  WorkspaceSummaryListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceSummaryList other) {
    _$v = other as _$WorkspaceSummaryList;
  }

  @override
  void update(void Function(WorkspaceSummaryListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceSummaryList build() => _build();

  _$WorkspaceSummaryList _build() {
    _$WorkspaceSummaryList _$result;
    try {
      _$result = _$v ??
          _$WorkspaceSummaryList._(
            data: data.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceSummaryList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
