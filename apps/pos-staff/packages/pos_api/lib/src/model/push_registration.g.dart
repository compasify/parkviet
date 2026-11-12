// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PushRegistrationPlatformEnum _$pushRegistrationPlatformEnum_fcm =
    const PushRegistrationPlatformEnum._('fcm');
const PushRegistrationPlatformEnum _$pushRegistrationPlatformEnum_apns =
    const PushRegistrationPlatformEnum._('apns');

PushRegistrationPlatformEnum _$pushRegistrationPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'fcm':
      return _$pushRegistrationPlatformEnum_fcm;
    case 'apns':
      return _$pushRegistrationPlatformEnum_apns;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PushRegistrationPlatformEnum>
    _$pushRegistrationPlatformEnumValues =
    BuiltSet<PushRegistrationPlatformEnum>(const <PushRegistrationPlatformEnum>[
  _$pushRegistrationPlatformEnum_fcm,
  _$pushRegistrationPlatformEnum_apns,
]);

Serializer<PushRegistrationPlatformEnum>
    _$pushRegistrationPlatformEnumSerializer =
    _$PushRegistrationPlatformEnumSerializer();

class _$PushRegistrationPlatformEnumSerializer
    implements PrimitiveSerializer<PushRegistrationPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fcm': 'fcm',
    'apns': 'apns',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fcm': 'fcm',
    'apns': 'apns',
  };

  @override
  final Iterable<Type> types = const <Type>[PushRegistrationPlatformEnum];
  @override
  final String wireName = 'PushRegistrationPlatformEnum';

  @override
  Object serialize(Serializers serializers, PushRegistrationPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PushRegistrationPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PushRegistrationPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PushRegistration extends PushRegistration {
  @override
  final String id;
  @override
  final String deviceId;
  @override
  final PushRegistrationPlatformEnum platform;
  @override
  final bool enabled;
  @override
  final String? lastError;
  @override
  final DateTime? lastErrorAt;
  @override
  final DateTime? lastDeliveredAt;

  factory _$PushRegistration(
          [void Function(PushRegistrationBuilder)? updates]) =>
      (PushRegistrationBuilder()..update(updates))._build();

  _$PushRegistration._(
      {required this.id,
      required this.deviceId,
      required this.platform,
      required this.enabled,
      this.lastError,
      this.lastErrorAt,
      this.lastDeliveredAt})
      : super._();
  @override
  PushRegistration rebuild(void Function(PushRegistrationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRegistrationBuilder toBuilder() =>
      PushRegistrationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRegistration &&
        id == other.id &&
        deviceId == other.deviceId &&
        platform == other.platform &&
        enabled == other.enabled &&
        lastError == other.lastError &&
        lastErrorAt == other.lastErrorAt &&
        lastDeliveredAt == other.lastDeliveredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, lastError.hashCode);
    _$hash = $jc(_$hash, lastErrorAt.hashCode);
    _$hash = $jc(_$hash, lastDeliveredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRegistration')
          ..add('id', id)
          ..add('deviceId', deviceId)
          ..add('platform', platform)
          ..add('enabled', enabled)
          ..add('lastError', lastError)
          ..add('lastErrorAt', lastErrorAt)
          ..add('lastDeliveredAt', lastDeliveredAt))
        .toString();
  }
}

class PushRegistrationBuilder
    implements Builder<PushRegistration, PushRegistrationBuilder> {
  _$PushRegistration? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  PushRegistrationPlatformEnum? _platform;
  PushRegistrationPlatformEnum? get platform => _$this._platform;
  set platform(PushRegistrationPlatformEnum? platform) =>
      _$this._platform = platform;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  String? _lastError;
  String? get lastError => _$this._lastError;
  set lastError(String? lastError) => _$this._lastError = lastError;

  DateTime? _lastErrorAt;
  DateTime? get lastErrorAt => _$this._lastErrorAt;
  set lastErrorAt(DateTime? lastErrorAt) => _$this._lastErrorAt = lastErrorAt;

  DateTime? _lastDeliveredAt;
  DateTime? get lastDeliveredAt => _$this._lastDeliveredAt;
  set lastDeliveredAt(DateTime? lastDeliveredAt) =>
      _$this._lastDeliveredAt = lastDeliveredAt;

  PushRegistrationBuilder() {
    PushRegistration._defaults(this);
  }

  PushRegistrationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _deviceId = $v.deviceId;
      _platform = $v.platform;
      _enabled = $v.enabled;
      _lastError = $v.lastError;
      _lastErrorAt = $v.lastErrorAt;
      _lastDeliveredAt = $v.lastDeliveredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRegistration other) {
    _$v = other as _$PushRegistration;
  }

  @override
  void update(void Function(PushRegistrationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRegistration build() => _build();

  _$PushRegistration _build() {
    final _$result = _$v ??
        _$PushRegistration._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PushRegistration', 'id'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'PushRegistration', 'deviceId'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PushRegistration', 'platform'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'PushRegistration', 'enabled'),
          lastError: lastError,
          lastErrorAt: lastErrorAt,
          lastDeliveredAt: lastDeliveredAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
