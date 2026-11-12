//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_modifier_option.g.dart';

/// KioskModifierOption
///
/// Properties:
/// * [id]
/// * [name]
/// * [priceDelta]
/// * [defaultSelected]
@BuiltValue()
abstract class KioskModifierOption
    implements Built<KioskModifierOption, KioskModifierOptionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'price_delta')
  String get priceDelta;

  @BuiltValueField(wireName: r'default_selected')
  bool get defaultSelected;

  KioskModifierOption._();

  factory KioskModifierOption([void updates(KioskModifierOptionBuilder b)]) =
      _$KioskModifierOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskModifierOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskModifierOption> get serializer =>
      _$KioskModifierOptionSerializer();
}

class _$KioskModifierOptionSerializer
    implements PrimitiveSerializer<KioskModifierOption> {
  @override
  final Iterable<Type> types = const [
    KioskModifierOption,
    _$KioskModifierOption
  ];

  @override
  final String wireName = r'KioskModifierOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskModifierOption object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'price_delta';
    yield serializers.serialize(
      object.priceDelta,
      specifiedType: const FullType(String),
    );
    yield r'default_selected';
    yield serializers.serialize(
      object.defaultSelected,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskModifierOption object, {
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
    required KioskModifierOptionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'price_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.priceDelta = valueDes;
          break;
        case r'default_selected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.defaultSelected = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskModifierOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskModifierOptionBuilder();
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
