//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_relay_settings_input.g.dart';

/// PushRelaySettingsInput
///
/// Properties:
/// * [url]
/// * [key]
@BuiltValue()
abstract class PushRelaySettingsInput
    implements Built<PushRelaySettingsInput, PushRelaySettingsInputBuilder> {
  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'key')
  String? get key;

  PushRelaySettingsInput._();

  factory PushRelaySettingsInput(
          [void updates(PushRelaySettingsInputBuilder b)]) =
      _$PushRelaySettingsInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRelaySettingsInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRelaySettingsInput> get serializer =>
      _$PushRelaySettingsInputSerializer();
}

class _$PushRelaySettingsInputSerializer
    implements PrimitiveSerializer<PushRelaySettingsInput> {
  @override
  final Iterable<Type> types = const [
    PushRelaySettingsInput,
    _$PushRelaySettingsInput
  ];

  @override
  final String wireName = r'PushRelaySettingsInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRelaySettingsInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    if (object.key != null) {
      yield r'key';
      yield serializers.serialize(
        object.key,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRelaySettingsInput object, {
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
    required PushRelaySettingsInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.key = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRelaySettingsInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRelaySettingsInputBuilder();
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
