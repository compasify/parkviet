//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/menu_tax_defaults.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_items_meta.g.dart';

/// MenuItemsMeta
///
/// Properties:
/// * [taxDefaults]
@BuiltValue()
abstract class MenuItemsMeta
    implements Built<MenuItemsMeta, MenuItemsMetaBuilder> {
  @BuiltValueField(wireName: r'tax_defaults')
  MenuTaxDefaults get taxDefaults;

  MenuItemsMeta._();

  factory MenuItemsMeta([void updates(MenuItemsMetaBuilder b)]) =
      _$MenuItemsMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuItemsMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuItemsMeta> get serializer =>
      _$MenuItemsMetaSerializer();
}

class _$MenuItemsMetaSerializer implements PrimitiveSerializer<MenuItemsMeta> {
  @override
  final Iterable<Type> types = const [MenuItemsMeta, _$MenuItemsMeta];

  @override
  final String wireName = r'MenuItemsMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuItemsMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tax_defaults';
    yield serializers.serialize(
      object.taxDefaults,
      specifiedType: const FullType(MenuTaxDefaults),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuItemsMeta object, {
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
    required MenuItemsMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tax_defaults':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MenuTaxDefaults),
          ) as MenuTaxDefaults;
          result.taxDefaults.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MenuItemsMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuItemsMetaBuilder();
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
