//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_minutes_card.g.dart';

/// The minutes card that pays the clock's time when it stops.
///
/// Properties:
/// * [id]
/// * [cardHint] - The last characters of the card's code.
@BuiltValue()
abstract class TimedMinutesCard
    implements Built<TimedMinutesCard, TimedMinutesCardBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// The last characters of the card's code.
  @BuiltValueField(wireName: r'card_hint')
  String? get cardHint;

  TimedMinutesCard._();

  factory TimedMinutesCard([void updates(TimedMinutesCardBuilder b)]) =
      _$TimedMinutesCard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedMinutesCardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedMinutesCard> get serializer =>
      _$TimedMinutesCardSerializer();
}

class _$TimedMinutesCardSerializer
    implements PrimitiveSerializer<TimedMinutesCard> {
  @override
  final Iterable<Type> types = const [TimedMinutesCard, _$TimedMinutesCard];

  @override
  final String wireName = r'TimedMinutesCard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedMinutesCard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'card_hint';
    yield object.cardHint == null
        ? null
        : serializers.serialize(
            object.cardHint,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedMinutesCard object, {
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
    required TimedMinutesCardBuilder result,
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
        case r'card_hint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cardHint = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedMinutesCard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedMinutesCardBuilder();
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
