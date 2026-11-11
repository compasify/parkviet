//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/stock_alert.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_stock_alerts200_response.g.dart';

/// PosStockAlerts200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosStockAlerts200Response
    implements
        Built<PosStockAlerts200Response, PosStockAlerts200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<StockAlert> get data;

  PosStockAlerts200Response._();

  factory PosStockAlerts200Response(
          [void updates(PosStockAlerts200ResponseBuilder b)]) =
      _$PosStockAlerts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosStockAlerts200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosStockAlerts200Response> get serializer =>
      _$PosStockAlerts200ResponseSerializer();
}

class _$PosStockAlerts200ResponseSerializer
    implements PrimitiveSerializer<PosStockAlerts200Response> {
  @override
  final Iterable<Type> types = const [
    PosStockAlerts200Response,
    _$PosStockAlerts200Response
  ];

  @override
  final String wireName = r'PosStockAlerts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosStockAlerts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(StockAlert)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosStockAlerts200Response object, {
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
    required PosStockAlerts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StockAlert)]),
          ) as BuiltList<StockAlert>;
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
  PosStockAlerts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosStockAlerts200ResponseBuilder();
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
