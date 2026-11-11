// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnum_escposLan =
    const PosPrinterCreateRequestConnectionEnum._('escposLan');
const PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnum_escposBluetooth =
    const PosPrinterCreateRequestConnectionEnum._('escposBluetooth');
const PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnum_sunmiBuiltin =
    const PosPrinterCreateRequestConnectionEnum._('sunmiBuiltin');
const PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnum_epsonEpos =
    const PosPrinterCreateRequestConnectionEnum._('epsonEpos');
const PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnum_starWebprnt =
    const PosPrinterCreateRequestConnectionEnum._('starWebprnt');
const PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnum_browser =
    const PosPrinterCreateRequestConnectionEnum._('browser');

PosPrinterCreateRequestConnectionEnum
    _$posPrinterCreateRequestConnectionEnumValueOf(String name) {
  switch (name) {
    case 'escposLan':
      return _$posPrinterCreateRequestConnectionEnum_escposLan;
    case 'escposBluetooth':
      return _$posPrinterCreateRequestConnectionEnum_escposBluetooth;
    case 'sunmiBuiltin':
      return _$posPrinterCreateRequestConnectionEnum_sunmiBuiltin;
    case 'epsonEpos':
      return _$posPrinterCreateRequestConnectionEnum_epsonEpos;
    case 'starWebprnt':
      return _$posPrinterCreateRequestConnectionEnum_starWebprnt;
    case 'browser':
      return _$posPrinterCreateRequestConnectionEnum_browser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterCreateRequestConnectionEnum>
    _$posPrinterCreateRequestConnectionEnumValues = BuiltSet<
        PosPrinterCreateRequestConnectionEnum>(const <PosPrinterCreateRequestConnectionEnum>[
  _$posPrinterCreateRequestConnectionEnum_escposLan,
  _$posPrinterCreateRequestConnectionEnum_escposBluetooth,
  _$posPrinterCreateRequestConnectionEnum_sunmiBuiltin,
  _$posPrinterCreateRequestConnectionEnum_epsonEpos,
  _$posPrinterCreateRequestConnectionEnum_starWebprnt,
  _$posPrinterCreateRequestConnectionEnum_browser,
]);

const PosPrinterCreateRequestPaperEnum
    _$posPrinterCreateRequestPaperEnum_n58mm =
    const PosPrinterCreateRequestPaperEnum._('n58mm');
const PosPrinterCreateRequestPaperEnum
    _$posPrinterCreateRequestPaperEnum_n80mm =
    const PosPrinterCreateRequestPaperEnum._('n80mm');

PosPrinterCreateRequestPaperEnum _$posPrinterCreateRequestPaperEnumValueOf(
    String name) {
  switch (name) {
    case 'n58mm':
      return _$posPrinterCreateRequestPaperEnum_n58mm;
    case 'n80mm':
      return _$posPrinterCreateRequestPaperEnum_n80mm;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterCreateRequestPaperEnum>
    _$posPrinterCreateRequestPaperEnumValues = BuiltSet<
        PosPrinterCreateRequestPaperEnum>(const <PosPrinterCreateRequestPaperEnum>[
  _$posPrinterCreateRequestPaperEnum_n58mm,
  _$posPrinterCreateRequestPaperEnum_n80mm,
]);

const PosPrinterCreateRequestCommandLanguageEnum
    _$posPrinterCreateRequestCommandLanguageEnum_escpos =
    const PosPrinterCreateRequestCommandLanguageEnum._('escpos');
const PosPrinterCreateRequestCommandLanguageEnum
    _$posPrinterCreateRequestCommandLanguageEnum_tspl =
    const PosPrinterCreateRequestCommandLanguageEnum._('tspl');

PosPrinterCreateRequestCommandLanguageEnum
    _$posPrinterCreateRequestCommandLanguageEnumValueOf(String name) {
  switch (name) {
    case 'escpos':
      return _$posPrinterCreateRequestCommandLanguageEnum_escpos;
    case 'tspl':
      return _$posPrinterCreateRequestCommandLanguageEnum_tspl;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterCreateRequestCommandLanguageEnum>
    _$posPrinterCreateRequestCommandLanguageEnumValues = BuiltSet<
        PosPrinterCreateRequestCommandLanguageEnum>(const <PosPrinterCreateRequestCommandLanguageEnum>[
  _$posPrinterCreateRequestCommandLanguageEnum_escpos,
  _$posPrinterCreateRequestCommandLanguageEnum_tspl,
]);

const PosPrinterCreateRequestStatusEnum
    _$posPrinterCreateRequestStatusEnum_active =
    const PosPrinterCreateRequestStatusEnum._('active');
const PosPrinterCreateRequestStatusEnum
    _$posPrinterCreateRequestStatusEnum_disabled =
    const PosPrinterCreateRequestStatusEnum._('disabled');

PosPrinterCreateRequestStatusEnum _$posPrinterCreateRequestStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'active':
      return _$posPrinterCreateRequestStatusEnum_active;
    case 'disabled':
      return _$posPrinterCreateRequestStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrinterCreateRequestStatusEnum>
    _$posPrinterCreateRequestStatusEnumValues = BuiltSet<
        PosPrinterCreateRequestStatusEnum>(const <PosPrinterCreateRequestStatusEnum>[
  _$posPrinterCreateRequestStatusEnum_active,
  _$posPrinterCreateRequestStatusEnum_disabled,
]);

Serializer<PosPrinterCreateRequestConnectionEnum>
    _$posPrinterCreateRequestConnectionEnumSerializer =
    _$PosPrinterCreateRequestConnectionEnumSerializer();
Serializer<PosPrinterCreateRequestPaperEnum>
    _$posPrinterCreateRequestPaperEnumSerializer =
    _$PosPrinterCreateRequestPaperEnumSerializer();
Serializer<PosPrinterCreateRequestCommandLanguageEnum>
    _$posPrinterCreateRequestCommandLanguageEnumSerializer =
    _$PosPrinterCreateRequestCommandLanguageEnumSerializer();
Serializer<PosPrinterCreateRequestStatusEnum>
    _$posPrinterCreateRequestStatusEnumSerializer =
    _$PosPrinterCreateRequestStatusEnumSerializer();

class _$PosPrinterCreateRequestConnectionEnumSerializer
    implements PrimitiveSerializer<PosPrinterCreateRequestConnectionEnum> {
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
    PosPrinterCreateRequestConnectionEnum
  ];
  @override
  final String wireName = 'PosPrinterCreateRequestConnectionEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrinterCreateRequestConnectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterCreateRequestConnectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterCreateRequestConnectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterCreateRequestPaperEnumSerializer
    implements PrimitiveSerializer<PosPrinterCreateRequestPaperEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n58mm': '58mm',
    'n80mm': '80mm',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '58mm': 'n58mm',
    '80mm': 'n80mm',
  };

  @override
  final Iterable<Type> types = const <Type>[PosPrinterCreateRequestPaperEnum];
  @override
  final String wireName = 'PosPrinterCreateRequestPaperEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrinterCreateRequestPaperEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterCreateRequestPaperEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterCreateRequestPaperEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterCreateRequestCommandLanguageEnumSerializer
    implements PrimitiveSerializer<PosPrinterCreateRequestCommandLanguageEnum> {
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
    PosPrinterCreateRequestCommandLanguageEnum
  ];
  @override
  final String wireName = 'PosPrinterCreateRequestCommandLanguageEnum';

  @override
  Object serialize(Serializers serializers,
          PosPrinterCreateRequestCommandLanguageEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterCreateRequestCommandLanguageEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterCreateRequestCommandLanguageEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterCreateRequestStatusEnumSerializer
    implements PrimitiveSerializer<PosPrinterCreateRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[PosPrinterCreateRequestStatusEnum];
  @override
  final String wireName = 'PosPrinterCreateRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrinterCreateRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrinterCreateRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrinterCreateRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrinterCreateRequest extends PosPrinterCreateRequest {
  @override
  final String branchId;
  @override
  final String name;
  @override
  final PosPrinterCreateRequestConnectionEnum connection;
  @override
  final String? address;
  @override
  final String? bluetoothId;
  @override
  final PosPrinterCreateRequestPaperEnum? paper;
  @override
  final PosPrinterCreateRequestCommandLanguageEnum? commandLanguage;
  @override
  final BuiltList<String>? roles;
  @override
  final String? printStationDeviceId;
  @override
  final String? registerId;
  @override
  final PosPrinterCreateRequestStatusEnum? status;
  @override
  final JsonObject? settings;

  factory _$PosPrinterCreateRequest(
          [void Function(PosPrinterCreateRequestBuilder)? updates]) =>
      (PosPrinterCreateRequestBuilder()..update(updates))._build();

  _$PosPrinterCreateRequest._(
      {required this.branchId,
      required this.name,
      required this.connection,
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
  PosPrinterCreateRequest rebuild(
          void Function(PosPrinterCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterCreateRequestBuilder toBuilder() =>
      PosPrinterCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterCreateRequest &&
        branchId == other.branchId &&
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
    _$hash = $jc(_$hash, branchId.hashCode);
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
    return (newBuiltValueToStringHelper(r'PosPrinterCreateRequest')
          ..add('branchId', branchId)
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

class PosPrinterCreateRequestBuilder
    implements
        Builder<PosPrinterCreateRequest, PosPrinterCreateRequestBuilder> {
  _$PosPrinterCreateRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PosPrinterCreateRequestConnectionEnum? _connection;
  PosPrinterCreateRequestConnectionEnum? get connection => _$this._connection;
  set connection(PosPrinterCreateRequestConnectionEnum? connection) =>
      _$this._connection = connection;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _bluetoothId;
  String? get bluetoothId => _$this._bluetoothId;
  set bluetoothId(String? bluetoothId) => _$this._bluetoothId = bluetoothId;

  PosPrinterCreateRequestPaperEnum? _paper;
  PosPrinterCreateRequestPaperEnum? get paper => _$this._paper;
  set paper(PosPrinterCreateRequestPaperEnum? paper) => _$this._paper = paper;

  PosPrinterCreateRequestCommandLanguageEnum? _commandLanguage;
  PosPrinterCreateRequestCommandLanguageEnum? get commandLanguage =>
      _$this._commandLanguage;
  set commandLanguage(
          PosPrinterCreateRequestCommandLanguageEnum? commandLanguage) =>
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

  PosPrinterCreateRequestStatusEnum? _status;
  PosPrinterCreateRequestStatusEnum? get status => _$this._status;
  set status(PosPrinterCreateRequestStatusEnum? status) =>
      _$this._status = status;

  JsonObject? _settings;
  JsonObject? get settings => _$this._settings;
  set settings(JsonObject? settings) => _$this._settings = settings;

  PosPrinterCreateRequestBuilder() {
    PosPrinterCreateRequest._defaults(this);
  }

  PosPrinterCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
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
  void replace(PosPrinterCreateRequest other) {
    _$v = other as _$PosPrinterCreateRequest;
  }

  @override
  void update(void Function(PosPrinterCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterCreateRequest build() => _build();

  _$PosPrinterCreateRequest _build() {
    _$PosPrinterCreateRequest _$result;
    try {
      _$result = _$v ??
          _$PosPrinterCreateRequest._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PosPrinterCreateRequest', 'branchId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'PosPrinterCreateRequest', 'name'),
            connection: BuiltValueNullFieldError.checkNotNull(
                connection, r'PosPrinterCreateRequest', 'connection'),
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
            r'PosPrinterCreateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
