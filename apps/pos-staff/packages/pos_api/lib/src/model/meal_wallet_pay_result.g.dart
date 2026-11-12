// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_wallet_pay_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealWalletPayResult extends MealWalletPayResult {
  @override
  final MealWalletPay data;

  factory _$MealWalletPayResult(
          [void Function(MealWalletPayResultBuilder)? updates]) =>
      (MealWalletPayResultBuilder()..update(updates))._build();

  _$MealWalletPayResult._({required this.data}) : super._();
  @override
  MealWalletPayResult rebuild(
          void Function(MealWalletPayResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealWalletPayResultBuilder toBuilder() =>
      MealWalletPayResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealWalletPayResult && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealWalletPayResult')
          ..add('data', data))
        .toString();
  }
}

class MealWalletPayResultBuilder
    implements Builder<MealWalletPayResult, MealWalletPayResultBuilder> {
  _$MealWalletPayResult? _$v;

  MealWalletPayBuilder? _data;
  MealWalletPayBuilder get data => _$this._data ??= MealWalletPayBuilder();
  set data(MealWalletPayBuilder? data) => _$this._data = data;

  MealWalletPayResultBuilder() {
    MealWalletPayResult._defaults(this);
  }

  MealWalletPayResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealWalletPayResult other) {
    _$v = other as _$MealWalletPayResult;
  }

  @override
  void update(void Function(MealWalletPayResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealWalletPayResult build() => _build();

  _$MealWalletPayResult _build() {
    _$MealWalletPayResult _$result;
    try {
      _$result = _$v ??
          _$MealWalletPayResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealWalletPayResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
