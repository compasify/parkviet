// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_open_unit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OwnerOpenUnitStatusEnum _$ownerOpenUnitStatusEnum_editing =
    const OwnerOpenUnitStatusEnum._('editing');
const OwnerOpenUnitStatusEnum _$ownerOpenUnitStatusEnum_parked =
    const OwnerOpenUnitStatusEnum._('parked');

OwnerOpenUnitStatusEnum _$ownerOpenUnitStatusEnumValueOf(String name) {
  switch (name) {
    case 'editing':
      return _$ownerOpenUnitStatusEnum_editing;
    case 'parked':
      return _$ownerOpenUnitStatusEnum_parked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OwnerOpenUnitStatusEnum> _$ownerOpenUnitStatusEnumValues =
    BuiltSet<OwnerOpenUnitStatusEnum>(const <OwnerOpenUnitStatusEnum>[
  _$ownerOpenUnitStatusEnum_editing,
  _$ownerOpenUnitStatusEnum_parked,
]);

Serializer<OwnerOpenUnitStatusEnum> _$ownerOpenUnitStatusEnumSerializer =
    _$OwnerOpenUnitStatusEnumSerializer();

class _$OwnerOpenUnitStatusEnumSerializer
    implements PrimitiveSerializer<OwnerOpenUnitStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editing': 'editing',
    'parked': 'parked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editing': 'editing',
    'parked': 'parked',
  };

  @override
  final Iterable<Type> types = const <Type>[OwnerOpenUnitStatusEnum];
  @override
  final String wireName = 'OwnerOpenUnitStatusEnum';

  @override
  Object serialize(Serializers serializers, OwnerOpenUnitStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OwnerOpenUnitStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OwnerOpenUnitStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OwnerOpenUnit extends OwnerOpenUnit {
  @override
  final String workspaceId;
  @override
  final String? resourceId;
  @override
  final String? label;
  @override
  final String? serviceMode;
  @override
  final OwnerOpenUnitStatusEnum status;
  @override
  final int? guestCount;
  @override
  final DateTime openedAt;
  @override
  final int minutesOpen;
  @override
  final String total;
  @override
  final int kitchenWaiting;
  @override
  final bool kitchenLate;

  factory _$OwnerOpenUnit([void Function(OwnerOpenUnitBuilder)? updates]) =>
      (OwnerOpenUnitBuilder()..update(updates))._build();

  _$OwnerOpenUnit._(
      {required this.workspaceId,
      this.resourceId,
      this.label,
      this.serviceMode,
      required this.status,
      this.guestCount,
      required this.openedAt,
      required this.minutesOpen,
      required this.total,
      required this.kitchenWaiting,
      required this.kitchenLate})
      : super._();
  @override
  OwnerOpenUnit rebuild(void Function(OwnerOpenUnitBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerOpenUnitBuilder toBuilder() => OwnerOpenUnitBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerOpenUnit &&
        workspaceId == other.workspaceId &&
        resourceId == other.resourceId &&
        label == other.label &&
        serviceMode == other.serviceMode &&
        status == other.status &&
        guestCount == other.guestCount &&
        openedAt == other.openedAt &&
        minutesOpen == other.minutesOpen &&
        total == other.total &&
        kitchenWaiting == other.kitchenWaiting &&
        kitchenLate == other.kitchenLate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jc(_$hash, minutesOpen.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, kitchenWaiting.hashCode);
    _$hash = $jc(_$hash, kitchenLate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerOpenUnit')
          ..add('workspaceId', workspaceId)
          ..add('resourceId', resourceId)
          ..add('label', label)
          ..add('serviceMode', serviceMode)
          ..add('status', status)
          ..add('guestCount', guestCount)
          ..add('openedAt', openedAt)
          ..add('minutesOpen', minutesOpen)
          ..add('total', total)
          ..add('kitchenWaiting', kitchenWaiting)
          ..add('kitchenLate', kitchenLate))
        .toString();
  }
}

class OwnerOpenUnitBuilder
    implements Builder<OwnerOpenUnit, OwnerOpenUnitBuilder> {
  _$OwnerOpenUnit? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  OwnerOpenUnitStatusEnum? _status;
  OwnerOpenUnitStatusEnum? get status => _$this._status;
  set status(OwnerOpenUnitStatusEnum? status) => _$this._status = status;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  DateTime? _openedAt;
  DateTime? get openedAt => _$this._openedAt;
  set openedAt(DateTime? openedAt) => _$this._openedAt = openedAt;

  int? _minutesOpen;
  int? get minutesOpen => _$this._minutesOpen;
  set minutesOpen(int? minutesOpen) => _$this._minutesOpen = minutesOpen;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  int? _kitchenWaiting;
  int? get kitchenWaiting => _$this._kitchenWaiting;
  set kitchenWaiting(int? kitchenWaiting) =>
      _$this._kitchenWaiting = kitchenWaiting;

  bool? _kitchenLate;
  bool? get kitchenLate => _$this._kitchenLate;
  set kitchenLate(bool? kitchenLate) => _$this._kitchenLate = kitchenLate;

  OwnerOpenUnitBuilder() {
    OwnerOpenUnit._defaults(this);
  }

  OwnerOpenUnitBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _resourceId = $v.resourceId;
      _label = $v.label;
      _serviceMode = $v.serviceMode;
      _status = $v.status;
      _guestCount = $v.guestCount;
      _openedAt = $v.openedAt;
      _minutesOpen = $v.minutesOpen;
      _total = $v.total;
      _kitchenWaiting = $v.kitchenWaiting;
      _kitchenLate = $v.kitchenLate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerOpenUnit other) {
    _$v = other as _$OwnerOpenUnit;
  }

  @override
  void update(void Function(OwnerOpenUnitBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerOpenUnit build() => _build();

  _$OwnerOpenUnit _build() {
    final _$result = _$v ??
        _$OwnerOpenUnit._(
          workspaceId: BuiltValueNullFieldError.checkNotNull(
              workspaceId, r'OwnerOpenUnit', 'workspaceId'),
          resourceId: resourceId,
          label: label,
          serviceMode: serviceMode,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'OwnerOpenUnit', 'status'),
          guestCount: guestCount,
          openedAt: BuiltValueNullFieldError.checkNotNull(
              openedAt, r'OwnerOpenUnit', 'openedAt'),
          minutesOpen: BuiltValueNullFieldError.checkNotNull(
              minutesOpen, r'OwnerOpenUnit', 'minutesOpen'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'OwnerOpenUnit', 'total'),
          kitchenWaiting: BuiltValueNullFieldError.checkNotNull(
              kitchenWaiting, r'OwnerOpenUnit', 'kitchenWaiting'),
          kitchenLate: BuiltValueNullFieldError.checkNotNull(
              kitchenLate, r'OwnerOpenUnit', 'kitchenLate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
