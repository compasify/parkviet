//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_segment.g.dart';

/// A stretch of a clock on one room at one rate plan; an open stretch has no end.
///
/// Properties:
/// * [endedReason] - Why the stretch ended; null while it runs and for older stretches.
/// * [id]
/// * [kind]
/// * [resourceId]
/// * [resourceName]
/// * [startedAt]
/// * [endedAt]
/// * [ratePlanId]
/// * [ratePlanName]
/// * [ratePlanVersion]
/// * [edited] - Its times were corrected by hand.
@BuiltValue()
abstract class TimedSegment
    implements Built<TimedSegment, TimedSegmentBuilder> {
  /// Why the stretch ended; null while it runs and for older stretches.
  @BuiltValueField(wireName: r'ended_reason')
  TimedSegmentEndedReasonEnum? get endedReason;
  // enum endedReasonEnum {  pause,  resume,  move,  stop,  split_window,  ,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  TimedSegmentKindEnum get kind;
  // enum kindEnum {  play,  pause,  };

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'resource_name')
  String get resourceName;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  @BuiltValueField(wireName: r'rate_plan_id')
  String? get ratePlanId;

  @BuiltValueField(wireName: r'rate_plan_name')
  String? get ratePlanName;

  @BuiltValueField(wireName: r'rate_plan_version')
  int? get ratePlanVersion;

  /// Its times were corrected by hand.
  @BuiltValueField(wireName: r'edited')
  bool get edited;

  TimedSegment._();

  factory TimedSegment([void updates(TimedSegmentBuilder b)]) = _$TimedSegment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSegmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSegment> get serializer => _$TimedSegmentSerializer();
}

class _$TimedSegmentSerializer implements PrimitiveSerializer<TimedSegment> {
  @override
  final Iterable<Type> types = const [TimedSegment, _$TimedSegment];

  @override
  final String wireName = r'TimedSegment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSegment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ended_reason';
    yield object.endedReason == null
        ? null
        : serializers.serialize(
            object.endedReason,
            specifiedType: const FullType.nullable(TimedSegmentEndedReasonEnum),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(TimedSegmentKindEnum),
    );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'resource_name';
    yield serializers.serialize(
      object.resourceName,
      specifiedType: const FullType(String),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ended_at';
    yield object.endedAt == null
        ? null
        : serializers.serialize(
            object.endedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'rate_plan_id';
    yield object.ratePlanId == null
        ? null
        : serializers.serialize(
            object.ratePlanId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'rate_plan_name';
    yield object.ratePlanName == null
        ? null
        : serializers.serialize(
            object.ratePlanName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'rate_plan_version';
    yield object.ratePlanVersion == null
        ? null
        : serializers.serialize(
            object.ratePlanVersion,
            specifiedType: const FullType.nullable(int),
          );
    yield r'edited';
    yield serializers.serialize(
      object.edited,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSegment object, {
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
    required TimedSegmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ended_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TimedSegmentEndedReasonEnum),
          ) as TimedSegmentEndedReasonEnum?;
          if (valueDes == null) continue;
          result.endedReason = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimedSegmentKindEnum),
          ) as TimedSegmentKindEnum;
          result.kind = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'resource_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceName = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
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
        case r'rate_plan_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ratePlanId = valueDes;
          break;
        case r'rate_plan_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ratePlanName = valueDes;
          break;
        case r'rate_plan_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.ratePlanVersion = valueDes;
          break;
        case r'edited':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.edited = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedSegment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSegmentBuilder();
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

/// Why the stretch ended; null while it runs and for older stretches.
class TimedSegmentEndedReasonEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pause')
  static const TimedSegmentEndedReasonEnum pause =
      _$timedSegmentEndedReasonEnum_pause;
  @BuiltValueEnumConst(wireName: r'resume')
  static const TimedSegmentEndedReasonEnum resume =
      _$timedSegmentEndedReasonEnum_resume;
  @BuiltValueEnumConst(wireName: r'move')
  static const TimedSegmentEndedReasonEnum move =
      _$timedSegmentEndedReasonEnum_move;
  @BuiltValueEnumConst(wireName: r'stop')
  static const TimedSegmentEndedReasonEnum stop =
      _$timedSegmentEndedReasonEnum_stop;
  @BuiltValueEnumConst(wireName: r'split_window')
  static const TimedSegmentEndedReasonEnum splitWindow =
      _$timedSegmentEndedReasonEnum_splitWindow;

  static Serializer<TimedSegmentEndedReasonEnum> get serializer =>
      _$timedSegmentEndedReasonEnumSerializer;

  const TimedSegmentEndedReasonEnum._(String name) : super(name);

  static BuiltSet<TimedSegmentEndedReasonEnum> get values =>
      _$timedSegmentEndedReasonEnumValues;
  static TimedSegmentEndedReasonEnum valueOf(String name) =>
      _$timedSegmentEndedReasonEnumValueOf(name);
}

class TimedSegmentKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'play')
  static const TimedSegmentKindEnum play = _$timedSegmentKindEnum_play;
  @BuiltValueEnumConst(wireName: r'pause')
  static const TimedSegmentKindEnum pause = _$timedSegmentKindEnum_pause;

  static Serializer<TimedSegmentKindEnum> get serializer =>
      _$timedSegmentKindEnumSerializer;

  const TimedSegmentKindEnum._(String name) : super(name);

  static BuiltSet<TimedSegmentKindEnum> get values =>
      _$timedSegmentKindEnumValues;
  static TimedSegmentKindEnum valueOf(String name) =>
      _$timedSegmentKindEnumValueOf(name);
}
