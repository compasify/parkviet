// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_page_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspacePageMeta extends WorkspacePageMeta {
  @override
  final int? page;
  @override
  final int? limit;
  @override
  final int? count;
  @override
  final int? pages;

  factory _$WorkspacePageMeta(
          [void Function(WorkspacePageMetaBuilder)? updates]) =>
      (WorkspacePageMetaBuilder()..update(updates))._build();

  _$WorkspacePageMeta._({this.page, this.limit, this.count, this.pages})
      : super._();
  @override
  WorkspacePageMeta rebuild(void Function(WorkspacePageMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspacePageMetaBuilder toBuilder() =>
      WorkspacePageMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspacePageMeta &&
        page == other.page &&
        limit == other.limit &&
        count == other.count &&
        pages == other.pages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, pages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspacePageMeta')
          ..add('page', page)
          ..add('limit', limit)
          ..add('count', count)
          ..add('pages', pages))
        .toString();
  }
}

class WorkspacePageMetaBuilder
    implements Builder<WorkspacePageMeta, WorkspacePageMetaBuilder> {
  _$WorkspacePageMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  int? _pages;
  int? get pages => _$this._pages;
  set pages(int? pages) => _$this._pages = pages;

  WorkspacePageMetaBuilder() {
    WorkspacePageMeta._defaults(this);
  }

  WorkspacePageMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _page = $v.page;
      _limit = $v.limit;
      _count = $v.count;
      _pages = $v.pages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspacePageMeta other) {
    _$v = other as _$WorkspacePageMeta;
  }

  @override
  void update(void Function(WorkspacePageMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspacePageMeta build() => _build();

  _$WorkspacePageMeta _build() {
    final _$result = _$v ??
        _$WorkspacePageMeta._(
          page: page,
          limit: limit,
          count: count,
          pages: pages,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
