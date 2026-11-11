// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_totals_taxes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EinvoiceTotalsTaxesInner extends EinvoiceTotalsTaxesInner {
  @override
  final String? taxRate;
  @override
  final String amountBeforeTax;
  @override
  final String taxAmount;

  factory _$EinvoiceTotalsTaxesInner(
          [void Function(EinvoiceTotalsTaxesInnerBuilder)? updates]) =>
      (EinvoiceTotalsTaxesInnerBuilder()..update(updates))._build();

  _$EinvoiceTotalsTaxesInner._(
      {this.taxRate, required this.amountBeforeTax, required this.taxAmount})
      : super._();
  @override
  EinvoiceTotalsTaxesInner rebuild(
          void Function(EinvoiceTotalsTaxesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceTotalsTaxesInnerBuilder toBuilder() =>
      EinvoiceTotalsTaxesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceTotalsTaxesInner &&
        taxRate == other.taxRate &&
        amountBeforeTax == other.amountBeforeTax &&
        taxAmount == other.taxAmount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxRate.hashCode);
    _$hash = $jc(_$hash, amountBeforeTax.hashCode);
    _$hash = $jc(_$hash, taxAmount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceTotalsTaxesInner')
          ..add('taxRate', taxRate)
          ..add('amountBeforeTax', amountBeforeTax)
          ..add('taxAmount', taxAmount))
        .toString();
  }
}

class EinvoiceTotalsTaxesInnerBuilder
    implements
        Builder<EinvoiceTotalsTaxesInner, EinvoiceTotalsTaxesInnerBuilder> {
  _$EinvoiceTotalsTaxesInner? _$v;

  String? _taxRate;
  String? get taxRate => _$this._taxRate;
  set taxRate(String? taxRate) => _$this._taxRate = taxRate;

  String? _amountBeforeTax;
  String? get amountBeforeTax => _$this._amountBeforeTax;
  set amountBeforeTax(String? amountBeforeTax) =>
      _$this._amountBeforeTax = amountBeforeTax;

  String? _taxAmount;
  String? get taxAmount => _$this._taxAmount;
  set taxAmount(String? taxAmount) => _$this._taxAmount = taxAmount;

  EinvoiceTotalsTaxesInnerBuilder() {
    EinvoiceTotalsTaxesInner._defaults(this);
  }

  EinvoiceTotalsTaxesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxRate = $v.taxRate;
      _amountBeforeTax = $v.amountBeforeTax;
      _taxAmount = $v.taxAmount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceTotalsTaxesInner other) {
    _$v = other as _$EinvoiceTotalsTaxesInner;
  }

  @override
  void update(void Function(EinvoiceTotalsTaxesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceTotalsTaxesInner build() => _build();

  _$EinvoiceTotalsTaxesInner _build() {
    final _$result = _$v ??
        _$EinvoiceTotalsTaxesInner._(
          taxRate: taxRate,
          amountBeforeTax: BuiltValueNullFieldError.checkNotNull(
              amountBeforeTax, r'EinvoiceTotalsTaxesInner', 'amountBeforeTax'),
          taxAmount: BuiltValueNullFieldError.checkNotNull(
              taxAmount, r'EinvoiceTotalsTaxesInner', 'taxAmount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
