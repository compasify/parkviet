//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_state_payments.g.dart';

/// KioskStatePayments
///
/// Properties:
/// * [vietqr]
/// * [counter]
@BuiltValue()
abstract class KioskStatePayments
    implements Built<KioskStatePayments, KioskStatePaymentsBuilder> {
  @BuiltValueField(wireName: r'vietqr')
  bool get vietqr;

  @BuiltValueField(wireName: r'counter')
  bool get counter;

  KioskStatePayments._();

  factory KioskStatePayments([void updates(KioskStatePaymentsBuilder b)]) =
      _$KioskStatePayments;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskStatePaymentsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskStatePayments> get serializer =>
      _$KioskStatePaymentsSerializer();
}

class _$KioskStatePaymentsSerializer
    implements PrimitiveSerializer<KioskStatePayments> {
  @override
  final Iterable<Type> types = const [KioskStatePayments, _$KioskStatePayments];

  @override
  final String wireName = r'KioskStatePayments';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskStatePayments object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'vietqr';
    yield serializers.serialize(
      object.vietqr,
      specifiedType: const FullType(bool),
    );
    yield r'counter';
    yield serializers.serialize(
      object.counter,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskStatePayments object, {
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
    required KioskStatePaymentsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'vietqr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.vietqr = valueDes;
          break;
        case r'counter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.counter = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskStatePayments deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskStatePaymentsBuilder();
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
