//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_printer_test200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_test200_response.g.dart';

/// PosPrinterTest200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrinterTest200Response
    implements
        Built<PosPrinterTest200Response, PosPrinterTest200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PosPrinterTest200ResponseData get data;

  PosPrinterTest200Response._();

  factory PosPrinterTest200Response(
          [void updates(PosPrinterTest200ResponseBuilder b)]) =
      _$PosPrinterTest200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterTest200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterTest200Response> get serializer =>
      _$PosPrinterTest200ResponseSerializer();
}

class _$PosPrinterTest200ResponseSerializer
    implements PrimitiveSerializer<PosPrinterTest200Response> {
  @override
  final Iterable<Type> types = const [
    PosPrinterTest200Response,
    _$PosPrinterTest200Response
  ];

  @override
  final String wireName = r'PosPrinterTest200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterTest200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PosPrinterTest200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterTest200Response object, {
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
    required PosPrinterTest200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosPrinterTest200ResponseData),
          ) as PosPrinterTest200ResponseData;
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
  PosPrinterTest200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterTest200ResponseBuilder();
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
