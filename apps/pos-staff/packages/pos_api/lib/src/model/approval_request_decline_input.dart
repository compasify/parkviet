//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'approval_request_decline_input.g.dart';

/// ApprovalRequestDeclineInput
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class ApprovalRequestDeclineInput
    implements
        Built<ApprovalRequestDeclineInput, ApprovalRequestDeclineInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  ApprovalRequestDeclineInput._();

  factory ApprovalRequestDeclineInput(
          [void updates(ApprovalRequestDeclineInputBuilder b)]) =
      _$ApprovalRequestDeclineInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApprovalRequestDeclineInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApprovalRequestDeclineInput> get serializer =>
      _$ApprovalRequestDeclineInputSerializer();
}

class _$ApprovalRequestDeclineInputSerializer
    implements PrimitiveSerializer<ApprovalRequestDeclineInput> {
  @override
  final Iterable<Type> types = const [
    ApprovalRequestDeclineInput,
    _$ApprovalRequestDeclineInput
  ];

  @override
  final String wireName = r'ApprovalRequestDeclineInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApprovalRequestDeclineInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ApprovalRequestDeclineInput object, {
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
    required ApprovalRequestDeclineInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  ApprovalRequestDeclineInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApprovalRequestDeclineInputBuilder();
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
