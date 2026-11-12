//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/timed_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_command.g.dart';

/// TimedSessionCommand
///
/// Properties:
/// * [workspace]
/// * [timedSession]
@BuiltValue()
abstract class TimedSessionCommand
    implements Built<TimedSessionCommand, TimedSessionCommandBuilder> {
  @BuiltValueField(wireName: r'workspace')
  Workspace get workspace;

  @BuiltValueField(wireName: r'timed_session')
  TimedSession get timedSession;

  TimedSessionCommand._();

  factory TimedSessionCommand([void updates(TimedSessionCommandBuilder b)]) =
      _$TimedSessionCommand;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionCommandBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSessionCommand> get serializer =>
      _$TimedSessionCommandSerializer();
}

class _$TimedSessionCommandSerializer
    implements PrimitiveSerializer<TimedSessionCommand> {
  @override
  final Iterable<Type> types = const [
    TimedSessionCommand,
    _$TimedSessionCommand
  ];

  @override
  final String wireName = r'TimedSessionCommand';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSessionCommand object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace';
    yield serializers.serialize(
      object.workspace,
      specifiedType: const FullType(Workspace),
    );
    yield r'timed_session';
    yield serializers.serialize(
      object.timedSession,
      specifiedType: const FullType(TimedSession),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSessionCommand object, {
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
    required TimedSessionCommandBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.workspace.replace(valueDes);
          break;
        case r'timed_session':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimedSession),
          ) as TimedSession;
          result.timedSession.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedSessionCommand deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionCommandBuilder();
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
