//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/hardware_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_hardware_status200_response.g.dart';

/// PosHardwareStatus200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosHardwareStatus200Response
    implements
        Built<PosHardwareStatus200Response,
            PosHardwareStatus200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  HardwareStatus get data;

  PosHardwareStatus200Response._();

  factory PosHardwareStatus200Response(
          [void updates(PosHardwareStatus200ResponseBuilder b)]) =
      _$PosHardwareStatus200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosHardwareStatus200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosHardwareStatus200Response> get serializer =>
      _$PosHardwareStatus200ResponseSerializer();
}

class _$PosHardwareStatus200ResponseSerializer
    implements PrimitiveSerializer<PosHardwareStatus200Response> {
  @override
  final Iterable<Type> types = const [
    PosHardwareStatus200Response,
    _$PosHardwareStatus200Response
  ];

  @override
  final String wireName = r'PosHardwareStatus200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosHardwareStatus200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(HardwareStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosHardwareStatus200Response object, {
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
    required PosHardwareStatus200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareStatus),
          ) as HardwareStatus;
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
  PosHardwareStatus200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosHardwareStatus200ResponseBuilder();
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
