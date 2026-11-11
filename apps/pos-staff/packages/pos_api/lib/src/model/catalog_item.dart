//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'catalog_item.g.dart';

/// CatalogItem
///
/// Properties:
/// * [productId]
/// * [price]
/// * [stockOnHand]
@BuiltValue()
abstract class CatalogItem implements Built<CatalogItem, CatalogItemBuilder> {
  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'stock_on_hand')
  num get stockOnHand;

  CatalogItem._();

  factory CatalogItem([void updates(CatalogItemBuilder b)]) = _$CatalogItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CatalogItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CatalogItem> get serializer => _$CatalogItemSerializer();
}

class _$CatalogItemSerializer implements PrimitiveSerializer<CatalogItem> {
  @override
  final Iterable<Type> types = const [CatalogItem, _$CatalogItem];

  @override
  final String wireName = r'CatalogItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CatalogItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'stock_on_hand';
    yield serializers.serialize(
      object.stockOnHand,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CatalogItem object, {
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
    required CatalogItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.price = valueDes;
          break;
        case r'stock_on_hand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.stockOnHand = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CatalogItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CatalogItemBuilder();
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
