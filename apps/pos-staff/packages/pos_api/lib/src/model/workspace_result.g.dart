// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceResult extends WorkspaceResult {
  @override
  final Workspace data;

  factory _$WorkspaceResult([void Function(WorkspaceResultBuilder)? updates]) =>
      (WorkspaceResultBuilder()..update(updates))._build();

  _$WorkspaceResult._({required this.data}) : super._();
  @override
  WorkspaceResult rebuild(void Function(WorkspaceResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceResultBuilder toBuilder() => WorkspaceResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceResult && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceResult')..add('data', data))
        .toString();
  }
}

class WorkspaceResultBuilder
    implements Builder<WorkspaceResult, WorkspaceResultBuilder> {
  _$WorkspaceResult? _$v;

  WorkspaceBuilder? _data;
  WorkspaceBuilder get data => _$this._data ??= WorkspaceBuilder();
  set data(WorkspaceBuilder? data) => _$this._data = data;

  WorkspaceResultBuilder() {
    WorkspaceResult._defaults(this);
  }

  WorkspaceResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceResult other) {
    _$v = other as _$WorkspaceResult;
  }

  @override
  void update(void Function(WorkspaceResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceResult build() => _build();

  _$WorkspaceResult _build() {
    _$WorkspaceResult _$result;
    try {
      _$result = _$v ??
          _$WorkspaceResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
