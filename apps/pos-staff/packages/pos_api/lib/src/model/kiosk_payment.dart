//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_qr.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_payment.g.dart';

/// KioskPayment
///
/// Properties:
/// * [kind]
/// * [attemptId]
/// * [amount]
/// * [state]
/// * [expiresAt]
/// * [qr]
@BuiltValue()
abstract class KioskPayment
    implements Built<KioskPayment, KioskPaymentBuilder> {
  @BuiltValueField(wireName: r'kind')
  KioskPaymentKindEnum get kind;
  // enum kindEnum {  vietqr,  };

  @BuiltValueField(wireName: r'attempt_id')
  String get attemptId;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'state')
  KioskPaymentStateEnum get state;
  // enum stateEnum {  waiting,  received,  expired,  };

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'qr')
  KioskQr? get qr;

  KioskPayment._();

  factory KioskPayment([void updates(KioskPaymentBuilder b)]) = _$KioskPayment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskPaymentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskPayment> get serializer => _$KioskPaymentSerializer();
}

class _$KioskPaymentSerializer implements PrimitiveSerializer<KioskPayment> {
  @override
  final Iterable<Type> types = const [KioskPayment, _$KioskPayment];

  @override
  final String wireName = r'KioskPayment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskPayment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(KioskPaymentKindEnum),
    );
    yield r'attempt_id';
    yield serializers.serialize(
      object.attemptId,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(KioskPaymentStateEnum),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'qr';
    yield object.qr == null
        ? null
        : serializers.serialize(
            object.qr,
            specifiedType: const FullType.nullable(KioskQr),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskPayment object, {
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
    required KioskPaymentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskPaymentKindEnum),
          ) as KioskPaymentKindEnum;
          result.kind = valueDes;
          break;
        case r'attempt_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.attemptId = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskPaymentStateEnum),
          ) as KioskPaymentStateEnum;
          result.state = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'qr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskQr),
          ) as KioskQr?;
          if (valueDes == null) continue;
          result.qr.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskPayment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskPaymentBuilder();
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

class KioskPaymentKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'vietqr')
  static const KioskPaymentKindEnum vietqr = _$kioskPaymentKindEnum_vietqr;

  static Serializer<KioskPaymentKindEnum> get serializer =>
      _$kioskPaymentKindEnumSerializer;

  const KioskPaymentKindEnum._(String name) : super(name);

  static BuiltSet<KioskPaymentKindEnum> get values =>
      _$kioskPaymentKindEnumValues;
  static KioskPaymentKindEnum valueOf(String name) =>
      _$kioskPaymentKindEnumValueOf(name);
}

class KioskPaymentStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'waiting')
  static const KioskPaymentStateEnum waiting = _$kioskPaymentStateEnum_waiting;
  @BuiltValueEnumConst(wireName: r'received')
  static const KioskPaymentStateEnum received =
      _$kioskPaymentStateEnum_received;
  @BuiltValueEnumConst(wireName: r'expired')
  static const KioskPaymentStateEnum expired = _$kioskPaymentStateEnum_expired;

  static Serializer<KioskPaymentStateEnum> get serializer =>
      _$kioskPaymentStateEnumSerializer;

  const KioskPaymentStateEnum._(String name) : super(name);

  static BuiltSet<KioskPaymentStateEnum> get values =>
      _$kioskPaymentStateEnumValues;
  static KioskPaymentStateEnum valueOf(String name) =>
      _$kioskPaymentStateEnumValueOf(name);
}
