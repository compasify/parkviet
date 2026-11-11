//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_availability_result_meta.g.dart';

/// ReservationAvailabilityResultMeta
///
/// Properties:
/// * [startsAt]
/// * [endsAt]
/// * [partySize]
@BuiltValue()
abstract class ReservationAvailabilityResultMeta
    implements
        Built<ReservationAvailabilityResultMeta,
            ReservationAvailabilityResultMetaBuilder> {
  @BuiltValueField(wireName: r'starts_at')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'ends_at')
  DateTime get endsAt;

  @BuiltValueField(wireName: r'party_size')
  int get partySize;

  ReservationAvailabilityResultMeta._();

  factory ReservationAvailabilityResultMeta(
          [void updates(ReservationAvailabilityResultMetaBuilder b)]) =
      _$ReservationAvailabilityResultMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationAvailabilityResultMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationAvailabilityResultMeta> get serializer =>
      _$ReservationAvailabilityResultMetaSerializer();
}

class _$ReservationAvailabilityResultMetaSerializer
    implements PrimitiveSerializer<ReservationAvailabilityResultMeta> {
  @override
  final Iterable<Type> types = const [
    ReservationAvailabilityResultMeta,
    _$ReservationAvailabilityResultMeta
  ];

  @override
  final String wireName = r'ReservationAvailabilityResultMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationAvailabilityResultMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'starts_at';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ends_at';
    yield serializers.serialize(
      object.endsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'party_size';
    yield serializers.serialize(
      object.partySize,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationAvailabilityResultMeta object, {
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
    required ReservationAvailabilityResultMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'starts_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'ends_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        case r'party_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.partySize = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationAvailabilityResultMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationAvailabilityResultMetaBuilder();
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
