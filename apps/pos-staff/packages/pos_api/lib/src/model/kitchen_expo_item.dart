//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_ticket_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_expo_item.g.dart';

/// KitchenExpoItem
///
/// Properties:
/// * [item]
/// * [kitchenTicketId]
/// * [stationName]
@BuiltValue()
abstract class KitchenExpoItem
    implements Built<KitchenExpoItem, KitchenExpoItemBuilder> {
  @BuiltValueField(wireName: r'item')
  KitchenTicketItem get item;

  @BuiltValueField(wireName: r'kitchen_ticket_id')
  String get kitchenTicketId;

  @BuiltValueField(wireName: r'station_name')
  String get stationName;

  KitchenExpoItem._();

  factory KitchenExpoItem([void updates(KitchenExpoItemBuilder b)]) =
      _$KitchenExpoItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenExpoItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenExpoItem> get serializer =>
      _$KitchenExpoItemSerializer();
}

class _$KitchenExpoItemSerializer
    implements PrimitiveSerializer<KitchenExpoItem> {
  @override
  final Iterable<Type> types = const [KitchenExpoItem, _$KitchenExpoItem];

  @override
  final String wireName = r'KitchenExpoItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenExpoItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'item';
    yield serializers.serialize(
      object.item,
      specifiedType: const FullType(KitchenTicketItem),
    );
    yield r'kitchen_ticket_id';
    yield serializers.serialize(
      object.kitchenTicketId,
      specifiedType: const FullType(String),
    );
    yield r'station_name';
    yield serializers.serialize(
      object.stationName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenExpoItem object, {
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
    required KitchenExpoItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'item':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenTicketItem),
          ) as KitchenTicketItem;
          result.item.replace(valueDes);
          break;
        case r'kitchen_ticket_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kitchenTicketId = valueDes;
          break;
        case r'station_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stationName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenExpoItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenExpoItemBuilder();
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
