//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/reservation_seat.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_seat_result.g.dart';

/// ReservationSeatResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ReservationSeatResult
    implements Built<ReservationSeatResult, ReservationSeatResultBuilder> {
  @BuiltValueField(wireName: r'data')
  ReservationSeat get data;

  ReservationSeatResult._();

  factory ReservationSeatResult(
      [void updates(ReservationSeatResultBuilder b)]) = _$ReservationSeatResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationSeatResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationSeatResult> get serializer =>
      _$ReservationSeatResultSerializer();
}

class _$ReservationSeatResultSerializer
    implements PrimitiveSerializer<ReservationSeatResult> {
  @override
  final Iterable<Type> types = const [
    ReservationSeatResult,
    _$ReservationSeatResult
  ];

  @override
  final String wireName = r'ReservationSeatResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationSeatResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ReservationSeat),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationSeatResult object, {
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
    required ReservationSeatResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationSeat),
          ) as ReservationSeat;
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
  ReservationSeatResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationSeatResultBuilder();
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
