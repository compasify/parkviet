// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_minimum_spend.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceMinimumSpend extends WorkspaceMinimumSpend {
  @override
  final String minimum;
  @override
  final String amount;
  @override
  final bool waived;

  factory _$WorkspaceMinimumSpend(
          [void Function(WorkspaceMinimumSpendBuilder)? updates]) =>
      (WorkspaceMinimumSpendBuilder()..update(updates))._build();

  _$WorkspaceMinimumSpend._(
      {required this.minimum, required this.amount, required this.waived})
      : super._();
  @override
  WorkspaceMinimumSpend rebuild(
          void Function(WorkspaceMinimumSpendBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceMinimumSpendBuilder toBuilder() =>
      WorkspaceMinimumSpendBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceMinimumSpend &&
        minimum == other.minimum &&
        amount == other.amount &&
        waived == other.waived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minimum.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, waived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceMinimumSpend')
          ..add('minimum', minimum)
          ..add('amount', amount)
          ..add('waived', waived))
        .toString();
  }
}

class WorkspaceMinimumSpendBuilder
    implements Builder<WorkspaceMinimumSpend, WorkspaceMinimumSpendBuilder> {
  _$WorkspaceMinimumSpend? _$v;

  String? _minimum;
  String? get minimum => _$this._minimum;
  set minimum(String? minimum) => _$this._minimum = minimum;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  bool? _waived;
  bool? get waived => _$this._waived;
  set waived(bool? waived) => _$this._waived = waived;

  WorkspaceMinimumSpendBuilder() {
    WorkspaceMinimumSpend._defaults(this);
  }

  WorkspaceMinimumSpendBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minimum = $v.minimum;
      _amount = $v.amount;
      _waived = $v.waived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceMinimumSpend other) {
    _$v = other as _$WorkspaceMinimumSpend;
  }

  @override
  void update(void Function(WorkspaceMinimumSpendBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceMinimumSpend build() => _build();

  _$WorkspaceMinimumSpend _build() {
    final _$result = _$v ??
        _$WorkspaceMinimumSpend._(
          minimum: BuiltValueNullFieldError.checkNotNull(
              minimum, r'WorkspaceMinimumSpend', 'minimum'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'WorkspaceMinimumSpend', 'amount'),
          waived: BuiltValueNullFieldError.checkNotNull(
              waived, r'WorkspaceMinimumSpend', 'waived'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
