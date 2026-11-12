// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_wallet_pay.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealWalletPay extends MealWalletPay {
  @override
  final Workspace workspace;
  @override
  final MealStatus meal;

  factory _$MealWalletPay([void Function(MealWalletPayBuilder)? updates]) =>
      (MealWalletPayBuilder()..update(updates))._build();

  _$MealWalletPay._({required this.workspace, required this.meal}) : super._();
  @override
  MealWalletPay rebuild(void Function(MealWalletPayBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealWalletPayBuilder toBuilder() => MealWalletPayBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealWalletPay &&
        workspace == other.workspace &&
        meal == other.meal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspace.hashCode);
    _$hash = $jc(_$hash, meal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealWalletPay')
          ..add('workspace', workspace)
          ..add('meal', meal))
        .toString();
  }
}

class MealWalletPayBuilder
    implements Builder<MealWalletPay, MealWalletPayBuilder> {
  _$MealWalletPay? _$v;

  WorkspaceBuilder? _workspace;
  WorkspaceBuilder get workspace => _$this._workspace ??= WorkspaceBuilder();
  set workspace(WorkspaceBuilder? workspace) => _$this._workspace = workspace;

  MealStatusBuilder? _meal;
  MealStatusBuilder get meal => _$this._meal ??= MealStatusBuilder();
  set meal(MealStatusBuilder? meal) => _$this._meal = meal;

  MealWalletPayBuilder() {
    MealWalletPay._defaults(this);
  }

  MealWalletPayBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspace = $v.workspace.toBuilder();
      _meal = $v.meal.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealWalletPay other) {
    _$v = other as _$MealWalletPay;
  }

  @override
  void update(void Function(MealWalletPayBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealWalletPay build() => _build();

  _$MealWalletPay _build() {
    _$MealWalletPay _$result;
    try {
      _$result = _$v ??
          _$MealWalletPay._(
            workspace: workspace.build(),
            meal: meal.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'workspace';
        workspace.build();
        _$failedField = 'meal';
        meal.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealWalletPay', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
