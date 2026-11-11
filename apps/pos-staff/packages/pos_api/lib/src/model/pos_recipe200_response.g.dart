// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_recipe200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosRecipe200Response extends PosRecipe200Response {
  @override
  final RecipeOwner data;

  factory _$PosRecipe200Response(
          [void Function(PosRecipe200ResponseBuilder)? updates]) =>
      (PosRecipe200ResponseBuilder()..update(updates))._build();

  _$PosRecipe200Response._({required this.data}) : super._();
  @override
  PosRecipe200Response rebuild(
          void Function(PosRecipe200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosRecipe200ResponseBuilder toBuilder() =>
      PosRecipe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosRecipe200Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosRecipe200Response')
          ..add('data', data))
        .toString();
  }
}

class PosRecipe200ResponseBuilder
    implements Builder<PosRecipe200Response, PosRecipe200ResponseBuilder> {
  _$PosRecipe200Response? _$v;

  RecipeOwnerBuilder? _data;
  RecipeOwnerBuilder get data => _$this._data ??= RecipeOwnerBuilder();
  set data(RecipeOwnerBuilder? data) => _$this._data = data;

  PosRecipe200ResponseBuilder() {
    PosRecipe200Response._defaults(this);
  }

  PosRecipe200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosRecipe200Response other) {
    _$v = other as _$PosRecipe200Response;
  }

  @override
  void update(void Function(PosRecipe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosRecipe200Response build() => _build();

  _$PosRecipe200Response _build() {
    _$PosRecipe200Response _$result;
    try {
      _$result = _$v ??
          _$PosRecipe200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosRecipe200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
