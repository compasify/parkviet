//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_item_all_of_variants.g.dart';

/// MenuItemAllOfVariants
///
/// Properties:
/// * [id]
/// * [name]
/// * [sku]
/// * [barcode]
/// * [price]
/// * [listPrice]
/// * [scheduleId] - The time-of-day menu that sets `price`, if any.
@BuiltValue()
abstract class MenuItemAllOfVariants
    implements Built<MenuItemAllOfVariants, MenuItemAllOfVariantsBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'barcode')
  String? get barcode;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'list_price')
  String? get listPrice;

  /// The time-of-day menu that sets `price`, if any.
  @BuiltValueField(wireName: r'schedule_id')
  String? get scheduleId;

  MenuItemAllOfVariants._();

  factory MenuItemAllOfVariants(
      [void updates(MenuItemAllOfVariantsBuilder b)]) = _$MenuItemAllOfVariants;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuItemAllOfVariantsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuItemAllOfVariants> get serializer =>
      _$MenuItemAllOfVariantsSerializer();
}

class _$MenuItemAllOfVariantsSerializer
    implements PrimitiveSerializer<MenuItemAllOfVariants> {
  @override
  final Iterable<Type> types = const [
    MenuItemAllOfVariants,
    _$MenuItemAllOfVariants
  ];

  @override
  final String wireName = r'MenuItemAllOfVariants';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuItemAllOfVariants object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sku';
    yield object.sku == null
        ? null
        : serializers.serialize(
            object.sku,
            specifiedType: const FullType.nullable(String),
          );
    yield r'barcode';
    yield object.barcode == null
        ? null
        : serializers.serialize(
            object.barcode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'list_price';
    yield object.listPrice == null
        ? null
        : serializers.serialize(
            object.listPrice,
            specifiedType: const FullType.nullable(String),
          );
    yield r'schedule_id';
    yield object.scheduleId == null
        ? null
        : serializers.serialize(
            object.scheduleId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuItemAllOfVariants object, {
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
    required MenuItemAllOfVariantsBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'barcode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.barcode = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.price = valueDes;
          break;
        case r'list_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.listPrice = valueDes;
          break;
        case r'schedule_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.scheduleId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MenuItemAllOfVariants deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuItemAllOfVariantsBuilder();
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
