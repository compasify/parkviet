// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_resolve.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealResolve extends MealResolve {
  @override
  final MealAccount? match;
  @override
  final BuiltList<MealAccount> suggestions;

  factory _$MealResolve([void Function(MealResolveBuilder)? updates]) =>
      (MealResolveBuilder()..update(updates))._build();

  _$MealResolve._({this.match, required this.suggestions}) : super._();
  @override
  MealResolve rebuild(void Function(MealResolveBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealResolveBuilder toBuilder() => MealResolveBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealResolve &&
        match == other.match &&
        suggestions == other.suggestions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, match.hashCode);
    _$hash = $jc(_$hash, suggestions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealResolve')
          ..add('match', match)
          ..add('suggestions', suggestions))
        .toString();
  }
}

class MealResolveBuilder implements Builder<MealResolve, MealResolveBuilder> {
  _$MealResolve? _$v;

  MealAccount? _match;
  MealAccount? get match => _$this._match;
  set match(MealAccount? match) => _$this._match = match;

  ListBuilder<MealAccount>? _suggestions;
  ListBuilder<MealAccount> get suggestions =>
      _$this._suggestions ??= ListBuilder<MealAccount>();
  set suggestions(ListBuilder<MealAccount>? suggestions) =>
      _$this._suggestions = suggestions;

  MealResolveBuilder() {
    MealResolve._defaults(this);
  }

  MealResolveBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _match = $v.match;
      _suggestions = $v.suggestions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealResolve other) {
    _$v = other as _$MealResolve;
  }

  @override
  void update(void Function(MealResolveBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealResolve build() => _build();

  _$MealResolve _build() {
    _$MealResolve _$result;
    try {
      _$result = _$v ??
          _$MealResolve._(
            match: match,
            suggestions: suggestions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'suggestions';
        suggestions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealResolve', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
