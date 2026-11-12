//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/vehicle_visit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_result.g.dart';

/// VehicleVisitResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class VehicleVisitResult
    implements Built<VehicleVisitResult, VehicleVisitResultBuilder> {
  @BuiltValueField(wireName: r'data')
  VehicleVisit get data;

  VehicleVisitResult._();

  factory VehicleVisitResult([void updates(VehicleVisitResultBuilder b)]) =
      _$VehicleVisitResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitResult> get serializer =>
      _$VehicleVisitResultSerializer();
}

class _$VehicleVisitResultSerializer
    implements PrimitiveSerializer<VehicleVisitResult> {
  @override
  final Iterable<Type> types = const [VehicleVisitResult, _$VehicleVisitResult];

  @override
  final String wireName = r'VehicleVisitResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(VehicleVisit),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisitResult object, {
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
    required VehicleVisitResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VehicleVisit),
          ) as VehicleVisit;
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
  VehicleVisitResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitResultBuilder();
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
