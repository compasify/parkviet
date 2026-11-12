//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/meal_split_plan.dart';
import 'package:pos_api/src/model/meal_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_meal.g.dart';

/// WorkspaceMeal
///
/// Properties:
/// * [workspaceId]
/// * [meal]
/// * [plan]
@BuiltValue()
abstract class WorkspaceMeal
    implements Built<WorkspaceMeal, WorkspaceMealBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'meal')
  MealStatus? get meal;

  @BuiltValueField(wireName: r'plan')
  MealSplitPlan get plan;

  WorkspaceMeal._();

  factory WorkspaceMeal([void updates(WorkspaceMealBuilder b)]) =
      _$WorkspaceMeal;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceMealBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceMeal> get serializer =>
      _$WorkspaceMealSerializer();
}

class _$WorkspaceMealSerializer implements PrimitiveSerializer<WorkspaceMeal> {
  @override
  final Iterable<Type> types = const [WorkspaceMeal, _$WorkspaceMeal];

  @override
  final String wireName = r'WorkspaceMeal';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceMeal object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    if (object.meal != null) {
      yield r'meal';
      yield serializers.serialize(
        object.meal,
        specifiedType: const FullType.nullable(MealStatus),
      );
    }
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(MealSplitPlan),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceMeal object, {
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
    required WorkspaceMealBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'meal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MealStatus),
          ) as MealStatus?;
          if (valueDes == null) continue;
          result.meal.replace(valueDes);
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealSplitPlan),
          ) as MealSplitPlan;
          result.plan.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceMeal deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceMealBuilder();
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
