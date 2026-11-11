//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/device_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_me200_response.g.dart';

/// PosDeviceMe200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDeviceMe200Response
    implements Built<PosDeviceMe200Response, PosDeviceMe200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DeviceSession get data;

  PosDeviceMe200Response._();

  factory PosDeviceMe200Response(
          [void updates(PosDeviceMe200ResponseBuilder b)]) =
      _$PosDeviceMe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceMe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceMe200Response> get serializer =>
      _$PosDeviceMe200ResponseSerializer();
}

class _$PosDeviceMe200ResponseSerializer
    implements PrimitiveSerializer<PosDeviceMe200Response> {
  @override
  final Iterable<Type> types = const [
    PosDeviceMe200Response,
    _$PosDeviceMe200Response
  ];

  @override
  final String wireName = r'PosDeviceMe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DeviceSession),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceMe200Response object, {
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
    required PosDeviceMe200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceSession),
          ) as DeviceSession;
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
  PosDeviceMe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceMe200ResponseBuilder();
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
