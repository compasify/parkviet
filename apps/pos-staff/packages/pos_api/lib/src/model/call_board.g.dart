// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_board.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CallBoard extends CallBoard {
  @override
  final BuiltList<CallBoardPreparingInner> preparing;
  @override
  final BuiltList<CallBoardReadyInner> ready;

  factory _$CallBoard([void Function(CallBoardBuilder)? updates]) =>
      (CallBoardBuilder()..update(updates))._build();

  _$CallBoard._({required this.preparing, required this.ready}) : super._();
  @override
  CallBoard rebuild(void Function(CallBoardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CallBoardBuilder toBuilder() => CallBoardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CallBoard &&
        preparing == other.preparing &&
        ready == other.ready;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, preparing.hashCode);
    _$hash = $jc(_$hash, ready.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CallBoard')
          ..add('preparing', preparing)
          ..add('ready', ready))
        .toString();
  }
}

class CallBoardBuilder implements Builder<CallBoard, CallBoardBuilder> {
  _$CallBoard? _$v;

  ListBuilder<CallBoardPreparingInner>? _preparing;
  ListBuilder<CallBoardPreparingInner> get preparing =>
      _$this._preparing ??= ListBuilder<CallBoardPreparingInner>();
  set preparing(ListBuilder<CallBoardPreparingInner>? preparing) =>
      _$this._preparing = preparing;

  ListBuilder<CallBoardReadyInner>? _ready;
  ListBuilder<CallBoardReadyInner> get ready =>
      _$this._ready ??= ListBuilder<CallBoardReadyInner>();
  set ready(ListBuilder<CallBoardReadyInner>? ready) => _$this._ready = ready;

  CallBoardBuilder() {
    CallBoard._defaults(this);
  }

  CallBoardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _preparing = $v.preparing.toBuilder();
      _ready = $v.ready.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CallBoard other) {
    _$v = other as _$CallBoard;
  }

  @override
  void update(void Function(CallBoardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CallBoard build() => _build();

  _$CallBoard _build() {
    _$CallBoard _$result;
    try {
      _$result = _$v ??
          _$CallBoard._(
            preparing: preparing.build(),
            ready: ready.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'preparing';
        preparing.build();
        _$failedField = 'ready';
        ready.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CallBoard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
