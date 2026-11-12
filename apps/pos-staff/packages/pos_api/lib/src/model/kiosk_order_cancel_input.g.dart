// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_cancel_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskOrderCancelInput extends KioskOrderCancelInput {
  @override
  final String? reason;

  factory _$KioskOrderCancelInput(
          [void Function(KioskOrderCancelInputBuilder)? updates]) =>
      (KioskOrderCancelInputBuilder()..update(updates))._build();

  _$KioskOrderCancelInput._({this.reason}) : super._();
  @override
  KioskOrderCancelInput rebuild(
          void Function(KioskOrderCancelInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderCancelInputBuilder toBuilder() =>
      KioskOrderCancelInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderCancelInput && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrderCancelInput')
          ..add('reason', reason))
        .toString();
  }
}

class KioskOrderCancelInputBuilder
    implements Builder<KioskOrderCancelInput, KioskOrderCancelInputBuilder> {
  _$KioskOrderCancelInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  KioskOrderCancelInputBuilder() {
    KioskOrderCancelInput._defaults(this);
  }

  KioskOrderCancelInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderCancelInput other) {
    _$v = other as _$KioskOrderCancelInput;
  }

  @override
  void update(void Function(KioskOrderCancelInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderCancelInput build() => _build();

  _$KioskOrderCancelInput _build() {
    final _$result = _$v ??
        _$KioskOrderCancelInput._(
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
