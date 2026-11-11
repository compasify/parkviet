// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_backup.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusBackup extends SystemStatusBackup {
  @override
  final bool configured;
  @override
  final DateTime? lastAt;
  @override
  final int count;

  factory _$SystemStatusBackup(
          [void Function(SystemStatusBackupBuilder)? updates]) =>
      (SystemStatusBackupBuilder()..update(updates))._build();

  _$SystemStatusBackup._(
      {required this.configured, this.lastAt, required this.count})
      : super._();
  @override
  SystemStatusBackup rebuild(
          void Function(SystemStatusBackupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusBackupBuilder toBuilder() =>
      SystemStatusBackupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusBackup &&
        configured == other.configured &&
        lastAt == other.lastAt &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configured.hashCode);
    _$hash = $jc(_$hash, lastAt.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusBackup')
          ..add('configured', configured)
          ..add('lastAt', lastAt)
          ..add('count', count))
        .toString();
  }
}

class SystemStatusBackupBuilder
    implements Builder<SystemStatusBackup, SystemStatusBackupBuilder> {
  _$SystemStatusBackup? _$v;

  bool? _configured;
  bool? get configured => _$this._configured;
  set configured(bool? configured) => _$this._configured = configured;

  DateTime? _lastAt;
  DateTime? get lastAt => _$this._lastAt;
  set lastAt(DateTime? lastAt) => _$this._lastAt = lastAt;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  SystemStatusBackupBuilder() {
    SystemStatusBackup._defaults(this);
  }

  SystemStatusBackupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configured = $v.configured;
      _lastAt = $v.lastAt;
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusBackup other) {
    _$v = other as _$SystemStatusBackup;
  }

  @override
  void update(void Function(SystemStatusBackupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusBackup build() => _build();

  _$SystemStatusBackup _build() {
    final _$result = _$v ??
        _$SystemStatusBackup._(
          configured: BuiltValueNullFieldError.checkNotNull(
              configured, r'SystemStatusBackup', 'configured'),
          lastAt: lastAt,
          count: BuiltValueNullFieldError.checkNotNull(
              count, r'SystemStatusBackup', 'count'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
