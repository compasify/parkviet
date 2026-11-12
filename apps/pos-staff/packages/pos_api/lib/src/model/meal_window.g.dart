// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_window.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealWindow extends MealWindow {
  @override
  final String key;
  @override
  final String from;
  @override
  final String to;
  @override
  final int? limit;

  factory _$MealWindow([void Function(MealWindowBuilder)? updates]) =>
      (MealWindowBuilder()..update(updates))._build();

  _$MealWindow._(
      {required this.key, required this.from, required this.to, this.limit})
      : super._();
  @override
  MealWindow rebuild(void Function(MealWindowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealWindowBuilder toBuilder() => MealWindowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealWindow &&
        key == other.key &&
        from == other.from &&
        to == other.to &&
        limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealWindow')
          ..add('key', key)
          ..add('from', from)
          ..add('to', to)
          ..add('limit', limit))
        .toString();
  }
}

class MealWindowBuilder implements Builder<MealWindow, MealWindowBuilder> {
  _$MealWindow? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _from;
  String? get from => _$this._from;
  set from(String? from) => _$this._from = from;

  String? _to;
  String? get to => _$this._to;
  set to(String? to) => _$this._to = to;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  MealWindowBuilder() {
    MealWindow._defaults(this);
  }

  MealWindowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _from = $v.from;
      _to = $v.to;
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealWindow other) {
    _$v = other as _$MealWindow;
  }

  @override
  void update(void Function(MealWindowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealWindow build() => _build();

  _$MealWindow _build() {
    final _$result = _$v ??
        _$MealWindow._(
          key: BuiltValueNullFieldError.checkNotNull(key, r'MealWindow', 'key'),
          from: BuiltValueNullFieldError.checkNotNull(
              from, r'MealWindow', 'from'),
          to: BuiltValueNullFieldError.checkNotNull(to, r'MealWindow', 'to'),
          limit: limit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
