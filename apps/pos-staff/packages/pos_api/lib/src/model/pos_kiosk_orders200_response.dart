//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kiosk_handoff_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kiosk_orders200_response.g.dart';

/// PosKioskOrders200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKioskOrders200Response
    implements
        Built<PosKioskOrders200Response, PosKioskOrders200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<KioskHandoffOrder> get data;

  PosKioskOrders200Response._();

  factory PosKioskOrders200Response(
          [void updates(PosKioskOrders200ResponseBuilder b)]) =
      _$PosKioskOrders200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKioskOrders200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKioskOrders200Response> get serializer =>
      _$PosKioskOrders200ResponseSerializer();
}

class _$PosKioskOrders200ResponseSerializer
    implements PrimitiveSerializer<PosKioskOrders200Response> {
  @override
  final Iterable<Type> types = const [
    PosKioskOrders200Response,
    _$PosKioskOrders200Response
  ];

  @override
  final String wireName = r'PosKioskOrders200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKioskOrders200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(KioskHandoffOrder)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKioskOrders200Response object, {
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
    required PosKioskOrders200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KioskHandoffOrder)]),
          ) as BuiltList<KioskHandoffOrder>;
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
  PosKioskOrders200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKioskOrders200ResponseBuilder();
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
