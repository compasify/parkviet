// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_reject_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestOrderRejectInput extends GuestOrderRejectInput {
  @override
  final String reason;

  factory _$GuestOrderRejectInput(
          [void Function(GuestOrderRejectInputBuilder)? updates]) =>
      (GuestOrderRejectInputBuilder()..update(updates))._build();

  _$GuestOrderRejectInput._({required this.reason}) : super._();
  @override
  GuestOrderRejectInput rebuild(
          void Function(GuestOrderRejectInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderRejectInputBuilder toBuilder() =>
      GuestOrderRejectInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderRejectInput && reason == other.reason;
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
    return (newBuiltValueToStringHelper(r'GuestOrderRejectInput')
          ..add('reason', reason))
        .toString();
  }
}

class GuestOrderRejectInputBuilder
    implements Builder<GuestOrderRejectInput, GuestOrderRejectInputBuilder> {
  _$GuestOrderRejectInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GuestOrderRejectInputBuilder() {
    GuestOrderRejectInput._defaults(this);
  }

  GuestOrderRejectInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderRejectInput other) {
    _$v = other as _$GuestOrderRejectInput;
  }

  @override
  void update(void Function(GuestOrderRejectInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderRejectInput build() => _build();

  _$GuestOrderRejectInput _build() {
    final _$result = _$v ??
        _$GuestOrderRejectInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'GuestOrderRejectInput', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
