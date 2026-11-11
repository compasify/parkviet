// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_station_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosKitchenStationCreateRequestKindEnum
    _$posKitchenStationCreateRequestKindEnum_prep =
    const PosKitchenStationCreateRequestKindEnum._('prep');
const PosKitchenStationCreateRequestKindEnum
    _$posKitchenStationCreateRequestKindEnum_bar =
    const PosKitchenStationCreateRequestKindEnum._('bar');
const PosKitchenStationCreateRequestKindEnum
    _$posKitchenStationCreateRequestKindEnum_expo =
    const PosKitchenStationCreateRequestKindEnum._('expo');

PosKitchenStationCreateRequestKindEnum
    _$posKitchenStationCreateRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'prep':
      return _$posKitchenStationCreateRequestKindEnum_prep;
    case 'bar':
      return _$posKitchenStationCreateRequestKindEnum_bar;
    case 'expo':
      return _$posKitchenStationCreateRequestKindEnum_expo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosKitchenStationCreateRequestKindEnum>
    _$posKitchenStationCreateRequestKindEnumValues = BuiltSet<
        PosKitchenStationCreateRequestKindEnum>(const <PosKitchenStationCreateRequestKindEnum>[
  _$posKitchenStationCreateRequestKindEnum_prep,
  _$posKitchenStationCreateRequestKindEnum_bar,
  _$posKitchenStationCreateRequestKindEnum_expo,
]);

Serializer<PosKitchenStationCreateRequestKindEnum>
    _$posKitchenStationCreateRequestKindEnumSerializer =
    _$PosKitchenStationCreateRequestKindEnumSerializer();

class _$PosKitchenStationCreateRequestKindEnumSerializer
    implements PrimitiveSerializer<PosKitchenStationCreateRequestKindEnum> {
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
  final Iterable<Type> types = const <Type>[
    PosKitchenStationCreateRequestKindEnum
  ];
  @override
  final String wireName = 'PosKitchenStationCreateRequestKindEnum';

  @override
  Object serialize(Serializers serializers,
          PosKitchenStationCreateRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosKitchenStationCreateRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosKitchenStationCreateRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosKitchenStationCreateRequest extends PosKitchenStationCreateRequest {
  @override
  final String branchId;
  @override
  final String? name;
  @override
  final KitchenStationInputKindEnum? kind;
  @override
  final String? printerId;
  @override
  final bool? kdsEnabled;
  @override
  final bool? isDefault;
  @override
  final int? warnAfterMinutes;
  @override
  final int? lateAfterMinutes;
  @override
  final int? position;
  @override
  final bool? active;

  factory _$PosKitchenStationCreateRequest(
          [void Function(PosKitchenStationCreateRequestBuilder)? updates]) =>
      (PosKitchenStationCreateRequestBuilder()..update(updates))._build();

  _$PosKitchenStationCreateRequest._(
      {required this.branchId,
      this.name,
      this.kind,
      this.printerId,
      this.kdsEnabled,
      this.isDefault,
      this.warnAfterMinutes,
      this.lateAfterMinutes,
      this.position,
      this.active})
      : super._();
  @override
  PosKitchenStationCreateRequest rebuild(
          void Function(PosKitchenStationCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenStationCreateRequestBuilder toBuilder() =>
      PosKitchenStationCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenStationCreateRequest &&
        branchId == other.branchId &&
        name == other.name &&
        kind == other.kind &&
        printerId == other.printerId &&
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
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
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
    return (newBuiltValueToStringHelper(r'PosKitchenStationCreateRequest')
          ..add('branchId', branchId)
          ..add('name', name)
          ..add('kind', kind)
          ..add('printerId', printerId)
          ..add('kdsEnabled', kdsEnabled)
          ..add('isDefault', isDefault)
          ..add('warnAfterMinutes', warnAfterMinutes)
          ..add('lateAfterMinutes', lateAfterMinutes)
          ..add('position', position)
          ..add('active', active))
        .toString();
  }
}

class PosKitchenStationCreateRequestBuilder
    implements
        Builder<PosKitchenStationCreateRequest,
            PosKitchenStationCreateRequestBuilder>,
        KitchenStationInputBuilder {
  _$PosKitchenStationCreateRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(covariant String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  KitchenStationInputKindEnum? _kind;
  KitchenStationInputKindEnum? get kind => _$this._kind;
  set kind(covariant KitchenStationInputKindEnum? kind) => _$this._kind = kind;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(covariant String? printerId) => _$this._printerId = printerId;

  bool? _kdsEnabled;
  bool? get kdsEnabled => _$this._kdsEnabled;
  set kdsEnabled(covariant bool? kdsEnabled) => _$this._kdsEnabled = kdsEnabled;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(covariant bool? isDefault) => _$this._isDefault = isDefault;

  int? _warnAfterMinutes;
  int? get warnAfterMinutes => _$this._warnAfterMinutes;
  set warnAfterMinutes(covariant int? warnAfterMinutes) =>
      _$this._warnAfterMinutes = warnAfterMinutes;

  int? _lateAfterMinutes;
  int? get lateAfterMinutes => _$this._lateAfterMinutes;
  set lateAfterMinutes(covariant int? lateAfterMinutes) =>
      _$this._lateAfterMinutes = lateAfterMinutes;

  int? _position;
  int? get position => _$this._position;
  set position(covariant int? position) => _$this._position = position;

  bool? _active;
  bool? get active => _$this._active;
  set active(covariant bool? active) => _$this._active = active;

  PosKitchenStationCreateRequestBuilder() {
    PosKitchenStationCreateRequest._defaults(this);
  }

  PosKitchenStationCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _name = $v.name;
      _kind = $v.kind;
      _printerId = $v.printerId;
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
  void replace(covariant PosKitchenStationCreateRequest other) {
    _$v = other as _$PosKitchenStationCreateRequest;
  }

  @override
  void update(void Function(PosKitchenStationCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenStationCreateRequest build() => _build();

  _$PosKitchenStationCreateRequest _build() {
    final _$result = _$v ??
        _$PosKitchenStationCreateRequest._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'PosKitchenStationCreateRequest', 'branchId'),
          name: name,
          kind: kind,
          printerId: printerId,
          kdsEnabled: kdsEnabled,
          isDefault: isDefault,
          warnAfterMinutes: warnAfterMinutes,
          lateAfterMinutes: lateAfterMinutes,
          position: position,
          active: active,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
