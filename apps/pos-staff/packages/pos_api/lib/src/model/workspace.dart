//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace_line.dart';
import 'package:pos_api/src/model/resource_ref.dart';
import 'package:pos_api/src/model/workspace_prebill.dart';
import 'package:pos_api/src/model/kitchen_send_summary.dart';
import 'package:pos_api/src/model/workspace_service_charge.dart';
import 'package:pos_api/src/model/workspace_totals.dart';
import 'package:pos_api/src/model/payment_request.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace.g.dart';

/// Workspace
///
/// Properties:
/// * [id]
/// * [revision]
/// * [leaseGeneration] - Sent back with commands that need the editing lease (move, merge).
/// * [operationalStatus]
/// * [serviceMode]
/// * [businessDate]
/// * [orderNumber] - Call number (`fnb.order_number`), 1, 2, 3… per branch and business date, given at the first kitchen send or at completion and kept.
/// * [guestName] - The name the counter calls out with the call number.
/// * [resource] - The table of a table order (`fnb.tables`).
/// * [guestCount]
/// * [tableLabel] - A, B… when a table has several open orders.
/// * [serviceCharge] - Present when the branch has a service charge rate.
/// * [prebill] - The latest pre-bill of a table order.
/// * [paymentRequest] - The table's open request for the bill.
/// * [kitchenSends] - Every kitchen send of a table order; null for other orders.
/// * [lineItems]
/// * [totals]
@BuiltValue()
abstract class Workspace implements Built<Workspace, WorkspaceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  /// Sent back with commands that need the editing lease (move, merge).
  @BuiltValueField(wireName: r'lease_generation')
  int? get leaseGeneration;

  @BuiltValueField(wireName: r'operational_status')
  String get operationalStatus;

  @BuiltValueField(wireName: r'service_mode')
  WorkspaceServiceModeEnum get serviceMode;
  // enum serviceModeEnum {  counter,  dine_in,  takeaway,  delivery,  tab,  timed,  };

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  /// Call number (`fnb.order_number`), 1, 2, 3… per branch and business date, given at the first kitchen send or at completion and kept.
  @BuiltValueField(wireName: r'order_number')
  int? get orderNumber;

  /// The name the counter calls out with the call number.
  @BuiltValueField(wireName: r'guest_name')
  String? get guestName;

  /// The table of a table order (`fnb.tables`).
  @BuiltValueField(wireName: r'resource')
  ResourceRef? get resource;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  /// A, B… when a table has several open orders.
  @BuiltValueField(wireName: r'table_label')
  String? get tableLabel;

  /// Present when the branch has a service charge rate.
  @BuiltValueField(wireName: r'service_charge')
  WorkspaceServiceCharge? get serviceCharge;

  /// The latest pre-bill of a table order.
  @BuiltValueField(wireName: r'prebill')
  WorkspacePrebill? get prebill;

  /// The table's open request for the bill.
  @BuiltValueField(wireName: r'payment_request')
  PaymentRequest? get paymentRequest;

  /// Every kitchen send of a table order; null for other orders.
  @BuiltValueField(wireName: r'kitchen_sends')
  BuiltList<KitchenSendSummary>? get kitchenSends;

  @BuiltValueField(wireName: r'line_items')
  BuiltList<WorkspaceLine>? get lineItems;

  @BuiltValueField(wireName: r'totals')
  WorkspaceTotals get totals;

  Workspace._();

  factory Workspace([void updates(WorkspaceBuilder b)]) = _$Workspace;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Workspace> get serializer => _$WorkspaceSerializer();
}

class _$WorkspaceSerializer implements PrimitiveSerializer<Workspace> {
  @override
  final Iterable<Type> types = const [Workspace, _$Workspace];

