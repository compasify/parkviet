//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/recipe_owner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_recipe200_response.g.dart';

/// PosRecipe200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosRecipe200Response
    implements Built<PosRecipe200Response, PosRecipe200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RecipeOwner get data;

  PosRecipe200Response._();

  factory PosRecipe200Response([void updates(PosRecipe200ResponseBuilder b)]) =
      _$PosRecipe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosRecipe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosRecipe200Response> get serializer =>
      _$PosRecipe200ResponseSerializer();
}

class _$PosRecipe200ResponseSerializer
    implements PrimitiveSerializer<PosRecipe200Response> {
  @override
  final Iterable<Type> types = const [
    PosRecipe200Response,
    _$PosRecipe200Response
  ];

  @override
  final String wireName = r'PosRecipe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosRecipe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RecipeOwner),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosRecipe200Response object, {
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
    required PosRecipe200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RecipeOwner),
          ) as RecipeOwner;
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
  PosRecipe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosRecipe200ResponseBuilder();
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
