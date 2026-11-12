//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/approval_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'approval_request_result.g.dart';

/// ApprovalRequestResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ApprovalRequestResult
    implements Built<ApprovalRequestResult, ApprovalRequestResultBuilder> {
  @BuiltValueField(wireName: r'data')
  ApprovalRequest get data;

  ApprovalRequestResult._();

  factory ApprovalRequestResult(
      [void updates(ApprovalRequestResultBuilder b)]) = _$ApprovalRequestResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApprovalRequestResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApprovalRequestResult> get serializer =>
      _$ApprovalRequestResultSerializer();
}

class _$ApprovalRequestResultSerializer
    implements PrimitiveSerializer<ApprovalRequestResult> {
  @override
  final Iterable<Type> types = const [
    ApprovalRequestResult,
    _$ApprovalRequestResult
  ];

  @override
  final String wireName = r'ApprovalRequestResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApprovalRequestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ApprovalRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApprovalRequestResult object, {
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
    required ApprovalRequestResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApprovalRequest),
          ) as ApprovalRequest;
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
  ApprovalRequestResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApprovalRequestResultBuilder();
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
