// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatus extends SystemStatus {
  @override
  final DateTime generatedAt;
  @override
  final SystemStatusVersion version;
  @override
  final SystemStatusServer server;
  @override
  final SystemStatusDatabase database;
  @override
  final SystemStatusJobs jobs;
  @override
  final SystemStatusRealtime realtime;
  @override
  final SystemStatusPrinting printing;
  @override
  final SystemStatusOutbound outbound;
  @override
  final SystemStatusVietqr vietqr;
  @override
  final SystemStatusBackup backup;

  factory _$SystemStatus([void Function(SystemStatusBuilder)? updates]) =>
      (SystemStatusBuilder()..update(updates))._build();

  _$SystemStatus._(
      {required this.generatedAt,
      required this.version,
      required this.server,
      required this.database,
      required this.jobs,
      required this.realtime,
      required this.printing,
      required this.outbound,
      required this.vietqr,
      required this.backup})
      : super._();
  @override
  SystemStatus rebuild(void Function(SystemStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusBuilder toBuilder() => SystemStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatus &&
        generatedAt == other.generatedAt &&
        version == other.version &&
        server == other.server &&
        database == other.database &&
        jobs == other.jobs &&
        realtime == other.realtime &&
        printing == other.printing &&
        outbound == other.outbound &&
        vietqr == other.vietqr &&
        backup == other.backup;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, server.hashCode);
    _$hash = $jc(_$hash, database.hashCode);
    _$hash = $jc(_$hash, jobs.hashCode);
    _$hash = $jc(_$hash, realtime.hashCode);
    _$hash = $jc(_$hash, printing.hashCode);
    _$hash = $jc(_$hash, outbound.hashCode);
    _$hash = $jc(_$hash, vietqr.hashCode);
    _$hash = $jc(_$hash, backup.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatus')
          ..add('generatedAt', generatedAt)
          ..add('version', version)
          ..add('server', server)
          ..add('database', database)
          ..add('jobs', jobs)
          ..add('realtime', realtime)
          ..add('printing', printing)
          ..add('outbound', outbound)
          ..add('vietqr', vietqr)
          ..add('backup', backup))
        .toString();
  }
}

class SystemStatusBuilder
    implements Builder<SystemStatus, SystemStatusBuilder> {
  _$SystemStatus? _$v;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  SystemStatusVersionBuilder? _version;
  SystemStatusVersionBuilder get version =>
      _$this._version ??= SystemStatusVersionBuilder();
  set version(SystemStatusVersionBuilder? version) => _$this._version = version;

  SystemStatusServerBuilder? _server;
  SystemStatusServerBuilder get server =>
      _$this._server ??= SystemStatusServerBuilder();
  set server(SystemStatusServerBuilder? server) => _$this._server = server;

  SystemStatusDatabaseBuilder? _database;
  SystemStatusDatabaseBuilder get database =>
      _$this._database ??= SystemStatusDatabaseBuilder();
  set database(SystemStatusDatabaseBuilder? database) =>
      _$this._database = database;

  SystemStatusJobsBuilder? _jobs;
  SystemStatusJobsBuilder get jobs =>
      _$this._jobs ??= SystemStatusJobsBuilder();
  set jobs(SystemStatusJobsBuilder? jobs) => _$this._jobs = jobs;

  SystemStatusRealtimeBuilder? _realtime;
  SystemStatusRealtimeBuilder get realtime =>
      _$this._realtime ??= SystemStatusRealtimeBuilder();
  set realtime(SystemStatusRealtimeBuilder? realtime) =>
      _$this._realtime = realtime;

  SystemStatusPrintingBuilder? _printing;
  SystemStatusPrintingBuilder get printing =>
      _$this._printing ??= SystemStatusPrintingBuilder();
  set printing(SystemStatusPrintingBuilder? printing) =>
      _$this._printing = printing;

  SystemStatusOutboundBuilder? _outbound;
  SystemStatusOutboundBuilder get outbound =>
      _$this._outbound ??= SystemStatusOutboundBuilder();
  set outbound(SystemStatusOutboundBuilder? outbound) =>
      _$this._outbound = outbound;

  SystemStatusVietqrBuilder? _vietqr;
  SystemStatusVietqrBuilder get vietqr =>
      _$this._vietqr ??= SystemStatusVietqrBuilder();
  set vietqr(SystemStatusVietqrBuilder? vietqr) => _$this._vietqr = vietqr;

  SystemStatusBackupBuilder? _backup;
  SystemStatusBackupBuilder get backup =>
      _$this._backup ??= SystemStatusBackupBuilder();
  set backup(SystemStatusBackupBuilder? backup) => _$this._backup = backup;

  SystemStatusBuilder() {
    SystemStatus._defaults(this);
  }

  SystemStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generatedAt = $v.generatedAt;
      _version = $v.version.toBuilder();
      _server = $v.server.toBuilder();
      _database = $v.database.toBuilder();
      _jobs = $v.jobs.toBuilder();
      _realtime = $v.realtime.toBuilder();
      _printing = $v.printing.toBuilder();
      _outbound = $v.outbound.toBuilder();
      _vietqr = $v.vietqr.toBuilder();
      _backup = $v.backup.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatus other) {
    _$v = other as _$SystemStatus;
  }

  @override
  void update(void Function(SystemStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatus build() => _build();

  _$SystemStatus _build() {
    _$SystemStatus _$result;
    try {
      _$result = _$v ??
          _$SystemStatus._(
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'SystemStatus', 'generatedAt'),
            version: version.build(),
            server: server.build(),
            database: database.build(),
            jobs: jobs.build(),
            realtime: realtime.build(),
            printing: printing.build(),
            outbound: outbound.build(),
            vietqr: vietqr.build(),
            backup: backup.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'version';
        version.build();
        _$failedField = 'server';
        server.build();
        _$failedField = 'database';
        database.build();
        _$failedField = 'jobs';
        jobs.build();
        _$failedField = 'realtime';
        realtime.build();
        _$failedField = 'printing';
        printing.build();
        _$failedField = 'outbound';
        outbound.build();
        _$failedField = 'vietqr';
        vietqr.build();
        _$failedField = 'backup';
        backup.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SystemStatus', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
