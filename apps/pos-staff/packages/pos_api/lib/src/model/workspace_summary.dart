//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/resource_ref.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_summary.g.dart';

/// WorkspaceSummary
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [revision]
/// * [operationalStatus]
/// * [serviceMode]
/// * [businessDate]
/// * [orderNumber]
/// * [guestName]
/// * [tabName] - The guest's name a bar tab is found by.
/// * [resource]
/// * [openedAt]
/// * [total]
@BuiltValue()
abstract class WorkspaceSummary
    implements Built<WorkspaceSummary, WorkspaceSummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'operational_status')
  String get operationalStatus;

  @BuiltValueField(wireName: r'service_mode')
  String get serviceMode;

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'order_number')
  int? get orderNumber;

  @BuiltValueField(wireName: r'guest_name')
  String? get guestName;

  /// The guest's name a bar tab is found by.
  @BuiltValueField(wireName: r'tab_name')
  String? get tabName;

  @BuiltValueField(wireName: r'resource')
  ResourceRef? get resource;

  @BuiltValueField(wireName: r'opened_at')
  DateTime? get openedAt;

  @BuiltValueField(wireName: r'total')
  String get total;

  WorkspaceSummary._();

  factory WorkspaceSummary([void updates(WorkspaceSummaryBuilder b)]) =
      _$WorkspaceSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceSummary> get serializer =>
      _$WorkspaceSummarySerializer();
}

class _$WorkspaceSummarySerializer
    implements PrimitiveSerializer<WorkspaceSummary> {
  @override
  final Iterable<Type> types = const [WorkspaceSummary, _$WorkspaceSummary];

  @override
  final String wireName = r'WorkspaceSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceSummary object, {
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
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'operational_status';
    yield serializers.serialize(
      object.operationalStatus,
      specifiedType: const FullType(String),
    );
    yield r'service_mode';
    yield serializers.serialize(
      object.serviceMode,
      specifiedType: const FullType(String),
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
    if (object.tabName != null) {
      yield r'tab_name';
      yield serializers.serialize(
        object.tabName,
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
    if (object.openedAt != null) {
      yield r'opened_at';
      yield serializers.serialize(
        object.openedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceSummary object, {
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
    required WorkspaceSummaryBuilder result,
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
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
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
        case r'tab_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tabName = valueDes;
          break;
        case r'resource':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ResourceRef),
          ) as ResourceRef?;
          if (valueDes == null) continue;
          result.resource.replace(valueDes);
          break;
        case r'opened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.openedAt = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceSummaryBuilder();
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
