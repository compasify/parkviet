//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_modifier.g.dart';

/// GuestOrderModifier
///
/// Properties:
/// * [optionId]
/// * [name]
/// * [quantity]
@BuiltValue()
abstract class GuestOrderModifier
    implements Built<GuestOrderModifier, GuestOrderModifierBuilder> {
  @BuiltValueField(wireName: r'option_id')
  String get optionId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  GuestOrderModifier._();

  factory GuestOrderModifier([void updates(GuestOrderModifierBuilder b)]) =
      _$GuestOrderModifier;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderModifierBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderModifier> get serializer =>
      _$GuestOrderModifierSerializer();
}

class _$GuestOrderModifierSerializer
    implements PrimitiveSerializer<GuestOrderModifier> {
  @override
  final Iterable<Type> types = const [GuestOrderModifier, _$GuestOrderModifier];

  @override
  final String wireName = r'GuestOrderModifier';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderModifier object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'option_id';
    yield serializers.serialize(
      object.optionId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrderModifier object, {
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
    required GuestOrderModifierBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'option_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.optionId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestOrderModifier deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderModifierBuilder();
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
