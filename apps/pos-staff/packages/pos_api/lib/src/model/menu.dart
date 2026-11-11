//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/menu_category.dart';
import 'package:pos_api/src/model/menu_schedules_inner.dart';
import 'package:pos_api/src/model/modifier_group.dart';
import 'package:pos_api/src/model/menu_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu.g.dart';

/// Menu
///
/// Properties:
/// * [branchId]
/// * [currency]
/// * [businessDate]
/// * [moduleEnabled]
/// * [categories]
/// * [items]
/// * [modifierGroups]
/// * [schedules] - Time-of-day menus running now.
/// * [favorites] - Menu item ids of the favourites row, in order.
/// * [etag]
@BuiltValue()
abstract class Menu implements Built<Menu, MenuBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'module_enabled')
  bool get moduleEnabled;

  @BuiltValueField(wireName: r'categories')
  BuiltList<MenuCategory> get categories;

  @BuiltValueField(wireName: r'items')
  BuiltList<MenuItem> get items;

  @BuiltValueField(wireName: r'modifier_groups')
  BuiltList<ModifierGroup> get modifierGroups;

  /// Time-of-day menus running now.
  @BuiltValueField(wireName: r'schedules')
  BuiltList<MenuSchedulesInner> get schedules;

  /// Menu item ids of the favourites row, in order.
  @BuiltValueField(wireName: r'favorites')
  BuiltList<String> get favorites;

  @BuiltValueField(wireName: r'etag')
  String get etag;

  Menu._();

  factory Menu([void updates(MenuBuilder b)]) = _$Menu;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Menu> get serializer => _$MenuSerializer();
}

class _$MenuSerializer implements PrimitiveSerializer<Menu> {
  @override
  final Iterable<Type> types = const [Menu, _$Menu];

  @override
  final String wireName = r'Menu';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Menu object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    yield r'module_enabled';
    yield serializers.serialize(
      object.moduleEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'categories';
    yield serializers.serialize(
      object.categories,
      specifiedType: const FullType(BuiltList, [FullType(MenuCategory)]),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(MenuItem)]),
    );
    yield r'modifier_groups';
    yield serializers.serialize(
      object.modifierGroups,
      specifiedType: const FullType(BuiltList, [FullType(ModifierGroup)]),
    );
    yield r'schedules';
    yield serializers.serialize(
      object.schedules,
      specifiedType: const FullType(BuiltList, [FullType(MenuSchedulesInner)]),
    );
    yield r'favorites';
    yield serializers.serialize(
      object.favorites,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'etag';
    yield serializers.serialize(
      object.etag,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Menu object, {
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
    required MenuBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'module_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.moduleEnabled = valueDes;
          break;
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MenuCategory)]),
          ) as BuiltList<MenuCategory>;
          result.categories.replace(valueDes);
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MenuItem)]),
          ) as BuiltList<MenuItem>;
          result.items.replace(valueDes);
          break;
        case r'modifier_groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ModifierGroup)]),
          ) as BuiltList<ModifierGroup>;
          result.modifierGroups.replace(valueDes);
          break;
        case r'schedules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(MenuSchedulesInner)]),
          ) as BuiltList<MenuSchedulesInner>;
          result.schedules.replace(valueDes);
          break;
        case r'favorites':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.favorites.replace(valueDes);
          break;
        case r'etag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.etag = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Menu deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuBuilder();
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
