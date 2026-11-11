//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_cancel_request.g.dart';

/// PosEinvoiceCancelRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class PosEinvoiceCancelRequest
    implements
        Built<PosEinvoiceCancelRequest, PosEinvoiceCancelRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  PosEinvoiceCancelRequest._();

  factory PosEinvoiceCancelRequest(
          [void updates(PosEinvoiceCancelRequestBuilder b)]) =
      _$PosEinvoiceCancelRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceCancelRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceCancelRequest> get serializer =>
      _$PosEinvoiceCancelRequestSerializer();
}

class _$PosEinvoiceCancelRequestSerializer
    implements PrimitiveSerializer<PosEinvoiceCancelRequest> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceCancelRequest,
    _$PosEinvoiceCancelRequest
  ];

  @override
  final String wireName = r'PosEinvoiceCancelRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceCancelRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceCancelRequest object, {
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
    required PosEinvoiceCancelRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  PosEinvoiceCancelRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceCancelRequestBuilder();
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
