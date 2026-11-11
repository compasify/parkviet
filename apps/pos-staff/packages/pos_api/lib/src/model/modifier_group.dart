//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/modifier_group_options_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'modifier_group.g.dart';

/// ModifierGroup
///
/// Properties:
/// * [id]
/// * [name]
/// * [minSelect]
/// * [maxSelect]
/// * [allowQuantity]
/// * [position]
/// * [required_]
/// * [options]
@BuiltValue()
abstract class ModifierGroup
    implements Built<ModifierGroup, ModifierGroupBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'min_select')
  int get minSelect;

  @BuiltValueField(wireName: r'max_select')
  int get maxSelect;

  @BuiltValueField(wireName: r'allow_quantity')
  bool get allowQuantity;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'required')
  bool get required_;

  @BuiltValueField(wireName: r'options')
  BuiltList<ModifierGroupOptionsInner> get options;

  ModifierGroup._();

  factory ModifierGroup([void updates(ModifierGroupBuilder b)]) =
      _$ModifierGroup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModifierGroupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModifierGroup> get serializer =>
      _$ModifierGroupSerializer();
}

class _$ModifierGroupSerializer implements PrimitiveSerializer<ModifierGroup> {
  @override
  final Iterable<Type> types = const [ModifierGroup, _$ModifierGroup];

  @override
  final String wireName = r'ModifierGroup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModifierGroup object, {
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
    yield r'min_select';
    yield serializers.serialize(
      object.minSelect,
      specifiedType: const FullType(int),
    );
    yield r'max_select';
    yield serializers.serialize(
      object.maxSelect,
      specifiedType: const FullType(int),
    );
    yield r'allow_quantity';
    yield serializers.serialize(
      object.allowQuantity,
      specifiedType: const FullType(bool),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'required';
    yield serializers.serialize(
      object.required_,
      specifiedType: const FullType(bool),
    );
    yield r'options';
    yield serializers.serialize(
      object.options,
      specifiedType:
          const FullType(BuiltList, [FullType(ModifierGroupOptionsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ModifierGroup object, {
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
    required ModifierGroupBuilder result,
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
        case r'min_select':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minSelect = valueDes;
          break;
        case r'max_select':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxSelect = valueDes;
          break;
        case r'allow_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.allowQuantity = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.required_ = valueDes;
          break;
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(ModifierGroupOptionsInner)]),
          ) as BuiltList<ModifierGroupOptionsInner>;
          result.options.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModifierGroup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModifierGroupBuilder();
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
