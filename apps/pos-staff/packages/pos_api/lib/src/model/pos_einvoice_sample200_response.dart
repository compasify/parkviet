//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice_sample.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_sample200_response.g.dart';

/// PosEinvoiceSample200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosEinvoiceSample200Response
    implements
        Built<PosEinvoiceSample200Response,
            PosEinvoiceSample200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  EinvoiceSample get data;

  PosEinvoiceSample200Response._();

  factory PosEinvoiceSample200Response(
          [void updates(PosEinvoiceSample200ResponseBuilder b)]) =
      _$PosEinvoiceSample200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceSample200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceSample200Response> get serializer =>
      _$PosEinvoiceSample200ResponseSerializer();
}

class _$PosEinvoiceSample200ResponseSerializer
    implements PrimitiveSerializer<PosEinvoiceSample200Response> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceSample200Response,
    _$PosEinvoiceSample200Response
  ];

  @override
  final String wireName = r'PosEinvoiceSample200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceSample200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(EinvoiceSample),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceSample200Response object, {
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
    required PosEinvoiceSample200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSample),
          ) as EinvoiceSample;
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
  PosEinvoiceSample200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceSample200ResponseBuilder();
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
