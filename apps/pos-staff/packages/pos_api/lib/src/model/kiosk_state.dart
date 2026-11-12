//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_state_payments.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kiosk_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_state.g.dart';

/// KioskState
///
/// Properties:
/// * [open]
/// * [reason] - Why the kiosk is paused; null while it is open.
/// * [branch]
/// * [register]
/// * [currency]
/// * [idleSeconds] - Seconds without a touch before the kiosk asks whether the guest is still there.
/// * [qrTimeoutSeconds] - Seconds a bank QR stays open before the order goes to the counter.
/// * [kitchenBeforePayment]
/// * [payments]
@BuiltValue()
abstract class KioskState implements Built<KioskState, KioskStateBuilder> {
  @BuiltValueField(wireName: r'open')
  bool get open;

  /// Why the kiosk is paused; null while it is open.
  @BuiltValueField(wireName: r'reason')
  KioskStateReasonEnum? get reason;
  // enum reasonEnum {  kiosk_unprovisioned,  module_disabled,  register_disabled,  shift_closed,  ,  };

  @BuiltValueField(wireName: r'branch')
  KioskRef get branch;

  @BuiltValueField(wireName: r'register')
  KioskRef? get register;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  /// Seconds without a touch before the kiosk asks whether the guest is still there.
  @BuiltValueField(wireName: r'idle_seconds')
  int get idleSeconds;

  /// Seconds a bank QR stays open before the order goes to the counter.
  @BuiltValueField(wireName: r'qr_timeout_seconds')
  int get qrTimeoutSeconds;

  @BuiltValueField(wireName: r'kitchen_before_payment')
  bool get kitchenBeforePayment;

  @BuiltValueField(wireName: r'payments')
  KioskStatePayments get payments;

  KioskState._();

  factory KioskState([void updates(KioskStateBuilder b)]) = _$KioskState;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskStateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskState> get serializer => _$KioskStateSerializer();
}

class _$KioskStateSerializer implements PrimitiveSerializer<KioskState> {
  @override
  final Iterable<Type> types = const [KioskState, _$KioskState];

  @override
  final String wireName = r'KioskState';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskState object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'open';
    yield serializers.serialize(
      object.open,
      specifiedType: const FullType(bool),
    );
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType: const FullType.nullable(KioskStateReasonEnum),
          );
    yield r'branch';
    yield serializers.serialize(
      object.branch,
      specifiedType: const FullType(KioskRef),
    );
    yield r'register';
    yield object.register == null
        ? null
        : serializers.serialize(
            object.register,
            specifiedType: const FullType.nullable(KioskRef),
          );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'idle_seconds';
    yield serializers.serialize(
      object.idleSeconds,
      specifiedType: const FullType(int),
    );
    yield r'qr_timeout_seconds';
    yield serializers.serialize(
      object.qrTimeoutSeconds,
      specifiedType: const FullType(int),
    );
    yield r'kitchen_before_payment';
    yield serializers.serialize(
      object.kitchenBeforePayment,
      specifiedType: const FullType(bool),
    );
    yield r'payments';
    yield serializers.serialize(
      object.payments,
      specifiedType: const FullType(KioskStatePayments),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskState object, {
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
    required KioskStateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.open = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskStateReasonEnum),
          ) as KioskStateReasonEnum?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'branch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskRef),
          ) as KioskRef;
          result.branch.replace(valueDes);
          break;
        case r'register':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskRef),
          ) as KioskRef?;
          if (valueDes == null) continue;
          result.register.replace(valueDes);
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'idle_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.idleSeconds = valueDes;
          break;
        case r'qr_timeout_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.qrTimeoutSeconds = valueDes;
          break;
        case r'kitchen_before_payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.kitchenBeforePayment = valueDes;
          break;
        case r'payments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskStatePayments),
          ) as KioskStatePayments;
          result.payments.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskState deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskStateBuilder();
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

/// Why the kiosk is paused; null while it is open.
class KioskStateReasonEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'kiosk_unprovisioned')
  static const KioskStateReasonEnum kioskUnprovisioned =
      _$kioskStateReasonEnum_kioskUnprovisioned;
  @BuiltValueEnumConst(wireName: r'module_disabled')
  static const KioskStateReasonEnum moduleDisabled =
      _$kioskStateReasonEnum_moduleDisabled;
  @BuiltValueEnumConst(wireName: r'register_disabled')
  static const KioskStateReasonEnum registerDisabled =
      _$kioskStateReasonEnum_registerDisabled;
  @BuiltValueEnumConst(wireName: r'shift_closed')
  static const KioskStateReasonEnum shiftClosed =
      _$kioskStateReasonEnum_shiftClosed;

  static Serializer<KioskStateReasonEnum> get serializer =>
      _$kioskStateReasonEnumSerializer;

  const KioskStateReasonEnum._(String name) : super(name);

  static BuiltSet<KioskStateReasonEnum> get values =>
      _$kioskStateReasonEnumValues;
  static KioskStateReasonEnum valueOf(String name) =>
      _$kioskStateReasonEnumValueOf(name);
}
