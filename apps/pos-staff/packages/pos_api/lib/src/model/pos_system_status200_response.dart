//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/system_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_system_status200_response.g.dart';

/// PosSystemStatus200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosSystemStatus200Response
    implements
        Built<PosSystemStatus200Response, PosSystemStatus200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SystemStatus get data;

  PosSystemStatus200Response._();

  factory PosSystemStatus200Response(
          [void updates(PosSystemStatus200ResponseBuilder b)]) =
      _$PosSystemStatus200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosSystemStatus200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosSystemStatus200Response> get serializer =>
      _$PosSystemStatus200ResponseSerializer();
}

class _$PosSystemStatus200ResponseSerializer
    implements PrimitiveSerializer<PosSystemStatus200Response> {
  @override
  final Iterable<Type> types = const [
    PosSystemStatus200Response,
    _$PosSystemStatus200Response
  ];

  @override
  final String wireName = r'PosSystemStatus200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosSystemStatus200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SystemStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosSystemStatus200Response object, {
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
    required PosSystemStatus200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatus),
          ) as SystemStatus;
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
  PosSystemStatus200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosSystemStatus200ResponseBuilder();
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
