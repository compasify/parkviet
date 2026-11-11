//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'modifier_pick.g.dart';

/// ModifierPick
///
/// Properties:
/// * [optionId]
/// * [quantity]
@BuiltValue()
abstract class ModifierPick
    implements Built<ModifierPick, ModifierPickBuilder> {
  @BuiltValueField(wireName: r'option_id')
  String get optionId;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  ModifierPick._();

  factory ModifierPick([void updates(ModifierPickBuilder b)]) = _$ModifierPick;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModifierPickBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModifierPick> get serializer => _$ModifierPickSerializer();
}

class _$ModifierPickSerializer implements PrimitiveSerializer<ModifierPick> {
  @override
  final Iterable<Type> types = const [ModifierPick, _$ModifierPick];

  @override
  final String wireName = r'ModifierPick';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModifierPick object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'option_id';
    yield serializers.serialize(
      object.optionId,
      specifiedType: const FullType(String),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ModifierPick object, {
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
    required ModifierPickBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'option_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.optionId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
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
  ModifierPick deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModifierPickBuilder();
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
