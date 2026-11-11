// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'append_items_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppendItemsResult extends AppendItemsResult {
  @override
  final Workspace data;
  @override
  final AppendItemsMeta meta;

  factory _$AppendItemsResult(
          [void Function(AppendItemsResultBuilder)? updates]) =>
      (AppendItemsResultBuilder()..update(updates))._build();

  _$AppendItemsResult._({required this.data, required this.meta}) : super._();
  @override
  AppendItemsResult rebuild(void Function(AppendItemsResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppendItemsResultBuilder toBuilder() =>
      AppendItemsResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppendItemsResult &&
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
    return (newBuiltValueToStringHelper(r'AppendItemsResult')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class AppendItemsResultBuilder
    implements Builder<AppendItemsResult, AppendItemsResultBuilder> {
  _$AppendItemsResult? _$v;

  WorkspaceBuilder? _data;
  WorkspaceBuilder get data => _$this._data ??= WorkspaceBuilder();
  set data(WorkspaceBuilder? data) => _$this._data = data;

  AppendItemsMetaBuilder? _meta;
  AppendItemsMetaBuilder get meta => _$this._meta ??= AppendItemsMetaBuilder();
  set meta(AppendItemsMetaBuilder? meta) => _$this._meta = meta;

  AppendItemsResultBuilder() {
    AppendItemsResult._defaults(this);
  }

  AppendItemsResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppendItemsResult other) {
    _$v = other as _$AppendItemsResult;
  }

  @override
  void update(void Function(AppendItemsResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppendItemsResult build() => _build();

  _$AppendItemsResult _build() {
    _$AppendItemsResult _$result;
    try {
      _$result = _$v ??
          _$AppendItemsResult._(
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
            r'AppendItemsResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
