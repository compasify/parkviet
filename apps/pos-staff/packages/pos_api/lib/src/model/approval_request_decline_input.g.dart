// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_request_decline_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApprovalRequestDeclineInput extends ApprovalRequestDeclineInput {
  @override
  final String? reason;

  factory _$ApprovalRequestDeclineInput(
          [void Function(ApprovalRequestDeclineInputBuilder)? updates]) =>
      (ApprovalRequestDeclineInputBuilder()..update(updates))._build();

  _$ApprovalRequestDeclineInput._({this.reason}) : super._();
  @override
  ApprovalRequestDeclineInput rebuild(
          void Function(ApprovalRequestDeclineInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalRequestDeclineInputBuilder toBuilder() =>
      ApprovalRequestDeclineInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApprovalRequestDeclineInput && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApprovalRequestDeclineInput')
          ..add('reason', reason))
        .toString();
  }
}

class ApprovalRequestDeclineInputBuilder
    implements
        Builder<ApprovalRequestDeclineInput,
            ApprovalRequestDeclineInputBuilder> {
  _$ApprovalRequestDeclineInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ApprovalRequestDeclineInputBuilder() {
    ApprovalRequestDeclineInput._defaults(this);
  }

  ApprovalRequestDeclineInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApprovalRequestDeclineInput other) {
    _$v = other as _$ApprovalRequestDeclineInput;
  }

  @override
  void update(void Function(ApprovalRequestDeclineInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApprovalRequestDeclineInput build() => _build();

  _$ApprovalRequestDeclineInput _build() {
    final _$result = _$v ??
        _$ApprovalRequestDeclineInput._(
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
