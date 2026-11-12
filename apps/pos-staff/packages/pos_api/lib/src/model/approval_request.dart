//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'approval_request.g.dart';

/// ApprovalRequest
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [branchName]
/// * [requesterId]
/// * [requesterName]
/// * [action]
/// * [subjectType]
/// * [subjectId]
/// * [subjectLabel] - The table, order number, booking time, plate or code; never a customer's name.
/// * [revision]
/// * [amount]
/// * [currency]
/// * [reason]
/// * [status]
/// * [approvalId]
/// * [decidedByName]
/// * [decidedAt]
/// * [expiresAt]
/// * [createdAt]
@BuiltValue()
abstract class ApprovalRequest
    implements Built<ApprovalRequest, ApprovalRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String get branchName;

  @BuiltValueField(wireName: r'requester_id')
  String get requesterId;

  @BuiltValueField(wireName: r'requester_name')
  String? get requesterName;

  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'subject_type')
  ApprovalRequestSubjectTypeEnum get subjectType;
  // enum subjectTypeEnum {  workspace,  reservation,  bottle_keep,  meal_account,  vehicle_visit,  stored_value_account,  };

  @BuiltValueField(wireName: r'subject_id')
  String? get subjectId;

  /// The table, order number, booking time, plate or code; never a customer's name.
  @BuiltValueField(wireName: r'subject_label')
  String? get subjectLabel;

  @BuiltValueField(wireName: r'revision')
  String get revision;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'currency')
  String? get currency;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'status')
  ApprovalRequestStatusEnum get status;
  // enum statusEnum {  pending,  granted,  declined,  expired,  canceled,  };

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'decided_by_name')
  String? get decidedByName;

  @BuiltValueField(wireName: r'decided_at')
  DateTime? get decidedAt;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  ApprovalRequest._();

  factory ApprovalRequest([void updates(ApprovalRequestBuilder b)]) =
      _$ApprovalRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApprovalRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApprovalRequest> get serializer =>
      _$ApprovalRequestSerializer();
}

class _$ApprovalRequestSerializer
    implements PrimitiveSerializer<ApprovalRequest> {
  @override
  final Iterable<Type> types = const [ApprovalRequest, _$ApprovalRequest];

  @override
  final String wireName = r'ApprovalRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApprovalRequest object, {
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
    yield r'branch_name';
    yield serializers.serialize(
      object.branchName,
      specifiedType: const FullType(String),
    );
    yield r'requester_id';
    yield serializers.serialize(
      object.requesterId,
      specifiedType: const FullType(String),
    );
    yield r'requester_name';
    yield object.requesterName == null
        ? null
        : serializers.serialize(
            object.requesterName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    yield r'subject_type';
    yield serializers.serialize(
      object.subjectType,
      specifiedType: const FullType(ApprovalRequestSubjectTypeEnum),
    );
    yield r'subject_id';
    yield object.subjectId == null
        ? null
        : serializers.serialize(
            object.subjectId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'subject_label';
    yield object.subjectLabel == null
        ? null
        : serializers.serialize(
            object.subjectLabel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield object.amount == null
        ? null
        : serializers.serialize(
            object.amount,
            specifiedType: const FullType.nullable(String),
          );
    yield r'currency';
    yield object.currency == null
        ? null
        : serializers.serialize(
            object.currency,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ApprovalRequestStatusEnum),
    );
    yield r'approval_id';
    yield object.approvalId == null
        ? null
        : serializers.serialize(
            object.approvalId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'decided_by_name';
    yield object.decidedByName == null
        ? null
        : serializers.serialize(
            object.decidedByName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'decided_at';
    yield object.decidedAt == null
        ? null
        : serializers.serialize(
            object.decidedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
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
    ApprovalRequest object, {
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
    required ApprovalRequestBuilder result,
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
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchName = valueDes;
          break;
        case r'requester_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requesterId = valueDes;
          break;
        case r'requester_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requesterName = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'subject_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApprovalRequestSubjectTypeEnum),
          ) as ApprovalRequestSubjectTypeEnum;
          result.subjectType = valueDes;
          break;
        case r'subject_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subjectId = valueDes;
          break;
        case r'subject_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subjectLabel = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.revision = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApprovalRequestStatusEnum),
          ) as ApprovalRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'decided_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decidedByName = valueDes;
          break;
        case r'decided_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.decidedAt = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
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
  ApprovalRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApprovalRequestBuilder();
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

class ApprovalRequestSubjectTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'workspace')
  static const ApprovalRequestSubjectTypeEnum workspace =
      _$approvalRequestSubjectTypeEnum_workspace;
  @BuiltValueEnumConst(wireName: r'reservation')
  static const ApprovalRequestSubjectTypeEnum reservation =
      _$approvalRequestSubjectTypeEnum_reservation;
  @BuiltValueEnumConst(wireName: r'bottle_keep')
  static const ApprovalRequestSubjectTypeEnum bottleKeep =
      _$approvalRequestSubjectTypeEnum_bottleKeep;
  @BuiltValueEnumConst(wireName: r'meal_account')
  static const ApprovalRequestSubjectTypeEnum mealAccount =
      _$approvalRequestSubjectTypeEnum_mealAccount;
  @BuiltValueEnumConst(wireName: r'vehicle_visit')
  static const ApprovalRequestSubjectTypeEnum vehicleVisit =
      _$approvalRequestSubjectTypeEnum_vehicleVisit;
  @BuiltValueEnumConst(wireName: r'stored_value_account')
  static const ApprovalRequestSubjectTypeEnum storedValueAccount =
      _$approvalRequestSubjectTypeEnum_storedValueAccount;

  static Serializer<ApprovalRequestSubjectTypeEnum> get serializer =>
      _$approvalRequestSubjectTypeEnumSerializer;

  const ApprovalRequestSubjectTypeEnum._(String name) : super(name);

  static BuiltSet<ApprovalRequestSubjectTypeEnum> get values =>
      _$approvalRequestSubjectTypeEnumValues;
  static ApprovalRequestSubjectTypeEnum valueOf(String name) =>
      _$approvalRequestSubjectTypeEnumValueOf(name);
}

class ApprovalRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const ApprovalRequestStatusEnum pending =
      _$approvalRequestStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'granted')
  static const ApprovalRequestStatusEnum granted =
      _$approvalRequestStatusEnum_granted;
  @BuiltValueEnumConst(wireName: r'declined')
  static const ApprovalRequestStatusEnum declined =
      _$approvalRequestStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'expired')
  static const ApprovalRequestStatusEnum expired =
      _$approvalRequestStatusEnum_expired;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const ApprovalRequestStatusEnum canceled =
      _$approvalRequestStatusEnum_canceled;

  static Serializer<ApprovalRequestStatusEnum> get serializer =>
      _$approvalRequestStatusEnumSerializer;

  const ApprovalRequestStatusEnum._(String name) : super(name);

  static BuiltSet<ApprovalRequestStatusEnum> get values =>
      _$approvalRequestStatusEnumValues;
  static ApprovalRequestStatusEnum valueOf(String name) =>
      _$approvalRequestStatusEnumValueOf(name);
}
