//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/timed_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_result.g.dart';

/// TimedSessionResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TimedSessionResult
    implements Built<TimedSessionResult, TimedSessionResultBuilder> {
  @BuiltValueField(wireName: r'data')
  TimedSession get data;

  TimedSessionResult._();

  factory TimedSessionResult([void updates(TimedSessionResultBuilder b)]) =
      _$TimedSessionResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSessionResult> get serializer =>
      _$TimedSessionResultSerializer();
}

class _$TimedSessionResultSerializer
    implements PrimitiveSerializer<TimedSessionResult> {
  @override
  final Iterable<Type> types = const [TimedSessionResult, _$TimedSessionResult];

  @override
  final String wireName = r'TimedSessionResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSessionResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TimedSession),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSessionResult object, {
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
    required TimedSessionResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimedSession),
          ) as TimedSession;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedSessionResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionResultBuilder();
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
