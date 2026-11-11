//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_device.g.dart';

/// HardwareDevice
///
/// Properties:
/// * [id]
/// * [name]
/// * [mode]
/// * [kitchenStationId]
/// * [lastSeenAt]
/// * [online]
@BuiltValue()
abstract class HardwareDevice
    implements Built<HardwareDevice, HardwareDeviceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'mode')
  HardwareDeviceModeEnum get mode;
  // enum modeEnum {  kds,  expo,  print_station,  };

  @BuiltValueField(wireName: r'kitchen_station_id')
  String get kitchenStationId;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime get lastSeenAt;

  @BuiltValueField(wireName: r'online')
  bool get online;

  HardwareDevice._();

  factory HardwareDevice([void updates(HardwareDeviceBuilder b)]) =
      _$HardwareDevice;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareDeviceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareDevice> get serializer =>
      _$HardwareDeviceSerializer();
}

class _$HardwareDeviceSerializer
    implements PrimitiveSerializer<HardwareDevice> {
  @override
  final Iterable<Type> types = const [HardwareDevice, _$HardwareDevice];

  @override
  final String wireName = r'HardwareDevice';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareDevice object, {
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
      specifiedType: const FullType(HardwareDeviceModeEnum),
    );
    yield r'kitchen_station_id';
    yield serializers.serialize(
      object.kitchenStationId,
      specifiedType: const FullType(String),
    );
    yield r'last_seen_at';
    yield serializers.serialize(
      object.lastSeenAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'online';
    yield serializers.serialize(
      object.online,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareDevice object, {
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
    required HardwareDeviceBuilder result,
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
            specifiedType: const FullType(HardwareDeviceModeEnum),
          ) as HardwareDeviceModeEnum;
          result.mode = valueDes;
          break;
        case r'kitchen_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kitchenStationId = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastSeenAt = valueDes;
          break;
        case r'online':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.online = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareDevice deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareDeviceBuilder();
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

class HardwareDeviceModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'kds')
  static const HardwareDeviceModeEnum kds = _$hardwareDeviceModeEnum_kds;
  @BuiltValueEnumConst(wireName: r'expo')
  static const HardwareDeviceModeEnum expo = _$hardwareDeviceModeEnum_expo;
  @BuiltValueEnumConst(wireName: r'print_station')
  static const HardwareDeviceModeEnum printStation =
      _$hardwareDeviceModeEnum_printStation;

  static Serializer<HardwareDeviceModeEnum> get serializer =>
      _$hardwareDeviceModeEnumSerializer;

  const HardwareDeviceModeEnum._(String name) : super(name);

  static BuiltSet<HardwareDeviceModeEnum> get values =>
      _$hardwareDeviceModeEnumValues;
  static HardwareDeviceModeEnum valueOf(String name) =>
      _$hardwareDeviceModeEnumValueOf(name);
}
