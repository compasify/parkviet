//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/timed_quote.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/timed_segment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session.g.dart';

/// The clock of a room's play time, with its stretches and quote. Every time is the server's.
///
/// Properties:
/// * [id]
/// * [status]
/// * [resourceId]
/// * [resourceName]
/// * [startedAt]
/// * [stoppedAt]
/// * [plannedEndAt]
/// * [playedMinutes]
/// * [billedMinutes]
/// * [amount] - The billed amount once stopped.
/// * [currency]
/// * [quoteVersion]
/// * [segments]
/// * [quote]
@BuiltValue()
abstract class TimedSession
    implements Built<TimedSession, TimedSessionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  TimedSessionStatusEnum get status;
  // enum statusEnum {  running,  paused,  stopped,  };

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'resource_name')
  String get resourceName;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'stopped_at')
  DateTime? get stoppedAt;

  @BuiltValueField(wireName: r'planned_end_at')
  DateTime? get plannedEndAt;

  @BuiltValueField(wireName: r'played_minutes')
  int get playedMinutes;

  @BuiltValueField(wireName: r'billed_minutes')
  int get billedMinutes;

  /// The billed amount once stopped.
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'quote_version')
  int get quoteVersion;

  @BuiltValueField(wireName: r'segments')
  BuiltList<TimedSegment> get segments;

  @BuiltValueField(wireName: r'quote')
  TimedQuote? get quote;

  TimedSession._();

  factory TimedSession([void updates(TimedSessionBuilder b)]) = _$TimedSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSession> get serializer => _$TimedSessionSerializer();
}

class _$TimedSessionSerializer implements PrimitiveSerializer<TimedSession> {
  @override
  final Iterable<Type> types = const [TimedSession, _$TimedSession];

  @override
  final String wireName = r'TimedSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TimedSessionStatusEnum),
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
    yield r'stopped_at';
    yield object.stoppedAt == null
        ? null
        : serializers.serialize(
            object.stoppedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'planned_end_at';
    yield object.plannedEndAt == null
        ? null
        : serializers.serialize(
            object.plannedEndAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'played_minutes';
    yield serializers.serialize(
      object.playedMinutes,
      specifiedType: const FullType(int),
    );
    yield r'billed_minutes';
    yield serializers.serialize(
      object.billedMinutes,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'quote_version';
    yield serializers.serialize(
      object.quoteVersion,
      specifiedType: const FullType(int),
    );
    yield r'segments';
    yield serializers.serialize(
      object.segments,
      specifiedType: const FullType(BuiltList, [FullType(TimedSegment)]),
    );
    yield r'quote';
    yield object.quote == null
        ? null
        : serializers.serialize(
            object.quote,
            specifiedType: const FullType.nullable(TimedQuote),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSession object, {
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
    required TimedSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimedSessionStatusEnum),
          ) as TimedSessionStatusEnum;
          result.status = valueDes;
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
        case r'stopped_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.stoppedAt = valueDes;
          break;
        case r'planned_end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.plannedEndAt = valueDes;
          break;
        case r'played_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.playedMinutes = valueDes;
          break;
        case r'billed_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.billedMinutes = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'quote_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quoteVersion = valueDes;
          break;
        case r'segments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TimedSegment)]),
          ) as BuiltList<TimedSegment>;
          result.segments.replace(valueDes);
          break;
        case r'quote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TimedQuote),
          ) as TimedQuote?;
          if (valueDes == null) continue;
          result.quote.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionBuilder();
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

class TimedSessionStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'running')
  static const TimedSessionStatusEnum running =
      _$timedSessionStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'paused')
  static const TimedSessionStatusEnum paused = _$timedSessionStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'stopped')
  static const TimedSessionStatusEnum stopped =
      _$timedSessionStatusEnum_stopped;

  static Serializer<TimedSessionStatusEnum> get serializer =>
      _$timedSessionStatusEnumSerializer;

  const TimedSessionStatusEnum._(String name) : super(name);

  static BuiltSet<TimedSessionStatusEnum> get values =>
      _$timedSessionStatusEnumValues;
  static TimedSessionStatusEnum valueOf(String name) =>
      _$timedSessionStatusEnumValueOf(name);
}
