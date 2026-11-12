// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskOrderLine extends KioskOrderLine {
  @override
  final String name;
  @override
  final String quantity;
  @override
  final String unitPrice;
  @override
  final String amount;
  @override
  final String? note;
  @override
  final BuiltList<KioskOrderModifier> modifiers;

  factory _$KioskOrderLine([void Function(KioskOrderLineBuilder)? updates]) =>
      (KioskOrderLineBuilder()..update(updates))._build();

  _$KioskOrderLine._(
      {required this.name,
      required this.quantity,
      required this.unitPrice,
      required this.amount,
      this.note,
      required this.modifiers})
      : super._();
  @override
  KioskOrderLine rebuild(void Function(KioskOrderLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderLineBuilder toBuilder() => KioskOrderLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderLine &&
        name == other.name &&
        quantity == other.quantity &&
        unitPrice == other.unitPrice &&
        amount == other.amount &&
        note == other.note &&
        modifiers == other.modifiers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrderLine')
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('unitPrice', unitPrice)
          ..add('amount', amount)
          ..add('note', note)
          ..add('modifiers', modifiers))
        .toString();
  }
}

class KioskOrderLineBuilder
    implements Builder<KioskOrderLine, KioskOrderLineBuilder> {
  _$KioskOrderLine? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<KioskOrderModifier>? _modifiers;
  ListBuilder<KioskOrderModifier> get modifiers =>
      _$this._modifiers ??= ListBuilder<KioskOrderModifier>();
  set modifiers(ListBuilder<KioskOrderModifier>? modifiers) =>
      _$this._modifiers = modifiers;

  KioskOrderLineBuilder() {
    KioskOrderLine._defaults(this);
  }

  KioskOrderLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _quantity = $v.quantity;
      _unitPrice = $v.unitPrice;
      _amount = $v.amount;
      _note = $v.note;
      _modifiers = $v.modifiers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderLine other) {
    _$v = other as _$KioskOrderLine;
  }

  @override
  void update(void Function(KioskOrderLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderLine build() => _build();

  _$KioskOrderLine _build() {
    _$KioskOrderLine _$result;
    try {
      _$result = _$v ??
          _$KioskOrderLine._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'KioskOrderLine', 'name'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'KioskOrderLine', 'quantity'),
            unitPrice: BuiltValueNullFieldError.checkNotNull(
                unitPrice, r'KioskOrderLine', 'unitPrice'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'KioskOrderLine', 'amount'),
            note: note,
            modifiers: modifiers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskOrderLine', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
