//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_relay_settings.g.dart';

/// PushRelaySettings
///
/// Properties:
/// * [url]
/// * [keySet]
/// * [lastError]
/// * [lastErrorAt]
/// * [lastDeliveredAt]
/// * [updatedAt]
@BuiltValue()
abstract class PushRelaySettings
    implements Built<PushRelaySettings, PushRelaySettingsBuilder> {
  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'key_set')
  bool get keySet;

  @BuiltValueField(wireName: r'last_error')
  String? get lastError;

  @BuiltValueField(wireName: r'last_error_at')
  DateTime? get lastErrorAt;

  @BuiltValueField(wireName: r'last_delivered_at')
  DateTime? get lastDeliveredAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  PushRelaySettings._();

  factory PushRelaySettings([void updates(PushRelaySettingsBuilder b)]) =
      _$PushRelaySettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRelaySettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRelaySettings> get serializer =>
      _$PushRelaySettingsSerializer();
}

class _$PushRelaySettingsSerializer
    implements PrimitiveSerializer<PushRelaySettings> {
  @override
  final Iterable<Type> types = const [PushRelaySettings, _$PushRelaySettings];

  @override
  final String wireName = r'PushRelaySettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRelaySettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'key_set';
    yield serializers.serialize(
      object.keySet,
      specifiedType: const FullType(bool),
    );
    yield r'last_error';
    yield object.lastError == null
        ? null
        : serializers.serialize(
            object.lastError,
            specifiedType: const FullType.nullable(String),
          );
    yield r'last_error_at';
    yield object.lastErrorAt == null
        ? null
        : serializers.serialize(
            object.lastErrorAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'last_delivered_at';
    yield object.lastDeliveredAt == null
        ? null
        : serializers.serialize(
            object.lastDeliveredAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'updated_at';
    yield object.updatedAt == null
        ? null
        : serializers.serialize(
            object.updatedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRelaySettings object, {
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
    required PushRelaySettingsBuilder result,
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
        case r'key_set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.keySet = valueDes;
          break;
        case r'last_error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastError = valueDes;
          break;
        case r'last_error_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastErrorAt = valueDes;
          break;
        case r'last_delivered_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastDeliveredAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRelaySettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRelaySettingsBuilder();
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
