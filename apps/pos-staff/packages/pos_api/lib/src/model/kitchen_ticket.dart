//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:pos_api/src/model/kitchen_ticket_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_ticket.g.dart';

/// What one send told one station. Written once; only item statuses move.
///
/// Properties:
/// * [id]
/// * [workspaceId]
/// * [branchId]
/// * [kitchenStationId]
/// * [stationName]
/// * [stationKind]
/// * [sequence] - 1, 2, 3 … within the order.
/// * [kind]
/// * [serviceMode]
/// * [businessDate]
/// * [header] - Copied at the send - service mode, order source, customer name, note, register, and for counter service the call number (`order_number`) and the guest's name (`guest_name`). A delivery platform's order (`order_source` grabfood or shopeefood) adds the platform's order code (`platform_order_ref`) and the driver's pickup code (`pickup_code`).
/// * [sentAt]
/// * [done]
/// * [doneAt]
/// * [items]
@BuiltValue()
abstract class KitchenTicket
    implements Built<KitchenTicket, KitchenTicketBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'kitchen_station_id')
  String get kitchenStationId;

  @BuiltValueField(wireName: r'station_name')
  String get stationName;

  @BuiltValueField(wireName: r'station_kind')
  KitchenTicketStationKindEnum get stationKind;
  // enum stationKindEnum {  prep,  bar,  expo,  };

  /// 1, 2, 3 … within the order.
  @BuiltValueField(wireName: r'sequence')
  int get sequence;

  @BuiltValueField(wireName: r'kind')
  KitchenTicketKindEnum get kind;
  // enum kindEnum {  fire,  void,  };

  @BuiltValueField(wireName: r'service_mode')
  String get serviceMode;

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  /// Copied at the send - service mode, order source, customer name, note, register, and for counter service the call number (`order_number`) and the guest's name (`guest_name`). A delivery platform's order (`order_source` grabfood or shopeefood) adds the platform's order code (`platform_order_ref`) and the driver's pickup code (`pickup_code`).
  @BuiltValueField(wireName: r'header')
  BuiltMap<String, JsonObject?> get header;

  @BuiltValueField(wireName: r'sent_at')
  DateTime get sentAt;

  @BuiltValueField(wireName: r'done')
  bool get done;

  @BuiltValueField(wireName: r'done_at')
  DateTime? get doneAt;

  @BuiltValueField(wireName: r'items')
  BuiltList<KitchenTicketItem> get items;

  KitchenTicket._();

  factory KitchenTicket([void updates(KitchenTicketBuilder b)]) =
      _$KitchenTicket;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenTicketBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenTicket> get serializer =>
      _$KitchenTicketSerializer();
}

class _$KitchenTicketSerializer implements PrimitiveSerializer<KitchenTicket> {
  @override
  final Iterable<Type> types = const [KitchenTicket, _$KitchenTicket];

  @override
  final String wireName = r'KitchenTicket';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenTicket object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'kitchen_station_id';
    yield serializers.serialize(
      object.kitchenStationId,
      specifiedType: const FullType(String),
    );
    yield r'station_name';
    yield serializers.serialize(
      object.stationName,
      specifiedType: const FullType(String),
    );
    yield r'station_kind';
    yield serializers.serialize(
      object.stationKind,
      specifiedType: const FullType(KitchenTicketStationKindEnum),
    );
    yield r'sequence';
    yield serializers.serialize(
      object.sequence,
      specifiedType: const FullType(int),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(KitchenTicketKindEnum),
    );
    yield r'service_mode';
    yield serializers.serialize(
      object.serviceMode,
      specifiedType: const FullType(String),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    yield r'header';
    yield serializers.serialize(
      object.header,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'sent_at';
    yield serializers.serialize(
      object.sentAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'done';
    yield serializers.serialize(
      object.done,
      specifiedType: const FullType(bool),
    );
    yield r'done_at';
    yield object.doneAt == null
        ? null
        : serializers.serialize(
            object.doneAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicketItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenTicket object, {
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
    required KitchenTicketBuilder result,
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
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'kitchen_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kitchenStationId = valueDes;
          break;
        case r'station_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stationName = valueDes;
          break;
        case r'station_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenTicketStationKindEnum),
          ) as KitchenTicketStationKindEnum;
          result.stationKind = valueDes;
          break;
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sequence = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenTicketKindEnum),
          ) as KitchenTicketKindEnum;
          result.kind = valueDes;
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serviceMode = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'header':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.header.replace(valueDes);
          break;
        case r'sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.sentAt = valueDes;
          break;
        case r'done':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.done = valueDes;
          break;
        case r'done_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.doneAt = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenTicketItem)]),
          ) as BuiltList<KitchenTicketItem>;
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
  KitchenTicket deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenTicketBuilder();
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

class KitchenTicketStationKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'prep')
  static const KitchenTicketStationKindEnum prep =
      _$kitchenTicketStationKindEnum_prep;
  @BuiltValueEnumConst(wireName: r'bar')
  static const KitchenTicketStationKindEnum bar =
      _$kitchenTicketStationKindEnum_bar;
  @BuiltValueEnumConst(wireName: r'expo')
  static const KitchenTicketStationKindEnum expo =
      _$kitchenTicketStationKindEnum_expo;

  static Serializer<KitchenTicketStationKindEnum> get serializer =>
      _$kitchenTicketStationKindEnumSerializer;

  const KitchenTicketStationKindEnum._(String name) : super(name);

  static BuiltSet<KitchenTicketStationKindEnum> get values =>
      _$kitchenTicketStationKindEnumValues;
  static KitchenTicketStationKindEnum valueOf(String name) =>
      _$kitchenTicketStationKindEnumValueOf(name);
}

class KitchenTicketKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fire')
  static const KitchenTicketKindEnum fire = _$kitchenTicketKindEnum_fire;
  @BuiltValueEnumConst(wireName: r'void')
  static const KitchenTicketKindEnum void_ = _$kitchenTicketKindEnum_void_;

  static Serializer<KitchenTicketKindEnum> get serializer =>
      _$kitchenTicketKindEnumSerializer;

  const KitchenTicketKindEnum._(String name) : super(name);

  static BuiltSet<KitchenTicketKindEnum> get values =>
      _$kitchenTicketKindEnumValues;
  static KitchenTicketKindEnum valueOf(String name) =>
      _$kitchenTicketKindEnumValueOf(name);
}
