//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device.g.dart';

/// Device
///
/// Properties:
/// * [id]
/// * [name]
/// * [mode]
/// * [status]
/// * [branchId]
/// * [platform]
/// * [kitchenStationId] - The station a kitchen screen shows; null for every station.
/// * [lastSeenAt]
@BuiltValue()
abstract class Device implements Built<Device, DeviceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'mode')
  DeviceModeEnum get mode;
  // enum modeEnum {  waiter,  kds,  expo,  kiosk,  print_station,  owner,  };

  @BuiltValueField(wireName: r'status')
  DeviceStatusEnum get status;
  // enum statusEnum {  active,  revoked,  };

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'platform')
  String? get platform;

  /// The station a kitchen screen shows; null for every station.
  @BuiltValueField(wireName: r'kitchen_station_id')
  String? get kitchenStationId;

  @BuiltValueField(wireName: r'last_seen_at')
  String? get lastSeenAt;

  Device._();

  factory Device([void updates(DeviceBuilder b)]) = _$Device;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Device> get serializer => _$DeviceSerializer();
}

class _$DeviceSerializer implements PrimitiveSerializer<Device> {
  @override
  final Iterable<Type> types = const [Device, _$Device];

  @override
  final String wireName = r'Device';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Device object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(DeviceModeEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DeviceStatusEnum),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.platform != null) {
      yield r'platform';
      yield serializers.serialize(
        object.platform,
        specifiedType: const FullType(String),
      );
    }
    if (object.kitchenStationId != null) {
      yield r'kitchen_station_id';
      yield serializers.serialize(
        object.kitchenStationId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lastSeenAt != null) {
      yield r'last_seen_at';
      yield serializers.serialize(
        object.lastSeenAt,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Device object, {
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
    required DeviceBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceModeEnum),
          ) as DeviceModeEnum;
          result.mode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceStatusEnum),
          ) as DeviceStatusEnum;
          result.status = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.platform = valueDes;
          break;
        case r'kitchen_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenStationId = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastSeenAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Device deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceBuilder();
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

class DeviceModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'waiter')
  static const DeviceModeEnum waiter = _$deviceModeEnum_waiter;
  @BuiltValueEnumConst(wireName: r'kds')
  static const DeviceModeEnum kds = _$deviceModeEnum_kds;
  @BuiltValueEnumConst(wireName: r'expo')
  static const DeviceModeEnum expo = _$deviceModeEnum_expo;
  @BuiltValueEnumConst(wireName: r'kiosk')
  static const DeviceModeEnum kiosk = _$deviceModeEnum_kiosk;
  @BuiltValueEnumConst(wireName: r'print_station')
  static const DeviceModeEnum printStation = _$deviceModeEnum_printStation;
  @BuiltValueEnumConst(wireName: r'owner')
  static const DeviceModeEnum owner = _$deviceModeEnum_owner;

  static Serializer<DeviceModeEnum> get serializer =>
      _$deviceModeEnumSerializer;

  const DeviceModeEnum._(String name) : super(name);

  static BuiltSet<DeviceModeEnum> get values => _$deviceModeEnumValues;
  static DeviceModeEnum valueOf(String name) => _$deviceModeEnumValueOf(name);
}

class DeviceStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const DeviceStatusEnum active = _$deviceStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'revoked')
  static const DeviceStatusEnum revoked = _$deviceStatusEnum_revoked;

  static Serializer<DeviceStatusEnum> get serializer =>
      _$deviceStatusEnumSerializer;

  const DeviceStatusEnum._(String name) : super(name);

  static BuiltSet<DeviceStatusEnum> get values => _$deviceStatusEnumValues;
  static DeviceStatusEnum valueOf(String name) =>
      _$deviceStatusEnumValueOf(name);
}
