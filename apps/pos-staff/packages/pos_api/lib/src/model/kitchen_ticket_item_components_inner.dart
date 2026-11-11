//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_ticket_item_components_inner.g.dart';

/// KitchenTicketItemComponentsInner
///
/// Properties:
/// * [name]
/// * [quantity]
@BuiltValue()
abstract class KitchenTicketItemComponentsInner
    implements
        Built<KitchenTicketItemComponentsInner,
            KitchenTicketItemComponentsInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  KitchenTicketItemComponentsInner._();

  factory KitchenTicketItemComponentsInner(
          [void updates(KitchenTicketItemComponentsInnerBuilder b)]) =
      _$KitchenTicketItemComponentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenTicketItemComponentsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenTicketItemComponentsInner> get serializer =>
      _$KitchenTicketItemComponentsInnerSerializer();
}

class _$KitchenTicketItemComponentsInnerSerializer
    implements PrimitiveSerializer<KitchenTicketItemComponentsInner> {
  @override
  final Iterable<Type> types = const [
    KitchenTicketItemComponentsInner,
    _$KitchenTicketItemComponentsInner
  ];

  @override
  final String wireName = r'KitchenTicketItemComponentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenTicketItemComponentsInner object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenTicketItemComponentsInner object, {
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
    required KitchenTicketItemComponentsInnerBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenTicketItemComponentsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenTicketItemComponentsInnerBuilder();
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
