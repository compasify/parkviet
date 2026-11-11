//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_ticket_result.g.dart';

/// KitchenTicketResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenTicketResult
    implements Built<KitchenTicketResult, KitchenTicketResultBuilder> {
  @BuiltValueField(wireName: r'data')
  KitchenTicket get data;

  KitchenTicketResult._();

  factory KitchenTicketResult([void updates(KitchenTicketResultBuilder b)]) =
      _$KitchenTicketResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenTicketResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenTicketResult> get serializer =>
      _$KitchenTicketResultSerializer();
}

class _$KitchenTicketResultSerializer
    implements PrimitiveSerializer<KitchenTicketResult> {
  @override
  final Iterable<Type> types = const [
    KitchenTicketResult,
    _$KitchenTicketResult
  ];

  @override
  final String wireName = r'KitchenTicketResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenTicketResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KitchenTicket),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenTicketResult object, {
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
    required KitchenTicketResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenTicket),
          ) as KitchenTicket;
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
  KitchenTicketResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenTicketResultBuilder();
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
