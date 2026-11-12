//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/meal_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_swipe.g.dart';

/// MealSwipe
///
/// Properties:
/// * [result]
/// * [reason]
/// * [meal]
/// * [workspace]
@BuiltValue()
abstract class MealSwipe implements Built<MealSwipe, MealSwipeBuilder> {
  @BuiltValueField(wireName: r'result')
  MealSwipeResultEnum get result;
  // enum resultEnum {  ok,  };

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'meal')
  MealStatus? get meal;

  @BuiltValueField(wireName: r'workspace')
  Workspace get workspace;

  MealSwipe._();

  factory MealSwipe([void updates(MealSwipeBuilder b)]) = _$MealSwipe;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealSwipeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealSwipe> get serializer => _$MealSwipeSerializer();
}

class _$MealSwipeSerializer implements PrimitiveSerializer<MealSwipe> {
  @override
  final Iterable<Type> types = const [MealSwipe, _$MealSwipe];

  @override
  final String wireName = r'MealSwipe';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealSwipe object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'result';
    yield serializers.serialize(
      object.result,
      specifiedType: const FullType(MealSwipeResultEnum),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.meal != null) {
      yield r'meal';
      yield serializers.serialize(
        object.meal,
        specifiedType: const FullType.nullable(MealStatus),
      );
    }
    yield r'workspace';
    yield serializers.serialize(
      object.workspace,
      specifiedType: const FullType(Workspace),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealSwipe object, {
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
    required MealSwipeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealSwipeResultEnum),
          ) as MealSwipeResultEnum;
          result.result = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'meal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MealStatus),
          ) as MealStatus?;
          if (valueDes == null) continue;
          result.meal.replace(valueDes);
          break;
        case r'workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.workspace.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealSwipe deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealSwipeBuilder();
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

class MealSwipeResultEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ok')
  static const MealSwipeResultEnum ok = _$mealSwipeResultEnum_ok;

  static Serializer<MealSwipeResultEnum> get serializer =>
      _$mealSwipeResultEnumSerializer;

  const MealSwipeResultEnum._(String name) : super(name);

  static BuiltSet<MealSwipeResultEnum> get values =>
      _$mealSwipeResultEnumValues;
  static MealSwipeResultEnum valueOf(String name) =>
      _$mealSwipeResultEnumValueOf(name);
}
