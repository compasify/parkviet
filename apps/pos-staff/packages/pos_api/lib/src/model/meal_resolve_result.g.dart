// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_resolve_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealResolveResult extends MealResolveResult {
  @override
  final MealResolve data;

  factory _$MealResolveResult(
          [void Function(MealResolveResultBuilder)? updates]) =>
      (MealResolveResultBuilder()..update(updates))._build();

  _$MealResolveResult._({required this.data}) : super._();
  @override
  MealResolveResult rebuild(void Function(MealResolveResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealResolveResultBuilder toBuilder() =>
      MealResolveResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealResolveResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'MealResolveResult')
          ..add('data', data))
        .toString();
  }
}

class MealResolveResultBuilder
    implements Builder<MealResolveResult, MealResolveResultBuilder> {
  _$MealResolveResult? _$v;

  MealResolveBuilder? _data;
  MealResolveBuilder get data => _$this._data ??= MealResolveBuilder();
  set data(MealResolveBuilder? data) => _$this._data = data;

  MealResolveResultBuilder() {
    MealResolveResult._defaults(this);
  }

  MealResolveResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealResolveResult other) {
    _$v = other as _$MealResolveResult;
  }

  @override
  void update(void Function(MealResolveResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealResolveResult build() => _build();

  _$MealResolveResult _build() {
    _$MealResolveResult _$result;
    try {
      _$result = _$v ??
          _$MealResolveResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealResolveResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
