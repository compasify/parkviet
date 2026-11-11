//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'station_route.g.dart';

/// StationRoute
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [kitchenStationId]
/// * [productId]
/// * [productName]
/// * [kitchenCategory]
/// * [serviceMode] - Null for every service mode.
@BuiltValue()
abstract class StationRoute
    implements Built<StationRoute, StationRouteBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'kitchen_station_id')
  String get kitchenStationId;

  @BuiltValueField(wireName: r'product_id')
  String? get productId;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'kitchen_category')
  String? get kitchenCategory;

  /// Null for every service mode.
  @BuiltValueField(wireName: r'service_mode')
  String? get serviceMode;

  StationRoute._();

  factory StationRoute([void updates(StationRouteBuilder b)]) = _$StationRoute;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StationRouteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StationRoute> get serializer => _$StationRouteSerializer();
}

class _$StationRouteSerializer implements PrimitiveSerializer<StationRoute> {
  @override
  final Iterable<Type> types = const [StationRoute, _$StationRoute];

  @override
  final String wireName = r'StationRoute';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StationRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'kitchen_station_id';
    yield serializers.serialize(
      object.kitchenStationId,
      specifiedType: const FullType(String),
    );
    yield r'product_id';
    yield object.productId == null
        ? null
        : serializers.serialize(
            object.productId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'product_name';
    yield object.productName == null
        ? null
        : serializers.serialize(
            object.productName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kitchen_category';
    yield object.kitchenCategory == null
        ? null
        : serializers.serialize(
            object.kitchenCategory,
            specifiedType: const FullType.nullable(String),
          );
    yield r'service_mode';
    yield object.serviceMode == null
        ? null
        : serializers.serialize(
            object.serviceMode,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    StationRoute object, {
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
    required StationRouteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
            specifiedType: const FullType(String),
          ) as String;
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
        case r'product_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
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
  StationRoute deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StationRouteBuilder();
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
