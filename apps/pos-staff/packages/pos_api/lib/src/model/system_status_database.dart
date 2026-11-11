//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_database.g.dart';

/// SystemStatusDatabase
///
/// Properties:
/// * [ok]
/// * [latencyMs]
@BuiltValue()
abstract class SystemStatusDatabase
    implements Built<SystemStatusDatabase, SystemStatusDatabaseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool get ok;

  @BuiltValueField(wireName: r'latency_ms')
  num? get latencyMs;

  SystemStatusDatabase._();

  factory SystemStatusDatabase([void updates(SystemStatusDatabaseBuilder b)]) =
      _$SystemStatusDatabase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusDatabaseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusDatabase> get serializer =>
      _$SystemStatusDatabaseSerializer();
}

class _$SystemStatusDatabaseSerializer
    implements PrimitiveSerializer<SystemStatusDatabase> {
  @override
  final Iterable<Type> types = const [
    SystemStatusDatabase,
    _$SystemStatusDatabase
  ];

  @override
  final String wireName = r'SystemStatusDatabase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusDatabase object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ok';
    yield serializers.serialize(
      object.ok,
      specifiedType: const FullType(bool),
    );
    yield r'latency_ms';
    yield object.latencyMs == null
        ? null
        : serializers.serialize(
            object.latencyMs,
            specifiedType: const FullType.nullable(num),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusDatabase object, {
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
    required SystemStatusDatabaseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        case r'latency_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.latencyMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusDatabase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusDatabaseBuilder();
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
