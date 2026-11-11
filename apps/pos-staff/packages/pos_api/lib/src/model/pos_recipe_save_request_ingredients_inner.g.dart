// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_recipe_save_request_ingredients_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosRecipeSaveRequestIngredientsInner
    extends PosRecipeSaveRequestIngredientsInner {
  @override
  final String variantId;
  @override
  final String quantity;
  @override
  final String unitCode;

  factory _$PosRecipeSaveRequestIngredientsInner(
          [void Function(PosRecipeSaveRequestIngredientsInnerBuilder)?
              updates]) =>
      (PosRecipeSaveRequestIngredientsInnerBuilder()..update(updates))._build();

  _$PosRecipeSaveRequestIngredientsInner._(
      {required this.variantId, required this.quantity, required this.unitCode})
      : super._();
  @override
  PosRecipeSaveRequestIngredientsInner rebuild(
          void Function(PosRecipeSaveRequestIngredientsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosRecipeSaveRequestIngredientsInnerBuilder toBuilder() =>
      PosRecipeSaveRequestIngredientsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosRecipeSaveRequestIngredientsInner &&
        variantId == other.variantId &&
        quantity == other.quantity &&
        unitCode == other.unitCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unitCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosRecipeSaveRequestIngredientsInner')
          ..add('variantId', variantId)
          ..add('quantity', quantity)
          ..add('unitCode', unitCode))
        .toString();
  }
}

class PosRecipeSaveRequestIngredientsInnerBuilder
    implements
        Builder<PosRecipeSaveRequestIngredientsInner,
            PosRecipeSaveRequestIngredientsInnerBuilder> {
  _$PosRecipeSaveRequestIngredientsInner? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _unitCode;
  String? get unitCode => _$this._unitCode;
  set unitCode(String? unitCode) => _$this._unitCode = unitCode;

  PosRecipeSaveRequestIngredientsInnerBuilder() {
    PosRecipeSaveRequestIngredientsInner._defaults(this);
  }

  PosRecipeSaveRequestIngredientsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _quantity = $v.quantity;
      _unitCode = $v.unitCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosRecipeSaveRequestIngredientsInner other) {
    _$v = other as _$PosRecipeSaveRequestIngredientsInner;
  }

  @override
  void update(
      void Function(PosRecipeSaveRequestIngredientsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosRecipeSaveRequestIngredientsInner build() => _build();

  _$PosRecipeSaveRequestIngredientsInner _build() {
    final _$result = _$v ??
        _$PosRecipeSaveRequestIngredientsInner._(
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'PosRecipeSaveRequestIngredientsInner', 'variantId'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'PosRecipeSaveRequestIngredientsInner', 'quantity'),
          unitCode: BuiltValueNullFieldError.checkNotNull(
              unitCode, r'PosRecipeSaveRequestIngredientsInner', 'unitCode'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
