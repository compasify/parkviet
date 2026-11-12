//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/vehicle_visit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_list.g.dart';

/// VehicleVisitList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class VehicleVisitList
    implements Built<VehicleVisitList, VehicleVisitListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<VehicleVisit> get data;

  VehicleVisitList._();

  factory VehicleVisitList([void updates(VehicleVisitListBuilder b)]) =
      _$VehicleVisitList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitList> get serializer =>
      _$VehicleVisitListSerializer();
}

class _$VehicleVisitListSerializer
    implements PrimitiveSerializer<VehicleVisitList> {
  @override
  final Iterable<Type> types = const [VehicleVisitList, _$VehicleVisitList];

  @override
  final String wireName = r'VehicleVisitList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(VehicleVisit)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisitList object, {
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
    required VehicleVisitListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(VehicleVisit)]),
          ) as BuiltList<VehicleVisit>;
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
  VehicleVisitList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitListBuilder();
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
