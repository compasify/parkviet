//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace_line.dart';
import 'package:pos_api/src/model/workspace_totals.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace.g.dart';

/// Workspace
///
/// Properties:
/// * [id]
/// * [revision]
/// * [operationalStatus]
/// * [serviceMode]
/// * [businessDate]
/// * [orderNumber] - Call number (`fnb.order_number`), 1, 2, 3… per branch and business date, given at the first kitchen send or at completion and kept.
/// * [guestName] - The name the counter calls out with the call number.
/// * [lineItems]
/// * [totals]
@BuiltValue()
abstract class Workspace implements Built<Workspace, WorkspaceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'revision')
  int get revision;

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
