//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_sale_line.dart';
import 'package:pos_api/src/model/offline_sale_staff.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale.g.dart';

/// OfflineSale
///
/// Properties:
/// * [id]
/// * [offlineId]
/// * [provisionalNumber]
/// * [status]
/// * [branchId]
/// * [registerId]
/// * [shiftId]
/// * [staff]
/// * [clientSoldAt]
/// * [clockCheck] - The counter's clock was more than 10 minutes off the server's.
/// * [clockSkewSeconds]
/// * [collectedTotal]
/// * [handedAmount]
/// * [currency]
/// * [lines]
/// * [reviewReason]
/// * [reviewDetails]
/// * [workspaceId]
/// * [orderNumber]
/// * [callNumber]
/// * [currentTotal]
/// * [resolution]
/// * [resolutionNote]
/// * [resolvedAt]
/// * [resolvedBy]
/// * [createdAt]
@BuiltValue()
abstract class OfflineSale implements Built<OfflineSale, OfflineSaleBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'offline_id')
  String get offlineId;

  @BuiltValueField(wireName: r'provisional_number')
  String get provisionalNumber;

  @BuiltValueField(wireName: r'status')
  OfflineSaleStatusEnum get status;
  // enum statusEnum {  completed,  needs_review,  rejected,  };

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'register_id')
  String get registerId;

  @BuiltValueField(wireName: r'shift_id')
  String get shiftId;

  @BuiltValueField(wireName: r'staff')
  OfflineSaleStaff get staff;

  @BuiltValueField(wireName: r'client_sold_at')
  DateTime get clientSoldAt;

  /// The counter's clock was more than 10 minutes off the server's.
  @BuiltValueField(wireName: r'clock_check')
  bool get clockCheck;

  @BuiltValueField(wireName: r'clock_skew_seconds')
  int get clockSkewSeconds;

  @BuiltValueField(wireName: r'collected_total')
  String get collectedTotal;

  @BuiltValueField(wireName: r'handed_amount')
  String get handedAmount;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'lines')
  BuiltList<OfflineSaleLine> get lines;

  @BuiltValueField(wireName: r'review_reason')
  OfflineSaleReviewReasonEnum? get reviewReason;
  // enum reviewReasonEnum {  price_changed,  item_unavailable,  item_sold_out,  shift_closed,  shift_mismatch,  sale_refused,  ,  };

  @BuiltValueField(wireName: r'review_details')
  BuiltMap<String, JsonObject?> get reviewDetails;

  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'order_number')
  String? get orderNumber;

  @BuiltValueField(wireName: r'call_number')
  int? get callNumber;

  @BuiltValueField(wireName: r'current_total')
  String? get currentTotal;

  @BuiltValueField(wireName: r'resolution')
  OfflineSaleResolutionEnum? get resolution;
  // enum resolutionEnum {  accept_collected,  current_price,  edited,  rejected,  ,  };

  @BuiltValueField(wireName: r'resolution_note')
  String? get resolutionNote;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  @BuiltValueField(wireName: r'resolved_by')
  OfflineSaleStaff? get resolvedBy;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  OfflineSale._();

  factory OfflineSale([void updates(OfflineSaleBuilder b)]) = _$OfflineSale;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSale> get serializer => _$OfflineSaleSerializer();
}

class _$OfflineSaleSerializer implements PrimitiveSerializer<OfflineSale> {
  @override
  final Iterable<Type> types = const [OfflineSale, _$OfflineSale];

