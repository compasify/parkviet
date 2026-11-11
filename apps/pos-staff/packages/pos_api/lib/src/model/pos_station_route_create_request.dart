//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/station_route_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_station_route_create_request.g.dart';

/// PosStationRouteCreateRequest
///
/// Properties:
/// * [kitchenStationId]
/// * [productId]
/// * [kitchenCategory]
/// * [serviceMode]
/// * [branchId]
@BuiltValue()
abstract class PosStationRouteCreateRequest
    implements
        StationRouteInput,
        Built<PosStationRouteCreateRequest,
            PosStationRouteCreateRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  PosStationRouteCreateRequest._();

  factory PosStationRouteCreateRequest(
          [void updates(PosStationRouteCreateRequestBuilder b)]) =
      _$PosStationRouteCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosStationRouteCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosStationRouteCreateRequest> get serializer =>
      _$PosStationRouteCreateRequestSerializer();
}

class _$PosStationRouteCreateRequestSerializer
    implements PrimitiveSerializer<PosStationRouteCreateRequest> {
  @override
  final Iterable<Type> types = const [
    PosStationRouteCreateRequest,
    _$PosStationRouteCreateRequest
  ];

  @override
  final String wireName = r'PosStationRouteCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosStationRouteCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.kitchenStationId != null) {
      yield r'kitchen_station_id';
      yield serializers.serialize(
        object.kitchenStationId,
        specifiedType: const FullType(String),
      );
    }
    if (object.productId != null) {
      yield r'product_id';
      yield serializers.serialize(
        object.productId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.kitchenCategory != null) {
      yield r'kitchen_category';
      yield serializers.serialize(
        object.kitchenCategory,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.serviceMode != null) {
      yield r'service_mode';
      yield serializers.serialize(
        object.serviceMode,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosStationRouteCreateRequest object, {
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
    required PosStationRouteCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'kitchen_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenStationId = valueDes;
          break;
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.productId = valueDes;
          break;
        case r'kitchen_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenCategory = valueDes;
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceMode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosStationRouteCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosStationRouteCreateRequestBuilder();
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
