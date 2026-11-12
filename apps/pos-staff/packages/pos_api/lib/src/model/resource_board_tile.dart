//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/resource_board_order.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/resource_next_reservation.dart';
import 'package:pos_api/src/model/resource_board_timed.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_board_tile.g.dart';

/// ResourceBoardTile
///
/// Properties:
/// * [timed] - The room's clock of play time, when an open order has one.
/// * [nextReservation] - The table's next active booking in the coming 12 hours.
/// * [buffetEndsAt] - The earliest buffet end of the table's open orders.
/// * [id]
/// * [areaId]
/// * [name]
/// * [kind]
/// * [capacity]
/// * [shape]
/// * [x]
/// * [y]
/// * [w]
/// * [h]
/// * [rotation]
/// * [manualStatus]
/// * [state] - Strongest first: out_of_service, cleaning (no open order), payment_requested, prebilled, ending_soon (a running clock is within ten minutes of its planned end), waiting_long (a kitchen item waited past its station's threshold), playing (a clock is running), ordered, occupied, reserved (no open order and a booking starts within the hour), available.
/// * [guestCount]
/// * [seatedMinutes] - Minutes since the oldest open order was opened, on the server clock.
/// * [subtotal]
/// * [currency]
/// * [paymentRequested]
/// * [editedAfterPrebill]
/// * [orders]
@BuiltValue()
abstract class ResourceBoardTile
    implements Built<ResourceBoardTile, ResourceBoardTileBuilder> {
  /// The room's clock of play time, when an open order has one.
  @BuiltValueField(wireName: r'timed')
  ResourceBoardTimed? get timed;

  /// The table's next active booking in the coming 12 hours.
  @BuiltValueField(wireName: r'next_reservation')
  ResourceNextReservation? get nextReservation;

  /// The earliest buffet end of the table's open orders.
  @BuiltValueField(wireName: r'buffet_ends_at')
  DateTime? get buffetEndsAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  ResourceBoardTileKindEnum get kind;
  // enum kindEnum {  table,  room,  billiard,  vip,  };

  @BuiltValueField(wireName: r'capacity')
  int get capacity;

  @BuiltValueField(wireName: r'shape')
  ResourceBoardTileShapeEnum get shape;
  // enum shapeEnum {  rect,  round,  };

  @BuiltValueField(wireName: r'x')
  int get x;

  @BuiltValueField(wireName: r'y')
  int get y;

  @BuiltValueField(wireName: r'w')
  int get w;

  @BuiltValueField(wireName: r'h')
  int get h;

  @BuiltValueField(wireName: r'rotation')
  int get rotation;

  @BuiltValueField(wireName: r'manual_status')
  ResourceBoardTileManualStatusEnum get manualStatus;
  // enum manualStatusEnum {  available,  cleaning,  out_of_service,  };

  /// Strongest first: out_of_service, cleaning (no open order), payment_requested, prebilled, ending_soon (a running clock is within ten minutes of its planned end), waiting_long (a kitchen item waited past its station's threshold), playing (a clock is running), ordered, occupied, reserved (no open order and a booking starts within the hour), available.
  @BuiltValueField(wireName: r'state')
  ResourceBoardTileStateEnum get state;
  // enum stateEnum {  available,  reserved,  occupied,  ordered,  waiting_long,  playing,  ending_soon,  payment_requested,  prebilled,  cleaning,  out_of_service,  };

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  /// Minutes since the oldest open order was opened, on the server clock.
  @BuiltValueField(wireName: r'seated_minutes')
  int? get seatedMinutes;

  @BuiltValueField(wireName: r'subtotal')
  String? get subtotal;

  @BuiltValueField(wireName: r'currency')
  String? get currency;

  @BuiltValueField(wireName: r'payment_requested')
  bool get paymentRequested;

  @BuiltValueField(wireName: r'edited_after_prebill')
  bool get editedAfterPrebill;

  @BuiltValueField(wireName: r'orders')
  BuiltList<ResourceBoardOrder> get orders;

  ResourceBoardTile._();

  factory ResourceBoardTile([void updates(ResourceBoardTileBuilder b)]) =
      _$ResourceBoardTile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBoardTileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceBoardTile> get serializer =>
      _$ResourceBoardTileSerializer();
}

