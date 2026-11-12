// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_request_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApprovalRequestInput extends ApprovalRequestInput {
  @override
  final String branchId;
  @override
  final String actionName;
  @override
  final String revision;
  @override
  final String? amount;
  @override
  final String? reason;
  @override
  final String? workspaceId;
  @override
  final String? reservationId;
  @override
  final String? bottleKeepId;
  @override
  final String? mealAccountId;
  @override
  final String? vehicleVisitId;
  @override
  final String? storedValueAccountId;

  factory _$ApprovalRequestInput(
          [void Function(ApprovalRequestInputBuilder)? updates]) =>
      (ApprovalRequestInputBuilder()..update(updates))._build();

  _$ApprovalRequestInput._(
      {required this.branchId,
      required this.actionName,
      required this.revision,
      this.amount,
      this.reason,
      this.workspaceId,
      this.reservationId,
      this.bottleKeepId,
      this.mealAccountId,
      this.vehicleVisitId,
      this.storedValueAccountId})
      : super._();
  @override
  ApprovalRequestInput rebuild(
          void Function(ApprovalRequestInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalRequestInputBuilder toBuilder() =>
      ApprovalRequestInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApprovalRequestInput &&
        branchId == other.branchId &&
        actionName == other.actionName &&
        revision == other.revision &&
        amount == other.amount &&
        reason == other.reason &&
        workspaceId == other.workspaceId &&
        reservationId == other.reservationId &&
        bottleKeepId == other.bottleKeepId &&
        mealAccountId == other.mealAccountId &&
        vehicleVisitId == other.vehicleVisitId &&
        storedValueAccountId == other.storedValueAccountId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, actionName.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, bottleKeepId.hashCode);
    _$hash = $jc(_$hash, mealAccountId.hashCode);
    _$hash = $jc(_$hash, vehicleVisitId.hashCode);
    _$hash = $jc(_$hash, storedValueAccountId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApprovalRequestInput')
          ..add('branchId', branchId)
          ..add('actionName', actionName)
          ..add('revision', revision)
          ..add('amount', amount)
          ..add('reason', reason)
          ..add('workspaceId', workspaceId)
          ..add('reservationId', reservationId)
          ..add('bottleKeepId', bottleKeepId)
          ..add('mealAccountId', mealAccountId)
          ..add('vehicleVisitId', vehicleVisitId)
          ..add('storedValueAccountId', storedValueAccountId))
        .toString();
  }
}

class ApprovalRequestInputBuilder
    implements Builder<ApprovalRequestInput, ApprovalRequestInputBuilder> {
  _$ApprovalRequestInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _actionName;
  String? get actionName => _$this._actionName;
  set actionName(String? actionName) => _$this._actionName = actionName;

  String? _revision;
  String? get revision => _$this._revision;
  set revision(String? revision) => _$this._revision = revision;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  String? _bottleKeepId;
  String? get bottleKeepId => _$this._bottleKeepId;
  set bottleKeepId(String? bottleKeepId) => _$this._bottleKeepId = bottleKeepId;

  String? _mealAccountId;
  String? get mealAccountId => _$this._mealAccountId;
  set mealAccountId(String? mealAccountId) =>
      _$this._mealAccountId = mealAccountId;

  String? _vehicleVisitId;
  String? get vehicleVisitId => _$this._vehicleVisitId;
  set vehicleVisitId(String? vehicleVisitId) =>
      _$this._vehicleVisitId = vehicleVisitId;

  String? _storedValueAccountId;
  String? get storedValueAccountId => _$this._storedValueAccountId;
  set storedValueAccountId(String? storedValueAccountId) =>
      _$this._storedValueAccountId = storedValueAccountId;

  ApprovalRequestInputBuilder() {
    ApprovalRequestInput._defaults(this);
  }

  ApprovalRequestInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _actionName = $v.actionName;
      _revision = $v.revision;
      _amount = $v.amount;
      _reason = $v.reason;
      _workspaceId = $v.workspaceId;
      _reservationId = $v.reservationId;
      _bottleKeepId = $v.bottleKeepId;
      _mealAccountId = $v.mealAccountId;
      _vehicleVisitId = $v.vehicleVisitId;
      _storedValueAccountId = $v.storedValueAccountId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApprovalRequestInput other) {
    _$v = other as _$ApprovalRequestInput;
  }

  @override
  void update(void Function(ApprovalRequestInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApprovalRequestInput build() => _build();

  _$ApprovalRequestInput _build() {
    final _$result = _$v ??
        _$ApprovalRequestInput._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'ApprovalRequestInput', 'branchId'),
          actionName: BuiltValueNullFieldError.checkNotNull(
              actionName, r'ApprovalRequestInput', 'actionName'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'ApprovalRequestInput', 'revision'),
          amount: amount,
          reason: reason,
          workspaceId: workspaceId,
          reservationId: reservationId,
          bottleKeepId: bottleKeepId,
          mealAccountId: mealAccountId,
          vehicleVisitId: vehicleVisitId,
          storedValueAccountId: storedValueAccountId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
