// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_swipe_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealSwipeResult extends MealSwipeResult {
  @override
  final MealSwipe data;

  factory _$MealSwipeResult([void Function(MealSwipeResultBuilder)? updates]) =>
      (MealSwipeResultBuilder()..update(updates))._build();

  _$MealSwipeResult._({required this.data}) : super._();
  @override
  MealSwipeResult rebuild(void Function(MealSwipeResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealSwipeResultBuilder toBuilder() => MealSwipeResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealSwipeResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'MealSwipeResult')..add('data', data))
        .toString();
  }
}

class MealSwipeResultBuilder
    implements Builder<MealSwipeResult, MealSwipeResultBuilder> {
  _$MealSwipeResult? _$v;

  MealSwipeBuilder? _data;
  MealSwipeBuilder get data => _$this._data ??= MealSwipeBuilder();
  set data(MealSwipeBuilder? data) => _$this._data = data;

  MealSwipeResultBuilder() {
    MealSwipeResult._defaults(this);
  }

  MealSwipeResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealSwipeResult other) {
    _$v = other as _$MealSwipeResult;
  }

  @override
  void update(void Function(MealSwipeResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealSwipeResult build() => _build();

  _$MealSwipeResult _build() {
    _$MealSwipeResult _$result;
    try {
      _$result = _$v ??
          _$MealSwipeResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealSwipeResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
