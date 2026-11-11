//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/call_board.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_orders200_response.g.dart';

/// PosKitchenOrders200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKitchenOrders200Response
    implements
        Built<PosKitchenOrders200Response, PosKitchenOrders200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  CallBoard get data;

  PosKitchenOrders200Response._();

  factory PosKitchenOrders200Response(
          [void updates(PosKitchenOrders200ResponseBuilder b)]) =
      _$PosKitchenOrders200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenOrders200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenOrders200Response> get serializer =>
      _$PosKitchenOrders200ResponseSerializer();
}

class _$PosKitchenOrders200ResponseSerializer
    implements PrimitiveSerializer<PosKitchenOrders200Response> {
  @override
  final Iterable<Type> types = const [
    PosKitchenOrders200Response,
    _$PosKitchenOrders200Response
  ];

  @override
  final String wireName = r'PosKitchenOrders200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenOrders200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CallBoard),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenOrders200Response object, {
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
    required PosKitchenOrders200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CallBoard),
          ) as CallBoard;
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
  PosKitchenOrders200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenOrders200ResponseBuilder();
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
