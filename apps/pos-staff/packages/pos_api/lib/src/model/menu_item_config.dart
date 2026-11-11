//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/menu_item_config_components_inner.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_item_config.g.dart';

/// MenuItemConfig
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
@BuiltValue(instantiable: false)
abstract class MenuItemConfig {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  MenuItemConfigKindEnum get kind;
  // enum kindEnum {  single,  combo,  };

  @BuiltValueField(wireName: r'menu_category_id')
  String? get menuCategoryId;

  @BuiltValueField(wireName: r'kitchen_category')
  String? get kitchenCategory;

  @BuiltValueField(wireName: r'cup_label')
  bool get cupLabel;

  @BuiltValueField(wireName: r'show_components_on_kds')
  bool get showComponentsOnKds;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'tax_category_id')
  String? get taxCategoryId;

  @BuiltValueField(wireName: r'modifier_group_ids')
  BuiltList<String> get modifierGroupIds;

  @BuiltValueField(wireName: r'components')
  BuiltList<MenuItemConfigComponentsInner> get components;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuItemConfig> get serializer =>
      _$MenuItemConfigSerializer();
}

class _$MenuItemConfigSerializer
    implements PrimitiveSerializer<MenuItemConfig> {
  @override
  final Iterable<Type> types = const [MenuItemConfig];

  @override
  final String wireName = r'MenuItemConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuItemConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(MenuItemConfigKindEnum),
    );
    yield r'menu_category_id';
    yield object.menuCategoryId == null
        ? null
        : serializers.serialize(
            object.menuCategoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kitchen_category';
    yield object.kitchenCategory == null
        ? null
        : serializers.serialize(
            object.kitchenCategory,
            specifiedType: const FullType.nullable(String),
          );
    yield r'cup_label';
    yield serializers.serialize(
      object.cupLabel,
      specifiedType: const FullType(bool),
    );
    yield r'show_components_on_kds';
    yield serializers.serialize(
      object.showComponentsOnKds,
      specifiedType: const FullType(bool),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
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
    yield r'components';
    yield serializers.serialize(
      object.components,
      specifiedType:
          const FullType(BuiltList, [FullType(MenuItemConfigComponentsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuItemConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  @override
  MenuItemConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized,
        specifiedType: FullType($MenuItemConfig)) as $MenuItemConfig;
  }
}

/// a concrete implementation of [MenuItemConfig], since [MenuItemConfig] is not instantiable
@BuiltValue(instantiable: true)
abstract class $MenuItemConfig
    implements MenuItemConfig, Built<$MenuItemConfig, $MenuItemConfigBuilder> {
  $MenuItemConfig._();

  factory $MenuItemConfig([void Function($MenuItemConfigBuilder)? updates]) =
      _$$MenuItemConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($MenuItemConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$MenuItemConfig> get serializer =>
      _$$MenuItemConfigSerializer();
}

class _$$MenuItemConfigSerializer
    implements PrimitiveSerializer<$MenuItemConfig> {
  @override
  final Iterable<Type> types = const [$MenuItemConfig, _$$MenuItemConfig];

  @override
  final String wireName = r'$MenuItemConfig';

  @override
  Object serialize(
    Serializers serializers,
    $MenuItemConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object,
        specifiedType: FullType(MenuItemConfig))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MenuItemConfigBuilder result,
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
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MenuItemConfigKindEnum),
          ) as MenuItemConfigKindEnum;
          result.kind = valueDes;
          break;
        case r'menu_category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.menuCategoryId = valueDes;
          break;
        case r'kitchen_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenCategory = valueDes;
          break;
        case r'cup_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.cupLabel = valueDes;
          break;
        case r'show_components_on_kds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showComponentsOnKds = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
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
        case r'components':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(MenuItemConfigComponentsInner)]),
          ) as BuiltList<MenuItemConfigComponentsInner>;
          result.components.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $MenuItemConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $MenuItemConfigBuilder();
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

class MenuItemConfigKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'single')
  static const MenuItemConfigKindEnum single = _$menuItemConfigKindEnum_single;
  @BuiltValueEnumConst(wireName: r'combo')
  static const MenuItemConfigKindEnum combo = _$menuItemConfigKindEnum_combo;

  static Serializer<MenuItemConfigKindEnum> get serializer =>
      _$menuItemConfigKindEnumSerializer;

  const MenuItemConfigKindEnum._(String name) : super(name);

  static BuiltSet<MenuItemConfigKindEnum> get values =>
      _$menuItemConfigKindEnumValues;
  static MenuItemConfigKindEnum valueOf(String name) =>
      _$menuItemConfigKindEnumValueOf(name);
}
