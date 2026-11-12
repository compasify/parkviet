//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_segment_edit_input.g.dart';

/// TimedSegmentEditInput
///
/// Properties:
/// * [reason] - Why the times are corrected; kept in the audit.
/// * [startedAt]
/// * [endedAt] - Only for a stretch that has ended.
/// * [approvalId] - A manager's approval for `timed.edit_segment`, for someone without `pos.timed.edit`.
@BuiltValue()
abstract class TimedSegmentEditInput
    implements Built<TimedSegmentEditInput, TimedSegmentEditInputBuilder> {
  /// Why the times are corrected; kept in the audit.
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  /// Only for a stretch that has ended.
  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  /// A manager's approval for `timed.edit_segment`, for someone without `pos.timed.edit`.
  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  TimedSegmentEditInput._();

  factory TimedSegmentEditInput(
      [void updates(TimedSegmentEditInputBuilder b)]) = _$TimedSegmentEditInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSegmentEditInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSegmentEditInput> get serializer =>
      _$TimedSegmentEditInputSerializer();
}

class _$TimedSegmentEditInputSerializer
    implements PrimitiveSerializer<TimedSegmentEditInput> {
  @override
  final Iterable<Type> types = const [
    TimedSegmentEditInput,
    _$TimedSegmentEditInput
  ];

  @override
  final String wireName = r'TimedSegmentEditInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSegmentEditInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.endedAt != null) {
      yield r'ended_at';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType(DateTime),
      );
    }
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
    TimedSegmentEditInput object, {
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
    required TimedSegmentEditInputBuilder result,
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
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
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
  TimedSegmentEditInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSegmentEditInputBuilder();
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
