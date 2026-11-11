//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_printer_delete200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_delete200_response.g.dart';

/// PosPrinterDelete200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrinterDelete200Response
    implements
        Built<PosPrinterDelete200Response, PosPrinterDelete200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PosPrinterDelete200ResponseData get data;

  PosPrinterDelete200Response._();

  factory PosPrinterDelete200Response(
          [void updates(PosPrinterDelete200ResponseBuilder b)]) =
      _$PosPrinterDelete200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterDelete200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterDelete200Response> get serializer =>
      _$PosPrinterDelete200ResponseSerializer();
}

class _$PosPrinterDelete200ResponseSerializer
    implements PrimitiveSerializer<PosPrinterDelete200Response> {
  @override
  final Iterable<Type> types = const [
    PosPrinterDelete200Response,
    _$PosPrinterDelete200Response
  ];

  @override
  final String wireName = r'PosPrinterDelete200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterDelete200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PosPrinterDelete200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterDelete200Response object, {
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
    required PosPrinterDelete200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosPrinterDelete200ResponseData),
          ) as PosPrinterDelete200ResponseData;
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
  PosPrinterDelete200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterDelete200ResponseBuilder();
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
