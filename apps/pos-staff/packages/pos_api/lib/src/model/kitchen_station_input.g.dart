// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_station_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KitchenStationInputKindEnum _$kitchenStationInputKindEnum_prep =
    const KitchenStationInputKindEnum._('prep');
const KitchenStationInputKindEnum _$kitchenStationInputKindEnum_bar =
    const KitchenStationInputKindEnum._('bar');
const KitchenStationInputKindEnum _$kitchenStationInputKindEnum_expo =
    const KitchenStationInputKindEnum._('expo');

KitchenStationInputKindEnum _$kitchenStationInputKindEnumValueOf(String name) {
  switch (name) {
    case 'prep':
      return _$kitchenStationInputKindEnum_prep;
    case 'bar':
      return _$kitchenStationInputKindEnum_bar;
    case 'expo':
      return _$kitchenStationInputKindEnum_expo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenStationInputKindEnum>
    _$kitchenStationInputKindEnumValues =
    BuiltSet<KitchenStationInputKindEnum>(const <KitchenStationInputKindEnum>[
  _$kitchenStationInputKindEnum_prep,
  _$kitchenStationInputKindEnum_bar,
  _$kitchenStationInputKindEnum_expo,
]);

Serializer<KitchenStationInputKindEnum>
    _$kitchenStationInputKindEnumSerializer =
    _$KitchenStationInputKindEnumSerializer();

class _$KitchenStationInputKindEnumSerializer
    implements PrimitiveSerializer<KitchenStationInputKindEnum> {
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
  final Iterable<Type> types = const <Type>[KitchenStationInputKindEnum];
  @override
  final String wireName = 'KitchenStationInputKindEnum';

  @override
  Object serialize(Serializers serializers, KitchenStationInputKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenStationInputKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenStationInputKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

abstract class KitchenStationInputBuilder {
  void replace(KitchenStationInput other);
  void update(void Function(KitchenStationInputBuilder) updates);
  String? get name;
  set name(String? name);

  KitchenStationInputKindEnum? get kind;
  set kind(KitchenStationInputKindEnum? kind);

  String? get printerId;
  set printerId(String? printerId);

  bool? get kdsEnabled;
  set kdsEnabled(bool? kdsEnabled);

  bool? get isDefault;
  set isDefault(bool? isDefault);

  int? get warnAfterMinutes;
  set warnAfterMinutes(int? warnAfterMinutes);

  int? get lateAfterMinutes;
  set lateAfterMinutes(int? lateAfterMinutes);

  int? get position;
  set position(int? position);

  bool? get active;
  set active(bool? active);
}

class _$$KitchenStationInput extends $KitchenStationInput {
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

  factory _$$KitchenStationInput(
          [void Function($KitchenStationInputBuilder)? updates]) =>
      ($KitchenStationInputBuilder()..update(updates))._build();

  _$$KitchenStationInput._(
      {this.name,
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
  $KitchenStationInput rebuild(
          void Function($KitchenStationInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $KitchenStationInputBuilder toBuilder() =>
      $KitchenStationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $KitchenStationInput &&
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
    return (newBuiltValueToStringHelper(r'$KitchenStationInput')
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

class $KitchenStationInputBuilder
    implements
        Builder<$KitchenStationInput, $KitchenStationInputBuilder>,
        KitchenStationInputBuilder {
  _$$KitchenStationInput? _$v;

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

  $KitchenStationInputBuilder() {
    $KitchenStationInput._defaults(this);
  }

  $KitchenStationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(covariant $KitchenStationInput other) {
    _$v = other as _$$KitchenStationInput;
  }

  @override
  void update(void Function($KitchenStationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $KitchenStationInput build() => _build();

  _$$KitchenStationInput _build() {
    final _$result = _$v ??
        _$$KitchenStationInput._(
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
