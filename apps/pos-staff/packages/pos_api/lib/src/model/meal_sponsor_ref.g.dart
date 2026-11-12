// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_sponsor_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MealSponsorRef extends MealSponsorRef {
  @override
  final String id;
  @override
  final String name;

  factory _$MealSponsorRef([void Function(MealSponsorRefBuilder)? updates]) =>
      (MealSponsorRefBuilder()..update(updates))._build();

  _$MealSponsorRef._({required this.id, required this.name}) : super._();
  @override
  MealSponsorRef rebuild(void Function(MealSponsorRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealSponsorRefBuilder toBuilder() => MealSponsorRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealSponsorRef && id == other.id && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealSponsorRef')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class MealSponsorRefBuilder
    implements Builder<MealSponsorRef, MealSponsorRefBuilder> {
  _$MealSponsorRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  MealSponsorRefBuilder() {
    MealSponsorRef._defaults(this);
  }

  MealSponsorRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealSponsorRef other) {
    _$v = other as _$MealSponsorRef;
  }

  @override
  void update(void Function(MealSponsorRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealSponsorRef build() => _build();

  _$MealSponsorRef _build() {
    final _$result = _$v ??
        _$MealSponsorRef._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MealSponsorRef', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MealSponsorRef', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
