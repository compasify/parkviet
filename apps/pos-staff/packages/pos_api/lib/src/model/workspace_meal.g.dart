// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_meal.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceMeal extends WorkspaceMeal {
  @override
  final String workspaceId;
  @override
  final MealStatus? meal;
  @override
  final MealSplitPlan plan;

  factory _$WorkspaceMeal([void Function(WorkspaceMealBuilder)? updates]) =>
      (WorkspaceMealBuilder()..update(updates))._build();

  _$WorkspaceMeal._({required this.workspaceId, this.meal, required this.plan})
      : super._();
  @override
  WorkspaceMeal rebuild(void Function(WorkspaceMealBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceMealBuilder toBuilder() => WorkspaceMealBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceMeal &&
        workspaceId == other.workspaceId &&
        meal == other.meal &&
        plan == other.plan;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, meal.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceMeal')
          ..add('workspaceId', workspaceId)
          ..add('meal', meal)
          ..add('plan', plan))
        .toString();
  }
}

class WorkspaceMealBuilder
    implements Builder<WorkspaceMeal, WorkspaceMealBuilder> {
  _$WorkspaceMeal? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  MealStatusBuilder? _meal;
  MealStatusBuilder get meal => _$this._meal ??= MealStatusBuilder();
  set meal(MealStatusBuilder? meal) => _$this._meal = meal;

  MealSplitPlanBuilder? _plan;
  MealSplitPlanBuilder get plan => _$this._plan ??= MealSplitPlanBuilder();
  set plan(MealSplitPlanBuilder? plan) => _$this._plan = plan;

  WorkspaceMealBuilder() {
    WorkspaceMeal._defaults(this);
  }

  WorkspaceMealBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _meal = $v.meal?.toBuilder();
      _plan = $v.plan.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceMeal other) {
    _$v = other as _$WorkspaceMeal;
  }

  @override
  void update(void Function(WorkspaceMealBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceMeal build() => _build();

  _$WorkspaceMeal _build() {
    _$WorkspaceMeal _$result;
    try {
      _$result = _$v ??
          _$WorkspaceMeal._(
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'WorkspaceMeal', 'workspaceId'),
            meal: _meal?.build(),
            plan: plan.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'meal';
        _meal?.build();
        _$failedField = 'plan';
        plan.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceMeal', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
