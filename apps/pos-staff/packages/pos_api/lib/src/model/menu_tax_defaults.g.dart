// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_tax_defaults.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuTaxDefaults extends MenuTaxDefaults {
  @override
  final String food;
  @override
  final String alcohol;

  factory _$MenuTaxDefaults([void Function(MenuTaxDefaultsBuilder)? updates]) =>
      (MenuTaxDefaultsBuilder()..update(updates))._build();

  _$MenuTaxDefaults._({required this.food, required this.alcohol}) : super._();
  @override
  MenuTaxDefaults rebuild(void Function(MenuTaxDefaultsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuTaxDefaultsBuilder toBuilder() => MenuTaxDefaultsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuTaxDefaults &&
        food == other.food &&
        alcohol == other.alcohol;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, food.hashCode);
    _$hash = $jc(_$hash, alcohol.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuTaxDefaults')
          ..add('food', food)
          ..add('alcohol', alcohol))
        .toString();
  }
}

class MenuTaxDefaultsBuilder
    implements Builder<MenuTaxDefaults, MenuTaxDefaultsBuilder> {
  _$MenuTaxDefaults? _$v;

  String? _food;
  String? get food => _$this._food;
  set food(String? food) => _$this._food = food;

  String? _alcohol;
  String? get alcohol => _$this._alcohol;
  set alcohol(String? alcohol) => _$this._alcohol = alcohol;

  MenuTaxDefaultsBuilder() {
    MenuTaxDefaults._defaults(this);
  }

  MenuTaxDefaultsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _food = $v.food;
      _alcohol = $v.alcohol;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuTaxDefaults other) {
    _$v = other as _$MenuTaxDefaults;
  }

  @override
  void update(void Function(MenuTaxDefaultsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuTaxDefaults build() => _build();

  _$MenuTaxDefaults _build() {
    final _$result = _$v ??
        _$MenuTaxDefaults._(
          food: BuiltValueNullFieldError.checkNotNull(
              food, r'MenuTaxDefaults', 'food'),
          alcohol: BuiltValueNullFieldError.checkNotNull(
              alcohol, r'MenuTaxDefaults', 'alcohol'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
