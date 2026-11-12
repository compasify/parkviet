// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VehicleVisitStatusEnum _$vehicleVisitStatusEnum_open =
    const VehicleVisitStatusEnum._('open');
const VehicleVisitStatusEnum _$vehicleVisitStatusEnum_closed =
    const VehicleVisitStatusEnum._('closed');
const VehicleVisitStatusEnum _$vehicleVisitStatusEnum_paid =
    const VehicleVisitStatusEnum._('paid');
const VehicleVisitStatusEnum _$vehicleVisitStatusEnum_voided =
    const VehicleVisitStatusEnum._('voided');

VehicleVisitStatusEnum _$vehicleVisitStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$vehicleVisitStatusEnum_open;
    case 'closed':
      return _$vehicleVisitStatusEnum_closed;
    case 'paid':
      return _$vehicleVisitStatusEnum_paid;
    case 'voided':
      return _$vehicleVisitStatusEnum_voided;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleVisitStatusEnum> _$vehicleVisitStatusEnumValues =
    BuiltSet<VehicleVisitStatusEnum>(const <VehicleVisitStatusEnum>[
  _$vehicleVisitStatusEnum_open,
  _$vehicleVisitStatusEnum_closed,
  _$vehicleVisitStatusEnum_paid,
  _$vehicleVisitStatusEnum_voided,
]);

const VehicleVisitPayoutMethodEnum _$vehicleVisitPayoutMethodEnum_cash =
    const VehicleVisitPayoutMethodEnum._('cash');
const VehicleVisitPayoutMethodEnum _$vehicleVisitPayoutMethodEnum_transfer =
    const VehicleVisitPayoutMethodEnum._('transfer');

