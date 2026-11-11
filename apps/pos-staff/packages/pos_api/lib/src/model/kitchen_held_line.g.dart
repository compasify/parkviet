// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_held_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenHeldLine extends KitchenHeldLine {
  @override
  final String saleLineId;
  @override
  final String name;
  @override
  final String quantity;
  @override
  final int? seat;

  factory _$KitchenHeldLine([void Function(KitchenHeldLineBuilder)? updates]) =>
      (KitchenHeldLineBuilder()..update(updates))._build();

  _$KitchenHeldLine._(
      {required this.saleLineId,
      required this.name,
      required this.quantity,
      this.seat})
      : super._();
  @override
  KitchenHeldLine rebuild(void Function(KitchenHeldLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenHeldLineBuilder toBuilder() => KitchenHeldLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenHeldLine &&
        saleLineId == other.saleLineId &&
        name == other.name &&
        quantity == other.quantity &&
        seat == other.seat;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, saleLineId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, seat.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenHeldLine')
          ..add('saleLineId', saleLineId)
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('seat', seat))
        .toString();
  }
}

class KitchenHeldLineBuilder
    implements Builder<KitchenHeldLine, KitchenHeldLineBuilder> {
  _$KitchenHeldLine? _$v;

  String? _saleLineId;
  String? get saleLineId => _$this._saleLineId;
  set saleLineId(String? saleLineId) => _$this._saleLineId = saleLineId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  int? _seat;
  int? get seat => _$this._seat;
  set seat(int? seat) => _$this._seat = seat;

  KitchenHeldLineBuilder() {
    KitchenHeldLine._defaults(this);
  }

  KitchenHeldLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _saleLineId = $v.saleLineId;
      _name = $v.name;
      _quantity = $v.quantity;
      _seat = $v.seat;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenHeldLine other) {
    _$v = other as _$KitchenHeldLine;
  }

  @override
  void update(void Function(KitchenHeldLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenHeldLine build() => _build();

  _$KitchenHeldLine _build() {
    final _$result = _$v ??
        _$KitchenHeldLine._(
          saleLineId: BuiltValueNullFieldError.checkNotNull(
              saleLineId, r'KitchenHeldLine', 'saleLineId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenHeldLine', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KitchenHeldLine', 'quantity'),
          seat: seat,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
