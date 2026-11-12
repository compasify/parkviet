// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_meal_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceMealResult extends WorkspaceMealResult {
  @override
  final WorkspaceMeal data;

  factory _$WorkspaceMealResult(
          [void Function(WorkspaceMealResultBuilder)? updates]) =>
      (WorkspaceMealResultBuilder()..update(updates))._build();

  _$WorkspaceMealResult._({required this.data}) : super._();
  @override
  WorkspaceMealResult rebuild(
          void Function(WorkspaceMealResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceMealResultBuilder toBuilder() =>
      WorkspaceMealResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceMealResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'WorkspaceMealResult')
          ..add('data', data))
        .toString();
  }
}

class WorkspaceMealResultBuilder
    implements Builder<WorkspaceMealResult, WorkspaceMealResultBuilder> {
  _$WorkspaceMealResult? _$v;

  WorkspaceMealBuilder? _data;
  WorkspaceMealBuilder get data => _$this._data ??= WorkspaceMealBuilder();
  set data(WorkspaceMealBuilder? data) => _$this._data = data;

  WorkspaceMealResultBuilder() {
    WorkspaceMealResult._defaults(this);
  }

  WorkspaceMealResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceMealResult other) {
    _$v = other as _$WorkspaceMealResult;
  }

  @override
  void update(void Function(WorkspaceMealResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceMealResult build() => _build();

  _$WorkspaceMealResult _build() {
    _$WorkspaceMealResult _$result;
    try {
      _$result = _$v ??
          _$WorkspaceMealResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceMealResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
