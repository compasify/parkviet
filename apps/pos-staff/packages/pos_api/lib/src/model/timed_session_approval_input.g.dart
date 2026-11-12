// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session_approval_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedSessionApprovalInput extends TimedSessionApprovalInput {
  @override
  final String? approvalId;

  factory _$TimedSessionApprovalInput(
          [void Function(TimedSessionApprovalInputBuilder)? updates]) =>
      (TimedSessionApprovalInputBuilder()..update(updates))._build();

  _$TimedSessionApprovalInput._({this.approvalId}) : super._();
  @override
  TimedSessionApprovalInput rebuild(
          void Function(TimedSessionApprovalInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionApprovalInputBuilder toBuilder() =>
      TimedSessionApprovalInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSessionApprovalInput && approvalId == other.approvalId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSessionApprovalInput')
          ..add('approvalId', approvalId))
        .toString();
  }
}

class TimedSessionApprovalInputBuilder
    implements
        Builder<TimedSessionApprovalInput, TimedSessionApprovalInputBuilder> {
  _$TimedSessionApprovalInput? _$v;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  TimedSessionApprovalInputBuilder() {
    TimedSessionApprovalInput._defaults(this);
  }

  TimedSessionApprovalInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approvalId = $v.approvalId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSessionApprovalInput other) {
    _$v = other as _$TimedSessionApprovalInput;
  }

  @override
  void update(void Function(TimedSessionApprovalInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSessionApprovalInput build() => _build();

  _$TimedSessionApprovalInput _build() {
    final _$result = _$v ??
        _$TimedSessionApprovalInput._(
          approvalId: approvalId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
