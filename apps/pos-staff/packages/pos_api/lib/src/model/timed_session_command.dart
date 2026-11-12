//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/timed_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_command.g.dart';

/// TimedSessionCommand
///
/// Properties:
/// * [warnings] - Only when starting; `outside_operating_hours` when the clock started outside the branch's hours.
/// * [workspace]
/// * [timedSession]
@BuiltValue()
abstract class TimedSessionCommand
    implements Built<TimedSessionCommand, TimedSessionCommandBuilder> {
  /// Only when starting; `outside_operating_hours` when the clock started outside the branch's hours.
  @BuiltValueField(wireName: r'warnings')
  BuiltList<TimedSessionCommandWarningsEnum>? get warnings;
  // enum warningsEnum {  outside_operating_hours,  };

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
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType: const FullType(
            BuiltList, [FullType(TimedSessionCommandWarningsEnum)]),
      );
    }
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
        case r'warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(TimedSessionCommandWarningsEnum)]),
          ) as BuiltList<TimedSessionCommandWarningsEnum>?;
          if (valueDes == null) continue;
          result.warnings.replace(valueDes);
          break;
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

class TimedSessionCommandWarningsEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'outside_operating_hours')
  static const TimedSessionCommandWarningsEnum outsideOperatingHours =
      _$timedSessionCommandWarningsEnum_outsideOperatingHours;

  static Serializer<TimedSessionCommandWarningsEnum> get serializer =>
      _$timedSessionCommandWarningsEnumSerializer;

  const TimedSessionCommandWarningsEnum._(String name) : super(name);

  static BuiltSet<TimedSessionCommandWarningsEnum> get values =>
      _$timedSessionCommandWarningsEnumValues;
  static TimedSessionCommandWarningsEnum valueOf(String name) =>
      _$timedSessionCommandWarningsEnumValueOf(name);
}
