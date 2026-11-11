//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_server.g.dart';

/// SystemStatusServer
///
/// Properties:
/// * [publicBaseUrl] - POS_PUBLIC_BASE_URL, the address in pairing QRs. Null when the QR uses the request origin.
/// * [tlsMode]
@BuiltValue()
abstract class SystemStatusServer
    implements Built<SystemStatusServer, SystemStatusServerBuilder> {
  /// POS_PUBLIC_BASE_URL, the address in pairing QRs. Null when the QR uses the request origin.
  @BuiltValueField(wireName: r'public_base_url')
  String? get publicBaseUrl;

  @BuiltValueField(wireName: r'tls_mode')
  SystemStatusServerTlsModeEnum get tlsMode;
  // enum tlsModeEnum {  none,  internal,  public,  unset,  };

  SystemStatusServer._();

  factory SystemStatusServer([void updates(SystemStatusServerBuilder b)]) =
      _$SystemStatusServer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusServerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusServer> get serializer =>
      _$SystemStatusServerSerializer();
}

class _$SystemStatusServerSerializer
    implements PrimitiveSerializer<SystemStatusServer> {
  @override
  final Iterable<Type> types = const [SystemStatusServer, _$SystemStatusServer];

  @override
  final String wireName = r'SystemStatusServer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusServer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'public_base_url';
    yield object.publicBaseUrl == null
        ? null
        : serializers.serialize(
            object.publicBaseUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'tls_mode';
    yield serializers.serialize(
      object.tlsMode,
      specifiedType: const FullType(SystemStatusServerTlsModeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusServer object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SystemStatusServerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'public_base_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.publicBaseUrl = valueDes;
          break;
        case r'tls_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusServerTlsModeEnum),
          ) as SystemStatusServerTlsModeEnum;
          result.tlsMode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusServer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusServerBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class SystemStatusServerTlsModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const SystemStatusServerTlsModeEnum none =
      _$systemStatusServerTlsModeEnum_none;
  @BuiltValueEnumConst(wireName: r'internal')
  static const SystemStatusServerTlsModeEnum internal =
      _$systemStatusServerTlsModeEnum_internal;
  @BuiltValueEnumConst(wireName: r'public')
  static const SystemStatusServerTlsModeEnum public =
      _$systemStatusServerTlsModeEnum_public;
  @BuiltValueEnumConst(wireName: r'unset')
  static const SystemStatusServerTlsModeEnum unset =
      _$systemStatusServerTlsModeEnum_unset;

  static Serializer<SystemStatusServerTlsModeEnum> get serializer =>
      _$systemStatusServerTlsModeEnumSerializer;

  const SystemStatusServerTlsModeEnum._(String name) : super(name);

  static BuiltSet<SystemStatusServerTlsModeEnum> get values =>
      _$systemStatusServerTlsModeEnumValues;
  static SystemStatusServerTlsModeEnum valueOf(String name) =>
      _$systemStatusServerTlsModeEnumValueOf(name);
}
