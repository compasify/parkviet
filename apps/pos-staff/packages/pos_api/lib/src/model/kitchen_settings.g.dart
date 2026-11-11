// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KitchenSettingsKitchenSendTriggerEnum
    _$kitchenSettingsKitchenSendTriggerEnum_onComplete =
    const KitchenSettingsKitchenSendTriggerEnum._('onComplete');
const KitchenSettingsKitchenSendTriggerEnum
    _$kitchenSettingsKitchenSendTriggerEnum_manual =
    const KitchenSettingsKitchenSendTriggerEnum._('manual');

KitchenSettingsKitchenSendTriggerEnum
    _$kitchenSettingsKitchenSendTriggerEnumValueOf(String name) {
  switch (name) {
    case 'onComplete':
      return _$kitchenSettingsKitchenSendTriggerEnum_onComplete;
    case 'manual':
      return _$kitchenSettingsKitchenSendTriggerEnum_manual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenSettingsKitchenSendTriggerEnum>
    _$kitchenSettingsKitchenSendTriggerEnumValues = BuiltSet<
        KitchenSettingsKitchenSendTriggerEnum>(const <KitchenSettingsKitchenSendTriggerEnum>[
  _$kitchenSettingsKitchenSendTriggerEnum_onComplete,
  _$kitchenSettingsKitchenSendTriggerEnum_manual,
]);

Serializer<KitchenSettingsKitchenSendTriggerEnum>
    _$kitchenSettingsKitchenSendTriggerEnumSerializer =
    _$KitchenSettingsKitchenSendTriggerEnumSerializer();

class _$KitchenSettingsKitchenSendTriggerEnumSerializer
    implements PrimitiveSerializer<KitchenSettingsKitchenSendTriggerEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'onComplete': 'on_complete',
    'manual': 'manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'on_complete': 'onComplete',
    'manual': 'manual',
  };

  @override
  final Iterable<Type> types = const <Type>[
    KitchenSettingsKitchenSendTriggerEnum
  ];
  @override
  final String wireName = 'KitchenSettingsKitchenSendTriggerEnum';

  @override
  Object serialize(
          Serializers serializers, KitchenSettingsKitchenSendTriggerEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenSettingsKitchenSendTriggerEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenSettingsKitchenSendTriggerEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KitchenSettings extends KitchenSettings {
  @override
  final String branchId;
  @override
  final KitchenSettingsKitchenSendTriggerEnum kitchenSendTrigger;
  @override
  final bool moduleEnabled;
  @override
  final BuiltList<String> voidReasons;

  factory _$KitchenSettings([void Function(KitchenSettingsBuilder)? updates]) =>
      (KitchenSettingsBuilder()..update(updates))._build();

  _$KitchenSettings._(
      {required this.branchId,
      required this.kitchenSendTrigger,
      required this.moduleEnabled,
      required this.voidReasons})
      : super._();
  @override
  KitchenSettings rebuild(void Function(KitchenSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenSettingsBuilder toBuilder() => KitchenSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenSettings &&
        branchId == other.branchId &&
        kitchenSendTrigger == other.kitchenSendTrigger &&
        moduleEnabled == other.moduleEnabled &&
        voidReasons == other.voidReasons;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kitchenSendTrigger.hashCode);
    _$hash = $jc(_$hash, moduleEnabled.hashCode);
    _$hash = $jc(_$hash, voidReasons.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenSettings')
          ..add('branchId', branchId)
          ..add('kitchenSendTrigger', kitchenSendTrigger)
          ..add('moduleEnabled', moduleEnabled)
          ..add('voidReasons', voidReasons))
        .toString();
  }
}

class KitchenSettingsBuilder
    implements Builder<KitchenSettings, KitchenSettingsBuilder> {
  _$KitchenSettings? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  KitchenSettingsKitchenSendTriggerEnum? _kitchenSendTrigger;
  KitchenSettingsKitchenSendTriggerEnum? get kitchenSendTrigger =>
      _$this._kitchenSendTrigger;
  set kitchenSendTrigger(
          KitchenSettingsKitchenSendTriggerEnum? kitchenSendTrigger) =>
      _$this._kitchenSendTrigger = kitchenSendTrigger;

  bool? _moduleEnabled;
  bool? get moduleEnabled => _$this._moduleEnabled;
  set moduleEnabled(bool? moduleEnabled) =>
      _$this._moduleEnabled = moduleEnabled;

  ListBuilder<String>? _voidReasons;
  ListBuilder<String> get voidReasons =>
      _$this._voidReasons ??= ListBuilder<String>();
  set voidReasons(ListBuilder<String>? voidReasons) =>
      _$this._voidReasons = voidReasons;

  KitchenSettingsBuilder() {
    KitchenSettings._defaults(this);
  }

  KitchenSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _kitchenSendTrigger = $v.kitchenSendTrigger;
      _moduleEnabled = $v.moduleEnabled;
      _voidReasons = $v.voidReasons.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenSettings other) {
    _$v = other as _$KitchenSettings;
  }

  @override
  void update(void Function(KitchenSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenSettings build() => _build();

  _$KitchenSettings _build() {
    _$KitchenSettings _$result;
    try {
      _$result = _$v ??
          _$KitchenSettings._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'KitchenSettings', 'branchId'),
            kitchenSendTrigger: BuiltValueNullFieldError.checkNotNull(
                kitchenSendTrigger, r'KitchenSettings', 'kitchenSendTrigger'),
            moduleEnabled: BuiltValueNullFieldError.checkNotNull(
                moduleEnabled, r'KitchenSettings', 'moduleEnabled'),
            voidReasons: voidReasons.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'voidReasons';
        voidReasons.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
