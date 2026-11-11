// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_jobs.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusJobs extends SystemStatusJobs {
  @override
  final bool ok;
  @override
  final bool? inPuma;
  @override
  final int? processes;
  @override
  final int? ready;
  @override
  final int? oldestReadyAgeSeconds;
  @override
  final int? failed;

  factory _$SystemStatusJobs(
          [void Function(SystemStatusJobsBuilder)? updates]) =>
      (SystemStatusJobsBuilder()..update(updates))._build();

  _$SystemStatusJobs._(
      {required this.ok,
      this.inPuma,
      this.processes,
      this.ready,
      this.oldestReadyAgeSeconds,
      this.failed})
      : super._();
  @override
  SystemStatusJobs rebuild(void Function(SystemStatusJobsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusJobsBuilder toBuilder() =>
      SystemStatusJobsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusJobs &&
        ok == other.ok &&
        inPuma == other.inPuma &&
        processes == other.processes &&
        ready == other.ready &&
        oldestReadyAgeSeconds == other.oldestReadyAgeSeconds &&
        failed == other.failed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, inPuma.hashCode);
    _$hash = $jc(_$hash, processes.hashCode);
    _$hash = $jc(_$hash, ready.hashCode);
    _$hash = $jc(_$hash, oldestReadyAgeSeconds.hashCode);
    _$hash = $jc(_$hash, failed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusJobs')
          ..add('ok', ok)
          ..add('inPuma', inPuma)
          ..add('processes', processes)
          ..add('ready', ready)
          ..add('oldestReadyAgeSeconds', oldestReadyAgeSeconds)
          ..add('failed', failed))
        .toString();
  }
}

class SystemStatusJobsBuilder
    implements Builder<SystemStatusJobs, SystemStatusJobsBuilder> {
  _$SystemStatusJobs? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  bool? _inPuma;
  bool? get inPuma => _$this._inPuma;
  set inPuma(bool? inPuma) => _$this._inPuma = inPuma;

  int? _processes;
  int? get processes => _$this._processes;
  set processes(int? processes) => _$this._processes = processes;

  int? _ready;
  int? get ready => _$this._ready;
  set ready(int? ready) => _$this._ready = ready;

  int? _oldestReadyAgeSeconds;
  int? get oldestReadyAgeSeconds => _$this._oldestReadyAgeSeconds;
  set oldestReadyAgeSeconds(int? oldestReadyAgeSeconds) =>
      _$this._oldestReadyAgeSeconds = oldestReadyAgeSeconds;

  int? _failed;
  int? get failed => _$this._failed;
  set failed(int? failed) => _$this._failed = failed;

  SystemStatusJobsBuilder() {
    SystemStatusJobs._defaults(this);
  }

  SystemStatusJobsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _inPuma = $v.inPuma;
      _processes = $v.processes;
      _ready = $v.ready;
      _oldestReadyAgeSeconds = $v.oldestReadyAgeSeconds;
      _failed = $v.failed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusJobs other) {
    _$v = other as _$SystemStatusJobs;
  }

  @override
  void update(void Function(SystemStatusJobsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusJobs build() => _build();

  _$SystemStatusJobs _build() {
    final _$result = _$v ??
        _$SystemStatusJobs._(
          ok: BuiltValueNullFieldError.checkNotNull(
              ok, r'SystemStatusJobs', 'ok'),
          inPuma: inPuma,
          processes: processes,
          ready: ready,
          oldestReadyAgeSeconds: oldestReadyAgeSeconds,
          failed: failed,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
