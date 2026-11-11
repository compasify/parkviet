// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_send201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKitchenSend201Response extends PosKitchenSend201Response {
  @override
  final Workspace data;
  @override
  final PosKitchenSend201ResponseMeta meta;

  factory _$PosKitchenSend201Response(
          [void Function(PosKitchenSend201ResponseBuilder)? updates]) =>
      (PosKitchenSend201ResponseBuilder()..update(updates))._build();

  _$PosKitchenSend201Response._({required this.data, required this.meta})
      : super._();
  @override
  PosKitchenSend201Response rebuild(
          void Function(PosKitchenSend201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenSend201ResponseBuilder toBuilder() =>
      PosKitchenSend201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenSend201Response &&
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
    return (newBuiltValueToStringHelper(r'PosKitchenSend201Response')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class PosKitchenSend201ResponseBuilder
    implements
        Builder<PosKitchenSend201Response, PosKitchenSend201ResponseBuilder> {
  _$PosKitchenSend201Response? _$v;

  WorkspaceBuilder? _data;
  WorkspaceBuilder get data => _$this._data ??= WorkspaceBuilder();
  set data(WorkspaceBuilder? data) => _$this._data = data;

  PosKitchenSend201ResponseMetaBuilder? _meta;
  PosKitchenSend201ResponseMetaBuilder get meta =>
      _$this._meta ??= PosKitchenSend201ResponseMetaBuilder();
  set meta(PosKitchenSend201ResponseMetaBuilder? meta) => _$this._meta = meta;

  PosKitchenSend201ResponseBuilder() {
    PosKitchenSend201Response._defaults(this);
  }

  PosKitchenSend201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKitchenSend201Response other) {
    _$v = other as _$PosKitchenSend201Response;
  }

  @override
  void update(void Function(PosKitchenSend201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenSend201Response build() => _build();

  _$PosKitchenSend201Response _build() {
    _$PosKitchenSend201Response _$result;
    try {
      _$result = _$v ??
          _$PosKitchenSend201Response._(
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
            r'PosKitchenSend201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
