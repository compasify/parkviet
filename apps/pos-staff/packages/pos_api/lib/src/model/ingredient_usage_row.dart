//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ingredient_usage_row.g.dart';

/// IngredientUsageRow
///
/// Properties:
/// * [businessDate]
/// * [ingredient]
/// * [ingredientSku]
/// * [menuItem]
/// * [quantity]
/// * [unit]
/// * [cost]
/// * [costMissing] - Some of the rows had no cost price and count as zero
@BuiltValue()
abstract class IngredientUsageRow
    implements Built<IngredientUsageRow, IngredientUsageRowBuilder> {
  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'ingredient')
  String get ingredient;

  @BuiltValueField(wireName: r'ingredient_sku')
  String? get ingredientSku;

  @BuiltValueField(wireName: r'menu_item')
  String get menuItem;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'unit')
  String get unit;

  @BuiltValueField(wireName: r'cost')
  String get cost;

  /// Some of the rows had no cost price and count as zero
  @BuiltValueField(wireName: r'cost_missing')
  bool get costMissing;

  IngredientUsageRow._();

  factory IngredientUsageRow([void updates(IngredientUsageRowBuilder b)]) =
      _$IngredientUsageRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IngredientUsageRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IngredientUsageRow> get serializer =>
      _$IngredientUsageRowSerializer();
}

class _$IngredientUsageRowSerializer
    implements PrimitiveSerializer<IngredientUsageRow> {
  @override
  final Iterable<Type> types = const [IngredientUsageRow, _$IngredientUsageRow];

  @override
  final String wireName = r'IngredientUsageRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IngredientUsageRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    yield r'ingredient';
    yield serializers.serialize(
      object.ingredient,
      specifiedType: const FullType(String),
    );
    yield r'ingredient_sku';
    yield object.ingredientSku == null
        ? null
        : serializers.serialize(
            object.ingredientSku,
            specifiedType: const FullType.nullable(String),
          );
    yield r'menu_item';
    yield serializers.serialize(
      object.menuItem,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
    yield r'cost';
    yield serializers.serialize(
      object.cost,
      specifiedType: const FullType(String),
    );
    yield r'cost_missing';
    yield serializers.serialize(
      object.costMissing,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IngredientUsageRow object, {
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
    required IngredientUsageRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'ingredient':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ingredient = valueDes;
          break;
        case r'ingredient_sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ingredientSku = valueDes;
          break;
        case r'menu_item':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.menuItem = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unit = valueDes;
          break;
        case r'cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cost = valueDes;
          break;
        case r'cost_missing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.costMissing = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IngredientUsageRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IngredientUsageRowBuilder();
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
