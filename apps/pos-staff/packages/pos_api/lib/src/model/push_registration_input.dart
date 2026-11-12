//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_registration_input.g.dart';

/// PushRegistrationInput
///
/// Properties:
/// * [platform]
/// * [token]
/// * [enabled]
@BuiltValue()
abstract class PushRegistrationInput
    implements Built<PushRegistrationInput, PushRegistrationInputBuilder> {
  @BuiltValueField(wireName: r'platform')
  PushRegistrationInputPlatformEnum? get platform;
  // enum platformEnum {  fcm,  apns,  };

  @BuiltValueField(wireName: r'token')
  String? get token;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  PushRegistrationInput._();

  factory PushRegistrationInput(
      [void updates(PushRegistrationInputBuilder b)]) = _$PushRegistrationInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRegistrationInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRegistrationInput> get serializer =>
      _$PushRegistrationInputSerializer();
}

class _$PushRegistrationInputSerializer
    implements PrimitiveSerializer<PushRegistrationInput> {
  @override
  final Iterable<Type> types = const [
    PushRegistrationInput,
    _$PushRegistrationInput
  ];

  @override
  final String wireName = r'PushRegistrationInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRegistrationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.platform != null) {
      yield r'platform';
      yield serializers.serialize(
        object.platform,
        specifiedType: const FullType(PushRegistrationInputPlatformEnum),
      );
    }
    if (object.token != null) {
      yield r'token';
      yield serializers.serialize(
        object.token,
        specifiedType: const FullType(String),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRegistrationInput object, {
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
    required PushRegistrationInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(PushRegistrationInputPlatformEnum),
          ) as PushRegistrationInputPlatformEnum?;
          if (valueDes == null) continue;
          result.platform = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.token = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRegistrationInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRegistrationInputBuilder();
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

class PushRegistrationInputPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fcm')
  static const PushRegistrationInputPlatformEnum fcm =
      _$pushRegistrationInputPlatformEnum_fcm;
  @BuiltValueEnumConst(wireName: r'apns')
  static const PushRegistrationInputPlatformEnum apns =
      _$pushRegistrationInputPlatformEnum_apns;

  static Serializer<PushRegistrationInputPlatformEnum> get serializer =>
      _$pushRegistrationInputPlatformEnumSerializer;

  const PushRegistrationInputPlatformEnum._(String name) : super(name);

  static BuiltSet<PushRegistrationInputPlatformEnum> get values =>
      _$pushRegistrationInputPlatformEnumValues;
  static PushRegistrationInputPlatformEnum valueOf(String name) =>
      _$pushRegistrationInputPlatformEnumValueOf(name);
}
