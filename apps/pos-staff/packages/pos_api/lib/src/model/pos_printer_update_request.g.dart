// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnum_escposLan =
    const PosPrinterUpdateRequestConnectionEnum._('escposLan');
const PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnum_escposBluetooth =
    const PosPrinterUpdateRequestConnectionEnum._('escposBluetooth');
const PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnum_sunmiBuiltin =
    const PosPrinterUpdateRequestConnectionEnum._('sunmiBuiltin');
const PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnum_epsonEpos =
    const PosPrinterUpdateRequestConnectionEnum._('epsonEpos');
const PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnum_starWebprnt =
    const PosPrinterUpdateRequestConnectionEnum._('starWebprnt');
const PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnum_browser =
    const PosPrinterUpdateRequestConnectionEnum._('browser');

PosPrinterUpdateRequestConnectionEnum
    _$posPrinterUpdateRequestConnectionEnumValueOf(String name) {
  switch (name) {
    case 'escposLan':
      return _$posPrinterUpdateRequestConnectionEnum_escposLan;
    case 'escposBluetooth':
      return _$posPrinterUpdateRequestConnectionEnum_escposBluetooth;
    case 'sunmiBuiltin':
      return _$posPrinterUpdateRequestConnectionEnum_sunmiBuiltin;
    case 'epsonEpos':
      return _$posPrinterUpdateRequestConnectionEnum_epsonEpos;
    case 'starWebprnt':
      return _$posPrinterUpdateRequestConnectionEnum_starWebprnt;
    case 'browser':
      return _$posPrinterUpdateRequestConnectionEnum_browser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterUpdateRequestConnectionEnum>
    _$posPrinterUpdateRequestConnectionEnumValues = BuiltSet<
        PosPrinterUpdateRequestConnectionEnum>(const <PosPrinterUpdateRequestConnectionEnum>[
  _$posPrinterUpdateRequestConnectionEnum_escposLan,
  _$posPrinterUpdateRequestConnectionEnum_escposBluetooth,
  _$posPrinterUpdateRequestConnectionEnum_sunmiBuiltin,
  _$posPrinterUpdateRequestConnectionEnum_epsonEpos,
  _$posPrinterUpdateRequestConnectionEnum_starWebprnt,
  _$posPrinterUpdateRequestConnectionEnum_browser,
]);

const PosPrinterUpdateRequestPaperEnum
    _$posPrinterUpdateRequestPaperEnum_n58mm =
    const PosPrinterUpdateRequestPaperEnum._('n58mm');
const PosPrinterUpdateRequestPaperEnum
    _$posPrinterUpdateRequestPaperEnum_n80mm =
    const PosPrinterUpdateRequestPaperEnum._('n80mm');

PosPrinterUpdateRequestPaperEnum _$posPrinterUpdateRequestPaperEnumValueOf(
    String name) {
  switch (name) {
    case 'n58mm':
      return _$posPrinterUpdateRequestPaperEnum_n58mm;
    case 'n80mm':
      return _$posPrinterUpdateRequestPaperEnum_n80mm;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterUpdateRequestPaperEnum>
    _$posPrinterUpdateRequestPaperEnumValues = BuiltSet<
        PosPrinterUpdateRequestPaperEnum>(const <PosPrinterUpdateRequestPaperEnum>[
  _$posPrinterUpdateRequestPaperEnum_n58mm,
  _$posPrinterUpdateRequestPaperEnum_n80mm,
]);

const PosPrinterUpdateRequestCommandLanguageEnum
    _$posPrinterUpdateRequestCommandLanguageEnum_escpos =
    const PosPrinterUpdateRequestCommandLanguageEnum._('escpos');
const PosPrinterUpdateRequestCommandLanguageEnum
    _$posPrinterUpdateRequestCommandLanguageEnum_tspl =
    const PosPrinterUpdateRequestCommandLanguageEnum._('tspl');

PosPrinterUpdateRequestCommandLanguageEnum
    _$posPrinterUpdateRequestCommandLanguageEnumValueOf(String name) {
  switch (name) {
    case 'escpos':
      return _$posPrinterUpdateRequestCommandLanguageEnum_escpos;
    case 'tspl':
      return _$posPrinterUpdateRequestCommandLanguageEnum_tspl;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterUpdateRequestCommandLanguageEnum>
    _$posPrinterUpdateRequestCommandLanguageEnumValues = BuiltSet<
        PosPrinterUpdateRequestCommandLanguageEnum>(const <PosPrinterUpdateRequestCommandLanguageEnum>[
  _$posPrinterUpdateRequestCommandLanguageEnum_escpos,
  _$posPrinterUpdateRequestCommandLanguageEnum_tspl,
]);

const PosPrinterUpdateRequestStatusEnum
    _$posPrinterUpdateRequestStatusEnum_active =
    const PosPrinterUpdateRequestStatusEnum._('active');
const PosPrinterUpdateRequestStatusEnum
    _$posPrinterUpdateRequestStatusEnum_disabled =
    const PosPrinterUpdateRequestStatusEnum._('disabled');

PosPrinterUpdateRequestStatusEnum _$posPrinterUpdateRequestStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'active':
      return _$posPrinterUpdateRequestStatusEnum_active;
    case 'disabled':
      return _$posPrinterUpdateRequestStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterUpdateRequestStatusEnum>
    _$posPrinterUpdateRequestStatusEnumValues = BuiltSet<
        PosPrinterUpdateRequestStatusEnum>(const <PosPrinterUpdateRequestStatusEnum>[
  _$posPrinterUpdateRequestStatusEnum_active,
  _$posPrinterUpdateRequestStatusEnum_disabled,
]);

Serializer<PosPrinterUpdateRequestConnectionEnum>
    _$posPrinterUpdateRequestConnectionEnumSerializer =
    _$PosPrinterUpdateRequestConnectionEnumSerializer();
Serializer<PosPrinterUpdateRequestPaperEnum>
    _$posPrinterUpdateRequestPaperEnumSerializer =
    _$PosPrinterUpdateRequestPaperEnumSerializer();
Serializer<PosPrinterUpdateRequestCommandLanguageEnum>
    _$posPrinterUpdateRequestCommandLanguageEnumSerializer =
    _$PosPrinterUpdateRequestCommandLanguageEnumSerializer();
Serializer<PosPrinterUpdateRequestStatusEnum>
    _$posPrinterUpdateRequestStatusEnumSerializer =
    _$PosPrinterUpdateRequestStatusEnumSerializer();

class _$PosPrinterUpdateRequestConnectionEnumSerializer
    implements PrimitiveSerializer<PosPrinterUpdateRequestConnectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'escposLan': 'escpos_lan',
    'escposBluetooth': 'escpos_bluetooth',
    'sunmiBuiltin': 'sunmi_builtin',
    'epsonEpos': 'epson_epos',
    'starWebprnt': 'star_webprnt',
    'browser': 'browser',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'escpos_lan': 'escposLan',
    'escpos_bluetooth': 'escposBluetooth',
    'sunmi_builtin': 'sunmiBuiltin',
    'epson_epos': 'epsonEpos',
    'star_webprnt': 'starWebprnt',
    'browser': 'browser',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosPrinterUpdateRequestConnectionEnum
  ];
  @override
  final String wireName = 'PosPrinterUpdateRequestConnectionEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrinterUpdateRequestConnectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterUpdateRequestConnectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterUpdateRequestConnectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterUpdateRequestPaperEnumSerializer
    implements PrimitiveSerializer<PosPrinterUpdateRequestPaperEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n58mm': '58mm',
    'n80mm': '80mm',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '58mm': 'n58mm',
    '80mm': 'n80mm',
  };

  @override
  final Iterable<Type> types = const <Type>[PosPrinterUpdateRequestPaperEnum];
  @override
  final String wireName = 'PosPrinterUpdateRequestPaperEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrinterUpdateRequestPaperEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterUpdateRequestPaperEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterUpdateRequestPaperEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterUpdateRequestCommandLanguageEnumSerializer
    implements PrimitiveSerializer<PosPrinterUpdateRequestCommandLanguageEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'escpos': 'escpos',
    'tspl': 'tspl',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'escpos': 'escpos',
    'tspl': 'tspl',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosPrinterUpdateRequestCommandLanguageEnum
  ];
  @override
  final String wireName = 'PosPrinterUpdateRequestCommandLanguageEnum';

  @override
  Object serialize(Serializers serializers,
          PosPrinterUpdateRequestCommandLanguageEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterUpdateRequestCommandLanguageEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterUpdateRequestCommandLanguageEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterUpdateRequestStatusEnumSerializer
    implements PrimitiveSerializer<PosPrinterUpdateRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[PosPrinterUpdateRequestStatusEnum];
  @override
  final String wireName = 'PosPrinterUpdateRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrinterUpdateRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterUpdateRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterUpdateRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterUpdateRequest extends PosPrinterUpdateRequest {
  @override
  final String? name;
  @override
  final PosPrinterUpdateRequestConnectionEnum? connection;
  @override
  final String? address;
  @override
  final String? bluetoothId;
  @override
  final PosPrinterUpdateRequestPaperEnum? paper;
  @override
  final PosPrinterUpdateRequestCommandLanguageEnum? commandLanguage;
  @override
  final BuiltList<String>? roles;
  @override
  final String? printStationDeviceId;
  @override
  final String? registerId;
  @override
  final PosPrinterUpdateRequestStatusEnum? status;
  @override
  final JsonObject? settings;

  factory _$PosPrinterUpdateRequest(
          [void Function(PosPrinterUpdateRequestBuilder)? updates]) =>
      (PosPrinterUpdateRequestBuilder()..update(updates))._build();

  _$PosPrinterUpdateRequest._(
      {this.name,
      this.connection,
      this.address,
      this.bluetoothId,
      this.paper,
      this.commandLanguage,
      this.roles,
      this.printStationDeviceId,
      this.registerId,
      this.status,
      this.settings})
      : super._();
  @override
  PosPrinterUpdateRequest rebuild(
          void Function(PosPrinterUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterUpdateRequestBuilder toBuilder() =>
      PosPrinterUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterUpdateRequest &&
        name == other.name &&
        connection == other.connection &&
        address == other.address &&
        bluetoothId == other.bluetoothId &&
        paper == other.paper &&
        commandLanguage == other.commandLanguage &&
        roles == other.roles &&
        printStationDeviceId == other.printStationDeviceId &&
        registerId == other.registerId &&
        status == other.status &&
        settings == other.settings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, connection.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, bluetoothId.hashCode);
    _$hash = $jc(_$hash, paper.hashCode);
    _$hash = $jc(_$hash, commandLanguage.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jc(_$hash, printStationDeviceId.hashCode);
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosPrinterUpdateRequest')
          ..add('name', name)
          ..add('connection', connection)
          ..add('address', address)
          ..add('bluetoothId', bluetoothId)
          ..add('paper', paper)
          ..add('commandLanguage', commandLanguage)
          ..add('roles', roles)
          ..add('printStationDeviceId', printStationDeviceId)
          ..add('registerId', registerId)
          ..add('status', status)
          ..add('settings', settings))
        .toString();
  }
}

class PosPrinterUpdateRequestBuilder
    implements
        Builder<PosPrinterUpdateRequest, PosPrinterUpdateRequestBuilder> {
  _$PosPrinterUpdateRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PosPrinterUpdateRequestConnectionEnum? _connection;
  PosPrinterUpdateRequestConnectionEnum? get connection => _$this._connection;
  set connection(PosPrinterUpdateRequestConnectionEnum? connection) =>
      _$this._connection = connection;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _bluetoothId;
  String? get bluetoothId => _$this._bluetoothId;
  set bluetoothId(String? bluetoothId) => _$this._bluetoothId = bluetoothId;

  PosPrinterUpdateRequestPaperEnum? _paper;
  PosPrinterUpdateRequestPaperEnum? get paper => _$this._paper;
  set paper(PosPrinterUpdateRequestPaperEnum? paper) => _$this._paper = paper;

  PosPrinterUpdateRequestCommandLanguageEnum? _commandLanguage;
  PosPrinterUpdateRequestCommandLanguageEnum? get commandLanguage =>
      _$this._commandLanguage;
  set commandLanguage(
          PosPrinterUpdateRequestCommandLanguageEnum? commandLanguage) =>
      _$this._commandLanguage = commandLanguage;

  ListBuilder<String>? _roles;
  ListBuilder<String> get roles => _$this._roles ??= ListBuilder<String>();
  set roles(ListBuilder<String>? roles) => _$this._roles = roles;

  String? _printStationDeviceId;
  String? get printStationDeviceId => _$this._printStationDeviceId;
  set printStationDeviceId(String? printStationDeviceId) =>
      _$this._printStationDeviceId = printStationDeviceId;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  PosPrinterUpdateRequestStatusEnum? _status;
  PosPrinterUpdateRequestStatusEnum? get status => _$this._status;
  set status(PosPrinterUpdateRequestStatusEnum? status) =>
      _$this._status = status;

  JsonObject? _settings;
  JsonObject? get settings => _$this._settings;
  set settings(JsonObject? settings) => _$this._settings = settings;

  PosPrinterUpdateRequestBuilder() {
    PosPrinterUpdateRequest._defaults(this);
  }

  PosPrinterUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _connection = $v.connection;
      _address = $v.address;
      _bluetoothId = $v.bluetoothId;
      _paper = $v.paper;
      _commandLanguage = $v.commandLanguage;
      _roles = $v.roles?.toBuilder();
      _printStationDeviceId = $v.printStationDeviceId;
      _registerId = $v.registerId;
      _status = $v.status;
      _settings = $v.settings;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterUpdateRequest other) {
    _$v = other as _$PosPrinterUpdateRequest;
  }

  @override
  void update(void Function(PosPrinterUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterUpdateRequest build() => _build();

  _$PosPrinterUpdateRequest _build() {
    _$PosPrinterUpdateRequest _$result;
    try {
      _$result = _$v ??
          _$PosPrinterUpdateRequest._(
            name: name,
            connection: connection,
            address: address,
            bluetoothId: bluetoothId,
            paper: paper,
            commandLanguage: commandLanguage,
            roles: _roles?.build(),
            printStationDeviceId: printStationDeviceId,
            registerId: registerId,
            status: status,
            settings: settings,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        _roles?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinterUpdateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
