// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_service_charge.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceServiceCharge extends WorkspaceServiceCharge {
  @override
  final String? rate;
  @override
  final String amount;
  @override
  final bool waived;
  @override
  final bool applies;

  factory _$WorkspaceServiceCharge(
          [void Function(WorkspaceServiceChargeBuilder)? updates]) =>
      (WorkspaceServiceChargeBuilder()..update(updates))._build();

  _$WorkspaceServiceCharge._(
      {this.rate,
      required this.amount,
      required this.waived,
      required this.applies})
      : super._();
  @override
  WorkspaceServiceCharge rebuild(
          void Function(WorkspaceServiceChargeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceServiceChargeBuilder toBuilder() =>
      WorkspaceServiceChargeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceServiceCharge &&
        rate == other.rate &&
        amount == other.amount &&
        waived == other.waived &&
        applies == other.applies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rate.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, waived.hashCode);
    _$hash = $jc(_$hash, applies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceServiceCharge')
          ..add('rate', rate)
          ..add('amount', amount)
          ..add('waived', waived)
          ..add('applies', applies))
        .toString();
  }
}

class WorkspaceServiceChargeBuilder
    implements Builder<WorkspaceServiceCharge, WorkspaceServiceChargeBuilder> {
  _$WorkspaceServiceCharge? _$v;

  String? _rate;
  String? get rate => _$this._rate;
  set rate(String? rate) => _$this._rate = rate;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  bool? _waived;
  bool? get waived => _$this._waived;
  set waived(bool? waived) => _$this._waived = waived;

  bool? _applies;
  bool? get applies => _$this._applies;
  set applies(bool? applies) => _$this._applies = applies;

  WorkspaceServiceChargeBuilder() {
    WorkspaceServiceCharge._defaults(this);
  }

  WorkspaceServiceChargeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rate = $v.rate;
      _amount = $v.amount;
      _waived = $v.waived;
      _applies = $v.applies;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceServiceCharge other) {
    _$v = other as _$WorkspaceServiceCharge;
  }

  @override
  void update(void Function(WorkspaceServiceChargeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceServiceCharge build() => _build();

  _$WorkspaceServiceCharge _build() {
    final _$result = _$v ??
        _$WorkspaceServiceCharge._(
          rate: rate,
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'WorkspaceServiceCharge', 'amount'),
          waived: BuiltValueNullFieldError.checkNotNull(
              waived, r'WorkspaceServiceCharge', 'waived'),
          applies: BuiltValueNullFieldError.checkNotNull(
              applies, r'WorkspaceServiceCharge', 'applies'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
