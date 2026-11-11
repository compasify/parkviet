//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_held_course.dart';
import 'package:pos_api/src/model/kitchen_expo_order.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:pos_api/src/model/kitchen_station.dart';
import 'package:pos_api/src/model/kitchen_all_day_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_board.g.dart';

/// KitchenBoard
///
/// Properties:
/// * [branchId]
/// * [station] - The one station shown; null for several or every station.
/// * [stations] - The stations shown.
/// * [serviceMode] - The way of serving the board is narrowed to; null for all.
/// * [serverNow] - The database clock; screens run their timers from it.
/// * [open] - Tickets with an item still to make: tickets past their station's red threshold first, then the oldest.
/// * [done] - Tickets finished in the last 30 minutes, newest first.
/// * [allDay] - The open items added up by dish and options, in the order the oldest of each was sent.
/// * [expo] - Ready items waiting at the pass, by order: from the stations that hand to the shown `expo` stations, or every ready item when no station is chosen. Items leave once served or after two hours.
/// * [held] - Held courses of open table orders, waiting at the pass for their fire, one row per order and course, oldest first. Only on the board of every station or of a chosen `expo` station; nothing of them has reached a station yet.
@BuiltValue()
abstract class KitchenBoard
    implements Built<KitchenBoard, KitchenBoardBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  /// The one station shown; null for several or every station.
  @BuiltValueField(wireName: r'station')
  KitchenStation? get station;

  /// The stations shown.
  @BuiltValueField(wireName: r'stations')
  BuiltList<KitchenStation> get stations;

  /// The way of serving the board is narrowed to; null for all.
  @BuiltValueField(wireName: r'service_mode')
  String? get serviceMode;

  /// The database clock; screens run their timers from it.
  @BuiltValueField(wireName: r'server_now')
  DateTime get serverNow;

  /// Tickets with an item still to make: tickets past their station's red threshold first, then the oldest.
  @BuiltValueField(wireName: r'open')
  BuiltList<KitchenTicket> get open;

  /// Tickets finished in the last 30 minutes, newest first.
  @BuiltValueField(wireName: r'done')
  BuiltList<KitchenTicket> get done;

  /// The open items added up by dish and options, in the order the oldest of each was sent.
  @BuiltValueField(wireName: r'all_day')
  BuiltList<KitchenAllDayRow> get allDay;

  /// Ready items waiting at the pass, by order: from the stations that hand to the shown `expo` stations, or every ready item when no station is chosen. Items leave once served or after two hours.
  @BuiltValueField(wireName: r'expo')
  BuiltList<KitchenExpoOrder> get expo;

  /// Held courses of open table orders, waiting at the pass for their fire, one row per order and course, oldest first. Only on the board of every station or of a chosen `expo` station; nothing of them has reached a station yet.
  @BuiltValueField(wireName: r'held')
  BuiltList<KitchenHeldCourse> get held;

  KitchenBoard._();

  factory KitchenBoard([void updates(KitchenBoardBuilder b)]) = _$KitchenBoard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenBoardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenBoard> get serializer => _$KitchenBoardSerializer();
}

class _$KitchenBoardSerializer implements PrimitiveSerializer<KitchenBoard> {
  @override
  final Iterable<Type> types = const [KitchenBoard, _$KitchenBoard];

  @override
  final String wireName = r'KitchenBoard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenBoard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'station';
    yield object.station == null
        ? null
        : serializers.serialize(
            object.station,
            specifiedType: const FullType.nullable(KitchenStation),
          );
    yield r'stations';
    yield serializers.serialize(
      object.stations,
      specifiedType: const FullType(BuiltList, [FullType(KitchenStation)]),
    );
    yield r'service_mode';
    yield object.serviceMode == null
        ? null
        : serializers.serialize(
            object.serviceMode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'server_now';
    yield serializers.serialize(
      object.serverNow,
      specifiedType: const FullType(DateTime),
    );
    yield r'open';
    yield serializers.serialize(
      object.open,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
    );
    yield r'done';
    yield serializers.serialize(
      object.done,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
    );
    yield r'all_day';
    yield serializers.serialize(
      object.allDay,
      specifiedType: const FullType(BuiltList, [FullType(KitchenAllDayRow)]),
    );
    yield r'expo';
    yield serializers.serialize(
      object.expo,
      specifiedType: const FullType(BuiltList, [FullType(KitchenExpoOrder)]),
    );
    yield r'held';
    yield serializers.serialize(
      object.held,
      specifiedType: const FullType(BuiltList, [FullType(KitchenHeldCourse)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenBoard object, {
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
    required KitchenBoardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'station':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KitchenStation),
          ) as KitchenStation?;
          if (valueDes == null) continue;
          result.station.replace(valueDes);
          break;
        case r'stations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenStation)]),
          ) as BuiltList<KitchenStation>;
          result.stations.replace(valueDes);
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceMode = valueDes;
          break;
        case r'server_now':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverNow = valueDes;
          break;
        case r'open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
          ) as BuiltList<KitchenTicket>;
          result.open.replace(valueDes);
          break;
        case r'done':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
          ) as BuiltList<KitchenTicket>;
          result.done.replace(valueDes);
          break;
        case r'all_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenAllDayRow)]),
          ) as BuiltList<KitchenAllDayRow>;
          result.allDay.replace(valueDes);
          break;
        case r'expo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenExpoOrder)]),
          ) as BuiltList<KitchenExpoOrder>;
          result.expo.replace(valueDes);
          break;
        case r'held':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenHeldCourse)]),
          ) as BuiltList<KitchenHeldCourse>;
          result.held.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenBoard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenBoardBuilder();
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
