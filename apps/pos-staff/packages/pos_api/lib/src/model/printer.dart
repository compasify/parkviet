//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'printer.g.dart';

/// Printer
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [name]
/// * [connection]
/// * [address]
/// * [bluetoothId]
/// * [paper]
/// * [commandLanguage]
/// * [roles]
/// * [printStationDeviceId]
/// * [registerId]
/// * [status]
/// * [settings]
@BuiltValue()
abstract class Printer implements Built<Printer, PrinterBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'connection')
  PrinterConnectionEnum get connection;
  // enum connectionEnum {  escpos_lan,  escpos_bluetooth,  sunmi_builtin,  epson_epos,  star_webprnt,  browser,  };

  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'bluetooth_id')
  String? get bluetoothId;

  @BuiltValueField(wireName: r'paper')
  PrinterPaperEnum get paper;
  // enum paperEnum {  58mm,  80mm,  };

  @BuiltValueField(wireName: r'command_language')
  PrinterCommandLanguageEnum get commandLanguage;
  // enum commandLanguageEnum {  escpos,  tspl,  };

  @BuiltValueField(wireName: r'roles')
  BuiltList<PrinterRolesEnum> get roles;
  // enum rolesEnum {  receipt,  prebill,  kitchen_ticket,  void_ticket,  cup_label,  checklist,  table_qr,  };

  @BuiltValueField(wireName: r'print_station_device_id')
  String? get printStationDeviceId;

  @BuiltValueField(wireName: r'register_id')
  String? get registerId;

  @BuiltValueField(wireName: r'status')
  PrinterStatusEnum get status;
  // enum statusEnum {  active,  disabled,  };

  @BuiltValueField(wireName: r'settings')
  JsonObject get settings;

  Printer._();

  factory Printer([void updates(PrinterBuilder b)]) = _$Printer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrinterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Printer> get serializer => _$PrinterSerializer();
}

class _$PrinterSerializer implements PrimitiveSerializer<Printer> {
  @override
  final Iterable<Type> types = const [Printer, _$Printer];

  @override
  final String wireName = r'Printer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Printer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'connection';
    yield serializers.serialize(
      object.connection,
      specifiedType: const FullType(PrinterConnectionEnum),
    );
    yield r'address';
    yield object.address == null
        ? null
        : serializers.serialize(
            object.address,
            specifiedType: const FullType.nullable(String),
          );
    yield r'bluetooth_id';
    yield object.bluetoothId == null
        ? null
        : serializers.serialize(
            object.bluetoothId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'paper';
    yield serializers.serialize(
      object.paper,
      specifiedType: const FullType(PrinterPaperEnum),
    );
    yield r'command_language';
    yield serializers.serialize(
      object.commandLanguage,
      specifiedType: const FullType(PrinterCommandLanguageEnum),
    );
    yield r'roles';
    yield serializers.serialize(
      object.roles,
      specifiedType: const FullType(BuiltList, [FullType(PrinterRolesEnum)]),
    );
    yield r'print_station_device_id';
    yield object.printStationDeviceId == null
        ? null
        : serializers.serialize(
            object.printStationDeviceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'register_id';
    yield object.registerId == null
        ? null
        : serializers.serialize(
            object.registerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PrinterStatusEnum),
    );
    yield r'settings';
    yield serializers.serialize(
      object.settings,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Printer object, {
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
    required PrinterBuilder result,
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
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'connection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrinterConnectionEnum),
          ) as PrinterConnectionEnum;
          result.connection = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address = valueDes;
          break;
        case r'bluetooth_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bluetoothId = valueDes;
          break;
        case r'paper':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrinterPaperEnum),
          ) as PrinterPaperEnum;
          result.paper = valueDes;
          break;
        case r'command_language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrinterCommandLanguageEnum),
          ) as PrinterCommandLanguageEnum;
          result.commandLanguage = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(PrinterRolesEnum)]),
          ) as BuiltList<PrinterRolesEnum>;
          result.roles.replace(valueDes);
          break;
        case r'print_station_device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printStationDeviceId = valueDes;
          break;
        case r'register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.registerId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrinterStatusEnum),
          ) as PrinterStatusEnum;
          result.status = valueDes;
          break;
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.settings = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Printer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrinterBuilder();
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

class PrinterConnectionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'escpos_lan')
  static const PrinterConnectionEnum escposLan =
      _$printerConnectionEnum_escposLan;
  @BuiltValueEnumConst(wireName: r'escpos_bluetooth')
  static const PrinterConnectionEnum escposBluetooth =
      _$printerConnectionEnum_escposBluetooth;
  @BuiltValueEnumConst(wireName: r'sunmi_builtin')
  static const PrinterConnectionEnum sunmiBuiltin =
      _$printerConnectionEnum_sunmiBuiltin;
  @BuiltValueEnumConst(wireName: r'epson_epos')
  static const PrinterConnectionEnum epsonEpos =
      _$printerConnectionEnum_epsonEpos;
  @BuiltValueEnumConst(wireName: r'star_webprnt')
  static const PrinterConnectionEnum starWebprnt =
      _$printerConnectionEnum_starWebprnt;
  @BuiltValueEnumConst(wireName: r'browser')
  static const PrinterConnectionEnum browser = _$printerConnectionEnum_browser;

  static Serializer<PrinterConnectionEnum> get serializer =>
      _$printerConnectionEnumSerializer;

  const PrinterConnectionEnum._(String name) : super(name);

  static BuiltSet<PrinterConnectionEnum> get values =>
      _$printerConnectionEnumValues;
  static PrinterConnectionEnum valueOf(String name) =>
      _$printerConnectionEnumValueOf(name);
}

class PrinterPaperEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'58mm')
  static const PrinterPaperEnum n58mm = _$printerPaperEnum_n58mm;
  @BuiltValueEnumConst(wireName: r'80mm')
  static const PrinterPaperEnum n80mm = _$printerPaperEnum_n80mm;

  static Serializer<PrinterPaperEnum> get serializer =>
      _$printerPaperEnumSerializer;

  const PrinterPaperEnum._(String name) : super(name);

  static BuiltSet<PrinterPaperEnum> get values => _$printerPaperEnumValues;
  static PrinterPaperEnum valueOf(String name) =>
      _$printerPaperEnumValueOf(name);
}

class PrinterCommandLanguageEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'escpos')
  static const PrinterCommandLanguageEnum escpos =
      _$printerCommandLanguageEnum_escpos;
  @BuiltValueEnumConst(wireName: r'tspl')
  static const PrinterCommandLanguageEnum tspl =
      _$printerCommandLanguageEnum_tspl;

  static Serializer<PrinterCommandLanguageEnum> get serializer =>
      _$printerCommandLanguageEnumSerializer;

  const PrinterCommandLanguageEnum._(String name) : super(name);

  static BuiltSet<PrinterCommandLanguageEnum> get values =>
      _$printerCommandLanguageEnumValues;
  static PrinterCommandLanguageEnum valueOf(String name) =>
      _$printerCommandLanguageEnumValueOf(name);
}

class PrinterRolesEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'receipt')
  static const PrinterRolesEnum receipt = _$printerRolesEnum_receipt;
  @BuiltValueEnumConst(wireName: r'prebill')
  static const PrinterRolesEnum prebill = _$printerRolesEnum_prebill;
  @BuiltValueEnumConst(wireName: r'kitchen_ticket')
  static const PrinterRolesEnum kitchenTicket =
      _$printerRolesEnum_kitchenTicket;
  @BuiltValueEnumConst(wireName: r'void_ticket')
  static const PrinterRolesEnum voidTicket = _$printerRolesEnum_voidTicket;
  @BuiltValueEnumConst(wireName: r'cup_label')
  static const PrinterRolesEnum cupLabel = _$printerRolesEnum_cupLabel;
  @BuiltValueEnumConst(wireName: r'checklist')
  static const PrinterRolesEnum checklist = _$printerRolesEnum_checklist;
  @BuiltValueEnumConst(wireName: r'table_qr')
  static const PrinterRolesEnum tableQr = _$printerRolesEnum_tableQr;

  static Serializer<PrinterRolesEnum> get serializer =>
      _$printerRolesEnumSerializer;

  const PrinterRolesEnum._(String name) : super(name);

  static BuiltSet<PrinterRolesEnum> get values => _$printerRolesEnumValues;
  static PrinterRolesEnum valueOf(String name) =>
      _$printerRolesEnumValueOf(name);
}

class PrinterStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const PrinterStatusEnum active = _$printerStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const PrinterStatusEnum disabled = _$printerStatusEnum_disabled;

  static Serializer<PrinterStatusEnum> get serializer =>
      _$printerStatusEnumSerializer;

  const PrinterStatusEnum._(String name) : super(name);

  static BuiltSet<PrinterStatusEnum> get values => _$printerStatusEnumValues;
  static PrinterStatusEnum valueOf(String name) =>
      _$printerStatusEnumValueOf(name);
}
