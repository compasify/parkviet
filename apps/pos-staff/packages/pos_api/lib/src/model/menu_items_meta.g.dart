// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_items_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuItemsMeta extends MenuItemsMeta {
  @override
  final MenuTaxDefaults taxDefaults;

  factory _$MenuItemsMeta([void Function(MenuItemsMetaBuilder)? updates]) =>
      (MenuItemsMetaBuilder()..update(updates))._build();

  _$MenuItemsMeta._({required this.taxDefaults}) : super._();
  @override
  MenuItemsMeta rebuild(void Function(MenuItemsMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuItemsMetaBuilder toBuilder() => MenuItemsMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuItemsMeta && taxDefaults == other.taxDefaults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxDefaults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuItemsMeta')
          ..add('taxDefaults', taxDefaults))
        .toString();
  }
}

class MenuItemsMetaBuilder
    implements Builder<MenuItemsMeta, MenuItemsMetaBuilder> {
  _$MenuItemsMeta? _$v;

  MenuTaxDefaultsBuilder? _taxDefaults;
  MenuTaxDefaultsBuilder get taxDefaults =>
      _$this._taxDefaults ??= MenuTaxDefaultsBuilder();
  set taxDefaults(MenuTaxDefaultsBuilder? taxDefaults) =>
      _$this._taxDefaults = taxDefaults;

  MenuItemsMetaBuilder() {
    MenuItemsMeta._defaults(this);
  }

  MenuItemsMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxDefaults = $v.taxDefaults.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuItemsMeta other) {
    _$v = other as _$MenuItemsMeta;
  }

  @override
  void update(void Function(MenuItemsMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuItemsMeta build() => _build();

  _$MenuItemsMeta _build() {
    _$MenuItemsMeta _$result;
    try {
      _$result = _$v ??
          _$MenuItemsMeta._(
            taxDefaults: taxDefaults.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taxDefaults';
        taxDefaults.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MenuItemsMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
