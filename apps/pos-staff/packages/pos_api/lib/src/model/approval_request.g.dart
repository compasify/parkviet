// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ApprovalRequestSubjectTypeEnum
    _$approvalRequestSubjectTypeEnum_workspace =
    const ApprovalRequestSubjectTypeEnum._('workspace');
const ApprovalRequestSubjectTypeEnum
    _$approvalRequestSubjectTypeEnum_reservation =
    const ApprovalRequestSubjectTypeEnum._('reservation');
const ApprovalRequestSubjectTypeEnum
    _$approvalRequestSubjectTypeEnum_bottleKeep =
    const ApprovalRequestSubjectTypeEnum._('bottleKeep');
const ApprovalRequestSubjectTypeEnum
    _$approvalRequestSubjectTypeEnum_mealAccount =
    const ApprovalRequestSubjectTypeEnum._('mealAccount');
const ApprovalRequestSubjectTypeEnum
    _$approvalRequestSubjectTypeEnum_vehicleVisit =
    const ApprovalRequestSubjectTypeEnum._('vehicleVisit');
const ApprovalRequestSubjectTypeEnum
    _$approvalRequestSubjectTypeEnum_storedValueAccount =
    const ApprovalRequestSubjectTypeEnum._('storedValueAccount');

ApprovalRequestSubjectTypeEnum _$approvalRequestSubjectTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'workspace':
      return _$approvalRequestSubjectTypeEnum_workspace;
    case 'reservation':
      return _$approvalRequestSubjectTypeEnum_reservation;
    case 'bottleKeep':
      return _$approvalRequestSubjectTypeEnum_bottleKeep;
    case 'mealAccount':
      return _$approvalRequestSubjectTypeEnum_mealAccount;
    case 'vehicleVisit':
      return _$approvalRequestSubjectTypeEnum_vehicleVisit;
    case 'storedValueAccount':
      return _$approvalRequestSubjectTypeEnum_storedValueAccount;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ApprovalRequestSubjectTypeEnum>
    _$approvalRequestSubjectTypeEnumValues = BuiltSet<
        ApprovalRequestSubjectTypeEnum>(const <ApprovalRequestSubjectTypeEnum>[
  _$approvalRequestSubjectTypeEnum_workspace,
  _$approvalRequestSubjectTypeEnum_reservation,
  _$approvalRequestSubjectTypeEnum_bottleKeep,
  _$approvalRequestSubjectTypeEnum_mealAccount,
  _$approvalRequestSubjectTypeEnum_vehicleVisit,
  _$approvalRequestSubjectTypeEnum_storedValueAccount,
]);

const ApprovalRequestStatusEnum _$approvalRequestStatusEnum_pending =
    const ApprovalRequestStatusEnum._('pending');
const ApprovalRequestStatusEnum _$approvalRequestStatusEnum_granted =
    const ApprovalRequestStatusEnum._('granted');
const ApprovalRequestStatusEnum _$approvalRequestStatusEnum_declined =
    const ApprovalRequestStatusEnum._('declined');
const ApprovalRequestStatusEnum _$approvalRequestStatusEnum_expired =
    const ApprovalRequestStatusEnum._('expired');
const ApprovalRequestStatusEnum _$approvalRequestStatusEnum_canceled =
    const ApprovalRequestStatusEnum._('canceled');

ApprovalRequestStatusEnum _$approvalRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$approvalRequestStatusEnum_pending;
    case 'granted':
      return _$approvalRequestStatusEnum_granted;
    case 'declined':
      return _$approvalRequestStatusEnum_declined;
    case 'expired':
      return _$approvalRequestStatusEnum_expired;
    case 'canceled':
      return _$approvalRequestStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ApprovalRequestStatusEnum> _$approvalRequestStatusEnumValues =
    BuiltSet<ApprovalRequestStatusEnum>(const <ApprovalRequestStatusEnum>[
  _$approvalRequestStatusEnum_pending,
  _$approvalRequestStatusEnum_granted,
  _$approvalRequestStatusEnum_declined,
  _$approvalRequestStatusEnum_expired,
  _$approvalRequestStatusEnum_canceled,
]);

