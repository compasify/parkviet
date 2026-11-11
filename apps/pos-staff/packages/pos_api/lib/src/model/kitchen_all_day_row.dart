//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_modifier.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_all_day_row.g.dart';

/// KitchenAllDayRow
///
/// Properties:
/// * [key] - Names the dish and its options; send it to the all-day bump.
/// * [name]
/// * [modifiers]
/// * [quantity]
/// * [oldestSentAt]
/// * [itemIds] - The open items of this dish, first sent first; a bump takes them in this order.
@BuiltValue()
abstract class KitchenAllDayRow
    implements Built<KitchenAllDayRow, KitchenAllDayRowBuilder> {
  /// Names the dish and its options; send it to the all-day bump.
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<KitchenTicketItemModifier> get modifiers;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'oldest_sent_at')
  DateTime get oldestSentAt;

  /// The open items of this dish, first sent first; a bump takes them in this order.
  @BuiltValueField(wireName: r'item_ids')
  BuiltList<String> get itemIds;

  KitchenAllDayRow._();

  factory KitchenAllDayRow([void updates(KitchenAllDayRowBuilder b)]) =
      _$KitchenAllDayRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenAllDayRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenAllDayRow> get serializer =>
      _$KitchenAllDayRowSerializer();
}

class _$KitchenAllDayRowSerializer
    implements PrimitiveSerializer<KitchenAllDayRow> {
  @override
  final Iterable<Type> types = const [KitchenAllDayRow, _$KitchenAllDayRow];

  @override
  final String wireName = r'KitchenAllDayRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenAllDayRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType:
          const FullType(BuiltList, [FullType(KitchenTicketItemModifier)]),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'oldest_sent_at';
    yield serializers.serialize(
      object.oldestSentAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'item_ids';
    yield serializers.serialize(
      object.itemIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenAllDayRow object, {
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
    required KitchenAllDayRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(KitchenTicketItemModifier)]),
          ) as BuiltList<KitchenTicketItemModifier>;
          result.modifiers.replace(valueDes);
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'oldest_sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.oldestSentAt = valueDes;
          break;
        case r'item_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.itemIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenAllDayRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenAllDayRowBuilder();
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
