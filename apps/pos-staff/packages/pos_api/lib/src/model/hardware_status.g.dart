// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HardwareStatus extends HardwareStatus {
  @override
  final String branchId;
  @override
  final DateTime generatedAt;
  @override
  final BuiltList<HardwareCheck> checks;
  @override
  final BuiltList<HardwarePrinter> printers;
  @override
  final BuiltList<HardwareStation> stations;
  @override
  final BuiltList<HardwareDevice> devices;
  @override
  final HardwareDisplays customerDisplays;
  @override
  final HardwareServer server;
  @override
  final HardwareEinvoice einvoice;

  factory _$HardwareStatus([void Function(HardwareStatusBuilder)? updates]) =>
      (HardwareStatusBuilder()..update(updates))._build();

  _$HardwareStatus._(
      {required this.branchId,
      required this.generatedAt,
      required this.checks,
      required this.printers,
      required this.stations,
      required this.devices,
      required this.customerDisplays,
      required this.server,
      required this.einvoice})
      : super._();
  @override
  HardwareStatus rebuild(void Function(HardwareStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareStatusBuilder toBuilder() => HardwareStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareStatus &&
        branchId == other.branchId &&
        generatedAt == other.generatedAt &&
        checks == other.checks &&
        printers == other.printers &&
        stations == other.stations &&
        devices == other.devices &&
        customerDisplays == other.customerDisplays &&
        server == other.server &&
        einvoice == other.einvoice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, checks.hashCode);
    _$hash = $jc(_$hash, printers.hashCode);
    _$hash = $jc(_$hash, stations.hashCode);
    _$hash = $jc(_$hash, devices.hashCode);
    _$hash = $jc(_$hash, customerDisplays.hashCode);
    _$hash = $jc(_$hash, server.hashCode);
    _$hash = $jc(_$hash, einvoice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareStatus')
          ..add('branchId', branchId)
          ..add('generatedAt', generatedAt)
          ..add('checks', checks)
          ..add('printers', printers)
          ..add('stations', stations)
          ..add('devices', devices)
          ..add('customerDisplays', customerDisplays)
          ..add('server', server)
          ..add('einvoice', einvoice))
        .toString();
  }
}

class HardwareStatusBuilder
    implements Builder<HardwareStatus, HardwareStatusBuilder> {
  _$HardwareStatus? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  ListBuilder<HardwareCheck>? _checks;
  ListBuilder<HardwareCheck> get checks =>
      _$this._checks ??= ListBuilder<HardwareCheck>();
  set checks(ListBuilder<HardwareCheck>? checks) => _$this._checks = checks;

  ListBuilder<HardwarePrinter>? _printers;
  ListBuilder<HardwarePrinter> get printers =>
      _$this._printers ??= ListBuilder<HardwarePrinter>();
  set printers(ListBuilder<HardwarePrinter>? printers) =>
      _$this._printers = printers;

  ListBuilder<HardwareStation>? _stations;
  ListBuilder<HardwareStation> get stations =>
      _$this._stations ??= ListBuilder<HardwareStation>();
  set stations(ListBuilder<HardwareStation>? stations) =>
      _$this._stations = stations;

  ListBuilder<HardwareDevice>? _devices;
  ListBuilder<HardwareDevice> get devices =>
      _$this._devices ??= ListBuilder<HardwareDevice>();
  set devices(ListBuilder<HardwareDevice>? devices) =>
      _$this._devices = devices;

  HardwareDisplaysBuilder? _customerDisplays;
  HardwareDisplaysBuilder get customerDisplays =>
      _$this._customerDisplays ??= HardwareDisplaysBuilder();
  set customerDisplays(HardwareDisplaysBuilder? customerDisplays) =>
      _$this._customerDisplays = customerDisplays;

  HardwareServerBuilder? _server;
  HardwareServerBuilder get server =>
      _$this._server ??= HardwareServerBuilder();
  set server(HardwareServerBuilder? server) => _$this._server = server;

  HardwareEinvoiceBuilder? _einvoice;
  HardwareEinvoiceBuilder get einvoice =>
      _$this._einvoice ??= HardwareEinvoiceBuilder();
  set einvoice(HardwareEinvoiceBuilder? einvoice) =>
      _$this._einvoice = einvoice;

  HardwareStatusBuilder() {
    HardwareStatus._defaults(this);
  }

  HardwareStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _generatedAt = $v.generatedAt;
      _checks = $v.checks.toBuilder();
      _printers = $v.printers.toBuilder();
      _stations = $v.stations.toBuilder();
      _devices = $v.devices.toBuilder();
      _customerDisplays = $v.customerDisplays.toBuilder();
      _server = $v.server.toBuilder();
      _einvoice = $v.einvoice.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareStatus other) {
    _$v = other as _$HardwareStatus;
  }

  @override
  void update(void Function(HardwareStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareStatus build() => _build();

  _$HardwareStatus _build() {
    _$HardwareStatus _$result;
    try {
      _$result = _$v ??
          _$HardwareStatus._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'HardwareStatus', 'branchId'),
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'HardwareStatus', 'generatedAt'),
            checks: checks.build(),
            printers: printers.build(),
            stations: stations.build(),
            devices: devices.build(),
            customerDisplays: customerDisplays.build(),
            server: server.build(),
            einvoice: einvoice.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'checks';
        checks.build();
        _$failedField = 'printers';
        printers.build();
        _$failedField = 'stations';
        stations.build();
        _$failedField = 'devices';
        devices.build();
        _$failedField = 'customerDisplays';
        customerDisplays.build();
        _$failedField = 'server';
        server.build();
        _$failedField = 'einvoice';
        einvoice.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'HardwareStatus', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
