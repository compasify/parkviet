// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_printing.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusPrinting extends SystemStatusPrinting {
  @override
  final int pending;
  @override
  final int? oldestPendingAgeSeconds;
  @override
  final int failedLast24h;
  @override
  final int failedWindowHours;

  factory _$SystemStatusPrinting(
          [void Function(SystemStatusPrintingBuilder)? updates]) =>
      (SystemStatusPrintingBuilder()..update(updates))._build();

  _$SystemStatusPrinting._(
      {required this.pending,
      this.oldestPendingAgeSeconds,
      required this.failedLast24h,
      required this.failedWindowHours})
      : super._();
  @override
  SystemStatusPrinting rebuild(
          void Function(SystemStatusPrintingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusPrintingBuilder toBuilder() =>
      SystemStatusPrintingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusPrinting &&
        pending == other.pending &&
        oldestPendingAgeSeconds == other.oldestPendingAgeSeconds &&
        failedLast24h == other.failedLast24h &&
        failedWindowHours == other.failedWindowHours;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pending.hashCode);
    _$hash = $jc(_$hash, oldestPendingAgeSeconds.hashCode);
    _$hash = $jc(_$hash, failedLast24h.hashCode);
    _$hash = $jc(_$hash, failedWindowHours.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusPrinting')
          ..add('pending', pending)
          ..add('oldestPendingAgeSeconds', oldestPendingAgeSeconds)
          ..add('failedLast24h', failedLast24h)
          ..add('failedWindowHours', failedWindowHours))
        .toString();
  }
}

class SystemStatusPrintingBuilder
    implements Builder<SystemStatusPrinting, SystemStatusPrintingBuilder> {
  _$SystemStatusPrinting? _$v;

  int? _pending;
  int? get pending => _$this._pending;
  set pending(int? pending) => _$this._pending = pending;

  int? _oldestPendingAgeSeconds;
  int? get oldestPendingAgeSeconds => _$this._oldestPendingAgeSeconds;
  set oldestPendingAgeSeconds(int? oldestPendingAgeSeconds) =>
      _$this._oldestPendingAgeSeconds = oldestPendingAgeSeconds;

  int? _failedLast24h;
  int? get failedLast24h => _$this._failedLast24h;
  set failedLast24h(int? failedLast24h) =>
      _$this._failedLast24h = failedLast24h;

  int? _failedWindowHours;
  int? get failedWindowHours => _$this._failedWindowHours;
  set failedWindowHours(int? failedWindowHours) =>
      _$this._failedWindowHours = failedWindowHours;

  SystemStatusPrintingBuilder() {
    SystemStatusPrinting._defaults(this);
  }

  SystemStatusPrintingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pending = $v.pending;
      _oldestPendingAgeSeconds = $v.oldestPendingAgeSeconds;
      _failedLast24h = $v.failedLast24h;
      _failedWindowHours = $v.failedWindowHours;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusPrinting other) {
    _$v = other as _$SystemStatusPrinting;
  }

  @override
  void update(void Function(SystemStatusPrintingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusPrinting build() => _build();

  _$SystemStatusPrinting _build() {
    final _$result = _$v ??
        _$SystemStatusPrinting._(
          pending: BuiltValueNullFieldError.checkNotNull(
              pending, r'SystemStatusPrinting', 'pending'),
          oldestPendingAgeSeconds: oldestPendingAgeSeconds,
          failedLast24h: BuiltValueNullFieldError.checkNotNull(
              failedLast24h, r'SystemStatusPrinting', 'failedLast24h'),
          failedWindowHours: BuiltValueNullFieldError.checkNotNull(
              failedWindowHours, r'SystemStatusPrinting', 'failedWindowHours'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
