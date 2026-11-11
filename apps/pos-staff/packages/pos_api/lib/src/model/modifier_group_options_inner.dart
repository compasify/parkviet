//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'modifier_group_options_inner.g.dart';

/// ModifierGroupOptionsInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [priceDelta]
/// * [variantId]
/// * [defaultSelected]
/// * [position]
/// * [active]
@BuiltValue()
abstract class ModifierGroupOptionsInner
    implements
        Built<ModifierGroupOptionsInner, ModifierGroupOptionsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'price_delta')
  String get priceDelta;

  @BuiltValueField(wireName: r'variant_id')
  String? get variantId;

  @BuiltValueField(wireName: r'default_selected')
  bool get defaultSelected;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'active')
  bool get active;

  ModifierGroupOptionsInner._();

  factory ModifierGroupOptionsInner(
          [void updates(ModifierGroupOptionsInnerBuilder b)]) =
      _$ModifierGroupOptionsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModifierGroupOptionsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModifierGroupOptionsInner> get serializer =>
      _$ModifierGroupOptionsInnerSerializer();
}

class _$ModifierGroupOptionsInnerSerializer
    implements PrimitiveSerializer<ModifierGroupOptionsInner> {
  @override
  final Iterable<Type> types = const [
    ModifierGroupOptionsInner,
    _$ModifierGroupOptionsInner
  ];

  @override
  final String wireName = r'ModifierGroupOptionsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModifierGroupOptionsInner object, {
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
    yield r'price_delta';
    yield serializers.serialize(
      object.priceDelta,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield object.variantId == null
        ? null
        : serializers.serialize(
            object.variantId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'default_selected';
    yield serializers.serialize(
      object.defaultSelected,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ModifierGroupOptionsInner object, {
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
    required ModifierGroupOptionsInnerBuilder result,
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
        case r'price_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.priceDelta = valueDes;
          break;
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.variantId = valueDes;
          break;
        case r'default_selected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.defaultSelected = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModifierGroupOptionsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModifierGroupOptionsInnerBuilder();
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
