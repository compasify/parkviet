// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_segment_edit_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedSegmentEditInput extends TimedSegmentEditInput {
  @override
  final String reason;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final String? approvalId;

  factory _$TimedSegmentEditInput(
          [void Function(TimedSegmentEditInputBuilder)? updates]) =>
      (TimedSegmentEditInputBuilder()..update(updates))._build();

  _$TimedSegmentEditInput._(
      {required this.reason, this.startedAt, this.endedAt, this.approvalId})
      : super._();
  @override
  TimedSegmentEditInput rebuild(
          void Function(TimedSegmentEditInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSegmentEditInputBuilder toBuilder() =>
      TimedSegmentEditInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSegmentEditInput &&
        reason == other.reason &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        approvalId == other.approvalId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSegmentEditInput')
          ..add('reason', reason)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('approvalId', approvalId))
        .toString();
  }
}

class TimedSegmentEditInputBuilder
    implements Builder<TimedSegmentEditInput, TimedSegmentEditInputBuilder> {
  _$TimedSegmentEditInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  TimedSegmentEditInputBuilder() {
    TimedSegmentEditInput._defaults(this);
  }

  TimedSegmentEditInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _approvalId = $v.approvalId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSegmentEditInput other) {
    _$v = other as _$TimedSegmentEditInput;
  }

  @override
  void update(void Function(TimedSegmentEditInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSegmentEditInput build() => _build();

  _$TimedSegmentEditInput _build() {
    final _$result = _$v ??
        _$TimedSegmentEditInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'TimedSegmentEditInput', 'reason'),
          startedAt: startedAt,
          endedAt: endedAt,
          approvalId: approvalId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
