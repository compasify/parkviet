//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/device_session_staff.dart';
import 'package:pos_api/src/model/device.dart';
import 'package:pos_api/src/model/device_session_branch.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_session.g.dart';

/// DeviceSession
///
/// Properties:
/// * [device]
/// * [branch]
/// * [registerId]
/// * [kitchenStationId]
/// * [staff]
/// * [serverTime] - Shows clock skew for timers; a device never sends its own clock as data.
@BuiltValue()
abstract class DeviceSession
    implements Built<DeviceSession, DeviceSessionBuilder> {
  @BuiltValueField(wireName: r'device')
  Device get device;

  @BuiltValueField(wireName: r'branch')
  DeviceSessionBranch get branch;

  @BuiltValueField(wireName: r'register_id')
  String? get registerId;

  @BuiltValueField(wireName: r'kitchen_station_id')
  String? get kitchenStationId;

  @BuiltValueField(wireName: r'staff')
  DeviceSessionStaff? get staff;

  /// Shows clock skew for timers; a device never sends its own clock as data.
  @BuiltValueField(wireName: r'server_time')
  DateTime get serverTime;

  DeviceSession._();

  factory DeviceSession([void updates(DeviceSessionBuilder b)]) =
      _$DeviceSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceSession> get serializer =>
      _$DeviceSessionSerializer();
}

class _$DeviceSessionSerializer implements PrimitiveSerializer<DeviceSession> {
  @override
  final Iterable<Type> types = const [DeviceSession, _$DeviceSession];

  @override
  final String wireName = r'DeviceSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device';
    yield serializers.serialize(
      object.device,
      specifiedType: const FullType(Device),
    );
    yield r'branch';
    yield serializers.serialize(
      object.branch,
      specifiedType: const FullType(DeviceSessionBranch),
    );
    if (object.registerId != null) {
      yield r'register_id';
      yield serializers.serialize(
        object.registerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.kitchenStationId != null) {
      yield r'kitchen_station_id';
      yield serializers.serialize(
        object.kitchenStationId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.staff != null) {
      yield r'staff';
      yield serializers.serialize(
        object.staff,
        specifiedType: const FullType.nullable(DeviceSessionStaff),
      );
    }
    yield r'server_time';
    yield serializers.serialize(
      object.serverTime,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceSession object, {
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
    required DeviceSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Device),
          ) as Device;
          result.device.replace(valueDes);
          break;
        case r'branch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceSessionBranch),
          ) as DeviceSessionBranch;
          result.branch.replace(valueDes);
          break;
        case r'register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.registerId = valueDes;
          break;
        case r'kitchen_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenStationId = valueDes;
          break;
        case r'staff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DeviceSessionStaff),
          ) as DeviceSessionStaff?;
          if (valueDes == null) continue;
          result.staff.replace(valueDes);
          break;
        case r'server_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceSessionBuilder();
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
