//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/station_route.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_station_route_create201_response.g.dart';

/// PosStationRouteCreate201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosStationRouteCreate201Response
    implements
        Built<PosStationRouteCreate201Response,
            PosStationRouteCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StationRoute get data;

  PosStationRouteCreate201Response._();

  factory PosStationRouteCreate201Response(
          [void updates(PosStationRouteCreate201ResponseBuilder b)]) =
      _$PosStationRouteCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosStationRouteCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosStationRouteCreate201Response> get serializer =>
      _$PosStationRouteCreate201ResponseSerializer();
}

class _$PosStationRouteCreate201ResponseSerializer
    implements PrimitiveSerializer<PosStationRouteCreate201Response> {
  @override
  final Iterable<Type> types = const [
    PosStationRouteCreate201Response,
    _$PosStationRouteCreate201Response
  ];

  @override
  final String wireName = r'PosStationRouteCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosStationRouteCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(StationRoute),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosStationRouteCreate201Response object, {
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
    required PosStationRouteCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StationRoute),
          ) as StationRoute;
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
  PosStationRouteCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosStationRouteCreate201ResponseBuilder();
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
