// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_line_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderLineInput extends PlatformOrderLineInput {
  @override
  final String variantId;
  @override
  final int quantity;
  @override
  final String? platformPrice;
  @override
  final String? note;
  @override
  final BuiltList<ModifierSelection>? modifiers;

  factory _$PlatformOrderLineInput(
          [void Function(PlatformOrderLineInputBuilder)? updates]) =>
      (PlatformOrderLineInputBuilder()..update(updates))._build();

  _$PlatformOrderLineInput._(
      {required this.variantId,
      required this.quantity,
      this.platformPrice,
      this.note,
      this.modifiers})
      : super._();
  @override
  PlatformOrderLineInput rebuild(
          void Function(PlatformOrderLineInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderLineInputBuilder toBuilder() =>
      PlatformOrderLineInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderLineInput &&
        variantId == other.variantId &&
        quantity == other.quantity &&
        platformPrice == other.platformPrice &&
        note == other.note &&
        modifiers == other.modifiers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, platformPrice.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformOrderLineInput')
          ..add('variantId', variantId)
          ..add('quantity', quantity)
          ..add('platformPrice', platformPrice)
          ..add('note', note)
          ..add('modifiers', modifiers))
        .toString();
  }
}

class PlatformOrderLineInputBuilder
    implements Builder<PlatformOrderLineInput, PlatformOrderLineInputBuilder> {
  _$PlatformOrderLineInput? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _platformPrice;
  String? get platformPrice => _$this._platformPrice;
  set platformPrice(String? platformPrice) =>
      _$this._platformPrice = platformPrice;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<ModifierSelection>? _modifiers;
  ListBuilder<ModifierSelection> get modifiers =>
      _$this._modifiers ??= ListBuilder<ModifierSelection>();
  set modifiers(ListBuilder<ModifierSelection>? modifiers) =>
      _$this._modifiers = modifiers;

  PlatformOrderLineInputBuilder() {
    PlatformOrderLineInput._defaults(this);
  }

  PlatformOrderLineInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _quantity = $v.quantity;
      _platformPrice = $v.platformPrice;
      _note = $v.note;
      _modifiers = $v.modifiers?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderLineInput other) {
    _$v = other as _$PlatformOrderLineInput;
  }

  @override
  void update(void Function(PlatformOrderLineInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderLineInput build() => _build();

  _$PlatformOrderLineInput _build() {
    _$PlatformOrderLineInput _$result;
    try {
      _$result = _$v ??
          _$PlatformOrderLineInput._(
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'PlatformOrderLineInput', 'variantId'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'PlatformOrderLineInput', 'quantity'),
            platformPrice: platformPrice,
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
            r'PlatformOrderLineInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
