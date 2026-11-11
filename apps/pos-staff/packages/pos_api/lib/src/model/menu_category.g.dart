// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuCategory extends MenuCategory {
  @override
  final String id;
  @override
  final String name;
  @override
  final int position;
  @override
  final String? color;
  @override
  final bool active;

  factory _$MenuCategory([void Function(MenuCategoryBuilder)? updates]) =>
      (MenuCategoryBuilder()..update(updates))._build();

  _$MenuCategory._(
      {required this.id,
      required this.name,
      required this.position,
      this.color,
      required this.active})
      : super._();
  @override
  MenuCategory rebuild(void Function(MenuCategoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuCategoryBuilder toBuilder() => MenuCategoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuCategory &&
        id == other.id &&
        name == other.name &&
        position == other.position &&
        color == other.color &&
        active == other.active;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuCategory')
          ..add('id', id)
          ..add('name', name)
          ..add('position', position)
          ..add('color', color)
          ..add('active', active))
        .toString();
  }
}

class MenuCategoryBuilder
    implements Builder<MenuCategory, MenuCategoryBuilder> {
  _$MenuCategory? _$v;

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

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  MenuCategoryBuilder() {
    MenuCategory._defaults(this);
  }

  MenuCategoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _position = $v.position;
      _color = $v.color;
      _active = $v.active;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuCategory other) {
    _$v = other as _$MenuCategory;
  }

  @override
  void update(void Function(MenuCategoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuCategory build() => _build();

  _$MenuCategory _build() {
    final _$result = _$v ??
        _$MenuCategory._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'MenuCategory', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MenuCategory', 'name'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'MenuCategory', 'position'),
          color: color,
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'MenuCategory', 'active'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