class _$ResourceBoardTileSerializer
    implements PrimitiveSerializer<ResourceBoardTile> {
  @override
  final Iterable<Type> types = const [ResourceBoardTile, _$ResourceBoardTile];

  @override
  final String wireName = r'ResourceBoardTile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceBoardTile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'timed';
    yield object.timed == null
        ? null
        : serializers.serialize(
            object.timed,
            specifiedType: const FullType.nullable(ResourceBoardTimed),
          );
    yield r'next_reservation';
    yield object.nextReservation == null
        ? null
        : serializers.serialize(
            object.nextReservation,
            specifiedType: const FullType.nullable(ResourceNextReservation),
          );
    yield r'buffet_ends_at';
    yield object.buffetEndsAt == null
        ? null
        : serializers.serialize(
            object.buffetEndsAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ResourceBoardTileKindEnum),
    );
    yield r'capacity';
    yield serializers.serialize(
      object.capacity,
      specifiedType: const FullType(int),
    );
    yield r'shape';
    yield serializers.serialize(
      object.shape,
      specifiedType: const FullType(ResourceBoardTileShapeEnum),
    );
    yield r'x';
    yield serializers.serialize(
      object.x,
      specifiedType: const FullType(int),
    );
    yield r'y';
    yield serializers.serialize(
      object.y,
      specifiedType: const FullType(int),
    );
    yield r'w';
    yield serializers.serialize(
      object.w,
      specifiedType: const FullType(int),
    );
    yield r'h';
    yield serializers.serialize(
      object.h,
      specifiedType: const FullType(int),
    );
    yield r'rotation';
    yield serializers.serialize(
      object.rotation,
      specifiedType: const FullType(int),
    );
    yield r'manual_status';
    yield serializers.serialize(
      object.manualStatus,
      specifiedType: const FullType(ResourceBoardTileManualStatusEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(ResourceBoardTileStateEnum),
    );
    yield r'guest_count';
    yield object.guestCount == null
        ? null
        : serializers.serialize(
            object.guestCount,
            specifiedType: const FullType.nullable(int),
          );
    yield r'seated_minutes';
    yield object.seatedMinutes == null
        ? null
        : serializers.serialize(
            object.seatedMinutes,
            specifiedType: const FullType.nullable(int),
          );
    yield r'subtotal';
    yield object.subtotal == null
        ? null
        : serializers.serialize(
            object.subtotal,
            specifiedType: const FullType.nullable(String),
          );
    yield r'currency';
    yield object.currency == null
        ? null
        : serializers.serialize(
            object.currency,
            specifiedType: const FullType.nullable(String),
          );
    yield r'payment_requested';
    yield serializers.serialize(
      object.paymentRequested,
      specifiedType: const FullType(bool),
    );
    yield r'edited_after_prebill';
    yield serializers.serialize(
      object.editedAfterPrebill,
      specifiedType: const FullType(bool),
    );
    yield r'orders';
    yield serializers.serialize(
      object.orders,
      specifiedType: const FullType(BuiltList, [FullType(ResourceBoardOrder)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceBoardTile object, {
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
    required ResourceBoardTileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'timed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ResourceBoardTimed),
          ) as ResourceBoardTimed?;
          if (valueDes == null) continue;
          result.timed.replace(valueDes);
          break;
        case r'next_reservation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ResourceNextReservation),
          ) as ResourceNextReservation?;
          if (valueDes == null) continue;
          result.nextReservation.replace(valueDes);
          break;
        case r'buffet_ends_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.buffetEndsAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceBoardTileKindEnum),
          ) as ResourceBoardTileKindEnum;
          result.kind = valueDes;
          break;
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.capacity = valueDes;
          break;
        case r'shape':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceBoardTileShapeEnum),
          ) as ResourceBoardTileShapeEnum;
          result.shape = valueDes;
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.x = valueDes;
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.y = valueDes;
          break;
        case r'w':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.w = valueDes;
          break;
        case r'h':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.h = valueDes;
          break;
        case r'rotation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rotation = valueDes;
          break;
        case r'manual_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceBoardTileManualStatusEnum),
          ) as ResourceBoardTileManualStatusEnum;
          result.manualStatus = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceBoardTileStateEnum),
          ) as ResourceBoardTileStateEnum;
          result.state = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'seated_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.seatedMinutes = valueDes;
          break;
        case r'subtotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subtotal = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
          break;
        case r'payment_requested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.paymentRequested = valueDes;
          break;
        case r'edited_after_prebill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.editedAfterPrebill = valueDes;
          break;
        case r'orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ResourceBoardOrder)]),
          ) as BuiltList<ResourceBoardOrder>;
          result.orders.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceBoardTile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBoardTileBuilder();
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

class ResourceBoardTileKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'table')
  static const ResourceBoardTileKindEnum table =
      _$resourceBoardTileKindEnum_table;
  @BuiltValueEnumConst(wireName: r'room')
  static const ResourceBoardTileKindEnum room =
      _$resourceBoardTileKindEnum_room;
  @BuiltValueEnumConst(wireName: r'billiard')
  static const ResourceBoardTileKindEnum billiard =
      _$resourceBoardTileKindEnum_billiard;
  @BuiltValueEnumConst(wireName: r'vip')
  static const ResourceBoardTileKindEnum vip = _$resourceBoardTileKindEnum_vip;

  static Serializer<ResourceBoardTileKindEnum> get serializer =>
      _$resourceBoardTileKindEnumSerializer;

  const ResourceBoardTileKindEnum._(String name) : super(name);

  static BuiltSet<ResourceBoardTileKindEnum> get values =>
      _$resourceBoardTileKindEnumValues;
  static ResourceBoardTileKindEnum valueOf(String name) =>
      _$resourceBoardTileKindEnumValueOf(name);
}

class ResourceBoardTileShapeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'rect')
  static const ResourceBoardTileShapeEnum rect =
      _$resourceBoardTileShapeEnum_rect;
  @BuiltValueEnumConst(wireName: r'round')
  static const ResourceBoardTileShapeEnum round =
      _$resourceBoardTileShapeEnum_round;

  static Serializer<ResourceBoardTileShapeEnum> get serializer =>
      _$resourceBoardTileShapeEnumSerializer;

  const ResourceBoardTileShapeEnum._(String name) : super(name);

  static BuiltSet<ResourceBoardTileShapeEnum> get values =>
      _$resourceBoardTileShapeEnumValues;
  static ResourceBoardTileShapeEnum valueOf(String name) =>
      _$resourceBoardTileShapeEnumValueOf(name);
}

class ResourceBoardTileManualStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'available')
  static const ResourceBoardTileManualStatusEnum available =
      _$resourceBoardTileManualStatusEnum_available;
  @BuiltValueEnumConst(wireName: r'cleaning')
  static const ResourceBoardTileManualStatusEnum cleaning =
      _$resourceBoardTileManualStatusEnum_cleaning;
  @BuiltValueEnumConst(wireName: r'out_of_service')
  static const ResourceBoardTileManualStatusEnum outOfService =
      _$resourceBoardTileManualStatusEnum_outOfService;

  static Serializer<ResourceBoardTileManualStatusEnum> get serializer =>
      _$resourceBoardTileManualStatusEnumSerializer;

  const ResourceBoardTileManualStatusEnum._(String name) : super(name);

  static BuiltSet<ResourceBoardTileManualStatusEnum> get values =>
      _$resourceBoardTileManualStatusEnumValues;
  static ResourceBoardTileManualStatusEnum valueOf(String name) =>
      _$resourceBoardTileManualStatusEnumValueOf(name);
}

/// Strongest first: out_of_service, cleaning (no open order), payment_requested, prebilled, ending_soon (a running clock is within ten minutes of its planned end), waiting_long (a kitchen item waited past its station's threshold), playing (a clock is running), ordered, occupied, reserved (no open order and a booking starts within the hour), available.
class ResourceBoardTileStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'available')
  static const ResourceBoardTileStateEnum available =
      _$resourceBoardTileStateEnum_available;
  @BuiltValueEnumConst(wireName: r'reserved')
  static const ResourceBoardTileStateEnum reserved =
      _$resourceBoardTileStateEnum_reserved;
  @BuiltValueEnumConst(wireName: r'occupied')
  static const ResourceBoardTileStateEnum occupied =
      _$resourceBoardTileStateEnum_occupied;
  @BuiltValueEnumConst(wireName: r'ordered')
  static const ResourceBoardTileStateEnum ordered =
      _$resourceBoardTileStateEnum_ordered;
  @BuiltValueEnumConst(wireName: r'waiting_long')
  static const ResourceBoardTileStateEnum waitingLong =
      _$resourceBoardTileStateEnum_waitingLong;
  @BuiltValueEnumConst(wireName: r'playing')
  static const ResourceBoardTileStateEnum playing =
      _$resourceBoardTileStateEnum_playing;
  @BuiltValueEnumConst(wireName: r'ending_soon')
  static const ResourceBoardTileStateEnum endingSoon =
      _$resourceBoardTileStateEnum_endingSoon;
  @BuiltValueEnumConst(wireName: r'payment_requested')
  static const ResourceBoardTileStateEnum paymentRequested =
      _$resourceBoardTileStateEnum_paymentRequested;
  @BuiltValueEnumConst(wireName: r'prebilled')
  static const ResourceBoardTileStateEnum prebilled =
      _$resourceBoardTileStateEnum_prebilled;
  @BuiltValueEnumConst(wireName: r'cleaning')
  static const ResourceBoardTileStateEnum cleaning =
      _$resourceBoardTileStateEnum_cleaning;
  @BuiltValueEnumConst(wireName: r'out_of_service')
  static const ResourceBoardTileStateEnum outOfService =
      _$resourceBoardTileStateEnum_outOfService;

  static Serializer<ResourceBoardTileStateEnum> get serializer =>
      _$resourceBoardTileStateEnumSerializer;

  const ResourceBoardTileStateEnum._(String name) : super(name);

  static BuiltSet<ResourceBoardTileStateEnum> get values =>
      _$resourceBoardTileStateEnumValues;
  static ResourceBoardTileStateEnum valueOf(String name) =>
      _$resourceBoardTileStateEnumValueOf(name);
}
