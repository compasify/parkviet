//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/meal_swipe.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_swipe_result.g.dart';

/// MealSwipeResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class MealSwipeResult
    implements Built<MealSwipeResult, MealSwipeResultBuilder> {
  @BuiltValueField(wireName: r'data')
  MealSwipe get data;

  MealSwipeResult._();

  factory MealSwipeResult([void updates(MealSwipeResultBuilder b)]) =
      _$MealSwipeResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealSwipeResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealSwipeResult> get serializer =>
      _$MealSwipeResultSerializer();
}

class _$MealSwipeResultSerializer
    implements PrimitiveSerializer<MealSwipeResult> {
  @override
  final Iterable<Type> types = const [MealSwipeResult, _$MealSwipeResult];

  @override
  final String wireName = r'MealSwipeResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealSwipeResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MealSwipe),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealSwipeResult object, {
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
    required MealSwipeResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealSwipe),
          ) as MealSwipe;
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
  MealSwipeResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealSwipeResultBuilder();
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
