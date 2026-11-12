// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceModeEnum _$deviceModeEnum_waiter = const DeviceModeEnum._('waiter');
const DeviceModeEnum _$deviceModeEnum_kds = const DeviceModeEnum._('kds');
const DeviceModeEnum _$deviceModeEnum_expo = const DeviceModeEnum._('expo');
const DeviceModeEnum _$deviceModeEnum_kiosk = const DeviceModeEnum._('kiosk');
const DeviceModeEnum _$deviceModeEnum_printStation =
    const DeviceModeEnum._('printStation');
const DeviceModeEnum _$deviceModeEnum_owner = const DeviceModeEnum._('owner');

DeviceModeEnum _$deviceModeEnumValueOf(String name) {
  switch (name) {
    case 'waiter':
      return _$deviceModeEnum_waiter;
    case 'kds':
      return _$deviceModeEnum_kds;
    case 'expo':
      return _$deviceModeEnum_expo;
    case 'kiosk':
      return _$deviceModeEnum_kiosk;
    case 'printStation':
      return _$deviceModeEnum_printStation;
    case 'owner':
      return _$deviceModeEnum_owner;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceModeEnum> _$deviceModeEnumValues =
    BuiltSet<DeviceModeEnum>(const <DeviceModeEnum>[
  _$deviceModeEnum_waiter,
  _$deviceModeEnum_kds,
  _$deviceModeEnum_expo,
  _$deviceModeEnum_kiosk,
  _$deviceModeEnum_printStation,
  _$deviceModeEnum_owner,
]);

const DeviceStatusEnum _$deviceStatusEnum_active =
    const DeviceStatusEnum._('active');
const DeviceStatusEnum _$deviceStatusEnum_revoked =
    const DeviceStatusEnum._('revoked');

DeviceStatusEnum _$deviceStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$deviceStatusEnum_active;
    case 'revoked':
      return _$deviceStatusEnum_revoked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceStatusEnum> _$deviceStatusEnumValues =
    BuiltSet<DeviceStatusEnum>(const <DeviceStatusEnum>[
  _$deviceStatusEnum_active,
  _$deviceStatusEnum_revoked,
]);

Serializer<DeviceModeEnum> _$deviceModeEnumSerializer =
    _$DeviceModeEnumSerializer();
Serializer<DeviceStatusEnum> _$deviceStatusEnumSerializer =
    _$DeviceStatusEnumSerializer();

class _$DeviceModeEnumSerializer
    implements PrimitiveSerializer<DeviceModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'waiter': 'waiter',
    'kds': 'kds',
    'expo': 'expo',
    'kiosk': 'kiosk',
    'printStation': 'print_station',
    'owner': 'owner',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'waiter': 'waiter',
    'kds': 'kds',
    'expo': 'expo',
    'kiosk': 'kiosk',
    'print_station': 'printStation',
    'owner': 'owner',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceModeEnum];
  @override
  final String wireName = 'DeviceModeEnum';

  @override
  Object serialize(Serializers serializers, DeviceModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceStatusEnumSerializer
    implements PrimitiveSerializer<DeviceStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'revoked': 'revoked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'revoked': 'revoked',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceStatusEnum];
  @override
  final String wireName = 'DeviceStatusEnum';

  @override
  Object serialize(Serializers serializers, DeviceStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Device extends Device {
  @override
  final String id;
  @override
  final String name;
  @override
  final DeviceModeEnum mode;
  @override
  final DeviceStatusEnum status;
  @override
  final String branchId;
  @override
  final String? platform;
  @override
  final String? kitchenStationId;
  @override
  final String? lastSeenAt;

  factory _$Device([void Function(DeviceBuilder)? updates]) =>
      (DeviceBuilder()..update(updates))._build();

  _$Device._(
      {required this.id,
      required this.name,
      required this.mode,
      required this.status,
      required this.branchId,
      this.platform,
      this.kitchenStationId,
      this.lastSeenAt})
      : super._();
  @override
  Device rebuild(void Function(DeviceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceBuilder toBuilder() => DeviceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Device &&
        id == other.id &&
        name == other.name &&
        mode == other.mode &&
        status == other.status &&
        branchId == other.branchId &&
        platform == other.platform &&
        kitchenStationId == other.kitchenStationId &&
        lastSeenAt == other.lastSeenAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Device')
          ..add('id', id)
          ..add('name', name)
          ..add('mode', mode)
          ..add('status', status)
          ..add('branchId', branchId)
          ..add('platform', platform)
          ..add('kitchenStationId', kitchenStationId)
          ..add('lastSeenAt', lastSeenAt))
        .toString();
  }
}

class DeviceBuilder implements Builder<Device, DeviceBuilder> {
  _$Device? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DeviceModeEnum? _mode;
  DeviceModeEnum? get mode => _$this._mode;
  set mode(DeviceModeEnum? mode) => _$this._mode = mode;

  DeviceStatusEnum? _status;
  DeviceStatusEnum? get status => _$this._status;
  set status(DeviceStatusEnum? status) => _$this._status = status;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  String? _kitchenStationId;
  String? get kitchenStationId => _$this._kitchenStationId;
  set kitchenStationId(String? kitchenStationId) =>
      _$this._kitchenStationId = kitchenStationId;

  String? _lastSeenAt;
  String? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(String? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DeviceBuilder() {
    Device._defaults(this);
  }

  DeviceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _mode = $v.mode;
      _status = $v.status;
      _branchId = $v.branchId;
      _platform = $v.platform;
      _kitchenStationId = $v.kitchenStationId;
      _lastSeenAt = $v.lastSeenAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Device other) {
    _$v = other as _$Device;
  }

  @override
  void update(void Function(DeviceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Device build() => _build();

  _$Device _build() {
    final _$result = _$v ??
        _$Device._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Device', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Device', 'name'),
          mode: BuiltValueNullFieldError.checkNotNull(mode, r'Device', 'mode'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Device', 'status'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'Device', 'branchId'),
          platform: platform,
          kitchenStationId: kitchenStationId,
          lastSeenAt: lastSeenAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
