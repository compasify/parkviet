//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice_buyer.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_buyer_request.g.dart';

/// PosEinvoiceBuyerRequest
///
/// Properties:
/// * [buyer]
@BuiltValue()
abstract class PosEinvoiceBuyerRequest
    implements Built<PosEinvoiceBuyerRequest, PosEinvoiceBuyerRequestBuilder> {
  @BuiltValueField(wireName: r'buyer')
  EinvoiceBuyer get buyer;

  PosEinvoiceBuyerRequest._();

  factory PosEinvoiceBuyerRequest(
          [void updates(PosEinvoiceBuyerRequestBuilder b)]) =
      _$PosEinvoiceBuyerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceBuyerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceBuyerRequest> get serializer =>
      _$PosEinvoiceBuyerRequestSerializer();
}

class _$PosEinvoiceBuyerRequestSerializer
    implements PrimitiveSerializer<PosEinvoiceBuyerRequest> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceBuyerRequest,
    _$PosEinvoiceBuyerRequest
  ];

  @override
  final String wireName = r'PosEinvoiceBuyerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceBuyerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'buyer';
    yield serializers.serialize(
      object.buyer,
      specifiedType: const FullType(EinvoiceBuyer),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceBuyerRequest object, {
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
    required PosEinvoiceBuyerRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosEinvoiceBuyerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceBuyerRequestBuilder();
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
