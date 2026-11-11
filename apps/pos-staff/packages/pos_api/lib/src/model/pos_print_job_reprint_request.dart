//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_print_job_reprint_request.g.dart';

/// PosPrintJobReprintRequest
///
/// Properties:
/// * [approvalId]
@BuiltValue()
abstract class PosPrintJobReprintRequest
    implements
        Built<PosPrintJobReprintRequest, PosPrintJobReprintRequestBuilder> {
  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  PosPrintJobReprintRequest._();

  factory PosPrintJobReprintRequest(
          [void updates(PosPrintJobReprintRequestBuilder b)]) =
      _$PosPrintJobReprintRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrintJobReprintRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrintJobReprintRequest> get serializer =>
      _$PosPrintJobReprintRequestSerializer();
}

class _$PosPrintJobReprintRequestSerializer
    implements PrimitiveSerializer<PosPrintJobReprintRequest> {
  @override
  final Iterable<Type> types = const [
    PosPrintJobReprintRequest,
    _$PosPrintJobReprintRequest
  ];

  @override
  final String wireName = r'PosPrintJobReprintRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrintJobReprintRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrintJobReprintRequest object, {
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
    required PosPrintJobReprintRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosPrintJobReprintRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrintJobReprintRequestBuilder();
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
