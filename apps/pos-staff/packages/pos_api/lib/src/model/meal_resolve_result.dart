//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/meal_resolve.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_resolve_result.g.dart';

/// MealResolveResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class MealResolveResult
    implements Built<MealResolveResult, MealResolveResultBuilder> {
  @BuiltValueField(wireName: r'data')
  MealResolve get data;

  MealResolveResult._();

  factory MealResolveResult([void updates(MealResolveResultBuilder b)]) =
      _$MealResolveResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealResolveResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealResolveResult> get serializer =>
      _$MealResolveResultSerializer();
}

class _$MealResolveResultSerializer
    implements PrimitiveSerializer<MealResolveResult> {
  @override
  final Iterable<Type> types = const [MealResolveResult, _$MealResolveResult];

  @override
  final String wireName = r'MealResolveResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealResolveResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MealResolve),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealResolveResult object, {
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
    required MealResolveResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealResolve),
          ) as MealResolve;
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
  MealResolveResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealResolveResultBuilder();
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
