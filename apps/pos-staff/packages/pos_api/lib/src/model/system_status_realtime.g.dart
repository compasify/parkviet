// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_realtime.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusRealtime extends SystemStatusRealtime {
  @override
  final bool ok;
  @override
  final String adapter;
  @override
  final num? probeMs;
  @override
  final DateTime measuredAt;

  factory _$SystemStatusRealtime(
          [void Function(SystemStatusRealtimeBuilder)? updates]) =>
      (SystemStatusRealtimeBuilder()..update(updates))._build();

  _$SystemStatusRealtime._(
      {required this.ok,
      required this.adapter,
      this.probeMs,
      required this.measuredAt})
      : super._();
  @override
  SystemStatusRealtime rebuild(
          void Function(SystemStatusRealtimeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusRealtimeBuilder toBuilder() =>
      SystemStatusRealtimeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusRealtime &&
        ok == other.ok &&
        adapter == other.adapter &&
        probeMs == other.probeMs &&
        measuredAt == other.measuredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, adapter.hashCode);
    _$hash = $jc(_$hash, probeMs.hashCode);
    _$hash = $jc(_$hash, measuredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusRealtime')
          ..add('ok', ok)
          ..add('adapter', adapter)
          ..add('probeMs', probeMs)
          ..add('measuredAt', measuredAt))
        .toString();
  }
}

class SystemStatusRealtimeBuilder
    implements Builder<SystemStatusRealtime, SystemStatusRealtimeBuilder> {
  _$SystemStatusRealtime? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  String? _adapter;
  String? get adapter => _$this._adapter;
  set adapter(String? adapter) => _$this._adapter = adapter;

  num? _probeMs;
  num? get probeMs => _$this._probeMs;
  set probeMs(num? probeMs) => _$this._probeMs = probeMs;

  DateTime? _measuredAt;
  DateTime? get measuredAt => _$this._measuredAt;
  set measuredAt(DateTime? measuredAt) => _$this._measuredAt = measuredAt;

  SystemStatusRealtimeBuilder() {
    SystemStatusRealtime._defaults(this);
  }

  SystemStatusRealtimeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _adapter = $v.adapter;
      _probeMs = $v.probeMs;
      _measuredAt = $v.measuredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusRealtime other) {
    _$v = other as _$SystemStatusRealtime;
  }

  @override
  void update(void Function(SystemStatusRealtimeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusRealtime build() => _build();

  _$SystemStatusRealtime _build() {
    final _$result = _$v ??
        _$SystemStatusRealtime._(
          ok: BuiltValueNullFieldError.checkNotNull(
              ok, r'SystemStatusRealtime', 'ok'),
          adapter: BuiltValueNullFieldError.checkNotNull(
              adapter, r'SystemStatusRealtime', 'adapter'),
          probeMs: probeMs,
          measuredAt: BuiltValueNullFieldError.checkNotNull(
              measuredAt, r'SystemStatusRealtime', 'measuredAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
