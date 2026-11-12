// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_source_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerSourceRow extends OwnerSourceRow {
  @override
  final String orderSource;
  @override
  final int orders;
  @override
  final String salesTotal;
  @override
  final String owed;

  factory _$OwnerSourceRow([void Function(OwnerSourceRowBuilder)? updates]) =>
      (OwnerSourceRowBuilder()..update(updates))._build();

  _$OwnerSourceRow._(
      {required this.orderSource,
      required this.orders,
      required this.salesTotal,
      required this.owed})
      : super._();
  @override
  OwnerSourceRow rebuild(void Function(OwnerSourceRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerSourceRowBuilder toBuilder() => OwnerSourceRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerSourceRow &&
        orderSource == other.orderSource &&
        orders == other.orders &&
        salesTotal == other.salesTotal &&
        owed == other.owed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, orderSource.hashCode);
    _$hash = $jc(_$hash, orders.hashCode);
    _$hash = $jc(_$hash, salesTotal.hashCode);
    _$hash = $jc(_$hash, owed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerSourceRow')
          ..add('orderSource', orderSource)
          ..add('orders', orders)
          ..add('salesTotal', salesTotal)
          ..add('owed', owed))
        .toString();
  }
}

class OwnerSourceRowBuilder
    implements Builder<OwnerSourceRow, OwnerSourceRowBuilder> {
  _$OwnerSourceRow? _$v;

  String? _orderSource;
  String? get orderSource => _$this._orderSource;
  set orderSource(String? orderSource) => _$this._orderSource = orderSource;

  int? _orders;
  int? get orders => _$this._orders;
  set orders(int? orders) => _$this._orders = orders;

  String? _salesTotal;
  String? get salesTotal => _$this._salesTotal;
  set salesTotal(String? salesTotal) => _$this._salesTotal = salesTotal;

  String? _owed;
  String? get owed => _$this._owed;
  set owed(String? owed) => _$this._owed = owed;

  OwnerSourceRowBuilder() {
    OwnerSourceRow._defaults(this);
  }

  OwnerSourceRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _orderSource = $v.orderSource;
      _orders = $v.orders;
      _salesTotal = $v.salesTotal;
      _owed = $v.owed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerSourceRow other) {
    _$v = other as _$OwnerSourceRow;
  }

  @override
  void update(void Function(OwnerSourceRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerSourceRow build() => _build();

  _$OwnerSourceRow _build() {
    final _$result = _$v ??
        _$OwnerSourceRow._(
          orderSource: BuiltValueNullFieldError.checkNotNull(
              orderSource, r'OwnerSourceRow', 'orderSource'),
          orders: BuiltValueNullFieldError.checkNotNull(
              orders, r'OwnerSourceRow', 'orders'),
          salesTotal: BuiltValueNullFieldError.checkNotNull(
              salesTotal, r'OwnerSourceRow', 'salesTotal'),
          owed: BuiltValueNullFieldError.checkNotNull(
              owed, r'OwnerSourceRow', 'owed'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
