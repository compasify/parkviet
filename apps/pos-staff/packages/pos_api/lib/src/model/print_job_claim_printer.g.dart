// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_claim_printer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintJobClaimPrinter extends PrintJobClaimPrinter {
  @override
  final String id;
  @override
  final String name;
  @override
  final String connection;
  @override
  final String? address;
  @override
  final String? bluetoothId;
  @override
  final String paper;
  @override
  final String commandLanguage;
  @override
  final JsonObject settings;

  factory _$PrintJobClaimPrinter(
          [void Function(PrintJobClaimPrinterBuilder)? updates]) =>
      (PrintJobClaimPrinterBuilder()..update(updates))._build();

  _$PrintJobClaimPrinter._(
      {required this.id,
      required this.name,
      required this.connection,
      this.address,
      this.bluetoothId,
      required this.paper,
      required this.commandLanguage,
      required this.settings})
      : super._();
  @override
  PrintJobClaimPrinter rebuild(
          void Function(PrintJobClaimPrinterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintJobClaimPrinterBuilder toBuilder() =>
      PrintJobClaimPrinterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintJobClaimPrinter &&
        id == other.id &&
        name == other.name &&
        connection == other.connection &&
        address == other.address &&
        bluetoothId == other.bluetoothId &&
        paper == other.paper &&
        commandLanguage == other.commandLanguage &&
        settings == other.settings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, connection.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, bluetoothId.hashCode);
    _$hash = $jc(_$hash, paper.hashCode);
    _$hash = $jc(_$hash, commandLanguage.hashCode);
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintJobClaimPrinter')
          ..add('id', id)
          ..add('name', name)
          ..add('connection', connection)
          ..add('address', address)
          ..add('bluetoothId', bluetoothId)
          ..add('paper', paper)
          ..add('commandLanguage', commandLanguage)
          ..add('settings', settings))
        .toString();
  }
}

class PrintJobClaimPrinterBuilder
    implements Builder<PrintJobClaimPrinter, PrintJobClaimPrinterBuilder> {
  _$PrintJobClaimPrinter? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _connection;
  String? get connection => _$this._connection;
  set connection(String? connection) => _$this._connection = connection;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _bluetoothId;
  String? get bluetoothId => _$this._bluetoothId;
  set bluetoothId(String? bluetoothId) => _$this._bluetoothId = bluetoothId;

  String? _paper;
  String? get paper => _$this._paper;
  set paper(String? paper) => _$this._paper = paper;

  String? _commandLanguage;
  String? get commandLanguage => _$this._commandLanguage;
  set commandLanguage(String? commandLanguage) =>
      _$this._commandLanguage = commandLanguage;

  JsonObject? _settings;
  JsonObject? get settings => _$this._settings;
  set settings(JsonObject? settings) => _$this._settings = settings;

  PrintJobClaimPrinterBuilder() {
    PrintJobClaimPrinter._defaults(this);
  }

  PrintJobClaimPrinterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _connection = $v.connection;
      _address = $v.address;
      _bluetoothId = $v.bluetoothId;
      _paper = $v.paper;
      _commandLanguage = $v.commandLanguage;
      _settings = $v.settings;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintJobClaimPrinter other) {
    _$v = other as _$PrintJobClaimPrinter;
  }

  @override
  void update(void Function(PrintJobClaimPrinterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintJobClaimPrinter build() => _build();

  _$PrintJobClaimPrinter _build() {
    final _$result = _$v ??
        _$PrintJobClaimPrinter._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PrintJobClaimPrinter', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PrintJobClaimPrinter', 'name'),
          connection: BuiltValueNullFieldError.checkNotNull(
              connection, r'PrintJobClaimPrinter', 'connection'),
          address: address,
          bluetoothId: bluetoothId,
          paper: BuiltValueNullFieldError.checkNotNull(
              paper, r'PrintJobClaimPrinter', 'paper'),
          commandLanguage: BuiltValueNullFieldError.checkNotNull(
              commandLanguage, r'PrintJobClaimPrinter', 'commandLanguage'),
          settings: BuiltValueNullFieldError.checkNotNull(
              settings, r'PrintJobClaimPrinter', 'settings'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
