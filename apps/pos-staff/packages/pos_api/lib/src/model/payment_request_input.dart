//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_request_input.g.dart';

/// PaymentRequestInput
///
/// Properties:
/// * [note]
@BuiltValue()
abstract class PaymentRequestInput
    implements Built<PaymentRequestInput, PaymentRequestInputBuilder> {
  @BuiltValueField(wireName: r'note')
  String? get note;

  PaymentRequestInput._();

  factory PaymentRequestInput([void updates(PaymentRequestInputBuilder b)]) =
      _$PaymentRequestInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentRequestInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentRequestInput> get serializer =>
      _$PaymentRequestInputSerializer();
}

class _$PaymentRequestInputSerializer
    implements PrimitiveSerializer<PaymentRequestInput> {
  @override
  final Iterable<Type> types = const [
    PaymentRequestInput,
    _$PaymentRequestInput
  ];

  @override
  final String wireName = r'PaymentRequestInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentRequestInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentRequestInput object, {
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
    required PaymentRequestInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentRequestInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentRequestInputBuilder();
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
