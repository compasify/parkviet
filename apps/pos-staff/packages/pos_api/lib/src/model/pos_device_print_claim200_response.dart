//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job_claim.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_print_claim200_response.g.dart';

/// PosDevicePrintClaim200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDevicePrintClaim200Response
    implements
        Built<PosDevicePrintClaim200Response,
            PosDevicePrintClaim200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrintJobClaim? get data;

  PosDevicePrintClaim200Response._();

  factory PosDevicePrintClaim200Response(
          [void updates(PosDevicePrintClaim200ResponseBuilder b)]) =
      _$PosDevicePrintClaim200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDevicePrintClaim200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDevicePrintClaim200Response> get serializer =>
      _$PosDevicePrintClaim200ResponseSerializer();
}

class _$PosDevicePrintClaim200ResponseSerializer
    implements PrimitiveSerializer<PosDevicePrintClaim200Response> {
  @override
  final Iterable<Type> types = const [
    PosDevicePrintClaim200Response,
    _$PosDevicePrintClaim200Response
  ];

  @override
  final String wireName = r'PosDevicePrintClaim200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDevicePrintClaim200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield object.data == null
        ? null
        : serializers.serialize(
            object.data,
            specifiedType: const FullType.nullable(PrintJobClaim),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDevicePrintClaim200Response object, {
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
    required PosDevicePrintClaim200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrintJobClaim),
          ) as PrintJobClaim?;
          if (valueDes == null) continue;
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
  PosDevicePrintClaim200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDevicePrintClaim200ResponseBuilder();
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
