// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_today.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerToday extends OwnerToday {
  @override
  final String branchId;
  @override
  final Date businessDate;
  @override
  final String timezone;
  @override
  final String currency;
  @override
  final int orders;
  @override
  final String salesTotal;
  @override
  final String returnsTotal;
  @override
  final String netSales;
  @override
  final BuiltList<OwnerSourceRow> bySource;
  @override
  final BuiltList<OwnerHourRow> byHour;
  @override
  final int openUnits;
  @override
  final int openOrders;
  @override
  final String openTotal;
  @override
  final int openShifts;
  @override
  final int canceledOrders;
  @override
  final int voidedItems;
  @override
  final int pendingApprovals;

  factory _$OwnerToday([void Function(OwnerTodayBuilder)? updates]) =>
      (OwnerTodayBuilder()..update(updates))._build();

  _$OwnerToday._(
      {required this.branchId,
      required this.businessDate,
      required this.timezone,
      required this.currency,
      required this.orders,
      required this.salesTotal,
      required this.returnsTotal,
      required this.netSales,
      required this.bySource,
      required this.byHour,
      required this.openUnits,
      required this.openOrders,
      required this.openTotal,
      required this.openShifts,
      required this.canceledOrders,
      required this.voidedItems,
      required this.pendingApprovals})
      : super._();
  @override
  OwnerToday rebuild(void Function(OwnerTodayBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerTodayBuilder toBuilder() => OwnerTodayBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerToday &&
        branchId == other.branchId &&
        businessDate == other.businessDate &&
        timezone == other.timezone &&
        currency == other.currency &&
        orders == other.orders &&
        salesTotal == other.salesTotal &&
        returnsTotal == other.returnsTotal &&
        netSales == other.netSales &&
        bySource == other.bySource &&
        byHour == other.byHour &&
        openUnits == other.openUnits &&
        openOrders == other.openOrders &&
        openTotal == other.openTotal &&
        openShifts == other.openShifts &&
        canceledOrders == other.canceledOrders &&
        voidedItems == other.voidedItems &&
        pendingApprovals == other.pendingApprovals;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, orders.hashCode);
    _$hash = $jc(_$hash, salesTotal.hashCode);
    _$hash = $jc(_$hash, returnsTotal.hashCode);
    _$hash = $jc(_$hash, netSales.hashCode);
    _$hash = $jc(_$hash, bySource.hashCode);
    _$hash = $jc(_$hash, byHour.hashCode);
    _$hash = $jc(_$hash, openUnits.hashCode);
    _$hash = $jc(_$hash, openOrders.hashCode);
    _$hash = $jc(_$hash, openTotal.hashCode);
    _$hash = $jc(_$hash, openShifts.hashCode);
    _$hash = $jc(_$hash, canceledOrders.hashCode);
    _$hash = $jc(_$hash, voidedItems.hashCode);
    _$hash = $jc(_$hash, pendingApprovals.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerToday')
          ..add('branchId', branchId)
          ..add('businessDate', businessDate)
          ..add('timezone', timezone)
          ..add('currency', currency)
          ..add('orders', orders)
          ..add('salesTotal', salesTotal)
          ..add('returnsTotal', returnsTotal)
          ..add('netSales', netSales)
          ..add('bySource', bySource)
          ..add('byHour', byHour)
          ..add('openUnits', openUnits)
          ..add('openOrders', openOrders)
          ..add('openTotal', openTotal)
          ..add('openShifts', openShifts)
          ..add('canceledOrders', canceledOrders)
          ..add('voidedItems', voidedItems)
          ..add('pendingApprovals', pendingApprovals))
        .toString();
  }
}

class OwnerTodayBuilder implements Builder<OwnerToday, OwnerTodayBuilder> {
  _$OwnerToday? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _orders;
  int? get orders => _$this._orders;
  set orders(int? orders) => _$this._orders = orders;

  String? _salesTotal;
  String? get salesTotal => _$this._salesTotal;
  set salesTotal(String? salesTotal) => _$this._salesTotal = salesTotal;

  String? _returnsTotal;
  String? get returnsTotal => _$this._returnsTotal;
  set returnsTotal(String? returnsTotal) => _$this._returnsTotal = returnsTotal;

  String? _netSales;
  String? get netSales => _$this._netSales;
  set netSales(String? netSales) => _$this._netSales = netSales;

  ListBuilder<OwnerSourceRow>? _bySource;
  ListBuilder<OwnerSourceRow> get bySource =>
      _$this._bySource ??= ListBuilder<OwnerSourceRow>();
  set bySource(ListBuilder<OwnerSourceRow>? bySource) =>
      _$this._bySource = bySource;

