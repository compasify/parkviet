// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_send_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenSendResult extends KitchenSendResult {
  @override
  final Workspace data;
  @override
  final KitchenSendMeta meta;

  factory _$KitchenSendResult(
          [void Function(KitchenSendResultBuilder)? updates]) =>
      (KitchenSendResultBuilder()..update(updates))._build();

  _$KitchenSendResult._({required this.data, required this.meta}) : super._();
  @override
  KitchenSendResult rebuild(void Function(KitchenSendResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenSendResultBuilder toBuilder() =>
      KitchenSendResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenSendResult &&
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
    return (newBuiltValueToStringHelper(r'KitchenSendResult')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class KitchenSendResultBuilder
    implements Builder<KitchenSendResult, KitchenSendResultBuilder> {
  _$KitchenSendResult? _$v;

  WorkspaceBuilder? _data;
  WorkspaceBuilder get data => _$this._data ??= WorkspaceBuilder();
  set data(WorkspaceBuilder? data) => _$this._data = data;

  KitchenSendMetaBuilder? _meta;
  KitchenSendMetaBuilder get meta => _$this._meta ??= KitchenSendMetaBuilder();
  set meta(KitchenSendMetaBuilder? meta) => _$this._meta = meta;

  KitchenSendResultBuilder() {
    KitchenSendResult._defaults(this);
  }

  KitchenSendResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenSendResult other) {
    _$v = other as _$KitchenSendResult;
  }

  @override
  void update(void Function(KitchenSendResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenSendResult build() => _build();

  _$KitchenSendResult _build() {
    _$KitchenSendResult _$result;
    try {
      _$result = _$v ??
          _$KitchenSendResult._(
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
            r'KitchenSendResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
