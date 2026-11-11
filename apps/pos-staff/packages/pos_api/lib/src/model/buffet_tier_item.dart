//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'buffet_tier_item.g.dart';

/// BuffetTierItem
///
/// Properties:
/// * [id]
/// * [productId]
/// * [variantId] - Order the dish with this variant and the cover's `buffet_cover_line_id`.
/// * [name]
/// * [maxPerRound] - At most this many per guest in one round; no limit when null.
@BuiltValue()
abstract class BuffetTierItem
    implements Built<BuffetTierItem, BuffetTierItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'product_id')
  String get productId;

  /// Order the dish with this variant and the cover's `buffet_cover_line_id`.
  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// At most this many per guest in one round; no limit when null.
  @BuiltValueField(wireName: r'max_per_round')
  int? get maxPerRound;

  BuffetTierItem._();

  factory BuffetTierItem([void updates(BuffetTierItemBuilder b)]) =
      _$BuffetTierItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BuffetTierItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BuffetTierItem> get serializer =>
      _$BuffetTierItemSerializer();
}

class _$BuffetTierItemSerializer
    implements PrimitiveSerializer<BuffetTierItem> {
  @override
  final Iterable<Type> types = const [BuffetTierItem, _$BuffetTierItem];

  @override
  final String wireName = r'BuffetTierItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BuffetTierItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'max_per_round';
    yield object.maxPerRound == null
        ? null
        : serializers.serialize(
            object.maxPerRound,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    BuffetTierItem object, {
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
    required BuffetTierItemBuilder result,
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
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'max_per_round':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxPerRound = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BuffetTierItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BuffetTierItemBuilder();
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
