// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_reject_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSaleRejectInput extends OfflineSaleRejectInput {
  @override
  final String reason;

  factory _$OfflineSaleRejectInput(
          [void Function(OfflineSaleRejectInputBuilder)? updates]) =>
      (OfflineSaleRejectInputBuilder()..update(updates))._build();

  _$OfflineSaleRejectInput._({required this.reason}) : super._();
  @override
  OfflineSaleRejectInput rebuild(
          void Function(OfflineSaleRejectInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleRejectInputBuilder toBuilder() =>
      OfflineSaleRejectInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleRejectInput && reason == other.reason;
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
    return (newBuiltValueToStringHelper(r'OfflineSaleRejectInput')
          ..add('reason', reason))
        .toString();
  }
}

class OfflineSaleRejectInputBuilder
    implements Builder<OfflineSaleRejectInput, OfflineSaleRejectInputBuilder> {
  _$OfflineSaleRejectInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  OfflineSaleRejectInputBuilder() {
    OfflineSaleRejectInput._defaults(this);
  }

  OfflineSaleRejectInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleRejectInput other) {
    _$v = other as _$OfflineSaleRejectInput;
  }

  @override
  void update(void Function(OfflineSaleRejectInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleRejectInput build() => _build();

  _$OfflineSaleRejectInput _build() {
    final _$result = _$v ??
        _$OfflineSaleRejectInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'OfflineSaleRejectInput', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
