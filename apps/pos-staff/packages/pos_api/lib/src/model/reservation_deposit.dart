//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_deposit.g.dart';

/// Money paid to hold a booking: a receipt with no order, never revenue until applied to the bill or kept as a taxed holding fee.
///
/// Properties:
/// * [id]
/// * [reservationId]
/// * [receivedFundsId]
/// * [kind]
/// * [amount]
/// * [currency]
/// * [status]
/// * [available] - What is left on its receipt, for the bill or a refund.
/// * [resolutionOrderId]
/// * [liabilityPayoutId]
/// * [fundsAllocationId]
/// * [receivedAt]
/// * [resolvedAt]
@BuiltValue()
abstract class ReservationDeposit
    implements Built<ReservationDeposit, ReservationDepositBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'reservation_id')
  String get reservationId;

  @BuiltValueField(wireName: r'received_funds_id')
  String get receivedFundsId;

  @BuiltValueField(wireName: r'kind')
  ReservationDepositKindEnum get kind;
  // enum kindEnum {  cash,  bank_manual,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'status')
  ReservationDepositStatusEnum get status;
  // enum statusEnum {  held,  applied,  refunded,  forfeited,  };

  /// What is left on its receipt, for the bill or a refund.
  @BuiltValueField(wireName: r'available')
  String get available;

  @BuiltValueField(wireName: r'resolution_order_id')
  String? get resolutionOrderId;

  @BuiltValueField(wireName: r'liability_payout_id')
  String? get liabilityPayoutId;

  @BuiltValueField(wireName: r'funds_allocation_id')
  String? get fundsAllocationId;

  @BuiltValueField(wireName: r'received_at')
  DateTime? get receivedAt;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  ReservationDeposit._();

  factory ReservationDeposit([void updates(ReservationDepositBuilder b)]) =
      _$ReservationDeposit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDepositBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDeposit> get serializer =>
      _$ReservationDepositSerializer();
}

class _$ReservationDepositSerializer
    implements PrimitiveSerializer<ReservationDeposit> {
  @override
  final Iterable<Type> types = const [ReservationDeposit, _$ReservationDeposit];

  @override
  final String wireName = r'ReservationDeposit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDeposit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'reservation_id';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
    yield r'received_funds_id';
    yield serializers.serialize(
      object.receivedFundsId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ReservationDepositKindEnum),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReservationDepositStatusEnum),
    );
    yield r'available';
    yield serializers.serialize(
      object.available,
      specifiedType: const FullType(String),
    );
    yield r'resolution_order_id';
    yield object.resolutionOrderId == null
        ? null
        : serializers.serialize(
            object.resolutionOrderId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'liability_payout_id';
    yield object.liabilityPayoutId == null
        ? null
        : serializers.serialize(
            object.liabilityPayoutId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'funds_allocation_id';
    yield object.fundsAllocationId == null
        ? null
        : serializers.serialize(
            object.fundsAllocationId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'received_at';
    yield object.receivedAt == null
        ? null
        : serializers.serialize(
            object.receivedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'resolved_at';
    yield object.resolvedAt == null
        ? null
        : serializers.serialize(
            object.resolvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDeposit object, {
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
    required ReservationDepositBuilder result,
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
        case r'reservation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reservationId = valueDes;
          break;
        case r'received_funds_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.receivedFundsId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDepositKindEnum),
          ) as ReservationDepositKindEnum;
          result.kind = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDepositStatusEnum),
          ) as ReservationDepositStatusEnum;
          result.status = valueDes;
          break;
        case r'available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.available = valueDes;
          break;
        case r'resolution_order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolutionOrderId = valueDes;
          break;
        case r'liability_payout_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.liabilityPayoutId = valueDes;
          break;
        case r'funds_allocation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fundsAllocationId = valueDes;
          break;
        case r'received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.receivedAt = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDeposit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDepositBuilder();
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

class ReservationDepositKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cash')
  static const ReservationDepositKindEnum cash =
      _$reservationDepositKindEnum_cash;
  @BuiltValueEnumConst(wireName: r'bank_manual')
  static const ReservationDepositKindEnum bankManual =
      _$reservationDepositKindEnum_bankManual;

  static Serializer<ReservationDepositKindEnum> get serializer =>
      _$reservationDepositKindEnumSerializer;

  const ReservationDepositKindEnum._(String name) : super(name);

  static BuiltSet<ReservationDepositKindEnum> get values =>
      _$reservationDepositKindEnumValues;
  static ReservationDepositKindEnum valueOf(String name) =>
      _$reservationDepositKindEnumValueOf(name);
}

class ReservationDepositStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'held')
  static const ReservationDepositStatusEnum held =
      _$reservationDepositStatusEnum_held;
  @BuiltValueEnumConst(wireName: r'applied')
  static const ReservationDepositStatusEnum applied =
      _$reservationDepositStatusEnum_applied;
  @BuiltValueEnumConst(wireName: r'refunded')
  static const ReservationDepositStatusEnum refunded =
      _$reservationDepositStatusEnum_refunded;
  @BuiltValueEnumConst(wireName: r'forfeited')
  static const ReservationDepositStatusEnum forfeited =
      _$reservationDepositStatusEnum_forfeited;

  static Serializer<ReservationDepositStatusEnum> get serializer =>
      _$reservationDepositStatusEnumSerializer;

  const ReservationDepositStatusEnum._(String name) : super(name);

  static BuiltSet<ReservationDepositStatusEnum> get values =>
      _$reservationDepositStatusEnumValues;
  static ReservationDepositStatusEnum valueOf(String name) =>
      _$reservationDepositStatusEnumValueOf(name);
}
