// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_split_plan.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealSplitPlan extends MealSplitPlan {
  @override
  final String? mealAccountId;
  @override
  final String? payMode;
  @override
  final String total;
  @override
  final String? sponsorId;
  @override
  final String? sponsorName;
  @override
  final String sponsorAmount;
  @override
  final String employeeAmount;
  @override
  final bool sponsorUnavailable;

  factory _$MealSplitPlan([void Function(MealSplitPlanBuilder)? updates]) =>
      (MealSplitPlanBuilder()..update(updates))._build();

  _$MealSplitPlan._(
      {this.mealAccountId,
      this.payMode,
      required this.total,
      this.sponsorId,
      this.sponsorName,
      required this.sponsorAmount,
      required this.employeeAmount,
      required this.sponsorUnavailable})
      : super._();
  @override
  MealSplitPlan rebuild(void Function(MealSplitPlanBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealSplitPlanBuilder toBuilder() => MealSplitPlanBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealSplitPlan &&
        mealAccountId == other.mealAccountId &&
        payMode == other.payMode &&
        total == other.total &&
        sponsorId == other.sponsorId &&
        sponsorName == other.sponsorName &&
        sponsorAmount == other.sponsorAmount &&
        employeeAmount == other.employeeAmount &&
        sponsorUnavailable == other.sponsorUnavailable;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mealAccountId.hashCode);
    _$hash = $jc(_$hash, payMode.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, sponsorId.hashCode);
    _$hash = $jc(_$hash, sponsorName.hashCode);
    _$hash = $jc(_$hash, sponsorAmount.hashCode);
    _$hash = $jc(_$hash, employeeAmount.hashCode);
    _$hash = $jc(_$hash, sponsorUnavailable.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealSplitPlan')
          ..add('mealAccountId', mealAccountId)
          ..add('payMode', payMode)
          ..add('total', total)
          ..add('sponsorId', sponsorId)
          ..add('sponsorName', sponsorName)
          ..add('sponsorAmount', sponsorAmount)
          ..add('employeeAmount', employeeAmount)
          ..add('sponsorUnavailable', sponsorUnavailable))
        .toString();
  }
}

class MealSplitPlanBuilder
    implements Builder<MealSplitPlan, MealSplitPlanBuilder> {
  _$MealSplitPlan? _$v;

  String? _mealAccountId;
  String? get mealAccountId => _$this._mealAccountId;
  set mealAccountId(String? mealAccountId) =>
      _$this._mealAccountId = mealAccountId;

  String? _payMode;
  String? get payMode => _$this._payMode;
  set payMode(String? payMode) => _$this._payMode = payMode;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _sponsorId;
  String? get sponsorId => _$this._sponsorId;
  set sponsorId(String? sponsorId) => _$this._sponsorId = sponsorId;

  String? _sponsorName;
  String? get sponsorName => _$this._sponsorName;
  set sponsorName(String? sponsorName) => _$this._sponsorName = sponsorName;

  String? _sponsorAmount;
  String? get sponsorAmount => _$this._sponsorAmount;
  set sponsorAmount(String? sponsorAmount) =>
      _$this._sponsorAmount = sponsorAmount;

  String? _employeeAmount;
  String? get employeeAmount => _$this._employeeAmount;
  set employeeAmount(String? employeeAmount) =>
      _$this._employeeAmount = employeeAmount;

  bool? _sponsorUnavailable;
  bool? get sponsorUnavailable => _$this._sponsorUnavailable;
  set sponsorUnavailable(bool? sponsorUnavailable) =>
      _$this._sponsorUnavailable = sponsorUnavailable;

  MealSplitPlanBuilder() {
    MealSplitPlan._defaults(this);
  }

  MealSplitPlanBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mealAccountId = $v.mealAccountId;
      _payMode = $v.payMode;
      _total = $v.total;
      _sponsorId = $v.sponsorId;
      _sponsorName = $v.sponsorName;
      _sponsorAmount = $v.sponsorAmount;
      _employeeAmount = $v.employeeAmount;
      _sponsorUnavailable = $v.sponsorUnavailable;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealSplitPlan other) {
    _$v = other as _$MealSplitPlan;
  }

  @override
  void update(void Function(MealSplitPlanBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealSplitPlan build() => _build();

  _$MealSplitPlan _build() {
    final _$result = _$v ??
        _$MealSplitPlan._(
          mealAccountId: mealAccountId,
          payMode: payMode,
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'MealSplitPlan', 'total'),
          sponsorId: sponsorId,
          sponsorName: sponsorName,
          sponsorAmount: BuiltValueNullFieldError.checkNotNull(
              sponsorAmount, r'MealSplitPlan', 'sponsorAmount'),
          employeeAmount: BuiltValueNullFieldError.checkNotNull(
              employeeAmount, r'MealSplitPlan', 'employeeAmount'),
          sponsorUnavailable: BuiltValueNullFieldError.checkNotNull(
              sponsorUnavailable, r'MealSplitPlan', 'sponsorUnavailable'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
