//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_move_input.g.dart';

/// TimedSessionMoveInput
///
/// Properties:
/// * [resourceId] - A free room of the same branch.
@BuiltValue()
abstract class TimedSessionMoveInput
    implements Built<TimedSessionMoveInput, TimedSessionMoveInputBuilder> {
  /// A free room of the same branch.
  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  TimedSessionMoveInput._();

  factory TimedSessionMoveInput(
      [void updates(TimedSessionMoveInputBuilder b)]) = _$TimedSessionMoveInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionMoveInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSessionMoveInput> get serializer =>
      _$TimedSessionMoveInputSerializer();
}

class _$TimedSessionMoveInputSerializer
    implements PrimitiveSerializer<TimedSessionMoveInput> {
  @override
  final Iterable<Type> types = const [
    TimedSessionMoveInput,
    _$TimedSessionMoveInput
  ];

  @override
  final String wireName = r'TimedSessionMoveInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSessionMoveInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSessionMoveInput object, {
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
    required TimedSessionMoveInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedSessionMoveInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionMoveInputBuilder();
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
