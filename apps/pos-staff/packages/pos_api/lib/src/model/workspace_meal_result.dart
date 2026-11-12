//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace_meal.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_meal_result.g.dart';

/// WorkspaceMealResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class WorkspaceMealResult
    implements Built<WorkspaceMealResult, WorkspaceMealResultBuilder> {
  @BuiltValueField(wireName: r'data')
  WorkspaceMeal get data;

  WorkspaceMealResult._();

  factory WorkspaceMealResult([void updates(WorkspaceMealResultBuilder b)]) =
      _$WorkspaceMealResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceMealResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceMealResult> get serializer =>
      _$WorkspaceMealResultSerializer();
}

class _$WorkspaceMealResultSerializer
    implements PrimitiveSerializer<WorkspaceMealResult> {
  @override
  final Iterable<Type> types = const [
    WorkspaceMealResult,
    _$WorkspaceMealResult
  ];

  @override
  final String wireName = r'WorkspaceMealResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceMealResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(WorkspaceMeal),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceMealResult object, {
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
    required WorkspaceMealResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkspaceMeal),
          ) as WorkspaceMeal;
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
  WorkspaceMealResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceMealResultBuilder();
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
