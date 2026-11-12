// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PushRegistrationInputPlatformEnum
    _$pushRegistrationInputPlatformEnum_fcm =
    const PushRegistrationInputPlatformEnum._('fcm');
const PushRegistrationInputPlatformEnum
    _$pushRegistrationInputPlatformEnum_apns =
    const PushRegistrationInputPlatformEnum._('apns');

PushRegistrationInputPlatformEnum _$pushRegistrationInputPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'fcm':
      return _$pushRegistrationInputPlatformEnum_fcm;
    case 'apns':
      return _$pushRegistrationInputPlatformEnum_apns;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PushRegistrationInputPlatformEnum>
    _$pushRegistrationInputPlatformEnumValues = BuiltSet<
        PushRegistrationInputPlatformEnum>(const <PushRegistrationInputPlatformEnum>[
  _$pushRegistrationInputPlatformEnum_fcm,
  _$pushRegistrationInputPlatformEnum_apns,
]);

Serializer<PushRegistrationInputPlatformEnum>
    _$pushRegistrationInputPlatformEnumSerializer =
    _$PushRegistrationInputPlatformEnumSerializer();

class _$PushRegistrationInputPlatformEnumSerializer
    implements PrimitiveSerializer<PushRegistrationInputPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fcm': 'fcm',
    'apns': 'apns',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fcm': 'fcm',
    'apns': 'apns',
  };

  @override
  final Iterable<Type> types = const <Type>[PushRegistrationInputPlatformEnum];
  @override
  final String wireName = 'PushRegistrationInputPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, PushRegistrationInputPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PushRegistrationInputPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PushRegistrationInputPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PushRegistrationInput extends PushRegistrationInput {
  @override
  final PushRegistrationInputPlatformEnum? platform;
  @override
  final String? token;
  @override
  final bool? enabled;

  factory _$PushRegistrationInput(
          [void Function(PushRegistrationInputBuilder)? updates]) =>
      (PushRegistrationInputBuilder()..update(updates))._build();

  _$PushRegistrationInput._({this.platform, this.token, this.enabled})
      : super._();
  @override
  PushRegistrationInput rebuild(
          void Function(PushRegistrationInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRegistrationInputBuilder toBuilder() =>
      PushRegistrationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRegistrationInput &&
        platform == other.platform &&
        token == other.token &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRegistrationInput')
          ..add('platform', platform)
          ..add('token', token)
          ..add('enabled', enabled))
        .toString();
  }
}

class PushRegistrationInputBuilder
    implements Builder<PushRegistrationInput, PushRegistrationInputBuilder> {
  _$PushRegistrationInput? _$v;

  PushRegistrationInputPlatformEnum? _platform;
  PushRegistrationInputPlatformEnum? get platform => _$this._platform;
  set platform(PushRegistrationInputPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  PushRegistrationInputBuilder() {
    PushRegistrationInput._defaults(this);
  }

  PushRegistrationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _token = $v.token;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRegistrationInput other) {
    _$v = other as _$PushRegistrationInput;
  }

  @override
  void update(void Function(PushRegistrationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRegistrationInput build() => _build();

  _$PushRegistrationInput _build() {
    final _$result = _$v ??
        _$PushRegistrationInput._(
          platform: platform,
          token: token,
          enabled: enabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
