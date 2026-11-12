//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/bus_operator_ref.dart';
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/vehicle_type.dart';
import 'package:pos_api/src/model/vehicle_commission_snapshot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit.g.dart';

/// VehicleVisit
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [busOperator]
/// * [plate] - Upper case letters and digits only.
/// * [vehicleType]
/// * [driverName]
/// * [driverPhone] - Masked to the last four digits unless the reader manages visits.
/// * [guestCount]
/// * [arrivedAt]
/// * [closesAt] - When the visit closes by itself if still open.
/// * [closedAt]
/// * [autoClosed]
/// * [status]
/// * [businessDate]
/// * [openedByName]
/// * [revenueAmount] - Total of the visit's completed orders when it closed.
/// * [commissionAmount]
/// * [currency]
/// * [commission] - The snapshot kept at closing: the rule's values, guests, revenue, the parts per vehicle and per guest, `amount`, `qualified` and `reason` (no_rule, min_guests, min_revenue), and any corrections.
/// * [paidAt]
/// * [payoutMethod]
/// * [payoutStatus] - A cash payout is `requested` until a second person confirms it.
/// * [cashMovementRequestId]
/// * [transferReference]
/// * [voidReason]
/// * [note]
/// * [revision]
/// * [workspacesCount]
/// * [warnings]
@BuiltValue()
abstract class VehicleVisit
    implements Built<VehicleVisit, VehicleVisitBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'bus_operator')
  BusOperatorRef? get busOperator;

  /// Upper case letters and digits only.
  @BuiltValueField(wireName: r'plate')
  String get plate;

  @BuiltValueField(wireName: r'vehicle_type')
  VehicleType get vehicleType;
  // enum vehicleTypeEnum {  seat_16,  seat_29,  seat_45,  other,  };

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  /// Masked to the last four digits unless the reader manages visits.
  @BuiltValueField(wireName: r'driver_phone')
  String? get driverPhone;

  @BuiltValueField(wireName: r'guest_count')
  int get guestCount;

  @BuiltValueField(wireName: r'arrived_at')
  DateTime get arrivedAt;

  /// When the visit closes by itself if still open.
  @BuiltValueField(wireName: r'closes_at')
  DateTime get closesAt;

  @BuiltValueField(wireName: r'closed_at')
  DateTime? get closedAt;

  @BuiltValueField(wireName: r'auto_closed')
  bool? get autoClosed;

  @BuiltValueField(wireName: r'status')
  VehicleVisitStatusEnum get status;
  // enum statusEnum {  open,  closed,  paid,  voided,  };

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'opened_by_name')
  String? get openedByName;

  /// Total of the visit's completed orders when it closed.
  @BuiltValueField(wireName: r'revenue_amount')
  String? get revenueAmount;

  @BuiltValueField(wireName: r'commission_amount')
  String? get commissionAmount;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  /// The snapshot kept at closing: the rule's values, guests, revenue, the parts per vehicle and per guest, `amount`, `qualified` and `reason` (no_rule, min_guests, min_revenue), and any corrections.
  @BuiltValueField(wireName: r'commission')
  VehicleCommissionSnapshot? get commission;

  @BuiltValueField(wireName: r'paid_at')
  DateTime? get paidAt;

  @BuiltValueField(wireName: r'payout_method')
  VehicleVisitPayoutMethodEnum? get payoutMethod;
  // enum payoutMethodEnum {  cash,  transfer,  ,  };

  /// A cash payout is `requested` until a second person confirms it.
  @BuiltValueField(wireName: r'payout_status')
  VehicleVisitPayoutStatusEnum? get payoutStatus;
  // enum payoutStatusEnum {  requested,  paid,  canceled,  ,  };

  @BuiltValueField(wireName: r'cash_movement_request_id')
  String? get cashMovementRequestId;

  @BuiltValueField(wireName: r'transfer_reference')
  String? get transferReference;

  @BuiltValueField(wireName: r'void_reason')
  String? get voidReason;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'workspaces_count')
  int? get workspacesCount;

  @BuiltValueField(wireName: r'warnings')
  BuiltList<VehicleVisitWarningsEnum>? get warnings;
  // enum warningsEnum {  plate_open_today,  };

  VehicleVisit._();

  factory VehicleVisit([void updates(VehicleVisitBuilder b)]) = _$VehicleVisit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisit> get serializer => _$VehicleVisitSerializer();
}

