// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session_move_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedSessionMoveInput extends TimedSessionMoveInput {
  @override
  final String resourceId;

  factory _$TimedSessionMoveInput(
          [void Function(TimedSessionMoveInputBuilder)? updates]) =>
      (TimedSessionMoveInputBuilder()..update(updates))._build();

  _$TimedSessionMoveInput._({required this.resourceId}) : super._();
  @override
  TimedSessionMoveInput rebuild(
          void Function(TimedSessionMoveInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionMoveInputBuilder toBuilder() =>
      TimedSessionMoveInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSessionMoveInput && resourceId == other.resourceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSessionMoveInput')
          ..add('resourceId', resourceId))
        .toString();
  }
}

class TimedSessionMoveInputBuilder
    implements Builder<TimedSessionMoveInput, TimedSessionMoveInputBuilder> {
  _$TimedSessionMoveInput? _$v;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  TimedSessionMoveInputBuilder() {
    TimedSessionMoveInput._defaults(this);
  }

  TimedSessionMoveInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resourceId = $v.resourceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSessionMoveInput other) {
    _$v = other as _$TimedSessionMoveInput;
  }

  @override
  void update(void Function(TimedSessionMoveInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSessionMoveInput build() => _build();

  _$TimedSessionMoveInput _build() {
    final _$result = _$v ??
        _$TimedSessionMoveInput._(
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'TimedSessionMoveInput', 'resourceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
