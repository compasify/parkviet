//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_order_served_result_data.g.dart';

/// KitchenOrderServedResultData
///
/// Properties:
/// * [workspaceId]
/// * [tickets]
@BuiltValue()
abstract class KitchenOrderServedResultData
    implements
        Built<KitchenOrderServedResultData,
            KitchenOrderServedResultDataBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'tickets')
  BuiltList<KitchenTicket> get tickets;

  KitchenOrderServedResultData._();

  factory KitchenOrderServedResultData(
          [void updates(KitchenOrderServedResultDataBuilder b)]) =
      _$KitchenOrderServedResultData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenOrderServedResultDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenOrderServedResultData> get serializer =>
      _$KitchenOrderServedResultDataSerializer();
}

class _$KitchenOrderServedResultDataSerializer
    implements PrimitiveSerializer<KitchenOrderServedResultData> {
  @override
  final Iterable<Type> types = const [
    KitchenOrderServedResultData,
    _$KitchenOrderServedResultData
  ];

  @override
  final String wireName = r'KitchenOrderServedResultData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenOrderServedResultData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'tickets';
    yield serializers.serialize(
      object.tickets,
      specifiedType: const FullType(BuiltList, [FullType(KitchenTicket)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenOrderServedResultData object, {
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
    required KitchenOrderServedResultDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
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
  KitchenOrderServedResultData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenOrderServedResultDataBuilder();
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
