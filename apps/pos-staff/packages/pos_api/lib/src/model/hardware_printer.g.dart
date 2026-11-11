// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_printer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HardwarePrinter extends HardwarePrinter {
  @override
  final String id;
  @override
  final String name;
  @override
  final String connection;
  @override
  final BuiltList<String> roles;
  @override
  final bool viaPrintStation;
  @override
  final String lastJobStatus;
  @override
  final String lastJobKind;
  @override
  final DateTime lastJobAt;
  @override
  final String lastError;

  factory _$HardwarePrinter([void Function(HardwarePrinterBuilder)? updates]) =>
      (HardwarePrinterBuilder()..update(updates))._build();

  _$HardwarePrinter._(
      {required this.id,
      required this.name,
      required this.connection,
      required this.roles,
      required this.viaPrintStation,
      required this.lastJobStatus,
      required this.lastJobKind,
      required this.lastJobAt,
      required this.lastError})
      : super._();
  @override
  HardwarePrinter rebuild(void Function(HardwarePrinterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwarePrinterBuilder toBuilder() => HardwarePrinterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwarePrinter &&
        id == other.id &&
        name == other.name &&
        connection == other.connection &&
        roles == other.roles &&
        viaPrintStation == other.viaPrintStation &&
        lastJobStatus == other.lastJobStatus &&
        lastJobKind == other.lastJobKind &&
        lastJobAt == other.lastJobAt &&
        lastError == other.lastError;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, connection.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jc(_$hash, viaPrintStation.hashCode);
    _$hash = $jc(_$hash, lastJobStatus.hashCode);
    _$hash = $jc(_$hash, lastJobKind.hashCode);
    _$hash = $jc(_$hash, lastJobAt.hashCode);
    _$hash = $jc(_$hash, lastError.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwarePrinter')
          ..add('id', id)
          ..add('name', name)
          ..add('connection', connection)
          ..add('roles', roles)
          ..add('viaPrintStation', viaPrintStation)
          ..add('lastJobStatus', lastJobStatus)
          ..add('lastJobKind', lastJobKind)
          ..add('lastJobAt', lastJobAt)
          ..add('lastError', lastError))
        .toString();
  }
}

class HardwarePrinterBuilder
    implements Builder<HardwarePrinter, HardwarePrinterBuilder> {
  _$HardwarePrinter? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _connection;
  String? get connection => _$this._connection;
  set connection(String? connection) => _$this._connection = connection;

  ListBuilder<String>? _roles;
  ListBuilder<String> get roles => _$this._roles ??= ListBuilder<String>();
  set roles(ListBuilder<String>? roles) => _$this._roles = roles;

  bool? _viaPrintStation;
  bool? get viaPrintStation => _$this._viaPrintStation;
  set viaPrintStation(bool? viaPrintStation) =>
      _$this._viaPrintStation = viaPrintStation;

  String? _lastJobStatus;
  String? get lastJobStatus => _$this._lastJobStatus;
  set lastJobStatus(String? lastJobStatus) =>
      _$this._lastJobStatus = lastJobStatus;

  String? _lastJobKind;
  String? get lastJobKind => _$this._lastJobKind;
  set lastJobKind(String? lastJobKind) => _$this._lastJobKind = lastJobKind;

  DateTime? _lastJobAt;
  DateTime? get lastJobAt => _$this._lastJobAt;
  set lastJobAt(DateTime? lastJobAt) => _$this._lastJobAt = lastJobAt;

  String? _lastError;
  String? get lastError => _$this._lastError;
  set lastError(String? lastError) => _$this._lastError = lastError;

  HardwarePrinterBuilder() {
    HardwarePrinter._defaults(this);
  }

  HardwarePrinterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _connection = $v.connection;
      _roles = $v.roles.toBuilder();
      _viaPrintStation = $v.viaPrintStation;
      _lastJobStatus = $v.lastJobStatus;
      _lastJobKind = $v.lastJobKind;
      _lastJobAt = $v.lastJobAt;
      _lastError = $v.lastError;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwarePrinter other) {
    _$v = other as _$HardwarePrinter;
  }

  @override
  void update(void Function(HardwarePrinterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwarePrinter build() => _build();

  _$HardwarePrinter _build() {
    _$HardwarePrinter _$result;
    try {
      _$result = _$v ??
          _$HardwarePrinter._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'HardwarePrinter', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'HardwarePrinter', 'name'),
            connection: BuiltValueNullFieldError.checkNotNull(
                connection, r'HardwarePrinter', 'connection'),
            roles: roles.build(),
            viaPrintStation: BuiltValueNullFieldError.checkNotNull(
                viaPrintStation, r'HardwarePrinter', 'viaPrintStation'),
            lastJobStatus: BuiltValueNullFieldError.checkNotNull(
                lastJobStatus, r'HardwarePrinter', 'lastJobStatus'),
            lastJobKind: BuiltValueNullFieldError.checkNotNull(
                lastJobKind, r'HardwarePrinter', 'lastJobKind'),
            lastJobAt: BuiltValueNullFieldError.checkNotNull(
                lastJobAt, r'HardwarePrinter', 'lastJobAt'),
            lastError: BuiltValueNullFieldError.checkNotNull(
                lastError, r'HardwarePrinter', 'lastError'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'HardwarePrinter', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
