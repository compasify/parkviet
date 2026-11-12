//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/meal_account.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_resolve.g.dart';

/// MealResolve
///
/// Properties:
/// * [match]
/// * [suggestions]
@BuiltValue()
abstract class MealResolve implements Built<MealResolve, MealResolveBuilder> {
  @BuiltValueField(wireName: r'match')
  MealAccount? get match;

  @BuiltValueField(wireName: r'suggestions')
  BuiltList<MealAccount> get suggestions;

  MealResolve._();

  factory MealResolve([void updates(MealResolveBuilder b)]) = _$MealResolve;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealResolveBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealResolve> get serializer => _$MealResolveSerializer();
}

class _$MealResolveSerializer implements PrimitiveSerializer<MealResolve> {
  @override
  final Iterable<Type> types = const [MealResolve, _$MealResolve];

  @override
  final String wireName = r'MealResolve';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealResolve object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.match != null) {
      yield r'match';
      yield serializers.serialize(
        object.match,
        specifiedType: const FullType.nullable(MealAccount),
      );
    }
    yield r'suggestions';
    yield serializers.serialize(
      object.suggestions,
      specifiedType: const FullType(BuiltList, [FullType(MealAccount)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealResolve object, {
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
    required MealResolveBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'match':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MealAccount),
          ) as MealAccount?;
          if (valueDes == null) continue;
          result.match = valueDes;
          break;
        case r'suggestions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MealAccount)]),
          ) as BuiltList<MealAccount>;
          result.suggestions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealResolve deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealResolveBuilder();
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
