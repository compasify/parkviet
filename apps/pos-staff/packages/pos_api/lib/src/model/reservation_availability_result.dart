//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/available_resource.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/reservation_availability_result_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_availability_result.g.dart';

/// ReservationAvailabilityResult
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class ReservationAvailabilityResult
    implements
        Built<ReservationAvailabilityResult,
            ReservationAvailabilityResultBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AvailableResource> get data;

  @BuiltValueField(wireName: r'meta')
  ReservationAvailabilityResultMeta get meta;

  ReservationAvailabilityResult._();

  factory ReservationAvailabilityResult(
          [void updates(ReservationAvailabilityResultBuilder b)]) =
      _$ReservationAvailabilityResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationAvailabilityResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationAvailabilityResult> get serializer =>
      _$ReservationAvailabilityResultSerializer();
}

class _$ReservationAvailabilityResultSerializer
    implements PrimitiveSerializer<ReservationAvailabilityResult> {
  @override
  final Iterable<Type> types = const [
    ReservationAvailabilityResult,
    _$ReservationAvailabilityResult
  ];

  @override
  final String wireName = r'ReservationAvailabilityResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationAvailabilityResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(AvailableResource)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ReservationAvailabilityResultMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationAvailabilityResult object, {
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
    required ReservationAvailabilityResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(AvailableResource)]),
          ) as BuiltList<AvailableResource>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationAvailabilityResultMeta),
          ) as ReservationAvailabilityResultMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationAvailabilityResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationAvailabilityResultBuilder();
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
