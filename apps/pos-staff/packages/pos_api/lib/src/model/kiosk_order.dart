//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kiosk_payment.dart';
import 'package:pos_api/src/model/kiosk_order_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order.g.dart';

/// KioskOrder
///
/// Properties:
/// * [id]
/// * [status]
/// * [callNumber] - The number the guest listens for; given once the order is paid or left for the counter.
/// * [orderNumber]
/// * [currency]
/// * [total]
/// * [itemTotal]
/// * [lines]
/// * [payment]
/// * [deviceId]
@BuiltValue()
abstract class KioskOrder implements Built<KioskOrder, KioskOrderBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  KioskOrderStatusEnum get status;
  // enum statusEnum {  draft,  awaiting_payment,  at_counter,  paid,  canceled,  };

  /// The number the guest listens for; given once the order is paid or left for the counter.
  @BuiltValueField(wireName: r'call_number')
  int? get callNumber;

  @BuiltValueField(wireName: r'order_number')
  String get orderNumber;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'item_total')
  String get itemTotal;

  @BuiltValueField(wireName: r'lines')
  BuiltList<KioskOrderLine> get lines;

  @BuiltValueField(wireName: r'payment')
  KioskPayment? get payment;

  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  KioskOrder._();

  factory KioskOrder([void updates(KioskOrderBuilder b)]) = _$KioskOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrder> get serializer => _$KioskOrderSerializer();
}

class _$KioskOrderSerializer implements PrimitiveSerializer<KioskOrder> {
  @override
  final Iterable<Type> types = const [KioskOrder, _$KioskOrder];

  @override
  final String wireName = r'KioskOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(KioskOrderStatusEnum),
    );
    yield r'call_number';
    yield object.callNumber == null
        ? null
        : serializers.serialize(
            object.callNumber,
            specifiedType: const FullType.nullable(int),
          );
    yield r'order_number';
    yield serializers.serialize(
      object.orderNumber,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'item_total';
    yield serializers.serialize(
      object.itemTotal,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(KioskOrderLine)]),
    );
    yield r'payment';
    yield object.payment == null
        ? null
        : serializers.serialize(
            object.payment,
            specifiedType: const FullType.nullable(KioskPayment),
          );
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskOrder object, {
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
    required KioskOrderBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskOrderStatusEnum),
          ) as KioskOrderStatusEnum;
          result.status = valueDes;
          break;
        case r'call_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.callNumber = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderNumber = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'item_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.itemTotal = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KioskOrderLine)]),
          ) as BuiltList<KioskOrderLine>;
          result.lines.replace(valueDes);
          break;
        case r'payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskPayment),
          ) as KioskPayment?;
          if (valueDes == null) continue;
          result.payment.replace(valueDes);
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderBuilder();
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

class KioskOrderStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const KioskOrderStatusEnum draft = _$kioskOrderStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'awaiting_payment')
  static const KioskOrderStatusEnum awaitingPayment =
      _$kioskOrderStatusEnum_awaitingPayment;
  @BuiltValueEnumConst(wireName: r'at_counter')
  static const KioskOrderStatusEnum atCounter =
      _$kioskOrderStatusEnum_atCounter;
  @BuiltValueEnumConst(wireName: r'paid')
  static const KioskOrderStatusEnum paid = _$kioskOrderStatusEnum_paid;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const KioskOrderStatusEnum canceled = _$kioskOrderStatusEnum_canceled;

  static Serializer<KioskOrderStatusEnum> get serializer =>
      _$kioskOrderStatusEnumSerializer;

  const KioskOrderStatusEnum._(String name) : super(name);

  static BuiltSet<KioskOrderStatusEnum> get values =>
      _$kioskOrderStatusEnumValues;
  static KioskOrderStatusEnum valueOf(String name) =>
      _$kioskOrderStatusEnumValueOf(name);
}
