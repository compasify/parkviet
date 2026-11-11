//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_send201_response_meta.g.dart';

/// PosKitchenSend201ResponseMeta
///
/// Properties:
/// * [tickets]
@BuiltValue()
abstract class PosKitchenSend201ResponseMeta
    implements
        Built<PosKitchenSend201ResponseMeta,
            PosKitchenSend201ResponseMetaBuilder> {
  @BuiltValueField(wireName: r'tickets')
  BuiltList<KitchenTicket> get tickets;

  PosKitchenSend201ResponseMeta._();

  factory PosKitchenSend201ResponseMeta(
          [void updates(PosKitchenSend201ResponseMetaBuilder b)]) =
      _$PosKitchenSend201ResponseMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenSend201ResponseMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenSend201ResponseMeta> get serializer =>
      _$PosKitchenSend201ResponseMetaSerializer();
}

class _$PosKitchenSend201ResponseMetaSerializer
    implements PrimitiveSerializer<PosKitchenSend201ResponseMeta> {
  @override
  final Iterable<Type> types = const [
    PosKitchenSend201ResponseMeta,
    _$PosKitchenSend201ResponseMeta
  ];

  @override
  final String wireName = r'PosKitchenSend201ResponseMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenSend201ResponseMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tickets';
    yield serializers.serialize(
      object.tickets,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenSend201ResponseMeta object, {
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
    required PosKitchenSend201ResponseMetaBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosKitchenSend201ResponseMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenSend201ResponseMetaBuilder();
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
