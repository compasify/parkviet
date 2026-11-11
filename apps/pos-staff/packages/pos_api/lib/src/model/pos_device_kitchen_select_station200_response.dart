//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/device.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_kitchen_select_station200_response.g.dart';

/// PosDeviceKitchenSelectStation200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDeviceKitchenSelectStation200Response
    implements
        Built<PosDeviceKitchenSelectStation200Response,
            PosDeviceKitchenSelectStation200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Device get data;

  PosDeviceKitchenSelectStation200Response._();

  factory PosDeviceKitchenSelectStation200Response(
          [void updates(PosDeviceKitchenSelectStation200ResponseBuilder b)]) =
      _$PosDeviceKitchenSelectStation200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceKitchenSelectStation200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceKitchenSelectStation200Response> get serializer =>
      _$PosDeviceKitchenSelectStation200ResponseSerializer();
}

class _$PosDeviceKitchenSelectStation200ResponseSerializer
    implements PrimitiveSerializer<PosDeviceKitchenSelectStation200Response> {
  @override
  final Iterable<Type> types = const [
    PosDeviceKitchenSelectStation200Response,
    _$PosDeviceKitchenSelectStation200Response
  ];

  @override
  final String wireName = r'PosDeviceKitchenSelectStation200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceKitchenSelectStation200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Device),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceKitchenSelectStation200Response object, {
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
    required PosDeviceKitchenSelectStation200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Device),
          ) as Device;
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
  PosDeviceKitchenSelectStation200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceKitchenSelectStation200ResponseBuilder();
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
