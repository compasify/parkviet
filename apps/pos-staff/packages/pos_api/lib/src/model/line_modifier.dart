//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'line_modifier.g.dart';

/// An option a line was sold with, copied at the time of sale.
///
/// Properties:
/// * [id]
/// * [optionId] - Null once the option itself was deleted.
/// * [name]
/// * [groupName]
/// * [priceDelta]
/// * [quantity]
@BuiltValue()
abstract class LineModifier
    implements Built<LineModifier, LineModifierBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Null once the option itself was deleted.
  @BuiltValueField(wireName: r'option_id')
  String? get optionId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'group_name')
  String get groupName;

  @BuiltValueField(wireName: r'price_delta')
  String get priceDelta;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  LineModifier._();

  factory LineModifier([void updates(LineModifierBuilder b)]) = _$LineModifier;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LineModifierBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LineModifier> get serializer => _$LineModifierSerializer();
}

class _$LineModifierSerializer implements PrimitiveSerializer<LineModifier> {
  @override
  final Iterable<Type> types = const [LineModifier, _$LineModifier];

  @override
  final String wireName = r'LineModifier';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LineModifier object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'option_id';
    yield object.optionId == null
        ? null
        : serializers.serialize(
            object.optionId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'group_name';
    yield serializers.serialize(
      object.groupName,
      specifiedType: const FullType(String),
    );
    yield r'price_delta';
    yield serializers.serialize(
      object.priceDelta,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LineModifier object, {
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
    required LineModifierBuilder result,
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
        case r'option_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.optionId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'group_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupName = valueDes;
          break;
        case r'price_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.priceDelta = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
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
  LineModifier deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LineModifierBuilder();
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
