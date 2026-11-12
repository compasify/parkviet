//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/guest_order_modifier.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_item.g.dart';

/// GuestOrderItem
///
/// Properties:
/// * [variantId]
/// * [menuItemId]
/// * [name]
/// * [size]
/// * [quantity]
/// * [unitPrice] - The server's price per unit with options when the guest sent it.
/// * [amount]
/// * [note]
/// * [outcome]
/// * [reason] - Why an item was left out, `item_sold_out` or `item_unavailable`.
/// * [modifiers]
@BuiltValue()
abstract class GuestOrderItem
    implements Built<GuestOrderItem, GuestOrderItemBuilder> {
  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'menu_item_id')
  String get menuItemId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'size')
  String? get size;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// The server's price per unit with options when the guest sent it.
  @BuiltValueField(wireName: r'unit_price')
  String get unitPrice;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'outcome')
  GuestOrderItemOutcomeEnum? get outcome;
  // enum outcomeEnum {  added,  left_out,  ,  };

  /// Why an item was left out, `item_sold_out` or `item_unavailable`.
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<GuestOrderModifier> get modifiers;

  GuestOrderItem._();

  factory GuestOrderItem([void updates(GuestOrderItemBuilder b)]) =
      _$GuestOrderItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderItem> get serializer =>
      _$GuestOrderItemSerializer();
}

class _$GuestOrderItemSerializer
    implements PrimitiveSerializer<GuestOrderItem> {
  @override
  final Iterable<Type> types = const [GuestOrderItem, _$GuestOrderItem];

  @override
  final String wireName = r'GuestOrderItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'menu_item_id';
    yield serializers.serialize(
      object.menuItemId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'size';
    yield object.size == null
        ? null
        : serializers.serialize(
            object.size,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'unit_price';
    yield serializers.serialize(
      object.unitPrice,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    if (object.outcome != null) {
      yield r'outcome';
      yield serializers.serialize(
        object.outcome,
        specifiedType: const FullType.nullable(GuestOrderItemOutcomeEnum),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType: const FullType(BuiltList, [FullType(GuestOrderModifier)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrderItem object, {
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
    required GuestOrderItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'menu_item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.menuItemId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.size = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitPrice = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GuestOrderItemOutcomeEnum),
          ) as GuestOrderItemOutcomeEnum?;
          if (valueDes == null) continue;
          result.outcome = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(GuestOrderModifier)]),
          ) as BuiltList<GuestOrderModifier>;
          result.modifiers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestOrderItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderItemBuilder();
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

class GuestOrderItemOutcomeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'added')
  static const GuestOrderItemOutcomeEnum added =
      _$guestOrderItemOutcomeEnum_added;
  @BuiltValueEnumConst(wireName: r'left_out')
  static const GuestOrderItemOutcomeEnum leftOut =
      _$guestOrderItemOutcomeEnum_leftOut;

  static Serializer<GuestOrderItemOutcomeEnum> get serializer =>
      _$guestOrderItemOutcomeEnumSerializer;

  const GuestOrderItemOutcomeEnum._(String name) : super(name);

  static BuiltSet<GuestOrderItemOutcomeEnum> get values =>
      _$guestOrderItemOutcomeEnumValues;
  static GuestOrderItemOutcomeEnum valueOf(String name) =>
      _$guestOrderItemOutcomeEnumValueOf(name);
}