  ListBuilder<OwnerHourRow>? _byHour;
  ListBuilder<OwnerHourRow> get byHour =>
      _$this._byHour ??= ListBuilder<OwnerHourRow>();
  set byHour(ListBuilder<OwnerHourRow>? byHour) => _$this._byHour = byHour;

  int? _openUnits;
  int? get openUnits => _$this._openUnits;
  set openUnits(int? openUnits) => _$this._openUnits = openUnits;

  int? _openOrders;
  int? get openOrders => _$this._openOrders;
  set openOrders(int? openOrders) => _$this._openOrders = openOrders;

  String? _openTotal;
  String? get openTotal => _$this._openTotal;
  set openTotal(String? openTotal) => _$this._openTotal = openTotal;

  int? _openShifts;
  int? get openShifts => _$this._openShifts;
  set openShifts(int? openShifts) => _$this._openShifts = openShifts;

  int? _canceledOrders;
  int? get canceledOrders => _$this._canceledOrders;
  set canceledOrders(int? canceledOrders) =>
      _$this._canceledOrders = canceledOrders;

  int? _voidedItems;
  int? get voidedItems => _$this._voidedItems;
  set voidedItems(int? voidedItems) => _$this._voidedItems = voidedItems;

  int? _pendingApprovals;
  int? get pendingApprovals => _$this._pendingApprovals;
  set pendingApprovals(int? pendingApprovals) =>
      _$this._pendingApprovals = pendingApprovals;

  OwnerTodayBuilder() {
    OwnerToday._defaults(this);
  }

  OwnerTodayBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _businessDate = $v.businessDate;
      _timezone = $v.timezone;
      _currency = $v.currency;
      _orders = $v.orders;
      _salesTotal = $v.salesTotal;
      _returnsTotal = $v.returnsTotal;
      _netSales = $v.netSales;
      _bySource = $v.bySource.toBuilder();
      _byHour = $v.byHour.toBuilder();
      _openUnits = $v.openUnits;
      _openOrders = $v.openOrders;
      _openTotal = $v.openTotal;
      _openShifts = $v.openShifts;
      _canceledOrders = $v.canceledOrders;
      _voidedItems = $v.voidedItems;
      _pendingApprovals = $v.pendingApprovals;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerToday other) {
    _$v = other as _$OwnerToday;
  }

  @override
  void update(void Function(OwnerTodayBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerToday build() => _build();

  _$OwnerToday _build() {
    _$OwnerToday _$result;
    try {
      _$result = _$v ??
          _$OwnerToday._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'OwnerToday', 'branchId'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'OwnerToday', 'businessDate'),
            timezone: BuiltValueNullFieldError.checkNotNull(
                timezone, r'OwnerToday', 'timezone'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'OwnerToday', 'currency'),
            orders: BuiltValueNullFieldError.checkNotNull(
                orders, r'OwnerToday', 'orders'),
            salesTotal: BuiltValueNullFieldError.checkNotNull(
                salesTotal, r'OwnerToday', 'salesTotal'),
            returnsTotal: BuiltValueNullFieldError.checkNotNull(
                returnsTotal, r'OwnerToday', 'returnsTotal'),
            netSales: BuiltValueNullFieldError.checkNotNull(
                netSales, r'OwnerToday', 'netSales'),
            bySource: bySource.build(),
            byHour: byHour.build(),
            openUnits: BuiltValueNullFieldError.checkNotNull(
                openUnits, r'OwnerToday', 'openUnits'),
            openOrders: BuiltValueNullFieldError.checkNotNull(
                openOrders, r'OwnerToday', 'openOrders'),
            openTotal: BuiltValueNullFieldError.checkNotNull(
                openTotal, r'OwnerToday', 'openTotal'),
            openShifts: BuiltValueNullFieldError.checkNotNull(
                openShifts, r'OwnerToday', 'openShifts'),
            canceledOrders: BuiltValueNullFieldError.checkNotNull(
                canceledOrders, r'OwnerToday', 'canceledOrders'),
            voidedItems: BuiltValueNullFieldError.checkNotNull(
                voidedItems, r'OwnerToday', 'voidedItems'),
            pendingApprovals: BuiltValueNullFieldError.checkNotNull(
                pendingApprovals, r'OwnerToday', 'pendingApprovals'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'bySource';
        bySource.build();
        _$failedField = 'byHour';
        byHour.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerToday', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
