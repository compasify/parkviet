//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_retry_request.g.dart';

/// PosEinvoiceRetryRequest
///
/// Properties:
/// * [ids]
/// * [branchId]
@BuiltValue()
abstract class PosEinvoiceRetryRequest
    implements Built<PosEinvoiceRetryRequest, PosEinvoiceRetryRequestBuilder> {
  @BuiltValueField(wireName: r'ids')
  BuiltList<String>? get ids;

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  PosEinvoiceRetryRequest._();

  factory PosEinvoiceRetryRequest(
          [void updates(PosEinvoiceRetryRequestBuilder b)]) =
      _$PosEinvoiceRetryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceRetryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceRetryRequest> get serializer =>
      _$PosEinvoiceRetryRequestSerializer();
}

class _$PosEinvoiceRetryRequestSerializer
    implements PrimitiveSerializer<PosEinvoiceRetryRequest> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceRetryRequest,
    _$PosEinvoiceRetryRequest
  ];

  @override
  final String wireName = r'PosEinvoiceRetryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceRetryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ids != null) {
      yield r'ids';
      yield serializers.serialize(
        object.ids,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
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
    PosEinvoiceRetryRequest object, {
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
    required PosEinvoiceRetryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.ids.replace(valueDes);
          break;
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
  PosEinvoiceRetryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceRetryRequestBuilder();
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
