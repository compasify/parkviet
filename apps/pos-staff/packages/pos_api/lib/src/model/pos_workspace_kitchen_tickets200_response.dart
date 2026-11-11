//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_kitchen_tickets200_response.g.dart';

/// PosWorkspaceKitchenTickets200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosWorkspaceKitchenTickets200Response
    implements
        Built<PosWorkspaceKitchenTickets200Response,
            PosWorkspaceKitchenTickets200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<KitchenTicket> get data;

  PosWorkspaceKitchenTickets200Response._();

  factory PosWorkspaceKitchenTickets200Response(
          [void updates(PosWorkspaceKitchenTickets200ResponseBuilder b)]) =
      _$PosWorkspaceKitchenTickets200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceKitchenTickets200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceKitchenTickets200Response> get serializer =>
      _$PosWorkspaceKitchenTickets200ResponseSerializer();
}

class _$PosWorkspaceKitchenTickets200ResponseSerializer
    implements PrimitiveSerializer<PosWorkspaceKitchenTickets200Response> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceKitchenTickets200Response,
    _$PosWorkspaceKitchenTickets200Response
  ];

  @override
  final String wireName = r'PosWorkspaceKitchenTickets200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceKitchenTickets200Response object, {
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
    PosWorkspaceKitchenTickets200Response object, {
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
    required PosWorkspaceKitchenTickets200ResponseBuilder result,
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
  PosWorkspaceKitchenTickets200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceKitchenTickets200ResponseBuilder();
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
