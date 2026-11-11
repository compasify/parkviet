//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_server.g.dart';

/// HardwareServer
///
/// Properties:
/// * [publicBaseUrl]
/// * [tlsMode]
/// * [outboundPending]
/// * [outboundFailed]
/// * [outboundOldestPendingAgeSeconds]
/// * [vietqrLastReceivedAt]
@BuiltValue()
abstract class HardwareServer
    implements Built<HardwareServer, HardwareServerBuilder> {
  @BuiltValueField(wireName: r'public_base_url')
  String get publicBaseUrl;

  @BuiltValueField(wireName: r'tls_mode')
  String get tlsMode;

  @BuiltValueField(wireName: r'outbound_pending')
  int get outboundPending;

  @BuiltValueField(wireName: r'outbound_failed')
  int get outboundFailed;

  @BuiltValueField(wireName: r'outbound_oldest_pending_age_seconds')
  int get outboundOldestPendingAgeSeconds;

  @BuiltValueField(wireName: r'vietqr_last_received_at')
  DateTime get vietqrLastReceivedAt;

  HardwareServer._();

  factory HardwareServer([void updates(HardwareServerBuilder b)]) =
      _$HardwareServer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareServerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareServer> get serializer =>
      _$HardwareServerSerializer();
}

class _$HardwareServerSerializer
    implements PrimitiveSerializer<HardwareServer> {
  @override
  final Iterable<Type> types = const [HardwareServer, _$HardwareServer];

  @override
  final String wireName = r'HardwareServer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareServer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'public_base_url';
    yield serializers.serialize(
      object.publicBaseUrl,
      specifiedType: const FullType(String),
    );
    yield r'tls_mode';
    yield serializers.serialize(
      object.tlsMode,
      specifiedType: const FullType(String),
    );
    yield r'outbound_pending';
    yield serializers.serialize(
      object.outboundPending,
      specifiedType: const FullType(int),
    );
    yield r'outbound_failed';
    yield serializers.serialize(
      object.outboundFailed,
      specifiedType: const FullType(int),
    );
    yield r'outbound_oldest_pending_age_seconds';
    yield serializers.serialize(
      object.outboundOldestPendingAgeSeconds,
      specifiedType: const FullType(int),
    );
    yield r'vietqr_last_received_at';
    yield serializers.serialize(
      object.vietqrLastReceivedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareServer object, {
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
    required HardwareServerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'public_base_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicBaseUrl = valueDes;
          break;
        case r'tls_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tlsMode = valueDes;
          break;
        case r'outbound_pending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.outboundPending = valueDes;
          break;
        case r'outbound_failed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.outboundFailed = valueDes;
          break;
        case r'outbound_oldest_pending_age_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.outboundOldestPendingAgeSeconds = valueDes;
          break;
        case r'vietqr_last_received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.vietqrLastReceivedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareServer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareServerBuilder();
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
