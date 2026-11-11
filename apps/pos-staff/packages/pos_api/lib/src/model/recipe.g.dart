// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Recipe extends Recipe {
  @override
  final String id;
  @override
  final int version;
  @override
  final bool active;
  @override
  final DateTime createdAt;
  @override
  final String? estimatedCost;
  @override
  final BuiltList<RecipeIngredientsInner> ingredients;

  factory _$Recipe([void Function(RecipeBuilder)? updates]) =>
      (RecipeBuilder()..update(updates))._build();

  _$Recipe._(
      {required this.id,
      required this.version,
      required this.active,
      required this.createdAt,
      this.estimatedCost,
      required this.ingredients})
      : super._();
  @override
  Recipe rebuild(void Function(RecipeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeBuilder toBuilder() => RecipeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Recipe &&
        id == other.id &&
        version == other.version &&
        active == other.active &&
        createdAt == other.createdAt &&
        estimatedCost == other.estimatedCost &&
        ingredients == other.ingredients;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, estimatedCost.hashCode);
    _$hash = $jc(_$hash, ingredients.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Recipe')
          ..add('id', id)
          ..add('version', version)
          ..add('active', active)
          ..add('createdAt', createdAt)
          ..add('estimatedCost', estimatedCost)
          ..add('ingredients', ingredients))
        .toString();
  }
}

class RecipeBuilder implements Builder<Recipe, RecipeBuilder> {
  _$Recipe? _$v;

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

  String? _estimatedCost;
  String? get estimatedCost => _$this._estimatedCost;
  set estimatedCost(String? estimatedCost) =>
      _$this._estimatedCost = estimatedCost;

  ListBuilder<RecipeIngredientsInner>? _ingredients;
  ListBuilder<RecipeIngredientsInner> get ingredients =>
      _$this._ingredients ??= ListBuilder<RecipeIngredientsInner>();
  set ingredients(ListBuilder<RecipeIngredientsInner>? ingredients) =>
      _$this._ingredients = ingredients;

  RecipeBuilder() {
    Recipe._defaults(this);
  }

  RecipeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _version = $v.version;
      _active = $v.active;
      _createdAt = $v.createdAt;
      _estimatedCost = $v.estimatedCost;
      _ingredients = $v.ingredients.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Recipe other) {
    _$v = other as _$Recipe;
  }

  @override
  void update(void Function(RecipeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Recipe build() => _build();

  _$Recipe _build() {
    _$Recipe _$result;
    try {
      _$result = _$v ??
          _$Recipe._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Recipe', 'id'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'Recipe', 'version'),
            active: BuiltValueNullFieldError.checkNotNull(
                active, r'Recipe', 'active'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Recipe', 'createdAt'),
            estimatedCost: estimatedCost,
            ingredients: ingredients.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ingredients';
        ingredients.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Recipe', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
