// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant_staff.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AttendantStaff extends AttendantStaff {
  @override
  final String id;
  @override
  final String name;

  factory _$AttendantStaff([void Function(AttendantStaffBuilder)? updates]) =>
      (AttendantStaffBuilder()..update(updates))._build();

  _$AttendantStaff._({required this.id, required this.name}) : super._();
  @override
  AttendantStaff rebuild(void Function(AttendantStaffBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendantStaffBuilder toBuilder() => AttendantStaffBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AttendantStaff && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'AttendantStaff')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class AttendantStaffBuilder
    implements Builder<AttendantStaff, AttendantStaffBuilder> {
  _$AttendantStaff? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AttendantStaffBuilder() {
    AttendantStaff._defaults(this);
  }

  AttendantStaffBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AttendantStaff other) {
    _$v = other as _$AttendantStaff;
  }

  @override
  void update(void Function(AttendantStaffBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AttendantStaff build() => _build();

  _$AttendantStaff _build() {
    final _$result = _$v ??
        _$AttendantStaff._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AttendantStaff', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AttendantStaff', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
