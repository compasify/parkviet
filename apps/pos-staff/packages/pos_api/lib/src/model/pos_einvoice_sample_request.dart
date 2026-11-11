//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_sample_request.g.dart';

/// PosEinvoiceSampleRequest
///
/// Properties:
/// * [branchId]
@BuiltValue()
abstract class PosEinvoiceSampleRequest
    implements
        Built<PosEinvoiceSampleRequest, PosEinvoiceSampleRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  PosEinvoiceSampleRequest._();

  factory PosEinvoiceSampleRequest(
          [void updates(PosEinvoiceSampleRequestBuilder b)]) =
      _$PosEinvoiceSampleRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceSampleRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceSampleRequest> get serializer =>
      _$PosEinvoiceSampleRequestSerializer();
}

class _$PosEinvoiceSampleRequestSerializer
    implements PrimitiveSerializer<PosEinvoiceSampleRequest> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceSampleRequest,
    _$PosEinvoiceSampleRequest
  ];

  @override
  final String wireName = r'PosEinvoiceSampleRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceSampleRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceSampleRequest object, {
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
    required PosEinvoiceSampleRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosEinvoiceSampleRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceSampleRequestBuilder();
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
