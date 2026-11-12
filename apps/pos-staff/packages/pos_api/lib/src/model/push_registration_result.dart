//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/push_registration_state.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_registration_result.g.dart';

/// PushRegistrationResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PushRegistrationResult
    implements Built<PushRegistrationResult, PushRegistrationResultBuilder> {
  @BuiltValueField(wireName: r'data')
  PushRegistrationState get data;

  PushRegistrationResult._();

  factory PushRegistrationResult(
          [void updates(PushRegistrationResultBuilder b)]) =
      _$PushRegistrationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRegistrationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRegistrationResult> get serializer =>
      _$PushRegistrationResultSerializer();
}

class _$PushRegistrationResultSerializer
    implements PrimitiveSerializer<PushRegistrationResult> {
  @override
  final Iterable<Type> types = const [
    PushRegistrationResult,
    _$PushRegistrationResult
  ];

  @override
  final String wireName = r'PushRegistrationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRegistrationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PushRegistrationState),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRegistrationResult object, {
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
    required PushRegistrationResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PushRegistrationState),
          ) as PushRegistrationState;
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
  PushRegistrationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRegistrationResultBuilder();
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
