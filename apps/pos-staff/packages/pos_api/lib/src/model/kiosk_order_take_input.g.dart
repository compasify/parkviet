// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_take_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskOrderTakeInput extends KioskOrderTakeInput {
  @override
  final String editorId;

  factory _$KioskOrderTakeInput(
          [void Function(KioskOrderTakeInputBuilder)? updates]) =>
      (KioskOrderTakeInputBuilder()..update(updates))._build();

  _$KioskOrderTakeInput._({required this.editorId}) : super._();
  @override
  KioskOrderTakeInput rebuild(
          void Function(KioskOrderTakeInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderTakeInputBuilder toBuilder() =>
      KioskOrderTakeInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderTakeInput && editorId == other.editorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrderTakeInput')
          ..add('editorId', editorId))
        .toString();
  }
}

class KioskOrderTakeInputBuilder
    implements Builder<KioskOrderTakeInput, KioskOrderTakeInputBuilder> {
  _$KioskOrderTakeInput? _$v;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  KioskOrderTakeInputBuilder() {
    KioskOrderTakeInput._defaults(this);
  }

  KioskOrderTakeInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editorId = $v.editorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderTakeInput other) {
    _$v = other as _$KioskOrderTakeInput;
  }

  @override
  void update(void Function(KioskOrderTakeInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderTakeInput build() => _build();

  _$KioskOrderTakeInput _build() {
    final _$result = _$v ??
        _$KioskOrderTakeInput._(
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'KioskOrderTakeInput', 'editorId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
