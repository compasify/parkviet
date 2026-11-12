// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VehicleType _$seat16 = const VehicleType._('seat16');
const VehicleType _$seat29 = const VehicleType._('seat29');
const VehicleType _$seat45 = const VehicleType._('seat45');
const VehicleType _$other = const VehicleType._('other');

VehicleType _$valueOf(String name) {
  switch (name) {
    case 'seat16':
      return _$seat16;
    case 'seat29':
      return _$seat29;
    case 'seat45':
      return _$seat45;
    case 'other':
      return _$other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleType> _$values =
    BuiltSet<VehicleType>(const <VehicleType>[
  _$seat16,
  _$seat29,
  _$seat45,
  _$other,
]);

class _$VehicleTypeMeta {
  const _$VehicleTypeMeta();
  VehicleType get seat16 => _$seat16;
  VehicleType get seat29 => _$seat29;
  VehicleType get seat45 => _$seat45;
  VehicleType get other => _$other;
  VehicleType valueOf(String name) => _$valueOf(name);
  BuiltSet<VehicleType> get values => _$values;
}

abstract class _$VehicleTypeMixin {
  // ignore: non_constant_identifier_names
  _$VehicleTypeMeta get VehicleType => const _$VehicleTypeMeta();
}

Serializer<VehicleType> _$vehicleTypeSerializer = _$VehicleTypeSerializer();

class _$VehicleTypeSerializer implements PrimitiveSerializer<VehicleType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'seat16': 'seat_16',
    'seat29': 'seat_29',
    'seat45': 'seat_45',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'seat_16': 'seat16',
    'seat_29': 'seat29',
    'seat_45': 'seat45',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[VehicleType];
  @override
  final String wireName = 'VehicleType';

  @override
  Object serialize(Serializers serializers, VehicleType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VehicleType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VehicleType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
