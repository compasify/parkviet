//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_open_unit.g.dart';

/// OwnerOpenUnit
///
/// Properties:
/// * [workspaceId]
/// * [resourceId]
/// * [label]
/// * [serviceMode]
/// * [status]
/// * [guestCount]
/// * [openedAt]
/// * [minutesOpen]
/// * [total]
/// * [kitchenWaiting]
/// * [kitchenLate]
@BuiltValue()
abstract class OwnerOpenUnit
    implements Built<OwnerOpenUnit, OwnerOpenUnitBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'resource_id')
  String? get resourceId;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'service_mode')
  String? get serviceMode;

  @BuiltValueField(wireName: r'status')
  OwnerOpenUnitStatusEnum get status;
  // enum statusEnum {  editing,  parked,  };

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  @BuiltValueField(wireName: r'opened_at')
  DateTime get openedAt;

  @BuiltValueField(wireName: r'minutes_open')
  int get minutesOpen;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'kitchen_waiting')
  int get kitchenWaiting;

  @BuiltValueField(wireName: r'kitchen_late')
  bool get kitchenLate;

  OwnerOpenUnit._();

  factory OwnerOpenUnit([void updates(OwnerOpenUnitBuilder b)]) =
      _$OwnerOpenUnit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerOpenUnitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerOpenUnit> get serializer =>
      _$OwnerOpenUnitSerializer();
}

class _$OwnerOpenUnitSerializer implements PrimitiveSerializer<OwnerOpenUnit> {
  @override
  final Iterable<Type> types = const [OwnerOpenUnit, _$OwnerOpenUnit];

  @override
  final String wireName = r'OwnerOpenUnit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerOpenUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'resource_id';
    yield object.resourceId == null
        ? null
        : serializers.serialize(
            object.resourceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'label';
    yield object.label == null
        ? null
        : serializers.serialize(
            object.label,
            specifiedType: const FullType.nullable(String),
          );
    yield r'service_mode';
    yield object.serviceMode == null
        ? null
        : serializers.serialize(
            object.serviceMode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OwnerOpenUnitStatusEnum),
    );
    yield r'guest_count';
    yield object.guestCount == null
        ? null
        : serializers.serialize(
            object.guestCount,
            specifiedType: const FullType.nullable(int),
          );
    yield r'opened_at';
    yield serializers.serialize(
      object.openedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'minutes_open';
    yield serializers.serialize(
      object.minutesOpen,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'kitchen_waiting';
    yield serializers.serialize(
      object.kitchenWaiting,
      specifiedType: const FullType(int),
    );
    yield r'kitchen_late';
    yield serializers.serialize(
      object.kitchenLate,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerOpenUnit object, {
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
    required OwnerOpenUnitBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resourceId = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceMode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnerOpenUnitStatusEnum),
          ) as OwnerOpenUnitStatusEnum;
          result.status = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'opened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.openedAt = valueDes;
          break;
        case r'minutes_open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minutesOpen = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'kitchen_waiting':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.kitchenWaiting = valueDes;
          break;
        case r'kitchen_late':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.kitchenLate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerOpenUnit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerOpenUnitBuilder();
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

class OwnerOpenUnitStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editing')
  static const OwnerOpenUnitStatusEnum editing =
      _$ownerOpenUnitStatusEnum_editing;
  @BuiltValueEnumConst(wireName: r'parked')
  static const OwnerOpenUnitStatusEnum parked =
      _$ownerOpenUnitStatusEnum_parked;

  static Serializer<OwnerOpenUnitStatusEnum> get serializer =>
      _$ownerOpenUnitStatusEnumSerializer;

  const OwnerOpenUnitStatusEnum._(String name) : super(name);

  static BuiltSet<OwnerOpenUnitStatusEnum> get values =>
      _$ownerOpenUnitStatusEnumValues;
  static OwnerOpenUnitStatusEnum valueOf(String name) =>
      _$ownerOpenUnitStatusEnumValueOf(name);
}
