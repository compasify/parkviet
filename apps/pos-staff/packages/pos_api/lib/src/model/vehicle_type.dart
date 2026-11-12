//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_type.g.dart';

class VehicleType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'seat_16')
  static const VehicleType seat16 = _$seat16;
  @BuiltValueEnumConst(wireName: r'seat_29')
  static const VehicleType seat29 = _$seat29;
  @BuiltValueEnumConst(wireName: r'seat_45')
  static const VehicleType seat45 = _$seat45;
  @BuiltValueEnumConst(wireName: r'other')
  static const VehicleType other = _$other;

  static Serializer<VehicleType> get serializer => _$vehicleTypeSerializer;

  const VehicleType._(String name) : super(name);

  static BuiltSet<VehicleType> get values => _$values;
  static VehicleType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class VehicleTypeMixin = Object with _$VehicleTypeMixin;
