//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_ticket_list.g.dart';

/// KitchenTicketList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenTicketList
    implements Built<KitchenTicketList, KitchenTicketListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<KitchenTicket> get data;

  KitchenTicketList._();

  factory KitchenTicketList([void updates(KitchenTicketListBuilder b)]) =
      _$KitchenTicketList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenTicketListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenTicketList> get serializer =>
      _$KitchenTicketListSerializer();
}

class _$KitchenTicketListSerializer
    implements PrimitiveSerializer<KitchenTicketList> {
  @override
  final Iterable<Type> types = const [KitchenTicketList, _$KitchenTicketList];

  @override
  final String wireName = r'KitchenTicketList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenTicketList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenTicketList object, {
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
    required KitchenTicketListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
          ) as BuiltList<KitchenTicket>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenTicketList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenTicketListBuilder();
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
