// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StaffRef extends StaffRef {
  @override
  final String id;
  @override
  final String? name;

  factory _$StaffRef([void Function(StaffRefBuilder)? updates]) =>
      (StaffRefBuilder()..update(updates))._build();

  _$StaffRef._({required this.id, this.name}) : super._();
  @override
  StaffRef rebuild(void Function(StaffRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StaffRefBuilder toBuilder() => StaffRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StaffRef && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'StaffRef')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class StaffRefBuilder implements Builder<StaffRef, StaffRefBuilder> {
  _$StaffRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  StaffRefBuilder() {
    StaffRef._defaults(this);
  }

  StaffRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StaffRef other) {
    _$v = other as _$StaffRef;
  }

  @override
  void update(void Function(StaffRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StaffRef build() => _build();

  _$StaffRef _build() {
    final _$result = _$v ??
        _$StaffRef._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'StaffRef', 'id'),
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
