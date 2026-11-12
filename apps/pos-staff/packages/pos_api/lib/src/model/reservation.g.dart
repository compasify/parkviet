// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationStatusEnum _$reservationStatusEnum_booked =
    const ReservationStatusEnum._('booked');
const ReservationStatusEnum _$reservationStatusEnum_seated =
    const ReservationStatusEnum._('seated');
const ReservationStatusEnum _$reservationStatusEnum_completed =
    const ReservationStatusEnum._('completed');
const ReservationStatusEnum _$reservationStatusEnum_noShow =
    const ReservationStatusEnum._('noShow');
const ReservationStatusEnum _$reservationStatusEnum_canceled =
    const ReservationStatusEnum._('canceled');

ReservationStatusEnum _$reservationStatusEnumValueOf(String name) {
  switch (name) {
    case 'booked':
      return _$reservationStatusEnum_booked;
    case 'seated':
      return _$reservationStatusEnum_seated;
    case 'completed':
      return _$reservationStatusEnum_completed;
    case 'noShow':
      return _$reservationStatusEnum_noShow;
    case 'canceled':
      return _$reservationStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationStatusEnum> _$reservationStatusEnumValues =
    BuiltSet<ReservationStatusEnum>(const <ReservationStatusEnum>[
  _$reservationStatusEnum_booked,
  _$reservationStatusEnum_seated,
  _$reservationStatusEnum_completed,
  _$reservationStatusEnum_noShow,
  _$reservationStatusEnum_canceled,
]);

const ReservationSource_Enum _$reservationSourceEnum_phone =
    const ReservationSource_Enum._('phone');
const ReservationSource_Enum _$reservationSourceEnum_walkIn =
    const ReservationSource_Enum._('walkIn');
const ReservationSource_Enum _$reservationSourceEnum_online =
    const ReservationSource_Enum._('online');

ReservationSource_Enum _$reservationSourceEnumValueOf(String name) {
  switch (name) {
    case 'phone':
      return _$reservationSourceEnum_phone;
    case 'walkIn':
      return _$reservationSourceEnum_walkIn;
    case 'online':
      return _$reservationSourceEnum_online;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationSource_Enum> _$reservationSourceEnumValues =
    BuiltSet<ReservationSource_Enum>(const <ReservationSource_Enum>[
  _$reservationSourceEnum_phone,
  _$reservationSourceEnum_walkIn,
  _$reservationSourceEnum_online,
]);

Serializer<ReservationStatusEnum> _$reservationStatusEnumSerializer =
    _$ReservationStatusEnumSerializer();
Serializer<ReservationSource_Enum> _$reservationSourceEnumSerializer =
    _$ReservationSource_EnumSerializer();

class _$ReservationStatusEnumSerializer
    implements PrimitiveSerializer<ReservationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'booked': 'booked',
    'seated': 'seated',
    'completed': 'completed',
    'noShow': 'no_show',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'booked': 'booked',
    'seated': 'seated',
    'completed': 'completed',
    'no_show': 'noShow',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationStatusEnum];
  @override
  final String wireName = 'ReservationStatusEnum';

  @override
  Object serialize(Serializers serializers, ReservationStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationSource_EnumSerializer
    implements PrimitiveSerializer<ReservationSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'walkIn': 'walk_in',
    'online': 'online',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'walk_in': 'walkIn',
    'online': 'online',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationSource_Enum];
  @override
  final String wireName = 'ReservationSource_Enum';

  @override
  Object serialize(Serializers serializers, ReservationSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationSource_Enum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Reservation extends Reservation {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final ReservationStatusEnum status;
  @override
  final ReservationSource_Enum source_;
  @override
  final String guestName;
  @override
  final String? phone;
  @override
  final int partySize;
  @override
  final String? note;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final int revision;
  @override
  final String? customerId;
  @override
  final String? workspaceId;
  @override
  final DateTime? confirmedAt;
  @override
  final DateTime? seatedAt;
  @override
  final DateTime? canceledAt;
  @override
  final BuiltList<ResourceRef> resources;
  @override
  final BuiltList<ReservationDeposit> deposits;
  @override
  final String depositHeld;
  @override
  final String? feeWorkspaceId;

  factory _$Reservation([void Function(ReservationBuilder)? updates]) =>
      (ReservationBuilder()..update(updates))._build();

  _$Reservation._(
      {required this.id,
      required this.branchId,
      required this.status,
      required this.source_,
      required this.guestName,
      this.phone,
      required this.partySize,
      this.note,
      required this.startsAt,
      required this.endsAt,
      required this.revision,
      this.customerId,
      this.workspaceId,
      this.confirmedAt,
      this.seatedAt,
      this.canceledAt,
      required this.resources,
      required this.deposits,
      required this.depositHeld,
      this.feeWorkspaceId})
      : super._();
  @override
  Reservation rebuild(void Function(ReservationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationBuilder toBuilder() => ReservationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Reservation &&
        id == other.id &&
        branchId == other.branchId &&
        status == other.status &&
        source_ == other.source_ &&
        guestName == other.guestName &&
        phone == other.phone &&
        partySize == other.partySize &&
        note == other.note &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        revision == other.revision &&
        customerId == other.customerId &&
        workspaceId == other.workspaceId &&
        confirmedAt == other.confirmedAt &&
        seatedAt == other.seatedAt &&
        canceledAt == other.canceledAt &&
        resources == other.resources &&
        deposits == other.deposits &&
        depositHeld == other.depositHeld &&
        feeWorkspaceId == other.feeWorkspaceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, partySize.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, customerId.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, confirmedAt.hashCode);
    _$hash = $jc(_$hash, seatedAt.hashCode);
    _$hash = $jc(_$hash, canceledAt.hashCode);
    _$hash = $jc(_$hash, resources.hashCode);
    _$hash = $jc(_$hash, deposits.hashCode);
    _$hash = $jc(_$hash, depositHeld.hashCode);
    _$hash = $jc(_$hash, feeWorkspaceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Reservation')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('status', status)
          ..add('source_', source_)
          ..add('guestName', guestName)
          ..add('phone', phone)
          ..add('partySize', partySize)
          ..add('note', note)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('revision', revision)
          ..add('customerId', customerId)
          ..add('workspaceId', workspaceId)
          ..add('confirmedAt', confirmedAt)
          ..add('seatedAt', seatedAt)
          ..add('canceledAt', canceledAt)
          ..add('resources', resources)
          ..add('deposits', deposits)
          ..add('depositHeld', depositHeld)
          ..add('feeWorkspaceId', feeWorkspaceId))
        .toString();
  }
}

class ReservationBuilder implements Builder<Reservation, ReservationBuilder> {
  _$Reservation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  ReservationStatusEnum? _status;
  ReservationStatusEnum? get status => _$this._status;
  set status(ReservationStatusEnum? status) => _$this._status = status;

  ReservationSource_Enum? _source_;
  ReservationSource_Enum? get source_ => _$this._source_;
  set source_(ReservationSource_Enum? source_) => _$this._source_ = source_;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  int? _partySize;
  int? get partySize => _$this._partySize;
  set partySize(int? partySize) => _$this._partySize = partySize;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _customerId;
  String? get customerId => _$this._customerId;
  set customerId(String? customerId) => _$this._customerId = customerId;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  DateTime? _confirmedAt;
  DateTime? get confirmedAt => _$this._confirmedAt;
  set confirmedAt(DateTime? confirmedAt) => _$this._confirmedAt = confirmedAt;

  DateTime? _seatedAt;
  DateTime? get seatedAt => _$this._seatedAt;
  set seatedAt(DateTime? seatedAt) => _$this._seatedAt = seatedAt;

  DateTime? _canceledAt;
  DateTime? get canceledAt => _$this._canceledAt;
  set canceledAt(DateTime? canceledAt) => _$this._canceledAt = canceledAt;

  ListBuilder<ResourceRef>? _resources;
  ListBuilder<ResourceRef> get resources =>
      _$this._resources ??= ListBuilder<ResourceRef>();
  set resources(ListBuilder<ResourceRef>? resources) =>
      _$this._resources = resources;

  ListBuilder<ReservationDeposit>? _deposits;
  ListBuilder<ReservationDeposit> get deposits =>
      _$this._deposits ??= ListBuilder<ReservationDeposit>();
  set deposits(ListBuilder<ReservationDeposit>? deposits) =>
      _$this._deposits = deposits;

  String? _depositHeld;
  String? get depositHeld => _$this._depositHeld;
  set depositHeld(String? depositHeld) => _$this._depositHeld = depositHeld;

  String? _feeWorkspaceId;
  String? get feeWorkspaceId => _$this._feeWorkspaceId;
  set feeWorkspaceId(String? feeWorkspaceId) =>
      _$this._feeWorkspaceId = feeWorkspaceId;

  ReservationBuilder() {
    Reservation._defaults(this);
  }

  ReservationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _status = $v.status;
      _source_ = $v.source_;
      _guestName = $v.guestName;
      _phone = $v.phone;
      _partySize = $v.partySize;
      _note = $v.note;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _revision = $v.revision;
      _customerId = $v.customerId;
      _workspaceId = $v.workspaceId;
      _confirmedAt = $v.confirmedAt;
      _seatedAt = $v.seatedAt;
      _canceledAt = $v.canceledAt;
      _resources = $v.resources.toBuilder();
      _deposits = $v.deposits.toBuilder();
      _depositHeld = $v.depositHeld;
      _feeWorkspaceId = $v.feeWorkspaceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Reservation other) {
    _$v = other as _$Reservation;
  }

  @override
  void update(void Function(ReservationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Reservation build() => _build();

  _$Reservation _build() {
    _$Reservation _$result;
    try {
      _$result = _$v ??
          _$Reservation._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Reservation', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'Reservation', 'branchId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Reservation', 'status'),
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'Reservation', 'source_'),
            guestName: BuiltValueNullFieldError.checkNotNull(
                guestName, r'Reservation', 'guestName'),
            phone: phone,
            partySize: BuiltValueNullFieldError.checkNotNull(
                partySize, r'Reservation', 'partySize'),
            note: note,
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'Reservation', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'Reservation', 'endsAt'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'Reservation', 'revision'),
            customerId: customerId,
            workspaceId: workspaceId,
            confirmedAt: confirmedAt,
            seatedAt: seatedAt,
            canceledAt: canceledAt,
            resources: resources.build(),
            deposits: deposits.build(),
            depositHeld: BuiltValueNullFieldError.checkNotNull(
                depositHeld, r'Reservation', 'depositHeld'),
            feeWorkspaceId: feeWorkspaceId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'resources';
        resources.build();
        _$failedField = 'deposits';
        deposits.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Reservation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
