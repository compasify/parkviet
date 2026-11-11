//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_outbound.g.dart';

/// Work waiting to leave the server (the outbox)
///
/// Properties:
/// * [pending]
/// * [failed]
/// * [oldestPendingAgeSeconds]
@BuiltValue()
abstract class SystemStatusOutbound
    implements Built<SystemStatusOutbound, SystemStatusOutboundBuilder> {
  @BuiltValueField(wireName: r'pending')
  int get pending;

  @BuiltValueField(wireName: r'failed')
  int get failed;

  @BuiltValueField(wireName: r'oldest_pending_age_seconds')
  int? get oldestPendingAgeSeconds;

  SystemStatusOutbound._();

  factory SystemStatusOutbound([void updates(SystemStatusOutboundBuilder b)]) =
      _$SystemStatusOutbound;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusOutboundBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusOutbound> get serializer =>
      _$SystemStatusOutboundSerializer();
}

class _$SystemStatusOutboundSerializer
    implements PrimitiveSerializer<SystemStatusOutbound> {
  @override
  final Iterable<Type> types = const [
    SystemStatusOutbound,
    _$SystemStatusOutbound
  ];

  @override
  final String wireName = r'SystemStatusOutbound';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusOutbound object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pending';
    yield serializers.serialize(
      object.pending,
      specifiedType: const FullType(int),
    );
    yield r'failed';
    yield serializers.serialize(
      object.failed,
      specifiedType: const FullType(int),
    );
    yield r'oldest_pending_age_seconds';
    yield object.oldestPendingAgeSeconds == null
        ? null
        : serializers.serialize(
            object.oldestPendingAgeSeconds,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusOutbound object, {
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
    required SystemStatusOutboundBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pending = valueDes;
          break;
        case r'failed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failed = valueDes;
          break;
        case r'oldest_pending_age_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.oldestPendingAgeSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusOutbound deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusOutboundBuilder();
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
