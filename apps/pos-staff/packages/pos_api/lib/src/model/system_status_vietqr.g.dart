// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_vietqr.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusVietqr extends SystemStatusVietqr {
  @override
  final DateTime? lastReceivedAt;
  @override
  final int unmatched;

  factory _$SystemStatusVietqr(
          [void Function(SystemStatusVietqrBuilder)? updates]) =>
      (SystemStatusVietqrBuilder()..update(updates))._build();

  _$SystemStatusVietqr._({this.lastReceivedAt, required this.unmatched})
      : super._();
  @override
  SystemStatusVietqr rebuild(
          void Function(SystemStatusVietqrBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusVietqrBuilder toBuilder() =>
      SystemStatusVietqrBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusVietqr &&
        lastReceivedAt == other.lastReceivedAt &&
        unmatched == other.unmatched;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lastReceivedAt.hashCode);
    _$hash = $jc(_$hash, unmatched.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusVietqr')
          ..add('lastReceivedAt', lastReceivedAt)
          ..add('unmatched', unmatched))
        .toString();
  }
}

class SystemStatusVietqrBuilder
    implements Builder<SystemStatusVietqr, SystemStatusVietqrBuilder> {
  _$SystemStatusVietqr? _$v;

  DateTime? _lastReceivedAt;
  DateTime? get lastReceivedAt => _$this._lastReceivedAt;
  set lastReceivedAt(DateTime? lastReceivedAt) =>
      _$this._lastReceivedAt = lastReceivedAt;

  int? _unmatched;
  int? get unmatched => _$this._unmatched;
  set unmatched(int? unmatched) => _$this._unmatched = unmatched;

  SystemStatusVietqrBuilder() {
    SystemStatusVietqr._defaults(this);
  }

  SystemStatusVietqrBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lastReceivedAt = $v.lastReceivedAt;
      _unmatched = $v.unmatched;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusVietqr other) {
    _$v = other as _$SystemStatusVietqr;
  }

  @override
  void update(void Function(SystemStatusVietqrBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusVietqr build() => _build();

  _$SystemStatusVietqr _build() {
    final _$result = _$v ??
        _$SystemStatusVietqr._(
          lastReceivedAt: lastReceivedAt,
          unmatched: BuiltValueNullFieldError.checkNotNull(
              unmatched, r'SystemStatusVietqr', 'unmatched'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
