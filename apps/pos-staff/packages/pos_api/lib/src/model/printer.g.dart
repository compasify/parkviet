// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrinterConnectionEnum _$printerConnectionEnum_escposLan =
    const PrinterConnectionEnum._('escposLan');
const PrinterConnectionEnum _$printerConnectionEnum_escposBluetooth =
    const PrinterConnectionEnum._('escposBluetooth');
const PrinterConnectionEnum _$printerConnectionEnum_sunmiBuiltin =
    const PrinterConnectionEnum._('sunmiBuiltin');
const PrinterConnectionEnum _$printerConnectionEnum_epsonEpos =
    const PrinterConnectionEnum._('epsonEpos');
const PrinterConnectionEnum _$printerConnectionEnum_starWebprnt =
    const PrinterConnectionEnum._('starWebprnt');
const PrinterConnectionEnum _$printerConnectionEnum_browser =
    const PrinterConnectionEnum._('browser');

PrinterConnectionEnum _$printerConnectionEnumValueOf(String name) {
  switch (name) {
    case 'escposLan':
      return _$printerConnectionEnum_escposLan;
    case 'escposBluetooth':
      return _$printerConnectionEnum_escposBluetooth;
    case 'sunmiBuiltin':
      return _$printerConnectionEnum_sunmiBuiltin;
    case 'epsonEpos':
      return _$printerConnectionEnum_epsonEpos;
    case 'starWebprnt':
      return _$printerConnectionEnum_starWebprnt;
    case 'browser':
      return _$printerConnectionEnum_browser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrinterConnectionEnum> _$printerConnectionEnumValues =
    BuiltSet<PrinterConnectionEnum>(const <PrinterConnectionEnum>[
  _$printerConnectionEnum_escposLan,
  _$printerConnectionEnum_escposBluetooth,
  _$printerConnectionEnum_sunmiBuiltin,
  _$printerConnectionEnum_epsonEpos,
  _$printerConnectionEnum_starWebprnt,
  _$printerConnectionEnum_browser,
]);

const PrinterPaperEnum _$printerPaperEnum_n58mm =
    const PrinterPaperEnum._('n58mm');
const PrinterPaperEnum _$printerPaperEnum_n80mm =
    const PrinterPaperEnum._('n80mm');

PrinterPaperEnum _$printerPaperEnumValueOf(String name) {
  switch (name) {
    case 'n58mm':
      return _$printerPaperEnum_n58mm;
    case 'n80mm':
      return _$printerPaperEnum_n80mm;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrinterPaperEnum> _$printerPaperEnumValues =
    BuiltSet<PrinterPaperEnum>(const <PrinterPaperEnum>[
  _$printerPaperEnum_n58mm,
  _$printerPaperEnum_n80mm,
]);

const PrinterCommandLanguageEnum _$printerCommandLanguageEnum_escpos =
    const PrinterCommandLanguageEnum._('escpos');
const PrinterCommandLanguageEnum _$printerCommandLanguageEnum_tspl =
    const PrinterCommandLanguageEnum._('tspl');

PrinterCommandLanguageEnum _$printerCommandLanguageEnumValueOf(String name) {
  switch (name) {
    case 'escpos':
      return _$printerCommandLanguageEnum_escpos;
    case 'tspl':
      return _$printerCommandLanguageEnum_tspl;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrinterCommandLanguageEnum> _$printerCommandLanguageEnumValues =
    BuiltSet<PrinterCommandLanguageEnum>(const <PrinterCommandLanguageEnum>[
  _$printerCommandLanguageEnum_escpos,
  _$printerCommandLanguageEnum_tspl,
]);

const PrinterRolesEnum _$printerRolesEnum_receipt =
    const PrinterRolesEnum._('receipt');
const PrinterRolesEnum _$printerRolesEnum_prebill =
    const PrinterRolesEnum._('prebill');
const PrinterRolesEnum _$printerRolesEnum_kitchenTicket =
    const PrinterRolesEnum._('kitchenTicket');
const PrinterRolesEnum _$printerRolesEnum_voidTicket =
    const PrinterRolesEnum._('voidTicket');
const PrinterRolesEnum _$printerRolesEnum_cupLabel =
    const PrinterRolesEnum._('cupLabel');
const PrinterRolesEnum _$printerRolesEnum_checklist =
    const PrinterRolesEnum._('checklist');
const PrinterRolesEnum _$printerRolesEnum_tableQr =
    const PrinterRolesEnum._('tableQr');

PrinterRolesEnum _$printerRolesEnumValueOf(String name) {
  switch (name) {
    case 'receipt':
      return _$printerRolesEnum_receipt;
    case 'prebill':
      return _$printerRolesEnum_prebill;
    case 'kitchenTicket':
      return _$printerRolesEnum_kitchenTicket;
    case 'voidTicket':
      return _$printerRolesEnum_voidTicket;
    case 'cupLabel':
      return _$printerRolesEnum_cupLabel;
    case 'checklist':
      return _$printerRolesEnum_checklist;
    case 'tableQr':
      return _$printerRolesEnum_tableQr;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrinterRolesEnum> _$printerRolesEnumValues =
    BuiltSet<PrinterRolesEnum>(const <PrinterRolesEnum>[
  _$printerRolesEnum_receipt,
  _$printerRolesEnum_prebill,
  _$printerRolesEnum_kitchenTicket,
  _$printerRolesEnum_voidTicket,
  _$printerRolesEnum_cupLabel,
  _$printerRolesEnum_checklist,
  _$printerRolesEnum_tableQr,
]);

const PrinterStatusEnum _$printerStatusEnum_active =
    const PrinterStatusEnum._('active');
const PrinterStatusEnum _$printerStatusEnum_disabled =
    const PrinterStatusEnum._('disabled');

PrinterStatusEnum _$printerStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$printerStatusEnum_active;
    case 'disabled':
      return _$printerStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrinterStatusEnum> _$printerStatusEnumValues =
    BuiltSet<PrinterStatusEnum>(const <PrinterStatusEnum>[
  _$printerStatusEnum_active,
  _$printerStatusEnum_disabled,
]);

Serializer<PrinterConnectionEnum> _$printerConnectionEnumSerializer =
    _$PrinterConnectionEnumSerializer();
Serializer<PrinterPaperEnum> _$printerPaperEnumSerializer =
    _$PrinterPaperEnumSerializer();
Serializer<PrinterCommandLanguageEnum> _$printerCommandLanguageEnumSerializer =
    _$PrinterCommandLanguageEnumSerializer();
Serializer<PrinterRolesEnum> _$printerRolesEnumSerializer =
    _$PrinterRolesEnumSerializer();
Serializer<PrinterStatusEnum> _$printerStatusEnumSerializer =
    _$PrinterStatusEnumSerializer();

class _$PrinterConnectionEnumSerializer
    implements PrimitiveSerializer<PrinterConnectionEnum> {
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
  final Iterable<Type> types = const <Type>[PrinterConnectionEnum];
  @override
  final String wireName = 'PrinterConnectionEnum';

  @override
  Object serialize(Serializers serializers, PrinterConnectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrinterConnectionEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrinterConnectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrinterPaperEnumSerializer
    implements PrimitiveSerializer<PrinterPaperEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n58mm': '58mm',
    'n80mm': '80mm',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '58mm': 'n58mm',
    '80mm': 'n80mm',
  };

  @override
  final Iterable<Type> types = const <Type>[PrinterPaperEnum];
  @override
  final String wireName = 'PrinterPaperEnum';

  @override
  Object serialize(Serializers serializers, PrinterPaperEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrinterPaperEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrinterPaperEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrinterCommandLanguageEnumSerializer
    implements PrimitiveSerializer<PrinterCommandLanguageEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'escpos': 'escpos',
    'tspl': 'tspl',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'escpos': 'escpos',
    'tspl': 'tspl',
  };

  @override
  final Iterable<Type> types = const <Type>[PrinterCommandLanguageEnum];
  @override
  final String wireName = 'PrinterCommandLanguageEnum';

  @override
  Object serialize(Serializers serializers, PrinterCommandLanguageEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrinterCommandLanguageEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrinterCommandLanguageEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrinterRolesEnumSerializer
    implements PrimitiveSerializer<PrinterRolesEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'receipt': 'receipt',
    'prebill': 'prebill',
    'kitchenTicket': 'kitchen_ticket',
    'voidTicket': 'void_ticket',
    'cupLabel': 'cup_label',
    'checklist': 'checklist',
    'tableQr': 'table_qr',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'receipt': 'receipt',
    'prebill': 'prebill',
    'kitchen_ticket': 'kitchenTicket',
    'void_ticket': 'voidTicket',
    'cup_label': 'cupLabel',
    'checklist': 'checklist',
    'table_qr': 'tableQr',
  };

  @override
  final Iterable<Type> types = const <Type>[PrinterRolesEnum];
  @override
  final String wireName = 'PrinterRolesEnum';

  @override
  Object serialize(Serializers serializers, PrinterRolesEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrinterRolesEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrinterRolesEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrinterStatusEnumSerializer
    implements PrimitiveSerializer<PrinterStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[PrinterStatusEnum];
  @override
  final String wireName = 'PrinterStatusEnum';

  @override
  Object serialize(Serializers serializers, PrinterStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrinterStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrinterStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Printer extends Printer {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String name;
  @override
  final PrinterConnectionEnum connection;
  @override
  final String? address;
  @override
  final String? bluetoothId;
  @override
  final PrinterPaperEnum paper;
  @override
  final PrinterCommandLanguageEnum commandLanguage;
  @override
  final BuiltList<PrinterRolesEnum> roles;
  @override
  final String? printStationDeviceId;
  @override
  final String? registerId;
  @override
  final PrinterStatusEnum status;
  @override
  final JsonObject settings;

  factory _$Printer([void Function(PrinterBuilder)? updates]) =>
      (PrinterBuilder()..update(updates))._build();

  _$Printer._(
      {required this.id,
      required this.branchId,
      required this.name,
      required this.connection,
      this.address,
      this.bluetoothId,
      required this.paper,
      required this.commandLanguage,
      required this.roles,
      this.printStationDeviceId,
      this.registerId,
      required this.status,
      required this.settings})
      : super._();
  @override
  Printer rebuild(void Function(PrinterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrinterBuilder toBuilder() => PrinterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Printer &&
        id == other.id &&
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
    _$hash = $jc(_$hash, id.hashCode);
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
    return (newBuiltValueToStringHelper(r'Printer')
          ..add('id', id)
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

class PrinterBuilder implements Builder<Printer, PrinterBuilder> {
  _$Printer? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PrinterConnectionEnum? _connection;
  PrinterConnectionEnum? get connection => _$this._connection;
  set connection(PrinterConnectionEnum? connection) =>
      _$this._connection = connection;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _bluetoothId;
  String? get bluetoothId => _$this._bluetoothId;
  set bluetoothId(String? bluetoothId) => _$this._bluetoothId = bluetoothId;

  PrinterPaperEnum? _paper;
  PrinterPaperEnum? get paper => _$this._paper;
  set paper(PrinterPaperEnum? paper) => _$this._paper = paper;

  PrinterCommandLanguageEnum? _commandLanguage;
  PrinterCommandLanguageEnum? get commandLanguage => _$this._commandLanguage;
  set commandLanguage(PrinterCommandLanguageEnum? commandLanguage) =>
      _$this._commandLanguage = commandLanguage;

  ListBuilder<PrinterRolesEnum>? _roles;
  ListBuilder<PrinterRolesEnum> get roles =>
      _$this._roles ??= ListBuilder<PrinterRolesEnum>();
  set roles(ListBuilder<PrinterRolesEnum>? roles) => _$this._roles = roles;

  String? _printStationDeviceId;
  String? get printStationDeviceId => _$this._printStationDeviceId;
  set printStationDeviceId(String? printStationDeviceId) =>
      _$this._printStationDeviceId = printStationDeviceId;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  PrinterStatusEnum? _status;
  PrinterStatusEnum? get status => _$this._status;
  set status(PrinterStatusEnum? status) => _$this._status = status;

  JsonObject? _settings;
  JsonObject? get settings => _$this._settings;
  set settings(JsonObject? settings) => _$this._settings = settings;

  PrinterBuilder() {
    Printer._defaults(this);
  }

  PrinterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _name = $v.name;
      _connection = $v.connection;
      _address = $v.address;
      _bluetoothId = $v.bluetoothId;
      _paper = $v.paper;
      _commandLanguage = $v.commandLanguage;
      _roles = $v.roles.toBuilder();
      _printStationDeviceId = $v.printStationDeviceId;
      _registerId = $v.registerId;
      _status = $v.status;
      _settings = $v.settings;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Printer other) {
    _$v = other as _$Printer;
  }

  @override
  void update(void Function(PrinterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Printer build() => _build();

  _$Printer _build() {
    _$Printer _$result;
    try {
      _$result = _$v ??
          _$Printer._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Printer', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'Printer', 'branchId'),
            name:
                BuiltValueNullFieldError.checkNotNull(name, r'Printer', 'name'),
            connection: BuiltValueNullFieldError.checkNotNull(
                connection, r'Printer', 'connection'),
            address: address,
            bluetoothId: bluetoothId,
            paper: BuiltValueNullFieldError.checkNotNull(
                paper, r'Printer', 'paper'),
            commandLanguage: BuiltValueNullFieldError.checkNotNull(
                commandLanguage, r'Printer', 'commandLanguage'),
            roles: roles.build(),
            printStationDeviceId: printStationDeviceId,
            registerId: registerId,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Printer', 'status'),
            settings: BuiltValueNullFieldError.checkNotNull(
                settings, r'Printer', 'settings'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Printer', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
