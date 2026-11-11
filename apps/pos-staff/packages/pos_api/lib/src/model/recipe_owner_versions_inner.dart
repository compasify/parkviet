//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_owner_versions_inner.g.dart';

/// RecipeOwnerVersionsInner
///
/// Properties:
/// * [id]
/// * [version]
/// * [active]
/// * [createdAt]
/// * [ingredients]
@BuiltValue()
abstract class RecipeOwnerVersionsInner
    implements
        Built<RecipeOwnerVersionsInner, RecipeOwnerVersionsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'ingredients')
  int get ingredients;

  RecipeOwnerVersionsInner._();

  factory RecipeOwnerVersionsInner(
          [void updates(RecipeOwnerVersionsInnerBuilder b)]) =
      _$RecipeOwnerVersionsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeOwnerVersionsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecipeOwnerVersionsInner> get serializer =>
      _$RecipeOwnerVersionsInnerSerializer();
}

class _$RecipeOwnerVersionsInnerSerializer
    implements PrimitiveSerializer<RecipeOwnerVersionsInner> {
  @override
  final Iterable<Type> types = const [
    RecipeOwnerVersionsInner,
    _$RecipeOwnerVersionsInner
  ];

  @override
  final String wireName = r'RecipeOwnerVersionsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecipeOwnerVersionsInner object, {
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
    yield r'ingredients';
    yield serializers.serialize(
      object.ingredients,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecipeOwnerVersionsInner object, {
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
    required RecipeOwnerVersionsInnerBuilder result,
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
        case r'ingredients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ingredients = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecipeOwnerVersionsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeOwnerVersionsInnerBuilder();
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
