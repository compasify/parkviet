//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_receipt_print_void_request.g.dart';

/// PosReceiptPrintVoidRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class PosReceiptPrintVoidRequest
    implements
        Built<PosReceiptPrintVoidRequest, PosReceiptPrintVoidRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  PosReceiptPrintVoidRequestReasonEnum get reason;
  // enum reasonEnum {  mixed_content,  no_address,  printer_error,  not_sent,  };

  PosReceiptPrintVoidRequest._();

  factory PosReceiptPrintVoidRequest(
          [void updates(PosReceiptPrintVoidRequestBuilder b)]) =
      _$PosReceiptPrintVoidRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosReceiptPrintVoidRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosReceiptPrintVoidRequest> get serializer =>
      _$PosReceiptPrintVoidRequestSerializer();
}

class _$PosReceiptPrintVoidRequestSerializer
    implements PrimitiveSerializer<PosReceiptPrintVoidRequest> {
  @override
  final Iterable<Type> types = const [
    PosReceiptPrintVoidRequest,
    _$PosReceiptPrintVoidRequest
  ];

  @override
  final String wireName = r'PosReceiptPrintVoidRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosReceiptPrintVoidRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(PosReceiptPrintVoidRequestReasonEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosReceiptPrintVoidRequest object, {
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
    required PosReceiptPrintVoidRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosReceiptPrintVoidRequestReasonEnum),
          ) as PosReceiptPrintVoidRequestReasonEnum;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosReceiptPrintVoidRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosReceiptPrintVoidRequestBuilder();
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

class PosReceiptPrintVoidRequestReasonEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'mixed_content')
  static const PosReceiptPrintVoidRequestReasonEnum mixedContent =
      _$posReceiptPrintVoidRequestReasonEnum_mixedContent;
  @BuiltValueEnumConst(wireName: r'no_address')
  static const PosReceiptPrintVoidRequestReasonEnum noAddress =
      _$posReceiptPrintVoidRequestReasonEnum_noAddress;
  @BuiltValueEnumConst(wireName: r'printer_error')
  static const PosReceiptPrintVoidRequestReasonEnum printerError =
      _$posReceiptPrintVoidRequestReasonEnum_printerError;
  @BuiltValueEnumConst(wireName: r'not_sent')
  static const PosReceiptPrintVoidRequestReasonEnum notSent =
      _$posReceiptPrintVoidRequestReasonEnum_notSent;

  static Serializer<PosReceiptPrintVoidRequestReasonEnum> get serializer =>
      _$posReceiptPrintVoidRequestReasonEnumSerializer;

  const PosReceiptPrintVoidRequestReasonEnum._(String name) : super(name);

  static BuiltSet<PosReceiptPrintVoidRequestReasonEnum> get values =>
      _$posReceiptPrintVoidRequestReasonEnumValues;
  static PosReceiptPrintVoidRequestReasonEnum valueOf(String name) =>
      _$posReceiptPrintVoidRequestReasonEnumValueOf(name);
}
