// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'append_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppendItem extends AppendItem {
  @override
  final String variantId;
  @override
  final int? quantity;
  @override
  final BuiltList<ModifierPick>? modifiers;
  @override
  final String? note;

  factory _$AppendItem([void Function(AppendItemBuilder)? updates]) =>
      (AppendItemBuilder()..update(updates))._build();

  _$AppendItem._(
      {required this.variantId, this.quantity, this.modifiers, this.note})
      : super._();
  @override
  AppendItem rebuild(void Function(AppendItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppendItemBuilder toBuilder() => AppendItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppendItem &&
        variantId == other.variantId &&
        quantity == other.quantity &&
        modifiers == other.modifiers &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppendItem')
          ..add('variantId', variantId)
          ..add('quantity', quantity)
          ..add('modifiers', modifiers)
          ..add('note', note))
        .toString();
  }
}

class AppendItemBuilder implements Builder<AppendItem, AppendItemBuilder> {
  _$AppendItem? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  ListBuilder<ModifierPick>? _modifiers;
  ListBuilder<ModifierPick> get modifiers =>
      _$this._modifiers ??= ListBuilder<ModifierPick>();
  set modifiers(ListBuilder<ModifierPick>? modifiers) =>
      _$this._modifiers = modifiers;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  AppendItemBuilder() {
    AppendItem._defaults(this);
  }

  AppendItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _quantity = $v.quantity;
      _modifiers = $v.modifiers?.toBuilder();
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppendItem other) {
    _$v = other as _$AppendItem;
  }

  @override
  void update(void Function(AppendItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppendItem build() => _build();

  _$AppendItem _build() {
    _$AppendItem _$result;
    try {
      _$result = _$v ??
          _$AppendItem._(
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'AppendItem', 'variantId'),
            quantity: quantity,
            modifiers: _modifiers?.build(),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        _modifiers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AppendItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
