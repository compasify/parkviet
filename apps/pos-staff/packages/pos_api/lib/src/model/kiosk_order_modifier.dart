//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order_modifier.g.dart';

/// KioskOrderModifier
///
/// Properties:
/// * [name]
/// * [quantity]
@BuiltValue()
abstract class KioskOrderModifier
    implements Built<KioskOrderModifier, KioskOrderModifierBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  KioskOrderModifier._();

  factory KioskOrderModifier([void updates(KioskOrderModifierBuilder b)]) =
      _$KioskOrderModifier;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderModifierBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrderModifier> get serializer =>
      _$KioskOrderModifierSerializer();
}

class _$KioskOrderModifierSerializer
    implements PrimitiveSerializer<KioskOrderModifier> {
  @override
  final Iterable<Type> types = const [KioskOrderModifier, _$KioskOrderModifier];

  @override
  final String wireName = r'KioskOrderModifier';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrderModifier object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    KioskOrderModifier object, {
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
    required KioskOrderModifierBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  KioskOrderModifier deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderModifierBuilder();
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
