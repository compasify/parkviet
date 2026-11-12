// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_hour_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerHourRow extends OwnerHourRow {
  @override
  final int hour;
  @override
  final int orders;
  @override
  final String salesTotal;

  factory _$OwnerHourRow([void Function(OwnerHourRowBuilder)? updates]) =>
      (OwnerHourRowBuilder()..update(updates))._build();

  _$OwnerHourRow._(
      {required this.hour, required this.orders, required this.salesTotal})
      : super._();
  @override
  OwnerHourRow rebuild(void Function(OwnerHourRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerHourRowBuilder toBuilder() => OwnerHourRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerHourRow &&
        hour == other.hour &&
        orders == other.orders &&
        salesTotal == other.salesTotal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hour.hashCode);
    _$hash = $jc(_$hash, orders.hashCode);
    _$hash = $jc(_$hash, salesTotal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerHourRow')
          ..add('hour', hour)
          ..add('orders', orders)
          ..add('salesTotal', salesTotal))
        .toString();
  }
}

class OwnerHourRowBuilder
    implements Builder<OwnerHourRow, OwnerHourRowBuilder> {
  _$OwnerHourRow? _$v;

  int? _hour;
  int? get hour => _$this._hour;
  set hour(int? hour) => _$this._hour = hour;

  int? _orders;
  int? get orders => _$this._orders;
  set orders(int? orders) => _$this._orders = orders;

  String? _salesTotal;
  String? get salesTotal => _$this._salesTotal;
  set salesTotal(String? salesTotal) => _$this._salesTotal = salesTotal;

  OwnerHourRowBuilder() {
    OwnerHourRow._defaults(this);
  }

  OwnerHourRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hour = $v.hour;
      _orders = $v.orders;
      _salesTotal = $v.salesTotal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerHourRow other) {
    _$v = other as _$OwnerHourRow;
  }

  @override
  void update(void Function(OwnerHourRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerHourRow build() => _build();

  _$OwnerHourRow _build() {
    final _$result = _$v ??
        _$OwnerHourRow._(
          hour: BuiltValueNullFieldError.checkNotNull(
              hour, r'OwnerHourRow', 'hour'),
          orders: BuiltValueNullFieldError.checkNotNull(
              orders, r'OwnerHourRow', 'orders'),
          salesTotal: BuiltValueNullFieldError.checkNotNull(
              salesTotal, r'OwnerHourRow', 'salesTotal'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
