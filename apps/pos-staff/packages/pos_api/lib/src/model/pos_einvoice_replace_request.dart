//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice_buyer.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_replace_request.g.dart';

/// PosEinvoiceReplaceRequest
///
/// Properties:
/// * [buyer]
/// * [reason]
@BuiltValue()
abstract class PosEinvoiceReplaceRequest
    implements
        Built<PosEinvoiceReplaceRequest, PosEinvoiceReplaceRequestBuilder> {
  @BuiltValueField(wireName: r'buyer')
  EinvoiceBuyer get buyer;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PosEinvoiceReplaceRequest._();

  factory PosEinvoiceReplaceRequest(
          [void updates(PosEinvoiceReplaceRequestBuilder b)]) =
      _$PosEinvoiceReplaceRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceReplaceRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceReplaceRequest> get serializer =>
      _$PosEinvoiceReplaceRequestSerializer();
}

class _$PosEinvoiceReplaceRequestSerializer
    implements PrimitiveSerializer<PosEinvoiceReplaceRequest> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceReplaceRequest,
    _$PosEinvoiceReplaceRequest
  ];

  @override
  final String wireName = r'PosEinvoiceReplaceRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceReplaceRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'buyer';
    yield serializers.serialize(
      object.buyer,
      specifiedType: const FullType(EinvoiceBuyer),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceReplaceRequest object, {
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
    required PosEinvoiceReplaceRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'buyer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceBuyer),
          ) as EinvoiceBuyer;
          result.buyer.replace(valueDes);
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  PosEinvoiceReplaceRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceReplaceRequestBuilder();
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
