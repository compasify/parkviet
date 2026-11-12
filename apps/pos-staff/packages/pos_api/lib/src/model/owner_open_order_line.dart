//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_open_order_line.g.dart';

/// OwnerOpenOrderLine
///
/// Properties:
/// * [id]
/// * [name]
/// * [quantity]
/// * [unit] - The sale unit; `item` for a count.
/// * [amount] - After the line's discounts.
/// * [kitchen] - `unsent` while some of it is not with the kitchen yet; `waiting` while some is new or being made; `none` without a kitchen.
@BuiltValue()
abstract class OwnerOpenOrderLine
    implements Built<OwnerOpenOrderLine, OwnerOpenOrderLineBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  /// The sale unit; `item` for a count.
  @BuiltValueField(wireName: r'unit')
  String? get unit;

  /// After the line's discounts.
  @BuiltValueField(wireName: r'amount')
  String get amount;

  /// `unsent` while some of it is not with the kitchen yet; `waiting` while some is new or being made; `none` without a kitchen.
  @BuiltValueField(wireName: r'kitchen')
  OwnerOpenOrderLineKitchenEnum get kitchen;
  // enum kitchenEnum {  none,  unsent,  waiting,  ready,  served,  };

  OwnerOpenOrderLine._();

  factory OwnerOpenOrderLine([void updates(OwnerOpenOrderLineBuilder b)]) =
      _$OwnerOpenOrderLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerOpenOrderLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerOpenOrderLine> get serializer =>
      _$OwnerOpenOrderLineSerializer();
}

class _$OwnerOpenOrderLineSerializer
    implements PrimitiveSerializer<OwnerOpenOrderLine> {
  @override
  final Iterable<Type> types = const [OwnerOpenOrderLine, _$OwnerOpenOrderLine];

  @override
  final String wireName = r'OwnerOpenOrderLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerOpenOrderLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'unit';
    yield object.unit == null
        ? null
        : serializers.serialize(
            object.unit,
            specifiedType: const FullType.nullable(String),
          );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'kitchen';
    yield serializers.serialize(
      object.kitchen,
      specifiedType: const FullType(OwnerOpenOrderLineKitchenEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerOpenOrderLine object, {
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
    required OwnerOpenOrderLineBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unit = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'kitchen':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnerOpenOrderLineKitchenEnum),
          ) as OwnerOpenOrderLineKitchenEnum;
          result.kitchen = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerOpenOrderLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerOpenOrderLineBuilder();
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

/// `unsent` while some of it is not with the kitchen yet; `waiting` while some is new or being made; `none` without a kitchen.
class OwnerOpenOrderLineKitchenEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const OwnerOpenOrderLineKitchenEnum none =
      _$ownerOpenOrderLineKitchenEnum_none;
  @BuiltValueEnumConst(wireName: r'unsent')
  static const OwnerOpenOrderLineKitchenEnum unsent =
      _$ownerOpenOrderLineKitchenEnum_unsent;
  @BuiltValueEnumConst(wireName: r'waiting')
  static const OwnerOpenOrderLineKitchenEnum waiting =
      _$ownerOpenOrderLineKitchenEnum_waiting;
  @BuiltValueEnumConst(wireName: r'ready')
  static const OwnerOpenOrderLineKitchenEnum ready =
      _$ownerOpenOrderLineKitchenEnum_ready;
  @BuiltValueEnumConst(wireName: r'served')
  static const OwnerOpenOrderLineKitchenEnum served =
      _$ownerOpenOrderLineKitchenEnum_served;

  static Serializer<OwnerOpenOrderLineKitchenEnum> get serializer =>
      _$ownerOpenOrderLineKitchenEnumSerializer;

  const OwnerOpenOrderLineKitchenEnum._(String name) : super(name);

  static BuiltSet<OwnerOpenOrderLineKitchenEnum> get values =>
      _$ownerOpenOrderLineKitchenEnumValues;
  static OwnerOpenOrderLineKitchenEnum valueOf(String name) =>
      _$ownerOpenOrderLineKitchenEnumValueOf(name);
}
