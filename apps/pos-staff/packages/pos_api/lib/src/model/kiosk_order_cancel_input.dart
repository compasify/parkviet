//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order_cancel_input.g.dart';

/// KioskOrderCancelInput
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class KioskOrderCancelInput
    implements Built<KioskOrderCancelInput, KioskOrderCancelInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  KioskOrderCancelInput._();

  factory KioskOrderCancelInput(
      [void updates(KioskOrderCancelInputBuilder b)]) = _$KioskOrderCancelInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderCancelInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrderCancelInput> get serializer =>
      _$KioskOrderCancelInputSerializer();
}

class _$KioskOrderCancelInputSerializer
    implements PrimitiveSerializer<KioskOrderCancelInput> {
  @override
  final Iterable<Type> types = const [
    KioskOrderCancelInput,
    _$KioskOrderCancelInput
  ];

  @override
  final String wireName = r'KioskOrderCancelInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrderCancelInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskOrderCancelInput object, {
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
    required KioskOrderCancelInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskOrderCancelInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderCancelInputBuilder();
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
