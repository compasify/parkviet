//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_deposit_resolve_input.g.dart';

/// ReservationDepositResolveInput
///
/// Properties:
/// * [approvalId]
/// * [reason]
@BuiltValue()
abstract class ReservationDepositResolveInput
    implements
        Built<ReservationDepositResolveInput,
            ReservationDepositResolveInputBuilder> {
  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  ReservationDepositResolveInput._();

  factory ReservationDepositResolveInput(
          [void updates(ReservationDepositResolveInputBuilder b)]) =
      _$ReservationDepositResolveInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDepositResolveInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDepositResolveInput> get serializer =>
      _$ReservationDepositResolveInputSerializer();
}

class _$ReservationDepositResolveInputSerializer
    implements PrimitiveSerializer<ReservationDepositResolveInput> {
  @override
  final Iterable<Type> types = const [
    ReservationDepositResolveInput,
    _$ReservationDepositResolveInput
  ];

  @override
  final String wireName = r'ReservationDepositResolveInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDepositResolveInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType(String),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDepositResolveInput object, {
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
    required ReservationDepositResolveInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDepositResolveInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDepositResolveInputBuilder();
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
