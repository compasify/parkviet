// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_item_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskOrderItemInput extends KioskOrderItemInput {
  @override
  final String variantId;
  @override
  final int? quantity;
  @override
  final String? note;
  @override
  final BuiltList<ModifierSelection>? modifiers;

  factory _$KioskOrderItemInput(
          [void Function(KioskOrderItemInputBuilder)? updates]) =>
      (KioskOrderItemInputBuilder()..update(updates))._build();

  _$KioskOrderItemInput._(
      {required this.variantId, this.quantity, this.note, this.modifiers})
      : super._();
  @override
  KioskOrderItemInput rebuild(
          void Function(KioskOrderItemInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderItemInputBuilder toBuilder() =>
      KioskOrderItemInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderItemInput &&
        variantId == other.variantId &&
        quantity == other.quantity &&
        note == other.note &&
        modifiers == other.modifiers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrderItemInput')
          ..add('variantId', variantId)
          ..add('quantity', quantity)
          ..add('note', note)
          ..add('modifiers', modifiers))
        .toString();
  }
}

class KioskOrderItemInputBuilder
    implements Builder<KioskOrderItemInput, KioskOrderItemInputBuilder> {
  _$KioskOrderItemInput? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<ModifierSelection>? _modifiers;
  ListBuilder<ModifierSelection> get modifiers =>
      _$this._modifiers ??= ListBuilder<ModifierSelection>();
  set modifiers(ListBuilder<ModifierSelection>? modifiers) =>
      _$this._modifiers = modifiers;

  KioskOrderItemInputBuilder() {
    KioskOrderItemInput._defaults(this);
  }

  KioskOrderItemInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _quantity = $v.quantity;
      _note = $v.note;
      _modifiers = $v.modifiers?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderItemInput other) {
    _$v = other as _$KioskOrderItemInput;
  }

  @override
  void update(void Function(KioskOrderItemInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderItemInput build() => _build();

  _$KioskOrderItemInput _build() {
    _$KioskOrderItemInput _$result;
    try {
      _$result = _$v ??
          _$KioskOrderItemInput._(
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'KioskOrderItemInput', 'variantId'),
            quantity: quantity,
            note: note,
            modifiers: _modifiers?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        _modifiers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskOrderItemInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