  @override
  final String wireName = r'Workspace';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Workspace object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    if (object.leaseGeneration != null) {
      yield r'lease_generation';
      yield serializers.serialize(
        object.leaseGeneration,
        specifiedType: const FullType(int),
      );
    }
    yield r'operational_status';
    yield serializers.serialize(
      object.operationalStatus,
      specifiedType: const FullType(String),
    );
    yield r'service_mode';
    yield serializers.serialize(
      object.serviceMode,
      specifiedType: const FullType(WorkspaceServiceModeEnum),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    if (object.orderNumber != null) {
      yield r'order_number';
      yield serializers.serialize(
        object.orderNumber,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.guestName != null) {
      yield r'guest_name';
      yield serializers.serialize(
        object.guestName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.resource != null) {
      yield r'resource';
      yield serializers.serialize(
        object.resource,
        specifiedType: const FullType.nullable(ResourceRef),
      );
    }
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.tableLabel != null) {
      yield r'table_label';
      yield serializers.serialize(
        object.tableLabel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.serviceCharge != null) {
      yield r'service_charge';
      yield serializers.serialize(
        object.serviceCharge,
        specifiedType: const FullType.nullable(WorkspaceServiceCharge),
      );
    }
    if (object.prebill != null) {
      yield r'prebill';
      yield serializers.serialize(
        object.prebill,
        specifiedType: const FullType.nullable(WorkspacePrebill),
      );
    }
    if (object.paymentRequest != null) {
      yield r'payment_request';
      yield serializers.serialize(
        object.paymentRequest,
        specifiedType: const FullType.nullable(PaymentRequest),
      );
    }
    if (object.kitchenSends != null) {
      yield r'kitchen_sends';
      yield serializers.serialize(
        object.kitchenSends,
        specifiedType:
            const FullType.nullable(BuiltList, [FullType(KitchenSendSummary)]),
      );
    }
    if (object.lineItems != null) {
      yield r'line_items';
      yield serializers.serialize(
        object.lineItems,
        specifiedType: const FullType(BuiltList, [FullType(WorkspaceLine)]),
      );
    }
    yield r'totals';
    yield serializers.serialize(
      object.totals,
      specifiedType: const FullType(WorkspaceTotals),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Workspace object, {
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
    required WorkspaceBuilder result,
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
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'lease_generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.leaseGeneration = valueDes;
          break;
        case r'operational_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.operationalStatus = valueDes;
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkspaceServiceModeEnum),
          ) as WorkspaceServiceModeEnum;
          result.serviceMode = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.orderNumber = valueDes;
          break;
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.guestName = valueDes;
          break;
        case r'resource':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ResourceRef),
          ) as ResourceRef?;
          if (valueDes == null) continue;
          result.resource.replace(valueDes);
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'table_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tableLabel = valueDes;
          break;
        case r'service_charge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WorkspaceServiceCharge),
          ) as WorkspaceServiceCharge?;
          if (valueDes == null) continue;
          result.serviceCharge.replace(valueDes);
          break;
        case r'prebill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WorkspacePrebill),
          ) as WorkspacePrebill?;
          if (valueDes == null) continue;
          result.prebill.replace(valueDes);
          break;
        case r'payment_request':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PaymentRequest),
          ) as PaymentRequest?;
          if (valueDes == null) continue;
          result.paymentRequest.replace(valueDes);
          break;
        case r'kitchen_sends':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(KitchenSendSummary)]),
          ) as BuiltList<KitchenSendSummary>?;
          if (valueDes == null) continue;
          result.kitchenSends.replace(valueDes);
          break;
        case r'line_items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(WorkspaceLine)]),
          ) as BuiltList<WorkspaceLine>?;
          if (valueDes == null) continue;
          result.lineItems.replace(valueDes);
          break;
        case r'totals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkspaceTotals),
          ) as WorkspaceTotals;
          result.totals.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Workspace deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceBuilder();
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

class WorkspaceServiceModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'counter')
  static const WorkspaceServiceModeEnum counter =
      _$workspaceServiceModeEnum_counter;
  @BuiltValueEnumConst(wireName: r'dine_in')
  static const WorkspaceServiceModeEnum dineIn =
      _$workspaceServiceModeEnum_dineIn;
  @BuiltValueEnumConst(wireName: r'takeaway')
  static const WorkspaceServiceModeEnum takeaway =
      _$workspaceServiceModeEnum_takeaway;
  @BuiltValueEnumConst(wireName: r'delivery')
  static const WorkspaceServiceModeEnum delivery =
      _$workspaceServiceModeEnum_delivery;
  @BuiltValueEnumConst(wireName: r'tab')
  static const WorkspaceServiceModeEnum tab = _$workspaceServiceModeEnum_tab;
  @BuiltValueEnumConst(wireName: r'timed')
  static const WorkspaceServiceModeEnum timed =
      _$workspaceServiceModeEnum_timed;

  static Serializer<WorkspaceServiceModeEnum> get serializer =>
      _$workspaceServiceModeEnumSerializer;

  const WorkspaceServiceModeEnum._(String name) : super(name);

  static BuiltSet<WorkspaceServiceModeEnum> get values =>
      _$workspaceServiceModeEnumValues;
  static WorkspaceServiceModeEnum valueOf(String name) =>
      _$workspaceServiceModeEnumValueOf(name);
}
