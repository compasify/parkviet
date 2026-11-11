// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_database.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusDatabase extends SystemStatusDatabase {
  @override
  final bool ok;
  @override
  final num? latencyMs;

  factory _$SystemStatusDatabase(
          [void Function(SystemStatusDatabaseBuilder)? updates]) =>
      (SystemStatusDatabaseBuilder()..update(updates))._build();

  _$SystemStatusDatabase._({required this.ok, this.latencyMs}) : super._();
  @override
  SystemStatusDatabase rebuild(
          void Function(SystemStatusDatabaseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusDatabaseBuilder toBuilder() =>
      SystemStatusDatabaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusDatabase &&
        ok == other.ok &&
        latencyMs == other.latencyMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, latencyMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusDatabase')
          ..add('ok', ok)
          ..add('latencyMs', latencyMs))
        .toString();
  }
}

class SystemStatusDatabaseBuilder
    implements Builder<SystemStatusDatabase, SystemStatusDatabaseBuilder> {
  _$SystemStatusDatabase? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  num? _latencyMs;
  num? get latencyMs => _$this._latencyMs;
  set latencyMs(num? latencyMs) => _$this._latencyMs = latencyMs;

  SystemStatusDatabaseBuilder() {
    SystemStatusDatabase._defaults(this);
  }

  SystemStatusDatabaseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _latencyMs = $v.latencyMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusDatabase other) {
    _$v = other as _$SystemStatusDatabase;
  }

  @override
  void update(void Function(SystemStatusDatabaseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusDatabase build() => _build();

  _$SystemStatusDatabase _build() {
    final _$result = _$v ??
        _$SystemStatusDatabase._(
          ok: BuiltValueNullFieldError.checkNotNull(
              ok, r'SystemStatusDatabase', 'ok'),
          latencyMs: latencyMs,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
