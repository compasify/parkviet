// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_owner_versions_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecipeOwnerVersionsInner extends RecipeOwnerVersionsInner {
  @override
  final String id;
  @override
  final int version;
  @override
  final bool active;
  @override
  final DateTime createdAt;
  @override
  final int ingredients;

  factory _$RecipeOwnerVersionsInner(
          [void Function(RecipeOwnerVersionsInnerBuilder)? updates]) =>
      (RecipeOwnerVersionsInnerBuilder()..update(updates))._build();

  _$RecipeOwnerVersionsInner._(
      {required this.id,
      required this.version,
      required this.active,
      required this.createdAt,
      required this.ingredients})
      : super._();
  @override
  RecipeOwnerVersionsInner rebuild(
          void Function(RecipeOwnerVersionsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeOwnerVersionsInnerBuilder toBuilder() =>
      RecipeOwnerVersionsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeOwnerVersionsInner &&
        id == other.id &&
        version == other.version &&
        active == other.active &&
        createdAt == other.createdAt &&
        ingredients == other.ingredients;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, ingredients.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecipeOwnerVersionsInner')
          ..add('id', id)
          ..add('version', version)
          ..add('active', active)
          ..add('createdAt', createdAt)
          ..add('ingredients', ingredients))
        .toString();
  }
}

class RecipeOwnerVersionsInnerBuilder
    implements
        Builder<RecipeOwnerVersionsInner, RecipeOwnerVersionsInnerBuilder> {
  _$RecipeOwnerVersionsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _ingredients;
  int? get ingredients => _$this._ingredients;
  set ingredients(int? ingredients) => _$this._ingredients = ingredients;

  RecipeOwnerVersionsInnerBuilder() {
    RecipeOwnerVersionsInner._defaults(this);
  }

  RecipeOwnerVersionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _version = $v.version;
      _active = $v.active;
      _createdAt = $v.createdAt;
      _ingredients = $v.ingredients;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecipeOwnerVersionsInner other) {
    _$v = other as _$RecipeOwnerVersionsInner;
  }

  @override
  void update(void Function(RecipeOwnerVersionsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecipeOwnerVersionsInner build() => _build();

  _$RecipeOwnerVersionsInner _build() {
    final _$result = _$v ??
        _$RecipeOwnerVersionsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RecipeOwnerVersionsInner', 'id'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'RecipeOwnerVersionsInner', 'version'),
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'RecipeOwnerVersionsInner', 'active'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RecipeOwnerVersionsInner', 'createdAt'),
          ingredients: BuiltValueNullFieldError.checkNotNull(
              ingredients, r'RecipeOwnerVersionsInner', 'ingredients'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
