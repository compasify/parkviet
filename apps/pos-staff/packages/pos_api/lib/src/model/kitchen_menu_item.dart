//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_menu_item.g.dart';

/// KitchenMenuItem
///
/// Properties:
/// * [id]
/// * [name]
/// * [kitchenCategory]
/// * [soldOut]
@BuiltValue()
abstract class KitchenMenuItem
    implements Built<KitchenMenuItem, KitchenMenuItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kitchen_category')
  String? get kitchenCategory;

  @BuiltValueField(wireName: r'sold_out')
  bool get soldOut;

  KitchenMenuItem._();

  factory KitchenMenuItem([void updates(KitchenMenuItemBuilder b)]) =
      _$KitchenMenuItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenMenuItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenMenuItem> get serializer =>
      _$KitchenMenuItemSerializer();
}

class _$KitchenMenuItemSerializer
    implements PrimitiveSerializer<KitchenMenuItem> {
  @override
  final Iterable<Type> types = const [KitchenMenuItem, _$KitchenMenuItem];

  @override
  final String wireName = r'KitchenMenuItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenMenuItem object, {
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
    yield r'kitchen_category';
    yield object.kitchenCategory == null
        ? null
        : serializers.serialize(
            object.kitchenCategory,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sold_out';
    yield serializers.serialize(
      object.soldOut,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenMenuItem object, {
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
    required KitchenMenuItemBuilder result,
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
        case r'kitchen_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenCategory = valueDes;
          break;
        case r'sold_out':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soldOut = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenMenuItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenMenuItemBuilder();
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
