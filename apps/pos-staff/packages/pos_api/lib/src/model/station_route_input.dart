//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'station_route_input.g.dart';

/// StationRouteInput
///
/// Properties:
/// * [kitchenStationId]
/// * [productId]
/// * [kitchenCategory]
/// * [serviceMode]
@BuiltValue(instantiable: false)
abstract class StationRouteInput {
  @BuiltValueField(wireName: r'kitchen_station_id')
  String? get kitchenStationId;

  @BuiltValueField(wireName: r'product_id')
  String? get productId;

  @BuiltValueField(wireName: r'kitchen_category')
  String? get kitchenCategory;

  @BuiltValueField(wireName: r'service_mode')
  String? get serviceMode;

  @BuiltValueSerializer(custom: true)
  static Serializer<StationRouteInput> get serializer =>
      _$StationRouteInputSerializer();
}

class _$StationRouteInputSerializer
    implements PrimitiveSerializer<StationRouteInput> {
  @override
  final Iterable<Type> types = const [StationRouteInput];

  @override
  final String wireName = r'StationRouteInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StationRouteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    StationRouteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  @override
  StationRouteInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized,
        specifiedType: FullType($StationRouteInput)) as $StationRouteInput;
  }
}

/// a concrete implementation of [StationRouteInput], since [StationRouteInput] is not instantiable
@BuiltValue(instantiable: true)
abstract class $StationRouteInput
    implements
        StationRouteInput,
        Built<$StationRouteInput, $StationRouteInputBuilder> {
  $StationRouteInput._();

  factory $StationRouteInput(
          [void Function($StationRouteInputBuilder)? updates]) =
      _$$StationRouteInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($StationRouteInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$StationRouteInput> get serializer =>
      _$$StationRouteInputSerializer();
}

class _$$StationRouteInputSerializer
    implements PrimitiveSerializer<$StationRouteInput> {
  @override
  final Iterable<Type> types = const [$StationRouteInput, _$$StationRouteInput];

  @override
  final String wireName = r'$StationRouteInput';

  @override
  Object serialize(
    Serializers serializers,
    $StationRouteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object,
        specifiedType: FullType(StationRouteInput))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StationRouteInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  $StationRouteInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $StationRouteInputBuilder();
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
