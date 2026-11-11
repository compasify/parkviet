// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier_pick.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModifierPick extends ModifierPick {
  @override
  final String optionId;
  @override
  final int? quantity;

  factory _$ModifierPick([void Function(ModifierPickBuilder)? updates]) =>
      (ModifierPickBuilder()..update(updates))._build();

  _$ModifierPick._({required this.optionId, this.quantity}) : super._();
  @override
  ModifierPick rebuild(void Function(ModifierPickBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModifierPickBuilder toBuilder() => ModifierPickBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModifierPick &&
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
    return (newBuiltValueToStringHelper(r'ModifierPick')
          ..add('optionId', optionId)
          ..add('quantity', quantity))
        .toString();
  }
}

class ModifierPickBuilder
    implements Builder<ModifierPick, ModifierPickBuilder> {
  _$ModifierPick? _$v;

  String? _optionId;
  String? get optionId => _$this._optionId;
  set optionId(String? optionId) => _$this._optionId = optionId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  ModifierPickBuilder() {
    ModifierPick._defaults(this);
  }

  ModifierPickBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _optionId = $v.optionId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModifierPick other) {
    _$v = other as _$ModifierPick;
  }

  @override
  void update(void Function(ModifierPickBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModifierPick build() => _build();

  _$ModifierPick _build() {
    final _$result = _$v ??
        _$ModifierPick._(
          optionId: BuiltValueNullFieldError.checkNotNull(
              optionId, r'ModifierPick', 'optionId'),
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
