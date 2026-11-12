//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kiosk_register.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_settings.g.dart';

/// KioskSettings
///
/// Properties:
/// * [branchId]
/// * [kioskIdleSeconds]
/// * [kioskQrTimeoutSeconds]
/// * [kioskKitchenBeforePayment]
/// * [kiosks]
@BuiltValue()
abstract class KioskSettings
    implements Built<KioskSettings, KioskSettingsBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'kiosk_idle_seconds')
  int get kioskIdleSeconds;

  @BuiltValueField(wireName: r'kiosk_qr_timeout_seconds')
  int get kioskQrTimeoutSeconds;

  @BuiltValueField(wireName: r'kiosk_kitchen_before_payment')
  bool get kioskKitchenBeforePayment;

  @BuiltValueField(wireName: r'kiosks')
  BuiltList<KioskRegister> get kiosks;

  KioskSettings._();

  factory KioskSettings([void updates(KioskSettingsBuilder b)]) =
      _$KioskSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskSettings> get serializer =>
      _$KioskSettingsSerializer();
}

class _$KioskSettingsSerializer implements PrimitiveSerializer<KioskSettings> {
  @override
  final Iterable<Type> types = const [KioskSettings, _$KioskSettings];

  @override
  final String wireName = r'KioskSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'kiosk_idle_seconds';
    yield serializers.serialize(
      object.kioskIdleSeconds,
      specifiedType: const FullType(int),
    );
    yield r'kiosk_qr_timeout_seconds';
    yield serializers.serialize(
      object.kioskQrTimeoutSeconds,
      specifiedType: const FullType(int),
    );
    yield r'kiosk_kitchen_before_payment';
    yield serializers.serialize(
      object.kioskKitchenBeforePayment,
      specifiedType: const FullType(bool),
    );
    yield r'kiosks';
    yield serializers.serialize(
      object.kiosks,
      specifiedType: const FullType(BuiltList, [FullType(KioskRegister)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskSettings object, {
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
    required KioskSettingsBuilder result,
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
            specifiedType: const FullType(int),
          ) as int;
          result.kioskIdleSeconds = valueDes;
          break;
        case r'kiosk_qr_timeout_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.kioskQrTimeoutSeconds = valueDes;
          break;
        case r'kiosk_kitchen_before_payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.kioskKitchenBeforePayment = valueDes;
          break;
        case r'kiosks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KioskRegister)]),
          ) as BuiltList<KioskRegister>;
          result.kiosks.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskSettingsBuilder();
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
