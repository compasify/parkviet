//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_printer_stations200_response_data_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_stations200_response.g.dart';

/// PosPrinterStations200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrinterStations200Response
    implements
        Built<PosPrinterStations200Response,
            PosPrinterStations200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PosPrinterStations200ResponseDataInner> get data;

  PosPrinterStations200Response._();

  factory PosPrinterStations200Response(
          [void updates(PosPrinterStations200ResponseBuilder b)]) =
      _$PosPrinterStations200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterStations200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterStations200Response> get serializer =>
      _$PosPrinterStations200ResponseSerializer();
}

class _$PosPrinterStations200ResponseSerializer
    implements PrimitiveSerializer<PosPrinterStations200Response> {
  @override
  final Iterable<Type> types = const [
    PosPrinterStations200Response,
    _$PosPrinterStations200Response
  ];

  @override
  final String wireName = r'PosPrinterStations200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterStations200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(
          BuiltList, [FullType(PosPrinterStations200ResponseDataInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterStations200Response object, {
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
    required PosPrinterStations200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PosPrinterStations200ResponseDataInner)]),
          ) as BuiltList<PosPrinterStations200ResponseDataInner>;
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
  PosPrinterStations200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterStations200ResponseBuilder();
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
