// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session_command_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedSessionCommandResult extends TimedSessionCommandResult {
  @override
  final TimedSessionCommand data;

  factory _$TimedSessionCommandResult(
          [void Function(TimedSessionCommandResultBuilder)? updates]) =>
      (TimedSessionCommandResultBuilder()..update(updates))._build();

  _$TimedSessionCommandResult._({required this.data}) : super._();
  @override
  TimedSessionCommandResult rebuild(
          void Function(TimedSessionCommandResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionCommandResultBuilder toBuilder() =>
      TimedSessionCommandResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSessionCommandResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TimedSessionCommandResult')
          ..add('data', data))
        .toString();
  }
}

class TimedSessionCommandResultBuilder
    implements
        Builder<TimedSessionCommandResult, TimedSessionCommandResultBuilder> {
  _$TimedSessionCommandResult? _$v;

  TimedSessionCommandBuilder? _data;
  TimedSessionCommandBuilder get data =>
      _$this._data ??= TimedSessionCommandBuilder();
  set data(TimedSessionCommandBuilder? data) => _$this._data = data;

  TimedSessionCommandResultBuilder() {
    TimedSessionCommandResult._defaults(this);
  }

  TimedSessionCommandResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSessionCommandResult other) {
    _$v = other as _$TimedSessionCommandResult;
  }

  @override
  void update(void Function(TimedSessionCommandResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSessionCommandResult build() => _build();

  _$TimedSessionCommandResult _build() {
    _$TimedSessionCommandResult _$result;
    try {
      _$result = _$v ??
          _$TimedSessionCommandResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimedSessionCommandResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
