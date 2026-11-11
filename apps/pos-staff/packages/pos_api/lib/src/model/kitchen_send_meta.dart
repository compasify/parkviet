//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_send_meta.g.dart';

/// KitchenSendMeta
///
/// Properties:
/// * [tickets]
/// * [ticketCount]
@BuiltValue()
abstract class KitchenSendMeta
    implements Built<KitchenSendMeta, KitchenSendMetaBuilder> {
  @BuiltValueField(wireName: r'tickets')
  BuiltList<KitchenTicket> get tickets;

  @BuiltValueField(wireName: r'ticket_count')
  int get ticketCount;

  KitchenSendMeta._();

  factory KitchenSendMeta([void updates(KitchenSendMetaBuilder b)]) =
      _$KitchenSendMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenSendMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenSendMeta> get serializer =>
      _$KitchenSendMetaSerializer();
}

class _$KitchenSendMetaSerializer
    implements PrimitiveSerializer<KitchenSendMeta> {
  @override
  final Iterable<Type> types = const [KitchenSendMeta, _$KitchenSendMeta];

  @override
  final String wireName = r'KitchenSendMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenSendMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tickets';
    yield serializers.serialize(
      object.tickets,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
    );
    yield r'ticket_count';
    yield serializers.serialize(
      object.ticketCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenSendMeta object, {
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
    required KitchenSendMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tickets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
          ) as BuiltList<KitchenTicket>;
          result.tickets.replace(valueDes);
          break;
        case r'ticket_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ticketCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenSendMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenSendMetaBuilder();
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
