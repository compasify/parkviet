// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_schedules_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MenuSchedulesInner extends MenuSchedulesInner {
  @override
  final String id;
  @override
  final String name;

  factory _$MenuSchedulesInner(
          [void Function(MenuSchedulesInnerBuilder)? updates]) =>
      (MenuSchedulesInnerBuilder()..update(updates))._build();

  _$MenuSchedulesInner._({required this.id, required this.name}) : super._();
  @override
  MenuSchedulesInner rebuild(
          void Function(MenuSchedulesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuSchedulesInnerBuilder toBuilder() =>
      MenuSchedulesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuSchedulesInner && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'MenuSchedulesInner')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class MenuSchedulesInnerBuilder
    implements Builder<MenuSchedulesInner, MenuSchedulesInnerBuilder> {
  _$MenuSchedulesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  MenuSchedulesInnerBuilder() {
    MenuSchedulesInner._defaults(this);
  }

  MenuSchedulesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MenuSchedulesInner other) {
    _$v = other as _$MenuSchedulesInner;
  }

  @override
  void update(void Function(MenuSchedulesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuSchedulesInner build() => _build();

  _$MenuSchedulesInner _build() {
    final _$result = _$v ??
        _$MenuSchedulesInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MenuSchedulesInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MenuSchedulesInner', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
