// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_menu.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskMenu extends KioskMenu {
  @override
  final String currency;
  @override
  final String etag;
  @override
  final BuiltList<KioskMenuCategory> categories;
  @override
  final BuiltList<KioskMenuItem> items;
  @override
  final BuiltList<KioskModifierGroup> modifierGroups;

  factory _$KioskMenu([void Function(KioskMenuBuilder)? updates]) =>
      (KioskMenuBuilder()..update(updates))._build();

  _$KioskMenu._(
      {required this.currency,
      required this.etag,
      required this.categories,
      required this.items,
      required this.modifierGroups})
      : super._();
  @override
  KioskMenu rebuild(void Function(KioskMenuBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskMenuBuilder toBuilder() => KioskMenuBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskMenu &&
        currency == other.currency &&
        etag == other.etag &&
        categories == other.categories &&
        items == other.items &&
        modifierGroups == other.modifierGroups;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, etag.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, modifierGroups.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskMenu')
          ..add('currency', currency)
          ..add('etag', etag)
          ..add('categories', categories)
          ..add('items', items)
          ..add('modifierGroups', modifierGroups))
        .toString();
  }
}

class KioskMenuBuilder implements Builder<KioskMenu, KioskMenuBuilder> {
  _$KioskMenu? _$v;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  ListBuilder<KioskMenuCategory>? _categories;
  ListBuilder<KioskMenuCategory> get categories =>
      _$this._categories ??= ListBuilder<KioskMenuCategory>();
  set categories(ListBuilder<KioskMenuCategory>? categories) =>
      _$this._categories = categories;

  ListBuilder<KioskMenuItem>? _items;
  ListBuilder<KioskMenuItem> get items =>
      _$this._items ??= ListBuilder<KioskMenuItem>();
  set items(ListBuilder<KioskMenuItem>? items) => _$this._items = items;

  ListBuilder<KioskModifierGroup>? _modifierGroups;
  ListBuilder<KioskModifierGroup> get modifierGroups =>
      _$this._modifierGroups ??= ListBuilder<KioskModifierGroup>();
  set modifierGroups(ListBuilder<KioskModifierGroup>? modifierGroups) =>
      _$this._modifierGroups = modifierGroups;

  KioskMenuBuilder() {
    KioskMenu._defaults(this);
  }

  KioskMenuBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currency = $v.currency;
      _etag = $v.etag;
      _categories = $v.categories.toBuilder();
      _items = $v.items.toBuilder();
      _modifierGroups = $v.modifierGroups.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskMenu other) {
    _$v = other as _$KioskMenu;
  }

  @override
  void update(void Function(KioskMenuBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskMenu build() => _build();

  _$KioskMenu _build() {
    _$KioskMenu _$result;
    try {
      _$result = _$v ??
          _$KioskMenu._(
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'KioskMenu', 'currency'),
            etag: BuiltValueNullFieldError.checkNotNull(
                etag, r'KioskMenu', 'etag'),
            categories: categories.build(),
            items: items.build(),
            modifierGroups: modifierGroups.build(),
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
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskMenu', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
