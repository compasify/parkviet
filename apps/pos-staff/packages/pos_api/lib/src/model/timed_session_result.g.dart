// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedSessionResult extends TimedSessionResult {
  @override
  final TimedSession data;

  factory _$TimedSessionResult(
          [void Function(TimedSessionResultBuilder)? updates]) =>
      (TimedSessionResultBuilder()..update(updates))._build();

  _$TimedSessionResult._({required this.data}) : super._();
  @override
  TimedSessionResult rebuild(
          void Function(TimedSessionResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionResultBuilder toBuilder() =>
      TimedSessionResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSessionResult && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSessionResult')
          ..add('data', data))
        .toString();
  }
}

class TimedSessionResultBuilder
    implements Builder<TimedSessionResult, TimedSessionResultBuilder> {
  _$TimedSessionResult? _$v;

  TimedSessionBuilder? _data;
  TimedSessionBuilder get data => _$this._data ??= TimedSessionBuilder();
  set data(TimedSessionBuilder? data) => _$this._data = data;

  TimedSessionResultBuilder() {
    TimedSessionResult._defaults(this);
  }

  TimedSessionResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSessionResult other) {
    _$v = other as _$TimedSessionResult;
  }

  @override
  void update(void Function(TimedSessionResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSessionResult build() => _build();

  _$TimedSessionResult _build() {
    _$TimedSessionResult _$result;
    try {
      _$result = _$v ??
          _$TimedSessionResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimedSessionResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
