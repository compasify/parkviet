// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_outbound.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusOutbound extends SystemStatusOutbound {
  @override
  final int pending;
  @override
  final int failed;
  @override
  final int? oldestPendingAgeSeconds;

  factory _$SystemStatusOutbound(
          [void Function(SystemStatusOutboundBuilder)? updates]) =>
      (SystemStatusOutboundBuilder()..update(updates))._build();

  _$SystemStatusOutbound._(
      {required this.pending,
      required this.failed,
      this.oldestPendingAgeSeconds})
      : super._();
  @override
  SystemStatusOutbound rebuild(
          void Function(SystemStatusOutboundBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusOutboundBuilder toBuilder() =>
      SystemStatusOutboundBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusOutbound &&
        pending == other.pending &&
        failed == other.failed &&
        oldestPendingAgeSeconds == other.oldestPendingAgeSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pending.hashCode);
    _$hash = $jc(_$hash, failed.hashCode);
    _$hash = $jc(_$hash, oldestPendingAgeSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusOutbound')
          ..add('pending', pending)
          ..add('failed', failed)
          ..add('oldestPendingAgeSeconds', oldestPendingAgeSeconds))
        .toString();
  }
}

class SystemStatusOutboundBuilder
    implements Builder<SystemStatusOutbound, SystemStatusOutboundBuilder> {
  _$SystemStatusOutbound? _$v;

  int? _pending;
  int? get pending => _$this._pending;
  set pending(int? pending) => _$this._pending = pending;

  int? _failed;
  int? get failed => _$this._failed;
  set failed(int? failed) => _$this._failed = failed;

  int? _oldestPendingAgeSeconds;
  int? get oldestPendingAgeSeconds => _$this._oldestPendingAgeSeconds;
  set oldestPendingAgeSeconds(int? oldestPendingAgeSeconds) =>
      _$this._oldestPendingAgeSeconds = oldestPendingAgeSeconds;

  SystemStatusOutboundBuilder() {
    SystemStatusOutbound._defaults(this);
  }

  SystemStatusOutboundBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pending = $v.pending;
      _failed = $v.failed;
      _oldestPendingAgeSeconds = $v.oldestPendingAgeSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusOutbound other) {
    _$v = other as _$SystemStatusOutbound;
  }

  @override
  void update(void Function(SystemStatusOutboundBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusOutbound build() => _build();

  _$SystemStatusOutbound _build() {
    final _$result = _$v ??
        _$SystemStatusOutbound._(
          pending: BuiltValueNullFieldError.checkNotNull(
              pending, r'SystemStatusOutbound', 'pending'),
          failed: BuiltValueNullFieldError.checkNotNull(
              failed, r'SystemStatusOutbound', 'failed'),
          oldestPendingAgeSeconds: oldestPendingAgeSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
