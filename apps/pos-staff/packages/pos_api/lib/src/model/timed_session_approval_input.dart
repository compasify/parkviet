//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_approval_input.g.dart';

/// TimedSessionApprovalInput
///
/// Properties:
/// * [approvalId] - A manager's approval for `timed.long_pause`, for someone without `pos.timed.edit`.
@BuiltValue()
abstract class TimedSessionApprovalInput
    implements
        Built<TimedSessionApprovalInput, TimedSessionApprovalInputBuilder> {
  /// A manager's approval for `timed.long_pause`, for someone without `pos.timed.edit`.
  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  TimedSessionApprovalInput._();

  factory TimedSessionApprovalInput(
          [void updates(TimedSessionApprovalInputBuilder b)]) =
      _$TimedSessionApprovalInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionApprovalInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSessionApprovalInput> get serializer =>
      _$TimedSessionApprovalInputSerializer();
}

class _$TimedSessionApprovalInputSerializer
    implements PrimitiveSerializer<TimedSessionApprovalInput> {
  @override
  final Iterable<Type> types = const [
    TimedSessionApprovalInput,
    _$TimedSessionApprovalInput
  ];

  @override
  final String wireName = r'TimedSessionApprovalInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSessionApprovalInput object, {
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
    TimedSessionApprovalInput object, {
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
    required TimedSessionApprovalInputBuilder result,
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
  TimedSessionApprovalInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionApprovalInputBuilder();
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
