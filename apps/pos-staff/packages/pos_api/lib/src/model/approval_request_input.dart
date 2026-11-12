//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'approval_request_input.g.dart';

/// ApprovalRequestInput
///
/// Properties:
/// * [branchId]
/// * [actionName]
/// * [revision]
/// * [amount]
/// * [reason]
/// * [workspaceId]
/// * [reservationId]
/// * [bottleKeepId]
/// * [mealAccountId]
/// * [vehicleVisitId]
/// * [storedValueAccountId]
@BuiltValue()
abstract class ApprovalRequestInput
    implements Built<ApprovalRequestInput, ApprovalRequestInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'action_name')
  String get actionName;

  @BuiltValueField(wireName: r'revision')
  String get revision;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'reservation_id')
  String? get reservationId;

  @BuiltValueField(wireName: r'bottle_keep_id')
  String? get bottleKeepId;

  @BuiltValueField(wireName: r'meal_account_id')
  String? get mealAccountId;

  @BuiltValueField(wireName: r'vehicle_visit_id')
  String? get vehicleVisitId;

  @BuiltValueField(wireName: r'stored_value_account_id')
  String? get storedValueAccountId;

  ApprovalRequestInput._();

  factory ApprovalRequestInput([void updates(ApprovalRequestInputBuilder b)]) =
      _$ApprovalRequestInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApprovalRequestInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApprovalRequestInput> get serializer =>
      _$ApprovalRequestInputSerializer();
}

class _$ApprovalRequestInputSerializer
    implements PrimitiveSerializer<ApprovalRequestInput> {
  @override
  final Iterable<Type> types = const [
    ApprovalRequestInput,
    _$ApprovalRequestInput
  ];

  @override
  final String wireName = r'ApprovalRequestInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApprovalRequestInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'action_name';
    yield serializers.serialize(
      object.actionName,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(String),
    );
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(String),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
    if (object.workspaceId != null) {
      yield r'workspace_id';
      yield serializers.serialize(
        object.workspaceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.reservationId != null) {
      yield r'reservation_id';
      yield serializers.serialize(
        object.reservationId,
        specifiedType: const FullType(String),
      );
    }
    if (object.bottleKeepId != null) {
      yield r'bottle_keep_id';
      yield serializers.serialize(
        object.bottleKeepId,
        specifiedType: const FullType(String),
      );
    }
    if (object.mealAccountId != null) {
      yield r'meal_account_id';
      yield serializers.serialize(
        object.mealAccountId,
        specifiedType: const FullType(String),
      );
    }
    if (object.vehicleVisitId != null) {
      yield r'vehicle_visit_id';
      yield serializers.serialize(
        object.vehicleVisitId,
        specifiedType: const FullType(String),
      );
    }
    if (object.storedValueAccountId != null) {
      yield r'stored_value_account_id';
      yield serializers.serialize(
        object.storedValueAccountId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ApprovalRequestInput object, {
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
    required ApprovalRequestInputBuilder result,
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
        case r'action_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actionName = valueDes;
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
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'reservation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reservationId = valueDes;
          break;
        case r'bottle_keep_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bottleKeepId = valueDes;
          break;
        case r'meal_account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mealAccountId = valueDes;
          break;
        case r'vehicle_visit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleVisitId = valueDes;
          break;
        case r'stored_value_account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.storedValueAccountId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApprovalRequestInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApprovalRequestInputBuilder();
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
