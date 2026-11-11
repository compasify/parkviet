// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_pair_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosDevicePairRequestPlatformEnum
    _$posDevicePairRequestPlatformEnum_android =
    const PosDevicePairRequestPlatformEnum._('android');
const PosDevicePairRequestPlatformEnum _$posDevicePairRequestPlatformEnum_ios =
    const PosDevicePairRequestPlatformEnum._('ios');
const PosDevicePairRequestPlatformEnum _$posDevicePairRequestPlatformEnum_web =
    const PosDevicePairRequestPlatformEnum._('web');

PosDevicePairRequestPlatformEnum _$posDevicePairRequestPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'android':
      return _$posDevicePairRequestPlatformEnum_android;
    case 'ios':
      return _$posDevicePairRequestPlatformEnum_ios;
    case 'web':
      return _$posDevicePairRequestPlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosDevicePairRequestPlatformEnum>
    _$posDevicePairRequestPlatformEnumValues = BuiltSet<
        PosDevicePairRequestPlatformEnum>(const <PosDevicePairRequestPlatformEnum>[
  _$posDevicePairRequestPlatformEnum_android,
  _$posDevicePairRequestPlatformEnum_ios,
  _$posDevicePairRequestPlatformEnum_web,
]);

Serializer<PosDevicePairRequestPlatformEnum>
    _$posDevicePairRequestPlatformEnumSerializer =
    _$PosDevicePairRequestPlatformEnumSerializer();

class _$PosDevicePairRequestPlatformEnumSerializer
    implements PrimitiveSerializer<PosDevicePairRequestPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[PosDevicePairRequestPlatformEnum];
  @override
  final String wireName = 'PosDevicePairRequestPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, PosDevicePairRequestPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosDevicePairRequestPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosDevicePairRequestPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosDevicePairRequest extends PosDevicePairRequest {
  @override
  final String code;
  @override
  final PosDevicePairRequestPlatformEnum platform;
  @override
  final String name;
  @override
  final String? appVersion;

  factory _$PosDevicePairRequest(
          [void Function(PosDevicePairRequestBuilder)? updates]) =>
      (PosDevicePairRequestBuilder()..update(updates))._build();

  _$PosDevicePairRequest._(
      {required this.code,
      required this.platform,
      required this.name,
      this.appVersion})
      : super._();
  @override
  PosDevicePairRequest rebuild(
          void Function(PosDevicePairRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDevicePairRequestBuilder toBuilder() =>
      PosDevicePairRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDevicePairRequest &&
        code == other.code &&
        platform == other.platform &&
        name == other.name &&
        appVersion == other.appVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosDevicePairRequest')
          ..add('code', code)
          ..add('platform', platform)
          ..add('name', name)
          ..add('appVersion', appVersion))
        .toString();
  }
}

class PosDevicePairRequestBuilder
    implements Builder<PosDevicePairRequest, PosDevicePairRequestBuilder> {
  _$PosDevicePairRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  PosDevicePairRequestPlatformEnum? _platform;
  PosDevicePairRequestPlatformEnum? get platform => _$this._platform;
  set platform(PosDevicePairRequestPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  PosDevicePairRequestBuilder() {
    PosDevicePairRequest._defaults(this);
  }

  PosDevicePairRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _platform = $v.platform;
      _name = $v.name;
      _appVersion = $v.appVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDevicePairRequest other) {
    _$v = other as _$PosDevicePairRequest;
  }

  @override
  void update(void Function(PosDevicePairRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDevicePairRequest build() => _build();

  _$PosDevicePairRequest _build() {
    final _$result = _$v ??
        _$PosDevicePairRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'PosDevicePairRequest', 'code'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PosDevicePairRequest', 'platform'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PosDevicePairRequest', 'name'),
          appVersion: appVersion,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
