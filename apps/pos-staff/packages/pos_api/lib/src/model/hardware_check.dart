//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_check.g.dart';

/// HardwareCheck
///
/// Properties:
/// * [key]
/// * [status] - `not_needed` when the branch does not use it (module or feature off, no printer behind a print station, no e-invoices).
@BuiltValue()
abstract class HardwareCheck
    implements Built<HardwareCheck, HardwareCheckBuilder> {
  @BuiltValueField(wireName: r'key')
  HardwareCheckKeyEnum get key;
  // enum keyEnum {  receipt_printer,  kitchen_printer,  cup_label_printer,  kitchen_stations,  print_station,  customer_display,  server,  einvoice,  };

  /// `not_needed` when the branch does not use it (module or feature off, no printer behind a print station, no e-invoices).
  @BuiltValueField(wireName: r'status')
  HardwareCheckStatusEnum get status;
  // enum statusEnum {  ok,  attention,  not_needed,  };

  HardwareCheck._();

  factory HardwareCheck([void updates(HardwareCheckBuilder b)]) =
      _$HardwareCheck;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareCheckBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareCheck> get serializer =>
      _$HardwareCheckSerializer();
}

class _$HardwareCheckSerializer implements PrimitiveSerializer<HardwareCheck> {
  @override
  final Iterable<Type> types = const [HardwareCheck, _$HardwareCheck];

  @override
  final String wireName = r'HardwareCheck';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareCheck object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(HardwareCheckKeyEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HardwareCheckStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareCheck object, {
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
    required HardwareCheckBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareCheckKeyEnum),
          ) as HardwareCheckKeyEnum;
          result.key = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareCheckStatusEnum),
          ) as HardwareCheckStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareCheck deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareCheckBuilder();
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

class HardwareCheckKeyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'receipt_printer')
  static const HardwareCheckKeyEnum receiptPrinter =
      _$hardwareCheckKeyEnum_receiptPrinter;
  @BuiltValueEnumConst(wireName: r'kitchen_printer')
  static const HardwareCheckKeyEnum kitchenPrinter =
      _$hardwareCheckKeyEnum_kitchenPrinter;
  @BuiltValueEnumConst(wireName: r'cup_label_printer')
  static const HardwareCheckKeyEnum cupLabelPrinter =
      _$hardwareCheckKeyEnum_cupLabelPrinter;
  @BuiltValueEnumConst(wireName: r'kitchen_stations')
  static const HardwareCheckKeyEnum kitchenStations =
      _$hardwareCheckKeyEnum_kitchenStations;
  @BuiltValueEnumConst(wireName: r'print_station')
  static const HardwareCheckKeyEnum printStation =
      _$hardwareCheckKeyEnum_printStation;
  @BuiltValueEnumConst(wireName: r'customer_display')
  static const HardwareCheckKeyEnum customerDisplay =
      _$hardwareCheckKeyEnum_customerDisplay;
  @BuiltValueEnumConst(wireName: r'server')
  static const HardwareCheckKeyEnum server = _$hardwareCheckKeyEnum_server;
  @BuiltValueEnumConst(wireName: r'einvoice')
  static const HardwareCheckKeyEnum einvoice = _$hardwareCheckKeyEnum_einvoice;

  static Serializer<HardwareCheckKeyEnum> get serializer =>
      _$hardwareCheckKeyEnumSerializer;

  const HardwareCheckKeyEnum._(String name) : super(name);

  static BuiltSet<HardwareCheckKeyEnum> get values =>
      _$hardwareCheckKeyEnumValues;
  static HardwareCheckKeyEnum valueOf(String name) =>
      _$hardwareCheckKeyEnumValueOf(name);
}

/// `not_needed` when the branch does not use it (module or feature off, no printer behind a print station, no e-invoices).
class HardwareCheckStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ok')
  static const HardwareCheckStatusEnum ok = _$hardwareCheckStatusEnum_ok;
  @BuiltValueEnumConst(wireName: r'attention')
  static const HardwareCheckStatusEnum attention =
      _$hardwareCheckStatusEnum_attention;
  @BuiltValueEnumConst(wireName: r'not_needed')
  static const HardwareCheckStatusEnum notNeeded =
      _$hardwareCheckStatusEnum_notNeeded;

  static Serializer<HardwareCheckStatusEnum> get serializer =>
      _$hardwareCheckStatusEnumSerializer;

  const HardwareCheckStatusEnum._(String name) : super(name);

  static BuiltSet<HardwareCheckStatusEnum> get values =>
      _$hardwareCheckStatusEnumValues;
  static HardwareCheckStatusEnum valueOf(String name) =>
      _$hardwareCheckStatusEnumValueOf(name);
}
