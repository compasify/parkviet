// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_deposit_resolve_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDepositResolveInput extends ReservationDepositResolveInput {
  @override
  final String? approvalId;
  @override
  final String? reason;

  factory _$ReservationDepositResolveInput(
          [void Function(ReservationDepositResolveInputBuilder)? updates]) =>
      (ReservationDepositResolveInputBuilder()..update(updates))._build();

  _$ReservationDepositResolveInput._({this.approvalId, this.reason})
      : super._();
  @override
  ReservationDepositResolveInput rebuild(
          void Function(ReservationDepositResolveInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDepositResolveInputBuilder toBuilder() =>
      ReservationDepositResolveInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDepositResolveInput &&
        approvalId == other.approvalId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDepositResolveInput')
          ..add('approvalId', approvalId)
          ..add('reason', reason))
        .toString();
  }
}

class ReservationDepositResolveInputBuilder
    implements
        Builder<ReservationDepositResolveInput,
            ReservationDepositResolveInputBuilder> {
  _$ReservationDepositResolveInput? _$v;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ReservationDepositResolveInputBuilder() {
    ReservationDepositResolveInput._defaults(this);
  }

  ReservationDepositResolveInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approvalId = $v.approvalId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDepositResolveInput other) {
    _$v = other as _$ReservationDepositResolveInput;
  }

  @override
  void update(void Function(ReservationDepositResolveInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDepositResolveInput build() => _build();

  _$ReservationDepositResolveInput _build() {
    final _$result = _$v ??
        _$ReservationDepositResolveInput._(
          approvalId: approvalId,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
