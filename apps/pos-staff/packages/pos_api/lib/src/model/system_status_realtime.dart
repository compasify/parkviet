//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_realtime.g.dart';

/// SystemStatusRealtime
///
/// Properties:
/// * [ok]
/// * [adapter]
/// * [probeMs] - One message through the pub/sub adapter, broadcast to delivery on the server. Excludes the hop to a device.
/// * [measuredAt]
@BuiltValue()
abstract class SystemStatusRealtime
    implements Built<SystemStatusRealtime, SystemStatusRealtimeBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool get ok;

  @BuiltValueField(wireName: r'adapter')
  String get adapter;

  /// One message through the pub/sub adapter, broadcast to delivery on the server. Excludes the hop to a device.
  @BuiltValueField(wireName: r'probe_ms')
  num? get probeMs;

  @BuiltValueField(wireName: r'measured_at')
  DateTime get measuredAt;

  SystemStatusRealtime._();

  factory SystemStatusRealtime([void updates(SystemStatusRealtimeBuilder b)]) =
      _$SystemStatusRealtime;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusRealtimeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusRealtime> get serializer =>
      _$SystemStatusRealtimeSerializer();
}

class _$SystemStatusRealtimeSerializer
    implements PrimitiveSerializer<SystemStatusRealtime> {
  @override
  final Iterable<Type> types = const [
    SystemStatusRealtime,
    _$SystemStatusRealtime
  ];

  @override
  final String wireName = r'SystemStatusRealtime';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusRealtime object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ok';
    yield serializers.serialize(
      object.ok,
      specifiedType: const FullType(bool),
    );
    yield r'adapter';
    yield serializers.serialize(
      object.adapter,
      specifiedType: const FullType(String),
    );
    yield r'probe_ms';
    yield object.probeMs == null
        ? null
        : serializers.serialize(
            object.probeMs,
            specifiedType: const FullType.nullable(num),
          );
    yield r'measured_at';
    yield serializers.serialize(
      object.measuredAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusRealtime object, {
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
    required SystemStatusRealtimeBuilder result,
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
        case r'adapter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adapter = valueDes;
          break;
        case r'probe_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.probeMs = valueDes;
          break;
        case r'measured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.measuredAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusRealtime deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusRealtimeBuilder();
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
