// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_margin_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuMarginRow extends MenuMarginRow {
  @override
  final String menuItem;
  @override
  final String? sku;
  @override
  final int quantity;
  @override
  final String revenue;
  @override
  final String cost;
  @override
  final String margin;
  @override
  final String? marginRate;
  @override
  final bool costed;

  factory _$MenuMarginRow([void Function(MenuMarginRowBuilder)? updates]) =>
      (MenuMarginRowBuilder()..update(updates))._build();

  _$MenuMarginRow._(
      {required this.menuItem,
      this.sku,
      required this.quantity,
      required this.revenue,
      required this.cost,
      required this.margin,
      this.marginRate,
      required this.costed})
      : super._();
  @override
  MenuMarginRow rebuild(void Function(MenuMarginRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuMarginRowBuilder toBuilder() => MenuMarginRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuMarginRow &&
        menuItem == other.menuItem &&
        sku == other.sku &&
        quantity == other.quantity &&
        revenue == other.revenue &&
        cost == other.cost &&
        margin == other.margin &&
        marginRate == other.marginRate &&
        costed == other.costed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, menuItem.hashCode);
    _$hash = $jc(_$hash, sku.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, revenue.hashCode);
    _$hash = $jc(_$hash, cost.hashCode);
    _$hash = $jc(_$hash, margin.hashCode);
    _$hash = $jc(_$hash, marginRate.hashCode);
    _$hash = $jc(_$hash, costed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuMarginRow')
          ..add('menuItem', menuItem)
          ..add('sku', sku)
          ..add('quantity', quantity)
          ..add('revenue', revenue)
          ..add('cost', cost)
          ..add('margin', margin)
          ..add('marginRate', marginRate)
          ..add('costed', costed))
        .toString();
  }
}

class MenuMarginRowBuilder
    implements Builder<MenuMarginRow, MenuMarginRowBuilder> {
  _$MenuMarginRow? _$v;

  String? _menuItem;
  String? get menuItem => _$this._menuItem;
  set menuItem(String? menuItem) => _$this._menuItem = menuItem;

  String? _sku;
  String? get sku => _$this._sku;
  set sku(String? sku) => _$this._sku = sku;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _revenue;
  String? get revenue => _$this._revenue;
  set revenue(String? revenue) => _$this._revenue = revenue;

  String? _cost;
  String? get cost => _$this._cost;
  set cost(String? cost) => _$this._cost = cost;

  String? _margin;
  String? get margin => _$this._margin;
  set margin(String? margin) => _$this._margin = margin;

  String? _marginRate;
  String? get marginRate => _$this._marginRate;
  set marginRate(String? marginRate) => _$this._marginRate = marginRate;

  bool? _costed;
  bool? get costed => _$this._costed;
  set costed(bool? costed) => _$this._costed = costed;

  MenuMarginRowBuilder() {
    MenuMarginRow._defaults(this);
  }

  MenuMarginRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _menuItem = $v.menuItem;
      _sku = $v.sku;
      _quantity = $v.quantity;
      _revenue = $v.revenue;
      _cost = $v.cost;
      _margin = $v.margin;
      _marginRate = $v.marginRate;
      _costed = $v.costed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuMarginRow other) {
    _$v = other as _$MenuMarginRow;
  }

  @override
  void update(void Function(MenuMarginRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuMarginRow build() => _build();

  _$MenuMarginRow _build() {
    final _$result = _$v ??
        _$MenuMarginRow._(
          menuItem: BuiltValueNullFieldError.checkNotNull(
              menuItem, r'MenuMarginRow', 'menuItem'),
          sku: sku,
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'MenuMarginRow', 'quantity'),
          revenue: BuiltValueNullFieldError.checkNotNull(
              revenue, r'MenuMarginRow', 'revenue'),
          cost: BuiltValueNullFieldError.checkNotNull(
              cost, r'MenuMarginRow', 'cost'),
          margin: BuiltValueNullFieldError.checkNotNull(
              margin, r'MenuMarginRow', 'margin'),
          marginRate: marginRate,
          costed: BuiltValueNullFieldError.checkNotNull(
              costed, r'MenuMarginRow', 'costed'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
