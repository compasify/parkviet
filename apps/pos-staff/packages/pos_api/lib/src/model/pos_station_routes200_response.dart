//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/station_route.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_station_routes200_response.g.dart';

/// PosStationRoutes200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosStationRoutes200Response
    implements
        Built<PosStationRoutes200Response, PosStationRoutes200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<StationRoute> get data;

  PosStationRoutes200Response._();

  factory PosStationRoutes200Response(
          [void updates(PosStationRoutes200ResponseBuilder b)]) =
      _$PosStationRoutes200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosStationRoutes200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosStationRoutes200Response> get serializer =>
      _$PosStationRoutes200ResponseSerializer();
}

class _$PosStationRoutes200ResponseSerializer
    implements PrimitiveSerializer<PosStationRoutes200Response> {
  @override
  final Iterable<Type> types = const [
    PosStationRoutes200Response,
    _$PosStationRoutes200Response
  ];

  @override
  final String wireName = r'PosStationRoutes200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosStationRoutes200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(StationRoute)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosStationRoutes200Response object, {
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
    required PosStationRoutes200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StationRoute)]),
          ) as BuiltList<StationRoute>;
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
  PosStationRoutes200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosStationRoutes200ResponseBuilder();
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
