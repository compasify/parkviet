//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_item_config_components_inner.g.dart';

/// MenuItemConfigComponentsInner
///
/// Properties:
/// * [id]
/// * [variantId]
/// * [name]
/// * [quantity]
@BuiltValue()
abstract class MenuItemConfigComponentsInner
    implements
        Built<MenuItemConfigComponentsInner,
            MenuItemConfigComponentsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  MenuItemConfigComponentsInner._();

  factory MenuItemConfigComponentsInner(
          [void updates(MenuItemConfigComponentsInnerBuilder b)]) =
      _$MenuItemConfigComponentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuItemConfigComponentsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuItemConfigComponentsInner> get serializer =>
      _$MenuItemConfigComponentsInnerSerializer();
}

class _$MenuItemConfigComponentsInnerSerializer
    implements PrimitiveSerializer<MenuItemConfigComponentsInner> {
  @override
  final Iterable<Type> types = const [
    MenuItemConfigComponentsInner,
    _$MenuItemConfigComponentsInner
  ];

  @override
  final String wireName = r'MenuItemConfigComponentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuItemConfigComponentsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
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
    MenuItemConfigComponentsInner object, {
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
    required MenuItemConfigComponentsInnerBuilder result,
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
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
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
  MenuItemConfigComponentsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuItemConfigComponentsInnerBuilder();
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
