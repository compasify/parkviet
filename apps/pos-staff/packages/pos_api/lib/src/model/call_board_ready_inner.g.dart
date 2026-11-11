// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_board_ready_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CallBoardReadyInner extends CallBoardReadyInner {
  @override
  final int number;
  @override
  final String workspaceId;
  @override
  final String? guestName;
  @override
  final DateTime readyAt;

  factory _$CallBoardReadyInner(
          [void Function(CallBoardReadyInnerBuilder)? updates]) =>
      (CallBoardReadyInnerBuilder()..update(updates))._build();

  _$CallBoardReadyInner._(
      {required this.number,
      required this.workspaceId,
      this.guestName,
      required this.readyAt})
      : super._();
  @override
  CallBoardReadyInner rebuild(
          void Function(CallBoardReadyInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CallBoardReadyInnerBuilder toBuilder() =>
      CallBoardReadyInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CallBoardReadyInner &&
        number == other.number &&
        workspaceId == other.workspaceId &&
        guestName == other.guestName &&
        readyAt == other.readyAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, readyAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CallBoardReadyInner')
          ..add('number', number)
          ..add('workspaceId', workspaceId)
          ..add('guestName', guestName)
          ..add('readyAt', readyAt))
        .toString();
  }
}

class CallBoardReadyInnerBuilder
    implements Builder<CallBoardReadyInner, CallBoardReadyInnerBuilder> {
  _$CallBoardReadyInner? _$v;

  int? _number;
  int? get number => _$this._number;
  set number(int? number) => _$this._number = number;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  DateTime? _readyAt;
  DateTime? get readyAt => _$this._readyAt;
  set readyAt(DateTime? readyAt) => _$this._readyAt = readyAt;

  CallBoardReadyInnerBuilder() {
    CallBoardReadyInner._defaults(this);
  }

  CallBoardReadyInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _number = $v.number;
      _workspaceId = $v.workspaceId;
      _guestName = $v.guestName;
      _readyAt = $v.readyAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CallBoardReadyInner other) {
    _$v = other as _$CallBoardReadyInner;
  }

  @override
  void update(void Function(CallBoardReadyInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CallBoardReadyInner build() => _build();

  _$CallBoardReadyInner _build() {
    final _$result = _$v ??
        _$CallBoardReadyInner._(
          number: BuiltValueNullFieldError.checkNotNull(
              number, r'CallBoardReadyInner', 'number'),
          workspaceId: BuiltValueNullFieldError.checkNotNull(
              workspaceId, r'CallBoardReadyInner', 'workspaceId'),
          guestName: guestName,
          readyAt: BuiltValueNullFieldError.checkNotNull(
              readyAt, r'CallBoardReadyInner', 'readyAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
