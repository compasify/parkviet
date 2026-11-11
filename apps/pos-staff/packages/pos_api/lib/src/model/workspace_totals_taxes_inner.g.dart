// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_totals_taxes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceTotalsTaxesInner extends WorkspaceTotalsTaxesInner {
  @override
  final String rate;
  @override
  final String label;
  @override
  final String amount;

  factory _$WorkspaceTotalsTaxesInner(
          [void Function(WorkspaceTotalsTaxesInnerBuilder)? updates]) =>
      (WorkspaceTotalsTaxesInnerBuilder()..update(updates))._build();

  _$WorkspaceTotalsTaxesInner._(
      {required this.rate, required this.label, required this.amount})
      : super._();
  @override
  WorkspaceTotalsTaxesInner rebuild(
          void Function(WorkspaceTotalsTaxesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceTotalsTaxesInnerBuilder toBuilder() =>
      WorkspaceTotalsTaxesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceTotalsTaxesInner &&
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
    return (newBuiltValueToStringHelper(r'WorkspaceTotalsTaxesInner')
          ..add('rate', rate)
          ..add('label', label)
          ..add('amount', amount))
        .toString();
  }
}

class WorkspaceTotalsTaxesInnerBuilder
    implements
        Builder<WorkspaceTotalsTaxesInner, WorkspaceTotalsTaxesInnerBuilder> {
  _$WorkspaceTotalsTaxesInner? _$v;

  String? _rate;
  String? get rate => _$this._rate;
  set rate(String? rate) => _$this._rate = rate;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  WorkspaceTotalsTaxesInnerBuilder() {
    WorkspaceTotalsTaxesInner._defaults(this);
  }

  WorkspaceTotalsTaxesInnerBuilder get _$this {
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
  void replace(WorkspaceTotalsTaxesInner other) {
    _$v = other as _$WorkspaceTotalsTaxesInner;
  }

  @override
  void update(void Function(WorkspaceTotalsTaxesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceTotalsTaxesInner build() => _build();

  _$WorkspaceTotalsTaxesInner _build() {
    final _$result = _$v ??
        _$WorkspaceTotalsTaxesInner._(
          rate: BuiltValueNullFieldError.checkNotNull(
              rate, r'WorkspaceTotalsTaxesInner', 'rate'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'WorkspaceTotalsTaxesInner', 'label'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'WorkspaceTotalsTaxesInner', 'amount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
