//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_receipt_print_void200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_receipt_print_void200_response.g.dart';

/// PosReceiptPrintVoid200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosReceiptPrintVoid200Response
    implements
        Built<PosReceiptPrintVoid200Response,
            PosReceiptPrintVoid200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PosReceiptPrintVoid200ResponseData get data;

  PosReceiptPrintVoid200Response._();

  factory PosReceiptPrintVoid200Response(
          [void updates(PosReceiptPrintVoid200ResponseBuilder b)]) =
      _$PosReceiptPrintVoid200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosReceiptPrintVoid200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosReceiptPrintVoid200Response> get serializer =>
      _$PosReceiptPrintVoid200ResponseSerializer();
}

class _$PosReceiptPrintVoid200ResponseSerializer
    implements PrimitiveSerializer<PosReceiptPrintVoid200Response> {
  @override
  final Iterable<Type> types = const [
    PosReceiptPrintVoid200Response,
    _$PosReceiptPrintVoid200Response
  ];

  @override
  final String wireName = r'PosReceiptPrintVoid200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosReceiptPrintVoid200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PosReceiptPrintVoid200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosReceiptPrintVoid200Response object, {
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
    required PosReceiptPrintVoid200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosReceiptPrintVoid200ResponseData),
          ) as PosReceiptPrintVoid200ResponseData;
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
  PosReceiptPrintVoid200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosReceiptPrintVoid200ResponseBuilder();
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
