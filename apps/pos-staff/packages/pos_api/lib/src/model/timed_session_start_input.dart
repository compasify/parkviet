//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_session_start_input.g.dart';

/// TimedSessionStartInput
///
/// Properties:
/// * [branchId]
/// * [editorId] - Holds the lease of the order opened for a room that has none.
/// * [workspaceId] - The order to bill when the room has several open orders.
/// * [guestCount]
/// * [plannedEndAt] - When the guests plan to leave; the room shows `ending_soon` ten minutes before.
/// * [packageCode] - A prepaid package of the room's rate plan (`RatePlan.packages`); the clock is billed at least its minutes at its price and ends when they are played.
/// * [cardToken] - What a minutes card's QR code or tag reads; the card pays the time when the clock stops.
@BuiltValue()
abstract class TimedSessionStartInput
    implements Built<TimedSessionStartInput, TimedSessionStartInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  /// Holds the lease of the order opened for a room that has none.
  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  /// The order to bill when the room has several open orders.
  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  /// When the guests plan to leave; the room shows `ending_soon` ten minutes before.
  @BuiltValueField(wireName: r'planned_end_at')
  DateTime? get plannedEndAt;

  /// A prepaid package of the room's rate plan (`RatePlan.packages`); the clock is billed at least its minutes at its price and ends when they are played.
  @BuiltValueField(wireName: r'package_code')
  String? get packageCode;

  /// What a minutes card's QR code or tag reads; the card pays the time when the clock stops.
  @BuiltValueField(wireName: r'card_token')
  String? get cardToken;

  TimedSessionStartInput._();

  factory TimedSessionStartInput(
          [void updates(TimedSessionStartInputBuilder b)]) =
      _$TimedSessionStartInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedSessionStartInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedSessionStartInput> get serializer =>
      _$TimedSessionStartInputSerializer();
}

class _$TimedSessionStartInputSerializer
    implements PrimitiveSerializer<TimedSessionStartInput> {
  @override
  final Iterable<Type> types = const [
    TimedSessionStartInput,
    _$TimedSessionStartInput
  ];

  @override
  final String wireName = r'TimedSessionStartInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedSessionStartInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.workspaceId != null) {
      yield r'workspace_id';
      yield serializers.serialize(
        object.workspaceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.plannedEndAt != null) {
      yield r'planned_end_at';
      yield serializers.serialize(
        object.plannedEndAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.packageCode != null) {
      yield r'package_code';
      yield serializers.serialize(
        object.packageCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.cardToken != null) {
      yield r'card_token';
      yield serializers.serialize(
        object.cardToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedSessionStartInput object, {
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
    required TimedSessionStartInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'planned_end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.plannedEndAt = valueDes;
          break;
        case r'package_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.packageCode = valueDes;
          break;
        case r'card_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cardToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedSessionStartInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedSessionStartInputBuilder();
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
