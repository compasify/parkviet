//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_summary200_response.g.dart';

/// PosEinvoiceSummary200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosEinvoiceSummary200Response
    implements
        Built<PosEinvoiceSummary200Response,
            PosEinvoiceSummary200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  EinvoiceSummary get data;

  PosEinvoiceSummary200Response._();

  factory PosEinvoiceSummary200Response(
          [void updates(PosEinvoiceSummary200ResponseBuilder b)]) =
      _$PosEinvoiceSummary200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceSummary200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceSummary200Response> get serializer =>
      _$PosEinvoiceSummary200ResponseSerializer();
}

class _$PosEinvoiceSummary200ResponseSerializer
    implements PrimitiveSerializer<PosEinvoiceSummary200Response> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceSummary200Response,
    _$PosEinvoiceSummary200Response
  ];

  @override
  final String wireName = r'PosEinvoiceSummary200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceSummary200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(EinvoiceSummary),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceSummary200Response object, {
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
    required PosEinvoiceSummary200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSummary),
          ) as EinvoiceSummary;
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
  PosEinvoiceSummary200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceSummary200ResponseBuilder();
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
