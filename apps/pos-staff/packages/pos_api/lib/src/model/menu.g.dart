// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Menu extends Menu {
  @override
  final String branchId;
  @override
  final String currency;
  @override
  final Date businessDate;
  @override
  final bool moduleEnabled;
  @override
  final BuiltList<MenuCategory> categories;
  @override
  final BuiltList<MenuItem> items;
  @override
  final BuiltList<ModifierGroup> modifierGroups;
  @override
  final BuiltList<MenuSchedulesInner> schedules;
  @override
  final BuiltList<String> favorites;
  @override
  final String etag;

  factory _$Menu([void Function(MenuBuilder)? updates]) =>
      (MenuBuilder()..update(updates))._build();

  _$Menu._(
      {required this.branchId,
      required this.currency,
      required this.businessDate,
      required this.moduleEnabled,
      required this.categories,
      required this.items,
      required this.modifierGroups,
      required this.schedules,
      required this.favorites,
      required this.etag})
      : super._();
  @override
  Menu rebuild(void Function(MenuBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuBuilder toBuilder() => MenuBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Menu &&
        branchId == other.branchId &&
        currency == other.currency &&
        businessDate == other.businessDate &&
        moduleEnabled == other.moduleEnabled &&
        categories == other.categories &&
        items == other.items &&
        modifierGroups == other.modifierGroups &&
        schedules == other.schedules &&
        favorites == other.favorites &&
        etag == other.etag;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, moduleEnabled.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, modifierGroups.hashCode);
    _$hash = $jc(_$hash, schedules.hashCode);
    _$hash = $jc(_$hash, favorites.hashCode);
    _$hash = $jc(_$hash, etag.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Menu')
          ..add('branchId', branchId)
          ..add('currency', currency)
          ..add('businessDate', businessDate)
          ..add('moduleEnabled', moduleEnabled)
          ..add('categories', categories)
          ..add('items', items)
          ..add('modifierGroups', modifierGroups)
          ..add('schedules', schedules)
          ..add('favorites', favorites)
          ..add('etag', etag))
        .toString();
  }
}

class MenuBuilder implements Builder<Menu, MenuBuilder> {
  _$Menu? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  bool? _moduleEnabled;
  bool? get moduleEnabled => _$this._moduleEnabled;
  set moduleEnabled(bool? moduleEnabled) =>
      _$this._moduleEnabled = moduleEnabled;

  ListBuilder<MenuCategory>? _categories;
  ListBuilder<MenuCategory> get categories =>
      _$this._categories ??= ListBuilder<MenuCategory>();
  set categories(ListBuilder<MenuCategory>? categories) =>
      _$this._categories = categories;

  ListBuilder<MenuItem>? _items;
  ListBuilder<MenuItem> get items => _$this._items ??= ListBuilder<MenuItem>();
  set items(ListBuilder<MenuItem>? items) => _$this._items = items;

  ListBuilder<ModifierGroup>? _modifierGroups;
  ListBuilder<ModifierGroup> get modifierGroups =>
      _$this._modifierGroups ??= ListBuilder<ModifierGroup>();
  set modifierGroups(ListBuilder<ModifierGroup>? modifierGroups) =>
      _$this._modifierGroups = modifierGroups;

  ListBuilder<MenuSchedulesInner>? _schedules;
  ListBuilder<MenuSchedulesInner> get schedules =>
      _$this._schedules ??= ListBuilder<MenuSchedulesInner>();
  set schedules(ListBuilder<MenuSchedulesInner>? schedules) =>
      _$this._schedules = schedules;

  ListBuilder<String>? _favorites;
  ListBuilder<String> get favorites =>
      _$this._favorites ??= ListBuilder<String>();
  set favorites(ListBuilder<String>? favorites) =>
      _$this._favorites = favorites;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  MenuBuilder() {
    Menu._defaults(this);
  }

  MenuBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _currency = $v.currency;
      _businessDate = $v.businessDate;
      _moduleEnabled = $v.moduleEnabled;
      _categories = $v.categories.toBuilder();
      _items = $v.items.toBuilder();
      _modifierGroups = $v.modifierGroups.toBuilder();
      _schedules = $v.schedules.toBuilder();
      _favorites = $v.favorites.toBuilder();
      _etag = $v.etag;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Menu other) {
    _$v = other as _$Menu;
  }

  @override
  void update(void Function(MenuBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Menu build() => _build();

  _$Menu _build() {
    _$Menu _$result;
    try {
      _$result = _$v ??
          _$Menu._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'Menu', 'branchId'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'Menu', 'currency'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'Menu', 'businessDate'),
            moduleEnabled: BuiltValueNullFieldError.checkNotNull(
                moduleEnabled, r'Menu', 'moduleEnabled'),
            categories: categories.build(),
            items: items.build(),
            modifierGroups: modifierGroups.build(),
            schedules: schedules.build(),
            favorites: favorites.build(),
            etag: BuiltValueNullFieldError.checkNotNull(etag, r'Menu', 'etag'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categories';
        categories.build();
        _$failedField = 'items';
        items.build();
        _$failedField = 'modifierGroups';
        modifierGroups.build();
        _$failedField = 'schedules';
        schedules.build();
        _$failedField = 'favorites';
        favorites.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Menu', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