class _$VehicleVisitSerializer implements PrimitiveSerializer<VehicleVisit> {
  @override
  final Iterable<Type> types = const [VehicleVisit, _$VehicleVisit];

  @override
  final String wireName = r'VehicleVisit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.busOperator != null) {
      yield r'bus_operator';
      yield serializers.serialize(
        object.busOperator,
        specifiedType: const FullType.nullable(BusOperatorRef),
      );
    }
    yield r'plate';
    yield serializers.serialize(
      object.plate,
      specifiedType: const FullType(String),
    );
    yield r'vehicle_type';
    yield serializers.serialize(
      object.vehicleType,
      specifiedType: const FullType(VehicleType),
    );
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.driverPhone != null) {
      yield r'driver_phone';
      yield serializers.serialize(
        object.driverPhone,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'guest_count';
    yield serializers.serialize(
      object.guestCount,
      specifiedType: const FullType(int),
    );
    yield r'arrived_at';
    yield serializers.serialize(
      object.arrivedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'closes_at';
    yield serializers.serialize(
      object.closesAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.closedAt != null) {
      yield r'closed_at';
      yield serializers.serialize(
        object.closedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.autoClosed != null) {
      yield r'auto_closed';
      yield serializers.serialize(
        object.autoClosed,
        specifiedType: const FullType(bool),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(VehicleVisitStatusEnum),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    if (object.openedByName != null) {
      yield r'opened_by_name';
      yield serializers.serialize(
        object.openedByName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.revenueAmount != null) {
      yield r'revenue_amount';
      yield serializers.serialize(
        object.revenueAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.commissionAmount != null) {
      yield r'commission_amount';
      yield serializers.serialize(
        object.commissionAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    if (object.commission != null) {
      yield r'commission';
      yield serializers.serialize(
        object.commission,
        specifiedType: const FullType.nullable(VehicleCommissionSnapshot),
      );
    }
    if (object.paidAt != null) {
      yield r'paid_at';
      yield serializers.serialize(
        object.paidAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.payoutMethod != null) {
      yield r'payout_method';
      yield serializers.serialize(
        object.payoutMethod,
        specifiedType: const FullType.nullable(VehicleVisitPayoutMethodEnum),
      );
    }
    if (object.payoutStatus != null) {
      yield r'payout_status';
      yield serializers.serialize(
        object.payoutStatus,
        specifiedType: const FullType.nullable(VehicleVisitPayoutStatusEnum),
      );
    }
    if (object.cashMovementRequestId != null) {
      yield r'cash_movement_request_id';
      yield serializers.serialize(
        object.cashMovementRequestId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.transferReference != null) {
      yield r'transfer_reference';
      yield serializers.serialize(
        object.transferReference,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.voidReason != null) {
      yield r'void_reason';
      yield serializers.serialize(
        object.voidReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    if (object.workspacesCount != null) {
      yield r'workspaces_count';
      yield serializers.serialize(
        object.workspacesCount,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType:
            const FullType(BuiltList, [FullType(VehicleVisitWarningsEnum)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisit object, {
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
    required VehicleVisitBuilder result,
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
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'bus_operator':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BusOperatorRef),
          ) as BusOperatorRef?;
          if (valueDes == null) continue;
          result.busOperator.replace(valueDes);
          break;
        case r'plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plate = valueDes;
          break;
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VehicleType),
          ) as VehicleType;
          result.vehicleType = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'driver_phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverPhone = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.guestCount = valueDes;
          break;
        case r'arrived_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.arrivedAt = valueDes;
          break;
        case r'closes_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.closesAt = valueDes;
          break;
        case r'closed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.closedAt = valueDes;
          break;
        case r'auto_closed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.autoClosed = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VehicleVisitStatusEnum),
          ) as VehicleVisitStatusEnum;
          result.status = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'opened_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.openedByName = valueDes;
          break;
        case r'revenue_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.revenueAmount = valueDes;
          break;
        case r'commission_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.commissionAmount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'commission':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(VehicleCommissionSnapshot),
          ) as VehicleCommissionSnapshot?;
          if (valueDes == null) continue;
          result.commission.replace(valueDes);
          break;
        case r'paid_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.paidAt = valueDes;
          break;
        case r'payout_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(VehicleVisitPayoutMethodEnum),
          ) as VehicleVisitPayoutMethodEnum?;
          if (valueDes == null) continue;
          result.payoutMethod = valueDes;
          break;
        case r'payout_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(VehicleVisitPayoutStatusEnum),
          ) as VehicleVisitPayoutStatusEnum?;
          if (valueDes == null) continue;
          result.payoutStatus = valueDes;
          break;
        case r'cash_movement_request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cashMovementRequestId = valueDes;
          break;
        case r'transfer_reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.transferReference = valueDes;
          break;
        case r'void_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.voidReason = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'workspaces_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.workspacesCount = valueDes;
          break;
        case r'warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(VehicleVisitWarningsEnum)]),
          ) as BuiltList<VehicleVisitWarningsEnum>?;
          if (valueDes == null) continue;
          result.warnings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleVisit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitBuilder();
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

class VehicleVisitStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const VehicleVisitStatusEnum open = _$vehicleVisitStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'closed')
  static const VehicleVisitStatusEnum closed = _$vehicleVisitStatusEnum_closed;
  @BuiltValueEnumConst(wireName: r'paid')
  static const VehicleVisitStatusEnum paid = _$vehicleVisitStatusEnum_paid;
  @BuiltValueEnumConst(wireName: r'voided')
  static const VehicleVisitStatusEnum voided = _$vehicleVisitStatusEnum_voided;

  static Serializer<VehicleVisitStatusEnum> get serializer =>
      _$vehicleVisitStatusEnumSerializer;

  const VehicleVisitStatusEnum._(String name) : super(name);

  static BuiltSet<VehicleVisitStatusEnum> get values =>
      _$vehicleVisitStatusEnumValues;
  static VehicleVisitStatusEnum valueOf(String name) =>
      _$vehicleVisitStatusEnumValueOf(name);
}

class VehicleVisitPayoutMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cash')
  static const VehicleVisitPayoutMethodEnum cash =
      _$vehicleVisitPayoutMethodEnum_cash;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const VehicleVisitPayoutMethodEnum transfer =
      _$vehicleVisitPayoutMethodEnum_transfer;

  static Serializer<VehicleVisitPayoutMethodEnum> get serializer =>
      _$vehicleVisitPayoutMethodEnumSerializer;

  const VehicleVisitPayoutMethodEnum._(String name) : super(name);

  static BuiltSet<VehicleVisitPayoutMethodEnum> get values =>
      _$vehicleVisitPayoutMethodEnumValues;
  static VehicleVisitPayoutMethodEnum valueOf(String name) =>
      _$vehicleVisitPayoutMethodEnumValueOf(name);
}

/// A cash payout is `requested` until a second person confirms it.
class VehicleVisitPayoutStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'requested')
  static const VehicleVisitPayoutStatusEnum requested =
      _$vehicleVisitPayoutStatusEnum_requested;
  @BuiltValueEnumConst(wireName: r'paid')
  static const VehicleVisitPayoutStatusEnum paid =
      _$vehicleVisitPayoutStatusEnum_paid;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const VehicleVisitPayoutStatusEnum canceled =
      _$vehicleVisitPayoutStatusEnum_canceled;

  static Serializer<VehicleVisitPayoutStatusEnum> get serializer =>
      _$vehicleVisitPayoutStatusEnumSerializer;

  const VehicleVisitPayoutStatusEnum._(String name) : super(name);

  static BuiltSet<VehicleVisitPayoutStatusEnum> get values =>
      _$vehicleVisitPayoutStatusEnumValues;
  static VehicleVisitPayoutStatusEnum valueOf(String name) =>
      _$vehicleVisitPayoutStatusEnumValueOf(name);
}

class VehicleVisitWarningsEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'plate_open_today')
  static const VehicleVisitWarningsEnum plateOpenToday =
      _$vehicleVisitWarningsEnum_plateOpenToday;

  static Serializer<VehicleVisitWarningsEnum> get serializer =>
      _$vehicleVisitWarningsEnumSerializer;

  const VehicleVisitWarningsEnum._(String name) : super(name);

  static BuiltSet<VehicleVisitWarningsEnum> get values =>
      _$vehicleVisitWarningsEnumValues;
  static VehicleVisitWarningsEnum valueOf(String name) =>
      _$vehicleVisitWarningsEnumValueOf(name);
}
