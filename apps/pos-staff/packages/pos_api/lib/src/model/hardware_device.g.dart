// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_device.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HardwareDeviceModeEnum _$hardwareDeviceModeEnum_kds =
    const HardwareDeviceModeEnum._('kds');
const HardwareDeviceModeEnum _$hardwareDeviceModeEnum_expo =
    const HardwareDeviceModeEnum._('expo');
const HardwareDeviceModeEnum _$hardwareDeviceModeEnum_printStation =
    const HardwareDeviceModeEnum._('printStation');

HardwareDeviceModeEnum _$hardwareDeviceModeEnumValueOf(String name) {
  switch (name) {
    case 'kds':
      return _$hardwareDeviceModeEnum_kds;
    case 'expo':
      return _$hardwareDeviceModeEnum_expo;
    case 'printStation':
      return _$hardwareDeviceModeEnum_printStation;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HardwareDeviceModeEnum> _$hardwareDeviceModeEnumValues =
    BuiltSet<HardwareDeviceModeEnum>(const <HardwareDeviceModeEnum>[
  _$hardwareDeviceModeEnum_kds,
  _$hardwareDeviceModeEnum_expo,
  _$hardwareDeviceModeEnum_printStation,
]);

Serializer<HardwareDeviceModeEnum> _$hardwareDeviceModeEnumSerializer =
    _$HardwareDeviceModeEnumSerializer();

class _$HardwareDeviceModeEnumSerializer
    implements PrimitiveSerializer<HardwareDeviceModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'kds': 'kds',
    'expo': 'expo',
    'printStation': 'print_station',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'kds': 'kds',
    'expo': 'expo',
    'print_station': 'printStation',
  };

  @override
  final Iterable<Type> types = const <Type>[HardwareDeviceModeEnum];
  @override
  final String wireName = 'HardwareDeviceModeEnum';

  @override
  Object serialize(Serializers serializers, HardwareDeviceModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HardwareDeviceModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HardwareDeviceModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$HardwareDevice extends HardwareDevice {
  @override
  final String id;
  @override
  final String name;
  @override
  final HardwareDeviceModeEnum mode;
  @override
  final String kitchenStationId;
  @override
  final DateTime lastSeenAt;
  @override
  final bool online;

  factory _$HardwareDevice([void Function(HardwareDeviceBuilder)? updates]) =>
      (HardwareDeviceBuilder()..update(updates))._build();

  _$HardwareDevice._(
      {required this.id,
      required this.name,
      required this.mode,
      required this.kitchenStationId,
      required this.lastSeenAt,
      required this.online})
      : super._();
  @override
  HardwareDevice rebuild(void Function(HardwareDeviceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareDeviceBuilder toBuilder() => HardwareDeviceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareDevice &&
        id == other.id &&
        name == other.name &&
        mode == other.mode &&
        kitchenStationId == other.kitchenStationId &&
        lastSeenAt == other.lastSeenAt &&
        online == other.online;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, online.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareDevice')
          ..add('id', id)
          ..add('name', name)
          ..add('mode', mode)
          ..add('kitchenStationId', kitchenStationId)
          ..add('lastSeenAt', lastSeenAt)
          ..add('online', online))
        .toString();
  }
}

class HardwareDeviceBuilder
    implements Builder<HardwareDevice, HardwareDeviceBuilder> {
  _$HardwareDevice? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  HardwareDeviceModeEnum? _mode;
  HardwareDeviceModeEnum? get mode => _$this._mode;
  set mode(HardwareDeviceModeEnum? mode) => _$this._mode = mode;

  String? _kitchenStationId;
  String? get kitchenStationId => _$this._kitchenStationId;
  set kitchenStationId(String? kitchenStationId) =>
      _$this._kitchenStationId = kitchenStationId;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  bool? _online;
  bool? get online => _$this._online;
  set online(bool? online) => _$this._online = online;

  HardwareDeviceBuilder() {
    HardwareDevice._defaults(this);
  }

  HardwareDeviceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _mode = $v.mode;
      _kitchenStationId = $v.kitchenStationId;
      _lastSeenAt = $v.lastSeenAt;
      _online = $v.online;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareDevice other) {
    _$v = other as _$HardwareDevice;
  }

  @override
  void update(void Function(HardwareDeviceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareDevice build() => _build();

  _$HardwareDevice _build() {
    final _$result = _$v ??
        _$HardwareDevice._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'HardwareDevice', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'HardwareDevice', 'name'),
          mode: BuiltValueNullFieldError.checkNotNull(
              mode, r'HardwareDevice', 'mode'),
          kitchenStationId: BuiltValueNullFieldError.checkNotNull(
              kitchenStationId, r'HardwareDevice', 'kitchenStationId'),
          lastSeenAt: BuiltValueNullFieldError.checkNotNull(
              lastSeenAt, r'HardwareDevice', 'lastSeenAt'),
          online: BuiltValueNullFieldError.checkNotNull(
              online, r'HardwareDevice', 'online'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
