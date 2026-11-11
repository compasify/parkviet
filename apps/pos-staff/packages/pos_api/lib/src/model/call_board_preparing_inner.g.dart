// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_board_preparing_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CallBoardPreparingInner extends CallBoardPreparingInner {
  @override
  final int number;
  @override
  final String workspaceId;

  factory _$CallBoardPreparingInner(
          [void Function(CallBoardPreparingInnerBuilder)? updates]) =>
      (CallBoardPreparingInnerBuilder()..update(updates))._build();

  _$CallBoardPreparingInner._({required this.number, required this.workspaceId})
      : super._();
  @override
  CallBoardPreparingInner rebuild(
          void Function(CallBoardPreparingInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CallBoardPreparingInnerBuilder toBuilder() =>
      CallBoardPreparingInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CallBoardPreparingInner &&
        number == other.number &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CallBoardPreparingInner')
          ..add('number', number)
          ..add('workspaceId', workspaceId))
        .toString();
  }
}

class CallBoardPreparingInnerBuilder
    implements
        Builder<CallBoardPreparingInner, CallBoardPreparingInnerBuilder> {
  _$CallBoardPreparingInner? _$v;

  int? _number;
  int? get number => _$this._number;
  set number(int? number) => _$this._number = number;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  CallBoardPreparingInnerBuilder() {
    CallBoardPreparingInner._defaults(this);
  }

  CallBoardPreparingInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _number = $v.number;
      _workspaceId = $v.workspaceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CallBoardPreparingInner other) {
    _$v = other as _$CallBoardPreparingInner;
  }

  @override
  void update(void Function(CallBoardPreparingInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CallBoardPreparingInner build() => _build();

  _$CallBoardPreparingInner _build() {
    final _$result = _$v ??
        _$CallBoardPreparingInner._(
          number: BuiltValueNullFieldError.checkNotNull(
              number, r'CallBoardPreparingInner', 'number'),
          workspaceId: BuiltValueNullFieldError.checkNotNull(
              workspaceId, r'CallBoardPreparingInner', 'workspaceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
