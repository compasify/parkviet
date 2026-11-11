// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_keep_actor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BottleKeepActor extends BottleKeepActor {
  @override
  final String id;
  @override
  final String name;

  factory _$BottleKeepActor([void Function(BottleKeepActorBuilder)? updates]) =>
      (BottleKeepActorBuilder()..update(updates))._build();

  _$BottleKeepActor._({required this.id, required this.name}) : super._();
  @override
  BottleKeepActor rebuild(void Function(BottleKeepActorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleKeepActorBuilder toBuilder() => BottleKeepActorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleKeepActor && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'BottleKeepActor')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class BottleKeepActorBuilder
    implements Builder<BottleKeepActor, BottleKeepActorBuilder> {
  _$BottleKeepActor? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  BottleKeepActorBuilder() {
    BottleKeepActor._defaults(this);
  }

  BottleKeepActorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleKeepActor other) {
    _$v = other as _$BottleKeepActor;
  }

  @override
  void update(void Function(BottleKeepActorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleKeepActor build() => _build();

  _$BottleKeepActor _build() {
    final _$result = _$v ??
        _$BottleKeepActor._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BottleKeepActor', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BottleKeepActor', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
