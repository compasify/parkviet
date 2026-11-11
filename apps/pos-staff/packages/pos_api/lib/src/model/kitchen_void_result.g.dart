// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_void_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenVoidResult extends KitchenVoidResult {
  @override
  final Workspace data;
  @override
  final KitchenVoidMeta meta;

  factory _$KitchenVoidResult(
          [void Function(KitchenVoidResultBuilder)? updates]) =>
      (KitchenVoidResultBuilder()..update(updates))._build();

  _$KitchenVoidResult._({required this.data, required this.meta}) : super._();
  @override
  KitchenVoidResult rebuild(void Function(KitchenVoidResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenVoidResultBuilder toBuilder() =>
      KitchenVoidResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenVoidResult &&
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
    return (newBuiltValueToStringHelper(r'KitchenVoidResult')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class KitchenVoidResultBuilder
    implements Builder<KitchenVoidResult, KitchenVoidResultBuilder> {
  _$KitchenVoidResult? _$v;

  WorkspaceBuilder? _data;
  WorkspaceBuilder get data => _$this._data ??= WorkspaceBuilder();
  set data(WorkspaceBuilder? data) => _$this._data = data;

  KitchenVoidMetaBuilder? _meta;
  KitchenVoidMetaBuilder get meta => _$this._meta ??= KitchenVoidMetaBuilder();
  set meta(KitchenVoidMetaBuilder? meta) => _$this._meta = meta;

  KitchenVoidResultBuilder() {
    KitchenVoidResult._defaults(this);
  }

  KitchenVoidResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenVoidResult other) {
    _$v = other as _$KitchenVoidResult;
  }

  @override
  void update(void Function(KitchenVoidResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenVoidResult build() => _build();

  _$KitchenVoidResult _build() {
    _$KitchenVoidResult _$result;
    try {
      _$result = _$v ??
          _$KitchenVoidResult._(
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
            r'KitchenVoidResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
