//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_menu_component.dart';
import 'package:pos_api/src/model/kiosk_menu_variant.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_menu_item.g.dart';

/// KioskMenuItem
///
/// Properties:
/// * [id]
/// * [name]
/// * [kind]
/// * [menuCategoryId]
/// * [position]
/// * [imageUrl]
/// * [soldOut]
/// * [modifierGroupIds]
/// * [components]
/// * [variants]
@BuiltValue()
abstract class KioskMenuItem
    implements Built<KioskMenuItem, KioskMenuItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  KioskMenuItemKindEnum get kind;
  // enum kindEnum {  single,  combo,  };

  @BuiltValueField(wireName: r'menu_category_id')
  String? get menuCategoryId;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'image_url')
  String? get imageUrl;

  @BuiltValueField(wireName: r'sold_out')
  bool get soldOut;

  @BuiltValueField(wireName: r'modifier_group_ids')
  BuiltList<String> get modifierGroupIds;

  @BuiltValueField(wireName: r'components')
  BuiltList<KioskMenuComponent> get components;

  @BuiltValueField(wireName: r'variants')
  BuiltList<KioskMenuVariant> get variants;

  KioskMenuItem._();

  factory KioskMenuItem([void updates(KioskMenuItemBuilder b)]) =
      _$KioskMenuItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskMenuItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskMenuItem> get serializer =>
      _$KioskMenuItemSerializer();
}

class _$KioskMenuItemSerializer implements PrimitiveSerializer<KioskMenuItem> {
  @override
  final Iterable<Type> types = const [KioskMenuItem, _$KioskMenuItem];

  @override
  final String wireName = r'KioskMenuItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskMenuItem object, {
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
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(KioskMenuItemKindEnum),
    );
    yield r'menu_category_id';
    yield object.menuCategoryId == null
        ? null
        : serializers.serialize(
            object.menuCategoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'image_url';
    yield object.imageUrl == null
        ? null
        : serializers.serialize(
            object.imageUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sold_out';
    yield serializers.serialize(
      object.soldOut,
      specifiedType: const FullType(bool),
    );
    yield r'modifier_group_ids';
    yield serializers.serialize(
      object.modifierGroupIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'components';
    yield serializers.serialize(
      object.components,
      specifiedType: const FullType(BuiltList, [FullType(KioskMenuComponent)]),
    );
    yield r'variants';
    yield serializers.serialize(
      object.variants,
      specifiedType: const FullType(BuiltList, [FullType(KioskMenuVariant)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskMenuItem object, {
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
    required KioskMenuItemBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskMenuItemKindEnum),
          ) as KioskMenuItemKindEnum;
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
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'image_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imageUrl = valueDes;
          break;
        case r'sold_out':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soldOut = valueDes;
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
            specifiedType:
                const FullType(BuiltList, [FullType(KioskMenuComponent)]),
          ) as BuiltList<KioskMenuComponent>;
          result.components.replace(valueDes);
          break;
        case r'variants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KioskMenuVariant)]),
          ) as BuiltList<KioskMenuVariant>;
          result.variants.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskMenuItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskMenuItemBuilder();
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

class KioskMenuItemKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'single')
  static const KioskMenuItemKindEnum single = _$kioskMenuItemKindEnum_single;
  @BuiltValueEnumConst(wireName: r'combo')
  static const KioskMenuItemKindEnum combo = _$kioskMenuItemKindEnum_combo;

  static Serializer<KioskMenuItemKindEnum> get serializer =>
      _$kioskMenuItemKindEnumSerializer;

  const KioskMenuItemKindEnum._(String name) : super(name);

  static BuiltSet<KioskMenuItemKindEnum> get values =>
      _$kioskMenuItemKindEnumValues;
  static KioskMenuItemKindEnum valueOf(String name) =>
      _$kioskMenuItemKindEnumValueOf(name);
}
