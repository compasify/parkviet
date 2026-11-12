// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSaleLine extends OfflineSaleLine {
  @override
  final String variantId;
  @override
  final int quantity;
  @override
  final String unitPrice;
  @override
  final String? name;
  @override
  final String? note;
  @override
  final BuiltList<OfflineSaleLineModifiersInner>? modifiers;

  factory _$OfflineSaleLine([void Function(OfflineSaleLineBuilder)? updates]) =>
      (OfflineSaleLineBuilder()..update(updates))._build();

  _$OfflineSaleLine._(
      {required this.variantId,
      required this.quantity,
      required this.unitPrice,
      this.name,
      this.note,
      this.modifiers})
      : super._();
  @override
  OfflineSaleLine rebuild(void Function(OfflineSaleLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleLineBuilder toBuilder() => OfflineSaleLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleLine &&
        variantId == other.variantId &&
        quantity == other.quantity &&
        unitPrice == other.unitPrice &&
        name == other.name &&
        note == other.note &&
        modifiers == other.modifiers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSaleLine')
          ..add('variantId', variantId)
          ..add('quantity', quantity)
          ..add('unitPrice', unitPrice)
          ..add('name', name)
          ..add('note', note)
          ..add('modifiers', modifiers))
        .toString();
  }
}

class OfflineSaleLineBuilder
    implements Builder<OfflineSaleLine, OfflineSaleLineBuilder> {
  _$OfflineSaleLine? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<OfflineSaleLineModifiersInner>? _modifiers;
  ListBuilder<OfflineSaleLineModifiersInner> get modifiers =>
      _$this._modifiers ??= ListBuilder<OfflineSaleLineModifiersInner>();
  set modifiers(ListBuilder<OfflineSaleLineModifiersInner>? modifiers) =>
      _$this._modifiers = modifiers;

  OfflineSaleLineBuilder() {
    OfflineSaleLine._defaults(this);
  }

  OfflineSaleLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _quantity = $v.quantity;
      _unitPrice = $v.unitPrice;
      _name = $v.name;
      _note = $v.note;
      _modifiers = $v.modifiers?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleLine other) {
    _$v = other as _$OfflineSaleLine;
  }

  @override
  void update(void Function(OfflineSaleLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleLine build() => _build();

  _$OfflineSaleLine _build() {
    _$OfflineSaleLine _$result;
    try {
      _$result = _$v ??
          _$OfflineSaleLine._(
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'OfflineSaleLine', 'variantId'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'OfflineSaleLine', 'quantity'),
            unitPrice: BuiltValueNullFieldError.checkNotNull(
                unitPrice, r'OfflineSaleLine', 'unitPrice'),
            name: name,
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
            r'OfflineSaleLine', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
