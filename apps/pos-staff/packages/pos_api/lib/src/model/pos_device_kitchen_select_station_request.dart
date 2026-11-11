//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_kitchen_select_station_request.g.dart';

/// PosDeviceKitchenSelectStationRequest
///
/// Properties:
/// * [stationId]
@BuiltValue()
abstract class PosDeviceKitchenSelectStationRequest
    implements
        Built<PosDeviceKitchenSelectStationRequest,
            PosDeviceKitchenSelectStationRequestBuilder> {
  @BuiltValueField(wireName: r'station_id')
  String? get stationId;

  PosDeviceKitchenSelectStationRequest._();

  factory PosDeviceKitchenSelectStationRequest(
          [void updates(PosDeviceKitchenSelectStationRequestBuilder b)]) =
      _$PosDeviceKitchenSelectStationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceKitchenSelectStationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceKitchenSelectStationRequest> get serializer =>
      _$PosDeviceKitchenSelectStationRequestSerializer();
}

class _$PosDeviceKitchenSelectStationRequestSerializer
    implements PrimitiveSerializer<PosDeviceKitchenSelectStationRequest> {
  @override
  final Iterable<Type> types = const [
    PosDeviceKitchenSelectStationRequest,
    _$PosDeviceKitchenSelectStationRequest
  ];

  @override
  final String wireName = r'PosDeviceKitchenSelectStationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceKitchenSelectStationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.stationId != null) {
      yield r'station_id';
      yield serializers.serialize(
        object.stationId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceKitchenSelectStationRequest object, {
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
    required PosDeviceKitchenSelectStationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.stationId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosDeviceKitchenSelectStationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceKitchenSelectStationRequestBuilder();
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
