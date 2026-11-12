//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_menu_category.dart';
import 'package:pos_api/src/model/kiosk_modifier_group.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kiosk_menu_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_menu.g.dart';

/// KioskMenu
///
/// Properties:
/// * [currency]
/// * [etag]
/// * [categories]
/// * [items]
/// * [modifierGroups]
@BuiltValue()
abstract class KioskMenu implements Built<KioskMenu, KioskMenuBuilder> {
  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'etag')
  String get etag;

  @BuiltValueField(wireName: r'categories')
  BuiltList<KioskMenuCategory> get categories;

  @BuiltValueField(wireName: r'items')
  BuiltList<KioskMenuItem> get items;

  @BuiltValueField(wireName: r'modifier_groups')
  BuiltList<KioskModifierGroup> get modifierGroups;

  KioskMenu._();

  factory KioskMenu([void updates(KioskMenuBuilder b)]) = _$KioskMenu;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskMenuBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskMenu> get serializer => _$KioskMenuSerializer();
}

class _$KioskMenuSerializer implements PrimitiveSerializer<KioskMenu> {
  @override
  final Iterable<Type> types = const [KioskMenu, _$KioskMenu];

  @override
  final String wireName = r'KioskMenu';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskMenu object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'etag';
    yield serializers.serialize(
      object.etag,
      specifiedType: const FullType(String),
    );
    yield r'categories';
    yield serializers.serialize(
      object.categories,
      specifiedType: const FullType(BuiltList, [FullType(KioskMenuCategory)]),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(KioskMenuItem)]),
    );
    yield r'modifier_groups';
    yield serializers.serialize(
      object.modifierGroups,
      specifiedType: const FullType(BuiltList, [FullType(KioskModifierGroup)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskMenu object, {
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
    required KioskMenuBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'etag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.etag = valueDes;
          break;
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KioskMenuCategory)]),
          ) as BuiltList<KioskMenuCategory>;
          result.categories.replace(valueDes);
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KioskMenuItem)]),
          ) as BuiltList<KioskMenuItem>;
          result.items.replace(valueDes);
          break;
        case r'modifier_groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KioskModifierGroup)]),
          ) as BuiltList<KioskModifierGroup>;
          result.modifierGroups.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskMenu deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskMenuBuilder();
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
