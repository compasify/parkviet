//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_einvoice_retry200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_retry200_response.g.dart';

/// PosEinvoiceRetry200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosEinvoiceRetry200Response
    implements
        Built<PosEinvoiceRetry200Response, PosEinvoiceRetry200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PosEinvoiceRetry200ResponseData get data;

  PosEinvoiceRetry200Response._();

  factory PosEinvoiceRetry200Response(
          [void updates(PosEinvoiceRetry200ResponseBuilder b)]) =
      _$PosEinvoiceRetry200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceRetry200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceRetry200Response> get serializer =>
      _$PosEinvoiceRetry200ResponseSerializer();
}

class _$PosEinvoiceRetry200ResponseSerializer
    implements PrimitiveSerializer<PosEinvoiceRetry200Response> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceRetry200Response,
    _$PosEinvoiceRetry200Response
  ];

  @override
  final String wireName = r'PosEinvoiceRetry200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceRetry200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PosEinvoiceRetry200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceRetry200Response object, {
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
    required PosEinvoiceRetry200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosEinvoiceRetry200ResponseData),
          ) as PosEinvoiceRetry200ResponseData;
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
  PosEinvoiceRetry200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceRetry200ResponseBuilder();
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
