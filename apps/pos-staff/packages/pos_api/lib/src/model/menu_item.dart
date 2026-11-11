//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/menu_item_config.dart';
import 'package:pos_api/src/model/menu_item_all_of_variants.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/menu_item_config_components_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_item.g.dart';

/// MenuItem
///
/// Properties:
/// * [id]
/// * [productId]
/// * [name]
/// * [kind]
/// * [menuCategoryId]
/// * [kitchenCategory]
/// * [cupLabel]
/// * [showComponentsOnKds]
/// * [position]
/// * [active]
/// * [taxCategoryId]
/// * [modifierGroupIds]
/// * [components]
/// * [imageUrl]
/// * [soldOut]
/// * [variants] - Sizes, each at its price now.
@BuiltValue()
abstract class MenuItem
    implements MenuItemConfig, Built<MenuItem, MenuItemBuilder> {
  @BuiltValueField(wireName: r'image_url')
  String? get imageUrl;

  /// Sizes, each at its price now.
  @BuiltValueField(wireName: r'variants')
  BuiltList<MenuItemAllOfVariants> get variants;

  @BuiltValueField(wireName: r'sold_out')
  bool get soldOut;

  MenuItem._();

  factory MenuItem([void updates(MenuItemBuilder b)]) = _$MenuItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuItem> get serializer => _$MenuItemSerializer();
}

class _$MenuItemSerializer implements PrimitiveSerializer<MenuItem> {
  @override
  final Iterable<Type> types = const [MenuItem, _$MenuItem];

  @override
  final String wireName = r'MenuItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'components';
    yield serializers.serialize(
      object.components,
      specifiedType:
          const FullType(BuiltList, [FullType(MenuItemConfigComponentsInner)]),
    );
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'kitchen_category';
    yield object.kitchenCategory == null
        ? null
        : serializers.serialize(
            object.kitchenCategory,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(MenuItemConfigKindEnum),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    yield r'variants';
    yield serializers.serialize(
      object.variants,
      specifiedType:
          const FullType(BuiltList, [FullType(MenuItemAllOfVariants)]),
    );
    yield r'menu_category_id';
    yield object.menuCategoryId == null
        ? null
        : serializers.serialize(
            object.menuCategoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sold_out';
    yield serializers.serialize(
      object.soldOut,
      specifiedType: const FullType(bool),
    );
    yield r'image_url';
    yield object.imageUrl == null
        ? null
        : serializers.serialize(
            object.imageUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'show_components_on_kds';
    yield serializers.serialize(
      object.showComponentsOnKds,
      specifiedType: const FullType(bool),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'cup_label';
    yield serializers.serialize(
      object.cupLabel,
      specifiedType: const FullType(bool),
    );
    yield r'tax_category_id';
    yield object.taxCategoryId == null
        ? null
        : serializers.serialize(
            object.taxCategoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'modifier_group_ids';
    yield serializers.serialize(
      object.modifierGroupIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuItem object, {
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
    required MenuItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'components':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(MenuItemConfigComponentsInner)]),
          ) as BuiltList<MenuItemConfigComponentsInner>;
          result.components.replace(valueDes);
          break;
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'kitchen_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenCategory = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MenuItemConfigKindEnum),
          ) as MenuItemConfigKindEnum;
          result.kind = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        case r'variants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(MenuItemAllOfVariants)]),
          ) as BuiltList<MenuItemAllOfVariants>;
          result.variants.replace(valueDes);
          break;
        case r'menu_category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.menuCategoryId = valueDes;
          break;
        case r'sold_out':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soldOut = valueDes;
          break;
        case r'image_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imageUrl = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'show_components_on_kds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showComponentsOnKds = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'cup_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.cupLabel = valueDes;
          break;
        case r'tax_category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxCategoryId = valueDes;
          break;
        case r'modifier_group_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.modifierGroupIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MenuItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuItemBuilder();
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

class MenuItemKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'single')
  static const MenuItemKindEnum single = _$menuItemKindEnum_single;
  @BuiltValueEnumConst(wireName: r'combo')
  static const MenuItemKindEnum combo = _$menuItemKindEnum_combo;

  static Serializer<MenuItemKindEnum> get serializer =>
      _$menuItemKindEnumSerializer;

  const MenuItemKindEnum._(String name) : super(name);

  static BuiltSet<MenuItemKindEnum> get values => _$menuItemKindEnumValues;
  static MenuItemKindEnum valueOf(String name) =>
      _$menuItemKindEnumValueOf(name);
}
