//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_item.g.dart';

/// PlatformOrderItem
///
/// Properties:
/// * [name]
/// * [quantity]
/// * [modifiers]
/// * [note]
@BuiltValue()
abstract class PlatformOrderItem
    implements Built<PlatformOrderItem, PlatformOrderItemBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<String> get modifiers;

  @BuiltValueField(wireName: r'note')
  String? get note;

  PlatformOrderItem._();

  factory PlatformOrderItem([void updates(PlatformOrderItemBuilder b)]) =
      _$PlatformOrderItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderItem> get serializer =>
      _$PlatformOrderItemSerializer();
}

class _$PlatformOrderItemSerializer
    implements PrimitiveSerializer<PlatformOrderItem> {
  @override
  final Iterable<Type> types = const [PlatformOrderItem, _$PlatformOrderItem];

  @override
  final String wireName = r'PlatformOrderItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrderItem object, {
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
    required PlatformOrderItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.modifiers.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformOrderItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderItemBuilder();
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
