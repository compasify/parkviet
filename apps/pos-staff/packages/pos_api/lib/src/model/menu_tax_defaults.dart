//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_tax_defaults.g.dart';

/// Tax categories new menu items start with, chosen in the F&B setup step.
///
/// Properties:
/// * [food]
/// * [alcohol]
@BuiltValue()
abstract class MenuTaxDefaults
    implements Built<MenuTaxDefaults, MenuTaxDefaultsBuilder> {
  @BuiltValueField(wireName: r'food')
  String get food;

  @BuiltValueField(wireName: r'alcohol')
  String get alcohol;

  MenuTaxDefaults._();

  factory MenuTaxDefaults([void updates(MenuTaxDefaultsBuilder b)]) =
      _$MenuTaxDefaults;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuTaxDefaultsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuTaxDefaults> get serializer =>
      _$MenuTaxDefaultsSerializer();
}

class _$MenuTaxDefaultsSerializer
    implements PrimitiveSerializer<MenuTaxDefaults> {
  @override
  final Iterable<Type> types = const [MenuTaxDefaults, _$MenuTaxDefaults];

  @override
  final String wireName = r'MenuTaxDefaults';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuTaxDefaults object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'food';
    yield serializers.serialize(
      object.food,
      specifiedType: const FullType(String),
    );
    yield r'alcohol';
    yield serializers.serialize(
      object.alcohol,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuTaxDefaults object, {
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
    required MenuTaxDefaultsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'food':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.food = valueDes;
          break;
        case r'alcohol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.alcohol = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MenuTaxDefaults deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuTaxDefaultsBuilder();
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
