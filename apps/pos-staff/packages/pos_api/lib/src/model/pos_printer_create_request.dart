//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_create_request.g.dart';

/// PosPrinterCreateRequest
///
/// Properties:
/// * [branchId]
/// * [name]
/// * [connection]
/// * [address] - Host or IP with an optional port; no scheme or path.
/// * [bluetoothId]
/// * [paper]
/// * [commandLanguage]
/// * [roles]
/// * [printStationDeviceId]
/// * [registerId]
/// * [status]
/// * [settings]
@BuiltValue()
abstract class PosPrinterCreateRequest
    implements Built<PosPrinterCreateRequest, PosPrinterCreateRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'connection')
  PosPrinterCreateRequestConnectionEnum get connection;
  // enum connectionEnum {  escpos_lan,  escpos_bluetooth,  sunmi_builtin,  epson_epos,  star_webprnt,  browser,  };

  /// Host or IP with an optional port; no scheme or path.
  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'bluetooth_id')
  String? get bluetoothId;

  @BuiltValueField(wireName: r'paper')
  PosPrinterCreateRequestPaperEnum? get paper;
  // enum paperEnum {  58mm,  80mm,  };

  @BuiltValueField(wireName: r'command_language')
  PosPrinterCreateRequestCommandLanguageEnum? get commandLanguage;
  // enum commandLanguageEnum {  escpos,  tspl,  };

  @BuiltValueField(wireName: r'roles')
  BuiltList<String>? get roles;

  @BuiltValueField(wireName: r'print_station_device_id')
  String? get printStationDeviceId;

  @BuiltValueField(wireName: r'register_id')
  String? get registerId;

  @BuiltValueField(wireName: r'status')
  PosPrinterCreateRequestStatusEnum? get status;
  // enum statusEnum {  active,  disabled,  };

  @BuiltValueField(wireName: r'settings')
  JsonObject? get settings;

  PosPrinterCreateRequest._();

  factory PosPrinterCreateRequest(
          [void updates(PosPrinterCreateRequestBuilder b)]) =
      _$PosPrinterCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterCreateRequest> get serializer =>
      _$PosPrinterCreateRequestSerializer();
}

class _$PosPrinterCreateRequestSerializer
    implements PrimitiveSerializer<PosPrinterCreateRequest> {
  @override
  final Iterable<Type> types = const [
    PosPrinterCreateRequest,
    _$PosPrinterCreateRequest
  ];

  @override
  final String wireName = r'PosPrinterCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
      specifiedType: const FullType(PosPrinterCreateRequestConnectionEnum),
    );
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.bluetoothId != null) {
      yield r'bluetooth_id';
      yield serializers.serialize(
        object.bluetoothId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.paper != null) {
      yield r'paper';
      yield serializers.serialize(
        object.paper,
        specifiedType: const FullType(PosPrinterCreateRequestPaperEnum),
      );
    }
    if (object.commandLanguage != null) {
      yield r'command_language';
      yield serializers.serialize(
        object.commandLanguage,
        specifiedType:
            const FullType(PosPrinterCreateRequestCommandLanguageEnum),
      );
    }
    if (object.roles != null) {
      yield r'roles';
      yield serializers.serialize(
        object.roles,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.printStationDeviceId != null) {
      yield r'print_station_device_id';
      yield serializers.serialize(
        object.printStationDeviceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.registerId != null) {
      yield r'register_id';
      yield serializers.serialize(
        object.registerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(PosPrinterCreateRequestStatusEnum),
      );
    }
    if (object.settings != null) {
      yield r'settings';
      yield serializers.serialize(
        object.settings,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterCreateRequest object, {
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
    required PosPrinterCreateRequestBuilder result,
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
            specifiedType:
                const FullType(PosPrinterCreateRequestConnectionEnum),
          ) as PosPrinterCreateRequestConnectionEnum;
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
            specifiedType:
                const FullType.nullable(PosPrinterCreateRequestPaperEnum),
          ) as PosPrinterCreateRequestPaperEnum?;
          if (valueDes == null) continue;
          result.paper = valueDes;
          break;
        case r'command_language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PosPrinterCreateRequestCommandLanguageEnum),
          ) as PosPrinterCreateRequestCommandLanguageEnum?;
          if (valueDes == null) continue;
          result.commandLanguage = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
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
            specifiedType:
                const FullType.nullable(PosPrinterCreateRequestStatusEnum),
          ) as PosPrinterCreateRequestStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
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
  PosPrinterCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterCreateRequestBuilder();
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

class PosPrinterCreateRequestConnectionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'escpos_lan')
  static const PosPrinterCreateRequestConnectionEnum escposLan =
      _$posPrinterCreateRequestConnectionEnum_escposLan;
  @BuiltValueEnumConst(wireName: r'escpos_bluetooth')
  static const PosPrinterCreateRequestConnectionEnum escposBluetooth =
      _$posPrinterCreateRequestConnectionEnum_escposBluetooth;
  @BuiltValueEnumConst(wireName: r'sunmi_builtin')
  static const PosPrinterCreateRequestConnectionEnum sunmiBuiltin =
      _$posPrinterCreateRequestConnectionEnum_sunmiBuiltin;
  @BuiltValueEnumConst(wireName: r'epson_epos')
  static const PosPrinterCreateRequestConnectionEnum epsonEpos =
      _$posPrinterCreateRequestConnectionEnum_epsonEpos;
  @BuiltValueEnumConst(wireName: r'star_webprnt')
  static const PosPrinterCreateRequestConnectionEnum starWebprnt =
      _$posPrinterCreateRequestConnectionEnum_starWebprnt;
  @BuiltValueEnumConst(wireName: r'browser')
  static const PosPrinterCreateRequestConnectionEnum browser =
      _$posPrinterCreateRequestConnectionEnum_browser;

  static Serializer<PosPrinterCreateRequestConnectionEnum> get serializer =>
      _$posPrinterCreateRequestConnectionEnumSerializer;

  const PosPrinterCreateRequestConnectionEnum._(String name) : super(name);

  static BuiltSet<PosPrinterCreateRequestConnectionEnum> get values =>
      _$posPrinterCreateRequestConnectionEnumValues;
  static PosPrinterCreateRequestConnectionEnum valueOf(String name) =>
      _$posPrinterCreateRequestConnectionEnumValueOf(name);
}

class PosPrinterCreateRequestPaperEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'58mm')
  static const PosPrinterCreateRequestPaperEnum n58mm =
      _$posPrinterCreateRequestPaperEnum_n58mm;
  @BuiltValueEnumConst(wireName: r'80mm')
  static const PosPrinterCreateRequestPaperEnum n80mm =
      _$posPrinterCreateRequestPaperEnum_n80mm;

  static Serializer<PosPrinterCreateRequestPaperEnum> get serializer =>
      _$posPrinterCreateRequestPaperEnumSerializer;

  const PosPrinterCreateRequestPaperEnum._(String name) : super(name);

  static BuiltSet<PosPrinterCreateRequestPaperEnum> get values =>
      _$posPrinterCreateRequestPaperEnumValues;
  static PosPrinterCreateRequestPaperEnum valueOf(String name) =>
      _$posPrinterCreateRequestPaperEnumValueOf(name);
}

class PosPrinterCreateRequestCommandLanguageEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'escpos')
  static const PosPrinterCreateRequestCommandLanguageEnum escpos =
      _$posPrinterCreateRequestCommandLanguageEnum_escpos;
  @BuiltValueEnumConst(wireName: r'tspl')
  static const PosPrinterCreateRequestCommandLanguageEnum tspl =
      _$posPrinterCreateRequestCommandLanguageEnum_tspl;

  static Serializer<PosPrinterCreateRequestCommandLanguageEnum>
      get serializer => _$posPrinterCreateRequestCommandLanguageEnumSerializer;

  const PosPrinterCreateRequestCommandLanguageEnum._(String name) : super(name);

  static BuiltSet<PosPrinterCreateRequestCommandLanguageEnum> get values =>
      _$posPrinterCreateRequestCommandLanguageEnumValues;
  static PosPrinterCreateRequestCommandLanguageEnum valueOf(String name) =>
      _$posPrinterCreateRequestCommandLanguageEnumValueOf(name);
}

class PosPrinterCreateRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const PosPrinterCreateRequestStatusEnum active =
      _$posPrinterCreateRequestStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const PosPrinterCreateRequestStatusEnum disabled =
      _$posPrinterCreateRequestStatusEnum_disabled;

  static Serializer<PosPrinterCreateRequestStatusEnum> get serializer =>
      _$posPrinterCreateRequestStatusEnumSerializer;

  const PosPrinterCreateRequestStatusEnum._(String name) : super(name);

  static BuiltSet<PosPrinterCreateRequestStatusEnum> get values =>
      _$posPrinterCreateRequestStatusEnumValues;
  static PosPrinterCreateRequestStatusEnum valueOf(String name) =>
      _$posPrinterCreateRequestStatusEnumValueOf(name);
}
