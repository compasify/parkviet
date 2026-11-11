//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_vietqr.g.dart';

/// SystemStatusVietqr
///
/// Properties:
/// * [lastReceivedAt]
/// * [unmatched]
@BuiltValue()
abstract class SystemStatusVietqr
    implements Built<SystemStatusVietqr, SystemStatusVietqrBuilder> {
  @BuiltValueField(wireName: r'last_received_at')
  DateTime? get lastReceivedAt;

  @BuiltValueField(wireName: r'unmatched')
  int get unmatched;

  SystemStatusVietqr._();

  factory SystemStatusVietqr([void updates(SystemStatusVietqrBuilder b)]) =
      _$SystemStatusVietqr;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusVietqrBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusVietqr> get serializer =>
      _$SystemStatusVietqrSerializer();
}

class _$SystemStatusVietqrSerializer
    implements PrimitiveSerializer<SystemStatusVietqr> {
  @override
  final Iterable<Type> types = const [SystemStatusVietqr, _$SystemStatusVietqr];

  @override
  final String wireName = r'SystemStatusVietqr';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusVietqr object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'last_received_at';
    yield object.lastReceivedAt == null
        ? null
        : serializers.serialize(
            object.lastReceivedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'unmatched';
    yield serializers.serialize(
      object.unmatched,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusVietqr object, {
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
    required SystemStatusVietqrBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'last_received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastReceivedAt = valueDes;
          break;
        case r'unmatched':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unmatched = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusVietqr deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusVietqrBuilder();
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