  @override
  final String wireName = r'OfflineSale';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSale object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'offline_id';
    yield serializers.serialize(
      object.offlineId,
      specifiedType: const FullType(String),
    );
    yield r'provisional_number';
    yield serializers.serialize(
      object.provisionalNumber,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OfflineSaleStatusEnum),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'register_id';
    yield serializers.serialize(
      object.registerId,
      specifiedType: const FullType(String),
    );
    yield r'shift_id';
    yield serializers.serialize(
      object.shiftId,
      specifiedType: const FullType(String),
    );
    yield r'staff';
    yield serializers.serialize(
      object.staff,
      specifiedType: const FullType(OfflineSaleStaff),
    );
    yield r'client_sold_at';
    yield serializers.serialize(
      object.clientSoldAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'clock_check';
    yield serializers.serialize(
      object.clockCheck,
      specifiedType: const FullType(bool),
    );
    yield r'clock_skew_seconds';
    yield serializers.serialize(
      object.clockSkewSeconds,
      specifiedType: const FullType(int),
    );
    yield r'collected_total';
    yield serializers.serialize(
      object.collectedTotal,
      specifiedType: const FullType(String),
    );
    yield r'handed_amount';
    yield serializers.serialize(
      object.handedAmount,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(OfflineSaleLine)]),
    );
    yield r'review_reason';
    yield object.reviewReason == null
        ? null
        : serializers.serialize(
            object.reviewReason,
            specifiedType: const FullType.nullable(OfflineSaleReviewReasonEnum),
          );
    yield r'review_details';
    yield serializers.serialize(
      object.reviewDetails,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'workspace_id';
    yield object.workspaceId == null
        ? null
        : serializers.serialize(
            object.workspaceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'order_number';
    yield object.orderNumber == null
        ? null
        : serializers.serialize(
            object.orderNumber,
            specifiedType: const FullType.nullable(String),
          );
    yield r'call_number';
    yield object.callNumber == null
        ? null
        : serializers.serialize(
            object.callNumber,
            specifiedType: const FullType.nullable(int),
          );
    yield r'current_total';
    yield object.currentTotal == null
        ? null
        : serializers.serialize(
            object.currentTotal,
            specifiedType: const FullType.nullable(String),
          );
    yield r'resolution';
    yield object.resolution == null
        ? null
        : serializers.serialize(
            object.resolution,
            specifiedType: const FullType.nullable(OfflineSaleResolutionEnum),
          );
    yield r'resolution_note';
    yield object.resolutionNote == null
        ? null
        : serializers.serialize(
            object.resolutionNote,
            specifiedType: const FullType.nullable(String),
          );
    yield r'resolved_at';
    yield object.resolvedAt == null
        ? null
        : serializers.serialize(
            object.resolvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'resolved_by';
    yield object.resolvedBy == null
        ? null
        : serializers.serialize(
            object.resolvedBy,
            specifiedType: const FullType.nullable(OfflineSaleStaff),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSale object, {
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
    required OfflineSaleBuilder result,
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
        case r'offline_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.offlineId = valueDes;
          break;
        case r'provisional_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provisionalNumber = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSaleStatusEnum),
          ) as OfflineSaleStatusEnum;
          result.status = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registerId = valueDes;
          break;
        case r'shift_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shiftId = valueDes;
          break;
        case r'staff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSaleStaff),
          ) as OfflineSaleStaff;
          result.staff.replace(valueDes);
          break;
        case r'client_sold_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.clientSoldAt = valueDes;
          break;
        case r'clock_check':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clockCheck = valueDes;
          break;
        case r'clock_skew_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.clockSkewSeconds = valueDes;
          break;
        case r'collected_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.collectedTotal = valueDes;
          break;
        case r'handed_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.handedAmount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OfflineSaleLine)]),
          ) as BuiltList<OfflineSaleLine>;
          result.lines.replace(valueDes);
          break;
        case r'review_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OfflineSaleReviewReasonEnum),
          ) as OfflineSaleReviewReasonEnum?;
          if (valueDes == null) continue;
          result.reviewReason = valueDes;
          break;
        case r'review_details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.reviewDetails.replace(valueDes);
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.orderNumber = valueDes;
          break;
        case r'call_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.callNumber = valueDes;
          break;
        case r'current_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currentTotal = valueDes;
          break;
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OfflineSaleResolutionEnum),
          ) as OfflineSaleResolutionEnum?;
          if (valueDes == null) continue;
          result.resolution = valueDes;
          break;
        case r'resolution_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolutionNote = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'resolved_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OfflineSaleStaff),
          ) as OfflineSaleStaff?;
          if (valueDes == null) continue;
          result.resolvedBy.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSale deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleBuilder();
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

class OfflineSaleStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'completed')
  static const OfflineSaleStatusEnum completed =
      _$offlineSaleStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'needs_review')
  static const OfflineSaleStatusEnum needsReview =
      _$offlineSaleStatusEnum_needsReview;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const OfflineSaleStatusEnum rejected =
      _$offlineSaleStatusEnum_rejected;

  static Serializer<OfflineSaleStatusEnum> get serializer =>
      _$offlineSaleStatusEnumSerializer;

  const OfflineSaleStatusEnum._(String name) : super(name);

  static BuiltSet<OfflineSaleStatusEnum> get values =>
      _$offlineSaleStatusEnumValues;
  static OfflineSaleStatusEnum valueOf(String name) =>
      _$offlineSaleStatusEnumValueOf(name);
}

class OfflineSaleReviewReasonEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'price_changed')
  static const OfflineSaleReviewReasonEnum priceChanged =
      _$offlineSaleReviewReasonEnum_priceChanged;
  @BuiltValueEnumConst(wireName: r'item_unavailable')
  static const OfflineSaleReviewReasonEnum itemUnavailable =
      _$offlineSaleReviewReasonEnum_itemUnavailable;
  @BuiltValueEnumConst(wireName: r'item_sold_out')
  static const OfflineSaleReviewReasonEnum itemSoldOut =
      _$offlineSaleReviewReasonEnum_itemSoldOut;
  @BuiltValueEnumConst(wireName: r'shift_closed')
  static const OfflineSaleReviewReasonEnum shiftClosed =
      _$offlineSaleReviewReasonEnum_shiftClosed;
  @BuiltValueEnumConst(wireName: r'shift_mismatch')
  static const OfflineSaleReviewReasonEnum shiftMismatch =
      _$offlineSaleReviewReasonEnum_shiftMismatch;
  @BuiltValueEnumConst(wireName: r'sale_refused')
  static const OfflineSaleReviewReasonEnum saleRefused =
      _$offlineSaleReviewReasonEnum_saleRefused;

  static Serializer<OfflineSaleReviewReasonEnum> get serializer =>
      _$offlineSaleReviewReasonEnumSerializer;

  const OfflineSaleReviewReasonEnum._(String name) : super(name);

  static BuiltSet<OfflineSaleReviewReasonEnum> get values =>
      _$offlineSaleReviewReasonEnumValues;
  static OfflineSaleReviewReasonEnum valueOf(String name) =>
      _$offlineSaleReviewReasonEnumValueOf(name);
}

class OfflineSaleResolutionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accept_collected')
  static const OfflineSaleResolutionEnum acceptCollected =
      _$offlineSaleResolutionEnum_acceptCollected;
  @BuiltValueEnumConst(wireName: r'current_price')
  static const OfflineSaleResolutionEnum currentPrice =
      _$offlineSaleResolutionEnum_currentPrice;
  @BuiltValueEnumConst(wireName: r'edited')
  static const OfflineSaleResolutionEnum edited =
      _$offlineSaleResolutionEnum_edited;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const OfflineSaleResolutionEnum rejected =
      _$offlineSaleResolutionEnum_rejected;

  static Serializer<OfflineSaleResolutionEnum> get serializer =>
      _$offlineSaleResolutionEnumSerializer;

  const OfflineSaleResolutionEnum._(String name) : super(name);

  static BuiltSet<OfflineSaleResolutionEnum> get values =>
      _$offlineSaleResolutionEnumValues;
  static OfflineSaleResolutionEnum valueOf(String name) =>
      _$offlineSaleResolutionEnumValueOf(name);
}
