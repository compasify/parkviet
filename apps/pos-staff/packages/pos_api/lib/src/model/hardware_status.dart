//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/hardware_device.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/hardware_station.dart';
import 'package:pos_api/src/model/hardware_displays.dart';
import 'package:pos_api/src/model/hardware_printer.dart';
import 'package:pos_api/src/model/hardware_einvoice.dart';
import 'package:pos_api/src/model/hardware_check.dart';
import 'package:pos_api/src/model/hardware_server.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_status.g.dart';

/// HardwareStatus
///
/// Properties:
/// * [branchId]
/// * [generatedAt]
/// * [checks]
/// * [printers]
/// * [stations]
/// * [devices]
/// * [customerDisplays]
/// * [server]
/// * [einvoice]
@BuiltValue()
abstract class HardwareStatus
    implements Built<HardwareStatus, HardwareStatusBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'generated_at')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'checks')
  BuiltList<HardwareCheck> get checks;

  @BuiltValueField(wireName: r'printers')
  BuiltList<HardwarePrinter> get printers;

  @BuiltValueField(wireName: r'stations')
  BuiltList<HardwareStation> get stations;

  @BuiltValueField(wireName: r'devices')
  BuiltList<HardwareDevice> get devices;

  @BuiltValueField(wireName: r'customer_displays')
  HardwareDisplays get customerDisplays;

  @BuiltValueField(wireName: r'server')
  HardwareServer get server;

  @BuiltValueField(wireName: r'einvoice')
  HardwareEinvoice get einvoice;

  HardwareStatus._();

  factory HardwareStatus([void updates(HardwareStatusBuilder b)]) =
      _$HardwareStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareStatus> get serializer =>
      _$HardwareStatusSerializer();
}

class _$HardwareStatusSerializer
    implements PrimitiveSerializer<HardwareStatus> {
  @override
  final Iterable<Type> types = const [HardwareStatus, _$HardwareStatus];

  @override
  final String wireName = r'HardwareStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'generated_at';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'checks';
    yield serializers.serialize(
      object.checks,
      specifiedType: const FullType(BuiltList, [FullType(HardwareCheck)]),
    );
    yield r'printers';
    yield serializers.serialize(
      object.printers,
      specifiedType: const FullType(BuiltList, [FullType(HardwarePrinter)]),
    );
    yield r'stations';
    yield serializers.serialize(
      object.stations,
      specifiedType: const FullType(BuiltList, [FullType(HardwareStation)]),
    );
    yield r'devices';
    yield serializers.serialize(
      object.devices,
      specifiedType: const FullType(BuiltList, [FullType(HardwareDevice)]),
    );
    yield r'customer_displays';
    yield serializers.serialize(
      object.customerDisplays,
      specifiedType: const FullType(HardwareDisplays),
    );
    yield r'server';
    yield serializers.serialize(
      object.server,
      specifiedType: const FullType(HardwareServer),
    );
    yield r'einvoice';
    yield serializers.serialize(
      object.einvoice,
      specifiedType: const FullType(HardwareEinvoice),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareStatus object, {
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
    required HardwareStatusBuilder result,
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
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'checks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(HardwareCheck)]),
          ) as BuiltList<HardwareCheck>;
          result.checks.replace(valueDes);
          break;
        case r'printers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(HardwarePrinter)]),
          ) as BuiltList<HardwarePrinter>;
          result.printers.replace(valueDes);
          break;
        case r'stations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(HardwareStation)]),
          ) as BuiltList<HardwareStation>;
          result.stations.replace(valueDes);
          break;
        case r'devices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(HardwareDevice)]),
          ) as BuiltList<HardwareDevice>;
          result.devices.replace(valueDes);
          break;
        case r'customer_displays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareDisplays),
          ) as HardwareDisplays;
          result.customerDisplays.replace(valueDes);
          break;
        case r'server':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareServer),
          ) as HardwareServer;
          result.server.replace(valueDes);
          break;
        case r'einvoice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareEinvoice),
          ) as HardwareEinvoice;
          result.einvoice.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareStatusBuilder();
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
