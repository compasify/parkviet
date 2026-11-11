// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_totals.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EinvoiceTotals extends EinvoiceTotals {
  @override
  final String? amountBeforeTax;
  @override
  final String? taxAmount;
  @override
  final String? discountTotal;
  @override
  final String? total;
  @override
  final BuiltList<EinvoiceTotalsTaxesInner>? taxes;

  factory _$EinvoiceTotals([void Function(EinvoiceTotalsBuilder)? updates]) =>
      (EinvoiceTotalsBuilder()..update(updates))._build();

  _$EinvoiceTotals._(
      {this.amountBeforeTax,
      this.taxAmount,
      this.discountTotal,
      this.total,
      this.taxes})
      : super._();
  @override
  EinvoiceTotals rebuild(void Function(EinvoiceTotalsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceTotalsBuilder toBuilder() => EinvoiceTotalsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceTotals &&
        amountBeforeTax == other.amountBeforeTax &&
        taxAmount == other.taxAmount &&
        discountTotal == other.discountTotal &&
        total == other.total &&
        taxes == other.taxes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amountBeforeTax.hashCode);
    _$hash = $jc(_$hash, taxAmount.hashCode);
    _$hash = $jc(_$hash, discountTotal.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, taxes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceTotals')
          ..add('amountBeforeTax', amountBeforeTax)
          ..add('taxAmount', taxAmount)
          ..add('discountTotal', discountTotal)
          ..add('total', total)
          ..add('taxes', taxes))
        .toString();
  }
}

class EinvoiceTotalsBuilder
    implements Builder<EinvoiceTotals, EinvoiceTotalsBuilder> {
  _$EinvoiceTotals? _$v;

  String? _amountBeforeTax;
  String? get amountBeforeTax => _$this._amountBeforeTax;
  set amountBeforeTax(String? amountBeforeTax) =>
      _$this._amountBeforeTax = amountBeforeTax;

  String? _taxAmount;
  String? get taxAmount => _$this._taxAmount;
  set taxAmount(String? taxAmount) => _$this._taxAmount = taxAmount;

  String? _discountTotal;
  String? get discountTotal => _$this._discountTotal;
  set discountTotal(String? discountTotal) =>
      _$this._discountTotal = discountTotal;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  ListBuilder<EinvoiceTotalsTaxesInner>? _taxes;
  ListBuilder<EinvoiceTotalsTaxesInner> get taxes =>
      _$this._taxes ??= ListBuilder<EinvoiceTotalsTaxesInner>();
  set taxes(ListBuilder<EinvoiceTotalsTaxesInner>? taxes) =>
      _$this._taxes = taxes;

  EinvoiceTotalsBuilder() {
    EinvoiceTotals._defaults(this);
  }

  EinvoiceTotalsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amountBeforeTax = $v.amountBeforeTax;
      _taxAmount = $v.taxAmount;
      _discountTotal = $v.discountTotal;
      _total = $v.total;
      _taxes = $v.taxes?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceTotals other) {
    _$v = other as _$EinvoiceTotals;
  }

  @override
  void update(void Function(EinvoiceTotalsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceTotals build() => _build();

  _$EinvoiceTotals _build() {
    _$EinvoiceTotals _$result;
    try {
      _$result = _$v ??
          _$EinvoiceTotals._(
            amountBeforeTax: amountBeforeTax,
            taxAmount: taxAmount,
            discountTotal: discountTotal,
            total: total,
            taxes: _taxes?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taxes';
        _taxes?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EinvoiceTotals', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
