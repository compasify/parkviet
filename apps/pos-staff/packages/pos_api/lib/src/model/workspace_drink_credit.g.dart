// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_drink_credit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceDrinkCredit extends WorkspaceDrinkCredit {
  @override
  final String total;
  @override
  final String used;
  @override
  final String remaining;

  factory _$WorkspaceDrinkCredit(
          [void Function(WorkspaceDrinkCreditBuilder)? updates]) =>
      (WorkspaceDrinkCreditBuilder()..update(updates))._build();

  _$WorkspaceDrinkCredit._(
      {required this.total, required this.used, required this.remaining})
      : super._();
  @override
  WorkspaceDrinkCredit rebuild(
          void Function(WorkspaceDrinkCreditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceDrinkCreditBuilder toBuilder() =>
      WorkspaceDrinkCreditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceDrinkCredit &&
        total == other.total &&
        used == other.used &&
        remaining == other.remaining;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, used.hashCode);
    _$hash = $jc(_$hash, remaining.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceDrinkCredit')
          ..add('total', total)
          ..add('used', used)
          ..add('remaining', remaining))
        .toString();
  }
}

class WorkspaceDrinkCreditBuilder
    implements Builder<WorkspaceDrinkCredit, WorkspaceDrinkCreditBuilder> {
  _$WorkspaceDrinkCredit? _$v;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _used;
  String? get used => _$this._used;
  set used(String? used) => _$this._used = used;

  String? _remaining;
  String? get remaining => _$this._remaining;
  set remaining(String? remaining) => _$this._remaining = remaining;

  WorkspaceDrinkCreditBuilder() {
    WorkspaceDrinkCredit._defaults(this);
  }

  WorkspaceDrinkCreditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _used = $v.used;
      _remaining = $v.remaining;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceDrinkCredit other) {
    _$v = other as _$WorkspaceDrinkCredit;
  }

  @override
  void update(void Function(WorkspaceDrinkCreditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceDrinkCredit build() => _build();

  _$WorkspaceDrinkCredit _build() {
    final _$result = _$v ??
        _$WorkspaceDrinkCredit._(
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'WorkspaceDrinkCredit', 'total'),
          used: BuiltValueNullFieldError.checkNotNull(
              used, r'WorkspaceDrinkCredit', 'used'),
          remaining: BuiltValueNullFieldError.checkNotNull(
              remaining, r'WorkspaceDrinkCredit', 'remaining'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
