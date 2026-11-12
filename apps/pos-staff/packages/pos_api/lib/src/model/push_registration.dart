//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_registration.g.dart';

/// PushRegistration
///
/// Properties:
/// * [id]
/// * [deviceId]
/// * [platform]
/// * [enabled]
/// * [lastError]
/// * [lastErrorAt]
/// * [lastDeliveredAt]
@BuiltValue()
abstract class PushRegistration
    implements Built<PushRegistration, PushRegistrationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  @BuiltValueField(wireName: r'platform')
  PushRegistrationPlatformEnum get platform;
  // enum platformEnum {  fcm,  apns,  };

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'last_error')
  String? get lastError;

  @BuiltValueField(wireName: r'last_error_at')
  DateTime? get lastErrorAt;

  @BuiltValueField(wireName: r'last_delivered_at')
  DateTime? get lastDeliveredAt;

  PushRegistration._();

  factory PushRegistration([void updates(PushRegistrationBuilder b)]) =
      _$PushRegistration;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRegistrationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRegistration> get serializer =>
      _$PushRegistrationSerializer();
}

class _$PushRegistrationSerializer
    implements PrimitiveSerializer<PushRegistration> {
  @override
  final Iterable<Type> types = const [PushRegistration, _$PushRegistration];

  @override
  final String wireName = r'PushRegistration';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRegistration object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PushRegistrationPlatformEnum),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRegistration object, {
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
    required PushRegistrationBuilder result,
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
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PushRegistrationPlatformEnum),
          ) as PushRegistrationPlatformEnum;
          result.platform = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRegistration deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRegistrationBuilder();
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

class PushRegistrationPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fcm')
  static const PushRegistrationPlatformEnum fcm =
      _$pushRegistrationPlatformEnum_fcm;
  @BuiltValueEnumConst(wireName: r'apns')
  static const PushRegistrationPlatformEnum apns =
      _$pushRegistrationPlatformEnum_apns;

  static Serializer<PushRegistrationPlatformEnum> get serializer =>
      _$pushRegistrationPlatformEnumSerializer;

  const PushRegistrationPlatformEnum._(String name) : super(name);

  static BuiltSet<PushRegistrationPlatformEnum> get values =>
      _$pushRegistrationPlatformEnumValues;
  static PushRegistrationPlatformEnum valueOf(String name) =>
      _$pushRegistrationPlatformEnumValueOf(name);
}
