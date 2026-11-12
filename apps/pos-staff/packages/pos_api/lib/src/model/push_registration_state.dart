//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/push_registration.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_registration_state.g.dart';

/// PushRegistrationState
///
/// Properties:
/// * [registration]
/// * [relay] - The store has a push relay.
@BuiltValue()
abstract class PushRegistrationState
    implements Built<PushRegistrationState, PushRegistrationStateBuilder> {
  @BuiltValueField(wireName: r'registration')
  PushRegistration? get registration;

  /// The store has a push relay.
  @BuiltValueField(wireName: r'relay')
  bool get relay;

  PushRegistrationState._();

  factory PushRegistrationState(
      [void updates(PushRegistrationStateBuilder b)]) = _$PushRegistrationState;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRegistrationStateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRegistrationState> get serializer =>
      _$PushRegistrationStateSerializer();
}

class _$PushRegistrationStateSerializer
    implements PrimitiveSerializer<PushRegistrationState> {
  @override
  final Iterable<Type> types = const [
    PushRegistrationState,
    _$PushRegistrationState
  ];

  @override
  final String wireName = r'PushRegistrationState';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRegistrationState object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'registration';
    yield object.registration == null
        ? null
        : serializers.serialize(
            object.registration,
            specifiedType: const FullType.nullable(PushRegistration),
          );
    yield r'relay';
    yield serializers.serialize(
      object.relay,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRegistrationState object, {
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
    required PushRegistrationStateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PushRegistration),
          ) as PushRegistration?;
          if (valueDes == null) continue;
          result.registration.replace(valueDes);
          break;
        case r'relay':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.relay = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRegistrationState deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRegistrationStateBuilder();
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
