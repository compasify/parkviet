// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaxRow extends TaxRow {
  @override
  final String rate;
  @override
  final String label;
  @override
  final String amount;

  factory _$TaxRow([void Function(TaxRowBuilder)? updates]) =>
      (TaxRowBuilder()..update(updates))._build();

  _$TaxRow._({required this.rate, required this.label, required this.amount})
      : super._();
  @override
  TaxRow rebuild(void Function(TaxRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaxRowBuilder toBuilder() => TaxRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaxRow &&
        rate == other.rate &&
        label == other.label &&
        amount == other.amount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rate.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaxRow')
          ..add('rate', rate)
          ..add('label', label)
          ..add('amount', amount))
        .toString();
  }
}

class TaxRowBuilder implements Builder<TaxRow, TaxRowBuilder> {
  _$TaxRow? _$v;

  String? _rate;
  String? get rate => _$this._rate;
  set rate(String? rate) => _$this._rate = rate;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  TaxRowBuilder() {
    TaxRow._defaults(this);
  }

  TaxRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rate = $v.rate;
      _label = $v.label;
      _amount = $v.amount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaxRow other) {
    _$v = other as _$TaxRow;
  }

  @override
  void update(void Function(TaxRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaxRow build() => _build();

  _$TaxRow _build() {
    final _$result = _$v ??
        _$TaxRow._(
          rate: BuiltValueNullFieldError.checkNotNull(rate, r'TaxRow', 'rate'),
          label:
              BuiltValueNullFieldError.checkNotNull(label, r'TaxRow', 'label'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'TaxRow', 'amount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
