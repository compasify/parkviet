//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_staff_member.g.dart';

/// DeviceStaffMember
///
/// Properties:
/// * [id] - Staff membership id, sent back as `membership_id`.
/// * [name]
/// * [pinSet]
@BuiltValue()
abstract class DeviceStaffMember
    implements Built<DeviceStaffMember, DeviceStaffMemberBuilder> {
  /// Staff membership id, sent back as `membership_id`.
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'pin_set')
  bool get pinSet;

  DeviceStaffMember._();

  factory DeviceStaffMember([void updates(DeviceStaffMemberBuilder b)]) =
      _$DeviceStaffMember;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceStaffMemberBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceStaffMember> get serializer =>
      _$DeviceStaffMemberSerializer();
}

class _$DeviceStaffMemberSerializer
    implements PrimitiveSerializer<DeviceStaffMember> {
  @override
  final Iterable<Type> types = const [DeviceStaffMember, _$DeviceStaffMember];

  @override
  final String wireName = r'DeviceStaffMember';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceStaffMember object, {
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
    yield r'pin_set';
    yield serializers.serialize(
      object.pinSet,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceStaffMember object, {
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
    required DeviceStaffMemberBuilder result,
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
        case r'pin_set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pinSet = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceStaffMember deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceStaffMemberBuilder();
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
