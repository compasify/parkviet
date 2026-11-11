// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_settle_order_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformSettleOrderInput extends PlatformSettleOrderInput {
  @override
  final String id;
  @override
  final String? commissionAmount;

  factory _$PlatformSettleOrderInput(
          [void Function(PlatformSettleOrderInputBuilder)? updates]) =>
      (PlatformSettleOrderInputBuilder()..update(updates))._build();

  _$PlatformSettleOrderInput._({required this.id, this.commissionAmount})
      : super._();
  @override
  PlatformSettleOrderInput rebuild(
          void Function(PlatformSettleOrderInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettleOrderInputBuilder toBuilder() =>
      PlatformSettleOrderInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSettleOrderInput &&
        id == other.id &&
        commissionAmount == other.commissionAmount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, commissionAmount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformSettleOrderInput')
          ..add('id', id)
          ..add('commissionAmount', commissionAmount))
        .toString();
  }
}

class PlatformSettleOrderInputBuilder
    implements
        Builder<PlatformSettleOrderInput, PlatformSettleOrderInputBuilder> {
  _$PlatformSettleOrderInput? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _commissionAmount;
  String? get commissionAmount => _$this._commissionAmount;
  set commissionAmount(String? commissionAmount) =>
      _$this._commissionAmount = commissionAmount;

  PlatformSettleOrderInputBuilder() {
    PlatformSettleOrderInput._defaults(this);
  }

  PlatformSettleOrderInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _commissionAmount = $v.commissionAmount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSettleOrderInput other) {
    _$v = other as _$PlatformSettleOrderInput;
  }

  @override
  void update(void Function(PlatformSettleOrderInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSettleOrderInput build() => _build();

  _$PlatformSettleOrderInput _build() {
    final _$result = _$v ??
        _$PlatformSettleOrderInput._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PlatformSettleOrderInput', 'id'),
          commissionAmount: commissionAmount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
