//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_station.g.dart';

/// HardwareStation
///
/// Properties:
/// * [id]
/// * [name]
/// * [kind]
/// * [printerId] - Its printer, when that printer is active.
/// * [kdsDevices] - Kitchen screens showing it (a screen with no station shows every station).
/// * [ok]
@BuiltValue()
abstract class HardwareStation
    implements Built<HardwareStation, HardwareStationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  HardwareStationKindEnum get kind;
  // enum kindEnum {  prep,  bar,  expo,  };

  /// Its printer, when that printer is active.
  @BuiltValueField(wireName: r'printer_id')
  String get printerId;

  /// Kitchen screens showing it (a screen with no station shows every station).
  @BuiltValueField(wireName: r'kds_devices')
  int get kdsDevices;

  @BuiltValueField(wireName: r'ok')
  bool get ok;

  HardwareStation._();

  factory HardwareStation([void updates(HardwareStationBuilder b)]) =
      _$HardwareStation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareStationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareStation> get serializer =>
      _$HardwareStationSerializer();
}

class _$HardwareStationSerializer
    implements PrimitiveSerializer<HardwareStation> {
  @override
  final Iterable<Type> types = const [HardwareStation, _$HardwareStation];

  @override
  final String wireName = r'HardwareStation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareStation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(HardwareStationKindEnum),
    );
    yield r'printer_id';
    yield serializers.serialize(
      object.printerId,
      specifiedType: const FullType(String),
    );
    yield r'kds_devices';
    yield serializers.serialize(
      object.kdsDevices,
      specifiedType: const FullType(int),
    );
    yield r'ok';
    yield serializers.serialize(
      object.ok,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareStation object, {
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
    required HardwareStationBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareStationKindEnum),
          ) as HardwareStationKindEnum;
          result.kind = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.printerId = valueDes;
          break;
        case r'kds_devices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.kdsDevices = valueDes;
          break;
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareStation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareStationBuilder();
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

class HardwareStationKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'prep')
  static const HardwareStationKindEnum prep = _$hardwareStationKindEnum_prep;
  @BuiltValueEnumConst(wireName: r'bar')
  static const HardwareStationKindEnum bar = _$hardwareStationKindEnum_bar;
  @BuiltValueEnumConst(wireName: r'expo')
  static const HardwareStationKindEnum expo = _$hardwareStationKindEnum_expo;

  static Serializer<HardwareStationKindEnum> get serializer =>
      _$hardwareStationKindEnumSerializer;

  const HardwareStationKindEnum._(String name) : super(name);

  static BuiltSet<HardwareStationKindEnum> get values =>
      _$hardwareStationKindEnumValues;
  static HardwareStationKindEnum valueOf(String name) =>
      _$hardwareStationKindEnumValueOf(name);
}
