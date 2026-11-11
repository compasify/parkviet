//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/recipe_owner_versions_inner.dart';
import 'package:pos_api/src/model/recipe.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_owner.g.dart';

/// RecipeOwner
///
/// Properties:
/// * [ownerType]
/// * [ownerId]
/// * [trackInventory] - Whether a size still keeps its own stock; null for an option
/// * [active]
/// * [versions]
@BuiltValue()
abstract class RecipeOwner implements Built<RecipeOwner, RecipeOwnerBuilder> {
  @BuiltValueField(wireName: r'owner_type')
  RecipeOwnerOwnerTypeEnum get ownerType;
  // enum ownerTypeEnum {  variant,  modifier_option,  };

  @BuiltValueField(wireName: r'owner_id')
  String get ownerId;

  /// Whether a size still keeps its own stock; null for an option
  @BuiltValueField(wireName: r'track_inventory')
  bool? get trackInventory;

  @BuiltValueField(wireName: r'active')
  Recipe? get active;

  @BuiltValueField(wireName: r'versions')
  BuiltList<RecipeOwnerVersionsInner> get versions;

  RecipeOwner._();

  factory RecipeOwner([void updates(RecipeOwnerBuilder b)]) = _$RecipeOwner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeOwnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecipeOwner> get serializer => _$RecipeOwnerSerializer();
}

class _$RecipeOwnerSerializer implements PrimitiveSerializer<RecipeOwner> {
  @override
  final Iterable<Type> types = const [RecipeOwner, _$RecipeOwner];

  @override
  final String wireName = r'RecipeOwner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecipeOwner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'owner_type';
    yield serializers.serialize(
      object.ownerType,
      specifiedType: const FullType(RecipeOwnerOwnerTypeEnum),
    );
    yield r'owner_id';
    yield serializers.serialize(
      object.ownerId,
      specifiedType: const FullType(String),
    );
    yield r'track_inventory';
    yield object.trackInventory == null
        ? null
        : serializers.serialize(
            object.trackInventory,
            specifiedType: const FullType.nullable(bool),
          );
    yield r'active';
    yield object.active == null
        ? null
        : serializers.serialize(
            object.active,
            specifiedType: const FullType.nullable(Recipe),
          );
    yield r'versions';
    yield serializers.serialize(
      object.versions,
      specifiedType:
          const FullType(BuiltList, [FullType(RecipeOwnerVersionsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecipeOwner object, {
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
    required RecipeOwnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'owner_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RecipeOwnerOwnerTypeEnum),
          ) as RecipeOwnerOwnerTypeEnum;
          result.ownerType = valueDes;
          break;
        case r'owner_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
          break;
        case r'track_inventory':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.trackInventory = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Recipe),
          ) as Recipe?;
          if (valueDes == null) continue;
          result.active.replace(valueDes);
          break;
        case r'versions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(RecipeOwnerVersionsInner)]),
          ) as BuiltList<RecipeOwnerVersionsInner>;
          result.versions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecipeOwner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeOwnerBuilder();
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

class RecipeOwnerOwnerTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'variant')
  static const RecipeOwnerOwnerTypeEnum variant =
      _$recipeOwnerOwnerTypeEnum_variant;
  @BuiltValueEnumConst(wireName: r'modifier_option')
  static const RecipeOwnerOwnerTypeEnum modifierOption =
      _$recipeOwnerOwnerTypeEnum_modifierOption;

  static Serializer<RecipeOwnerOwnerTypeEnum> get serializer =>
      _$recipeOwnerOwnerTypeEnumSerializer;

  const RecipeOwnerOwnerTypeEnum._(String name) : super(name);

  static BuiltSet<RecipeOwnerOwnerTypeEnum> get values =>
      _$recipeOwnerOwnerTypeEnumValues;
  static RecipeOwnerOwnerTypeEnum valueOf(String name) =>
      _$recipeOwnerOwnerTypeEnumValueOf(name);
}
