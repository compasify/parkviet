// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_menu_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskMenuCategory extends KioskMenuCategory {
  @override
  final String id;
  @override
  final String name;
  @override
  final int position;
  @override
  final String? color;

  factory _$KioskMenuCategory(
          [void Function(KioskMenuCategoryBuilder)? updates]) =>
      (KioskMenuCategoryBuilder()..update(updates))._build();

  _$KioskMenuCategory._(
      {required this.id,
      required this.name,
      required this.position,
      this.color})
      : super._();
  @override
  KioskMenuCategory rebuild(void Function(KioskMenuCategoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskMenuCategoryBuilder toBuilder() =>
      KioskMenuCategoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskMenuCategory &&
        id == other.id &&
        name == other.name &&
        position == other.position &&
        color == other.color;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskMenuCategory')
          ..add('id', id)
          ..add('name', name)
          ..add('position', position)
          ..add('color', color))
        .toString();
  }
}

class KioskMenuCategoryBuilder
    implements Builder<KioskMenuCategory, KioskMenuCategoryBuilder> {
  _$KioskMenuCategory? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  KioskMenuCategoryBuilder() {
    KioskMenuCategory._defaults(this);
  }

  KioskMenuCategoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _position = $v.position;
      _color = $v.color;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskMenuCategory other) {
    _$v = other as _$KioskMenuCategory;
  }

  @override
  void update(void Function(KioskMenuCategoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskMenuCategory build() => _build();

  _$KioskMenuCategory _build() {
    final _$result = _$v ??
        _$KioskMenuCategory._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KioskMenuCategory', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KioskMenuCategory', 'name'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'KioskMenuCategory', 'position'),
          color: color,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
