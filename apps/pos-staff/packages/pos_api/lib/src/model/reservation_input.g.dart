// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationInputSource_Enum _$reservationInputSourceEnum_phone =
    const ReservationInputSource_Enum._('phone');
const ReservationInputSource_Enum _$reservationInputSourceEnum_walkIn =
    const ReservationInputSource_Enum._('walkIn');
const ReservationInputSource_Enum _$reservationInputSourceEnum_online =
    const ReservationInputSource_Enum._('online');

ReservationInputSource_Enum _$reservationInputSourceEnumValueOf(String name) {
  switch (name) {
    case 'phone':
      return _$reservationInputSourceEnum_phone;
    case 'walkIn':
      return _$reservationInputSourceEnum_walkIn;
    case 'online':
      return _$reservationInputSourceEnum_online;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationInputSource_Enum> _$reservationInputSourceEnumValues =
    BuiltSet<ReservationInputSource_Enum>(const <ReservationInputSource_Enum>[
  _$reservationInputSourceEnum_phone,
  _$reservationInputSourceEnum_walkIn,
  _$reservationInputSourceEnum_online,
]);

Serializer<ReservationInputSource_Enum> _$reservationInputSourceEnumSerializer =
    _$ReservationInputSource_EnumSerializer();

class _$ReservationInputSource_EnumSerializer
    implements PrimitiveSerializer<ReservationInputSource_Enum> {
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
  final Iterable<Type> types = const <Type>[ReservationInputSource_Enum];
  @override
  final String wireName = 'ReservationInputSource_Enum';

  @override
  Object serialize(Serializers serializers, ReservationInputSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationInputSource_Enum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationInputSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationInput extends ReservationInput {
  @override
  final String branchId;
  @override
  final BuiltList<String> resourceIds;
  @override
  final String guestName;
  @override
  final String? phone;
  @override
  final int partySize;
  @override
  final DateTime startsAt;
  @override
  final DateTime? endsAt;
  @override
  final ReservationInputSource_Enum? source_;
  @override
  final String? note;
  @override
  final String? customerId;

  factory _$ReservationInput(
          [void Function(ReservationInputBuilder)? updates]) =>
      (ReservationInputBuilder()..update(updates))._build();

  _$ReservationInput._(
      {required this.branchId,
      required this.resourceIds,
      required this.guestName,
      this.phone,
      required this.partySize,
      required this.startsAt,
      this.endsAt,
      this.source_,
      this.note,
      this.customerId})
      : super._();
  @override
  ReservationInput rebuild(void Function(ReservationInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationInputBuilder toBuilder() =>
      ReservationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationInput &&
        branchId == other.branchId &&
        resourceIds == other.resourceIds &&
        guestName == other.guestName &&
        phone == other.phone &&
        partySize == other.partySize &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        source_ == other.source_ &&
        note == other.note &&
        customerId == other.customerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, resourceIds.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, partySize.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, customerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationInput')
          ..add('branchId', branchId)
          ..add('resourceIds', resourceIds)
          ..add('guestName', guestName)
          ..add('phone', phone)
          ..add('partySize', partySize)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('source_', source_)
          ..add('note', note)
          ..add('customerId', customerId))
        .toString();
  }
}

class ReservationInputBuilder
    implements Builder<ReservationInput, ReservationInputBuilder> {
  _$ReservationInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  ListBuilder<String>? _resourceIds;
  ListBuilder<String> get resourceIds =>
      _$this._resourceIds ??= ListBuilder<String>();
  set resourceIds(ListBuilder<String>? resourceIds) =>
      _$this._resourceIds = resourceIds;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  int? _partySize;
  int? get partySize => _$this._partySize;
  set partySize(int? partySize) => _$this._partySize = partySize;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  ReservationInputSource_Enum? _source_;
  ReservationInputSource_Enum? get source_ => _$this._source_;
  set source_(ReservationInputSource_Enum? source_) =>
      _$this._source_ = source_;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _customerId;
  String? get customerId => _$this._customerId;
  set customerId(String? customerId) => _$this._customerId = customerId;

  ReservationInputBuilder() {
    ReservationInput._defaults(this);
  }

  ReservationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _resourceIds = $v.resourceIds.toBuilder();
      _guestName = $v.guestName;
      _phone = $v.phone;
      _partySize = $v.partySize;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _source_ = $v.source_;
      _note = $v.note;
      _customerId = $v.customerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationInput other) {
    _$v = other as _$ReservationInput;
  }

  @override
  void update(void Function(ReservationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationInput build() => _build();

  _$ReservationInput _build() {
    _$ReservationInput _$result;
    try {
      _$result = _$v ??
          _$ReservationInput._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'ReservationInput', 'branchId'),
            resourceIds: resourceIds.build(),
            guestName: BuiltValueNullFieldError.checkNotNull(
                guestName, r'ReservationInput', 'guestName'),
            phone: phone,
            partySize: BuiltValueNullFieldError.checkNotNull(
                partySize, r'ReservationInput', 'partySize'),
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'ReservationInput', 'startsAt'),
            endsAt: endsAt,
            source_: source_,
            note: note,
            customerId: customerId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'resourceIds';
        resourceIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