VehicleVisitPayoutMethodEnum _$vehicleVisitPayoutMethodEnumValueOf(
    String name) {
  switch (name) {
    case 'cash':
      return _$vehicleVisitPayoutMethodEnum_cash;
    case 'transfer':
      return _$vehicleVisitPayoutMethodEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleVisitPayoutMethodEnum>
    _$vehicleVisitPayoutMethodEnumValues =
    BuiltSet<VehicleVisitPayoutMethodEnum>(const <VehicleVisitPayoutMethodEnum>[
  _$vehicleVisitPayoutMethodEnum_cash,
  _$vehicleVisitPayoutMethodEnum_transfer,
]);

const VehicleVisitPayoutStatusEnum _$vehicleVisitPayoutStatusEnum_requested =
    const VehicleVisitPayoutStatusEnum._('requested');
const VehicleVisitPayoutStatusEnum _$vehicleVisitPayoutStatusEnum_paid =
    const VehicleVisitPayoutStatusEnum._('paid');
const VehicleVisitPayoutStatusEnum _$vehicleVisitPayoutStatusEnum_canceled =
    const VehicleVisitPayoutStatusEnum._('canceled');

VehicleVisitPayoutStatusEnum _$vehicleVisitPayoutStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'requested':
      return _$vehicleVisitPayoutStatusEnum_requested;
    case 'paid':
      return _$vehicleVisitPayoutStatusEnum_paid;
    case 'canceled':
      return _$vehicleVisitPayoutStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleVisitPayoutStatusEnum>
    _$vehicleVisitPayoutStatusEnumValues =
    BuiltSet<VehicleVisitPayoutStatusEnum>(const <VehicleVisitPayoutStatusEnum>[
  _$vehicleVisitPayoutStatusEnum_requested,
  _$vehicleVisitPayoutStatusEnum_paid,
  _$vehicleVisitPayoutStatusEnum_canceled,
]);

const VehicleVisitWarningsEnum _$vehicleVisitWarningsEnum_plateOpenToday =
    const VehicleVisitWarningsEnum._('plateOpenToday');

VehicleVisitWarningsEnum _$vehicleVisitWarningsEnumValueOf(String name) {
  switch (name) {
    case 'plateOpenToday':
      return _$vehicleVisitWarningsEnum_plateOpenToday;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleVisitWarningsEnum> _$vehicleVisitWarningsEnumValues =
    BuiltSet<VehicleVisitWarningsEnum>(const <VehicleVisitWarningsEnum>[
  _$vehicleVisitWarningsEnum_plateOpenToday,
]);

Serializer<VehicleVisitStatusEnum> _$vehicleVisitStatusEnumSerializer =
    _$VehicleVisitStatusEnumSerializer();
Serializer<VehicleVisitPayoutMethodEnum>
    _$vehicleVisitPayoutMethodEnumSerializer =
    _$VehicleVisitPayoutMethodEnumSerializer();
Serializer<VehicleVisitPayoutStatusEnum>
    _$vehicleVisitPayoutStatusEnumSerializer =
    _$VehicleVisitPayoutStatusEnumSerializer();
Serializer<VehicleVisitWarningsEnum> _$vehicleVisitWarningsEnumSerializer =
    _$VehicleVisitWarningsEnumSerializer();

class _$VehicleVisitStatusEnumSerializer
    implements PrimitiveSerializer<VehicleVisitStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'closed': 'closed',
    'paid': 'paid',
    'voided': 'voided',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'closed': 'closed',
    'paid': 'paid',
    'voided': 'voided',
  };

  @override
  final Iterable<Type> types = const <Type>[VehicleVisitStatusEnum];
  @override
  final String wireName = 'VehicleVisitStatusEnum';

  @override
  Object serialize(Serializers serializers, VehicleVisitStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VehicleVisitStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VehicleVisitStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VehicleVisitPayoutMethodEnumSerializer
    implements PrimitiveSerializer<VehicleVisitPayoutMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'transfer': 'transfer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'transfer': 'transfer',
  };

  @override
  final Iterable<Type> types = const <Type>[VehicleVisitPayoutMethodEnum];
  @override
  final String wireName = 'VehicleVisitPayoutMethodEnum';

  @override
  Object serialize(Serializers serializers, VehicleVisitPayoutMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VehicleVisitPayoutMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VehicleVisitPayoutMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VehicleVisitPayoutStatusEnumSerializer
    implements PrimitiveSerializer<VehicleVisitPayoutStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'requested': 'requested',
    'paid': 'paid',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'requested': 'requested',
    'paid': 'paid',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[VehicleVisitPayoutStatusEnum];
  @override
  final String wireName = 'VehicleVisitPayoutStatusEnum';

  @override
  Object serialize(Serializers serializers, VehicleVisitPayoutStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VehicleVisitPayoutStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VehicleVisitPayoutStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VehicleVisitWarningsEnumSerializer
    implements PrimitiveSerializer<VehicleVisitWarningsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'plateOpenToday': 'plate_open_today',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'plate_open_today': 'plateOpenToday',
  };

  @override
  final Iterable<Type> types = const <Type>[VehicleVisitWarningsEnum];
  @override
  final String wireName = 'VehicleVisitWarningsEnum';

  @override
  Object serialize(Serializers serializers, VehicleVisitWarningsEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VehicleVisitWarningsEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VehicleVisitWarningsEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VehicleVisit extends VehicleVisit {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final BusOperatorRef? busOperator;
  @override
  final String plate;
  @override
  final VehicleType vehicleType;
  @override
  final String? driverName;
  @override
  final String? driverPhone;
  @override
  final int guestCount;
  @override
  final DateTime arrivedAt;
  @override
  final DateTime closesAt;
  @override
  final DateTime? closedAt;
  @override
  final bool? autoClosed;
  @override
  final VehicleVisitStatusEnum status;
  @override
  final Date businessDate;
  @override
  final String? openedByName;
  @override
  final String? revenueAmount;
  @override
  final String? commissionAmount;
  @override
  final String currency;
  @override
  final VehicleCommissionSnapshot? commission;
  @override
  final DateTime? paidAt;
  @override
  final VehicleVisitPayoutMethodEnum? payoutMethod;
  @override
  final VehicleVisitPayoutStatusEnum? payoutStatus;
  @override
  final String? cashMovementRequestId;
  @override
  final String? transferReference;
  @override
  final String? voidReason;
  @override
  final String? note;
  @override
  final int revision;
  @override
  final int? workspacesCount;
  @override
  final BuiltList<VehicleVisitWarningsEnum>? warnings;

  factory _$VehicleVisit([void Function(VehicleVisitBuilder)? updates]) =>
      (VehicleVisitBuilder()..update(updates))._build();

  _$VehicleVisit._(
      {required this.id,
      required this.branchId,
      this.busOperator,
      required this.plate,
      required this.vehicleType,
      this.driverName,
      this.driverPhone,
      required this.guestCount,
      required this.arrivedAt,
      required this.closesAt,
      this.closedAt,
      this.autoClosed,
      required this.status,
      required this.businessDate,
      this.openedByName,
      this.revenueAmount,
      this.commissionAmount,
      required this.currency,
      this.commission,
      this.paidAt,
      this.payoutMethod,
      this.payoutStatus,
      this.cashMovementRequestId,
      this.transferReference,
      this.voidReason,
      this.note,
      required this.revision,
      this.workspacesCount,
      this.warnings})
      : super._();
  @override
  VehicleVisit rebuild(void Function(VehicleVisitBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitBuilder toBuilder() => VehicleVisitBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisit &&
        id == other.id &&
        branchId == other.branchId &&
        busOperator == other.busOperator &&
        plate == other.plate &&
        vehicleType == other.vehicleType &&
        driverName == other.driverName &&
        driverPhone == other.driverPhone &&
        guestCount == other.guestCount &&
        arrivedAt == other.arrivedAt &&
        closesAt == other.closesAt &&
        closedAt == other.closedAt &&
        autoClosed == other.autoClosed &&
        status == other.status &&
        businessDate == other.businessDate &&
        openedByName == other.openedByName &&
        revenueAmount == other.revenueAmount &&
        commissionAmount == other.commissionAmount &&
        currency == other.currency &&
        commission == other.commission &&
        paidAt == other.paidAt &&
        payoutMethod == other.payoutMethod &&
        payoutStatus == other.payoutStatus &&
        cashMovementRequestId == other.cashMovementRequestId &&
        transferReference == other.transferReference &&
        voidReason == other.voidReason &&
        note == other.note &&
        revision == other.revision &&
        workspacesCount == other.workspacesCount &&
        warnings == other.warnings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, busOperator.hashCode);
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, driverPhone.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, arrivedAt.hashCode);
    _$hash = $jc(_$hash, closesAt.hashCode);
    _$hash = $jc(_$hash, closedAt.hashCode);
    _$hash = $jc(_$hash, autoClosed.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, openedByName.hashCode);
    _$hash = $jc(_$hash, revenueAmount.hashCode);
    _$hash = $jc(_$hash, commissionAmount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, commission.hashCode);
    _$hash = $jc(_$hash, paidAt.hashCode);
    _$hash = $jc(_$hash, payoutMethod.hashCode);
    _$hash = $jc(_$hash, payoutStatus.hashCode);
    _$hash = $jc(_$hash, cashMovementRequestId.hashCode);
    _$hash = $jc(_$hash, transferReference.hashCode);
    _$hash = $jc(_$hash, voidReason.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, workspacesCount.hashCode);
    _$hash = $jc(_$hash, warnings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleVisit')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('busOperator', busOperator)
          ..add('plate', plate)
          ..add('vehicleType', vehicleType)
          ..add('driverName', driverName)
          ..add('driverPhone', driverPhone)
          ..add('guestCount', guestCount)
          ..add('arrivedAt', arrivedAt)
          ..add('closesAt', closesAt)
          ..add('closedAt', closedAt)
          ..add('autoClosed', autoClosed)
          ..add('status', status)
          ..add('businessDate', businessDate)
          ..add('openedByName', openedByName)
          ..add('revenueAmount', revenueAmount)
          ..add('commissionAmount', commissionAmount)
          ..add('currency', currency)
          ..add('commission', commission)
          ..add('paidAt', paidAt)
          ..add('payoutMethod', payoutMethod)
          ..add('payoutStatus', payoutStatus)
          ..add('cashMovementRequestId', cashMovementRequestId)
          ..add('transferReference', transferReference)
          ..add('voidReason', voidReason)
          ..add('note', note)
          ..add('revision', revision)
          ..add('workspacesCount', workspacesCount)
          ..add('warnings', warnings))
        .toString();
  }
}

class VehicleVisitBuilder
    implements Builder<VehicleVisit, VehicleVisitBuilder> {
  _$VehicleVisit? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  BusOperatorRefBuilder? _busOperator;
  BusOperatorRefBuilder get busOperator =>
      _$this._busOperator ??= BusOperatorRefBuilder();
  set busOperator(BusOperatorRefBuilder? busOperator) =>
      _$this._busOperator = busOperator;

  String? _plate;
  String? get plate => _$this._plate;
  set plate(String? plate) => _$this._plate = plate;

  VehicleType? _vehicleType;
  VehicleType? get vehicleType => _$this._vehicleType;
  set vehicleType(VehicleType? vehicleType) =>
      _$this._vehicleType = vehicleType;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _driverPhone;
  String? get driverPhone => _$this._driverPhone;
  set driverPhone(String? driverPhone) => _$this._driverPhone = driverPhone;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  DateTime? _arrivedAt;
  DateTime? get arrivedAt => _$this._arrivedAt;
  set arrivedAt(DateTime? arrivedAt) => _$this._arrivedAt = arrivedAt;

  DateTime? _closesAt;
  DateTime? get closesAt => _$this._closesAt;
  set closesAt(DateTime? closesAt) => _$this._closesAt = closesAt;

  DateTime? _closedAt;
  DateTime? get closedAt => _$this._closedAt;
  set closedAt(DateTime? closedAt) => _$this._closedAt = closedAt;

  bool? _autoClosed;
  bool? get autoClosed => _$this._autoClosed;
  set autoClosed(bool? autoClosed) => _$this._autoClosed = autoClosed;

  VehicleVisitStatusEnum? _status;
  VehicleVisitStatusEnum? get status => _$this._status;
  set status(VehicleVisitStatusEnum? status) => _$this._status = status;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  String? _openedByName;
  String? get openedByName => _$this._openedByName;
  set openedByName(String? openedByName) => _$this._openedByName = openedByName;

  String? _revenueAmount;
  String? get revenueAmount => _$this._revenueAmount;
  set revenueAmount(String? revenueAmount) =>
      _$this._revenueAmount = revenueAmount;

  String? _commissionAmount;
  String? get commissionAmount => _$this._commissionAmount;
  set commissionAmount(String? commissionAmount) =>
      _$this._commissionAmount = commissionAmount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  VehicleCommissionSnapshotBuilder? _commission;
  VehicleCommissionSnapshotBuilder get commission =>
      _$this._commission ??= VehicleCommissionSnapshotBuilder();
  set commission(VehicleCommissionSnapshotBuilder? commission) =>
      _$this._commission = commission;

  DateTime? _paidAt;
  DateTime? get paidAt => _$this._paidAt;
  set paidAt(DateTime? paidAt) => _$this._paidAt = paidAt;

  VehicleVisitPayoutMethodEnum? _payoutMethod;
  VehicleVisitPayoutMethodEnum? get payoutMethod => _$this._payoutMethod;
  set payoutMethod(VehicleVisitPayoutMethodEnum? payoutMethod) =>
      _$this._payoutMethod = payoutMethod;

  VehicleVisitPayoutStatusEnum? _payoutStatus;
  VehicleVisitPayoutStatusEnum? get payoutStatus => _$this._payoutStatus;
  set payoutStatus(VehicleVisitPayoutStatusEnum? payoutStatus) =>
      _$this._payoutStatus = payoutStatus;

  String? _cashMovementRequestId;
  String? get cashMovementRequestId => _$this._cashMovementRequestId;
  set cashMovementRequestId(String? cashMovementRequestId) =>
      _$this._cashMovementRequestId = cashMovementRequestId;

  String? _transferReference;
  String? get transferReference => _$this._transferReference;
  set transferReference(String? transferReference) =>
      _$this._transferReference = transferReference;

  String? _voidReason;
  String? get voidReason => _$this._voidReason;
  set voidReason(String? voidReason) => _$this._voidReason = voidReason;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _workspacesCount;
  int? get workspacesCount => _$this._workspacesCount;
  set workspacesCount(int? workspacesCount) =>
      _$this._workspacesCount = workspacesCount;

  ListBuilder<VehicleVisitWarningsEnum>? _warnings;
  ListBuilder<VehicleVisitWarningsEnum> get warnings =>
      _$this._warnings ??= ListBuilder<VehicleVisitWarningsEnum>();
  set warnings(ListBuilder<VehicleVisitWarningsEnum>? warnings) =>
      _$this._warnings = warnings;

  VehicleVisitBuilder() {
    VehicleVisit._defaults(this);
  }

  VehicleVisitBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _busOperator = $v.busOperator?.toBuilder();
      _plate = $v.plate;
      _vehicleType = $v.vehicleType;
      _driverName = $v.driverName;
      _driverPhone = $v.driverPhone;
      _guestCount = $v.guestCount;
      _arrivedAt = $v.arrivedAt;
      _closesAt = $v.closesAt;
      _closedAt = $v.closedAt;
      _autoClosed = $v.autoClosed;
      _status = $v.status;
      _businessDate = $v.businessDate;
      _openedByName = $v.openedByName;
      _revenueAmount = $v.revenueAmount;
      _commissionAmount = $v.commissionAmount;
      _currency = $v.currency;
      _commission = $v.commission?.toBuilder();
      _paidAt = $v.paidAt;
      _payoutMethod = $v.payoutMethod;
      _payoutStatus = $v.payoutStatus;
      _cashMovementRequestId = $v.cashMovementRequestId;
      _transferReference = $v.transferReference;
      _voidReason = $v.voidReason;
      _note = $v.note;
      _revision = $v.revision;
      _workspacesCount = $v.workspacesCount;
      _warnings = $v.warnings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisit other) {
    _$v = other as _$VehicleVisit;
  }

  @override
  void update(void Function(VehicleVisitBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisit build() => _build();

  _$VehicleVisit _build() {
    _$VehicleVisit _$result;
    try {
      _$result = _$v ??
          _$VehicleVisit._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'VehicleVisit', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'VehicleVisit', 'branchId'),
            busOperator: _busOperator?.build(),
            plate: BuiltValueNullFieldError.checkNotNull(
                plate, r'VehicleVisit', 'plate'),
            vehicleType: BuiltValueNullFieldError.checkNotNull(
                vehicleType, r'VehicleVisit', 'vehicleType'),
            driverName: driverName,
            driverPhone: driverPhone,
            guestCount: BuiltValueNullFieldError.checkNotNull(
                guestCount, r'VehicleVisit', 'guestCount'),
            arrivedAt: BuiltValueNullFieldError.checkNotNull(
                arrivedAt, r'VehicleVisit', 'arrivedAt'),
            closesAt: BuiltValueNullFieldError.checkNotNull(
                closesAt, r'VehicleVisit', 'closesAt'),
            closedAt: closedAt,
            autoClosed: autoClosed,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'VehicleVisit', 'status'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'VehicleVisit', 'businessDate'),
            openedByName: openedByName,
            revenueAmount: revenueAmount,
            commissionAmount: commissionAmount,
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'VehicleVisit', 'currency'),
            commission: _commission?.build(),
            paidAt: paidAt,
            payoutMethod: payoutMethod,
            payoutStatus: payoutStatus,
            cashMovementRequestId: cashMovementRequestId,
            transferReference: transferReference,
            voidReason: voidReason,
            note: note,
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'VehicleVisit', 'revision'),
            workspacesCount: workspacesCount,
            warnings: _warnings?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'busOperator';
        _busOperator?.build();

        _$failedField = 'commission';
        _commission?.build();

        _$failedField = 'warnings';
        _warnings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VehicleVisit', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
