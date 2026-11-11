//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_receipt_print_void200_response_data.g.dart';

/// PosReceiptPrintVoid200ResponseData
///
/// Properties:
/// * [print]
/// * [receipt]
@BuiltValue()
abstract class PosReceiptPrintVoid200ResponseData
    implements
        Built<PosReceiptPrintVoid200ResponseData,
            PosReceiptPrintVoid200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'print')
  JsonObject get print;

  @BuiltValueField(wireName: r'receipt')
  JsonObject get receipt;

  PosReceiptPrintVoid200ResponseData._();

  factory PosReceiptPrintVoid200ResponseData(
          [void updates(PosReceiptPrintVoid200ResponseDataBuilder b)]) =
      _$PosReceiptPrintVoid200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosReceiptPrintVoid200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosReceiptPrintVoid200ResponseData> get serializer =>
      _$PosReceiptPrintVoid200ResponseDataSerializer();
}

class _$PosReceiptPrintVoid200ResponseDataSerializer
    implements PrimitiveSerializer<PosReceiptPrintVoid200ResponseData> {
  @override
  final Iterable<Type> types = const [
    PosReceiptPrintVoid200ResponseData,
    _$PosReceiptPrintVoid200ResponseData
  ];

  @override
  final String wireName = r'PosReceiptPrintVoid200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosReceiptPrintVoid200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'print';
    yield serializers.serialize(
      object.print,
      specifiedType: const FullType(JsonObject),
    );
    yield r'receipt';
    yield serializers.serialize(
      object.receipt,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosReceiptPrintVoid200ResponseData object, {
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
    required PosReceiptPrintVoid200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'print':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.print = valueDes;
          break;
        case r'receipt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.receipt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosReceiptPrintVoid200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosReceiptPrintVoid200ResponseDataBuilder();
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
