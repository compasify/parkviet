//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/device_staff_member.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_staff200_response.g.dart';

/// PosDeviceStaff200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDeviceStaff200Response
    implements
        Built<PosDeviceStaff200Response, PosDeviceStaff200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DeviceStaffMember> get data;

  PosDeviceStaff200Response._();

  factory PosDeviceStaff200Response(
          [void updates(PosDeviceStaff200ResponseBuilder b)]) =
      _$PosDeviceStaff200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceStaff200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceStaff200Response> get serializer =>
      _$PosDeviceStaff200ResponseSerializer();
}

class _$PosDeviceStaff200ResponseSerializer
    implements PrimitiveSerializer<PosDeviceStaff200Response> {
  @override
  final Iterable<Type> types = const [
    PosDeviceStaff200Response,
    _$PosDeviceStaff200Response
  ];

  @override
  final String wireName = r'PosDeviceStaff200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceStaff200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(DeviceStaffMember)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceStaff200Response object, {
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
    required PosDeviceStaff200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(DeviceStaffMember)]),
          ) as BuiltList<DeviceStaffMember>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosDeviceStaff200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceStaff200ResponseBuilder();
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
