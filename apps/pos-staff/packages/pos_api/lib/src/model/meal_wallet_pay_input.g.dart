// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_wallet_pay_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealWalletPayInput extends MealWalletPayInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final String? amount;

  factory _$MealWalletPayInput(
          [void Function(MealWalletPayInputBuilder)? updates]) =>
      (MealWalletPayInputBuilder()..update(updates))._build();

  _$MealWalletPayInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      this.amount})
      : super._();
  @override
  MealWalletPayInput rebuild(
          void Function(MealWalletPayInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealWalletPayInputBuilder toBuilder() =>
      MealWalletPayInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealWalletPayInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        amount == other.amount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealWalletPayInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('amount', amount))
        .toString();
  }
}

class MealWalletPayInputBuilder
    implements Builder<MealWalletPayInput, MealWalletPayInputBuilder> {
  _$MealWalletPayInput? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _leaseGeneration;
  int? get leaseGeneration => _$this._leaseGeneration;
  set leaseGeneration(int? leaseGeneration) =>
      _$this._leaseGeneration = leaseGeneration;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  MealWalletPayInputBuilder() {
    MealWalletPayInput._defaults(this);
  }

  MealWalletPayInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _amount = $v.amount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealWalletPayInput other) {
    _$v = other as _$MealWalletPayInput;
  }

  @override
  void update(void Function(MealWalletPayInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealWalletPayInput build() => _build();

  _$MealWalletPayInput _build() {
    final _$result = _$v ??
        _$MealWalletPayInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'MealWalletPayInput', 'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration, r'MealWalletPayInput', 'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'MealWalletPayInput', 'editorId'),
          amount: amount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
