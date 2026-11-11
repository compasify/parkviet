// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceCreate201Response extends PosWorkspaceCreate201Response {
  @override
  final Workspace data;

  factory _$PosWorkspaceCreate201Response(
          [void Function(PosWorkspaceCreate201ResponseBuilder)? updates]) =>
      (PosWorkspaceCreate201ResponseBuilder()..update(updates))._build();

  _$PosWorkspaceCreate201Response._({required this.data}) : super._();
  @override
  PosWorkspaceCreate201Response rebuild(
          void Function(PosWorkspaceCreate201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceCreate201ResponseBuilder toBuilder() =>
      PosWorkspaceCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceCreate201Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosWorkspaceCreate201Response')
          ..add('data', data))
        .toString();
  }
}

class PosWorkspaceCreate201ResponseBuilder
    implements
        Builder<PosWorkspaceCreate201Response,
            PosWorkspaceCreate201ResponseBuilder> {
  _$PosWorkspaceCreate201Response? _$v;

  WorkspaceBuilder? _data;
  WorkspaceBuilder get data => _$this._data ??= WorkspaceBuilder();
  set data(WorkspaceBuilder? data) => _$this._data = data;

  PosWorkspaceCreate201ResponseBuilder() {
    PosWorkspaceCreate201Response._defaults(this);
  }

  PosWorkspaceCreate201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceCreate201Response other) {
    _$v = other as _$PosWorkspaceCreate201Response;
  }

  @override
  void update(void Function(PosWorkspaceCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceCreate201Response build() => _build();

  _$PosWorkspaceCreate201Response _build() {
    _$PosWorkspaceCreate201Response _$result;
    try {
      _$result = _$v ??
          _$PosWorkspaceCreate201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosWorkspaceCreate201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
