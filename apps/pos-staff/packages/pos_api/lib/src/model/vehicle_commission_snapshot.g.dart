// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_commission_snapshot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleCommissionSnapshot extends VehicleCommissionSnapshot {
  @override
  final String? amount;
  @override
  final bool? qualified;
  @override
  final String? reason;
  @override
  final int? guestCount;
  @override
  final String? revenue;

  factory _$VehicleCommissionSnapshot(
          [void Function(VehicleCommissionSnapshotBuilder)? updates]) =>
      (VehicleCommissionSnapshotBuilder()..update(updates))._build();

  _$VehicleCommissionSnapshot._(
      {this.amount, this.qualified, this.reason, this.guestCount, this.revenue})
      : super._();
  @override
  VehicleCommissionSnapshot rebuild(
          void Function(VehicleCommissionSnapshotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleCommissionSnapshotBuilder toBuilder() =>
      VehicleCommissionSnapshotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleCommissionSnapshot &&
        amount == other.amount &&
        qualified == other.qualified &&
        reason == other.reason &&
        guestCount == other.guestCount &&
        revenue == other.revenue;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, qualified.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, revenue.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleCommissionSnapshot')
          ..add('amount', amount)
          ..add('qualified', qualified)
          ..add('reason', reason)
          ..add('guestCount', guestCount)
          ..add('revenue', revenue))
        .toString();
  }
}

class VehicleCommissionSnapshotBuilder
    implements
        Builder<VehicleCommissionSnapshot, VehicleCommissionSnapshotBuilder> {
  _$VehicleCommissionSnapshot? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  bool? _qualified;
  bool? get qualified => _$this._qualified;
  set qualified(bool? qualified) => _$this._qualified = qualified;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  String? _revenue;
  String? get revenue => _$this._revenue;
  set revenue(String? revenue) => _$this._revenue = revenue;

  VehicleCommissionSnapshotBuilder() {
    VehicleCommissionSnapshot._defaults(this);
  }

  VehicleCommissionSnapshotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount;
      _qualified = $v.qualified;
      _reason = $v.reason;
      _guestCount = $v.guestCount;
      _revenue = $v.revenue;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleCommissionSnapshot other) {
    _$v = other as _$VehicleCommissionSnapshot;
  }

  @override
  void update(void Function(VehicleCommissionSnapshotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleCommissionSnapshot build() => _build();

  _$VehicleCommissionSnapshot _build() {
    final _$result = _$v ??
        _$VehicleCommissionSnapshot._(
          amount: amount,
          qualified: qualified,
          reason: reason,
          guestCount: guestCount,
          revenue: revenue,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
