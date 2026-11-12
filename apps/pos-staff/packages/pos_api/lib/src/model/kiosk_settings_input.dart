//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_settings_input.g.dart';

/// KioskSettingsInput
///
/// Properties:
/// * [branchId]
/// * [kioskIdleSeconds]
/// * [kioskQrTimeoutSeconds]
/// * [kioskKitchenBeforePayment]
@BuiltValue()
abstract class KioskSettingsInput
    implements Built<KioskSettingsInput, KioskSettingsInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'kiosk_idle_seconds')
  int? get kioskIdleSeconds;

  @BuiltValueField(wireName: r'kiosk_qr_timeout_seconds')
  int? get kioskQrTimeoutSeconds;

  @BuiltValueField(wireName: r'kiosk_kitchen_before_payment')
  bool? get kioskKitchenBeforePayment;

  KioskSettingsInput._();

  factory KioskSettingsInput([void updates(KioskSettingsInputBuilder b)]) =
      _$KioskSettingsInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskSettingsInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskSettingsInput> get serializer =>
      _$KioskSettingsInputSerializer();
}

class _$KioskSettingsInputSerializer
    implements PrimitiveSerializer<KioskSettingsInput> {
  @override
  final Iterable<Type> types = const [KioskSettingsInput, _$KioskSettingsInput];

  @override
  final String wireName = r'KioskSettingsInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskSettingsInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.kioskIdleSeconds != null) {
      yield r'kiosk_idle_seconds';
      yield serializers.serialize(
        object.kioskIdleSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.kioskQrTimeoutSeconds != null) {
      yield r'kiosk_qr_timeout_seconds';
      yield serializers.serialize(
        object.kioskQrTimeoutSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.kioskKitchenBeforePayment != null) {
      yield r'kiosk_kitchen_before_payment';
      yield serializers.serialize(
        object.kioskKitchenBeforePayment,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskSettingsInput object, {
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
    required KioskSettingsInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'kiosk_idle_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.kioskIdleSeconds = valueDes;
          break;
        case r'kiosk_qr_timeout_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.kioskQrTimeoutSeconds = valueDes;
          break;
        case r'kiosk_kitchen_before_payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.kioskKitchenBeforePayment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskSettingsInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskSettingsInputBuilder();
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
