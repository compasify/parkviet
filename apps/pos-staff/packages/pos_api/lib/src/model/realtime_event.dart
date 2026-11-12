//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'realtime_event.g.dart';

/// RealtimeEvent
///
/// Properties:
/// * [event]
/// * [id]
/// * [branchId]
/// * [revision]
/// * [leaseGeneration]
/// * [at]
/// * [alert] - Only on `resource.updated`, sent once per deadline: a clock is ten minutes from its planned end, a package's minutes are played, or a pause ran longer than the branch allows.
/// * [refs]
@BuiltValue()
abstract class RealtimeEvent
    implements Built<RealtimeEvent, RealtimeEventBuilder> {
  @BuiltValueField(wireName: r'event')
  RealtimeEventEventEnum get event;
  // enum eventEnum {  workspace.updated,  kitchen_ticket.updated,  menu.sold_out,  payment.requested,  print_job.created,  resource.updated,  approval.requested,  guest_order.created,  guest_order.updated,  guest_request.created,  guest_request.updated,  kiosk.updated,  kiosk_order.waiting,  approval_request.created,  approval_request.updated,  owner_alert.created,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'revision')
  int? get revision;

  @BuiltValueField(wireName: r'lease_generation')
  int? get leaseGeneration;

  @BuiltValueField(wireName: r'at')
  DateTime get at;

  /// Only on `resource.updated`, sent once per deadline: a clock is ten minutes from its planned end, a package's minutes are played, or a pause ran longer than the branch allows.
  @BuiltValueField(wireName: r'alert')
  RealtimeEventAlertEnum? get alert;
  // enum alertEnum {  ending_soon,  ended_package,  pause_too_long,  };

  @BuiltValueField(wireName: r'refs')
  BuiltMap<String, String> get refs;

  RealtimeEvent._();

  factory RealtimeEvent([void updates(RealtimeEventBuilder b)]) =
      _$RealtimeEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RealtimeEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RealtimeEvent> get serializer =>
      _$RealtimeEventSerializer();
}

class _$RealtimeEventSerializer implements PrimitiveSerializer<RealtimeEvent> {
  @override
  final Iterable<Type> types = const [RealtimeEvent, _$RealtimeEvent];

  @override
  final String wireName = r'RealtimeEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RealtimeEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'event';
    yield serializers.serialize(
      object.event,
      specifiedType: const FullType(RealtimeEventEventEnum),
    );
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
    if (object.revision != null) {
      yield r'revision';
      yield serializers.serialize(
        object.revision,
        specifiedType: const FullType(int),
      );
    }
    if (object.leaseGeneration != null) {
      yield r'lease_generation';
      yield serializers.serialize(
        object.leaseGeneration,
        specifiedType: const FullType(int),
      );
    }
    yield r'at';
    yield serializers.serialize(
      object.at,
      specifiedType: const FullType(DateTime),
    );
    if (object.alert != null) {
      yield r'alert';
      yield serializers.serialize(
        object.alert,
        specifiedType: const FullType(RealtimeEventAlertEnum),
      );
    }
    yield r'refs';
    yield serializers.serialize(
      object.refs,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RealtimeEvent object, {
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
    required RealtimeEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RealtimeEventEventEnum),
          ) as RealtimeEventEventEnum;
          result.event = valueDes;
          break;
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
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
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
        case r'at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.at = valueDes;
          break;
        case r'alert':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RealtimeEventAlertEnum),
          ) as RealtimeEventAlertEnum?;
          if (valueDes == null) continue;
          result.alert = valueDes;
          break;
        case r'refs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.refs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RealtimeEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RealtimeEventBuilder();
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

class RealtimeEventEventEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'workspace.updated')
  static const RealtimeEventEventEnum workspacePeriodUpdated =
      _$realtimeEventEventEnum_workspacePeriodUpdated;
  @BuiltValueEnumConst(wireName: r'kitchen_ticket.updated')
  static const RealtimeEventEventEnum kitchenTicketPeriodUpdated =
      _$realtimeEventEventEnum_kitchenTicketPeriodUpdated;
  @BuiltValueEnumConst(wireName: r'menu.sold_out')
  static const RealtimeEventEventEnum menuPeriodSoldOut =
      _$realtimeEventEventEnum_menuPeriodSoldOut;
  @BuiltValueEnumConst(wireName: r'payment.requested')
  static const RealtimeEventEventEnum paymentPeriodRequested =
      _$realtimeEventEventEnum_paymentPeriodRequested;
  @BuiltValueEnumConst(wireName: r'print_job.created')
  static const RealtimeEventEventEnum printJobPeriodCreated =
      _$realtimeEventEventEnum_printJobPeriodCreated;
  @BuiltValueEnumConst(wireName: r'resource.updated')
  static const RealtimeEventEventEnum resourcePeriodUpdated =
      _$realtimeEventEventEnum_resourcePeriodUpdated;
  @BuiltValueEnumConst(wireName: r'approval.requested')
  static const RealtimeEventEventEnum approvalPeriodRequested =
      _$realtimeEventEventEnum_approvalPeriodRequested;
  @BuiltValueEnumConst(wireName: r'guest_order.created')
  static const RealtimeEventEventEnum guestOrderPeriodCreated =
      _$realtimeEventEventEnum_guestOrderPeriodCreated;
  @BuiltValueEnumConst(wireName: r'guest_order.updated')
  static const RealtimeEventEventEnum guestOrderPeriodUpdated =
      _$realtimeEventEventEnum_guestOrderPeriodUpdated;
  @BuiltValueEnumConst(wireName: r'guest_request.created')
  static const RealtimeEventEventEnum guestRequestPeriodCreated =
      _$realtimeEventEventEnum_guestRequestPeriodCreated;
  @BuiltValueEnumConst(wireName: r'guest_request.updated')
  static const RealtimeEventEventEnum guestRequestPeriodUpdated =
      _$realtimeEventEventEnum_guestRequestPeriodUpdated;
  @BuiltValueEnumConst(wireName: r'kiosk.updated')
  static const RealtimeEventEventEnum kioskPeriodUpdated =
      _$realtimeEventEventEnum_kioskPeriodUpdated;
  @BuiltValueEnumConst(wireName: r'kiosk_order.waiting')
  static const RealtimeEventEventEnum kioskOrderPeriodWaiting =
      _$realtimeEventEventEnum_kioskOrderPeriodWaiting;
  @BuiltValueEnumConst(wireName: r'approval_request.created')
  static const RealtimeEventEventEnum approvalRequestPeriodCreated =
      _$realtimeEventEventEnum_approvalRequestPeriodCreated;
  @BuiltValueEnumConst(wireName: r'approval_request.updated')
  static const RealtimeEventEventEnum approvalRequestPeriodUpdated =
      _$realtimeEventEventEnum_approvalRequestPeriodUpdated;
  @BuiltValueEnumConst(wireName: r'owner_alert.created')
  static const RealtimeEventEventEnum ownerAlertPeriodCreated =
      _$realtimeEventEventEnum_ownerAlertPeriodCreated;

  static Serializer<RealtimeEventEventEnum> get serializer =>
      _$realtimeEventEventEnumSerializer;

  const RealtimeEventEventEnum._(String name) : super(name);

  static BuiltSet<RealtimeEventEventEnum> get values =>
      _$realtimeEventEventEnumValues;
  static RealtimeEventEventEnum valueOf(String name) =>
      _$realtimeEventEventEnumValueOf(name);
}

/// Only on `resource.updated`, sent once per deadline: a clock is ten minutes from its planned end, a package's minutes are played, or a pause ran longer than the branch allows.
class RealtimeEventAlertEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ending_soon')
  static const RealtimeEventAlertEnum endingSoon =
      _$realtimeEventAlertEnum_endingSoon;
  @BuiltValueEnumConst(wireName: r'ended_package')
  static const RealtimeEventAlertEnum endedPackage =
      _$realtimeEventAlertEnum_endedPackage;
  @BuiltValueEnumConst(wireName: r'pause_too_long')
  static const RealtimeEventAlertEnum pauseTooLong =
      _$realtimeEventAlertEnum_pauseTooLong;

  static Serializer<RealtimeEventAlertEnum> get serializer =>
      _$realtimeEventAlertEnumSerializer;

  const RealtimeEventAlertEnum._(String name) : super(name);

  static BuiltSet<RealtimeEventAlertEnum> get values =>
      _$realtimeEventAlertEnumValues;
  static RealtimeEventAlertEnum valueOf(String name) =>
      _$realtimeEventAlertEnumValueOf(name);
}
