// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_settle_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformSettleInput extends PlatformSettleInput {
  @override
  final String branchId;
  @override
  final String? reference;
  @override
  final BuiltList<PlatformSettleOrderInput> orders;

  factory _$PlatformSettleInput(
          [void Function(PlatformSettleInputBuilder)? updates]) =>
      (PlatformSettleInputBuilder()..update(updates))._build();

  _$PlatformSettleInput._(
      {required this.branchId, this.reference, required this.orders})
      : super._();
  @override
  PlatformSettleInput rebuild(
          void Function(PlatformSettleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettleInputBuilder toBuilder() =>
      PlatformSettleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSettleInput &&
        branchId == other.branchId &&
        reference == other.reference &&
        orders == other.orders;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, reference.hashCode);
    _$hash = $jc(_$hash, orders.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformSettleInput')
          ..add('branchId', branchId)
          ..add('reference', reference)
          ..add('orders', orders))
        .toString();
  }
}

class PlatformSettleInputBuilder
    implements Builder<PlatformSettleInput, PlatformSettleInputBuilder> {
  _$PlatformSettleInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _reference;
  String? get reference => _$this._reference;
  set reference(String? reference) => _$this._reference = reference;

  ListBuilder<PlatformSettleOrderInput>? _orders;
  ListBuilder<PlatformSettleOrderInput> get orders =>
      _$this._orders ??= ListBuilder<PlatformSettleOrderInput>();
  set orders(ListBuilder<PlatformSettleOrderInput>? orders) =>
      _$this._orders = orders;

  PlatformSettleInputBuilder() {
    PlatformSettleInput._defaults(this);
  }

  PlatformSettleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _reference = $v.reference;
      _orders = $v.orders.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSettleInput other) {
    _$v = other as _$PlatformSettleInput;
  }

  @override
  void update(void Function(PlatformSettleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSettleInput build() => _build();

  _$PlatformSettleInput _build() {
    _$PlatformSettleInput _$result;
    try {
      _$result = _$v ??
          _$PlatformSettleInput._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PlatformSettleInput', 'branchId'),
            reference: reference,
            orders: orders.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'orders';
        orders.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformSettleInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
