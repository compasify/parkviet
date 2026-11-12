// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session_start_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedSessionStartInput extends TimedSessionStartInput {
  @override
  final String branchId;
  @override
  final String editorId;
  @override
  final String? workspaceId;
  @override
  final int? guestCount;
  @override
  final DateTime? plannedEndAt;

  factory _$TimedSessionStartInput(
          [void Function(TimedSessionStartInputBuilder)? updates]) =>
      (TimedSessionStartInputBuilder()..update(updates))._build();

  _$TimedSessionStartInput._(
      {required this.branchId,
      required this.editorId,
      this.workspaceId,
      this.guestCount,
      this.plannedEndAt})
      : super._();
  @override
  TimedSessionStartInput rebuild(
          void Function(TimedSessionStartInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionStartInputBuilder toBuilder() =>
      TimedSessionStartInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSessionStartInput &&
        branchId == other.branchId &&
        editorId == other.editorId &&
        workspaceId == other.workspaceId &&
        guestCount == other.guestCount &&
        plannedEndAt == other.plannedEndAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, plannedEndAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSessionStartInput')
          ..add('branchId', branchId)
          ..add('editorId', editorId)
          ..add('workspaceId', workspaceId)
          ..add('guestCount', guestCount)
          ..add('plannedEndAt', plannedEndAt))
        .toString();
  }
}

class TimedSessionStartInputBuilder
    implements Builder<TimedSessionStartInput, TimedSessionStartInputBuilder> {
  _$TimedSessionStartInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  DateTime? _plannedEndAt;
  DateTime? get plannedEndAt => _$this._plannedEndAt;
  set plannedEndAt(DateTime? plannedEndAt) =>
      _$this._plannedEndAt = plannedEndAt;

  TimedSessionStartInputBuilder() {
    TimedSessionStartInput._defaults(this);
  }

  TimedSessionStartInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _editorId = $v.editorId;
      _workspaceId = $v.workspaceId;
      _guestCount = $v.guestCount;
      _plannedEndAt = $v.plannedEndAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSessionStartInput other) {
    _$v = other as _$TimedSessionStartInput;
  }

  @override
  void update(void Function(TimedSessionStartInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSessionStartInput build() => _build();

  _$TimedSessionStartInput _build() {
    final _$result = _$v ??
        _$TimedSessionStartInput._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'TimedSessionStartInput', 'branchId'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'TimedSessionStartInput', 'editorId'),
          workspaceId: workspaceId,
          guestCount: guestCount,
          plannedEndAt: plannedEndAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
