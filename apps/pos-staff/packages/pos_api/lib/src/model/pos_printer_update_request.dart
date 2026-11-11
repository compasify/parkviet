//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_update_request.g.dart';

/// PosPrinterUpdateRequest
///
/// Properties:
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
abstract class PosPrinterUpdateRequest
    implements Built<PosPrinterUpdateRequest, PosPrinterUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'connection')
  PosPrinterUpdateRequestConnectionEnum? get connection;
  // enum connectionEnum {  escpos_lan,  escpos_bluetooth,  sunmi_builtin,  epson_epos,  star_webprnt,  browser,  };

  /// Host or IP with an optional port; no scheme or path.
  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'bluetooth_id')
  String? get bluetoothId;

  @BuiltValueField(wireName: r'paper')
  PosPrinterUpdateRequestPaperEnum? get paper;
  // enum paperEnum {  58mm,  80mm,  };

  @BuiltValueField(wireName: r'command_language')
  PosPrinterUpdateRequestCommandLanguageEnum? get commandLanguage;
  // enum commandLanguageEnum {  escpos,  tspl,  };

  @BuiltValueField(wireName: r'roles')
  BuiltList<String>? get roles;

  @BuiltValueField(wireName: r'print_station_device_id')
  String? get printStationDeviceId;

  @BuiltValueField(wireName: r'register_id')
  String? get registerId;

  @BuiltValueField(wireName: r'status')
  PosPrinterUpdateRequestStatusEnum? get status;
  // enum statusEnum {  active,  disabled,  };

  @BuiltValueField(wireName: r'settings')
  JsonObject? get settings;

  PosPrinterUpdateRequest._();

  factory PosPrinterUpdateRequest(
          [void updates(PosPrinterUpdateRequestBuilder b)]) =
      _$PosPrinterUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterUpdateRequest> get serializer =>
      _$PosPrinterUpdateRequestSerializer();
}

class _$PosPrinterUpdateRequestSerializer
    implements PrimitiveSerializer<PosPrinterUpdateRequest> {
  @override
  final Iterable<Type> types = const [
    PosPrinterUpdateRequest,
    _$PosPrinterUpdateRequest
  ];

  @override
  final String wireName = r'PosPrinterUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.connection != null) {
      yield r'connection';
      yield serializers.serialize(
        object.connection,
        specifiedType: const FullType(PosPrinterUpdateRequestConnectionEnum),
      );
    }
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
        specifiedType: const FullType(PosPrinterUpdateRequestPaperEnum),
      );
    }
    if (object.commandLanguage != null) {
      yield r'command_language';
      yield serializers.serialize(
        object.commandLanguage,
        specifiedType:
            const FullType(PosPrinterUpdateRequestCommandLanguageEnum),
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
        specifiedType: const FullType(PosPrinterUpdateRequestStatusEnum),
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
    PosPrinterUpdateRequest object, {
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
    required PosPrinterUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'connection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(PosPrinterUpdateRequestConnectionEnum),
          ) as PosPrinterUpdateRequestConnectionEnum?;
          if (valueDes == null) continue;
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
                const FullType.nullable(PosPrinterUpdateRequestPaperEnum),
          ) as PosPrinterUpdateRequestPaperEnum?;
          if (valueDes == null) continue;
          result.paper = valueDes;
          break;
        case r'command_language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PosPrinterUpdateRequestCommandLanguageEnum),
          ) as PosPrinterUpdateRequestCommandLanguageEnum?;
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
                const FullType.nullable(PosPrinterUpdateRequestStatusEnum),
          ) as PosPrinterUpdateRequestStatusEnum?;
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
  PosPrinterUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterUpdateRequestBuilder();
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

class PosPrinterUpdateRequestConnectionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'escpos_lan')
  static const PosPrinterUpdateRequestConnectionEnum escposLan =
      _$posPrinterUpdateRequestConnectionEnum_escposLan;
  @BuiltValueEnumConst(wireName: r'escpos_bluetooth')
  static const PosPrinterUpdateRequestConnectionEnum escposBluetooth =
      _$posPrinterUpdateRequestConnectionEnum_escposBluetooth;
  @BuiltValueEnumConst(wireName: r'sunmi_builtin')
  static const PosPrinterUpdateRequestConnectionEnum sunmiBuiltin =
      _$posPrinterUpdateRequestConnectionEnum_sunmiBuiltin;
  @BuiltValueEnumConst(wireName: r'epson_epos')
  static const PosPrinterUpdateRequestConnectionEnum epsonEpos =
      _$posPrinterUpdateRequestConnectionEnum_epsonEpos;
  @BuiltValueEnumConst(wireName: r'star_webprnt')
  static const PosPrinterUpdateRequestConnectionEnum starWebprnt =
      _$posPrinterUpdateRequestConnectionEnum_starWebprnt;
  @BuiltValueEnumConst(wireName: r'browser')
  static const PosPrinterUpdateRequestConnectionEnum browser =
      _$posPrinterUpdateRequestConnectionEnum_browser;

  static Serializer<PosPrinterUpdateRequestConnectionEnum> get serializer =>
      _$posPrinterUpdateRequestConnectionEnumSerializer;

  const PosPrinterUpdateRequestConnectionEnum._(String name) : super(name);

  static BuiltSet<PosPrinterUpdateRequestConnectionEnum> get values =>
      _$posPrinterUpdateRequestConnectionEnumValues;
  static PosPrinterUpdateRequestConnectionEnum valueOf(String name) =>
      _$posPrinterUpdateRequestConnectionEnumValueOf(name);
}

class PosPrinterUpdateRequestPaperEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'58mm')
  static const PosPrinterUpdateRequestPaperEnum n58mm =
      _$posPrinterUpdateRequestPaperEnum_n58mm;
  @BuiltValueEnumConst(wireName: r'80mm')
  static const PosPrinterUpdateRequestPaperEnum n80mm =
      _$posPrinterUpdateRequestPaperEnum_n80mm;

  static Serializer<PosPrinterUpdateRequestPaperEnum> get serializer =>
      _$posPrinterUpdateRequestPaperEnumSerializer;

  const PosPrinterUpdateRequestPaperEnum._(String name) : super(name);

  static BuiltSet<PosPrinterUpdateRequestPaperEnum> get values =>
      _$posPrinterUpdateRequestPaperEnumValues;
  static PosPrinterUpdateRequestPaperEnum valueOf(String name) =>
      _$posPrinterUpdateRequestPaperEnumValueOf(name);
}

class PosPrinterUpdateRequestCommandLanguageEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'escpos')
  static const PosPrinterUpdateRequestCommandLanguageEnum escpos =
      _$posPrinterUpdateRequestCommandLanguageEnum_escpos;
  @BuiltValueEnumConst(wireName: r'tspl')
  static const PosPrinterUpdateRequestCommandLanguageEnum tspl =
      _$posPrinterUpdateRequestCommandLanguageEnum_tspl;

  static Serializer<PosPrinterUpdateRequestCommandLanguageEnum>
      get serializer => _$posPrinterUpdateRequestCommandLanguageEnumSerializer;

  const PosPrinterUpdateRequestCommandLanguageEnum._(String name) : super(name);

  static BuiltSet<PosPrinterUpdateRequestCommandLanguageEnum> get values =>
      _$posPrinterUpdateRequestCommandLanguageEnumValues;
  static PosPrinterUpdateRequestCommandLanguageEnum valueOf(String name) =>
      _$posPrinterUpdateRequestCommandLanguageEnumValueOf(name);
}

class PosPrinterUpdateRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const PosPrinterUpdateRequestStatusEnum active =
      _$posPrinterUpdateRequestStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const PosPrinterUpdateRequestStatusEnum disabled =
      _$posPrinterUpdateRequestStatusEnum_disabled;

  static Serializer<PosPrinterUpdateRequestStatusEnum> get serializer =>
      _$posPrinterUpdateRequestStatusEnumSerializer;

  const PosPrinterUpdateRequestStatusEnum._(String name) : super(name);

  static BuiltSet<PosPrinterUpdateRequestStatusEnum> get values =>
      _$posPrinterUpdateRequestStatusEnumValues;
  static PosPrinterUpdateRequestStatusEnum valueOf(String name) =>
      _$posPrinterUpdateRequestStatusEnumValueOf(name);
}
