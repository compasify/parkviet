//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_settings200_response.g.dart';

/// PosEinvoiceSettings200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosEinvoiceSettings200Response
    implements
        Built<PosEinvoiceSettings200Response,
            PosEinvoiceSettings200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  EinvoiceSettings get data;

  PosEinvoiceSettings200Response._();

  factory PosEinvoiceSettings200Response(
          [void updates(PosEinvoiceSettings200ResponseBuilder b)]) =
      _$PosEinvoiceSettings200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceSettings200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceSettings200Response> get serializer =>
      _$PosEinvoiceSettings200ResponseSerializer();
}

class _$PosEinvoiceSettings200ResponseSerializer
    implements PrimitiveSerializer<PosEinvoiceSettings200Response> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceSettings200Response,
    _$PosEinvoiceSettings200Response
  ];

  @override
  final String wireName = r'PosEinvoiceSettings200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceSettings200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(EinvoiceSettings),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceSettings200Response object, {
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
    required PosEinvoiceSettings200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSettings),
          ) as EinvoiceSettings;
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
  PosEinvoiceSettings200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceSettings200ResponseBuilder();
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
