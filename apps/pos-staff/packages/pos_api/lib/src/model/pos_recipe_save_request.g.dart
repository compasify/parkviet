// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_recipe_save_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosRecipeSaveRequest extends PosRecipeSaveRequest {
  @override
  final String? variantId;
  @override
  final String? modifierOptionId;
  @override
  final bool? confirmStockWriteOff;
  @override
  final BuiltList<PosRecipeSaveRequestIngredientsInner> ingredients;

  factory _$PosRecipeSaveRequest(
          [void Function(PosRecipeSaveRequestBuilder)? updates]) =>
      (PosRecipeSaveRequestBuilder()..update(updates))._build();

  _$PosRecipeSaveRequest._(
      {this.variantId,
      this.modifierOptionId,
      this.confirmStockWriteOff,
      required this.ingredients})
      : super._();
  @override
  PosRecipeSaveRequest rebuild(
          void Function(PosRecipeSaveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosRecipeSaveRequestBuilder toBuilder() =>
      PosRecipeSaveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosRecipeSaveRequest &&
        variantId == other.variantId &&
        modifierOptionId == other.modifierOptionId &&
        confirmStockWriteOff == other.confirmStockWriteOff &&
        ingredients == other.ingredients;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, modifierOptionId.hashCode);
    _$hash = $jc(_$hash, confirmStockWriteOff.hashCode);
    _$hash = $jc(_$hash, ingredients.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosRecipeSaveRequest')
          ..add('variantId', variantId)
          ..add('modifierOptionId', modifierOptionId)
          ..add('confirmStockWriteOff', confirmStockWriteOff)
          ..add('ingredients', ingredients))
        .toString();
  }
}

class PosRecipeSaveRequestBuilder
    implements Builder<PosRecipeSaveRequest, PosRecipeSaveRequestBuilder> {
  _$PosRecipeSaveRequest? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _modifierOptionId;
  String? get modifierOptionId => _$this._modifierOptionId;
  set modifierOptionId(String? modifierOptionId) =>
      _$this._modifierOptionId = modifierOptionId;

  bool? _confirmStockWriteOff;
  bool? get confirmStockWriteOff => _$this._confirmStockWriteOff;
  set confirmStockWriteOff(bool? confirmStockWriteOff) =>
      _$this._confirmStockWriteOff = confirmStockWriteOff;

  ListBuilder<PosRecipeSaveRequestIngredientsInner>? _ingredients;
  ListBuilder<PosRecipeSaveRequestIngredientsInner> get ingredients =>
      _$this._ingredients ??=
          ListBuilder<PosRecipeSaveRequestIngredientsInner>();
  set ingredients(
          ListBuilder<PosRecipeSaveRequestIngredientsInner>? ingredients) =>
      _$this._ingredients = ingredients;

  PosRecipeSaveRequestBuilder() {
    PosRecipeSaveRequest._defaults(this);
  }

  PosRecipeSaveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _modifierOptionId = $v.modifierOptionId;
      _confirmStockWriteOff = $v.confirmStockWriteOff;
      _ingredients = $v.ingredients.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosRecipeSaveRequest other) {
    _$v = other as _$PosRecipeSaveRequest;
  }

  @override
  void update(void Function(PosRecipeSaveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosRecipeSaveRequest build() => _build();

  _$PosRecipeSaveRequest _build() {
    _$PosRecipeSaveRequest _$result;
    try {
      _$result = _$v ??
          _$PosRecipeSaveRequest._(
            variantId: variantId,
            modifierOptionId: modifierOptionId,
            confirmStockWriteOff: confirmStockWriteOff,
            ingredients: ingredients.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ingredients';
        ingredients.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosRecipeSaveRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
