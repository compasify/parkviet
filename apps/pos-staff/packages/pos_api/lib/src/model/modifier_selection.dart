//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'modifier_selection.g.dart';

/// ModifierSelection
///
/// Properties:
/// * [optionId]
/// * [quantity] - Above 1 only in a group with `allow_quantity`.
@BuiltValue()
abstract class ModifierSelection
    implements Built<ModifierSelection, ModifierSelectionBuilder> {
  @BuiltValueField(wireName: r'option_id')
  String get optionId;

  /// Above 1 only in a group with `allow_quantity`.
  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  ModifierSelection._();

  factory ModifierSelection([void updates(ModifierSelectionBuilder b)]) =
      _$ModifierSelection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModifierSelectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModifierSelection> get serializer =>
      _$ModifierSelectionSerializer();
}

class _$ModifierSelectionSerializer
    implements PrimitiveSerializer<ModifierSelection> {
  @override
  final Iterable<Type> types = const [ModifierSelection, _$ModifierSelection];

  @override
  final String wireName = r'ModifierSelection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModifierSelection object, {
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
    ModifierSelection object, {
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
    required ModifierSelectionBuilder result,
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
  ModifierSelection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModifierSelectionBuilder();
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
