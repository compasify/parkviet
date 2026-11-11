//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_components_inner.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_modifiers_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_ticket_item.g.dart';

/// KitchenTicketItem
///
/// Properties:
/// * [recalledAt] - The last time the item was called back to the kitchen.
/// * [recallCount]
/// * [prepSeconds] - From the send to ready, written when the item became ready.
/// * [late_] - It took longer than its station's red threshold.
/// * [id]
/// * [saleLineId] - Null once the line was voided off the order; the ticket keeps what it said.
/// * [name] - The item and its size, as sold.
/// * [modifiers]
/// * [components] - The parts of a combo, when the combo shows them on the kitchen screen.
/// * [note]
/// * [quantity]
/// * [status]
/// * [startedAt]
/// * [readyAt]
/// * [servedAt]
/// * [voidedAt]
@BuiltValue()
abstract class KitchenTicketItem
    implements Built<KitchenTicketItem, KitchenTicketItemBuilder> {
  /// The last time the item was called back to the kitchen.
  @BuiltValueField(wireName: r'recalled_at')
  DateTime? get recalledAt;

  @BuiltValueField(wireName: r'recall_count')
  int get recallCount;

  /// From the send to ready, written when the item became ready.
  @BuiltValueField(wireName: r'prep_seconds')
  int? get prepSeconds;

  /// It took longer than its station's red threshold.
  @BuiltValueField(wireName: r'late')
  bool get late_;

  @BuiltValueField(wireName: r'id')
  String get id;

  /// Null once the line was voided off the order; the ticket keeps what it said.
  @BuiltValueField(wireName: r'sale_line_id')
  String? get saleLineId;

  /// The item and its size, as sold.
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<KitchenTicketItemModifiersInner> get modifiers;

  /// The parts of a combo, when the combo shows them on the kitchen screen.
  @BuiltValueField(wireName: r'components')
  BuiltList<KitchenTicketItemComponentsInner> get components;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'status')
  KitchenTicketItemStatusEnum get status;
  // enum statusEnum {  new,  preparing,  ready,  served,  voided,  };

  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'ready_at')
  DateTime? get readyAt;

  @BuiltValueField(wireName: r'served_at')
  DateTime? get servedAt;

  @BuiltValueField(wireName: r'voided_at')
  DateTime? get voidedAt;

  KitchenTicketItem._();

  factory KitchenTicketItem([void updates(KitchenTicketItemBuilder b)]) =
      _$KitchenTicketItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenTicketItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenTicketItem> get serializer =>
      _$KitchenTicketItemSerializer();
}

class _$KitchenTicketItemSerializer
    implements PrimitiveSerializer<KitchenTicketItem> {
  @override
  final Iterable<Type> types = const [KitchenTicketItem, _$KitchenTicketItem];

  @override
  final String wireName = r'KitchenTicketItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenTicketItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recalled_at';
    yield object.recalledAt == null
        ? null
        : serializers.serialize(
            object.recalledAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'recall_count';
    yield serializers.serialize(
      object.recallCount,
      specifiedType: const FullType(int),
    );
    yield r'prep_seconds';
    yield object.prepSeconds == null
        ? null
        : serializers.serialize(
            object.prepSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'late';
    yield serializers.serialize(
      object.late_,
      specifiedType: const FullType(bool),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sale_line_id';
    yield object.saleLineId == null
        ? null
        : serializers.serialize(
            object.saleLineId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType: const FullType(
          BuiltList, [FullType(KitchenTicketItemModifiersInner)]),
    );
    yield r'components';
    yield serializers.serialize(
      object.components,
      specifiedType: const FullType(
          BuiltList, [FullType(KitchenTicketItemComponentsInner)]),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(KitchenTicketItemStatusEnum),
    );
    yield r'started_at';
    yield object.startedAt == null
        ? null
        : serializers.serialize(
            object.startedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'ready_at';
    yield object.readyAt == null
        ? null
        : serializers.serialize(
            object.readyAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'served_at';
    yield object.servedAt == null
        ? null
        : serializers.serialize(
            object.servedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'voided_at';
    yield object.voidedAt == null
        ? null
        : serializers.serialize(
            object.voidedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenTicketItem object, {
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
    required KitchenTicketItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recalled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.recalledAt = valueDes;
          break;
        case r'recall_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.recallCount = valueDes;
          break;
        case r'prep_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.prepSeconds = valueDes;
          break;
        case r'late':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.late_ = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'sale_line_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.saleLineId = valueDes;
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
                BuiltList, [FullType(KitchenTicketItemModifiersInner)]),
          ) as BuiltList<KitchenTicketItemModifiersInner>;
          result.modifiers.replace(valueDes);
          break;
        case r'components':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(KitchenTicketItemComponentsInner)]),
          ) as BuiltList<KitchenTicketItemComponentsInner>;
          result.components.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenTicketItemStatusEnum),
          ) as KitchenTicketItemStatusEnum;
          result.status = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'ready_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readyAt = valueDes;
          break;
        case r'served_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.servedAt = valueDes;
          break;
        case r'voided_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.voidedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenTicketItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenTicketItemBuilder();
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

class KitchenTicketItemStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'new')
  static const KitchenTicketItemStatusEnum new_ =
      _$kitchenTicketItemStatusEnum_new_;
  @BuiltValueEnumConst(wireName: r'preparing')
  static const KitchenTicketItemStatusEnum preparing =
      _$kitchenTicketItemStatusEnum_preparing;
  @BuiltValueEnumConst(wireName: r'ready')
  static const KitchenTicketItemStatusEnum ready =
      _$kitchenTicketItemStatusEnum_ready;
  @BuiltValueEnumConst(wireName: r'served')
  static const KitchenTicketItemStatusEnum served =
      _$kitchenTicketItemStatusEnum_served;
  @BuiltValueEnumConst(wireName: r'voided')
  static const KitchenTicketItemStatusEnum voided =
      _$kitchenTicketItemStatusEnum_voided;

  static Serializer<KitchenTicketItemStatusEnum> get serializer =>
      _$kitchenTicketItemStatusEnumSerializer;

  const KitchenTicketItemStatusEnum._(String name) : super(name);

  static BuiltSet<KitchenTicketItemStatusEnum> get values =>
      _$kitchenTicketItemStatusEnumValues;
  static KitchenTicketItemStatusEnum valueOf(String name) =>
      _$kitchenTicketItemStatusEnumValueOf(name);
}
