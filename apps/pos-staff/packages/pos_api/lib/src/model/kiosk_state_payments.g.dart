// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_state_payments.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskStatePayments extends KioskStatePayments {
  @override
  final bool vietqr;
  @override
  final bool counter;

  factory _$KioskStatePayments(
          [void Function(KioskStatePaymentsBuilder)? updates]) =>
      (KioskStatePaymentsBuilder()..update(updates))._build();

  _$KioskStatePayments._({required this.vietqr, required this.counter})
      : super._();
  @override
  KioskStatePayments rebuild(
          void Function(KioskStatePaymentsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskStatePaymentsBuilder toBuilder() =>
      KioskStatePaymentsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskStatePayments &&
        vietqr == other.vietqr &&
        counter == other.counter;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vietqr.hashCode);
    _$hash = $jc(_$hash, counter.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskStatePayments')
          ..add('vietqr', vietqr)
          ..add('counter', counter))
        .toString();
  }
}

class KioskStatePaymentsBuilder
    implements Builder<KioskStatePayments, KioskStatePaymentsBuilder> {
  _$KioskStatePayments? _$v;

  bool? _vietqr;
  bool? get vietqr => _$this._vietqr;
  set vietqr(bool? vietqr) => _$this._vietqr = vietqr;

  bool? _counter;
  bool? get counter => _$this._counter;
  set counter(bool? counter) => _$this._counter = counter;

  KioskStatePaymentsBuilder() {
    KioskStatePayments._defaults(this);
  }

  KioskStatePaymentsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vietqr = $v.vietqr;
      _counter = $v.counter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskStatePayments other) {
    _$v = other as _$KioskStatePayments;
  }

  @override
  void update(void Function(KioskStatePaymentsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskStatePayments build() => _build();

  _$KioskStatePayments _build() {
    final _$result = _$v ??
        _$KioskStatePayments._(
          vietqr: BuiltValueNullFieldError.checkNotNull(
              vietqr, r'KioskStatePayments', 'vietqr'),
          counter: BuiltValueNullFieldError.checkNotNull(
              counter, r'KioskStatePayments', 'counter'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
