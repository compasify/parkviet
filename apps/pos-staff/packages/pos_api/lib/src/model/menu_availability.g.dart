// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_availability.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuAvailability extends MenuAvailability {
  @override
  final String menuItemId;
  @override
  final String branchId;
  @override
  final bool soldOut;
  @override
  final Date businessDate;

  factory _$MenuAvailability(
          [void Function(MenuAvailabilityBuilder)? updates]) =>
      (MenuAvailabilityBuilder()..update(updates))._build();

  _$MenuAvailability._(
      {required this.menuItemId,
      required this.branchId,
      required this.soldOut,
      required this.businessDate})
      : super._();
  @override
  MenuAvailability rebuild(void Function(MenuAvailabilityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuAvailabilityBuilder toBuilder() =>
      MenuAvailabilityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuAvailability &&
        menuItemId == other.menuItemId &&
        branchId == other.branchId &&
        soldOut == other.soldOut &&
        businessDate == other.businessDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, menuItemId.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, soldOut.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuAvailability')
          ..add('menuItemId', menuItemId)
          ..add('branchId', branchId)
          ..add('soldOut', soldOut)
          ..add('businessDate', businessDate))
        .toString();
  }
}

class MenuAvailabilityBuilder
    implements Builder<MenuAvailability, MenuAvailabilityBuilder> {
  _$MenuAvailability? _$v;

  String? _menuItemId;
  String? get menuItemId => _$this._menuItemId;
  set menuItemId(String? menuItemId) => _$this._menuItemId = menuItemId;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  bool? _soldOut;
  bool? get soldOut => _$this._soldOut;
  set soldOut(bool? soldOut) => _$this._soldOut = soldOut;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  MenuAvailabilityBuilder() {
    MenuAvailability._defaults(this);
  }

  MenuAvailabilityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _menuItemId = $v.menuItemId;
      _branchId = $v.branchId;
      _soldOut = $v.soldOut;
      _businessDate = $v.businessDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuAvailability other) {
    _$v = other as _$MenuAvailability;
  }

  @override
  void update(void Function(MenuAvailabilityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuAvailability build() => _build();

  _$MenuAvailability _build() {
    final _$result = _$v ??
        _$MenuAvailability._(
          menuItemId: BuiltValueNullFieldError.checkNotNull(
              menuItemId, r'MenuAvailability', 'menuItemId'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'MenuAvailability', 'branchId'),
          soldOut: BuiltValueNullFieldError.checkNotNull(
              soldOut, r'MenuAvailability', 'soldOut'),
          businessDate: BuiltValueNullFieldError.checkNotNull(
              businessDate, r'MenuAvailability', 'businessDate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
