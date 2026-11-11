//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/recipe_ingredients_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe.g.dart';

/// Recipe
///
/// Properties:
/// * [id]
/// * [version]
/// * [active]
/// * [createdAt]
/// * [estimatedCost] - At today's cost prices; null while an ingredient has none
/// * [ingredients]
@BuiltValue()
abstract class Recipe implements Built<Recipe, RecipeBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  /// At today's cost prices; null while an ingredient has none
  @BuiltValueField(wireName: r'estimated_cost')
  String? get estimatedCost;

  @BuiltValueField(wireName: r'ingredients')
  BuiltList<RecipeIngredientsInner> get ingredients;

  Recipe._();

  factory Recipe([void updates(RecipeBuilder b)]) = _$Recipe;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Recipe> get serializer => _$RecipeSerializer();
}

class _$RecipeSerializer implements PrimitiveSerializer<Recipe> {
  @override
  final Iterable<Type> types = const [Recipe, _$Recipe];

  @override
  final String wireName = r'Recipe';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Recipe object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'estimated_cost';
    yield object.estimatedCost == null
        ? null
        : serializers.serialize(
            object.estimatedCost,
            specifiedType: const FullType.nullable(String),
          );
    yield r'ingredients';
    yield serializers.serialize(
      object.ingredients,
      specifiedType:
          const FullType(BuiltList, [FullType(RecipeIngredientsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Recipe object, {
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
    required RecipeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'estimated_cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.estimatedCost = valueDes;
          break;
        case r'ingredients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(RecipeIngredientsInner)]),
          ) as BuiltList<RecipeIngredientsInner>;
          result.ingredients.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Recipe deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeBuilder();
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
