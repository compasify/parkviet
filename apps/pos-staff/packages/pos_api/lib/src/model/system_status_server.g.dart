// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_server.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SystemStatusServerTlsModeEnum _$systemStatusServerTlsModeEnum_none =
    const SystemStatusServerTlsModeEnum._('none');
const SystemStatusServerTlsModeEnum _$systemStatusServerTlsModeEnum_internal =
    const SystemStatusServerTlsModeEnum._('internal');
const SystemStatusServerTlsModeEnum _$systemStatusServerTlsModeEnum_public =
    const SystemStatusServerTlsModeEnum._('public');
const SystemStatusServerTlsModeEnum _$systemStatusServerTlsModeEnum_unset =
    const SystemStatusServerTlsModeEnum._('unset');

SystemStatusServerTlsModeEnum _$systemStatusServerTlsModeEnumValueOf(
    String name) {
  switch (name) {
    case 'none':
      return _$systemStatusServerTlsModeEnum_none;
    case 'internal':
      return _$systemStatusServerTlsModeEnum_internal;
    case 'public':
      return _$systemStatusServerTlsModeEnum_public;
    case 'unset':
      return _$systemStatusServerTlsModeEnum_unset;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SystemStatusServerTlsModeEnum>
    _$systemStatusServerTlsModeEnumValues = BuiltSet<
        SystemStatusServerTlsModeEnum>(const <SystemStatusServerTlsModeEnum>[
  _$systemStatusServerTlsModeEnum_none,
  _$systemStatusServerTlsModeEnum_internal,
  _$systemStatusServerTlsModeEnum_public,
  _$systemStatusServerTlsModeEnum_unset,
]);

Serializer<SystemStatusServerTlsModeEnum>
    _$systemStatusServerTlsModeEnumSerializer =
    _$SystemStatusServerTlsModeEnumSerializer();

class _$SystemStatusServerTlsModeEnumSerializer
    implements PrimitiveSerializer<SystemStatusServerTlsModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'internal': 'internal',
    'public': 'public',
    'unset': 'unset',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'internal': 'internal',
    'public': 'public',
    'unset': 'unset',
  };

  @override
  final Iterable<Type> types = const <Type>[SystemStatusServerTlsModeEnum];
  @override
  final String wireName = 'SystemStatusServerTlsModeEnum';

  @override
  Object serialize(
          Serializers serializers, SystemStatusServerTlsModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SystemStatusServerTlsModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SystemStatusServerTlsModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SystemStatusServer extends SystemStatusServer {
  @override
  final String? publicBaseUrl;
  @override
  final SystemStatusServerTlsModeEnum tlsMode;

  factory _$SystemStatusServer(
          [void Function(SystemStatusServerBuilder)? updates]) =>
      (SystemStatusServerBuilder()..update(updates))._build();

  _$SystemStatusServer._({this.publicBaseUrl, required this.tlsMode})
      : super._();
  @override
  SystemStatusServer rebuild(
          void Function(SystemStatusServerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusServerBuilder toBuilder() =>
      SystemStatusServerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusServer &&
        publicBaseUrl == other.publicBaseUrl &&
        tlsMode == other.tlsMode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publicBaseUrl.hashCode);
    _$hash = $jc(_$hash, tlsMode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusServer')
          ..add('publicBaseUrl', publicBaseUrl)
          ..add('tlsMode', tlsMode))
        .toString();
  }
}

class SystemStatusServerBuilder
    implements Builder<SystemStatusServer, SystemStatusServerBuilder> {
  _$SystemStatusServer? _$v;

  String? _publicBaseUrl;
  String? get publicBaseUrl => _$this._publicBaseUrl;
  set publicBaseUrl(String? publicBaseUrl) =>
      _$this._publicBaseUrl = publicBaseUrl;

  SystemStatusServerTlsModeEnum? _tlsMode;
  SystemStatusServerTlsModeEnum? get tlsMode => _$this._tlsMode;
  set tlsMode(SystemStatusServerTlsModeEnum? tlsMode) =>
      _$this._tlsMode = tlsMode;

  SystemStatusServerBuilder() {
    SystemStatusServer._defaults(this);
  }

  SystemStatusServerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publicBaseUrl = $v.publicBaseUrl;
      _tlsMode = $v.tlsMode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusServer other) {
    _$v = other as _$SystemStatusServer;
  }

  @override
  void update(void Function(SystemStatusServerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusServer build() => _build();

  _$SystemStatusServer _build() {
    final _$result = _$v ??
        _$SystemStatusServer._(
          publicBaseUrl: publicBaseUrl,
          tlsMode: BuiltValueNullFieldError.checkNotNull(
              tlsMode, r'SystemStatusServer', 'tlsMode'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
