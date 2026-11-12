// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_swipe.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MealSwipeResultEnum _$mealSwipeResultEnum_ok =
    const MealSwipeResultEnum._('ok');

MealSwipeResultEnum _$mealSwipeResultEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$mealSwipeResultEnum_ok;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MealSwipeResultEnum> _$mealSwipeResultEnumValues =
    BuiltSet<MealSwipeResultEnum>(const <MealSwipeResultEnum>[
  _$mealSwipeResultEnum_ok,
]);

Serializer<MealSwipeResultEnum> _$mealSwipeResultEnumSerializer =
    _$MealSwipeResultEnumSerializer();

class _$MealSwipeResultEnumSerializer
    implements PrimitiveSerializer<MealSwipeResultEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
  };

  @override
  final Iterable<Type> types = const <Type>[MealSwipeResultEnum];
  @override
  final String wireName = 'MealSwipeResultEnum';

  @override
  Object serialize(Serializers serializers, MealSwipeResultEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MealSwipeResultEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MealSwipeResultEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MealSwipe extends MealSwipe {
  @override
  final MealSwipeResultEnum result;
  @override
  final String? reason;
  @override
  final MealStatus? meal;
  @override
  final Workspace workspace;

  factory _$MealSwipe([void Function(MealSwipeBuilder)? updates]) =>
      (MealSwipeBuilder()..update(updates))._build();

  _$MealSwipe._(
      {required this.result, this.reason, this.meal, required this.workspace})
      : super._();
  @override
  MealSwipe rebuild(void Function(MealSwipeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealSwipeBuilder toBuilder() => MealSwipeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealSwipe &&
        result == other.result &&
        reason == other.reason &&
        meal == other.meal &&
        workspace == other.workspace;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, result.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, meal.hashCode);
    _$hash = $jc(_$hash, workspace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealSwipe')
          ..add('result', result)
          ..add('reason', reason)
          ..add('meal', meal)
          ..add('workspace', workspace))
        .toString();
  }
}

class MealSwipeBuilder implements Builder<MealSwipe, MealSwipeBuilder> {
  _$MealSwipe? _$v;

  MealSwipeResultEnum? _result;
  MealSwipeResultEnum? get result => _$this._result;
  set result(MealSwipeResultEnum? result) => _$this._result = result;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  MealStatusBuilder? _meal;
  MealStatusBuilder get meal => _$this._meal ??= MealStatusBuilder();
  set meal(MealStatusBuilder? meal) => _$this._meal = meal;

  WorkspaceBuilder? _workspace;
  WorkspaceBuilder get workspace => _$this._workspace ??= WorkspaceBuilder();
  set workspace(WorkspaceBuilder? workspace) => _$this._workspace = workspace;

  MealSwipeBuilder() {
    MealSwipe._defaults(this);
  }

  MealSwipeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _result = $v.result;
      _reason = $v.reason;
      _meal = $v.meal?.toBuilder();
      _workspace = $v.workspace.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealSwipe other) {
    _$v = other as _$MealSwipe;
  }

  @override
  void update(void Function(MealSwipeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealSwipe build() => _build();

  _$MealSwipe _build() {
    _$MealSwipe _$result;
    try {
      _$result = _$v ??
          _$MealSwipe._(
            result: BuiltValueNullFieldError.checkNotNull(
                result, r'MealSwipe', 'result'),
            reason: reason,
            meal: _meal?.build(),
            workspace: workspace.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'meal';
        _meal?.build();
        _$failedField = 'workspace';
        workspace.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealSwipe', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
