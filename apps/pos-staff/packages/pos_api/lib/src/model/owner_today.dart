//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/owner_hour_row.dart';
import 'package:pos_api/src/model/owner_source_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_today.g.dart';

/// OwnerToday
///
/// Properties:
/// * [branchId]
/// * [businessDate]
/// * [timezone]
/// * [currency]
/// * [orders]
/// * [salesTotal]
/// * [returnsTotal]
/// * [netSales]
/// * [bySource]
/// * [byHour]
/// * [openUnits] - Open orders on a table or room.
/// * [openOrders]
/// * [openTotal]
/// * [openShifts]
/// * [canceledOrders]
/// * [voidedItems]
/// * [pendingApprovals]
@BuiltValue()
abstract class OwnerToday implements Built<OwnerToday, OwnerTodayBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'timezone')
  String get timezone;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'orders')
  int get orders;

  @BuiltValueField(wireName: r'sales_total')
  String get salesTotal;

  @BuiltValueField(wireName: r'returns_total')
  String get returnsTotal;

  @BuiltValueField(wireName: r'net_sales')
  String get netSales;

  @BuiltValueField(wireName: r'by_source')
  BuiltList<OwnerSourceRow> get bySource;

  @BuiltValueField(wireName: r'by_hour')
  BuiltList<OwnerHourRow> get byHour;

  /// Open orders on a table or room.
  @BuiltValueField(wireName: r'open_units')
  int get openUnits;

  @BuiltValueField(wireName: r'open_orders')
  int get openOrders;

  @BuiltValueField(wireName: r'open_total')
  String get openTotal;

  @BuiltValueField(wireName: r'open_shifts')
  int get openShifts;

  @BuiltValueField(wireName: r'canceled_orders')
  int get canceledOrders;

  @BuiltValueField(wireName: r'voided_items')
  int get voidedItems;

  @BuiltValueField(wireName: r'pending_approvals')
  int get pendingApprovals;

  OwnerToday._();

  factory OwnerToday([void updates(OwnerTodayBuilder b)]) = _$OwnerToday;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerTodayBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerToday> get serializer => _$OwnerTodaySerializer();
}

class _$OwnerTodaySerializer implements PrimitiveSerializer<OwnerToday> {
  @override
  final Iterable<Type> types = const [OwnerToday, _$OwnerToday];

  @override
  final String wireName = r'OwnerToday';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerToday object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'orders';
    yield serializers.serialize(
      object.orders,
      specifiedType: const FullType(int),
    );
    yield r'sales_total';
    yield serializers.serialize(
      object.salesTotal,
      specifiedType: const FullType(String),
    );
    yield r'returns_total';
    yield serializers.serialize(
      object.returnsTotal,
      specifiedType: const FullType(String),
    );
    yield r'net_sales';
    yield serializers.serialize(
      object.netSales,
      specifiedType: const FullType(String),
    );
    yield r'by_source';
    yield serializers.serialize(
      object.bySource,
      specifiedType: const FullType(BuiltList, [FullType(OwnerSourceRow)]),
    );
    yield r'by_hour';
    yield serializers.serialize(
      object.byHour,
      specifiedType: const FullType(BuiltList, [FullType(OwnerHourRow)]),
    );
    yield r'open_units';
    yield serializers.serialize(
      object.openUnits,
      specifiedType: const FullType(int),
    );
    yield r'open_orders';
    yield serializers.serialize(
      object.openOrders,
      specifiedType: const FullType(int),
    );
    yield r'open_total';
    yield serializers.serialize(
      object.openTotal,
      specifiedType: const FullType(String),
    );
    yield r'open_shifts';
    yield serializers.serialize(
      object.openShifts,
      specifiedType: const FullType(int),
    );
    yield r'canceled_orders';
    yield serializers.serialize(
      object.canceledOrders,
      specifiedType: const FullType(int),
    );
    yield r'voided_items';
    yield serializers.serialize(
      object.voidedItems,
      specifiedType: const FullType(int),
    );
    yield r'pending_approvals';
    yield serializers.serialize(
      object.pendingApprovals,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerToday object, {
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
    required OwnerTodayBuilder result,
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
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.orders = valueDes;
          break;
        case r'sales_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.salesTotal = valueDes;
          break;
        case r'returns_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.returnsTotal = valueDes;
          break;
        case r'net_sales':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.netSales = valueDes;
          break;
        case r'by_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OwnerSourceRow)]),
          ) as BuiltList<OwnerSourceRow>;
          result.bySource.replace(valueDes);
          break;
        case r'by_hour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OwnerHourRow)]),
          ) as BuiltList<OwnerHourRow>;
          result.byHour.replace(valueDes);
          break;
        case r'open_units':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.openUnits = valueDes;
          break;
        case r'open_orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.openOrders = valueDes;
          break;
        case r'open_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.openTotal = valueDes;
          break;
        case r'open_shifts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.openShifts = valueDes;
          break;
        case r'canceled_orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.canceledOrders = valueDes;
          break;
        case r'voided_items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.voidedItems = valueDes;
          break;
        case r'pending_approvals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pendingApprovals = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerToday deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerTodayBuilder();
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
