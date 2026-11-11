//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/reservation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_seat.g.dart';

/// ReservationSeat
///
/// Properties:
/// * [reservation]
/// * [workspace]
@BuiltValue()
abstract class ReservationSeat
    implements Built<ReservationSeat, ReservationSeatBuilder> {
  @BuiltValueField(wireName: r'reservation')
  Reservation get reservation;

  @BuiltValueField(wireName: r'workspace')
  Workspace get workspace;

  ReservationSeat._();

  factory ReservationSeat([void updates(ReservationSeatBuilder b)]) =
      _$ReservationSeat;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationSeatBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationSeat> get serializer =>
      _$ReservationSeatSerializer();
}

class _$ReservationSeatSerializer
    implements PrimitiveSerializer<ReservationSeat> {
  @override
  final Iterable<Type> types = const [ReservationSeat, _$ReservationSeat];

  @override
  final String wireName = r'ReservationSeat';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationSeat object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservation';
    yield serializers.serialize(
      object.reservation,
      specifiedType: const FullType(Reservation),
    );
    yield r'workspace';
    yield serializers.serialize(
      object.workspace,
      specifiedType: const FullType(Workspace),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationSeat object, {
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
    required ReservationSeatBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Reservation),
          ) as Reservation;
          result.reservation.replace(valueDes);
          break;
        case r'workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.workspace.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationSeat deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationSeatBuilder();
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
