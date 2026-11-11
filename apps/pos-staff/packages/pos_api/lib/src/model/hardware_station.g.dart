// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_station.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HardwareStationKindEnum _$hardwareStationKindEnum_prep =
    const HardwareStationKindEnum._('prep');
const HardwareStationKindEnum _$hardwareStationKindEnum_bar =
    const HardwareStationKindEnum._('bar');
const HardwareStationKindEnum _$hardwareStationKindEnum_expo =
    const HardwareStationKindEnum._('expo');

HardwareStationKindEnum _$hardwareStationKindEnumValueOf(String name) {
  switch (name) {
    case 'prep':
      return _$hardwareStationKindEnum_prep;
    case 'bar':
      return _$hardwareStationKindEnum_bar;
    case 'expo':
      return _$hardwareStationKindEnum_expo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HardwareStationKindEnum> _$hardwareStationKindEnumValues =
    BuiltSet<HardwareStationKindEnum>(const <HardwareStationKindEnum>[
  _$hardwareStationKindEnum_prep,
  _$hardwareStationKindEnum_bar,
  _$hardwareStationKindEnum_expo,
]);

Serializer<HardwareStationKindEnum> _$hardwareStationKindEnumSerializer =
    _$HardwareStationKindEnumSerializer();

class _$HardwareStationKindEnumSerializer
    implements PrimitiveSerializer<HardwareStationKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'prep': 'prep',
    'bar': 'bar',
    'expo': 'expo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'prep': 'prep',
    'bar': 'bar',
    'expo': 'expo',
  };

  @override
  final Iterable<Type> types = const <Type>[HardwareStationKindEnum];
  @override
  final String wireName = 'HardwareStationKindEnum';

  @override
  Object serialize(Serializers serializers, HardwareStationKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HardwareStationKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HardwareStationKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$HardwareStation extends HardwareStation {
  @override
  final String id;
  @override
  final String name;
  @override
  final HardwareStationKindEnum kind;
  @override
  final String printerId;
  @override
  final int kdsDevices;
  @override
  final bool ok;

  factory _$HardwareStation([void Function(HardwareStationBuilder)? updates]) =>
      (HardwareStationBuilder()..update(updates))._build();

  _$HardwareStation._(
      {required this.id,
      required this.name,
      required this.kind,
      required this.printerId,
      required this.kdsDevices,
      required this.ok})
      : super._();
  @override
  HardwareStation rebuild(void Function(HardwareStationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareStationBuilder toBuilder() => HardwareStationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareStation &&
        id == other.id &&
        name == other.name &&
        kind == other.kind &&
        printerId == other.printerId &&
        kdsDevices == other.kdsDevices &&
        ok == other.ok;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, kdsDevices.hashCode);
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareStation')
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('printerId', printerId)
          ..add('kdsDevices', kdsDevices)
          ..add('ok', ok))
        .toString();
  }
}

class HardwareStationBuilder
    implements Builder<HardwareStation, HardwareStationBuilder> {
  _$HardwareStation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  HardwareStationKindEnum? _kind;
  HardwareStationKindEnum? get kind => _$this._kind;
  set kind(HardwareStationKindEnum? kind) => _$this._kind = kind;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  int? _kdsDevices;
  int? get kdsDevices => _$this._kdsDevices;
  set kdsDevices(int? kdsDevices) => _$this._kdsDevices = kdsDevices;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  HardwareStationBuilder() {
    HardwareStation._defaults(this);
  }

  HardwareStationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _kind = $v.kind;
      _printerId = $v.printerId;
      _kdsDevices = $v.kdsDevices;
      _ok = $v.ok;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareStation other) {
    _$v = other as _$HardwareStation;
  }

  @override
  void update(void Function(HardwareStationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareStation build() => _build();

  _$HardwareStation _build() {
    final _$result = _$v ??
        _$HardwareStation._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'HardwareStation', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'HardwareStation', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'HardwareStation', 'kind'),
          printerId: BuiltValueNullFieldError.checkNotNull(
              printerId, r'HardwareStation', 'printerId'),
          kdsDevices: BuiltValueNullFieldError.checkNotNull(
              kdsDevices, r'HardwareStation', 'kdsDevices'),
          ok: BuiltValueNullFieldError.checkNotNull(
              ok, r'HardwareStation', 'ok'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
