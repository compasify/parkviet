//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/timed_session_command.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_command_result.g.dart';

/// TimedSessionCommandResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TimedSessionCommandResult
    implements
        Built<TimedSessionCommandResult, TimedSessionCommandResultBuilder> {
  @BuiltValueField(wireName: r'data')
  TimedSessionCommand get data;

  TimedSessionCommandResult._();

  factory TimedSessionCommandResult(
          [void updates(TimedSessionCommandResultBuilder b)]) =
      _$TimedSessionCommandResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionCommandResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSessionCommandResult> get serializer =>
      _$TimedSessionCommandResultSerializer();
}

class _$TimedSessionCommandResultSerializer
    implements PrimitiveSerializer<TimedSessionCommandResult> {
  @override
  final Iterable<Type> types = const [
    TimedSessionCommandResult,
    _$TimedSessionCommandResult
  ];

  @override
  final String wireName = r'TimedSessionCommandResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSessionCommandResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TimedSessionCommand),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSessionCommandResult object, {
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
    required TimedSessionCommandResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimedSessionCommand),
          ) as TimedSessionCommand;
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
  TimedSessionCommandResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionCommandResultBuilder();
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
