// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_accept_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestOrderAcceptMeta extends GuestOrderAcceptMeta {
  @override
  final Workspace? workspace;
  @override
  final int? kitchenTicketCount;

  factory _$GuestOrderAcceptMeta(
          [void Function(GuestOrderAcceptMetaBuilder)? updates]) =>
      (GuestOrderAcceptMetaBuilder()..update(updates))._build();

  _$GuestOrderAcceptMeta._({this.workspace, this.kitchenTicketCount})
      : super._();
  @override
  GuestOrderAcceptMeta rebuild(
          void Function(GuestOrderAcceptMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderAcceptMetaBuilder toBuilder() =>
      GuestOrderAcceptMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderAcceptMeta &&
        workspace == other.workspace &&
        kitchenTicketCount == other.kitchenTicketCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspace.hashCode);
    _$hash = $jc(_$hash, kitchenTicketCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestOrderAcceptMeta')
          ..add('workspace', workspace)
          ..add('kitchenTicketCount', kitchenTicketCount))
        .toString();
  }
}

class GuestOrderAcceptMetaBuilder
    implements Builder<GuestOrderAcceptMeta, GuestOrderAcceptMetaBuilder> {
  _$GuestOrderAcceptMeta? _$v;

  WorkspaceBuilder? _workspace;
  WorkspaceBuilder get workspace => _$this._workspace ??= WorkspaceBuilder();
  set workspace(WorkspaceBuilder? workspace) => _$this._workspace = workspace;

  int? _kitchenTicketCount;
  int? get kitchenTicketCount => _$this._kitchenTicketCount;
  set kitchenTicketCount(int? kitchenTicketCount) =>
      _$this._kitchenTicketCount = kitchenTicketCount;

  GuestOrderAcceptMetaBuilder() {
    GuestOrderAcceptMeta._defaults(this);
  }

  GuestOrderAcceptMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspace = $v.workspace?.toBuilder();
      _kitchenTicketCount = $v.kitchenTicketCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderAcceptMeta other) {
    _$v = other as _$GuestOrderAcceptMeta;
  }

  @override
  void update(void Function(GuestOrderAcceptMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderAcceptMeta build() => _build();

  _$GuestOrderAcceptMeta _build() {
    _$GuestOrderAcceptMeta _$result;
    try {
      _$result = _$v ??
          _$GuestOrderAcceptMeta._(
            workspace: _workspace?.build(),
            kitchenTicketCount: kitchenTicketCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'workspace';
        _workspace?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GuestOrderAcceptMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
