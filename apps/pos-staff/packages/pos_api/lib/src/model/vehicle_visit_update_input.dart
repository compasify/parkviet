//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/vehicle_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_update_input.g.dart';

/// VehicleVisitUpdateInput
///
/// Properties:
/// * [expectedRevision]
/// * [plate]
/// * [vehicleType]
/// * [busOperatorId]
/// * [driverName]
/// * [driverPhone]
/// * [guestCount]
/// * [note]
@BuiltValue()
abstract class VehicleVisitUpdateInput
    implements Built<VehicleVisitUpdateInput, VehicleVisitUpdateInputBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'plate')
  String? get plate;

  @BuiltValueField(wireName: r'vehicle_type')
  VehicleType? get vehicleType;
  // enum vehicleTypeEnum {  seat_16,  seat_29,  seat_45,  other,  };

  @BuiltValueField(wireName: r'bus_operator_id')
  String? get busOperatorId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'driver_phone')
  String? get driverPhone;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  @BuiltValueField(wireName: r'note')
  String? get note;

  VehicleVisitUpdateInput._();

  factory VehicleVisitUpdateInput(
          [void updates(VehicleVisitUpdateInputBuilder b)]) =
      _$VehicleVisitUpdateInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitUpdateInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitUpdateInput> get serializer =>
      _$VehicleVisitUpdateInputSerializer();
}

class _$VehicleVisitUpdateInputSerializer
    implements PrimitiveSerializer<VehicleVisitUpdateInput> {
  @override
  final Iterable<Type> types = const [
    VehicleVisitUpdateInput,
    _$VehicleVisitUpdateInput
  ];

  @override
  final String wireName = r'VehicleVisitUpdateInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitUpdateInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_revision';
    yield serializers.serialize(
      object.expectedRevision,
      specifiedType: const FullType(int),
    );
    if (object.plate != null) {
      yield r'plate';
      yield serializers.serialize(
        object.plate,
        specifiedType: const FullType(String),
      );
    }
    if (object.vehicleType != null) {
      yield r'vehicle_type';
      yield serializers.serialize(
        object.vehicleType,
        specifiedType: const FullType(VehicleType),
      );
    }
    if (object.busOperatorId != null) {
      yield r'bus_operator_id';
      yield serializers.serialize(
        object.busOperatorId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverPhone != null) {
      yield r'driver_phone';
      yield serializers.serialize(
        object.driverPhone,
        specifiedType: const FullType(String),
      );
    }
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisitUpdateInput object, {
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
    required VehicleVisitUpdateInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedRevision = valueDes;
          break;
        case r'plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plate = valueDes;
          break;
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(VehicleType),
          ) as VehicleType?;
          if (valueDes == null) continue;
          result.vehicleType = valueDes;
          break;
        case r'bus_operator_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.busOperatorId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'driver_phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverPhone = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleVisitUpdateInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitUpdateInputBuilder();
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
