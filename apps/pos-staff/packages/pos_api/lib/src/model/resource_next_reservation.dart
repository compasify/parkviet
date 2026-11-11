//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_next_reservation.g.dart';

/// ResourceNextReservation
///
/// Properties:
/// * [id]
/// * [startsAt]
/// * [guestName]
/// * [partySize]
@BuiltValue()
abstract class ResourceNextReservation
    implements Built<ResourceNextReservation, ResourceNextReservationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'starts_at')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'guest_name')
  String get guestName;

  @BuiltValueField(wireName: r'party_size')
  int get partySize;

  ResourceNextReservation._();

  factory ResourceNextReservation(
          [void updates(ResourceNextReservationBuilder b)]) =
      _$ResourceNextReservation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceNextReservationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceNextReservation> get serializer =>
      _$ResourceNextReservationSerializer();
}

class _$ResourceNextReservationSerializer
    implements PrimitiveSerializer<ResourceNextReservation> {
  @override
  final Iterable<Type> types = const [
    ResourceNextReservation,
    _$ResourceNextReservation
  ];

  @override
  final String wireName = r'ResourceNextReservation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceNextReservation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'starts_at';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'guest_name';
    yield serializers.serialize(
      object.guestName,
      specifiedType: const FullType(String),
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
    ResourceNextReservation object, {
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
    required ResourceNextReservationBuilder result,
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
        case r'starts_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.guestName = valueDes;
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
  ResourceNextReservation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceNextReservationBuilder();
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
