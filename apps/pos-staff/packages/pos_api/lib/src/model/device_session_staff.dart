//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_session_staff.g.dart';

/// The signed-in person, when the request carries a staff session.
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class DeviceSessionStaff
    implements Built<DeviceSessionStaff, DeviceSessionStaffBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  DeviceSessionStaff._();

  factory DeviceSessionStaff([void updates(DeviceSessionStaffBuilder b)]) =
      _$DeviceSessionStaff;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceSessionStaffBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceSessionStaff> get serializer =>
      _$DeviceSessionStaffSerializer();
}

class _$DeviceSessionStaffSerializer
    implements PrimitiveSerializer<DeviceSessionStaff> {
  @override
  final Iterable<Type> types = const [DeviceSessionStaff, _$DeviceSessionStaff];

  @override
  final String wireName = r'DeviceSessionStaff';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceSessionStaff object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceSessionStaff object, {
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
    required DeviceSessionStaffBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceSessionStaff deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceSessionStaffBuilder();
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
