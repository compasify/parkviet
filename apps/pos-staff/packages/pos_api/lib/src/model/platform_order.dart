//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/platform_order_item.dart';
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order.g.dart';

/// A delivery platform's order and what the platform owes for it. The commission is the branch rate's estimate until the order is settled, then the platform's figure; net is gross less commission.
///
/// Properties:
/// * [id]
/// * [workspaceId]
/// * [orderId]
/// * [orderNumber]
/// * [businessDate]
/// * [platform]
/// * [platformOrderRef]
/// * [pickupCode]
/// * [status]
/// * [grossAmount]
/// * [commissionRate] - Percent the platform keeps, as entered with the order.
/// * [commissionAmount]
/// * [netAmount]
/// * [currency]
/// * [enteredAt]
/// * [readyAt]
/// * [completedAt]
/// * [canceledAt]
/// * [cancelReason]
/// * [settledAt]
/// * [settlementReference]
/// * [items]
@BuiltValue()
abstract class PlatformOrder
    implements Built<PlatformOrder, PlatformOrderBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'order_id')
  String get orderId;

  @BuiltValueField(wireName: r'order_number')
  int? get orderNumber;

  @BuiltValueField(wireName: r'business_date')
  Date? get businessDate;

  @BuiltValueField(wireName: r'platform')
  PlatformOrderPlatformEnum get platform;
  // enum platformEnum {  grabfood,  shopeefood,  };

  @BuiltValueField(wireName: r'platform_order_ref')
  String get platformOrderRef;

  @BuiltValueField(wireName: r'pickup_code')
  String? get pickupCode;

  @BuiltValueField(wireName: r'status')
  PlatformOrderStatusEnum get status;
  // enum statusEnum {  accepted,  ready,  completed,  canceled,  };

  @BuiltValueField(wireName: r'gross_amount')
  String get grossAmount;

  /// Percent the platform keeps, as entered with the order.
  @BuiltValueField(wireName: r'commission_rate')
  String get commissionRate;

  @BuiltValueField(wireName: r'commission_amount')
  String get commissionAmount;

  @BuiltValueField(wireName: r'net_amount')
  String get netAmount;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'entered_at')
  DateTime? get enteredAt;

  @BuiltValueField(wireName: r'ready_at')
  DateTime? get readyAt;

  @BuiltValueField(wireName: r'completed_at')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'canceled_at')
  DateTime? get canceledAt;

  @BuiltValueField(wireName: r'cancel_reason')
  String? get cancelReason;

  @BuiltValueField(wireName: r'settled_at')
  DateTime? get settledAt;

  @BuiltValueField(wireName: r'settlement_reference')
  String? get settlementReference;

  @BuiltValueField(wireName: r'items')
  BuiltList<PlatformOrderItem> get items;

  PlatformOrder._();

  factory PlatformOrder([void updates(PlatformOrderBuilder b)]) =
      _$PlatformOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrder> get serializer =>
      _$PlatformOrderSerializer();
}

class _$PlatformOrderSerializer implements PrimitiveSerializer<PlatformOrder> {
  @override
  final Iterable<Type> types = const [PlatformOrder, _$PlatformOrder];