Serializer<ApprovalRequestSubjectTypeEnum>
    _$approvalRequestSubjectTypeEnumSerializer =
    _$ApprovalRequestSubjectTypeEnumSerializer();
Serializer<ApprovalRequestStatusEnum> _$approvalRequestStatusEnumSerializer =
    _$ApprovalRequestStatusEnumSerializer();

class _$ApprovalRequestSubjectTypeEnumSerializer
    implements PrimitiveSerializer<ApprovalRequestSubjectTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'workspace': 'workspace',
    'reservation': 'reservation',
    'bottleKeep': 'bottle_keep',
    'mealAccount': 'meal_account',
    'vehicleVisit': 'vehicle_visit',
    'storedValueAccount': 'stored_value_account',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'workspace': 'workspace',
    'reservation': 'reservation',
    'bottle_keep': 'bottleKeep',
    'meal_account': 'mealAccount',
    'vehicle_visit': 'vehicleVisit',
    'stored_value_account': 'storedValueAccount',
  };

  @override
  final Iterable<Type> types = const <Type>[ApprovalRequestSubjectTypeEnum];
  @override
  final String wireName = 'ApprovalRequestSubjectTypeEnum';

  @override
  Object serialize(
          Serializers serializers, ApprovalRequestSubjectTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ApprovalRequestSubjectTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ApprovalRequestSubjectTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ApprovalRequestStatusEnumSerializer
    implements PrimitiveSerializer<ApprovalRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'granted': 'granted',
    'declined': 'declined',
    'expired': 'expired',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'granted': 'granted',
    'declined': 'declined',
    'expired': 'expired',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[ApprovalRequestStatusEnum];
  @override
  final String wireName = 'ApprovalRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, ApprovalRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ApprovalRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ApprovalRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ApprovalRequest extends ApprovalRequest {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String branchName;
  @override
  final String requesterId;
  @override
  final String? requesterName;
  @override
  final String action;
  @override
  final ApprovalRequestSubjectTypeEnum subjectType;
  @override
  final String? subjectId;
  @override
  final String? subjectLabel;
  @override
  final String revision;
  @override
  final String? amount;
  @override
  final String? currency;
  @override
  final String? reason;
  @override
  final ApprovalRequestStatusEnum status;
  @override
  final String? approvalId;
  @override
  final String? decidedByName;
  @override
  final DateTime? decidedAt;
  @override
  final DateTime expiresAt;
  @override
  final DateTime createdAt;

  factory _$ApprovalRequest([void Function(ApprovalRequestBuilder)? updates]) =>
      (ApprovalRequestBuilder()..update(updates))._build();

  _$ApprovalRequest._(
      {required this.id,
      required this.branchId,
      required this.branchName,
      required this.requesterId,
      this.requesterName,
      required this.action,
      required this.subjectType,
      this.subjectId,
      this.subjectLabel,
      required this.revision,
      this.amount,
      this.currency,
      this.reason,
      required this.status,
      this.approvalId,
      this.decidedByName,
      this.decidedAt,
      required this.expiresAt,
      required this.createdAt})
      : super._();
  @override
  ApprovalRequest rebuild(void Function(ApprovalRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalRequestBuilder toBuilder() => ApprovalRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApprovalRequest &&
        id == other.id &&
        branchId == other.branchId &&
        branchName == other.branchName &&
        requesterId == other.requesterId &&
        requesterName == other.requesterName &&
        action == other.action &&
        subjectType == other.subjectType &&
        subjectId == other.subjectId &&
        subjectLabel == other.subjectLabel &&
        revision == other.revision &&
        amount == other.amount &&
        currency == other.currency &&
        reason == other.reason &&
        status == other.status &&
        approvalId == other.approvalId &&
        decidedByName == other.decidedByName &&
        decidedAt == other.decidedAt &&
        expiresAt == other.expiresAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, branchName.hashCode);
    _$hash = $jc(_$hash, requesterId.hashCode);
    _$hash = $jc(_$hash, requesterName.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, subjectType.hashCode);
    _$hash = $jc(_$hash, subjectId.hashCode);
    _$hash = $jc(_$hash, subjectLabel.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, decidedByName.hashCode);
    _$hash = $jc(_$hash, decidedAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApprovalRequest')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('branchName', branchName)
          ..add('requesterId', requesterId)
          ..add('requesterName', requesterName)
          ..add('action', action)
          ..add('subjectType', subjectType)
          ..add('subjectId', subjectId)
          ..add('subjectLabel', subjectLabel)
          ..add('revision', revision)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('reason', reason)
          ..add('status', status)
          ..add('approvalId', approvalId)
          ..add('decidedByName', decidedByName)
          ..add('decidedAt', decidedAt)
          ..add('expiresAt', expiresAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ApprovalRequestBuilder
    implements Builder<ApprovalRequest, ApprovalRequestBuilder> {
  _$ApprovalRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _branchName;
  String? get branchName => _$this._branchName;
  set branchName(String? branchName) => _$this._branchName = branchName;

  String? _requesterId;
  String? get requesterId => _$this._requesterId;
  set requesterId(String? requesterId) => _$this._requesterId = requesterId;

  String? _requesterName;
  String? get requesterName => _$this._requesterName;
  set requesterName(String? requesterName) =>
      _$this._requesterName = requesterName;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  ApprovalRequestSubjectTypeEnum? _subjectType;
  ApprovalRequestSubjectTypeEnum? get subjectType => _$this._subjectType;
  set subjectType(ApprovalRequestSubjectTypeEnum? subjectType) =>
      _$this._subjectType = subjectType;

  String? _subjectId;
  String? get subjectId => _$this._subjectId;
  set subjectId(String? subjectId) => _$this._subjectId = subjectId;

  String? _subjectLabel;
  String? get subjectLabel => _$this._subjectLabel;
  set subjectLabel(String? subjectLabel) => _$this._subjectLabel = subjectLabel;

  String? _revision;
  String? get revision => _$this._revision;
  set revision(String? revision) => _$this._revision = revision;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ApprovalRequestStatusEnum? _status;
  ApprovalRequestStatusEnum? get status => _$this._status;
  set status(ApprovalRequestStatusEnum? status) => _$this._status = status;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  String? _decidedByName;
  String? get decidedByName => _$this._decidedByName;
  set decidedByName(String? decidedByName) =>
      _$this._decidedByName = decidedByName;

  DateTime? _decidedAt;
  DateTime? get decidedAt => _$this._decidedAt;
  set decidedAt(DateTime? decidedAt) => _$this._decidedAt = decidedAt;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ApprovalRequestBuilder() {
    ApprovalRequest._defaults(this);
  }

  ApprovalRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _branchName = $v.branchName;
      _requesterId = $v.requesterId;
      _requesterName = $v.requesterName;
      _action = $v.action;
      _subjectType = $v.subjectType;
      _subjectId = $v.subjectId;
      _subjectLabel = $v.subjectLabel;
      _revision = $v.revision;
      _amount = $v.amount;
      _currency = $v.currency;
      _reason = $v.reason;
      _status = $v.status;
      _approvalId = $v.approvalId;
      _decidedByName = $v.decidedByName;
      _decidedAt = $v.decidedAt;
      _expiresAt = $v.expiresAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApprovalRequest other) {
    _$v = other as _$ApprovalRequest;
  }

  @override
  void update(void Function(ApprovalRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApprovalRequest build() => _build();

  _$ApprovalRequest _build() {
    final _$result = _$v ??
        _$ApprovalRequest._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ApprovalRequest', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'ApprovalRequest', 'branchId'),
          branchName: BuiltValueNullFieldError.checkNotNull(
              branchName, r'ApprovalRequest', 'branchName'),
          requesterId: BuiltValueNullFieldError.checkNotNull(
              requesterId, r'ApprovalRequest', 'requesterId'),
          requesterName: requesterName,
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'ApprovalRequest', 'action'),
          subjectType: BuiltValueNullFieldError.checkNotNull(
              subjectType, r'ApprovalRequest', 'subjectType'),
          subjectId: subjectId,
          subjectLabel: subjectLabel,
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'ApprovalRequest', 'revision'),
          amount: amount,
          currency: currency,
          reason: reason,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ApprovalRequest', 'status'),
          approvalId: approvalId,
          decidedByName: decidedByName,
          decidedAt: decidedAt,
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'ApprovalRequest', 'expiresAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ApprovalRequest', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
