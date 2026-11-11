//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_ingredients_inner.g.dart';

/// RecipeIngredientsInner
///
/// Properties:
/// * [id]
/// * [variantId]
/// * [name]
/// * [sku]
/// * [optionsText]
/// * [quantity]
/// * [unitCode]
/// * [baseQuantity] - The quantity in the ingredient's stock unit
/// * [baseUnit]
/// * [unitCost] - Cost per stock unit now
/// * [cost]
@BuiltValue()
abstract class RecipeIngredientsInner
    implements Built<RecipeIngredientsInner, RecipeIngredientsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'options_text')
  String? get optionsText;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'unit_code')
  String get unitCode;

  /// The quantity in the ingredient's stock unit
  @BuiltValueField(wireName: r'base_quantity')
  int get baseQuantity;

  @BuiltValueField(wireName: r'base_unit')
  String get baseUnit;

  /// Cost per stock unit now
  @BuiltValueField(wireName: r'unit_cost')
  String? get unitCost;

  @BuiltValueField(wireName: r'cost')
  String? get cost;

  RecipeIngredientsInner._();

  factory RecipeIngredientsInner(
          [void updates(RecipeIngredientsInnerBuilder b)]) =
      _$RecipeIngredientsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeIngredientsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecipeIngredientsInner> get serializer =>
      _$RecipeIngredientsInnerSerializer();
}

class _$RecipeIngredientsInnerSerializer
    implements PrimitiveSerializer<RecipeIngredientsInner> {
  @override
  final Iterable<Type> types = const [
    RecipeIngredientsInner,
    _$RecipeIngredientsInner
  ];

  @override
  final String wireName = r'RecipeIngredientsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecipeIngredientsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sku';
    yield object.sku == null
        ? null
        : serializers.serialize(
            object.sku,
            specifiedType: const FullType.nullable(String),
          );
    yield r'options_text';
    yield object.optionsText == null
        ? null
        : serializers.serialize(
            object.optionsText,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'unit_code';
    yield serializers.serialize(
      object.unitCode,
      specifiedType: const FullType(String),
    );
    yield r'base_quantity';
    yield serializers.serialize(
      object.baseQuantity,
      specifiedType: const FullType(int),
    );
    yield r'base_unit';
    yield serializers.serialize(
      object.baseUnit,
      specifiedType: const FullType(String),
    );
    yield r'unit_cost';
    yield object.unitCost == null
        ? null
        : serializers.serialize(
            object.unitCost,
            specifiedType: const FullType.nullable(String),
          );
    yield r'cost';
    yield object.cost == null
        ? null
        : serializers.serialize(
            object.cost,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecipeIngredientsInner object, {
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
    required RecipeIngredientsInnerBuilder result,
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
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'options_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.optionsText = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'unit_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitCode = valueDes;
          break;
        case r'base_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.baseQuantity = valueDes;
          break;
        case r'base_unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.baseUnit = valueDes;
          break;
        case r'unit_cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitCost = valueDes;
          break;
        case r'cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cost = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecipeIngredientsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeIngredientsInnerBuilder();
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
