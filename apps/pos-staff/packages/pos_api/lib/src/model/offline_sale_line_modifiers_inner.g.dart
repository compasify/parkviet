// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_line_modifiers_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSaleLineModifiersInner extends OfflineSaleLineModifiersInner {
  @override
  final String optionId;
  @override
  final int? quantity;

  factory _$OfflineSaleLineModifiersInner(
          [void Function(OfflineSaleLineModifiersInnerBuilder)? updates]) =>
      (OfflineSaleLineModifiersInnerBuilder()..update(updates))._build();

  _$OfflineSaleLineModifiersInner._({required this.optionId, this.quantity})
      : super._();
  @override
  OfflineSaleLineModifiersInner rebuild(
          void Function(OfflineSaleLineModifiersInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleLineModifiersInnerBuilder toBuilder() =>
      OfflineSaleLineModifiersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleLineModifiersInner &&
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
    return (newBuiltValueToStringHelper(r'OfflineSaleLineModifiersInner')
          ..add('optionId', optionId)
          ..add('quantity', quantity))
        .toString();
  }
}

class OfflineSaleLineModifiersInnerBuilder
    implements
        Builder<OfflineSaleLineModifiersInner,
            OfflineSaleLineModifiersInnerBuilder> {
  _$OfflineSaleLineModifiersInner? _$v;

  String? _optionId;
  String? get optionId => _$this._optionId;
  set optionId(String? optionId) => _$this._optionId = optionId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  OfflineSaleLineModifiersInnerBuilder() {
    OfflineSaleLineModifiersInner._defaults(this);
  }

  OfflineSaleLineModifiersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _optionId = $v.optionId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleLineModifiersInner other) {
    _$v = other as _$OfflineSaleLineModifiersInner;
  }

  @override
  void update(void Function(OfflineSaleLineModifiersInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleLineModifiersInner build() => _build();

  _$OfflineSaleLineModifiersInner _build() {
    final _$result = _$v ??
        _$OfflineSaleLineModifiersInner._(
          optionId: BuiltValueNullFieldError.checkNotNull(
              optionId, r'OfflineSaleLineModifiersInner', 'optionId'),
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
