//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_request_resolve_input.g.dart';

/// PaymentRequestResolveInput
///
/// Properties:
/// * [status]
@BuiltValue()
abstract class PaymentRequestResolveInput
    implements
        Built<PaymentRequestResolveInput, PaymentRequestResolveInputBuilder> {
  @BuiltValueField(wireName: r'status')
  PaymentRequestResolveInputStatusEnum get status;
  // enum statusEnum {  done,  canceled,  };

  PaymentRequestResolveInput._();

  factory PaymentRequestResolveInput(
          [void updates(PaymentRequestResolveInputBuilder b)]) =
      _$PaymentRequestResolveInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentRequestResolveInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentRequestResolveInput> get serializer =>
      _$PaymentRequestResolveInputSerializer();
}

class _$PaymentRequestResolveInputSerializer
    implements PrimitiveSerializer<PaymentRequestResolveInput> {
  @override
  final Iterable<Type> types = const [
    PaymentRequestResolveInput,
    _$PaymentRequestResolveInput
  ];

  @override
  final String wireName = r'PaymentRequestResolveInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentRequestResolveInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PaymentRequestResolveInputStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentRequestResolveInput object, {
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
    required PaymentRequestResolveInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentRequestResolveInputStatusEnum),
          ) as PaymentRequestResolveInputStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentRequestResolveInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentRequestResolveInputBuilder();
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

class PaymentRequestResolveInputStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'done')
  static const PaymentRequestResolveInputStatusEnum done =
      _$paymentRequestResolveInputStatusEnum_done;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const PaymentRequestResolveInputStatusEnum canceled =
      _$paymentRequestResolveInputStatusEnum_canceled;

  static Serializer<PaymentRequestResolveInputStatusEnum> get serializer =>
      _$paymentRequestResolveInputStatusEnumSerializer;

  const PaymentRequestResolveInputStatusEnum._(String name) : super(name);

  static BuiltSet<PaymentRequestResolveInputStatusEnum> get values =>
      _$paymentRequestResolveInputStatusEnumValues;
  static PaymentRequestResolveInputStatusEnum valueOf(String name) =>
      _$paymentRequestResolveInputStatusEnumValueOf(name);
}
