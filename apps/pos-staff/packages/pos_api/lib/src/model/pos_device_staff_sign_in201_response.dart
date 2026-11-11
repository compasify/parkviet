//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/device_staff_sign_in.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_staff_sign_in201_response.g.dart';

/// PosDeviceStaffSignIn201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDeviceStaffSignIn201Response
    implements
        Built<PosDeviceStaffSignIn201Response,
            PosDeviceStaffSignIn201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DeviceStaffSignIn get data;

  PosDeviceStaffSignIn201Response._();

  factory PosDeviceStaffSignIn201Response(
          [void updates(PosDeviceStaffSignIn201ResponseBuilder b)]) =
      _$PosDeviceStaffSignIn201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceStaffSignIn201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceStaffSignIn201Response> get serializer =>
      _$PosDeviceStaffSignIn201ResponseSerializer();
}

class _$PosDeviceStaffSignIn201ResponseSerializer
    implements PrimitiveSerializer<PosDeviceStaffSignIn201Response> {
  @override
  final Iterable<Type> types = const [
    PosDeviceStaffSignIn201Response,
    _$PosDeviceStaffSignIn201Response
  ];

  @override
  final String wireName = r'PosDeviceStaffSignIn201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceStaffSignIn201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DeviceStaffSignIn),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceStaffSignIn201Response object, {
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
    required PosDeviceStaffSignIn201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceStaffSignIn),
          ) as DeviceStaffSignIn;
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
  PosDeviceStaffSignIn201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceStaffSignIn201ResponseBuilder();
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
