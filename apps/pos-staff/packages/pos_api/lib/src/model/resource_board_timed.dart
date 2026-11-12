//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_board_timed.g.dart';

/// ResourceBoardTimed
///
/// Properties:
/// * [pausedAt] - Server time the clock was paused; null unless paused.
/// * [prepaidMinutes] - The minutes of the package the clock was sold with.
/// * [playedSeconds] - Seconds played up to `server_now`, pauses not counted; null once stopped.
/// * [packageEnded] - A package clock still runs past its prepaid minutes.
/// * [pauseTooLong] - Paused longer than the branch's `max_pause_minutes`; resuming needs `pos.timed.edit` or an approval.
/// * [id]
/// * [workspaceId]
/// * [status]
/// * [startedAt] - Server time the clock started; show elapsed time from it with the server clock offset.
/// * [stoppedAt]
/// * [plannedEndAt]
/// * [playedMinutes]
/// * [quoteAmount] - The price of the time so far on the server clock; final once stopped.
/// * [endingSoon]
@BuiltValue()
abstract class ResourceBoardTimed
    implements Built<ResourceBoardTimed, ResourceBoardTimedBuilder> {
  /// Server time the clock was paused; null unless paused.
  @BuiltValueField(wireName: r'paused_at')
  DateTime? get pausedAt;

  /// The minutes of the package the clock was sold with.
  @BuiltValueField(wireName: r'prepaid_minutes')
  int? get prepaidMinutes;

  /// Seconds played up to `server_now`, pauses not counted; null once stopped.
  @BuiltValueField(wireName: r'played_seconds')
  int? get playedSeconds;

  /// A package clock still runs past its prepaid minutes.
  @BuiltValueField(wireName: r'package_ended')
  bool get packageEnded;

  /// Paused longer than the branch's `max_pause_minutes`; resuming needs `pos.timed.edit` or an approval.
  @BuiltValueField(wireName: r'pause_too_long')
  bool get pauseTooLong;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'status')
  ResourceBoardTimedStatusEnum get status;
  // enum statusEnum {  running,  paused,  stopped,  };

  /// Server time the clock started; show elapsed time from it with the server clock offset.
  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'stopped_at')
  DateTime? get stoppedAt;

  @BuiltValueField(wireName: r'planned_end_at')
  DateTime? get plannedEndAt;

  @BuiltValueField(wireName: r'played_minutes')
  int get playedMinutes;

  /// The price of the time so far on the server clock; final once stopped.
  @BuiltValueField(wireName: r'quote_amount')
  String get quoteAmount;

  @BuiltValueField(wireName: r'ending_soon')
  bool get endingSoon;

  ResourceBoardTimed._();

  factory ResourceBoardTimed([void updates(ResourceBoardTimedBuilder b)]) =
      _$ResourceBoardTimed;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBoardTimedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceBoardTimed> get serializer =>
      _$ResourceBoardTimedSerializer();
}

class _$ResourceBoardTimedSerializer
    implements PrimitiveSerializer<ResourceBoardTimed> {
  @override
  final Iterable<Type> types = const [ResourceBoardTimed, _$ResourceBoardTimed];

  @override
  final String wireName = r'ResourceBoardTimed';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceBoardTimed object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'paused_at';
    yield object.pausedAt == null
        ? null
        : serializers.serialize(
            object.pausedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'prepaid_minutes';
    yield object.prepaidMinutes == null
        ? null
        : serializers.serialize(
            object.prepaidMinutes,
            specifiedType: const FullType.nullable(int),
          );
    yield r'played_seconds';
    yield object.playedSeconds == null
        ? null
        : serializers.serialize(
            object.playedSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'package_ended';
    yield serializers.serialize(
      object.packageEnded,
      specifiedType: const FullType(bool),
    );
    yield r'pause_too_long';
    yield serializers.serialize(
      object.pauseTooLong,
      specifiedType: const FullType(bool),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'workspace_id';
    yield object.workspaceId == null
        ? null
        : serializers.serialize(
            object.workspaceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ResourceBoardTimedStatusEnum),
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
    yield r'quote_amount';
    yield serializers.serialize(
      object.quoteAmount,
      specifiedType: const FullType(String),
    );
    yield r'ending_soon';
    yield serializers.serialize(
      object.endingSoon,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceBoardTimed object, {
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
    required ResourceBoardTimedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'paused_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.pausedAt = valueDes;
          break;
        case r'prepaid_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.prepaidMinutes = valueDes;
          break;
        case r'played_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.playedSeconds = valueDes;
          break;
        case r'package_ended':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.packageEnded = valueDes;
          break;
        case r'pause_too_long':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pauseTooLong = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceBoardTimedStatusEnum),
          ) as ResourceBoardTimedStatusEnum;
          result.status = valueDes;
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
        case r'quote_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quoteAmount = valueDes;
          break;
        case r'ending_soon':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.endingSoon = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceBoardTimed deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBoardTimedBuilder();
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

class ResourceBoardTimedStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'running')
  static const ResourceBoardTimedStatusEnum running =
      _$resourceBoardTimedStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'paused')
  static const ResourceBoardTimedStatusEnum paused =
      _$resourceBoardTimedStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'stopped')
  static const ResourceBoardTimedStatusEnum stopped =
      _$resourceBoardTimedStatusEnum_stopped;

  static Serializer<ResourceBoardTimedStatusEnum> get serializer =>
      _$resourceBoardTimedStatusEnumSerializer;

  const ResourceBoardTimedStatusEnum._(String name) : super(name);

  static BuiltSet<ResourceBoardTimedStatusEnum> get values =>
      _$resourceBoardTimedStatusEnumValues;
  static ResourceBoardTimedStatusEnum valueOf(String name) =>
      _$resourceBoardTimedStatusEnumValueOf(name);
}
