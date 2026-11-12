//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_reject_input.g.dart';

/// GuestOrderRejectInput
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class GuestOrderRejectInput
    implements Built<GuestOrderRejectInput, GuestOrderRejectInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  GuestOrderRejectInput._();

  factory GuestOrderRejectInput(
      [void updates(GuestOrderRejectInputBuilder b)]) = _$GuestOrderRejectInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderRejectInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderRejectInput> get serializer =>
      _$GuestOrderRejectInputSerializer();
}

class _$GuestOrderRejectInputSerializer
    implements PrimitiveSerializer<GuestOrderRejectInput> {
  @override
  final Iterable<Type> types = const [
    GuestOrderRejectInput,
    _$GuestOrderRejectInput
  ];

  @override
  final String wireName = r'GuestOrderRejectInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderRejectInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrderRejectInput object, {
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
    required GuestOrderRejectInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GuestOrderRejectInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderRejectInputBuilder();
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
