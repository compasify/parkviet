//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/buffet_tier_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'buffet_tier.g.dart';

/// BuffetTier
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [name]
/// * [status]
/// * [productId] - The ticket sold per guest.
/// * [productName]
/// * [variantId]
/// * [durationMinutes] - How long a table eats; the table board warns near the end.
/// * [roundItemLimit] - Dishes per guest in one round; no limit when null.
/// * [roundIntervalMinutes] - Minutes between two rounds.
/// * [items]
@BuiltValue()
abstract class BuffetTier implements Built<BuffetTier, BuffetTierBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'status')
  BuffetTierStatusEnum get status;
  // enum statusEnum {  active,  archived,  };

  /// The ticket sold per guest.
  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  /// How long a table eats; the table board warns near the end.
  @BuiltValueField(wireName: r'duration_minutes')
  int get durationMinutes;

  /// Dishes per guest in one round; no limit when null.
  @BuiltValueField(wireName: r'round_item_limit')
  int? get roundItemLimit;

  /// Minutes between two rounds.
  @BuiltValueField(wireName: r'round_interval_minutes')
  int get roundIntervalMinutes;

  @BuiltValueField(wireName: r'items')
  BuiltList<BuffetTierItem> get items;

  BuffetTier._();

  factory BuffetTier([void updates(BuffetTierBuilder b)]) = _$BuffetTier;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BuffetTierBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BuffetTier> get serializer => _$BuffetTierSerializer();
}

class _$BuffetTierSerializer implements PrimitiveSerializer<BuffetTier> {
  @override
  final Iterable<Type> types = const [BuffetTier, _$BuffetTier];

  @override
  final String wireName = r'BuffetTier';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BuffetTier object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(BuffetTierStatusEnum),
    );
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'duration_minutes';
    yield serializers.serialize(
      object.durationMinutes,
      specifiedType: const FullType(int),
    );
    yield r'round_item_limit';
    yield object.roundItemLimit == null
        ? null
        : serializers.serialize(
            object.roundItemLimit,
            specifiedType: const FullType.nullable(int),
          );
    yield r'round_interval_minutes';
    yield serializers.serialize(
      object.roundIntervalMinutes,
      specifiedType: const FullType(int),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(BuffetTierItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BuffetTier object, {
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
    required BuffetTierBuilder result,
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
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuffetTierStatusEnum),
          ) as BuffetTierStatusEnum;
          result.status = valueDes;
          break;
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'product_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productName = valueDes;
          break;
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'duration_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationMinutes = valueDes;
          break;
        case r'round_item_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.roundItemLimit = valueDes;
          break;
        case r'round_interval_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.roundIntervalMinutes = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(BuffetTierItem)]),
          ) as BuiltList<BuffetTierItem>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BuffetTier deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BuffetTierBuilder();
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

class BuffetTierStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const BuffetTierStatusEnum active = _$buffetTierStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'archived')
  static const BuffetTierStatusEnum archived = _$buffetTierStatusEnum_archived;

  static Serializer<BuffetTierStatusEnum> get serializer =>
      _$buffetTierStatusEnumSerializer;

  const BuffetTierStatusEnum._(String name) : super(name);

  static BuiltSet<BuffetTierStatusEnum> get values =>
      _$buffetTierStatusEnumValues;
  static BuffetTierStatusEnum valueOf(String name) =>
      _$buffetTierStatusEnumValueOf(name);
}
