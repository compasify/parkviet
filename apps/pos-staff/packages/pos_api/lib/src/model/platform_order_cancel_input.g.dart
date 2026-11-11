// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_cancel_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderCancelInput extends PlatformOrderCancelInput {
  @override
  final String editorId;
  @override
  final String? reason;
  @override
  final String? approvalId;

  factory _$PlatformOrderCancelInput(
          [void Function(PlatformOrderCancelInputBuilder)? updates]) =>
      (PlatformOrderCancelInputBuilder()..update(updates))._build();

  _$PlatformOrderCancelInput._(
      {required this.editorId, this.reason, this.approvalId})
      : super._();
  @override
  PlatformOrderCancelInput rebuild(
          void Function(PlatformOrderCancelInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderCancelInputBuilder toBuilder() =>
      PlatformOrderCancelInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderCancelInput &&
        editorId == other.editorId &&
        reason == other.reason &&
        approvalId == other.approvalId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformOrderCancelInput')
          ..add('editorId', editorId)
          ..add('reason', reason)
          ..add('approvalId', approvalId))
        .toString();
  }
}

class PlatformOrderCancelInputBuilder
    implements
        Builder<PlatformOrderCancelInput, PlatformOrderCancelInputBuilder> {
  _$PlatformOrderCancelInput? _$v;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  PlatformOrderCancelInputBuilder() {
    PlatformOrderCancelInput._defaults(this);
  }

  PlatformOrderCancelInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editorId = $v.editorId;
      _reason = $v.reason;
      _approvalId = $v.approvalId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderCancelInput other) {
    _$v = other as _$PlatformOrderCancelInput;
  }

  @override
  void update(void Function(PlatformOrderCancelInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderCancelInput build() => _build();

  _$PlatformOrderCancelInput _build() {
    final _$result = _$v ??
        _$PlatformOrderCancelInput._(
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'PlatformOrderCancelInput', 'editorId'),
          reason: reason,
          approvalId: approvalId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
