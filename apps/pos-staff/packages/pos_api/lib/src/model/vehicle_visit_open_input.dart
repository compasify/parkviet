//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/vehicle_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_open_input.g.dart';

/// VehicleVisitOpenInput
///
/// Properties:
/// * [branchId]
/// * [plate]
/// * [vehicleType]
/// * [busOperatorId]
/// * [driverName]
/// * [driverPhone]
/// * [guestCount]
/// * [note]
@BuiltValue()
abstract class VehicleVisitOpenInput
    implements Built<VehicleVisitOpenInput, VehicleVisitOpenInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'plate')
  String get plate;

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

  VehicleVisitOpenInput._();

  factory VehicleVisitOpenInput(
      [void updates(VehicleVisitOpenInputBuilder b)]) = _$VehicleVisitOpenInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitOpenInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitOpenInput> get serializer =>
      _$VehicleVisitOpenInputSerializer();
}

class _$VehicleVisitOpenInputSerializer
    implements PrimitiveSerializer<VehicleVisitOpenInput> {
  @override
  final Iterable<Type> types = const [
    VehicleVisitOpenInput,
    _$VehicleVisitOpenInput
  ];

  @override
  final String wireName = r'VehicleVisitOpenInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitOpenInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'plate';
    yield serializers.serialize(
      object.plate,
      specifiedType: const FullType(String),
    );
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
    VehicleVisitOpenInput object, {
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
    required VehicleVisitOpenInputBuilder result,
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
        case r'plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  VehicleVisitOpenInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitOpenInputBuilder();
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
