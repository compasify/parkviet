//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/reservation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_result.g.dart';

/// ReservationResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ReservationResult
    implements Built<ReservationResult, ReservationResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Reservation get data;

  ReservationResult._();

  factory ReservationResult([void updates(ReservationResultBuilder b)]) =
      _$ReservationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationResult> get serializer =>
      _$ReservationResultSerializer();
}

class _$ReservationResultSerializer
    implements PrimitiveSerializer<ReservationResult> {
  @override
  final Iterable<Type> types = const [ReservationResult, _$ReservationResult];

  @override
  final String wireName = r'ReservationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Reservation),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationResult object, {
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
    required ReservationResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Reservation),
          ) as Reservation;
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
  ReservationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationResultBuilder();
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
