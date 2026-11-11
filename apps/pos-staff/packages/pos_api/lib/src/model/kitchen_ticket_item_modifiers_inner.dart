//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_ticket_item_modifiers_inner.g.dart';

/// KitchenTicketItemModifiersInner
///
/// Properties:
/// * [name]
/// * [groupName]
/// * [quantity]
@BuiltValue()
abstract class KitchenTicketItemModifiersInner
    implements
        Built<KitchenTicketItemModifiersInner,
            KitchenTicketItemModifiersInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'group_name')
  String? get groupName;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  KitchenTicketItemModifiersInner._();

  factory KitchenTicketItemModifiersInner(
          [void updates(KitchenTicketItemModifiersInnerBuilder b)]) =
      _$KitchenTicketItemModifiersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenTicketItemModifiersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenTicketItemModifiersInner> get serializer =>
      _$KitchenTicketItemModifiersInnerSerializer();
}

class _$KitchenTicketItemModifiersInnerSerializer
    implements PrimitiveSerializer<KitchenTicketItemModifiersInner> {
  @override
  final Iterable<Type> types = const [
    KitchenTicketItemModifiersInner,
    _$KitchenTicketItemModifiersInner
  ];

  @override
  final String wireName = r'KitchenTicketItemModifiersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenTicketItemModifiersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.groupName != null) {
      yield r'group_name';
      yield serializers.serialize(
        object.groupName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenTicketItemModifiersInner object, {
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
    required KitchenTicketItemModifiersInnerBuilder result,
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
        case r'group_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.groupName = valueDes;
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
  KitchenTicketItemModifiersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenTicketItemModifiersInnerBuilder();
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
