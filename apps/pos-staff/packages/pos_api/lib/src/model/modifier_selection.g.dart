// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier_selection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModifierSelection extends ModifierSelection {
  @override
  final String optionId;
  @override
  final int? quantity;

  factory _$ModifierSelection(
          [void Function(ModifierSelectionBuilder)? updates]) =>
      (ModifierSelectionBuilder()..update(updates))._build();

  _$ModifierSelection._({required this.optionId, this.quantity}) : super._();
  @override
  ModifierSelection rebuild(void Function(ModifierSelectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModifierSelectionBuilder toBuilder() =>
      ModifierSelectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModifierSelection &&
        optionId == other.optionId &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, optionId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModifierSelection')
          ..add('optionId', optionId)
          ..add('quantity', quantity))
        .toString();
  }
}

class ModifierSelectionBuilder
    implements Builder<ModifierSelection, ModifierSelectionBuilder> {
  _$ModifierSelection? _$v;

  String? _optionId;
  String? get optionId => _$this._optionId;
  set optionId(String? optionId) => _$this._optionId = optionId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  ModifierSelectionBuilder() {
    ModifierSelection._defaults(this);
  }

  ModifierSelectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _optionId = $v.optionId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModifierSelection other) {
    _$v = other as _$ModifierSelection;
  }

  @override
  void update(void Function(ModifierSelectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModifierSelection build() => _build();

  _$ModifierSelection _build() {
    final _$result = _$v ??
        _$ModifierSelection._(
          optionId: BuiltValueNullFieldError.checkNotNull(
              optionId, r'ModifierSelection', 'optionId'),
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
