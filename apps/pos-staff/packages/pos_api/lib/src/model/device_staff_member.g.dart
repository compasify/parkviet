// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_staff_member.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceStaffMember extends DeviceStaffMember {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool pinSet;

  factory _$DeviceStaffMember(
          [void Function(DeviceStaffMemberBuilder)? updates]) =>
      (DeviceStaffMemberBuilder()..update(updates))._build();

  _$DeviceStaffMember._(
      {required this.id, required this.name, required this.pinSet})
      : super._();
  @override
  DeviceStaffMember rebuild(void Function(DeviceStaffMemberBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceStaffMemberBuilder toBuilder() =>
      DeviceStaffMemberBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceStaffMember &&
        id == other.id &&
        name == other.name &&
        pinSet == other.pinSet;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, pinSet.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceStaffMember')
          ..add('id', id)
          ..add('name', name)
          ..add('pinSet', pinSet))
        .toString();
  }
}

class DeviceStaffMemberBuilder
    implements Builder<DeviceStaffMember, DeviceStaffMemberBuilder> {
  _$DeviceStaffMember? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _pinSet;
  bool? get pinSet => _$this._pinSet;
  set pinSet(bool? pinSet) => _$this._pinSet = pinSet;

  DeviceStaffMemberBuilder() {
    DeviceStaffMember._defaults(this);
  }

  DeviceStaffMemberBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _pinSet = $v.pinSet;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceStaffMember other) {
    _$v = other as _$DeviceStaffMember;
  }

  @override
  void update(void Function(DeviceStaffMemberBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceStaffMember build() => _build();

  _$DeviceStaffMember _build() {
    final _$result = _$v ??
        _$DeviceStaffMember._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DeviceStaffMember', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DeviceStaffMember', 'name'),
          pinSet: BuiltValueNullFieldError.checkNotNull(
              pinSet, r'DeviceStaffMember', 'pinSet'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