  @override
  final String wireName = r'PlatformOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrder object, {
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
    yield r'order_id';
    yield serializers.serialize(
      object.orderId,
      specifiedType: const FullType(String),
    );
    yield r'order_number';
    yield object.orderNumber == null
        ? null
        : serializers.serialize(
            object.orderNumber,
            specifiedType: const FullType.nullable(int),
          );
    yield r'business_date';
    yield object.businessDate == null
        ? null
        : serializers.serialize(
            object.businessDate,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PlatformOrderPlatformEnum),
    );
    yield r'platform_order_ref';
    yield serializers.serialize(
      object.platformOrderRef,
      specifiedType: const FullType(String),
    );
    yield r'pickup_code';
    yield object.pickupCode == null
        ? null
        : serializers.serialize(
            object.pickupCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PlatformOrderStatusEnum),
    );
    yield r'gross_amount';
    yield serializers.serialize(
      object.grossAmount,
      specifiedType: const FullType(String),
    );
    yield r'commission_rate';
    yield serializers.serialize(
      object.commissionRate,
      specifiedType: const FullType(String),
    );
    yield r'commission_amount';
    yield serializers.serialize(
      object.commissionAmount,
      specifiedType: const FullType(String),
    );
    yield r'net_amount';
    yield serializers.serialize(
      object.netAmount,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'entered_at';
    yield object.enteredAt == null
        ? null
        : serializers.serialize(
            object.enteredAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'ready_at';
    yield object.readyAt == null
        ? null
        : serializers.serialize(
            object.readyAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'completed_at';
    yield object.completedAt == null
        ? null
        : serializers.serialize(
            object.completedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'canceled_at';
    yield object.canceledAt == null
        ? null
        : serializers.serialize(
            object.canceledAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'cancel_reason';
    yield object.cancelReason == null
        ? null
        : serializers.serialize(
            object.cancelReason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'settled_at';
    yield object.settledAt == null
        ? null
        : serializers.serialize(
            object.settledAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'settlement_reference';
    yield object.settlementReference == null
        ? null
        : serializers.serialize(
            object.settlementReference,
            specifiedType: const FullType.nullable(String),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(PlatformOrderItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrder object, {
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
    required PlatformOrderBuilder result,
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
        case r'order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderId = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.orderNumber = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.businessDate = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformOrderPlatformEnum),
          ) as PlatformOrderPlatformEnum;
          result.platform = valueDes;
          break;
        case r'platform_order_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.platformOrderRef = valueDes;
          break;
        case r'pickup_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pickupCode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformOrderStatusEnum),
          ) as PlatformOrderStatusEnum;
          result.status = valueDes;
          break;
        case r'gross_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.grossAmount = valueDes;
          break;
        case r'commission_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commissionRate = valueDes;
          break;
        case r'commission_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commissionAmount = valueDes;
          break;
        case r'net_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.netAmount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'entered_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.enteredAt = valueDes;
          break;
        case r'ready_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readyAt = valueDes;
          break;
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'canceled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.canceledAt = valueDes;
          break;
        case r'cancel_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancelReason = valueDes;
          break;
        case r'settled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.settledAt = valueDes;
          break;
        case r'settlement_reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.settlementReference = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(PlatformOrderItem)]),
          ) as BuiltList<PlatformOrderItem>;
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
  PlatformOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderBuilder();
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

class PlatformOrderPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'grabfood')
  static const PlatformOrderPlatformEnum grabfood =
      _$platformOrderPlatformEnum_grabfood;
  @BuiltValueEnumConst(wireName: r'shopeefood')
  static const PlatformOrderPlatformEnum shopeefood =
      _$platformOrderPlatformEnum_shopeefood;

  static Serializer<PlatformOrderPlatformEnum> get serializer =>
      _$platformOrderPlatformEnumSerializer;

  const PlatformOrderPlatformEnum._(String name) : super(name);

  static BuiltSet<PlatformOrderPlatformEnum> get values =>
      _$platformOrderPlatformEnumValues;
  static PlatformOrderPlatformEnum valueOf(String name) =>
      _$platformOrderPlatformEnumValueOf(name);
}

class PlatformOrderStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accepted')
  static const PlatformOrderStatusEnum accepted =
      _$platformOrderStatusEnum_accepted;
  @BuiltValueEnumConst(wireName: r'ready')
  static const PlatformOrderStatusEnum ready = _$platformOrderStatusEnum_ready;
  @BuiltValueEnumConst(wireName: r'completed')
  static const PlatformOrderStatusEnum completed =
      _$platformOrderStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const PlatformOrderStatusEnum canceled =
      _$platformOrderStatusEnum_canceled;

  static Serializer<PlatformOrderStatusEnum> get serializer =>
      _$platformOrderStatusEnumSerializer;

  const PlatformOrderStatusEnum._(String name) : super(name);

  static BuiltSet<PlatformOrderStatusEnum> get values =>
      _$platformOrderStatusEnumValues;
  static PlatformOrderStatusEnum valueOf(String name) =>
      _$platformOrderStatusEnumValueOf(name);
}
