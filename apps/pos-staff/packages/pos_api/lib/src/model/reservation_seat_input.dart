//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_seat_input.g.dart';

/// ReservationSeatInput
///
/// Properties:
/// * [editorId]
/// * [guestCount] - The party size by default.
@BuiltValue()
abstract class ReservationSeatInput
    implements Built<ReservationSeatInput, ReservationSeatInputBuilder> {
  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  /// The party size by default.
  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  ReservationSeatInput._();

  factory ReservationSeatInput([void updates(ReservationSeatInputBuilder b)]) =
      _$ReservationSeatInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationSeatInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationSeatInput> get serializer =>
      _$ReservationSeatInputSerializer();
}

class _$ReservationSeatInputSerializer
    implements PrimitiveSerializer<ReservationSeatInput> {
  @override
  final Iterable<Type> types = const [
    ReservationSeatInput,
    _$ReservationSeatInput
  ];

  @override
  final String wireName = r'ReservationSeatInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationSeatInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationSeatInput object, {
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
    required ReservationSeatInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationSeatInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationSeatInputBuilder();
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
