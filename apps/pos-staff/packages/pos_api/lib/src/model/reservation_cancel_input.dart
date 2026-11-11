//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_cancel_input.g.dart';

/// ReservationCancelInput
///
/// Properties:
/// * [status]
@BuiltValue()
abstract class ReservationCancelInput
    implements Built<ReservationCancelInput, ReservationCancelInputBuilder> {
  @BuiltValueField(wireName: r'status')
  ReservationCancelInputStatusEnum? get status;
  // enum statusEnum {  canceled,  no_show,  };

  ReservationCancelInput._();

  factory ReservationCancelInput(
          [void updates(ReservationCancelInputBuilder b)]) =
      _$ReservationCancelInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationCancelInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationCancelInput> get serializer =>
      _$ReservationCancelInputSerializer();
}

class _$ReservationCancelInputSerializer
    implements PrimitiveSerializer<ReservationCancelInput> {
  @override
  final Iterable<Type> types = const [
    ReservationCancelInput,
    _$ReservationCancelInput
  ];

  @override
  final String wireName = r'ReservationCancelInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationCancelInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ReservationCancelInputStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationCancelInput object, {
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
    required ReservationCancelInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(ReservationCancelInputStatusEnum),
          ) as ReservationCancelInputStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationCancelInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationCancelInputBuilder();
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

class ReservationCancelInputStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'canceled')
  static const ReservationCancelInputStatusEnum canceled =
      _$reservationCancelInputStatusEnum_canceled;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const ReservationCancelInputStatusEnum noShow =
      _$reservationCancelInputStatusEnum_noShow;

  static Serializer<ReservationCancelInputStatusEnum> get serializer =>
      _$reservationCancelInputStatusEnumSerializer;

  const ReservationCancelInputStatusEnum._(String name) : super(name);

  static BuiltSet<ReservationCancelInputStatusEnum> get values =>
      _$reservationCancelInputStatusEnumValues;
  static ReservationCancelInputStatusEnum valueOf(String name) =>
      _$reservationCancelInputStatusEnumValueOf(name);
}
