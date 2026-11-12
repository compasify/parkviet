//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/push_relay_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_relay_settings_result.g.dart';

/// PushRelaySettingsResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PushRelaySettingsResult
    implements Built<PushRelaySettingsResult, PushRelaySettingsResultBuilder> {
  @BuiltValueField(wireName: r'data')
  PushRelaySettings? get data;

  PushRelaySettingsResult._();

  factory PushRelaySettingsResult(
          [void updates(PushRelaySettingsResultBuilder b)]) =
      _$PushRelaySettingsResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRelaySettingsResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRelaySettingsResult> get serializer =>
      _$PushRelaySettingsResultSerializer();
}

class _$PushRelaySettingsResultSerializer
    implements PrimitiveSerializer<PushRelaySettingsResult> {
  @override
  final Iterable<Type> types = const [
    PushRelaySettingsResult,
    _$PushRelaySettingsResult
  ];

  @override
  final String wireName = r'PushRelaySettingsResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRelaySettingsResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield object.data == null
        ? null
        : serializers.serialize(
            object.data,
            specifiedType: const FullType.nullable(PushRelaySettings),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRelaySettingsResult object, {
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
    required PushRelaySettingsResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PushRelaySettings),
          ) as PushRelaySettings?;
          if (valueDes == null) continue;
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
  PushRelaySettingsResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRelaySettingsResultBuilder();
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
