// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_station.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KitchenStationKindEnum _$kitchenStationKindEnum_prep =
    const KitchenStationKindEnum._('prep');
const KitchenStationKindEnum _$kitchenStationKindEnum_bar =
    const KitchenStationKindEnum._('bar');
const KitchenStationKindEnum _$kitchenStationKindEnum_expo =
    const KitchenStationKindEnum._('expo');

KitchenStationKindEnum _$kitchenStationKindEnumValueOf(String name) {
  switch (name) {
    case 'prep':
      return _$kitchenStationKindEnum_prep;
    case 'bar':
      return _$kitchenStationKindEnum_bar;
    case 'expo':
      return _$kitchenStationKindEnum_expo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenStationKindEnum> _$kitchenStationKindEnumValues =
    BuiltSet<KitchenStationKindEnum>(const <KitchenStationKindEnum>[
  _$kitchenStationKindEnum_prep,
  _$kitchenStationKindEnum_bar,
  _$kitchenStationKindEnum_expo,
]);

Serializer<KitchenStationKindEnum> _$kitchenStationKindEnumSerializer =
    _$KitchenStationKindEnumSerializer();

class _$KitchenStationKindEnumSerializer
    implements PrimitiveSerializer<KitchenStationKindEnum> {
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
  final Iterable<Type> types = const <Type>[KitchenStationKindEnum];
  @override
  final String wireName = 'KitchenStationKindEnum';

  @override
  Object serialize(Serializers serializers, KitchenStationKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenStationKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenStationKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KitchenStation extends KitchenStation {
  @override
  final String? expoStationId;
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String name;
  @override
  final KitchenStationKindEnum kind;
  @override
  final String? printerId;
  @override
  final String? printerName;
  @override
  final bool kdsEnabled;
  @override
  final bool isDefault;
  @override
  final int warnAfterMinutes;
  @override
  final int lateAfterMinutes;
  @override
  final int position;
  @override
  final bool active;

  factory _$KitchenStation([void Function(KitchenStationBuilder)? updates]) =>
      (KitchenStationBuilder()..update(updates))._build();

  _$KitchenStation._(
      {this.expoStationId,
      required this.id,
      required this.branchId,
      required this.name,
      required this.kind,
      this.printerId,
      this.printerName,
      required this.kdsEnabled,
      required this.isDefault,
      required this.warnAfterMinutes,
      required this.lateAfterMinutes,
      required this.position,
      required this.active})
      : super._();
  @override
  KitchenStation rebuild(void Function(KitchenStationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenStationBuilder toBuilder() => KitchenStationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenStation &&
        expoStationId == other.expoStationId &&
        id == other.id &&
        branchId == other.branchId &&
        name == other.name &&
        kind == other.kind &&
        printerId == other.printerId &&
        printerName == other.printerName &&
        kdsEnabled == other.kdsEnabled &&
        isDefault == other.isDefault &&
        warnAfterMinutes == other.warnAfterMinutes &&
        lateAfterMinutes == other.lateAfterMinutes &&
        position == other.position &&
        active == other.active;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expoStationId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, printerName.hashCode);
    _$hash = $jc(_$hash, kdsEnabled.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, warnAfterMinutes.hashCode);
    _$hash = $jc(_$hash, lateAfterMinutes.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenStation')
          ..add('expoStationId', expoStationId)
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('name', name)
          ..add('kind', kind)
          ..add('printerId', printerId)
          ..add('printerName', printerName)
          ..add('kdsEnabled', kdsEnabled)
          ..add('isDefault', isDefault)
          ..add('warnAfterMinutes', warnAfterMinutes)
          ..add('lateAfterMinutes', lateAfterMinutes)
          ..add('position', position)
          ..add('active', active))
        .toString();
  }
}

class KitchenStationBuilder
    implements Builder<KitchenStation, KitchenStationBuilder> {
  _$KitchenStation? _$v;

  String? _expoStationId;
  String? get expoStationId => _$this._expoStationId;
  set expoStationId(String? expoStationId) =>
      _$this._expoStationId = expoStationId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  KitchenStationKindEnum? _kind;
  KitchenStationKindEnum? get kind => _$this._kind;
  set kind(KitchenStationKindEnum? kind) => _$this._kind = kind;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  String? _printerName;
  String? get printerName => _$this._printerName;
  set printerName(String? printerName) => _$this._printerName = printerName;

  bool? _kdsEnabled;
  bool? get kdsEnabled => _$this._kdsEnabled;
  set kdsEnabled(bool? kdsEnabled) => _$this._kdsEnabled = kdsEnabled;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  int? _warnAfterMinutes;
  int? get warnAfterMinutes => _$this._warnAfterMinutes;
  set warnAfterMinutes(int? warnAfterMinutes) =>
      _$this._warnAfterMinutes = warnAfterMinutes;

  int? _lateAfterMinutes;
  int? get lateAfterMinutes => _$this._lateAfterMinutes;
  set lateAfterMinutes(int? lateAfterMinutes) =>
      _$this._lateAfterMinutes = lateAfterMinutes;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  KitchenStationBuilder() {
    KitchenStation._defaults(this);
  }

  KitchenStationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expoStationId = $v.expoStationId;
      _id = $v.id;
      _branchId = $v.branchId;
      _name = $v.name;
      _kind = $v.kind;
      _printerId = $v.printerId;
      _printerName = $v.printerName;
      _kdsEnabled = $v.kdsEnabled;
      _isDefault = $v.isDefault;
      _warnAfterMinutes = $v.warnAfterMinutes;
      _lateAfterMinutes = $v.lateAfterMinutes;
      _position = $v.position;
      _active = $v.active;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenStation other) {
    _$v = other as _$KitchenStation;
  }

  @override
  void update(void Function(KitchenStationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenStation build() => _build();

  _$KitchenStation _build() {
    final _$result = _$v ??
        _$KitchenStation._(
          expoStationId: expoStationId,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KitchenStation', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'KitchenStation', 'branchId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenStation', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'KitchenStation', 'kind'),
          printerId: printerId,
          printerName: printerName,
          kdsEnabled: BuiltValueNullFieldError.checkNotNull(
              kdsEnabled, r'KitchenStation', 'kdsEnabled'),
          isDefault: BuiltValueNullFieldError.checkNotNull(
              isDefault, r'KitchenStation', 'isDefault'),
          warnAfterMinutes: BuiltValueNullFieldError.checkNotNull(
              warnAfterMinutes, r'KitchenStation', 'warnAfterMinutes'),
          lateAfterMinutes: BuiltValueNullFieldError.checkNotNull(
              lateAfterMinutes, r'KitchenStation', 'lateAfterMinutes'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'KitchenStation', 'position'),
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'KitchenStation', 'active'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
