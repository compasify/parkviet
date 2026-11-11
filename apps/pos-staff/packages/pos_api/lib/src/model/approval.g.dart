// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Approval extends Approval {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String approverId;
  @override
  final String requesterId;
  @override
  final String action;
  @override
  final String? amount;
  @override
  final String currency;
  @override
  final ApprovalRevision revision;
  @override
  final String status;
  @override
  final String expiresAt;

  factory _$Approval([void Function(ApprovalBuilder)? updates]) =>
      (ApprovalBuilder()..update(updates))._build();

  _$Approval._(
      {required this.id,
      required this.branchId,
      required this.approverId,
      required this.requesterId,
      required this.action,
      this.amount,
      required this.currency,
      required this.revision,
      required this.status,
      required this.expiresAt})
      : super._();
  @override
  Approval rebuild(void Function(ApprovalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalBuilder toBuilder() => ApprovalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Approval &&
        id == other.id &&
        branchId == other.branchId &&
        approverId == other.approverId &&
        requesterId == other.requesterId &&
        action == other.action &&
        amount == other.amount &&
        currency == other.currency &&
        revision == other.revision &&
        status == other.status &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, approverId.hashCode);
    _$hash = $jc(_$hash, requesterId.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Approval')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('approverId', approverId)
          ..add('requesterId', requesterId)
          ..add('action', action)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('revision', revision)
          ..add('status', status)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class ApprovalBuilder implements Builder<Approval, ApprovalBuilder> {
  _$Approval? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _approverId;
  String? get approverId => _$this._approverId;
  set approverId(String? approverId) => _$this._approverId = approverId;

  String? _requesterId;
  String? get requesterId => _$this._requesterId;
  set requesterId(String? requesterId) => _$this._requesterId = requesterId;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  ApprovalRevisionBuilder? _revision;
  ApprovalRevisionBuilder get revision =>
      _$this._revision ??= ApprovalRevisionBuilder();
  set revision(ApprovalRevisionBuilder? revision) =>
      _$this._revision = revision;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _expiresAt;
  String? get expiresAt => _$this._expiresAt;
  set expiresAt(String? expiresAt) => _$this._expiresAt = expiresAt;

  ApprovalBuilder() {
    Approval._defaults(this);
  }

  ApprovalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _approverId = $v.approverId;
      _requesterId = $v.requesterId;
      _action = $v.action;
      _amount = $v.amount;
      _currency = $v.currency;
      _revision = $v.revision.toBuilder();
      _status = $v.status;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Approval other) {
    _$v = other as _$Approval;
  }

  @override
  void update(void Function(ApprovalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Approval build() => _build();

  _$Approval _build() {
    _$Approval _$result;
    try {
      _$result = _$v ??
          _$Approval._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Approval', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'Approval', 'branchId'),
            approverId: BuiltValueNullFieldError.checkNotNull(
                approverId, r'Approval', 'approverId'),
            requesterId: BuiltValueNullFieldError.checkNotNull(
                requesterId, r'Approval', 'requesterId'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'Approval', 'action'),
            amount: amount,
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'Approval', 'currency'),
            revision: revision.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Approval', 'status'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'Approval', 'expiresAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'revision';
        revision.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Approval', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
