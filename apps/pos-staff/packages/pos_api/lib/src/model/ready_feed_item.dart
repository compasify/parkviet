//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_modifier.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ready_feed_item.g.dart';

/// ReadyFeedItem
///
/// Properties:
/// * [id] - The kitchen ticket item.
/// * [name]
/// * [quantity]
/// * [modifiers]
/// * [status]
/// * [readyAt]
/// * [servedAt]
/// * [stationName]
/// * [workspaceId]
/// * [tableLabel]
/// * [resourceId]
/// * [tableName]
@BuiltValue()
abstract class ReadyFeedItem
    implements Built<ReadyFeedItem, ReadyFeedItemBuilder> {
  /// The kitchen ticket item.
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<KitchenTicketItemModifier> get modifiers;

  @BuiltValueField(wireName: r'status')
  ReadyFeedItemStatusEnum get status;
  // enum statusEnum {  ready,  served,  };

  @BuiltValueField(wireName: r'ready_at')
  DateTime? get readyAt;

  @BuiltValueField(wireName: r'served_at')
  DateTime? get servedAt;

  @BuiltValueField(wireName: r'station_name')
  String get stationName;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'table_label')
  String? get tableLabel;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'table_name')
  String get tableName;

  ReadyFeedItem._();

  factory ReadyFeedItem([void updates(ReadyFeedItemBuilder b)]) =
      _$ReadyFeedItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadyFeedItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadyFeedItem> get serializer =>
      _$ReadyFeedItemSerializer();
}

class _$ReadyFeedItemSerializer implements PrimitiveSerializer<ReadyFeedItem> {
  @override
  final Iterable<Type> types = const [ReadyFeedItem, _$ReadyFeedItem];

  @override
  final String wireName = r'ReadyFeedItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadyFeedItem object, {
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
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType:
          const FullType(BuiltList, [FullType(KitchenTicketItemModifier)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReadyFeedItemStatusEnum),
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
    yield r'station_name';
    yield serializers.serialize(
      object.stationName,
      specifiedType: const FullType(String),
    );
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'table_label';
    yield object.tableLabel == null
        ? null
        : serializers.serialize(
            object.tableLabel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'table_name';
    yield serializers.serialize(
      object.tableName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadyFeedItem object, {
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
    required ReadyFeedItemBuilder result,
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
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(KitchenTicketItemModifier)]),
          ) as BuiltList<KitchenTicketItemModifier>;
          result.modifiers.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadyFeedItemStatusEnum),
          ) as ReadyFeedItemStatusEnum;
          result.status = valueDes;
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
        case r'station_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stationName = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'table_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tableLabel = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'table_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tableName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReadyFeedItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadyFeedItemBuilder();
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

class ReadyFeedItemStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ready')
  static const ReadyFeedItemStatusEnum ready = _$readyFeedItemStatusEnum_ready;
  @BuiltValueEnumConst(wireName: r'served')
  static const ReadyFeedItemStatusEnum served =
      _$readyFeedItemStatusEnum_served;

  static Serializer<ReadyFeedItemStatusEnum> get serializer =>
      _$readyFeedItemStatusEnumSerializer;

  const ReadyFeedItemStatusEnum._(String name) : super(name);

  static BuiltSet<ReadyFeedItemStatusEnum> get values =>
      _$readyFeedItemStatusEnumValues;
  static ReadyFeedItemStatusEnum valueOf(String name) =>
      _$readyFeedItemStatusEnumValueOf(name);
}
